#!/usr/bin/env python3 -u

# MIT License
#
# Copyright (c) 2021-2022 Bosch Rexroth AG
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import sys

import subprocess
import time

import typing
from datetime import datetime

from comm.datalayer import Metadata

import ctrlxdatalayer
from ctrlxdatalayer.variant import Result, Variant, VariantType

import ctrlxdatalayer.subscription
from ctrlxdatalayer.client import Client

from helper.ctrlx_datalayer_helper import get_client, connection_ip, get_provider
from alldataprovider.nodeManagerAllData import NodeManagerAllData

# addresses of provided values
address_base = "ctrlx-datalayer-mqtt-interface/"
datalayer_system = ctrlxdatalayer.system.System("")
update_flag = False
address_input = ""


def main():
    print("Running datalayer interface...")
    with datalayer_system:
        datalayer_system.start(False)

        datalayer_client, datalayer_client_connection_string = get_client(
            datalayer_system)

        if datalayer_client is None:
            print("ERROR Connecting", datalayer_client_connection_string, "failed.")
            sys.exit(1)

        provider, connection_string = get_provider(datalayer_system)
        if provider is None:
            print("ERROR Connecting", connection_string, "failed.")
            datalayer_system.stop(False)
            sys.exit(1)

        with provider:
            # Provide datalayer node to set MQTT tree
            nodeManager = NodeManagerAllData(provider, address_base)
            data = Variant()
            data.set_string("")
            node_address = address_base + "MQTT_Root"
            nodeManager.create_single_node(addressBranch=node_address, addressType="string", name="",
                                           unit="string", description="Path to MQTT root", dynamic=True, data=data)

            with datalayer_client:  # datalayer_client is closed automatically when leaving with block
                # If not connected exit and retry with app daemon restart-delay (see snapcraft.yaml)
                if datalayer_client.is_connected() is False:

                    print("ERROR Not connected to", datalayer_client_connection_string,
                          "- restarting app after a delay of 10 s ...")
                    sys.exit(2)

                # Subscribe to MQTT root datalayer node
                subscription_properties = ctrlxdatalayer.subscription.create_properties(
                    "datalayer-client-sub", publish_interval=1000)
                if subscription_properties is None:
                    print("ERROR create_properties() returned: None")
                    sys.exit(1)

                with subscription_properties:
                    print("Creating subscription to MQTT root node...")
                    result, subscription = subscribe_single(
                        datalayer_client, subscription_properties, node_address, rncb_root)

                    if result != Result.OK:
                        print("ERROR subscribe_single() failed with:", result)
                        sys.exit(1)

                    if subscription is None:
                        print("ERROR subscribe_single() returned None")
                        sys.exit(1)

                    with subscription:
                        # Endless loop
                        while datalayer_client.is_connected():
                            global update_flag
                            global address_input
                            if update_flag:
                                update_flag = False
                                if address_input != "" and address_input is not None:
                                    browse_tree(
                                        datalayer_client, datalayer_system.json_converter(), address_input)
                            time.sleep(1.0)

                        subscription.unsubscribe_all()
                        provider.stop()

        print("Stopping Datalayer System")
        # Attention: Doesn't return if any provider or client instance is still running
        stop_ok = datalayer_system.stop(False)
        print("System Stop", stop_ok)


def rncb_root(result: Result, items: typing.List[ctrlxdatalayer.subscription.NotifyItem], userdata: ctrlxdatalayer.clib.userData_c_void_p):
    now = datetime.now().time()
    print(now, "--------------------------ROOT------------------------")
    print(userdata)
    print("ResponseNotifyCallback", result)

    if result != Result.OK:
        return

    if items is None:
        print("No items")
        return

    print("Number of items", len(items))
    if len(items) <= 0:
        return

    n = 1
    for item in items:
        vt = item.get_data().get_type()
        if vt == VariantType.UNKNON:
            return
        else:
            print("#", n)
            print("  address:", item.get_address())
            vt = item.get_data().get_type()
            print("  type:", vt)
            value = item.get_data().get_string()
            print("  value:", item.get_data().get_string())
            if vt == VariantType.STRING:
                global address_input
                address_input = value
                global update_flag
                update_flag = True
            print("  timestamp:", item.get_timestamp())
            print("  datetime:", ctrlxdatalayer.subscription.to_datetime(
                item.get_timestamp()))
            n = n + 1


