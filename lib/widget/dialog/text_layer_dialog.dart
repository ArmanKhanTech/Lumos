import 'package:flutter/material.dart';

import 'package:quill/editor/single_image_editor.dart';
import 'package:quill/utility/model.dart';

import '../picker/color_picker.dart';

class TextLayerDialog extends StatefulWidget {
  final int index;

  final TextLayerData layer;

  final Function onUpdate;

  final bool darkTheme;

  const TextLayerDialog({
    super.key,
    required this.layer,
    required this.index,
    required this.onUpdate,
    required this.darkTheme,
  });

  @override
  createState() => _TextLayerDialogState();
}

class _TextLayerDialogState extends State<TextLayerDialog> {
  double slider = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Text Size',
                style: TextStyle(
                  color: widget.darkTheme ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Text Color',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.darkTheme ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
              ),
              Row(children: [
                Expanded(
                  child: BarColorPicker(
                    thumbColor: Colors.white,
                    initialColor: widget.layer.color,
                    cornerRadius: 10,
                    pickMode: PickMode.color,
                    colorListener: (int value) {
                      setState(() {
                        widget.layer.color = Color(value);
                        widget.onUpdate();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.layer.color = Colors.white;
                      widget.onUpdate();
                    });
                  },
                  child: const Text('Reset',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                      )),
                ),
              ]),
              const SizedBox(height: 10),
              Text(
                'Text Background Color',
                style: TextStyle(
                  color: widget.darkTheme ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
              ),
              Row(children: [
                Expanded(
                  child: BarColorPicker(
                    initialColor: widget.layer.background,
                    thumbColor: Colors.white,
                    cornerRadius: 10,
                    pickMode: PickMode.color,
                    colorListener: (int value) {
                      setState(() {
                        widget.layer.background = Color(value);
                        widget.onUpdate();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.layer.background = Colors.transparent;
                      widget.onUpdate();
                    });
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                    ),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Text Background Opacity',
                style: TextStyle(
                  color: widget.darkTheme ? Colors.white : Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Slider(
              activeColor: widget.darkTheme ? Colors.white : Colors.black,
              inactiveColor: Colors.grey,
              value: widget.layer.backgroundOpacity.toDouble(),
              thumbColor: widget.darkTheme ? Colors.white : Colors.black,
              min: 0.0,
              max: 100.0,
              onChanged: (v) {
                setState(() {
                  widget.layer.backgroundOpacity = v.toInt();
                  widget.onUpdate();
                });
              }),
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
