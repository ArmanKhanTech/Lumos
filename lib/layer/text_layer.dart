import 'package:flutter/material.dart';

import 'package:pixelate/editor/single_image_editor.dart';
import 'package:pixelate/utility/model.dart';
import 'package:pixelate/widget/dialog/text_layer_dialog.dart';

class TextLayer extends StatefulWidget {
  final TextLayerData layerData;

  final VoidCallback? onUpdate;

  final bool darkTheme;

  const TextLayer({
    super.key,
    required this.layerData,
    this.onUpdate,
    required this.darkTheme,
  });
  @override
  createState() => _TextViewState();
}

class _TextViewState extends State<TextLayer> {
  double initialSize = 0, initialRotation = 0;

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
              isScrollControlled: true,
              backgroundColor: widget.darkTheme ? Colors.black : Colors.white,
              builder: (BuildContext context) {
                return SingleChildScrollView(
                    child: Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: TextLayerDialog(
                    index: layers.indexOf(widget.layerData),
                    layer: widget.layerData,
                    darkTheme: widget.darkTheme,
                    onUpdate: () {
                      if (widget.onUpdate != null) widget.onUpdate!();
                      setState(() {});
                    },
                  ),
                ));
              });
        },
        onScaleUpdate: (detail) {
          if (detail.pointerCount == 1) {
            widget.layerData.offset = Offset(
              widget.layerData.offset.dx + detail.focalPointDelta.dx,
              widget.layerData.offset.dy + detail.focalPointDelta.dy,
            );
          } else if (detail.pointerCount == 2) {
            widget.layerData.size =
                initialSize + detail.scale * (detail.scale > 1 ? 1 : -1);
            widget.layerData.rotation = detail.rotation;
          }
          setState(() {});
        },
        child: Transform.rotate(
          angle: widget.layerData.rotation,
          child: Container(
            decoration: BoxDecoration(
              color: widget.layerData.background
                  .withAlpha(widget.layerData.backgroundOpacity.toInt()),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(5),
            child: Text(
              widget.layerData.text.toString(),
              textAlign: widget.layerData.align,
              style: TextStyle(
                color: widget.layerData.color,
                fontSize: widget.layerData.size,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
