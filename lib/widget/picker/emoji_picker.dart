import 'package:flutter/material.dart';

import '../../data/emojies.dart';
import '../../data/layer.dart';

class EmojiPicker extends StatefulWidget {
  final bool darkTheme;

  const EmojiPicker({super.key, required this.darkTheme});

  @override
  createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              'Select Emoji',
              style: TextStyle(
                color: widget.darkTheme ? Colors.white : Colors.black,
                fontSize: 18,
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Container(
            height: 320,
            padding: const EdgeInsets.only(
              left: 20,
              right: 10,
              top: 5,
            ),
            child: GridView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisSpacing: 0.0,
                maxCrossAxisExtent: 60.0,
              ),
              children: emojis.map((String emoji) {
                return GridTile(
                    child: GestureDetector(
                  onTap: () {
                    Navigator.pop(
                      context,
                      EmojiLayerData(
                        text: emoji,
                        size: 30.0,
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.zero,
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ));
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
