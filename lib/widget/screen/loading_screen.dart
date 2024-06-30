import 'package:flutter/material.dart';
import 'package:pixelate/widget/indicator/progress_indicator.dart';

class LoadingScreen {
  final GlobalKey globalKey;

  final bool darkTheme;

  static LoadingScreen? instance;

  LoadingScreen._(this.globalKey, this.darkTheme);

  factory LoadingScreen(GlobalKey globalKey, bool darkTheme) {
    instance ??= LoadingScreen._(globalKey, darkTheme);
    return instance!;
  }

  show([String? text]) {
    if (globalKey.currentContext == null) {
      return;
    }

    showDialog<String>(
        context: globalKey.currentContext!,
        builder: (BuildContext context) => Scaffold(
              backgroundColor: darkTheme ? Colors.black : Colors.white,
              body: Center(
                child: circularProgress(
                  context,
                  darkTheme ? Colors.white : Colors.black,
                ),
              ),
            ));
  }

  void hide() {
    if (globalKey.currentContext == null) {
      return;
    }

    Navigator.pop(globalKey.currentContext!);
  }
}
