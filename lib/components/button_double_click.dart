import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:layout/controllers/click_controller.dart';

class ButtonDoubleClick extends StatefulWidget {
  final String? buttonName;
  final String? comandOn;
  final String? comandOff;
  final BluetoothConnection? connection;
  final VoidCallback? doubleCLick;
  final VoidCallback? isClicked;
  bool isDoubleCLick;
  final int clientID;
  final String svgImage;
  final int? duration;

  ButtonDoubleClick({
    Key? key,
    this.buttonName,
    this.comandOn,
    this.comandOff,
    this.connection,
    required this.clientID,
    required this.svgImage,
    this.doubleCLick,
    required this.isDoubleCLick,
    required this.isClicked,
    this.duration,
  }) : super(key: key);
  _ButtonState createState() => _ButtonState();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ButtonState extends State<ButtonDoubleClick> {
  bool buttonClicado = false;
  final TextEditingController textEditingController = TextEditingController();
  List<_Message> messages = <_Message>[];
  bool isClicking = false;
  bool onPanDown = false;
  SingleClickController controllerClicking1 = Get.find<SingleClickController>();

  _changeButtonColor() {
    setState(() {
      buttonClicado = !buttonClicado;
    });
  }

  @override
  Widget build(BuildContext context) {
    // log('${widget.svgImage}');
    return GetBuilder<SingleClickController>(
      init: SingleClickController(),
      initState: (_) {
        Get.find<SingleClickController>();
      },
      builder: (controllerClicking) {
        return Container(
            height: 100,
            width: 95,
            decoration: const BoxDecoration(
                // color: Colors.white,
                // borderRadius: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
            child: GestureDetector(
              onDoubleTap: widget.doubleCLick != null
                  ? () async {
                      setState(() {
                        isClicking = true;
                      });

                      controllerClicking1.isDoubleCLicking = true;
                      controllerClicking1.doubleClickButton = true;

                      if (controllerClicking.isDoubleCLicking) {
                        Timer(Duration(milliseconds: widget.duration!), () {
                          setState(() {
                            isClicking = false;
                          });
                          controllerClicking1.isDoubleCLicking = false;
                          controllerClicking1.doubleClickButton = false;
                        });

                        // print('$details');
                        _sendMessage(widget.comandOn!);
                        while (isClicking) {
                          await Future.delayed(
                              const Duration(milliseconds: 300), () {
                            widget.doubleCLick!();
                            // log("$isClicking");
                            // log("${widget.isDoubleCLick}");

                            controllerClicking1.isPaningDown =
                                !controllerClicking.isPaningDown;
                          });
                        }
                        if (isClicking == false) {
                          controllerClicking1.doubleClickButton = false;
                          controllerClicking1.isDoubleCLicking = false;
                          controllerClicking1.isPaningDown = false;

                          log('${controllerClicking1.isDoubleCLicking} :controller1 is double clicking');

                          // controllerClicking1.doubleClickButton = false;
                          // controllerClicking1.isDoubleCLicking = false;
                          // controllerClicking1.isPaningDown = false;

                          widget.doubleCLick!();
                          log('${controllerClicking1.isDoubleCLicking} :controller1 is double clicking2');
                          // controllerClicking.refresh();
                          // log('${controllerClicking.doubleClickButton} :doubleClickButtonController');
                          // setState(() {
                          //   controllerClicking.doubleClickButton = false;
                          //   controllerClicking.isDoubleCLicking == false;
                          // });
                          // setState(() {
                          //   buttonClicado = false;
                          // });
                        }
                        log("${widget.comandOn!}");
                      }
                    }
                  : null,

              // child: widget.svgImage.endsWith(".svg")
              //     ? SvgPicture.asset(
              //         widget.svgImage,
              //         color: buttonClicado ? Colors.white : null,
              //         // fit: BoxFit.fitWidth,
              //       )
              //     : Image.asset(
              //         widget.svgImage,
              //         color: buttonClicado ? Colors.white : null,
              //         // fit: BoxFit.cover,
              //       ),
            ));
      },
    );
  }

  Future _sendMessage(text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        widget.connection!.output
            .add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await widget.connection!.output.allSent;

        setState(() {
          messages.add(_Message(widget.clientID, text));
        });
      } catch (e) {
        // setState(() {});
      }
    }
  }
}
