import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lumos/model/models.dart';

class BackgroundBlurLayer extends StatefulWidget {
  final BackgroundBlurLayerData layerData;
  final VoidCallback? onUpdate;

  const BackgroundBlurLayer({
    super.key,
    required this.layerData,
    this.onUpdate,
  });

  @override
  State<BackgroundBlurLayer> createState() => _BackgroundBlurLayerState();
}

/// This widget uses [BackdropFilter] to apply a Gaussian blur effect based on the
/// given blur radius and applies a color overlay with specified opacity on top of it.
///
/// The [BackgroundBlurLayerData] model provides the configuration for the blur
/// radius, color, and opacity. The [onUpdate] callback, if provided, can be used to
/// trigger additional actions when the widget updates.
class _BackgroundBlurLayerState extends State<BackgroundBlurLayer> {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.layerData.radius,
          sigmaY: widget.layerData.radius,
        ),
        blendMode: BlendMode.srcOver,
        child: Container(
          color: widget.layerData.color
              .withAlpha((widget.layerData.opacity * 100).toInt()),
        ),
      ),
    );
  }
}
