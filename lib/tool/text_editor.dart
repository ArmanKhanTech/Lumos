// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';

import 'package:pixelate/data/constants.dart';
import 'package:pixelate/utility/model.dart';

import '../widget/picker/color_picker.dart';

class TextEditor extends StatefulWidget {
  final bool darkTheme;

  const TextEditor({super.key, required this.darkTheme});

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  TextEditingController name = TextEditingController();

  late Color currentColor;

  double slider = 20.0;

  TextAlign align = TextAlign.left;

  @override
  void initState() {
    super.initState();
    currentColor = widget.darkTheme ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: widget.darkTheme ? Constants.darkTheme : Constants.lightTheme,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
              iconSize: 30.0,
              color: widget.darkTheme ? Colors.white : Colors.black,
              padding: const EdgeInsets.only(bottom: 3),
            ),
            title: Text(
              'Text',
              style: TextStyle(
                color: widget.darkTheme ? Colors.white : Colors.black,
                fontSize: 20,
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.align_horizontal_left,
                    color: align == TextAlign.left
                        ? widget.darkTheme
                            ? Colors.white
                            : Colors.black
                        : Colors.grey),
                onPressed: () {
                  setState(() {
                    align = TextAlign.left;
                  });
                },
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.align_horizontal_center,
                    color: align == TextAlign.center
                        ? widget.darkTheme
                            ? Colors.white
                            : Colors.black
                        : Colors.grey),
                onPressed: () {
                  setState(() {
                    align = TextAlign.center;
                  });
                },
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.align_horizontal_right,
                    color: align == TextAlign.right
                        ? widget.darkTheme
                            ? Colors.white
                            : Colors.black
                        : Colors.grey),
                onPressed: () {
                  setState(() {
                    align = TextAlign.right;
                  });
                },
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.check, size: 30),
                onPressed: () {
                  Navigator.pop(
                    context,
                    TextLayerData(
                      background: Colors.transparent,
                      text: name.text,
                      color: currentColor,
                      size: slider.toDouble(),
                      align: align,
                    ),
                  );
                },
                color: widget.darkTheme ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 20),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(children: [
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: TextField(
                    controller: name,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(30),
                      hintText: 'Enter your text here',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: slider,
                      ),
                      alignLabelWithHint: true,
                    ),
                    scrollPadding: const EdgeInsets.all(20.0),
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    style: TextStyle(
                      color: currentColor,
                      fontSize: slider,
                    ),
                    textAlign: align,
                    autofocus: true,
                    cursorColor: widget.darkTheme ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Text Size',
                            style: TextStyle(
                              color: widget.darkTheme
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Slider(
                          activeColor:
                              widget.darkTheme ? Colors.white : Colors.black,
                          inactiveColor: Colors.grey,
                          thumbColor:
                              widget.darkTheme ? Colors.white : Colors.black,
                          value: slider,
                          min: 0.0,
                          max: 100.0,
                          onChangeEnd: (v) {
                            setState(() {
                              slider = v;
                            });
                          },
                          onChanged: (v) {
                            setState(() {
                              slider = v;
                            });
                          }),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Text Color',
                          style: TextStyle(
                            color:
                                widget.darkTheme ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Row(children: [
                        Expanded(
                          child: BarColorPicker(
                            thumbColor:
                                widget.darkTheme ? Colors.white : Colors.black,
                            cornerRadius: 10,
                            pickMode: PickMode.color,
                            colorListener: (int value) {
                              setState(() {
                                currentColor = Color(value);
                              });
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              currentColor = Colors.white;
                            });
                          },
                          child: const Text('Reset',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              )),
                        ),
                      ]),
                      const SizedBox(height: 10.0),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Text Opacity',
                          style: TextStyle(
                            color:
                                widget.darkTheme ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Row(children: [
                        Expanded(
                          child: BarColorPicker(
                            thumbColor:
                                widget.darkTheme ? Colors.white : Colors.black,
                            cornerRadius: 10,
                            pickMode: PickMode.grey,
                            colorListener: (int value) {
                              setState(() {
                                currentColor = Color(value);
                              });
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                currentColor = const Color(0xFFFFFFFF);
                              });
                            },
                            child: const Text('Reset',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ))),
                      ]),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ));
  }
}
