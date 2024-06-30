import 'package:flutter/material.dart';

import 'package:pixel/editor/single_image_editor.dart';
import 'package:pixel/utility/model.dart';

class EmojiLayerDialog extends StatefulWidget {
  final int index;

  final EmojiLayerData layer;

  final Function onUpdate;

  final bool darkTheme;

  const EmojiLayerDialog({
    super.key,
    required this.layer,
    required this.index,
    required this.onUpdate,
    required this.darkTheme,
  });

  @override
  createState() => _EmojiLayerDialogState();
}

class _EmojiLayerDialogState extends State<EmojiLayerDialog> {
  double slider = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 165,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Size Adjust',
              style: TextStyle(
                color: widget.darkTheme ? Colors.white : Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          Slider(
              activeColor: widget.darkTheme ? Colors.white : Colors.black,
              inactiveColor: Colors.grey,
              thumbColor: widget.darkTheme ? Colors.white : Colors.black,
              value: widget.layer.size,
              min: 0.0,
              max: 100.0,
              onChangeEnd: (v) {
                setState(() {
                  widget.layer.size = v.toDouble();
                  widget.onUpdate();
                });
              },
              onChanged: (v) {
                setState(() {
                  slider = v;
                  widget.layer.size = v.toDouble();
                  widget.onUpdate();
                });
              }),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  removedLayers.add(layers.removeAt(widget.index));
                  Navigator.pop(context);
                  widget.onUpdate();
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
