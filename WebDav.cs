using WebDav;
using System;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Collections.Generic;

public class WebDavInterface
{
    private string ip_address;
    private string port;

    public WebDavClient Client;
    public WebDavInterface(string _ip_address, string _port, string _username, string _password)
    {
        port = _port;
        ip_address = _ip_address;
        // WebDav connection
        var httpClientHandler = new HttpClientHandler();
        httpClientHandler.ServerCertificateCustomValidationCallback = (message, cert, chain, sslPolicyErrors) =>
        {
            return true;
        };
        httpClientHandler.Credentials = new NetworkCredential(_username, _password);
        var httpClient = new HttpClient(httpClientHandler) { BaseAddress = new Uri($"http://{ip_address}") };
        Client = new WebDavClient(httpClient);
    }

    // Example path (solutions/webdav/appdata/comm.ethercat.master/config/ethercatmaster/)
    public async Task<string[]> Browse(string path)
    {
        List<string> file_list = new List<string>();
        var root_URI = $"https://{ip_address}:{port}/{path}";
        var result = await Client.Propfind(root_URI);
        if (result.IsSuccessful)
        {
            // list files & subdirectories in ethercat directory
            foreach (var res in result.Resources)
            {
                file_list.Add(res.DisplayName);
                Console.WriteLine("Name: " + res.DisplayName);
            }
        }
        else
        {
            file_list.Add(result.ToString());
            Console.WriteLine(result);
        }
        return file_list.ToArray();
    }
}




