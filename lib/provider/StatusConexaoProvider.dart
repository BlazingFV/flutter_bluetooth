import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:layout/provider/shared_prefs_provider.dart';
import 'package:provider/provider.dart';

import '../SelecionarDispositivo.dart';

class StatusConexaoProvider extends ChangeNotifier {
  BluetoothDevice? device;
  List<DeviceWithAvailability> devices = <DeviceWithAvailability>[];
  String macAddress = '';
  SharedPreferencesProvider sharedPreferencesProvider =
      SharedPreferencesProvider();

  BluetoothDevice? get getDevice => device;

  setDevice(BluetoothDevice? deviceReceived) {
    device = deviceReceived;
    log('${device} deviceProvider');
    notifyListeners();
  }

  setActiveDevice(
      List<DeviceWithAvailability> devicesList) async {
    devices = devicesList;
    macAddress = await sharedPreferencesProvider.getMacAddress();
    log('macAddress: $macAddress');
    if (devices.isNotEmpty) {
      devices.firstWhere((element) => element.address == macAddress).device;
      setDevice(devices
          .firstWhere((element) => element.address == macAddress)
          .device);
    }

    notifyListeners();
  }
}
