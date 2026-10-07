import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jshadowing_app/model/lesson_model.dart';
import 'package:just_audio/just_audio.dart';

class ConversationProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  LessonResponse? _lessonData;
  bool _isLoading = false;
  String? _errorMessage;
  int? _activeDialogueIndex;
  String? _currentLoadedAudioPath;

  // getter
  LessonResponse? get lessonData => _lessonData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AudioPlayer get audioPlayer => _audioPlayer;
  int? get activeDialogueIndex => _activeDialogueIndex;

  ConversationProvider() {
    _audioPlayer.positionStream.listen((postition) {
      _updateActiveDialogue(postition.inMilliseconds);
    });
  }

  Section? getSection(int unitId, int sectionId) {
    if (_lessonData == null || _lessonData!.unit != unitId) return null;
    try {
      final List<Section> sectionsList = _lessonData!.sections.cast<Section>();

      return sectionsList.firstWhere((s) => s.section == sectionId);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadConversationData() async {
    if (_lessonData != null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/data.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _lessonData = LessonResponse.fromJson(jsonData);
    } catch (e) {
      _errorMessage = "Failed to load data: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initAudio(String audioPath) async {
    if (_currentLoadedAudioPath == audioPath) return;

    try {
      _currentLoadedAudioPath = audioPath;
      await _audioPlayer.setAsset(audioPath);
    } catch (e) {
      debugPrint("Error initializing audio path: $e");
    }
  }

  // highlight dialogue dynamically
  void _updateActiveDialogue(int currentMs) {
    if (_lessonData == null) return;

    final dialogues = _lessonData!.sections.first.dialogues;
    int? newActiveIndex;
    for (int i = 0; i < dialogues.length; i++) {
      final d = dialogues[i];
      if (currentMs >= d.startMs && currentMs <= d.endMs) {
        newActiveIndex = i;
        break;
      }
    }

    if (_activeDialogueIndex != newActiveIndex) {
      _activeDialogueIndex = newActiveIndex;
      notifyListeners();
    }
  }

  // Jump audio directly to a targeted dialogue bubble when tapped
  void playDialogueSegment(int startMs) {
    _audioPlayer.seek(Duration(milliseconds: startMs));
    _audioPlayer.play();
  }

  void stopAndResetAudio() {
    _audioPlayer.stop();
    _audioPlayer.seek(Duration.zero);
    _activeDialogueIndex = null;
    _currentLoadedAudioPath = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Always clean up your players
    super.dispose();
  }
}
