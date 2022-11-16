import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:layout/HomePage.dart';
import 'package:layout/provider/StatusConexaoProvider.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? Title;
  final bool? isBluetooth;
  final bool? isDiscovering;
  final Function? onPress;

  const CustomAppBar({
    Key? key,
    @required this.Title,
    this.isBluetooth,
    this.isDiscovering,
    this.onPress,
  }) : super(key: key);
  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    // DisconnectarBluetooth() {
    //   Provider.of<StatusConexaoProvider>(context, listen: false)
    //       .setDevice(null);
    // }

    return AppBar(
      toolbarHeight: 100.0,
      elevation: 0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(5))),
      // title:  Center(
      //     child: Row(
      //   children: [
      //      Text(Title!, textAlign: TextAlign.center),
      //   ],
      // )),
      backgroundColor: Colors.black,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: SizedBox(
            height: 60,
            width: 60,
            child: Consumer<StatusConexaoProvider>(
                builder: (context, StatusConnectionProvider, widget) {
              return (isBluetooth!
                  ? ElevatedButton(
                      onPressed: StatusConnectionProvider.device != null
                          ? () {
                              Provider.of<StatusConexaoProvider>(context,
                                      listen: false)
                                  .setDevice(null);
                              onPress!();
                              // Navigator.of(context).pushReplacement(
                              //     MaterialPageRoute(
                              //         settings: const RouteSettings(name: '/'),
                              //         builder: (context) =>
                              //             const HomePage())); // push it back in
                            }
                          : onPress!(),
                      child: Icon(StatusConnectionProvider.device != null
                          ? Icons.settings
                          : Icons.settings),
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          primary:
                              StatusConnectionProvider.device?.isConnected ??
                                      false
                                  ? const Color.fromRGBO(15, 171, 118, 1)
                                  : Colors.black),
                    )
                  : const SizedBox.shrink());
            }),
          ),
        )
      ],
      title: Consumer<StatusConexaoProvider>(
          builder: (context, StatusConnectionProvider, widget) {
        return StatusConnectionProvider.device?.isConnected ?? false
            ? Text('Connected')
            : Text('Disconnected');
      }),
    );
  }
}
