import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  Future<void> uploadPostSingleImage(
      {BuildContext? context, required File image}) async {
    try {
      Navigator.push(
        context!,
        CupertinoPageRoute(
          builder: (context) => SingleImageEditor(
            image: image,
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
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> uploadPostMultipleImages({
    BuildContext? context,
    required List<File> images,
  }) async {
    try {
      Navigator.push(
        context!,
        CupertinoPageRoute(
          builder: (context) => MultiImageEditor(
            images: images,
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
    } catch (e) {
      debugPrint(e.toString());
    }
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
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '//',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
