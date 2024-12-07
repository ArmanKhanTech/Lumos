import 'package:flutter/material.dart';
import 'package:lumos/model/models.dart';

/// The [BackgroundLayer] widget takes in a [BackgroundLayerData] model that
/// provides image file data, including width and height, to render the background
/// image. This layer can be used as a backdrop for other editing elements in an
/// image editor, utilizing the specified dimensions.

/// The [onUpdate] callback allows for custom actions to be triggered when the
/// widget updates.
class BackgroundLayer extends StatefulWidget {
  /// The [BackgroundLayerData] model that provides image file data.
  final BackgroundLayerData layerData;

  /// The [onUpdate] acts callback function to trigger when the widget updates.
  final VoidCallback? onUpdate;

  /// The [BackgroundLayer] constructor requires a [layerData] parameter and
  const BackgroundLayer({
    super.key,
    required this.layerData,
    this.onUpdate,
  });

  @override
  State<BackgroundLayer> createState() => _BackgroundLayerState();
}

class _BackgroundLayerState extends State<BackgroundLayer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.layerData.file.width.toDouble(),
      height: widget.layerData.file.height.toDouble(),
      child: Image.memory(widget.layerData.file.image),
    );
  }
}
