import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';

import 'package:pixelate/widget/button/animated_on_tap_button.dart';

Future<dynamic> exitDialog(BuildContext context) {
  return showDialog(
      context: context,
      barrierColor: Colors.black38,
      barrierDismissible: true,
      builder: (c) => Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetAnimationDuration: const Duration(milliseconds: 300),
            insetAnimationCurve: Curves.ease,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: BlurryContainer(
                color: Colors.black.withOpacity(0.15),
                blur: 5,
                padding: const EdgeInsets.all(20),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Cancel?',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "If you go back now, you'll lose all the edits you've made.",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white54,
                          letterSpacing: 0.1),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    AnimatedOnTapButton(
                      onTap: () async {
                        Navigator.pop(c, true);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Yes',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent.shade200,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.1),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                      child: Divider(
                        color: Colors.white,
                      ),
                    ),
                    AnimatedOnTapButton(
                      onTap: () {
                        Navigator.pop(c, true);
                      },
                      child: const Text(
                        'No',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ));
}
