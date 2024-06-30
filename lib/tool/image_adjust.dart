// ignore_for_file: use_build_context_synchronously
import 'package:colorfilter_generator/addons.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';

import 'package:pixel/data/constants.dart';
import 'package:pixel/widget/button/bottom_button.dart';

class ImageAdjust extends StatefulWidget {
  final Uint8List image;

  final bool darkTheme;

  const ImageAdjust({
    super.key,
    required this.image,
    required this.darkTheme,
  });

  @override
  State<ImageAdjust> createState() => _ImageAdjustState();
}

class _ImageAdjustState extends State<ImageAdjust> {
  ScreenshotController screenshotController = ScreenshotController();

  Uint8List adjustedImage = Uint8List.fromList([]);

  double brightness = 0.0;
  double contrast = 0.0;
  double saturation = 0.0;
  double current = 0;

  String currentFilter = 'Brightness';

  ColorFilterGenerator myFilter =
      ColorFilterGenerator(name: "CustomFilter", filters: [
    ColorFilterAddons.brightness(0),
    ColorFilterAddons.contrast(0),
    ColorFilterAddons.saturation(0),
  ]);

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
              color: widget.darkTheme ? Colors.white : Colors.black,
              iconSize: 30.0,
              padding: const EdgeInsets.only(bottom: 3),
            ),
            title: Text(
              'Adjust',
              style: TextStyle(
                fontSize: 20,
                color: widget.darkTheme ? Colors.white : Colors.black,
              ),
            ),
            actions: [
              IconButton(
                color: widget.darkTheme ? Colors.white : Colors.black,
                icon: const Icon(Icons.check, size: 30),
                onPressed: () async {
                  var data = await screenshotController.capture();
                  if (mounted) Navigator.pop(context, data);
                },
              ),
              const SizedBox(width: 20),
            ],
          ),
          body: Center(
            child: Screenshot(
              controller: screenshotController,
              child: Stack(
                children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.matrix(myFilter.matrix),
                    child: Image.memory(
                      widget.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SizedBox(
            height: 145,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 10),
                Text(
                  currentFilter,
                  style: TextStyle(
                    color: widget.darkTheme ? Colors.white : Colors.black,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 20,
                  child: Slider(
                    min: 0.0,
                    max: 1.0,
                    value: current,
                    activeColor: widget.darkTheme ? Colors.white : Colors.black,
                    inactiveColor: Colors.grey,
                    thumbColor: widget.darkTheme ? Colors.white : Colors.black,
                    onChanged: (value) {
                      current = value;
                      if (currentFilter == 'Brightness') {
                        brightness = value;
                        myFilter = ColorFilterGenerator(
                            name: "CustomFilter",
                            filters: [
                              ColorFilterAddons.brightness(brightness),
                              ColorFilterAddons.contrast(contrast),
                              ColorFilterAddons.saturation(saturation),
                            ]);
                      } else if (currentFilter == 'Contrast') {
                        contrast = value;
                        myFilter = ColorFilterGenerator(
                            name: "CustomFilter",
                            filters: [
                              ColorFilterAddons.brightness(brightness),
                              ColorFilterAddons.contrast(contrast),
                              ColorFilterAddons.saturation(saturation),
                            ]);
                      } else if (currentFilter == 'Saturation') {
                        saturation = value;
                        myFilter = ColorFilterGenerator(
                            name: "CustomFilter",
                            filters: [
                              ColorFilterAddons.brightness(brightness),
                              ColorFilterAddons.contrast(contrast),
                              ColorFilterAddons.saturation(saturation),
                            ]);
                      }
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BottomButton(
                      icon: CupertinoIcons.brightness,
                      text: 'Brightness',
                      darkTheme: widget.darkTheme,
                      onTap: () async {
                        setState(() {
                          current = brightness;
                          currentFilter = 'Brightness';
                        });
                      },
                    ),
                    BottomButton(
                      icon: Icons.contrast,
                      text: 'Contrast',
                      darkTheme: widget.darkTheme,
                      onTap: () async {
                        setState(() {
                          current = contrast;
                          currentFilter = 'Contrast';
                        });
                      },
                    ),
                    BottomButton(
                      icon: CupertinoIcons.circle_grid_hex,
                      text: 'Saturation',
                      darkTheme: widget.darkTheme,
                      onTap: () async {
                        setState(() {
                          current = saturation;
                          currentFilter = 'Saturation';
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
