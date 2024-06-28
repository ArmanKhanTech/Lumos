import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quill/tool/image_filters.dart';
import 'package:quill/widget/bottom_button.dart';
import 'package:screenshot/screenshot.dart';

import 'package:quill/data/layer.dart';
import 'package:quill/layer/background_blur_layer.dart';
import 'package:quill/layer/background_layer.dart';
import 'package:quill/layer/emoji_layer.dart';
import 'package:quill/layer/image_layer.dart';
import 'package:quill/layer/text_layer.dart';
import 'package:quill/module/all_emojies.dart';
import 'package:quill/module/color_picker.dart';
import 'package:quill/module/text_overlay_screen.dart';
import 'package:quill/utility/utilities.dart';
import 'package:quill/widget/animated_on_tap_button.dart';
import 'package:quill/widget/loading_screen.dart';

import '../tool/image_adjust.dart';
import '../tool/image_cropper.dart';

late Size viewportSize;

List<Layer> layers = [], undoLayers = [], removedLayers = [];

class SingleImageEditor extends StatefulWidget {
  final Directory? savePath;
  final dynamic image;
  final List? imageList;
  final bool allowCamera, allowGallery, multiImages;
  final ImageEditorFeatures features;
  final List<AspectRatioOption> cropAvailableRatios;

  const SingleImageEditor({
    super.key,
    this.savePath,
    this.image,
    this.imageList,
    @Deprecated('Use features instead') this.allowCamera = false,
    @Deprecated('Use features instead') this.allowGallery = false,
    this.features = const ImageEditorFeatures(
      pickFromGallery: true,
      captureFromCamera: true,
      crop: true,
      blur: true,
      brush: true,
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
    required this.multiImages,
  });

  @override
  createState() => SingleImageEditorState();
}

class SingleImageEditorState extends State<SingleImageEditor> {
  ImageItem currentImage = ImageItem();

  Offset offset1 = Offset.zero;
  Offset offset2 = Offset.zero;

  final scaffoldGlobalKey = GlobalKey<ScaffoldState>();

  final GlobalKey container = GlobalKey();
  final GlobalKey globalKey = GlobalKey();

  ScreenshotController screenshotController = ScreenshotController();

  late Color topLeftColor, bottomRightColor;
  late Size viewportSize;

  @override
  void dispose() {
    layers.clear();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.image != null) {
      loadImage(widget.image!);
    }
    setState(() {});
    super.initState();
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

  Future<dynamic> exitDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierColor: Colors.black38,
        barrierDismissible: true,
        builder: (c) => Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetAnimationDuration: const Duration(milliseconds: 300),
              insetAnimationCurve: Curves.ease,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: BlurryContainer(
                  height: 250,
                  color: Colors.black.withOpacity(0.15),
                  blur: 5,
                  padding: const EdgeInsets.all(20),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'Cancel?',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "If you go back now, you'll lose all the edits you've made.",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white54,
                            letterSpacing: 0.1),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      AnimatedOnTapButton(
                        onTap: () async {
                          if (mounted) {
                            Navigator.pop(c, true);
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          'Yes',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.redAccent.shade200,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.1),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 22,
                        child: Divider(
                          color: Colors.white,
                        ),
                      ),
                      AnimatedOnTapButton(
                        onTap: () {
                          Navigator.pop(c, true);
                        },
                        child: const Text(
                          'No',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    viewportSize = MediaQuery.of(context).size;

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

        if (layerItem is ImageLayerData) {
          return ImageLayer(
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
            onUpdate: () {
              setState(() {});
            },
          );
        }

        if (layerItem is TextLayerData) {
          return TextLayer(
            layerData: layerItem,
            onUpdate: () {
              setState(() {});
            },
          );
        }

        return Container();
      }).toList(),
    );

    widthRatio = currentImage.width / viewportSize.width;
    heightRatio = currentImage.height / viewportSize.height;
    pixelRatio = max(widthRatio, heightRatio);