def rncb_node(result: Result, items: typing.List[ctrlxdatalayer.subscription.NotifyItem], userdata: ctrlxdatalayer.clib.userData_c_void_p):
    now = datetime.now().time()
    print(now, "-------------------------NODE-------------------------")
    print(userdata)
    print("ResponseNotifyCallback", result)

    if result != Result.OK:
        return

    if items is None:
        print("No items")
        return

    print("Number of items", len(items))
    if len(items) <= 0:
        return

    n = 1
    for item in items:
        vt = item.get_data().get_type()
        if vt == VariantType.UNKNON:
            return
        else:
            print("#", n)
            address = item.get_address()
            print("  address:", address)
            print("  type:", vt)
            data = item.get_data()
            value = None
            if vt == VariantType.ARRAY_BOOL8:
                value = data.get_array_bool8()

            if vt == VariantType.ARRAY_FLOAT32:
                value = data.get_array_float32()

            if vt == VariantType.ARRAY_FLOAT64:
                value = data.get_array_float64()

            if vt == VariantType.ARRAY_INT16:
                value = data.get_array_int16()

            if vt == VariantType.ARRAY_INT32:
                value = data.get_array_int32()

            if vt == VariantType.ARRAY_INT64:
                value = data.get_array_int64()

            if vt == VariantType.ARRAY_INT8:
                value = data.get_array_int8()

            if vt == VariantType.ARRAY_STRING:
                value = data.get_array_string()

            if vt == VariantType.ARRAY_UINT16:
                value = data.get_array_uint16()

            if vt == VariantType.ARRAY_UINT32:
                value = data.get_array_uint32()

            if vt == VariantType.ARRAY_UINT64:
                value = data.get_array_uint64()

            if vt == VariantType.ARRAY_UINT8:
                value = data.get_array_uint8()

            if vt == VariantType.BOOL8:
                value = data.get_bool8()

            if vt == VariantType.FLOAT32:
                value = data.get_float32()

            if vt == VariantType.FLOAT64:
                value = data.get_float64()

            if vt == VariantType.INT16:
                value = data.get_int16()

            if vt == VariantType.INT32:
                value = data.get_int32()

            if vt == VariantType.INT64:
                value = data.get_int64()

            if vt == VariantType.INT8:
                value = data.get_int8()

            if vt == VariantType.STRING:
                value = data.get_string()

            if vt == VariantType.UINT16:
                value = data.get_uint16()

            if vt == VariantType.UINT32:
                value = data.get_uint32()

            if vt == VariantType.UINT64:
                value = data.get_uint64()

            if vt == VariantType.UINT8:
                value = data.get_uint8()

            if vt == VariantType.FLATBUFFERS:
                print("Flatbuffers not supported")
                value = ""

            if value is None:
                print("WARNING Unknown Variant Type:", vt)
            else:
                print("  value:", value)

            if address != "":
                subprocess.run(["/app/mosquitto_publish.sh",
                                connection_ip, address, str(value)])

            print("  timestamp:", item.get_timestamp())
            print("  datetime:", ctrlxdatalayer.subscription.to_datetime(
                item.get_timestamp()))
            n = n + 1


def subscribe_single(client: Client, subscription_properties: Variant, address: str, callback: ctrlxdatalayer.subscription.ResponseNotifyCallback):

    print(
        f"subscribe_single() +++++++++++++++:{address}")
    if address == "" or address is None:
        print("ERROR subscribe_single() failed with: invalid address")
        return
    else:
        result, subscription = client.create_subscription_sync(
            subscription_properties, callback, address)

        if result != Result.OK:
            print("ERROR create_subscription_sync() failed with:", result)
            return result, None

        if subscription is None:
            print("ERROR create_subscription_sync() returned: None")
            return Result.CREATION_FAILED, None

        if address is not None and address != "":
            result = subscription.subscribe(address)

        return result, subscription


