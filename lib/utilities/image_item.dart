import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// The [ImageItem] class encapsulates the details of an image, including its dimensions (width and height),
/// viewport ratio, and the raw image data as a byte array. It also provides a [Completer] to handle the
/// asynchronous loading of the image.
class ImageItem {
  // The width of the image.
  int width = 300;

  /// The height of the image.
  int height = 300;

  /// The viewport ratio of the image.
  double viewportRatio = 1;

  /// The raw image data as a byte array.
  Uint8List image = Uint8List.fromList([]);

  /// A [Completer] to handle the asynchronous loading of the image.
  Completer loader = Completer();

  /// Creates an [ImageItem] instance.
  ImageItem([dynamic img, Size? viewportSize]) {
    if (img != null) load(img, viewportSize!);
  }

  /// The [status] getter returns the status of the image loader.
  Future get status => loader.future;

  /// The [load] method loads the image asynchronously and sets the image dimensions, viewport ratio, and raw image data.
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
