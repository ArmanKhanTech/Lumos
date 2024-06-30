// ignore_for_file: use_build_context_synchronously
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:quill/data/constants.dart';
import 'package:quill/quill.dart';
import 'package:quill/utility/model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quill',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Quill Image Editor'),
      debugShowCheckedModeBanner: false,
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

  Uint8List? editedImage;
  List<Uint8List>? editedImages;

  Future<void> uploadPostSingleImage(
      {BuildContext? context, required XFile image}) async {
    // Open the single-image editor
    editedImage = await Navigator.push(
      context!,
      CupertinoPageRoute(
        builder: (context) => SingleImageEditor(
          image: image,
          darkTheme: true,
          background: EditorBackground.blur,
          viewportSize: MediaQuery.of(context).size,
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
  }

  Future<void> uploadPostMultipleImages({
    BuildContext? context,
    required List<XFile> images,
  }) async {
    // Open the multi-image editor
    editedImages = await Navigator.push(
      context!,
      CupertinoPageRoute(
        builder: (context) => MultiImageEditor(
          images: images,
          darkTheme: false,
          background: EditorBackground.none,
          viewportSize: MediaQuery.of(context).size,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(20),
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
                  setState(() {});
                }
              },
              child: const Text('Single Image Editor'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final List<XFile> images = await picker.pickMultiImage();
                if (images.isNotEmpty) {
                  await uploadPostMultipleImages(
                    context: context,
                    images: images,
                  );
                  setState(() {});
                }
              },
              child: const Text('Multiple Image Editor'),
            ),
            const SizedBox(height: 20),
            if (editedImage != null)
              Image.memory(
                editedImage!,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 4,
                fit: BoxFit.cover,
              ),
            if (editedImages != null)
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: editedImages!.length,
                itemBuilder: (context, index) {
                  return Image.memory(
                    editedImages![index],
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
