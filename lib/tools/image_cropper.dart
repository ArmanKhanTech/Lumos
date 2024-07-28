// ignore_for_file: use_build_context_synchronously
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor/image_editor.dart';

import 'package:lumos/utilities/constants.dart';
import 'package:lumos/model/models.dart';

class ImageCropper extends StatefulWidget {
  final Uint8List image;

  final List<AspectRatioOption> availableRatios;

  final bool darkTheme;

  const ImageCropper({
    super.key,
    required this.image,
    this.availableRatios = const [
      AspectRatioOption(title: 'Freeform'),
      AspectRatioOption(title: '1:1', ratio: 1),
      AspectRatioOption(title: '4:3', ratio: 4 / 3),
      AspectRatioOption(title: '5:4', ratio: 5 / 4),
      AspectRatioOption(title: '7:5', ratio: 7 / 5),
      AspectRatioOption(title: '16:9', ratio: 16 / 9),
    ],
    required this.darkTheme,
  });

  @override
  State<ImageCropper> createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  final GlobalKey<ExtendedImageEditorState> controller =
      GlobalKey<ExtendedImageEditorState>();

  double? aspectRatio;
  double? aspectRatioOriginal;

  bool isLandscape = true;

  int rotateAngle = 0;

  @override
  void initState() {
    super.initState();
    if (widget.availableRatios.isNotEmpty) {
      aspectRatio = aspectRatioOriginal = 1;
    }
    controller.currentState?.rotate(right: true);
  }

  @override
  void dispose() {
    controller.currentState?.dispose();
    super.dispose();
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
              padding: const EdgeInsets.only(bottom: 3),
            ),
            title: const Text(
              'Crop',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.check, size: 30),
                onPressed: () async {
                  var state = controller.currentState;
                  if (state == null) {
                    return;
                  }

                  var data = await cropImageDataWithNativeLibrary(state: state);
                  if (mounted) {
                    Navigator.pop(context, data);
                  }
                },
              ),
              const SizedBox(width: 20),
            ],
          ),
          body: SizedBox(
            child: ExtendedImage.memory(
              widget.image,
              cacheRawData: true,
              fit: BoxFit.contain,
              extendedImageEditorKey: controller,
              mode: ExtendedImageMode.editor,
              initEditorConfigHandler: (state) {
                return EditorConfig(
                  cornerColor: widget.darkTheme ? Colors.white : Colors.black,
                  cropAspectRatio: aspectRatio,
                  lineColor: widget.darkTheme ? Colors.white : Colors.black,
                );
              },
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: SizedBox(
              height: 80,
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (aspectRatioOriginal != null &&
                              aspectRatioOriginal != 1)
                            IconButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              icon: Icon(
                                Icons.portrait,
                                size: 30,
                                color: isLandscape
                                    ? Colors.grey
                                    : widget.darkTheme
                                        ? Colors.white
                                        : Colors.black,
                              ),
                              onPressed: () {
                                isLandscape = false;
                                if (aspectRatioOriginal != null) {
                                  aspectRatio = 1 / aspectRatioOriginal!;
                                }

                                setState(() {});
                              },
                            ),
                          if (aspectRatioOriginal != null &&
                              aspectRatioOriginal != 1)
                            IconButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              icon: Icon(
                                Icons.landscape,
                                size: 30,
                                color: isLandscape
                                    ? widget.darkTheme
                                        ? Colors.white
                                        : Colors.black
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                isLandscape = true;
                                aspectRatio = aspectRatioOriginal!;

                                setState(() {});
                              },
                            ),
                          for (var ratio in widget.availableRatios)
                            imageRatioButton(
                                ratio.ratio, ratio.title, widget.darkTheme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<Uint8List?> cropImageDataWithNativeLibrary(
      {required ExtendedImageEditorState state}) async {
    final Rect? cropRect = state.getCropRect();

    final EditActionDetails action = state.editAction!;

    final int rotateAngle = action.rotateAngle.toInt();

    final bool flipHorizontal = action.flipY;
    final bool flipVertical = action.flipX;

    final Uint8List img = state.rawImageData;

    final option = ImageEditorOption();

    if (action.needCrop) {
      option.addOption(ClipOption.fromRect(cropRect!));
    }

    if (action.needFlip) {
      option.addOption(
          FlipOption(horizontal: flipHorizontal, vertical: flipVertical));
    }

    if (action.hasRotateAngle) {
      option.addOption(RotateOption(rotateAngle));
    }

    final Uint8List? result = await ImageEditor.editImage(
      image: img,
      imageEditorOption: option,
    );

    return result;
  }

  Widget imageRatioButton(double? ratio, String title, bool darkTheme) {
    return TextButton(
      onPressed: () {
        aspectRatioOriginal = ratio;
        if (aspectRatioOriginal != null && isLandscape == false) {
          aspectRatio = 1 / aspectRatioOriginal!;
        } else {
          aspectRatio = aspectRatioOriginal;
        }

        setState(() {});
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: aspectRatioOriginal == ratio
                  ? darkTheme
                      ? Colors.white
                      : Colors.black
                  : Colors.grey,
            ),
          )),
    );
  }
}
