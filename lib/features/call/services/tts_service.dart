import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;
  static bool _isEnabled = true;
  static const String _enabledKey = 'tts_enabled';

  static Future<void> init() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.4); // Slower for elderly users
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Load saved preference
    await _loadEnabledState();

    _isInitialized = true;
  }

  static Future<void> _loadEnabledState() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_enabledKey) ?? true;
  }

  static Future<bool> isEnabled() async {
    await _loadEnabledState();
    return _isEnabled;
  }

  static Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);

    if (!enabled) {
      await stop();
    }
  }

  static Future<void> speak(String text) async {
    await init();

    // Check if TTS is enabled
    if (!_isEnabled) return;

    await _flutterTts.speak(text);
  }

  static Future<void> speakContactName(String name) async {
    await speak(name);
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

  /// Force speak even if disabled (for testing)
  static Future<void> speakForce(String text) async {
    await init();
    await _flutterTts.speak(text);
  }
}
