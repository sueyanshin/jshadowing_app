import 'package:flutter/material.dart';
import 'package:jshadowing_app/model/furigana_model.dart';

class FuriganaText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;
  final TextStyle furiganaStyle;
  const FuriganaText({
    required this.text,
    this.baseStyle = const TextStyle(fontSize: 18, color: Colors.black87),
    this.furiganaStyle = const TextStyle(fontSize: 10, color: Colors.grey),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final parts = FuriganaParser.parse(text);
    return Wrap(
      alignment: .start,
      crossAxisAlignment: .end,
      runSpacing: 4.0,
      children: parts.map((part) {
        return Column(
          children: [
            Text(part.hasFurigana ? part.furigana : '  ', style: furiganaStyle),
            Text(part.text, style: baseStyle),
          ],
        );
      }).toList(),
    );
  }
}
