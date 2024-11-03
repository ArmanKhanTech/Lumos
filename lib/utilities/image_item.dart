import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// The [ImageItem] class encapsulates the details of an image, including its dimensions (width and height),
/// viewport ratio, and the raw image data as a byte array. It also provides a [Completer] to handle the
/// asynchronous loading of the image.
///
/// The constructor can initialize the image item with an existing image or load a new one based on the
/// provided file or byte data. The [load] method is responsible for reading the image from a file,
/// decoding it, and updating its dimensions and viewport ratio accordingly.
///
/// Properties:
/// - [width]: The width of the image.
/// - [height]: The height of the image.
/// - [viewportRatio]: The ratio of the viewport size to the image height.
/// - [image]: The raw image data in bytes.
/// - [loader]: A [Completer] that indicates when the image loading is complete.
///
/// Methods:
/// - [load]: Loads an image from a file or byte data and updates the image item properties.
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
