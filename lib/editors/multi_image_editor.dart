// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor/image_editor.dart';

import 'package:lumos/utilities/constants.dart';
import 'package:lumos/editors/single_image_editor.dart';
import 'package:lumos/utilities/image_item.dart';
import 'package:lumos/model/models.dart';
import 'package:lumos/widgets/dialog/exit_dialog.dart';

import '../tools/image_filters.dart';

/// The [MultiImageEditor] widget provides an interactive UI for users to edit multiple images
class MultiImageEditor extends StatefulWidget {
  /// The [images] list contains the images to be edited
  final List<dynamic> images;

  /// The [cropAvailableRatios] list defines preset aspect ratios for cropping
  final List<AspectRatioOption> cropAvailableRatios;

  /// The [features] parameter toggles the availability of various editing features
  final ImageEditorFeatures features;

  /// The [viewportSize] parameter defines the size of the viewport
  final Size viewportSize;

  /// The [darkTheme] parameter toggles between dark and light themes for the UI
  final bool darkTheme;

  /// The [background] parameter defines the background configuration
  final EditorBackground background;

  /// The [MultiImageEditor] constructor requires the [images], [viewportSize], [darkTheme], and [background] parameters
  const MultiImageEditor({
    super.key,
    required this.images,
    this.features = const ImageEditorFeatures(
      crop: true,
      blur: true,
      adjust: true,
      emoji: true,
      filters: true,
      flip: true,
      rotate: true,
      text: true,
    ),
    this.cropAvailableRatios = const [
      AspectRatioOption(title: 'Freeform'),
      AspectRatioOption(title: '1:1', ratio: 1),
      AspectRatioOption(title: '4:3', ratio: 4 / 3),
      AspectRatioOption(title: '5:4', ratio: 5 / 4),
      AspectRatioOption(title: '7:5', ratio: 7 / 5),
      AspectRatioOption(title: '16:9', ratio: 16 / 9),
    ],
    required this.viewportSize,
    required this.darkTheme,
    required this.background,
  });

  @override
  State<MultiImageEditor> createState() => _MultiImageEditorState();
}

class _MultiImageEditorState extends State<MultiImageEditor> {
  List<ImageItem> images = [];
  List<Uint8List> saveImages = [];
  List<GlobalKey<ExtendedImageEditorState>> editorKey = [];

  int index = 0;

  double? aspectRatio;
  double? aspectRatioOriginal;

  bool isLandscape = true, crop = false;

  int rotateAngle = 0;

  @override
  void initState() {
    super.initState();

    images =
        widget.images.map((e) => ImageItem(e, widget.viewportSize)).toList();
    aspectRatio = aspectRatioOriginal = 1;

    for (int i = 0; i < images.length; i++) {
      editorKey.add(GlobalKey<ExtendedImageEditorState>());
    }

    Timer(const Duration(milliseconds: 1000), () {
      setState(() {});
    });
  }

