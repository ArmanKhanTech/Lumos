// ignore_for_file: use_build_context_synchronously
import 'package:colorfilter_generator/addons.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';

import 'package:lumos/utilities/constants.dart';
import 'package:lumos/widgets/button/bottom_button.dart';

/// The [ImageAdjust] widget provides a UI for modifying an image using sliders
/// for brightness, contrast, and saturation adjustments. It applies a [ColorFilter]
/// to preview changes in real-time and allows users to capture the adjusted image.

/// - The [image] parameter supplies the image to be adjusted.
/// - The [darkTheme] boolean toggles between dark and light themes for the UI.

/// This widget also includes a bottom navigation bar with buttons to switch between
/// adjustments and a save button to confirm changes.
class ImageAdjust extends StatefulWidget {
  /// The image to be adjusted.
  final Uint8List image;

  /// A boolean to toggle between dark and light themes.
  final bool darkTheme;

  /// Creates a [ImageAdjust] widget.
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
              iconSize: 30.0,
              padding: const EdgeInsets.only(bottom: 3),
            ),
            title: const Text(
              'Adjust',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
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
          bottomNavigationBar: Container(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
            height: 180,
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
