import 'package:flutter/material.dart';
import 'package:pixel/utility/image_item.dart';

class AspectRatioOption {
  final String title;
  final double? ratio;

  const AspectRatioOption({
    required this.title,
    this.ratio,
  });
}

class ImageEditorFeatures {
  final bool crop, text, adjust, flip, rotate, blur, filters, emoji;

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

class Layer {
  late Offset offset;

  late double rotation, scale, opacity;

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

class BackgroundLayerData extends Layer {
  ImageItem file;

  BackgroundLayerData({
    required this.file,
  });
}

class EmojiLayerData extends Layer {
  String text;
  double size;

  EmojiLayerData({
    this.text = '',
    this.size = 64,
    super.offset,
    super.opacity,
    super.rotation,
    super.scale,
  });
}

class ImageLayerData extends Layer {
  ImageItem image;
  double size;

  ImageLayerData({
    required this.image,
    this.size = 64,
    super.offset,
    super.opacity,
    super.rotation,
    super.scale,
  });
}

class TextLayerData extends Layer {
  String text;
  double size;
  Color color, background;
  int backgroundOpacity;
  TextAlign align;

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

class BackgroundBlurLayerData extends Layer {
  Color color;
  double radius;

  BackgroundBlurLayerData({
    required this.color,
    required this.radius,
    super.offset,
    super.opacity,
    super.rotation,
    super.scale,
  });
}
