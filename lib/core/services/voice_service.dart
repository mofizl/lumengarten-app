import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'tts_service.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final TtsService _ttsService = TtsService();
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _preferAudioFiles = true; // Bevorzuge Audio-Dateien über TTS

  // Getter für Status
  bool get isPlaying => _isPlaying;
  bool get isInitialized => _isInitialized;
  bool get preferAudioFiles => _preferAudioFiles;

  /// Initialisiert den Voice Service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Audio Player Event-Handler setzen
      _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        _isPlaying = state == PlayerState.playing;
        if (kDebugMode) {
          if (state == PlayerState.playing) {
            print('Voice: Started playing audio');
          } else if (state == PlayerState.completed) {
            print('Voice: Completed playing audio');
          }
        }
      });

      // TTS Service auch initialisieren als Fallback
      await _ttsService.initialize();
      
      _isInitialized = true;
      if (kDebugMode) print('Voice Service initialized successfully');
    } catch (e) {
      if (kDebugMode) print('Voice Service initialization error: $e');
    }
  }

  /// Spricht den gegebenen Text aus (Audio-Datei oder TTS)
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.isEmpty) return;

    try {
      // Stoppt eventuell laufende Wiedergabe
      await stop();
      
      // Versuche zuerst Audio-Datei zu finden und abzuspielen
      if (_preferAudioFiles) {
        final audioPath = _getAudioFileForText(text);
        if (audioPath.isNotEmpty) {
          try {
            await _playAudioFile(audioPath);
            return;
          } catch (e) {
            if (kDebugMode) print('Voice: Audio file failed, falling back to TTS: $e');
          }
        }
      }
      
      // Fallback zu TTS wenn keine Audio-Datei vorhanden
      if (kDebugMode) print('Voice: No audio file found for "$text", using TTS');
      await _ttsService.speak(text);
      
    } catch (e) {
      if (kDebugMode) print('Voice speak error: $e');
    }
  }

  /// Spielt eine Audio-Datei ab
  Future<void> _playAudioFile(String audioPath) async {
    try {
      if (kDebugMode) print('Voice: Attempting to play audio file: $audioPath');
      
      // Setze die Source
      await _audioPlayer.setSource(AssetSource(audioPath));
      
      // Spiele ab
      await _audioPlayer.resume();
      
      if (kDebugMode) print('Voice: Successfully started playing: $audioPath');
    } catch (e) {
      if (kDebugMode) print('Voice: Error playing audio file $audioPath: $e');
      rethrow; // Wirft den Fehler weiter, damit das Fallback zu TTS funktioniert
    }
  }

  /// Bestimmt die Audio-Datei für einen gegebenen Text
  String _getAudioFileForText(String text) {
    // Mapping von Texten zu Audio-Dateien
    final audioMap = <String, String>{
      // Story-Sequenz Texte
      'Es war einmal ein wunderschöner magischer Garten...': 'sounds/story/story_01_beautiful_garden.mp3',
      'Hier lebte Dunki, der freundliche Gartendrachen! 🐲': 'sounds/story/story_02_dunki_introduction.mp3',
      'Doch plötzlich... Ein dunkler Schatten zog über das Land! ⚡': 'sounds/story/story_03_dark_shadow.mp3',
      'Ein böser Zauberer hat alle Lichtblumen gestohlen! 😢': 'sounds/story/story_04_stolen_flowers.mp3',
      'Hallo! Ich bin Dunki, der Gartendrachen! Hilfst du mir, das Licht zurückzubringen?': 'sounds/story/story_05_call_for_help.mp3',
      'Hallo! Ich bin Dunki! Hilfst du mir?': 'sounds/story/story_05_call_for_help.mp3',
      
      // Lernbereich-Karten
      'Lese-Abenteuer. Magische Geschichten.': 'sounds/cards/reading_adventure.mp3',
      'Schreib-Werkstatt. Zauberhafte Buchstaben.': 'sounds/cards/writing_workshop.mp3',
      'Logik-Labor. Clevere Rätsel.': 'sounds/cards/logic_lab.mp3',
      'Zahlen-Zoo. Tierische Mathematik.': 'sounds/cards/number_zoo.mp3',
      
      // UI-Elemente
      'Willkommen in Dunkis Lumengarten!': 'sounds/ui/welcome.mp3',
      'Gut gemacht!': 'sounds/ui/well_done.mp3',
      'Versuche es nochmal!': 'sounds/ui/try_again.mp3',
    };

    // Bereinige Text für Lookup (entferne Emojis etc.)
    final cleanText = text
        .replaceAll('🐲', '')
        .replaceAll('⚡', '')
        .replaceAll('😢', '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');

    // Exakter Match
    if (audioMap.containsKey(text)) {
      return audioMap[text]!;
    }
    
    // Match mit bereinigtem Text
    if (audioMap.containsKey(cleanText)) {
      return audioMap[cleanText]!;
    }

    // Partial Match für ähnliche Texte
    for (var entry in audioMap.entries) {
      if (entry.key.toLowerCase().contains(cleanText.toLowerCase()) ||
          cleanText.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    return ''; // Keine Audio-Datei gefunden
  }

  /// Stoppt die aktuelle Wiedergabe
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      await _ttsService.stop();
      _isPlaying = false;
    } catch (e) {
      if (kDebugMode) print('Voice stop error: $e');
    }
  }

  /// Pausiert die Wiedergabe
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      await _ttsService.pause();
    } catch (e) {
      if (kDebugMode) print('Voice pause error: $e');
    }
  }

  /// Setzt die Präferenz für Audio-Dateien vs. TTS
  void setPreferAudioFiles(bool prefer) {
    _preferAudioFiles = prefer;
    if (kDebugMode) print('Voice: Set prefer audio files to $prefer');
  }

  /// Prüft ob eine Audio-Datei für den Text existiert
  bool hasAudioFile(String text) {
    return _getAudioFileForText(text).isNotEmpty;
  }

  /// Listet alle verfügbaren Audio-Dateien auf
  List<String> getAvailableAudioFiles() {
    return [
      'sounds/story/story_01_beautiful_garden.mp3',
      'sounds/story/story_02_dunki_introduction.mp3',
      'sounds/story/story_03_dark_shadow.mp3',
      'sounds/story/story_04_stolen_flowers.mp3',
      'sounds/story/story_05_call_for_help.mp3',
      'sounds/cards/reading_adventure.mp3',
      'sounds/cards/writing_workshop.mp3',
      'sounds/cards/logic_lab.mp3',
      'sounds/cards/number_zoo.mp3',
      'sounds/ui/welcome.mp3',
      'sounds/ui/well_done.mp3',
      'sounds/ui/try_again.mp3',
    ];
  }

  /// Setzt die Lautstärke für Audio-Wiedergabe (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
      await _ttsService.setVolume(volume);
    } catch (e) {
      if (kDebugMode) print('Voice setVolume error: $e');
    }
  }

  /// Dispose-Methode zum Aufräumen
  void dispose() {
    _audioPlayer.dispose();
    _ttsService.dispose();
    _isInitialized = false;
  }
}