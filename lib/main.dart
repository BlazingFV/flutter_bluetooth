import 'dart:developer';

import 'package:flutter/material.dart'
    show
        BuildContext,
        MaterialApp,
        StatelessWidget,
        StreamBuilder,
        Widget,
        runApp;
import 'package:flutter_blue/flutter_blue.dart';
import 'package:layout/SelecionarDispositivo.dart';
import 'package:layout/HomePage.dart';
import 'package:layout/provider/shared_prefs_provider.dart';
import 'package:provider/provider.dart';
import 'provider/StatusConexaoProvider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<StatusConexaoProvider>.value(
              value: StatusConexaoProvider()),
          ChangeNotifierProvider<SharedPreferencesProvider>.value(
              value: SharedPreferencesProvider()),
        ],
        child: MaterialApp(
          title: 'SL1',
          initialRoute: '/',
          // routes: {
          //   // '/': (context) =>const  HomePage(),
          //   // '/selectDevice': (context) => const SelecionarDispositivoPage(),
          // },
          home: StreamBuilder<BluetoothState>(
              stream: FlutterBlue.instance.state,
              initialData: BluetoothState.unknown,
              builder: (c, snapshot) {
                final state = snapshot.data;
                log('state: $state');

                if (state == BluetoothState.on) {
                  return const SelecionarDispositivoPage();
                } else if (state == BluetoothState.off) {
                  log('state: $state');
                  return const HomePage();
                } else if (state == BluetoothState.turningOff) {
                  log('state: $state');
                  return const HomePage();
                }

                return const HomePage();
              }),
        ));
  }
}
