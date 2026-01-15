import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.4); // Slower for elderly users
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _isInitialized = true;
  }

  static Future<void> speak(String text) async {
    await init();
    await _flutterTts.speak(text);
  }

  static Future<void> speakContactName(String nickname,
      {String? realName}) async {
    String text = nickname;
    if (realName != null && realName.isNotEmpty) {
      text = '$nickname, $realName';
    }
    await speak(text);
  }

  static Future<void> speakCallConfirmation(String name) async {
    await speak('Calling $name. Tap the green button to confirm, or cancel.');
  }

  static Future<void> stop() async {
    await _flutterTts.stop();
  }

  static Future<void> dispose() async {
    await _flutterTts.stop();
    _isInitialized = false;
  }
}
