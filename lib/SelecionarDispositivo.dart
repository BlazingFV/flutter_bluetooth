// ignore_for_file: file_names

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:layout/ListaBluetooth.dart';
import 'package:layout/HomePage.dart';
import 'package:layout/provider/StatusConexaoProvider.dart';
import 'package:layout/provider/shared_prefs_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/CustomAppBar.dart';

class SelecionarDispositivoPage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.
  final bool checkAvailability;

  const SelecionarDispositivoPage({this.checkAvailability = true});

  @override
  _SelecionarDispositivoPage createState() => _SelecionarDispositivoPage();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice? device;
  _DeviceAvailability? availability;
  int? rssi;

  DeviceWithAvailability(this.device, this.availability, [this.rssi])
      : super(address: device!.address);

  factory DeviceWithAvailability.fromJson(Map<String, dynamic> parsedJson) {
    return DeviceWithAvailability(
      parsedJson['device'],
      parsedJson['availability'],
      parsedJson['rssi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device': device,
      'availability': availability,
      'rssi': rssi,
    };
  }
}

class _SelecionarDispositivoPage extends State<SelecionarDispositivoPage> {
  List<DeviceWithAvailability> devices = <DeviceWithAvailability>[];
  DeviceWithAvailability? device;
  DeviceWithAvailability? deviceSaving;
  SharedPreferences? prefs;
  String macAddress = '';
  bool deviceFound = false;

  // Availability
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  bool? _isDiscovering;

  _SelecionarDispositivoPage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _isDiscovering = widget.checkAvailability;

      if (_isDiscovering!) {
        _startDiscovery();
      }

      // Setup a list of the bonded devices
      FlutterBluetoothSerial.instance
          .getBondedDevices()
          .then((List<BluetoothDevice> bondedDevices) {
        setState(() {
          devices = bondedDevices
              .map(
                (device) => DeviceWithAvailability(
                  device,
                  widget.checkAvailability
                      ? _DeviceAvailability.maybe
                      : _DeviceAvailability.yes,
                ),
              )
              .toList();
        });
      });

      macAddress =
          await Provider.of<SharedPreferencesProvider>(context, listen: false)
              .getMacAddress();
      log('macAddress: $macAddress');
      if (devices.isNotEmpty) {
         Provider.of<StatusConexaoProvider>(context, listen: false).setActiveDevice(devices);
        Provider.of<StatusConexaoProvider>(context, listen: false).setDevice(
            devices
                .firstWhere((element) => element.address == macAddress)
                .device);
        setState(() {
          device =
              devices.firstWhere((element) => element.address == macAddress);
        });
        // log(' Device:${device!.address}');
        // Provider.of<SharedPreferencesProvider>(context, listen: false)
        //     .saveDeviceObject(device!.toJson());
      }
      if (Provider.of<StatusConexaoProvider>(context, listen: false).device !=
          null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            settings: const RouteSettings(name: '/'),
            builder: (context) => const HomePage()));
      }

      // device =       Provider.of<StatusConexaoProvider>(context, listen: false).getDevice();
      // log('${devices.firstWhere((element) => element.address == macAddress).address} asasas');

      // log('${Provider.of<StatusConexaoProvider>(context, listen: false).device!.address} asas');
    });
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      log('Discovery: ${r.device.isConnected}');
      log('Discovery: ${r}');
      setState(() {
        Iterator i = devices.iterator;

        // if(){}
        while (i.moveNext()) {
          var _device = i.current;
          if (_device.device == r.device) {
            _device.availability = _DeviceAvailability.yes;
            _device.rssi = r.rssi;
            _device.device = r.device;

            // device?.device ??= r.device;
            device!.device = r.device;
            device!.rssi = r.rssi;
            device!.availability = _DeviceAvailability.yes;
            log('${r.device}');
            log('${device?.device?.address}');
          }
        }
      });
    });

    _discoveryStreamSubscription!.onDone(() async {
      setState(() {
        _isDiscovering = false;
      });
      log('Discovery finished');
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _discoveryStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // devices.removeWhere((element) => element.availability==_DeviceAvailability.no);
    List<ListaBluetoothPage> list = devices
        .map(
          (_device) => ListaBluetoothPage(
            device: _device.device,
            onTap: () {
              device = _device;
              Provider.of<StatusConexaoProvider>(context, listen: false)
                  .setDevice(_device.device!);
              Provider.of<SharedPreferencesProvider>(context, listen: false)
                  .getAndSaveDevice(_device.device!.address);
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  settings: const RouteSettings(name: '/'),
                  builder: (context) => const HomePage()));
            },
          ),
        )
        .toList();

    // if (Provider.of<SharedPreferencesProvider>(context, listen: false)
    //         .preferences!
    //         .get('device') !=
    //     null) {
    //   Provider.of<StatusConexaoProvider>(context, listen: false)
    //       .setDevice(device!.device!);

    // }

    return Scaffold(
      // appBar: CustomAppBar(
      //   Title: 'Bluetooh list',
      //   isBluetooth: false,
      //   isDiscovering: false,
      //   onPress: () {},
      // ),
      body: ListView(
        children: list,
      ),
    );
  }
}