  @override
  void dispose() {
    for (var key in editorKey) {
      key.currentState?.dispose();
    }

    images.clear();
    saveImages.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) return;
          return await exitDialog(context, widget.darkTheme);
        },
        child: Theme(
            data: widget.darkTheme ? Constants.darkTheme : Constants.lightTheme,
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    exitDialog(context, widget.darkTheme);
                  },
                  iconSize: 30.0,
                  padding: const EdgeInsets.only(bottom: 3),
                ),
                title: const Text(
                  'Customize',
                  style: TextStyle(fontSize: 20),
                ),
                actions: [
                  widget.features.crop
                      ? IconButton(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          onPressed: () {
                            crop = !crop;
                            setState(() {});
                          },
                          icon: const Icon(Icons.crop, size: 30))
                      : const SizedBox(),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.done, size: 30),
                    onPressed: () async {
                      if (crop) {
                        for (int i = 0; i < images.length; i++) {
                          final Uint8List? result =
                              await cropImageDataWithNativeLibrary(
                            state: editorKey[i].currentState!,
                          );

                          if (result == null) {
                            return;
                          } else {
                            saveImages.add(result);
                          }
                        }
                      } else {
                        for (var image in images) {
                          saveImages.add(image.image);
                        }
                      }

                      Navigator.of(context).pop(saveImages);
                    },
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              body: Center(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: double.infinity,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(width: 32),
                          for (var image in images)
                            Builder(
                              builder: (BuildContext context) {
                                index = images.indexOf(image);

                                return Container(
                                  margin: const EdgeInsets.only(
                                      top: 32, right: 32, bottom: 32),
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      width: 1,
                                      color: widget.darkTheme
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    color: widget.darkTheme
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        GestureDetector(
                                            onTap: () async {
                                              var img = await Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                      SingleImageEditor(
                                                          image: image,
                                                          viewportSize: widget
                                                              .viewportSize,
                                                          darkTheme: widget
                                                              .darkTheme,
                                                          background:
                                                              widget.background,
                                                          cropAvailableRatios:
                                                              widget
                                                                  .cropAvailableRatios,
                                                          features:
                                                              widget.features),
                                                ),
                                              );

                                              if (img != null) {
                                                image.load(
                                                    img, widget.viewportSize);
                                                setState(() {});
                                              }
                                            },
                                            child: crop
                                                ? SizedBox(
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child:
                                                          ExtendedImage.memory(
                                                        image.image,
                                                        cacheRawData: true,
                                                        fit: BoxFit.contain,
                                                        mode: ExtendedImageMode
                                                            .editor,
                                                        extendedImageEditorKey:
                                                            editorKey[index],
                                                        initEditorConfigHandler:
                                                            (state) {
                                                          return EditorConfig(
                                                            cornerColor: widget
                                                                    .darkTheme
                                                                ? Colors.white
                                                                : Colors.black,
                                                            cropAspectRatio:
                                                                aspectRatio,
                                                            lineColor: widget
                                                                    .darkTheme
                                                                ? Colors.white
                                                                : Colors.black,
                                                            editorMaskColorHandler:
                                                                (context,
                                                                    pointerDown) {
                                                              return Colors
                                                                  .transparent;
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        child: Image.memory(
                                                          image.image,
                                                          fit: BoxFit.contain,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                              color: widget
                                                                      .darkTheme
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                            ));
                                                          },
                                                        )),
                                                  )),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: widget.darkTheme
                                                  ? Colors.white
                                                  : Colors.black,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topRight: Radius.circular(18),
                                                bottomLeft: Radius.circular(18),
                                              ),
                                            ),
                                            child: IconButton(
                                              iconSize: 30,
                                              padding: const EdgeInsets.all(0),
                                              onPressed: () {
                                                images.remove(image);
                                                setState(() {});
                                              },
                                              icon: Icon(Icons.clear_outlined,
                                                  color: widget.darkTheme
                                                      ? Colors.black
                                                      : Colors.white),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: widget.darkTheme
                                                  ? Colors.white
                                                  : Colors.black,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topRight: Radius.circular(18),
                                                bottomLeft: Radius.circular(18),
                                              ),
                                            ),
                                            child: IconButton(
                                              iconSize: 30,
                                              padding: const EdgeInsets.all(5),
                                              onPressed: () async {
                                                Uint8List? editedImage =
                                                    await Navigator.push(
                                                  context,
                                                  CupertinoPageRoute(
                                                    builder: (context) =>
                                                        ImageFilters(
                                                      image: image.image,
                                                      darkTheme:
                                                          widget.darkTheme,
                                                    ),
                                                  ),
                                                );

                                                if (editedImage != null) {
                                                  image.load(editedImage,
                                                      widget.viewportSize);
                                                }
                                                setState(() {});
                                              },
                                              icon: Icon(
                                                  Icons.photo_filter_outlined,
                                                  color: widget.darkTheme
                                                      ? Colors.black
                                                      : Colors.white),
                                            ),
                                          ),
                                        ),
                                      ]),
                                );
                              },
                            ),
                        ],
                      )),
                ),
              ),
              bottomNavigationBar: crop
                  ? Container(
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
                                        icon: Icon(Icons.portrait,
                                            size: 30,
                                            color: isLandscape
                                                ? Colors.grey
                                                : widget.darkTheme
                                                    ? Colors.white
                                                    : Colors.black),
                                        onPressed: () {
                                          isLandscape = false;
                                          if (aspectRatioOriginal != null) {
                                            aspectRatio =
                                                1 / aspectRatioOriginal!;
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
                                        icon: Icon(Icons.landscape,
                                            size: 30,
                                            color: isLandscape
                                                ? widget.darkTheme
                                                    ? Colors.white
                                                    : Colors.black
                                                : Colors.grey),
                                        onPressed: () {
                                          isLandscape = true;
                                          aspectRatio = aspectRatioOriginal!;
                                          setState(() {});
                                        },
                                      ),
                                    for (var ratio
                                        in widget.cropAvailableRatios)
                                      imageRatioButton(
                                          ratio.ratio, ratio.title),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
            )));
  }

  Widget imageRatioButton(double? ratio, String title) {
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
                  ? widget.darkTheme
                      ? Colors.white
                      : Colors.black
                  : Colors.grey,
            ),
          )),
    );
  }

  Future<Uint8List?> cropImageDataWithNativeLibrary(
      {required ExtendedImageEditorState state}) async {
    final Rect? cropRect = state.getCropRect();

    final EditActionDetails action = state.editAction!;

    final double rotateAngle = action.rotateDegrees;

    final Uint8List img = state.rawImageData;

    final option = ImageEditorOption();

    if (action.needCrop) {
      option.addOption(ClipOption.fromRect(cropRect!));
    }

    if (action.needFlip) {
      option.addOption(const FlipOption(horizontal: true, vertical: true));
    }

    if (action.hasRotateDegrees) {
      option.addOption(RotateOption(rotateAngle as int));
    }

    final Uint8List? result = await ImageEditor.editImage(
      image: img,
      imageEditorOption: option,
    );
    return result;
  }
}
