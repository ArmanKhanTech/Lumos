import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor/image_editor.dart';

import 'package:quill/data/constants.dart';
import 'package:quill/editor/single_image_editor.dart';
import 'package:quill/utility/image_item.dart';
import 'package:quill/utility/utilities.dart';

import '../tool/image_filters.dart';

class MultiImageEditor extends StatefulWidget {
  final List<dynamic> images;
  final List<AspectRatioOption> cropAvailableRatios;

  final int maxLength;

  final ImageEditorFeatures features;

  final Size viewportSize;

  final bool darkTheme;

  final EditorBackground background;

  const MultiImageEditor({
    super.key,
    this.images = const [],
    this.maxLength = 10,
    this.features = const ImageEditorFeatures(
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
    required this.viewportSize,
    required this.darkTheme,
    required this.background,
  });

  @override
  createState() => MultiImageEditorState();
}

class MultiImageEditorState extends State<MultiImageEditor> {
  List<ImageItem> images = [];
  List<Uint8List> saveImages = [];
  List<GlobalKey<ExtendedImageEditorState>> editorKey = [];

  int index = 0;

  final List<AspectRatioOption> availableRatios = const [
    AspectRatioOption(title: '1:1', ratio: 1),
    AspectRatioOption(title: '4:3', ratio: 4 / 3),
    AspectRatioOption(title: '5:4', ratio: 5 / 4),
    AspectRatioOption(title: '7:5', ratio: 7 / 5),
    AspectRatioOption(title: '16:9', ratio: 16 / 9),
  ];

  double? aspectRatio;
  double? aspectRatioOriginal;

  bool isLandscape = true;

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
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                color:
                    aspectRatioOriginal == ratio ? Colors.white : Colors.grey,
              ),
            )),
      );
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
          'Customize',
          style: TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500),
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
            padding: const EdgeInsets.only(left: 10, right: 22),
            icon: const Icon(Icons.done, color: Colors.white, size: 30),
            onPressed: () async {
              for (int i = 0; i < images.length; i++) {
                final Uint8List? result = await cropImageDataWithNativeLibrary(
                  state: editorKey[i].currentState!,
                );
                if (result == null) {
                  return;
                } else {
                  saveImages.add(result);
                }
              }
              Navigator.of(context).pop(saveImages);
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(
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
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 1,
                              color: Colors.white,
                            ),
                            color: Colors.black,
                          ),
                          child: Stack(alignment: Alignment.center, children: [
                            GestureDetector(
                                onTap: () async {
                                  var img = await Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => SingleImageEditor(
                                          image: image,
                                          viewportSize: widget.viewportSize,
                                          darkTheme: widget.darkTheme,
                                          background: widget.background,
                                          features: widget.features),
                                    ),
                                  );
                                  if (img != null) {
                                    image.load(img, widget.viewportSize);
                                    setState(() {});
                                  }
                                },
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: ExtendedImage.memory(
                                      image.image,
                                      cacheRawData: true,
                                      fit: BoxFit.contain,
                                      mode: ExtendedImageMode.editor,
                                      extendedImageEditorKey: editorKey[index],
                                      initEditorConfigHandler: (state) {
                                        return EditorConfig(
                                          cornerColor: Colors.white,
                                          cropAspectRatio: aspectRatio,
                                          lineColor: Colors.white,
                                          editorMaskColorHandler:
                                              (context, pointerDown) {
                                            return Colors.transparent;
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                )),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Container(
                                height: 32,
                                width: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(60),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: IconButton(
                                  iconSize: 20,
                                  padding: const EdgeInsets.all(0),
                                  onPressed: () {
                                    images.remove(image);
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.clear_outlined,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 1,
                              left: 1,
                              child: Container(
                                height: 50,
                                width: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(100),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
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
                                        builder: (context) => ImageFilters(
                                          image: image.image,
                                          darkTheme: widget.darkTheme,
                                        ),
                                      ),
                                    );
                                    if (editedImage != null) {
                                      image.load(
                                          editedImage, widget.viewportSize);
                                    }
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.photo_filter_outlined,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ]),
                        );
                      },
                    )
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 80,
          child: Column(
            children: [
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 10,
                    ),
                  ],
                ),
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
                            size: 25,
                            color: isLandscape ? Colors.grey : Colors.white,
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
                            size: 25,
                            color: isLandscape ? Colors.white : Colors.grey,
                          ),
                          onPressed: () {
                            isLandscape = true;
                            aspectRatio = aspectRatioOriginal!;
                            setState(() {});
                          },
                        ),
                      for (var ratio in availableRatios)
                        imageRatioButton(ratio.ratio, ratio.title),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
