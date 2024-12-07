import 'package:flutter/material.dart';
import 'package:lumos/utilities/image_item.dart';

/// The [AspectRatioOption] class provides a title and ratio value for aspect ratio options.
class AspectRatioOption {
  /// The [title] of the aspect ratio option.
  final String title;

  /// The [ratio] value of the aspect ratio option.
  final double? ratio;

  /// The [AspectRatioOption] constructor requires a [title] parameter and
  const AspectRatioOption({
    required this.title,
    this.ratio,
  });
}

/// The [ImageEditorFeatures] class provides a set of features that can be enabled or disabled
class ImageEditorFeatures {
  /// The flags determines if the crop feature is enabled.
  final bool crop, text, adjust, flip, rotate, blur, filters, emoji;

  /// The [ImageEditorFeatures] constructor requires a set of optional parameters
  const ImageEditorFeatures({
    this.crop = false,
    this.blur = false,
    this.adjust = false,
    this.emoji = false,
    this.filters = false,
    this.flip = false,
    this.rotate = false,
    this.text = false,
  });
}

/// The [ImageEditorData] class provides data for the image editor, including the image file
class Layer {
  /// The [Layer] class provides properties for layers in the image editor, such as
  late Offset offset;

  /// The [Layer] class provides properties for layers in the image editor, such as
  late double rotation, scale, opacity;

  /// The [Layer] class provides properties for layers in the image editor, such as
  Layer({
    Offset? offset,
    double? opacity,
    double? rotation,
    double? scale,
  }) {
    this.offset = offset ?? const Offset(64, 64);
    this.opacity = opacity ?? 1;
    this.rotation = rotation ?? 0;
    this.scale = scale ?? 1;
  }
}

/// The [BackgroundLayerData] class provides image file data for the background layer
class BackgroundLayerData extends Layer {
  /// The [file] property contains the image file data for the background layer.
  ImageItem file;

  /// The [BackgroundLayerData] constructor requires an [file] parameter and
  BackgroundLayerData({
    required this.file,
  });
}

/// The [EmojiLayerData] class provides properties for the emoji layer, including text and size
class EmojiLayerData extends Layer {
  /// The [text] property contains the text for the emoji layer.
  String text;

  /// The [size] property contains the size for the emoji layer.
  double size;

  /// The [EmojiLayerData] constructor requires a [text] parameter and
  EmojiLayerData({
    this.text = '',
    this.size = 64,
    super.offset,
    super.opacity,
    super.rotation,
    super.scale,
  });
}

/// The [ImageLayerData] class provides properties for the image layer, including image and size
class ImageLayerData extends Layer {
  /// The [image] property contains the image for the image layer.
  ImageItem image;

  /// The [size] property contains the size for the image layer.
  double size;

  /// The [ImageLayerData] constructor requires an [image] parameter and
  ImageLayerData({
    required this.image,
    this.size = 64,
    super.offset,
    super.opacity,
    super.rotation,
    super.scale,
  });
}

/// The [TextLayerData] class provides properties for the text layer, including text and size
class TextLayerData extends Layer {
  /// The [text] property contains the text for the text layer.
  String text;

  /// The [size] property contains the size for the text layer.
  double size;

  /// The [color] property contains the color for the text layer.
  Color color, background;

  /// The [backgroundOpacity] property contains the background opacity for the text layer.
  int backgroundOpacity;

  /// The [align] property contains the alignment for the text layer.
  TextAlign align;

  /// The [TextLayerData] constructor requires a [text] parameter and
  TextLayerData({
    required this.text,
    this.size = 64,
    this.color = Colors.white,
    this.background = Colors.transparent,
    this.backgroundOpacity = 1,
    this.align = TextAlign.left,
    super.offset,
    super.opacity,
    super.rotation,
    super.scale,
  });
}

/// The [BackgroundBlurLayerData] class provides properties for the background blur layer
class BackgroundBlurLayerData extends Layer {
  /// The [color] property contains the color for the background blur layer.
  Color color;

  /// The [radius] property contains the radius for the background blur layer.
  double radius;

  /// The [BackgroundBlurLayerData] constructor requires a [color] and [radius] parameter and
  BackgroundBlurLayerData({
    required this.color,
    required this.radius,
    super.offset,
    super.opacity,
    super.rotation,
    super.scale,
  });
}
