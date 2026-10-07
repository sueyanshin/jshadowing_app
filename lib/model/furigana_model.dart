class FuriganaPart {
  final String text; // The base text (e.g., "渡辺" or "は")
  final String furigana; // The reading above it (e.g., "わたなべ" or "")

  FuriganaPart({required this.text, this.furigana = ""});

  bool get hasFurigana => furigana.isNotEmpty;
}

class FuriganaParser {
  static List<FuriganaPart> parse(String rawText) {
    final List<FuriganaPart> parts = [];
    final RegExp regExp = RegExp(r'([^\[]+)(?:\[([^\]]+)\])?');
    final matches = regExp.allMatches(rawText);

    for (final match in matches) {
      final base = match.group(1) ?? '';
      final furi = match.group(2) ?? '';

      if (furi.isNotEmpty) {
        parts.add(FuriganaPart(text: base, furigana: furi));
      } else {
        for (int i = 0; i < base.length; i++) {
          parts.add(FuriganaPart(text: base[i]));
        }
      }
    }

    return parts;
  }
}
