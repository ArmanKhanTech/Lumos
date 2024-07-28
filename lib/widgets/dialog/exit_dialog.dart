import 'package:flutter/material.dart';

Future<dynamic> exitDialog(BuildContext context, bool darkTheme) {
  return showDialog(
    context: context,
    barrierColor: Colors.black38,
    barrierDismissible: true,
    builder: (c) => Dialog(
      backgroundColor: darkTheme ? Colors.black : Colors.white,
      insetAnimationDuration: const Duration(milliseconds: 300),
      insetAnimationCurve: Curves.ease,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Cancel?',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: darkTheme ? Colors.white : Colors.black,
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
                  color: Colors.grey,
                  letterSpacing: 0.1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
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
            SizedBox(
              height: 22,
              child: Divider(
                color: darkTheme ? Colors.white : Colors.black,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(c, true);
              },
              child: Text(
                'No',
                style: TextStyle(
                    fontSize: 16,
                    color: darkTheme ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
