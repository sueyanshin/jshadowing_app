class LessonListResponse {
  final List<LessonResponse> units;

  LessonListResponse({required this.units});

  factory LessonListResponse.fromJsonList(List<dynamic> jsonList) {
    return LessonListResponse(
      units: jsonList
          .map((item) => LessonResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LessonResponse {
  final int unit;
  final String unitTitle;
  final List<Section> sections;

  LessonResponse({
    required this.unit,
    required this.unitTitle,
    required this.sections,
  });

  factory LessonResponse.fromJson(Map<String, dynamic> json) {
    return LessonResponse(
      unit: json['unit'],
      unitTitle: json['unit_title'],
      sections: (json['sections'] as List? ?? [])
          .map((i) => Section.fromJson(i))
          .toList(),
    );
  }
}

class Section {
  final int section;
  final String sectionTitle;
  final String audioAsset;
  final List<Dialogue> dialogues;

  new({
    required this.section,
    required this.sectionTitle,
    required this.audioAsset,
    required this.dialogues,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      section: json['section'],
      sectionTitle: json['section_title'],
      audioAsset: json['audio_asset'],
      dialogues: (json['dialogues'] as List? ?? [])
          .map((i) => Dialogue.fromJson(i))
          .toList(),
    );
  }
}

class Dialogue {
  final int itemNumber;
  final String speaker;
  final String japanese;
  final String furigana;
  final String myanmar;
  final int startMs;
  final int endMs;

  Dialogue({
    required this.itemNumber,
    required this.speaker,
    required this.japanese,
    required this.furigana,
    required this.myanmar,
    required this.startMs,
    required this.endMs,
  });

  factory Dialogue.fromJson(Map<String, dynamic> json) {
    return Dialogue(
      itemNumber: json['item_number'] ?? 0,
      speaker: json['speaker'] ?? '',
      japanese: json['japanese'] ?? '',
      furigana: json['furigana'] ?? '',
      myanmar: json['myanmar'] ?? '',
      startMs: json['start_ms'] ?? 0,
      endMs: json['end_ms'] ?? 0,
    );
  }
}