def browse_tree(client: ctrlxdatalayer.client.Client, converter: ctrlxdatalayer.system.Converter, address: str):
    if address is None or address == "":
        print("ERROR Browsing Data Layer failed with: NoneType address")
        return
    else:
        # print current address and get value of node
        node_value = get_value(client, converter, address)

        if node_value is None:
            print(address)
        else:
            if type(node_value) is not list:
                # Subscribe to new topics on datalayer
                subscription_properties = ctrlxdatalayer.subscription.create_properties(
                    address, publish_interval=100)
                subprocess.run(["/app/echo.sh", address])
                result, subscription = subscribe_single(
                    client, subscription_properties, address, rncb_node)
                if result != Result.OK:
                    print("ERROR subscribe_single() failed with:", result)
                    sys.exit(1)

                if subscription is None:
                    print("ERROR subscribe_single() returned None")
                    sys.exit(1)

        # Browse Data Layer tree
        result, data = client.browse_sync(address)
        if result != Result.OK:
            print("ERROR Browsing Data Layer failed with: ", result)
            return
        with data:
            # Recursive loop
            nodes = data.get_array_string()
            for node in nodes:
                browse_tree(client, converter, address + "/" + node)


def get_value(client: ctrlxdatalayer.client.Client, converter: ctrlxdatalayer.system.Converter, address: str):

    # get data with read sync
    result, data = client.read_sync(address)
    if result != Result.OK:
        # print("ERROR Reading Data Layer failed with: ", result)
        return
    with data:

        vt = data.get_type()

        if vt == VariantType.ARRAY_BOOL8:
            return data.get_array_bool8()

        if vt == VariantType.ARRAY_FLOAT32:
            return data.get_array_float32()

        if vt == VariantType.ARRAY_FLOAT64:
            return data.get_array_float64()

        if vt == VariantType.ARRAY_INT16:
            return data.get_array_int16()

        if vt == VariantType.ARRAY_INT32:
            return data.get_array_int32()

        if vt == VariantType.ARRAY_INT64:
            return data.get_array_int64()

        if vt == VariantType.ARRAY_INT8:
            return data.get_array_int8()

        if vt == VariantType.ARRAY_STRING:
            return data.get_array_string()

        if vt == VariantType.ARRAY_UINT16:
            return data.get_array_uint16()

        if vt == VariantType.ARRAY_UINT32:
            return data.get_array_uint32()

        if vt == VariantType.ARRAY_UINT64:
            return data.get_array_uint64()

        if vt == VariantType.ARRAY_UINT8:
            return data.get_array_uint8()

        if vt == VariantType.BOOL8:
            return data.get_bool8()

        if vt == VariantType.FLATBUFFERS:

            # Get type address for flatbuffers information
            typeAddress = get_typeaddress(client, address)
            if typeAddress is None:
                print("ERROR Type Address is none")
                return

            # Read type address as variant
            result, typeVar = client.read_sync(typeAddress)
            if result != Result.OK:
                print("ERROR Reading Type Value failed with: ", result)
                return

            # Convert variant flatbuffers data to json type
            result, json = converter.converter_generate_json_complex(
                data, typeVar, -1)
            if result != Result.OK:
                print("ERROR Converting json failed with: ", result)
                return

            return json.get_string()

        if vt == VariantType.FLOAT32:
            return data.get_float32()

        if vt == VariantType.FLOAT64:
            return data.get_float64()

        if vt == VariantType.INT16:
            return data.get_int16()

        if vt == VariantType.INT32:
            return data.get_int32()

        if vt == VariantType.INT64:
            return data.get_int64()

        if vt == VariantType.INT8:
            return data.get_int8()

        if vt == VariantType.STRING:
            return data.get_string()

        if vt == VariantType.UINT16:
            return data.get_uint16()

        if vt == VariantType.UINT32:
            return data.get_uint32()

        if vt == VariantType.UINT64:
            return data.get_uint64()

        if vt == VariantType.UINT8:
            return data.get_uint8()

        print("WARNING Unknown Variant Type:", vt)
        return None


def get_typeaddress(client: ctrlxdatalayer.client.Client, address: str):
    read_typeaddress = ""

    result, metadata = client.metadata_sync(address)
    if result != Result.OK:
        print("ERROR Reading metadata of ", address, " failed with: ", result)
        return

    metadata_root = Metadata.Metadata.GetRootAsMetadata(
        metadata.get_flatbuffers())

    if metadata_root.ReferencesLength() == 0:
        print("ERROR Metadata references are empty")
        return

    for i in range(0, metadata_root.ReferencesLength()):
        reference = metadata_root.References(i)

        if reference is None:
            continue

        if reference.Type().decode('utf-8').lower() == "readtype":
            read_typeaddress = reference.TargetAddress().decode('utf-8')
            break

    return read_typeaddress


if __name__ == '__main__':
    main()
