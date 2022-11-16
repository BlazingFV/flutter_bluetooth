// ignore_for_file: file_names
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:get/get.dart';
import 'package:layout/components/ButtonDouble.dart';
import 'package:layout/components/ButtonSingle.dart';
import 'package:layout/components/button_double_click.dart';
import 'package:layout/controllers/click_controller.dart';
import 'package:layout/controllers/double_click_controller.dart';

import 'components/VoiceButtonPage.dart';

class ControlePrincipalPage extends StatefulWidget {
  final BluetoothDevice? server;
  const ControlePrincipalPage({this.server});

  @override
  _ControlePrincipalPage createState() => _ControlePrincipalPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ControlePrincipalPage extends State<ControlePrincipalPage> {
  static const clientID = 0;
  BluetoothConnection? connection;
  String? language;

  // ignore: deprecated_member_use
  List<_Message> messages = <_Message>[];
  String _messageBuffer = '';

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection!.isConnected;

  bool isDisconnecting = false;
  bool buttonClicado = false;
  SingleClickController clickController = Get.put(
    SingleClickController(),
  );
  DoubleClickController doubleClickController = Get.put(
    DoubleClickController(),
  );

  List<String> _languages = ['en_US', 'es_ES', 'pt_BR'];

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server?.address).then((_connection) {
      print('Connected to device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnected localy!');
        } else {
          print('Disconnected remote!');
        }
        if (mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Failed to connect, something is wrong!');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection!.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: const TextStyle(color: Colors.white)),
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GetBuilder<SingleClickController>(
        init: SingleClickController(),
        initState: (_) {},
        builder: (cnt) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Container(
              // margin: EdgeInsets.only(bottom: 350),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(cnt.imageAssetPath),
                  fit: BoxFit.contain,
                ),
              ),
              child: Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Image.asset("assets/top_logo.png"),

                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // const SizedBox(height: 55),

                            Positioned(
                              top: MediaQuery.of(context).size.height * 0.14,
                              child: columnOne(context),
                            ),

                            Positioned(
                              top: MediaQuery.of(context).size.height * 0.12,
                              // left:150,
                              right: 0,
                              child: columnTwo(context),
                            ),
                            Positioned(
                              top: MediaQuery.of(context).size.height * 0.05,
                              left: 115,
                              child: middleColumn(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget columnTwo(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
        width: MediaQuery.of(context).size.width * 0.35,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 40,
              child: ButtonSingleClick(
                isClicked: () async {
                  clickController.doubleClickButton = false;
                  await clickController.onClickedChangeImageAsset(
                      "assets/right_upper_clicked.png");
                },
                isDoubleCLick: false,
                buttonName: "A/B",
                comandOn: 'A',
                comandOff: 'a',
                clientID: clientID,
                connection: connection,
                svgImage: 'assets/RaiseButton.svg',
              ),
            ),
            Positioned(
              top: 230,
              left: 40,
              child: ButtonSingleClick(
                isClicked: () async {
                  clickController.doubleClickButton = false;
                  await clickController.onClickedChangeImageAsset(
                      "assets/right_bottom_clicked.png");
                },
                isDoubleCLick: false,
                buttonName: "A/B",
                comandOn: 'B',
                comandOff: 'b',
                clientID: clientID,
                connection: connection,
                svgImage: 'assets/DropButton.svg',
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget columnOne(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              width: MediaQuery.of(context).size.width * 0.35,
              child: Stack(
                children: [
                  // Positioned(
                  //   top: 111,
                  //   left: 32,
                  //   // right: 36,
                  //   child: Container(
                  //     color: const Color(0xff646464),
                  //     width: 145,
                  //     height: MediaQuery.of(context).size.height * 0.15,
                  //   ),
                  // ),
                  Positioned(
                    top: 0,
                    left: 10,
                    child: ButtonSingleClick(
                      isDoubleCLick: false,
                      buttonName: "A/B",
                      comandOn: 'C',
                      comandOff: 'c',
                      clientID: clientID,
                      connection: connection,
                      svgImage: 'assets/RaiseButton.svg',
                      isClicked: () async {
                        clickController.doubleClickButton = false;
                        await clickController.onClickedChangeImageAsset(
                            "assets/left_upper_clicked.png");
                      },
                    ),
                  ),
                  Positioned(
                    top: 220,
                    left: 10,
                    child: ButtonSingleClick(
                      isDoubleCLick: false,
                      buttonName: "A/B",
                      comandOn: 'D',
                      comandOff: 'd',
                      clientID: clientID,
                      connection: connection,
                      svgImage: 'assets/DropButton.svg',
                      isClicked: () async {
                        clickController.doubleClickButton = false;
                        await clickController.onClickedChangeImageAsset(
                            "assets/lower_bottom_clicked.png");
                      },
                    ),
                  ),
                ],
              ),
            ),
          ]),

          // Column 2

          // const SizedBox(width: 30),
        ]);
  }

  //         // Column 2

  Widget middleColumn(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              width: MediaQuery.of(context).size.width * 0.45,
              child: Column(
                children: [
                  ButtonSingleClick(
                    isClicked: () async {
                      // clickController.doubleClickButton = false;
                      // clickController.isDoubleCLicking = true;
                      // clickController.update();
                      await clickController.onClickedChangeImageAsset(
                          "assets/middle_top_clicked.png");
                    },
                    buttonName: "A/B",
                    comandOn: 'E',
                    comandOff: 'e',
                    isDoubleCLick: false,
                    clientID: clientID,
                    connection: connection,
                    svgImage: 'assets/AllUpButton.svg',
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.30,
                    width: MediaQuery.of(context).size.width * 1,
                    child: Stack(
                      children: [
                        Positioned(
                          top: -10,
                          left: 0,
                          right: 20,
                          // bottom: 0,
                          child: ButtonDoubleClick(
                            isClicked: () async {
                              // setState(() {
                              //   clickController.doubleClickButton = true;
                              //   clickController.isDoubleCLicking = true;
                              // });
                              // await clickController.onClickedChangeImageAsset(
                              //     "assets/middle_upper_middle_clicked.png");
                            },
                            doubleCLick: () async {
                              // clickController.doubleClickButton = true;
                              // clickController.isDoubleCLicking = true;
                              // clickController.update();
                              await clickController.onClickedChangeImageAsset(
                                  "assets/middle_upper_middle_clicked.png");
                            },
                            buttonName: "Raise 1.5S",
                            isDoubleCLick: true,
                            duration: 1500,
                            comandOn: 'H',
                            comandOff: 'H',
                            clientID: clientID,
                            connection: connection,
                            svgImage: 'assets/UpperPreset.svg',
                          ),
                        ),
                        Positioned(
                          top: 145,
                          left: 0,
                          right: 20,
                          child: ButtonDoubleClick(
                            isClicked: () async {},
                            doubleCLick: () async {
                              // clickController.doubleClickButton = true;
                              // clickController.isDoubleCLicking = true;
                              // clickController.update();
                              await clickController.onClickedChangeImageAsset(
                                  "assets/middle_lower_middle_clicked.png");
                            },
                            buttonName: "AIROUT",
                            comandOn: 'G',
                            comandOff: 'G',
                            duration: 8000,
                            clientID: clientID,
                            connection: connection,
                            svgImage: 'assets/LowerPreset.svg',
                            isDoubleCLick: true,
                          ),
                        ),
                        // Positioned(
                        //   // top: 0,
                        //   left: 0,
                        //   right: 0,
                        //   bottom: 110,
                        //   child: ButtonSingleClick(
                        //     isClicked: () {},
                        //     buttonName: "A/B",
                        //     comandOn: '',
                        //     comandOff: '',
                        //     clientID: clientID,
                        //     connection: connection,
                        //     svgImage: 'assets/main_middle_logo.png',
                        //     isDoubleCLick: false,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),

                  ButtonSingleClick(
                    isClicked: () async {
                      clickController.doubleClickButton = false;
                      await clickController.onClickedChangeImageAsset(
                          "assets/middle_bottom_clicked.png");
                    },
                    buttonName: "A/B",
                    isDoubleCLick: false,
                    comandOn: 'F',
                    comandOff: 'f',
                    clientID: clientID,
                    connection: connection,
                    svgImage: 'assets/AllDownButton.svg',
                  )
                ],
              ),
            ),
          ]),
          // const SizedBox(width: 30),
        ]);
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }
}
