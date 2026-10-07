import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jshadowing_app/model/lesson_model.dart';
import 'package:just_audio/just_audio.dart';

class ConversationProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<LessonResponse>? _units;
  bool _isLoading = false;
  String? _errorMessage;
  int? _activeDialogueIndex;
  String? _currentLoadedAudioPath;

  int? _currentUnitId;
  int? _currentSectionId;

  // getter
  List<LessonResponse>? get units => _units;
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
    try {
      final targetUnit = _units!.firstWhere((u) => u.unit == unitId);
      return targetUnit.sections.firstWhere((s) => s.section == sectionId);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadConversationData() async {
    if (_units != null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/data.json',
      );
      final List<dynamic> decodedList = json.decode(jsonString);
      final parsedData = LessonListResponse.fromJsonList(decodedList);

      _units = parsedData.units;
    } catch (e) {
      _errorMessage = "Failed to load data: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initAudio(int unitId, int sectionId, String audioPath) async {
    _currentUnitId = unitId;
    _currentSectionId = sectionId;

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
    if (_units!.isEmpty ||
        _currentUnitId == null ||
        _currentSectionId == null) {
      return;
    }
    try {
      final targetUnit = _units!.firstWhere((u) => u.unit == _currentUnitId);
      final targetSection = targetUnit.sections.firstWhere(
        (s) => s.section == _currentSectionId,
      );

      final dialogues = targetSection.dialogues;
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
    } catch (e) {
      debugPrint("Error updating active dialogue: $e");
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
