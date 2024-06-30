import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AnimatedOnTapButton extends StatefulWidget {
  final Widget child;

  final void Function() onTap;
  final Function()? onLongPress;

  const AnimatedOnTapButton(
      {super.key, required this.onTap, required this.child, this.onLongPress});

  @override
  State<AnimatedOnTapButton> createState() => _AnimatedOnTapButtonState();
}

class _AnimatedOnTapButtonState extends State<AnimatedOnTapButton>
    with TickerProviderStateMixin {
  double squareScaleA = 1;
  AnimationController? controller;
  Timer timer = Timer(const Duration(milliseconds: 300), () {});

  @override
  void initState() {
    if (mounted) {
      controller = AnimationController(
        vsync: this,
        lowerBound: 0.95,
        upperBound: 1.0,
        value: 1,
        duration: const Duration(milliseconds: 10),
      );

      controller?.addListener(() {
        setState(() {
          squareScaleA = controller!.value;
        });
      });

      super.initState();
    }
  }

  @override
  void dispose() {
    if (mounted) {
      controller!.dispose();
      timer.cancel();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        HapticFeedback.lightImpact();
        controller!.reverse();
        widget.onTap();
      },
      onTapDown: (dp) {
        controller!.reverse();
      },
      onTapUp: (dp) {
        try {
          if (mounted) {
            timer = Timer(const Duration(milliseconds: 100), () {
              controller!.fling();
            });
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      },
      onTapCancel: () {
        controller!.fling();
      },
      onLongPress: widget.onLongPress ?? () {},
      child: Transform.scale(
        scale: squareScaleA,
        child: widget.child,
      ),
    );
  }
}
