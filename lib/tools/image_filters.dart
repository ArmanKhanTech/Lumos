// ignore_for_file: use_build_context_synchronously
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor/image_editor.dart';
import 'package:screenshot/screenshot.dart';

import 'package:lumos/utilities/constants.dart';

/// The [ImageFilters] widget allows users to preview and select from a range of preset filters
/// to enhance their images. The selected filter can be applied with varying opacity using a slider,
/// and users can capture the final filtered image.

/// - The [image] parameter provides the base image for editing.
/// - [useCache] determines if caching should be applied to improve performance.
/// - The [darkTheme] parameter enables theme customization for a cohesive UI experience.
class ImageFilters extends StatefulWidget {
  /// The image to be filtered.
  final Uint8List image;

  /// A boolean to toggle between dark and light themes.
  final bool useCache, darkTheme;

  /// Creates a [ImageFilters] widget.
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
              padding: const EdgeInsets.only(bottom: 3),
            ),
            title: const Text(
              'Filters',
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
              height: 180,
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
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  height: 100,
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
          margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
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

/// The [FilterAppliedImage] widget applies a filter to an image and displays the result.
class FilterAppliedImage extends StatelessWidget {
  /// The image to be filtered.
  final Uint8List image;

  /// The filter to be applied to the image.
  final ColorFilterGenerator filter;

  /// The fit of the image.
  final BoxFit? fit;

  /// The function to be called after processing the image.
  final Function(Uint8List)? onProcess;

  /// The opacity of the image.
  final double opacity;

  /// Creates a [FilterAppliedImage] widget.
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
