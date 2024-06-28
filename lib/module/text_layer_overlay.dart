import 'package:flutter/material.dart';
import 'package:quill/editor/single_image_editor.dart';

import '../data/layer.dart';

import 'color_picker.dart';

class TextLayerOverlay extends StatefulWidget {
  final int index;
  final TextLayerData layer;
  final Function onUpdate;

  const TextLayerOverlay({
    super.key,
    required this.layer,
    required this.index,
    required this.onUpdate,
  });

  @override
  createState() => _TextLayerOverlayState();
}

class _TextLayerOverlayState extends State<TextLayerOverlay> {
  double slider = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20)),
          border: Border(
            top: BorderSide(width: 1, color: Colors.white),
            bottom: BorderSide(width: 0, color: Colors.white),
            left: BorderSide(width: 0, color: Colors.white),
            right: BorderSide(width: 0, color: Colors.white),
          )),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Text Size',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Slider(
              activeColor: Colors.white,
              inactiveColor: Colors.grey,
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
              const Text(
                'Text Color',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
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
                        color: Colors.blue,
                        fontSize: 18,
                      )),
                ),
              ]),
              const SizedBox(height: 10),
              const Text(
                'Text Background Color',
                style: TextStyle(
                  color: Colors.white,
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
                      color: Colors.blue,
                      fontSize: 18,
                    ),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Text Background Opacity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Slider(
              activeColor: Colors.white,
              inactiveColor: Colors.grey,
              value: widget.layer.backgroundOpacity.toDouble(),
              thumbColor: Colors.white,
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
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
