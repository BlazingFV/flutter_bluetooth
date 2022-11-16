import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider extends ChangeNotifier {
  SharedPreferences? preferences;
  getAndSaveDevice(String macAddress) async {
    preferences = await SharedPreferences.getInstance();
    await preferences?.setString('device', macAddress);
    preferences?.get('device');
    log('Device salvo: ${preferences?.get('device')}');
    notifyListeners();
  }

  getMacAddress() async {
    preferences = await SharedPreferences.getInstance();
    log('Device salvo: ${preferences?.get('device')}');
    notifyListeners();
    return preferences?.getString('device')!;
  }

  saveDeviceObject(Map<String, dynamic> deviceData) async {
    preferences = await SharedPreferences.getInstance();
    await preferences?.setString('deviceData', jsonEncode(deviceData));
    preferences?.get('deviceData');
    log('Device Data: ${preferences?.get('deviceData')}');
    notifyListeners();
  }

  getDeviceObject() async {
    preferences = await SharedPreferences.getInstance();
    String deviceDataString = preferences?.getString('deviceData') ?? "";
    Map<String, dynamic> deviceData =
        jsonDecode(deviceDataString) as Map<String, dynamic>;
    log('Device Data: ${preferences?.get('deviceData')}');
    notifyListeners();
    return deviceData;
  }
}
