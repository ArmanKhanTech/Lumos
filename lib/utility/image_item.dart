import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class ImageItem {
  int width = 300;
  int height = 300;

  double viewportRatio = 1;

  Uint8List image = Uint8List.fromList([]);

  Completer loader = Completer();

  ImageItem([dynamic img, Size? viewportSize]) {
    if (img != null) load(img, viewportSize!);
  }

  Future get status => loader.future;

  Future load(dynamic imageFile, Size viewportSize) async {
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
