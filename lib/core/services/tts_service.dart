import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isPlaying = false;

  // Getter für Status
  bool get isPlaying => _isPlaying;
  bool get isInitialized => _isInitialized;

  /// Initialisiert den TTS Service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Sprache auf Deutsch setzen
      await _flutterTts.setLanguage('de-DE');
      
      // Sprachgeschwindigkeit für Kinder anpassen (normal und natürlich)
      await _flutterTts.setSpeechRate(0.9);
      
      // Lautstärke setzen
      await _flutterTts.setVolume(0.8);
      
      // Tonhöhe für Kinder anpassen (nur leicht höher, nicht zu extrem)
      await _flutterTts.setPitch(1.1);

      // Versuche eine kindliche/weibliche Stimme zu wählen
      await _setChildFriendlyVoice();

      // Event-Handler setzen
      _flutterTts.setStartHandler(() {
        _isPlaying = true;
        if (kDebugMode) print('TTS: Started speaking');
      });

      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        if (kDebugMode) print('TTS: Completed speaking');
      });

      _flutterTts.setErrorHandler((message) {
        _isPlaying = false;
        if (kDebugMode) print('TTS Error: $message');
      });

      _isInitialized = true;
      if (kDebugMode) print('TTS Service initialized successfully');
    } catch (e) {
      if (kDebugMode) print('TTS initialization error: $e');
    }
  }

  /// Spricht den gegebenen Text aus
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.isEmpty) return;

    try {
      // Stoppt eventuell laufende Sprachausgabe
      await stop();
      
      // Bereinigt den Text von Emojis und anderen Symbolen
      final cleanText = _cleanTextForSpeech(text);
      
      if (cleanText.isNotEmpty) {
        if (kDebugMode) print('TTS: Speaking: "$cleanText"');
        await _flutterTts.speak(cleanText);
      }
    } catch (e) {
      if (kDebugMode) print('TTS speak error: $e');
    }
  }

  /// Stoppt die aktuelle Sprachausgabe
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isPlaying = false;
    } catch (e) {
      if (kDebugMode) print('TTS stop error: $e');
    }
  }

  /// Pausiert die Sprachausgabe
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      if (kDebugMode) print('TTS pause error: $e');
    }
  }

  /// Versucht eine kindgerechte Stimme zu setzen
  Future<void> _setChildFriendlyVoice() async {
    try {
      final voices = await _flutterTts.getVoices;
      if (voices != null && voices.isNotEmpty) {
        if (kDebugMode) {
          print('TTS: Available voices:');
          for (var voice in voices) {
            print('  - ${voice['name']} (${voice['locale']})');
          }
        }
        
        // Suche nach deutschen Stimmen
        final germanVoices = voices.where((voice) {
          final locale = voice['locale']?.toString().toLowerCase() ?? '';
          return locale.contains('de-de') || locale.contains('de_de') || locale.contains('german');
        }).toList();

        if (germanVoices.isNotEmpty) {
          // Sortiere Stimmen nach Präferenz (weiblich und freundlich klingend)
          germanVoices.sort((a, b) {
            final nameA = a['name']?.toString().toLowerCase() ?? '';
            final nameB = b['name']?.toString().toLowerCase() ?? '';
            
            // Bevorzuge eindeutig weibliche Namen
            int scoreA = 0;
            int scoreB = 0;
            
            if (nameA.contains('female') || nameA.contains('woman')) scoreA += 10;
            if (nameB.contains('female') || nameB.contains('woman')) scoreB += 10;
            
            // Bevorzuge freundlich klingende Namen
            final friendlyNames = ['google', 'microsoft', 'anna', 'julia', 'sarah', 'emma', 'maria'];
            for (String name in friendlyNames) {
              if (nameA.contains(name)) scoreA += 5;
              if (nameB.contains(name)) scoreB += 5;
            }
            
            return scoreB.compareTo(scoreA); // Höchste Punktzahl zuerst
          });
          
          final selectedVoice = germanVoices.first;
          if (kDebugMode) print('TTS: Selected voice: ${selectedVoice['name']} (${selectedVoice['locale']})');
          await _flutterTts.setVoice(selectedVoice);
        } else {
          if (kDebugMode) print('TTS: No German voices found, using default');
        }
      }
    } catch (e) {
      if (kDebugMode) print('TTS: Could not set child-friendly voice: $e');
    }
  }

  /// Bereinigt Text für die Sprachausgabe
  String _cleanTextForSpeech(String text) {
    return text
        // Ersetze Emojis mit Worten
        .replaceAll('🐲', 'Drache')
        .replaceAll('⚡', 'Blitz')
        .replaceAll('😢', 'traurig')
        .replaceAll('🌑', 'dunkler Mond')
        .replaceAll('🌱', 'Pflanze')
        .replaceAll('🌸', 'Blüte')
        .replaceAll('💎', 'Kristall')
        .replaceAll('✨', 'Sterne')
        .replaceAll('📚', 'Buch')
        .replaceAll('✏️', 'Stift')
        .replaceAll('🧪', 'Labor')
        .replaceAll('🦁', 'Löwe')
        .replaceAll('🎮', 'Spiel')
        .replaceAll('⭐', 'Stern')
        // Entferne andere Emojis
        .replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F5FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{1F680}-\u{1F6FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{1F700}-\u{1F77F}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{1F780}-\u{1F7FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{1F800}-\u{1F8FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{1F900}-\u{1F9FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{1FA00}-\u{1FA6F}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{1FA70}-\u{1FAFF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2600}-\u{26FF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\u{2700}-\u{27BF}]', unicode: true), '')
        // Bereinige Zeichensetzung
        .replaceAll('...', '. ')
        .replaceAll('!', '. ')
        .replaceAll('?', '. ')
        // Entferne Mehrfach-Leerzeichen
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Setzt die Sprachgeschwindigkeit (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate.clamp(0.1, 1.0));
    } catch (e) {
      if (kDebugMode) print('TTS setSpeechRate error: $e');
    }
  }

  /// Setzt die Lautstärke (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      if (kDebugMode) print('TTS setVolume error: $e');
    }
  }

  /// Überprüft verfügbare Sprachen
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages?.cast<String>() ?? [];
    } catch (e) {
      if (kDebugMode) print('TTS getLanguages error: $e');
      return [];
    }
  }

  /// Überprüft verfügbare Stimmen für eine Sprache
  Future<List<Map<String, String>>> getVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      return voices?.cast<Map<String, String>>() ?? [];
    } catch (e) {
      if (kDebugMode) print('TTS getVoices error: $e');
      return [];
    }
  }

  /// Dispose-Methode zum Aufräumen
  void dispose() {
    stop();
    _isInitialized = false;
  }
}