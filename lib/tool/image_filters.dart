import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor/image_editor.dart';
import 'package:screenshot/screenshot.dart';

class ImageFilters extends StatefulWidget {
  final Uint8List image;
  final bool useCache;

  const ImageFilters({
    super.key,
    required this.image,
    this.useCache = true,
  });

  @override
  createState() => ImageFiltersState();
}

class ImageFiltersState extends State<ImageFilters> {
  late Image decodedImage;

  ColorFilterGenerator selectedFilter = PresetFilters.none;

  Uint8List resizedImage = Uint8List.fromList([]);

  double filterOpacity = 1;

  Uint8List filterAppliedImage = Uint8List.fromList([]);

  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
  }

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
          'Filters',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.black,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
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
          height: 140,
          child: Column(children: [
            const SizedBox(height: 10),
            SizedBox(
              height: 20,
              child: Slider(
                min: 0,
                max: 1,
                divisions: 100,
                value: filterOpacity,
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
                thumbColor: Colors.white,
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
                    ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget filterPreviewButton({required filter, required String name}) {
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
              color: Colors.black,
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
          style: const TextStyle(fontSize: 15, color: Colors.white),
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
