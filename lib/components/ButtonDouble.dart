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

class ButtonSingleClick extends StatefulWidget {
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

  ButtonSingleClick({
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
  _ButtonSingleClickState createState() => _ButtonSingleClickState();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ButtonSingleClickState extends State<ButtonSingleClick> {
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
        // log('${controllerClicking1.isDoubleCLicking} controller 1 is doubleCLicking');
        // log('${controllerClicking.isDoubleCLicking} controller  is doubleCLicking');
        return Container(
            height: 100,
            width: 95,
            decoration: const BoxDecoration(
                // color: Colors.white,
                // borderRadius: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
            child: GestureDetector(
              onPanDown: (onPan)async {
                log('OnPan');

                if (!controllerClicking1.isDoubleCLicking) {
                  controllerClicking1.isPaningDown = true;
                  // controllerClicking1.update();

                  widget.isClicked!();
                 await _sendMessage(widget.comandOn!);

                  log("Button Clicado");
                  //   // print('$details');
                  log("${widget.comandOn!} onn");
                }
                // }
                // _changeButtonColor();
              },
              onPanEnd: (end)async {
                if (!controllerClicking1.isDoubleCLicking) {
                  log('PanCanceld');

                  controllerClicking1.isPaningDown = false;
                  // controllerClicking1.update();
                  widget.isClicked!();

                 await _sendMessage(widget.comandOff!);

                  log("${widget.comandOff!} off");
                }
                // print('canceled');
              },

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
          log('${messages.last.text} messages');
        });
      } catch (e) {
        // setState(() {});
      }
    }
  }
}
