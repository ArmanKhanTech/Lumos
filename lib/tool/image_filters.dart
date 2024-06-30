// ignore_for_file: use_build_context_synchronously
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor/image_editor.dart';
import 'package:screenshot/screenshot.dart';

import 'package:lumos/data/constants.dart';

class ImageFilters extends StatefulWidget {
  final Uint8List image;

  final bool useCache, darkTheme;

  const ImageFilters({
    super.key,
    required this.image,
    this.useCache = true,
    required this.darkTheme,
  });

  @override
  State<ImageFilters> createState() => _ImageFiltersState();
}

class _ImageFiltersState extends State<ImageFilters> {
  late Image decodedImage;

  ColorFilterGenerator selectedFilter = PresetFilters.none;

  Uint8List resizedImage = Uint8List.fromList([]);
  Uint8List filterAppliedImage = Uint8List.fromList([]);

  double filterOpacity = 1;

  ScreenshotController screenshotController = ScreenshotController();

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
              'Filters',
              style: TextStyle(
                color: widget.darkTheme ? Colors.white : Colors.black,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.check,
                    size: 30,
                    color: widget.darkTheme ? Colors.white : Colors.black),
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
                  Image.memory(
                    widget.image,
                    fit: BoxFit.cover,
                  ),
                  FilterAppliedImage(
                    image: widget.image,
                    filter: selectedFilter,
                    fit: BoxFit.cover,
                    opacity: filterOpacity,
                    onProcess: (img) {
                      filterAppliedImage = img;
                    },
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: SizedBox(
              height: 185,
              child: Column(children: [
                const SizedBox(height: 10),
                Text(
                  selectedFilter.name,
                  style: TextStyle(
                    color: widget.darkTheme ? Colors.white : Colors.black,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 20,
                  child: Slider(
                    min: 0,
                    max: 1,
                    divisions: 100,
                    value: filterOpacity,
                    activeColor: widget.darkTheme ? Colors.white : Colors.black,
                    inactiveColor: Colors.grey,
                    thumbColor: widget.darkTheme ? Colors.white : Colors.black,
                    onChanged: (value) {
                      filterOpacity = value;
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      for (int i = 0; i < presetFiltersList.length; i++)
                        filterPreviewButton(
                            filter: presetFiltersList[i],
                            name: presetFiltersList[i].name,
                            color:
                                widget.darkTheme ? Colors.white : Colors.black),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ));
  }

  Widget filterPreviewButton(
      {required filter, required String name, required Color color}) {
    if (name == 'AddictiveBlue') {
      name = 'Cerulean';
    } else if (name == 'AddictiveRed') {
      name = 'Crimson';
    }

    return GestureDetector(
      onTap: () {
        selectedFilter = filter;
        setState(() {});
      },
      child: Column(children: [
        Container(
          height: 60,
          width: 60,
          margin:
              const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: FilterAppliedImage(
              image: widget.image,
              filter: filter,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text(
          name,
          style: TextStyle(fontSize: 15, color: color),
        ),
      ]),
    );
  }
}

class FilterAppliedImage extends StatelessWidget {
  final Uint8List image;

  final ColorFilterGenerator filter;

  final BoxFit? fit;

  final Function(Uint8List)? onProcess;

  final double opacity;

  FilterAppliedImage({
    super.key,
    required this.image,
    required this.filter,
    this.fit,
    this.onProcess,
    this.opacity = 1,
  }) {
    if (onProcess != null) {
      if (filter.filters.isEmpty) {
        onProcess!(image);
        return;
      }

      final ImageEditorOption option = ImageEditorOption();
      option.addOption(ColorOption(matrix: filter.matrix));

      ImageEditor.editImage(
        image: image,
        imageEditorOption: option,
      ).then((result) {
        if (result != null) {
          onProcess!(result);
        }
      }).catchError((err, stack) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (filter.filters.isEmpty) return Image.memory(image, fit: fit);
    return Opacity(
      opacity: opacity,
      child: filter.build(
        Image.memory(image, fit: fit),
      ),
    );
  }
}
