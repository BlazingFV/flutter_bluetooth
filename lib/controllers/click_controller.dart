import 'dart:developer';

import 'package:get/get.dart';

class SingleClickController extends GetxController {
  String imageAssetPath = 'assets/whole_non_clicked.png';
  bool isPaningDown = false;
  bool isDoubleCLicking=false;
  bool doubleClickButton=false;
  onClickedChangeImageAsset(String imageAsset) {
    if (isPaningDown) {
      log('isPaningDown $isPaningDown');
      imageAssetPath = imageAsset;
      log(imageAsset);
      update();
    } else if (!isPaningDown) {
         log('isPaningDown $isPaningDown');
      imageAssetPath = 'assets/whole_non_clicked.png';
      update();
    }
  }
}
