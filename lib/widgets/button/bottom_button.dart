import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  final VoidCallback? onTap, onLongPress;

  final IconData icon;

  final String text;

  final bool darkTheme;

  const BottomButton({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.icon,
    required this.text,
    required this.darkTheme,
  });

  @override
  Widget build(BuildContext context) {
    double left = 10, right = 10;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.only(
          left: left,
          right: right,
        ),
        child: Column(
          children: [
            Icon(icon,
                color: darkTheme ? Colors.white : Colors.black, size: 30),
            const SizedBox(
              height: 2,
            ),
            Text(
              text,
              style: TextStyle(
                color: darkTheme ? Colors.white : Colors.black,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
