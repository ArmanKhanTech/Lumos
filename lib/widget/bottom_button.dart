import 'package:flutter/material.dart';

class BottomButton extends StatelessWidget {
  final VoidCallback? onTap, onLongPress;
  final IconData icon;
  final String text;

  const BottomButton({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.icon,
    required this.text,
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
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(
              height: 4,
            ),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
