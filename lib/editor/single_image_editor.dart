// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:pixel/widget/indicator/progress_indicator.dart';
import 'package:screenshot/screenshot.dart';

import 'package:pixel/utility/image_item.dart';
import 'package:pixel/widget/dialog/exit_dialog.dart';
import 'package:pixel/layer/background_blur_layer.dart';
import 'package:pixel/layer/background_layer.dart';
import 'package:pixel/layer/emoji_layer.dart';
import 'package:pixel/layer/text_layer.dart';
import 'package:pixel/widget/picker/emoji_picker.dart';
import 'package:pixel/widget/picker/color_picker.dart';
import 'package:pixel/tool/text_editor.dart';
import 'package:pixel/utility/model.dart';
import 'package:pixel/widget/screen/loading_screen.dart';
import 'package:pixel/data/constants.dart';
import 'package:pixel/tool/image_filters.dart';
import 'package:pixel/widget/button/bottom_button.dart';

import '../tool/image_adjust.dart';
import '../tool/image_cropper.dart';

List<Layer> layers = [], undoLayers = [], removedLayers = [];

class SingleImageEditor extends StatefulWidget {
  final dynamic image;

  final ImageEditorFeatures features;

  final List<AspectRatioOption> cropAvailableRatios;

  final Size viewportSize;

  final bool darkTheme;

  final EditorBackground background;

  const SingleImageEditor(
      {super.key,
      required this.image,
      this.features = const ImageEditorFeatures(
        adjust: true,
        crop: true,
        blur: true,
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
      required this.background});

  @override
  State<SingleImageEditor> createState() => _SingleImageEditorState();
}

class _SingleImageEditorState extends State<SingleImageEditor> {
  ImageItem currentImage = ImageItem();

  Offset offset1 = Offset.zero;
  Offset offset2 = Offset.zero;

  final scaffoldGlobalKey = GlobalKey<ScaffoldState>();

  final GlobalKey container = GlobalKey();
  final GlobalKey globalKey = GlobalKey();

  ScreenshotController screenshotController = ScreenshotController();

  late Color topLeftColor, bottomRightColor;

  @override
  void initState() {
    super.initState();
    if (widget.image != null) {
      loadImage(widget.image!);
    }
  }

  @override
  void dispose() {
    layers.clear();
    undoLayers.clear();
    removedLayers.clear();
    super.dispose();
  }

  double flipValue = 0;
  int rotateValue = 0;

  double x = 0;
  double y = 0;
  double z = 0;

  double lastScaleFactor = 1, scaleFactor = 1;
  double widthRatio = 1, heightRatio = 1, pixelRatio = 1;

  void resetTransformation() {
    scaleFactor = 1;
    x = 0;
    y = 0;
    setState(() {});
  }

  Future<Uint8List?> getMergedImage() async {
    if (layers.length == 1 && layers.first is BackgroundLayerData) {
      return (layers.first as BackgroundLayerData).file.image;
    } else if (layers.length == 1 && layers.first is ImageLayerData) {
      return (layers.first as ImageLayerData).image.image;
    }

    return screenshotController.capture(
      pixelRatio: pixelRatio,
    );
  }

