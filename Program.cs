/*
MIT License

Copyright (c) 2021 Bosch Rexroth AG

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/


using comm.datalayer;
using Datalayer;
using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace Samples.Datalayer.Client
{
    class Program
    {
        /// <summary>
        /// The Main method is the entry point of an executable app.
        /// </summary>
        /// <param name="args">The args<see cref="string"/>.</param>
        static async Task Main(string[] args)
        {
            // Create a new ctrlX Data Layer system
            using var system = new DatalayerSystem();

            // Starts the ctrlX Data Layer system without a new broker (startBroker = false) because one broker is already running on ctrlX device
            system.Start(startBroker: false);
            Console.WriteLine("INIT-TEST");
            Console.WriteLine("ctrlX Data Layer system started.");

            // Create a connection string with the parameters according to your environment (see DatalayerHelper class)
            var ip_address = "192.168.1.100";
            var connectionString = DatalayerHelper.GetConnectionString(ip: ip_address, sslPort: 443);

            // Create the client with remote connection string
            using var client = system.Factory.CreateClient(connectionString);
            Console.WriteLine("ctrlX Data Layer client created.");

            // Check if client is connected
            if (!client.IsConnected)
            {
                // We exit and retry after app daemon restart-delay (see snapcraft.yaml)
                Console.WriteLine($"Client is not connected -> exit");
                return;
            }

            // WebDav configuration
            var webDavInterface = new WebDavInterface("192.168.1.100", "443", "sgilk", "sgilk");
            var root_URI = "https://192.168.1.100:443/solutions/webdav/appdata/comm.ethercat.master/config/ethercatmaster/ethercat.xml";
            await webDavInterface.Browse("solutions/webdav/appdata/comm.ethercat.master/config/ethercatmaster/");
            await webDavInterface.Client.Delete(root_URI);
            await webDavInterface.Client.PutFile("https://192.168.1.100:443/solutions/webdav/appdata/comm.ethercat.master/config/ethercatmaster/ethercat.xml", File.OpenRead("TEST/ethercat_new.xml")); // upload a resource

            // Define the subscription properties by using helper class SubscriptionPropertiesBuilder.
            var propertiesFlatbuffers = new SubscriptionPropertiesBuilder("mySubscription")
                .SetKeepAliveIntervalMillis(60000)
                .SetPublishIntervalMillis(40)
                .SetErrorIntervalMillis(10000)
                .SetSamplingIntervalMillis(20)
                .SetChangeEvents(DataChangeTrigger.StatusValue)
                .Build();

            // Create the subscription
            var (createResult, subscription) = client.CreateSubscription(propertiesFlatbuffers, userData: null);
            if (createResult.IsBad())
            {
                Console.WriteLine($"Failed to create subscription: {createResult}");
                return;
            }

            // Add DataChanged Event Handler
            subscription.DataChanged += (subscription, eventArgs) =>
            {
                var notifyInfo = NotifyInfo.GetRootAsNotifyInfo(eventArgs.Item.Info.ToFlatbuffers());
                var timestamp = DateTime.FromFileTime(Convert.ToInt64(notifyInfo.Timestamp));
                var timeStampFile = timestamp.ToString("MM/dd/yyyy hh:mm:ss.fff tt");
                if (notifyInfo.Node == "")
                {
                    Console.WriteLine($"{timeStampFile}, No value change.");
                }
                else
                {
                    Console.WriteLine($"{timeStampFile}, {notifyInfo.Node}: {eventArgs.Item.Value.ToFloat()} (subscription)");
                }

            };

            // Subscribe the Node with address 'fieldbuses/ethercat/master/instances/ethercatmaster/realtime_data/input/data/EL1008/Channel_2.Input'
            const string address = "fieldbuses/ethercat/master/instances/ethercatmaster/realtime_data/input/data/EL1008/Channel_2.Input"; //"system/health/temperature-cpu/value";
            var subscribeResult = subscription.Subscribe(address: address);
            if (subscribeResult.IsBad())
            {
                Console.WriteLine($"Failed to subscribe: {subscribeResult}");
                return;
            }

            //Just keep the process running
            while (true)
            {
                if (!client.IsConnected)
                {
                    Console.WriteLine("Client disconnected.");
                }
                Thread.Sleep(1000);
            }
        }
    }
}
