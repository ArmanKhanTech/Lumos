import 'package:flutter/material.dart';

import 'package:pixelate/editor/single_image_editor.dart';
import 'package:pixelate/utility/model.dart';

import '../widget/dialog/emoji_layer_dialog.dart';

class EmojiLayer extends StatefulWidget {
  final EmojiLayerData layerData;

  final VoidCallback? onUpdate;

  final bool darkTheme;

  const EmojiLayer({
    super.key,
    required this.layerData,
    this.onUpdate,
    required this.darkTheme,
  });

  @override
  createState() => _EmojiLayerState();
}

class _EmojiLayerState extends State<EmojiLayer> {
  double initialSize = 0;
  double initialRotation = 0;

  @override
  Widget build(BuildContext context) {
    initialSize = widget.layerData.size;
    initialRotation = widget.layerData.rotation;

    return Positioned(
      left: widget.layerData.offset.dx,
      top: widget.layerData.offset.dy,
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: widget.darkTheme ? Colors.black : Colors.white,
            builder: (context) {
              return EmojiLayerDialog(
                index: layers.indexOf(widget.layerData),
                layer: widget.layerData,
                darkTheme: widget.darkTheme,
                onUpdate: () {
                  if (widget.onUpdate != null) widget.onUpdate!();
                  setState(() {});
                },
              );
            },
          );
        },
        onScaleUpdate: (detail) {
          if (detail.pointerCount == 1) {
            widget.layerData.offset = Offset(
              widget.layerData.offset.dx + detail.focalPointDelta.dx,
              widget.layerData.offset.dy + detail.focalPointDelta.dy,
            );
          } else if (detail.pointerCount == 2) {
            widget.layerData.size =
                initialSize + detail.scale * 5 * (detail.scale > 1 ? 1 : -1);
          }

          setState(() {});
        },
        child: Transform.rotate(
          angle: widget.layerData.rotation,
          child: Container(
            padding: const EdgeInsets.all(64),
            child: Text(
              widget.layerData.text.toString(),
              style: TextStyle(
                fontSize: widget.layerData.size,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
