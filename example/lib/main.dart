// ignore_for_file: use_build_context_synchronously
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lumos/data/constants.dart';
import 'package:lumos/lumos.dart';
import 'package:lumos/utility/model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Lumos Image Editor'),
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

  // The edited image or images are returned as Uint8List.
  Uint8List? editedImage;
  List<Uint8List>? editedImages;

  Future<void> uploadPostSingleImage(
      {BuildContext? context, required XFile image}) async {
    // Open the single-image editor.
    editedImage = await Navigator.push(
      context!,
      CupertinoPageRoute(
        builder: (context) => SingleImageEditor(
          image: image,
          darkTheme: true,
          background: EditorBackground.none,
          viewportSize: MediaQuery.of(context).size,
          features: const ImageEditorFeatures(
            crop: true,
            adjust: true,
            rotate: true,
            emoji: true,
            filters: true,
            flip: true,
            text: true,
            blur: true,
          ),
          cropAvailableRatios: const [
            AspectRatioOption(title: 'Freeform'),
            AspectRatioOption(title: '1:1', ratio: 1),
            AspectRatioOption(title: '4:3', ratio: 4 / 3),
            AspectRatioOption(title: '5:4', ratio: 5 / 4),
            AspectRatioOption(title: '7:5', ratio: 7 / 5),
            AspectRatioOption(title: '16:9', ratio: 16 / 9),
          ],
        ),
      ),
    );
  }

  Future<void> uploadPostMultipleImages({
    BuildContext? context,
    required List<XFile> images,
  }) async {
    // Open the multi-image editor.
    editedImages = await Navigator.push(
      context!,
      CupertinoPageRoute(
        builder: (context) => MultiImageEditor(
          images: images,
          darkTheme: true,
          background: EditorBackground.none,
          viewportSize: MediaQuery.of(context).size,
          features: const ImageEditorFeatures(
            crop: true,
            adjust: true,
            rotate: true,
            emoji: true,
            filters: true,
            flip: true,
            text: true,
            blur: true,
          ),
          cropAvailableRatios: const [
            AspectRatioOption(title: 'Freeform'),
            AspectRatioOption(title: '4:3', ratio: 4 / 3),
            AspectRatioOption(title: '5:4', ratio: 5 / 4),
            AspectRatioOption(title: '7:5', ratio: 7 / 5),
            AspectRatioOption(title: '16:9', ratio: 16 / 9),
          ],
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
