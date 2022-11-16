// ignore_for_file: file_names

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:layout/SelecionarDispositivo.dart';
import 'package:layout/ControlePrincipal.dart';
import 'package:layout/provider/shared_prefs_provider.dart';
import 'package:provider/provider.dart';
import 'components/CustomAppBar.dart';
import 'provider/StatusConexaoProvider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    onPressBluetooth() {
      return (() async {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            settings: const RouteSettings(name: 'selectDevice'),
            builder: (context) => const SelecionarDispositivoPage()));
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
       appBar: CustomAppBar(
        Title: 'Remote Arduino',
        isBluetooth: true,
        isDiscovering: false,
        onPress: onPressBluetooth,
      ),
    
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
          child: Consumer<StatusConexaoProvider>(
              builder: (context, provider, widget) {
                log('StatusConnectionProvider.device: ${Provider.of<StatusConexaoProvider>(context,listen:false).device}');
                log('StatusConnectionProvider.device: ${Provider.of<StatusConexaoProvider>(context,listen:false).macAddress}');
            return (Provider.of<StatusConexaoProvider>(context,listen: false).device == null 
                ? const SelecionarDispositivoPage()
                
                
                // Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: const[
                //        Icon(Icons.bluetooth_disabled_sharp, size: 50,color: Colors.white,),
                //        Text(
                //         "Bluetooth Disconnected \nPlease Enable Bluetooth",
                //         style: TextStyle(
                //           fontSize: 20,
                //           color: Colors.white
                //         ),
                //       )
                //     ],
                //   )
                : ControlePrincipalPage(
                    server: provider.device));
          }),
        ),
      ),
    );
  }
}