  @override
  Widget build(BuildContext context) {
    var layersStack = Stack(
      children: layers.map<Widget>((layerItem) {
        if (layerItem is BackgroundLayerData) {
          return BackgroundLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        if (layerItem is BackgroundBlurLayerData && layerItem.radius > 0) {
          return BackgroundBlurLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        if (layerItem is EmojiLayerData) {
          return EmojiLayer(
            layerData: layerItem,
            darkTheme: widget.darkTheme,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        if (layerItem is TextLayerData) {
          return TextLayer(
            layerData: layerItem,
            darkTheme: widget.darkTheme,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        return Container();
      }).toList(),
    );

    widthRatio = currentImage.width / widget.viewportSize.width;
    heightRatio = currentImage.height / widget.viewportSize.height;
    pixelRatio = max(widthRatio, heightRatio);

    return PopScope(
        canPop: false,
        onPopInvoked: (onPopInvoked) async {
          if (onPopInvoked) return;
          return await exitDialog(context);
        },
        child: Theme(
          data: widget.darkTheme ? Constants.darkTheme : Constants.lightTheme,
          child: Scaffold(
            key: scaffoldGlobalKey,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  exitDialog(context);
                },
                iconSize: 30.0,
                color: widget.darkTheme ? Colors.white : Colors.black,
                padding: const EdgeInsets.only(bottom: 3),
              ),
              title: Text(
                'Edit',
                style: TextStyle(
                    color: widget.darkTheme ? Colors.white : Colors.black,
                    fontSize: 20),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(Icons.undo,
                      size: 30,
                      color: layers.length > 1 || removedLayers.isNotEmpty
                          ? widget.darkTheme
                              ? Colors.white
                              : Colors.black
                          : Colors.grey),
                  onPressed: () {
                    if (removedLayers.isNotEmpty) {
                      layers.add(removedLayers.removeLast());
                      setState(() {});
                      return;
                    }

                    if (layers.length <= 1) {
                      return; // do not remove image layer
                    }

                    undoLayers.add(layers.removeLast());
                    setState(() {});
                  },
                ),
                const SizedBox(width: 10),
                IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: Icon(Icons.redo,
                      size: 30,
                      color: undoLayers.isNotEmpty
                          ? widget.darkTheme
                              ? Colors.white
                              : Colors.black
                          : Colors.grey),
                  onPressed: () {
                    if (undoLayers.isEmpty) {
                      return;
                    }

                    layers.add(undoLayers.removeLast());
                    setState(() {});
                  },
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.done,
                      color: widget.darkTheme ? Colors.white : Colors.black,
                      size: 30),
                  onPressed: () async {
                    resetTransformation();
                    setState(() {});
                    LoadingScreen(scaffoldGlobalKey, widget.darkTheme).show();
                    var binaryIntList = await screenshotController.capture(
                        pixelRatio: pixelRatio);
                    LoadingScreen(scaffoldGlobalKey, widget.darkTheme).hide();

                    if (mounted) {
                      Navigator.of(context).pop(binaryIntList);
                    }
                  },
                ),
                const SizedBox(width: 20),
              ],
            ),
            body: currentImage.image.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      image: widget.background == EditorBackground.blur
                          ? DecorationImage(
                              image: MemoryImage(currentImage.image),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: widget.darkTheme ? Colors.black : Colors.white,
                    ),
                    child: Stack(
                      children: [
                        widget.background == EditorBackground.gradient
                            ? ImagePixels(
                                imageProvider: MemoryImage(currentImage.image),
                                builder:
                                    (BuildContext context, ImgDetails img) {
                                  topLeftColor = img.pixelColorAtAlignment!(
                                      Alignment.topLeft);
                                  bottomRightColor = img.pixelColorAtAlignment!(
                                      Alignment.bottomRight);

                                  return Container(
                                      decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        topLeftColor,
                                        bottomRightColor,
                                      ],
                                    ),
                                  ));
                                },
                              )
                            : const SizedBox(),
                        widget.background == EditorBackground.blur
                            ? Positioned.fill(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.2),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        // TODO: Fix size
                        Center(
                          child: SizedBox(
                              width: currentImage.width / pixelRatio,
                              height: currentImage.height / pixelRatio,
                              child: Center(
                                child: Screenshot(
                                  controller: screenshotController,
                                  child: RotatedBox(
                                    quarterTurns: rotateValue,
                                    child: Transform(
                                      transform: Matrix4(
                                        1,
                                        0,
                                        0,
                                        0,
                                        0,
                                        1,
                                        0,
                                        0,
                                        0,
                                        0,
                                        1,
                                        0,
                                        x,
                                        y,
                                        0,
                                        1 / scaleFactor,
                                      )..rotateY(flipValue),
                                      alignment: FractionalOffset.center,
                                      child: layersStack,
                                    ),
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ))
                : circularProgress(
                    context, widget.darkTheme ? Colors.white : Colors.black),
            bottomNavigationBar: Container(
              alignment: Alignment.bottomCenter,
              height: 75,
              padding: const EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                color: widget.darkTheme ? Colors.black : Colors.white,
                shape: BoxShape.rectangle,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (widget.features.adjust)
                        BottomButton(
                          icon: CupertinoIcons.slider_horizontal_3,
                          text: 'Adjust',
                          darkTheme: widget.darkTheme,
                          onTap: () async {
                            resetTransformation();
                            LoadingScreen(scaffoldGlobalKey, widget.darkTheme)
                                .show();
                            var mergedImage = await getMergedImage();

                            if (!mounted) {
                              return;
                            }

                            Uint8List? adjustedImage = await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ImageAdjust(
                                  image: mergedImage!,
                                  darkTheme: widget.darkTheme,
                                ),
                              ),
                            );

                            LoadingScreen(scaffoldGlobalKey, widget.darkTheme)
                                .hide();
                            if (adjustedImage == null) {
                              return;
                            }

                            removedLayers.clear();
                            undoLayers.clear();

                            var layer = BackgroundLayerData(
                              file:
                                  ImageItem(adjustedImage, widget.viewportSize),
                            );

                            layers.add(layer);
                            await layer.file.status;

                            setState(() {});
                          },
                        ),
                      if (widget.features.crop)
                        BottomButton(
                          icon: Icons.crop,
                          text: 'Crop',
                          darkTheme: widget.darkTheme,
                          onTap: () async {
                            resetTransformation();

                            LoadingScreen(scaffoldGlobalKey, widget.darkTheme)
                                .show();
                            var mergedImage = await getMergedImage();
                            LoadingScreen(scaffoldGlobalKey, widget.darkTheme)
                                .hide();

                            if (!mounted) {
                              return;
                            }

                            Uint8List? croppedImage = await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ImageCropper(
                                  image: mergedImage!,
                                  darkTheme: widget.darkTheme,
                                  availableRatios: widget.cropAvailableRatios,
                                ),
                              ),
                            );

                            if (croppedImage == null) {
                              return;
                            }

                            flipValue = 0;
                            rotateValue = 0;
                            await currentImage.load(
                                croppedImage, widget.viewportSize);

                            setState(() {});
                          },
                        ),
                      if (widget.features.text)
                        BottomButton(
                          icon: Icons.text_fields,
                          text: 'Text',
                          darkTheme: widget.darkTheme,
                          onTap: () async {
                            TextLayerData? layer = await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                    TextEditor(darkTheme: widget.darkTheme),
                              ),
                            );

                            if (layer == null) {
                              return;
                            }

                            undoLayers.clear();
                            removedLayers.clear();
                            layers.add(layer);

                            setState(() {});
                          },
                        ),
                      if (widget.features.flip)
                        BottomButton(
                          icon: Icons.flip,
                          text: 'Flip',
                          darkTheme: widget.darkTheme,
                          onTap: () {
                            setState(() {
                              flipValue = flipValue == 0 ? pi : 0;
                            });
                          },
                        ),
                      if (widget.features.rotate)
                        BottomButton(
                          icon: Icons.rotate_left,
                          text: 'Rotate',
                          darkTheme: widget.darkTheme,
                          onTap: () {
                            var t = currentImage.width;

                            currentImage.width = currentImage.height;
                            currentImage.height = t;
                            rotateValue--;

                            setState(() {});
                          },
                        ),
                      if (widget.features.blur)
                        BottomButton(
                          icon: Icons.blur_on,
                          text: 'Blur',
                          darkTheme: widget.darkTheme,
                          onTap: () {
                            var blurLayer = BackgroundBlurLayerData(
                              color: Colors.transparent,
                              radius: 0.0,
                              opacity: 0.0,
                            );

                            undoLayers.clear();
                            removedLayers.clear();
                            layers.add(blurLayer);

                            setState(() {});

                            showModalBottomSheet(
                              context: context,
                              backgroundColor: widget.darkTheme
                                  ? Colors.black
                                  : Colors.white,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setS) {
                                    return SingleChildScrollView(
                                      child: Container(
                                        padding: const EdgeInsets.all(15),
                                        height: 300,
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 5.0),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Blur Color',
                                                  style: TextStyle(
                                                    color: widget.darkTheme
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Row(children: [
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15),
                                                  child: BarColorPicker(
                                                    thumbColor: widget.darkTheme
                                                        ? Colors.white
                                                        : Colors.black,
                                                    cornerRadius: 10,
                                                    pickMode: PickMode.color,
                                                    colorListener: (int value) {
                                                      setS(() {
                                                        setState(() {
                                                          blurLayer.color =
                                                              Color(value);
                                                        });
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              TextButton(
                                                child: const Text(
                                                  'Reset',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 18),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    setS(() {
                                                      blurLayer.color =
                                                          Colors.transparent;
                                                    });
                                                  });
                                                },
                                              ),
                                              const SizedBox(width: 15),
                                            ]),
                                            const SizedBox(height: 10.0),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Blur Radius',
                                                  style: TextStyle(
                                                    color: widget.darkTheme
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Row(children: [
                                              Expanded(
                                                child: Slider(
                                                  activeColor: widget.darkTheme
                                                      ? Colors.white
                                                      : Colors.black,
                                                  inactiveColor: Colors.grey,
                                                  thumbColor: widget.darkTheme
                                                      ? Colors.white
                                                      : Colors.black,
                                                  value: blurLayer.radius,
                                                  min: 0.0,
                                                  max: 10.0,
                                                  onChanged: (v) {
                                                    setS(() {
                                                      setState(() {
                                                        blurLayer.radius = v;
                                                      });
                                                    });
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              TextButton(
                                                child: const Text(
                                                  'Reset',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 18),
                                                ),
                                                onPressed: () {
                                                  setS(() {
                                                    setState(() {
                                                      blurLayer.radius = 0.0;
                                                    });
                                                  });
                                                },
                                              ),
                                              const SizedBox(width: 15),
                                            ]),
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Blur Opacity',
                                                  style: TextStyle(
                                                    color: widget.darkTheme
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Row(children: [
                                              Expanded(
                                                child: Slider(
                                                  activeColor: widget.darkTheme
                                                      ? Colors.white
                                                      : Colors.black,
                                                  inactiveColor: Colors.grey,
                                                  thumbColor: widget.darkTheme
                                                      ? Colors.white
                                                      : Colors.black,
                                                  value: blurLayer.opacity,
                                                  min: 0.00,
                                                  max: 1.0,
                                                  onChanged: (v) {
                                                    setS(() {
                                                      setState(() {
                                                        blurLayer.opacity = v;
                                                      });
                                                    });
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              TextButton(
                                                child: const Text(
                                                  'Reset',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 18),
                                                ),
                                                onPressed: () {
                                                  setS(() {
                                                    setState(() {
                                                      blurLayer.opacity = 0.0;
                                                    });
                                                  });
                                                },
                                              ),
                                              const SizedBox(width: 15),
                                            ]),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      if (widget.features.filters)
                        BottomButton(
                          icon: Icons.photo_filter_outlined,
                          text: 'Filters',
                          darkTheme: widget.darkTheme,
                          onTap: () async {
                            resetTransformation();
                            LoadingScreen(scaffoldGlobalKey, widget.darkTheme)
                                .show();
                            var mergedImage = await getMergedImage();

                            if (!mounted) {
                              return;
                            }

                            Uint8List? filterAppliedImage =
                                await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ImageFilters(
                                  image: mergedImage!,
                                  darkTheme: widget.darkTheme,
                                ),
                              ),
                            );

                            LoadingScreen(scaffoldGlobalKey, widget.darkTheme)
                                .hide();
                            if (filterAppliedImage == null) {
                              return;
                            }

                            removedLayers.clear();
                            undoLayers.clear();
                            await currentImage.load(
                                filterAppliedImage, widget.viewportSize);

                            setState(() {});
                          },
                        ),
                      if (widget.features.emoji)
                        BottomButton(
                          icon: Icons.emoji_emotions_outlined,
                          text: 'Emoji',
                          darkTheme: widget.darkTheme,
                          onTap: () async {
                            EmojiLayerData? layer = await showModalBottomSheet(
                              context: context,
                              backgroundColor: widget.darkTheme
                                  ? Colors.black
                                  : Colors.white,
                              builder: (BuildContext context) {
                                return EmojiPicker(darkTheme: widget.darkTheme);
                              },
                            );

                            if (layer == null) {
                              return;
                            }

                            undoLayers.clear();
                            removedLayers.clear();
                            layers.add(layer);

                            setState(() {});
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Future<void> loadImage(dynamic imageFile) async {
    await currentImage.load(imageFile, widget.viewportSize);
    layers.clear();
    layers.add(BackgroundLayerData(
      file: currentImage,
    ));
    setState(() {});
  }
}