    return PopScope(
      onPopInvoked: (onPopInvoked) async {
        if (onPopInvoked) {
          return await exitDialog(context);
        }
      },
      child: Scaffold(
        key: scaffoldGlobalKey,
        backgroundColor: Colors.black,
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.black,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.chevron_back),
            onPressed: () {
              exitDialog(context);
            },
            iconSize: 30.0,
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 3),
          ),
          title: const Text(
            'Edit',
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(Icons.undo,
                  size: 30,
                  color: layers.length > 1 || removedLayers.isNotEmpty
                      ? Colors.white
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
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              icon: Icon(Icons.redo,
                  size: 30,
                  color: undoLayers.isNotEmpty ? Colors.white : Colors.grey),
              onPressed: () {
                if (undoLayers.isEmpty) {
                  return;
                }

                layers.add(undoLayers.removeLast());
                setState(() {});
              },
            ),
            IconButton(
              padding: const EdgeInsets.only(left: 10, right: 22),
              icon: const Icon(Icons.done, color: Colors.white, size: 30),
              onPressed: () async {
                resetTransformation();
                setState(() {});
                LoadingScreen(scaffoldGlobalKey).show();
                var binaryIntList =
                    await screenshotController.capture(pixelRatio: pixelRatio);
                LoadingScreen(scaffoldGlobalKey).hide();

                if (mounted) {
                  Navigator.of(context).pop(binaryIntList);
                }
              },
            ),
          ],
        ),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: MemoryImage(currentImage.image),
                fit: BoxFit.cover,
              ),
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10,
                        sigmaY: 10,
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Center(
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
                )
              ],
            )),
        bottomNavigationBar: Container(
          alignment: Alignment.bottomCenter,
          height: 78 + MediaQuery.of(context).padding.bottom,
          padding: const EdgeInsets.only(top: 15),
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.rectangle,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  BottomButton(
                    icon: CupertinoIcons.slider_horizontal_3,
                    text: 'Adjust',
                    onTap: () async {
                      resetTransformation();
                      LoadingScreen(scaffoldGlobalKey).show();
                      var mergedImage = await getMergedImage();

                      if (!mounted) {
                        return;
                      }

                      Uint8List? adjustedImage = await Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ImageAdjust(
                            image: mergedImage!,
                          ),
                        ),
                      );

                      LoadingScreen(scaffoldGlobalKey).hide();
                      if (adjustedImage == null) {
                        return;
                      }

                      removedLayers.clear();
                      undoLayers.clear();

                      var layer = BackgroundLayerData(
                        file: ImageItem(adjustedImage),
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
                      onTap: () async {
                        resetTransformation();

                        LoadingScreen(scaffoldGlobalKey).show();
                        var mergedImage = await getMergedImage();
                        LoadingScreen(scaffoldGlobalKey).hide();

                        if (!mounted) {
                          return;
                        }

                        Uint8List? croppedImage = await Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ImageCropper(
                              image: mergedImage!,
                              availableRatios: widget.cropAvailableRatios,
                            ),
                          ),
                        );

                        if (croppedImage == null) {
                          return;
                        }

                        flipValue = 0;
                        rotateValue = 0;
                        await currentImage.load(croppedImage);

                        setState(() {});
                      },
                    ),
                  if (widget.features.text)
                    BottomButton(
                      icon: Icons.text_fields,
                      text: 'Text',
                      onTap: () async {
                        TextLayerData? layer = await Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const TextEditorImage(),
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
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20)),
                          ),
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setS) {
                                return SingleChildScrollView(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            topLeft: Radius.circular(20)),
                                        border: Border(
                                          top: BorderSide(
                                              width: 1, color: Colors.white),
                                          bottom: BorderSide(
                                              width: 0, color: Colors.white),
                                          left: BorderSide(
                                              width: 0, color: Colors.white),
                                          right: BorderSide(
                                              width: 0, color: Colors.white),
                                        )),
                                    padding: const EdgeInsets.all(15),
                                    height: 280,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 5.0),
                                        const Padding(
                                          padding: EdgeInsets.only(left: 15),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Blur Color',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: BarColorPicker(
                                                thumbColor: Colors.white,
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
                                                  color: Colors.blue,
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
                                        const Padding(
                                          padding: EdgeInsets.only(left: 15),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Blur Radius',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(children: [
                                          Expanded(
                                            child: Slider(
                                              activeColor: Colors.white,
                                              inactiveColor: Colors.grey,
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
                                                  color: Colors.blue,
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
                                        const Padding(
                                          padding: EdgeInsets.only(left: 15),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Blur Opacity',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(children: [
                                          Expanded(
                                            child: Slider(
                                              activeColor: Colors.white,
                                              inactiveColor: Colors.grey,
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
                                                  color: Colors.blue,
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
                      onTap: () async {
                        resetTransformation();
                        LoadingScreen(scaffoldGlobalKey).show();
                        var mergedImage = await getMergedImage();

                        if (!mounted) {
                          return;
                        }

                        Uint8List? filterAppliedImage = await Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ImageFilters(
                              image: mergedImage!,
                            ),
                          ),
                        );

                        LoadingScreen(scaffoldGlobalKey).hide();
                        if (filterAppliedImage == null) {
                          return;
                        }

                        removedLayers.clear();
                        undoLayers.clear();
                        await currentImage.load(filterAppliedImage);

                        setState(() {});
                      },
                    ),
                  if (widget.features.emoji)
                    BottomButton(
                      icon: Icons.emoji_emotions_outlined,
                      text: 'Emoji',
                      onTap: () async {
                        EmojiLayerData? layer = await showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20)),
                          ),
                          builder: (BuildContext context) {
                            return const Emojies();
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
    );
  }

  final picker = ImagePicker();

  Future<void> loadImage(dynamic imageFile) async {
    await currentImage.load(imageFile);

    layers.clear();
    layers.add(BackgroundLayerData(
      file: currentImage,
    ));
    setState(() {});
  }
}

class ImageItem {
  int width = 300;
  int height = 300;

  double viewportRatio = 1;

  Uint8List image = Uint8List.fromList([]);

  Completer loader = Completer();

  ImageItem([dynamic img]) {
    if (img != null) load(img);
  }

  Future get status => loader.future;

  Future load(dynamic imageFile) async {
    loader = Completer();
    dynamic decodedImage;

    if (imageFile is ImageItem) {
      height = imageFile.height;
      width = imageFile.width;

      image = imageFile.image;
      viewportRatio = imageFile.viewportRatio;

      loader.complete(true);
    } else if (imageFile is File || imageFile is XFile) {
      image = await imageFile.readAsBytes();
      decodedImage = await decodeImageFromList(image);
    } else {
      image = imageFile;
      decodedImage = await decodeImageFromList(imageFile);
    }

    if (decodedImage != null) {
      height = decodedImage.height;
      width = decodedImage.width;
      viewportRatio = viewportSize.height / height;

      loader.complete(decodedImage);
    }

    return true;
  }
}
