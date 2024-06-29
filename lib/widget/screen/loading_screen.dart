import 'package:flutter/material.dart';
import 'package:quill/widget/indicator/progress_indicator.dart';

class LoadingScreen {
  final GlobalKey globalKey;

  final bool darkTheme;

  // TODO: Implement factory
  LoadingScreen(this.globalKey, this.darkTheme);

  show([String? text]) {
    if (globalKey.currentContext == null) {
      return;
    }

    showDialog<String>(
        context: globalKey.currentContext!,
        builder: (BuildContext context) => Scaffold(
              backgroundColor: darkTheme
                  ? Colors.black.withOpacity(0.9)
                  : Colors.white.withOpacity(0.9),
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
