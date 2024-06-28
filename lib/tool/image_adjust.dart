import 'package:colorfilter_generator/addons.dart';
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quill/widget/bottom_button.dart';
import 'package:screenshot/screenshot.dart';

class ImageAdjust extends StatefulWidget {
  final Uint8List image;

  const ImageAdjust({
    super.key,
    required this.image,
  });

  @override
  createState() => ImageAdjustState();
}

class ImageAdjustState extends State<ImageAdjust> {
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          iconSize: 30.0,
          color: Colors.white,
          padding: const EdgeInsets.only(bottom: 3),
        ),
        title: const Text(
          'Adjust',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(
              left: 10,
              right: 22,
            ),
            icon: const Icon(Icons.check, size: 30, color: Colors.white),
            onPressed: () async {
              var data = await screenshotController.capture();
              if (mounted) Navigator.pop(context, data);
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
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
        height: 105,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 10),
            SizedBox(
              height: 20,
              child: Slider(
                min: 0.0,
                max: 1.0,
                value: current,
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
                thumbColor: Colors.white,
                onChanged: (value) {
                  current = value;
                  if (currentFilter == 'Brightness') {
                    brightness = value;
                    myFilter =
                        ColorFilterGenerator(name: "CustomFilter", filters: [
                      ColorFilterAddons.brightness(brightness),
                      ColorFilterAddons.contrast(contrast),
                      ColorFilterAddons.saturation(saturation),
                    ]);
                  } else if (currentFilter == 'Contrast') {
                    contrast = value;
                    myFilter =
                        ColorFilterGenerator(name: "CustomFilter", filters: [
                      ColorFilterAddons.brightness(brightness),
                      ColorFilterAddons.contrast(contrast),
                      ColorFilterAddons.saturation(saturation),
                    ]);
                  } else if (currentFilter == 'Saturation') {
                    saturation = value;
                    myFilter =
                        ColorFilterGenerator(name: "CustomFilter", filters: [
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
                  onTap: () async {
                    setState(() {
                      current = contrast / 100;
                      currentFilter = 'Contrast';
                    });
                  },
                ),
                BottomButton(
                  icon: CupertinoIcons.circle_grid_hex,
                  text: 'Saturation',
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
    );
  }
}
