# Kinderstimmen Audio-Dateien

Dieses Verzeichnis enthält die Audio-Aufnahmen von Kindern für die natürliche Sprachausgabe.

## Verzeichnisstruktur:

### story/ - Geschichte Audio-Dateien
- `story_01_beautiful_garden.mp3` - "Es war einmal ein wunderschöner magischer Garten..."
- `story_02_dunki_introduction.mp3` - "Hier lebte Dunki, der freundliche Gartendrachen!"
- `story_03_dark_shadow.mp3` - "Doch plötzlich... Ein dunkler Schatten zog über das Land!"
- `story_04_stolen_flowers.mp3` - "Ein böser Zauberer hat alle Lichtblumen gestohlen!"
- `story_05_call_for_help.mp3` - "Hallo! Ich bin Dunki, der Gartendrachen! Hilfst du mir, das Licht zurückzubringen?"

### cards/ - Lernbereich-Karten Audio-Dateien
- `reading_adventure.mp3` - "Lese-Abenteuer. Magische Geschichten."
- `writing_workshop.mp3` - "Schreib-Werkstatt. Zauberhafte Buchstaben."
- `logic_lab.mp3` - "Logik-Labor. Clevere Rätsel."
- `number_zoo.mp3` - "Zahlen-Zoo. Tierische Mathematik."

### ui/ - Benutzeroberfläche Audio-Dateien
- `welcome.mp3` - "Willkommen in Dunkis Lumengarten!"
- `well_done.mp3` - "Gut gemacht!"
- `try_again.mp3` - "Versuche es nochmal!"

## Audio-Anforderungen:

### Technische Spezifikationen:
- **Format**: MP3 (für beste Kompatibilität)
- **Bitrate**: 128 kbps (gute Qualität, moderate Dateigröße)
- **Sample Rate**: 44.1 kHz
- **Kanäle**: Mono (ausreichend für Sprache, kleinere Dateien)
- **Lautstärke**: Normalisiert auf -12dB bis -16dB (konsistente Lautstärke)

### Aufnahme-Tipps:
1. **Umgebung**: Ruhiger Raum ohne Echo oder Hintergrundgeräusche
2. **Mikrofon**: Gutes USB-Mikrofon oder Headset, etwa 15-20cm Abstand
3. **Sprechweise**: Langsam, deutlich, freundlich und kindgerecht
4. **Pausen**: Natürliche Pausen an Kommas und Satzzeichen
5. **Emotion**: Enthusiastisch und einladend, besonders bei der Story

### Kinderstimmen:
- **Alter**: 6-10 Jahre optimal (klingen für 4-6 Jahre alte Zielgruppe freundlich)
- **Geschlecht**: Gemischt oder überwiegend weiblich (klingt meist freundlicher)
- **Anzahl**: 2-3 verschiedene Stimmen für Abwechslung
- **Konsistenz**: Gleiche Stimme für zusammenhängende Texte (z.B. komplette Story)

## Fallback-System:
Falls Audio-Dateien fehlen, wird automatisch TTS (Text-to-Speech) verwendet.
Das System prüft zuerst nach Audio-Dateien, dann nach TTS als Backup.

## Hinweise:
- Dateinamen müssen exakt mit den Pfaden in `voice_service.dart` übereinstimmen
- Bei Änderungen der Texte müssen entsprechende Audio-Dateien neu aufgenommen werden
- Größere Dateien verlängern die App-Ladezeit - Balance zwischen Qualität und Größe beachten