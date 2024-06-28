// ignore_for_file: use_build_context_synchronously
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:quill/quill.dart';
import 'package:quill/utility/utilities.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quill Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Quill Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker picker = ImagePicker();

  Future<Uint8List> uploadPostSingleImage(
      {BuildContext? context, required XFile image}) async {
    // Convert the image to bytes
    Uint8List imageToEdit = await image.readAsBytes();

    // Open the single-image editor
    Uint8List editedImage = await Navigator.push(
      context!,
      CupertinoPageRoute(
        builder: (context) => SingleImageEditor(
          image: imageToEdit,
          multiImages: false,
          features: const ImageEditorFeatures(
            crop: true,
            rotate: true,
            brush: false,
            emoji: true,
            filters: true,
            flip: true,
            text: true,
            blur: true,
          ),
        ),
      ),
    );

    return editedImage;
  }

  Future<Uint8List> uploadPostMultipleImages({
    BuildContext? context,
    required List<XFile> images,
  }) async {
    // Convert the images to bytes
    List<Uint8List> imagesToEdit = [];
    for (int i = 0; i < images.length; i++) {
      imagesToEdit.add(await images[i].readAsBytes());
    }

    // Open the multi-image editor
    Uint8List editedImages = await Navigator.push(
      context!,
      CupertinoPageRoute(
        builder: (context) => MultiImageEditor(
          images: imagesToEdit,
          features: const ImageEditorFeatures(
            crop: true,
            rotate: true,
            brush: false,
            emoji: true,
            filters: true,
            flip: true,
            text: true,
            blur: true,
          ),
          maxLength: 5,
        ),
      ),
    );

    return editedImages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  await uploadPostSingleImage(
                    context: context,
                    image: image,
                  );
                }
              },
              child: const Text('Single Image Editor'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final List<XFile> images = await picker.pickMultiImage();
                await uploadPostMultipleImages(
                  context: context,
                  images: images,
                );
              },
              child: const Text('Multiple Image Editor'),
            ),
          ],
        ),
      ),
    );
  }
}
