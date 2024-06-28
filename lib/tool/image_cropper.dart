import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor/image_editor.dart';
import 'package:quill/data/theme.dart';
import 'package:quill/utility/utilities.dart';

class ImageCropper extends StatefulWidget {
  final Uint8List image;
  final List<AspectRatioOption> availableRatios;

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
  });

  @override
  createState() => ImageCropperState();
}

class ImageCropperState extends State<ImageCropper> {
  final GlobalKey<ExtendedImageEditorState> _controller =
      GlobalKey<ExtendedImageEditorState>();

  double? aspectRatio;
  double? aspectRatioOriginal;

  bool isLandscape = true;

  int rotateAngle = 0;

  @override
  void initState() {
    if (widget.availableRatios.isNotEmpty) {
      aspectRatio = aspectRatioOriginal = 1;
    }
    _controller.currentState?.rotate(right: true);
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
          'Crop',
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
              var state = _controller.currentState;
              if (state == null) {
                return;
              }

              var data = await cropImageDataWithNativeLibrary(state: state);
              if (mounted) {
                Navigator.pop(context, data);
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Theme(
        data: Constants.lightTheme,
        child: Container(
          color: Colors.black,
          child: ExtendedImage.memory(
            widget.image,
            cacheRawData: true,
            fit: BoxFit.contain,
            extendedImageEditorKey: _controller,
            mode: ExtendedImageMode.editor,
            initEditorConfigHandler: (state) {
              return EditorConfig(
                cornerColor: Colors.white,
                cropAspectRatio: aspectRatio,
                lineColor: Colors.white,
              );
            },
          ),
        ),
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
                      for (var ratio in widget.availableRatios)
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
              color: aspectRatioOriginal == ratio ? Colors.white : Colors.grey,
            ),
          )),
    );
  }
}
