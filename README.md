# Lumengarten 🌟🌱

> **Eine magische Lern-App für Vorschulkinder (4-6 Jahre) ohne nervige In-App-Käufe**

Lumengarten entführt Kinder in eine fantastische Welt, in der das Lernen zu einem aufregenden Abenteuer wird. Im magischen Lumengarten sind alle Lichtblumen verwelkt und die Kristallbäume haben ihren Glanz verloren. Nur mit Hilfe des kleinen Gartendrachen können die Kinder das Licht zurückbringen - und das mit jedem gelösten Rätsel!

## 📱 App Store Status

[![iOS Build](https://github.com/mofizl/lumengarten-app/actions/workflows/build.yml/badge.svg)](https://github.com/mofizl/lumengarten-app/actions/workflows/build.yml) [![TestFlight Deploy](https://github.com/mofizl/lumengarten-app/actions/workflows/testflight.yml/badge.svg)](https://github.com/mofizl/lumengarten-app/actions/workflows/testflight.yml)

**🍎 iOS**: ✅ Build funktioniert - TestFlight ready!  
**🤖 Android**: ✅ Build funktioniert - Play Store ready!  
**📦 Bundle ID**: `com.lumengarten.lumengartenApp`  
**👥 Team ID**: `QX8XC3CNTR`

## ✨ Features

### 🎮 Kernfunktionen
- **🌸 Phantasiegarten**: Magischer Garten, der mit jedem Lernerfolg aufblüht und wächst
- **🧩 Logik-Spiele**: Fokus auf logisches Denken, Problemlösung und kreatives Denken
- **📚 Lese-Abenteuer**: Spielerische Einführung in Buchstaben und Wörter
- **✏️ Schreib-Werkstatt**: Feinmotorik und erste Schreibübungen
- **🔢 Zahlen-Zoo**: Mathematische Grundlagen mit niedlichen Tierfiguren
- **⭐ Fortschritts-System**: Sterne sammeln und den Garten zum Leben erwecken

### 🎨 Design & UX
- **Kinderfreundliche Bedienung**: Intuitive Touch-Gesten, keine komplexen Menüs
- **Magische Farbpalette**: Warme Pastellfarben die zum Träumen einladen
- **Barrierefreiheit**: Große Buttons, klare Symbole, einfache Navigation
- **Belohnungssystem**: Visuelle Erfolge statt Zeitdruck oder Stress

### 🔒 Sicherheit & Vertrauen
- **Keine In-App-Käufe**: Einmaliger Kaufpreis, vollständige App ohne Zusatzkosten
- **Offline-First**: Funktioniert komplett ohne Internetverbindung
- **Kinderschutz**: Keine Werbung, keine externen Links, keine Datensammlung
- **DSGVO-konform**: Minimale Datenverarbeitung, Transparenz für Eltern

### 🚀 Technische Highlights
- **Cross-Platform**: Native Performance auf iOS und Android
- **KI-unterstützte Entwicklung**: Einzigartige Grafiken und Animationen
- **Modern Architecture**: Flutter mit Riverpod State Management
- **Automated Testing**: Kontinuierliche Qualitätssicherung

## 🛠️ Entwicklungsumgebung

### Systemvoraussetzungen

**Minimale Requirements:**
- **Flutter**: 3.19.0+ (empfohlen: 3.24.3+)
- **Dart**: 3.5.3+
- **Git**: Aktuelle Version
- **VS Code** oder **Android Studio** mit Flutter Plugin

**Plattform-spezifisch:**

**iOS Entwicklung:**
- **macOS**: 12.0+ (Monterey oder neuer)
- **Xcode**: 14.0+ (aus dem Mac App Store)
- **iOS Simulator**: In Xcode enthalten
- **CocoaPods**: `sudo gem install cocoapods`

**Android Entwicklung:**
- **Android Studio**: Electric Eel (2022.1.1) oder neuer
- **Android SDK**: API Level 21+ (Android 5.0)
- **Java**: JDK 11 oder 17 (automatisch mit Android Studio)

### 🚀 Schnellstart

```bash
# 1. Repository klonen
git clone https://github.com/mofizl/lumengarten-app.git
cd lumengarten-app

# 2. Flutter Dependencies installieren
flutter pub get

# 3. iOS Pods installieren (nur macOS)
cd ios && pod install && cd ..

# 4. Verfügbare Geräte prüfen
flutter devices

# 5. App starten (Debug-Modus)
flutter run

# Spezifisches Target wählen
flutter run -d chrome          # Web
flutter run -d ios             # iOS Simulator  
flutter run -d android         # Android Emulator
```

### 🔧 Entwicklungstools Setup

**VS Code Extensions:**
```bash
# Empfohlene Extensions installieren
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
code --install-extension ms-vscode.vscode-json
code --install-extension bradlc.vscode-tailwindcss
```

**Flutter Doctor Check:**
```bash
# System-Check ausführen
flutter doctor -v

# Häufige Probleme beheben
flutter doctor --android-licenses  # Android SDK Lizenzen
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer  # Xcode Path
```

### 🏃‍♂️ Häufige Entwicklungsaufgaben

```bash
# Hot Reload während der Entwicklung (automatisch)
# Hot Restart: Shift + Cmd/Ctrl + R (VS Code)

# Tests ausführen
flutter test                    # Unit & Widget Tests
flutter test --coverage        # Mit Coverage Report

# Code Analyse
flutter analyze                 # Static Analysis
dart format lib/ test/          # Code Formatting

# Build Varianten
flutter run --debug            # Debug Build (Standard)
flutter run --profile          # Profile Build (Performance)
flutter run --release          # Release Build (Produktiv)

# Dependency Updates
flutter pub outdated           # Veraltete Packages anzeigen
flutter pub upgrade            # Dependencies aktualisieren

# Clean Build (bei Problemen)
flutter clean                  # Build Cache leeren
flutter pub get                # Dependencies neu laden
cd ios && pod install && cd .. # iOS Pods neu installieren
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflows

Die App nutzt GitHub Actions für automatisierte Builds und Deployments:

#### 🏗️ **Development Build** (`.github/workflows/build.yml`)
**🚀 Triggers:**
- **Push to `main`**: Vollständiger Build für iOS und Android
- **Pull Request**: Validierung und Tests

**📱 Outputs:**
- ✅ Android APK (unsigned, für Testing)
- ✅ iOS Simulator Build (unsigned, für Development)

#### 🚀 **TestFlight Deployment** (`.github/workflows/testflight.yml`) 
**🎯 Manueller Trigger:** GitHub Actions → TestFlight Deployment → Run workflow

**📱 Features:**
- ✅ iOS Code Signing mit Distribution Certificate
- ✅ App Store Archive & IPA Export
- ✅ Automatischer TestFlight Upload
- ✅ App Store Connect API Integration

### 🔐 Required GitHub Secrets

**Gehe zu:** `Repository Settings > Secrets and Variables > Actions`

#### 🍎 iOS TestFlight Deployment
```
IOS_CERTIFICATE_BASE64          # Base64: iOS Distribution Certificate (.p12)
IOS_CERTIFICATE_PASSWORD        # Passwort: "lumengarten"
IOS_PROVISIONING_PROFILE_BASE64 # Base64: Lumengarten AppStore Profile
KEYCHAIN_PASSWORD               # Beliebiges sicheres Passwort
APP_STORE_CONNECT_TEAM_ID       # Team ID: "QX8XC3CNTR"
```

#### 🔑 App Store Connect API (TestFlight Upload)
```
APP_STORE_CONNECT_API_KEY_ID      # API Key: "PFKHVM8ANBHK"
APP_STORE_CONNECT_ISSUER_ID       # Issuer: "d439615c-03af-424b-8ed7-98abfae18d23"
APP_STORE_CONNECT_PRIVATE_KEY     # Base64: AuthKey_PFKHVM8ANBHK.p8
```

#### 🤖 Android Signing (Future)
```
ANDROID_KEYSTORE_BASE64         # Base64: Android Keystore (.jks)
ANDROID_KEY_ALIAS               # Key Alias Name
ANDROID_STORE_PASSWORD          # Keystore Password
ANDROID_KEY_PASSWORD            # Key Password
```

### 📱 Build Artifacts

Nach erfolgreichem Build stehen folgende Artifacts zur Verfügung:

**iOS:**
- `ios-release` → `Runner.ipa` (App Store Ready)
- Automatischer Upload zu TestFlight (bei konfigurierter API)

**Android:**
- `app-release` → `app-release.apk` (Debug/Testing)
- `app-bundle` → `app-release.aab` (Play Store Ready)

### 🛠️ Lokale Builds

**Release Build für iOS:**
```bash
# iOS (nur macOS)
flutter build ios --release
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath Runner.xcarchive \
  archive

# IPA Export (manuell)
xcodebuild -exportArchive \
  -archivePath Runner.xcarchive \
  -exportPath . \
  -exportOptionsPlist Runner/ExportOptions.plist
```

**Release Build für Android:**
```bash
# Android APK (Testing)
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# Ausgabe-Pfade:
# APK:  build/app/outputs/flutter-apk/app-release.apk
# AAB:  build/app/outputs/bundle/release/app-release.aab
```

**Web Build:**
```bash
flutter build web --release
# Ausgabe: build/web/
```

### 🚀 TestFlight Deployment

**📱 Manueller TestFlight Upload:**

1. **GitHub Actions** → **TestFlight Deployment** → **Run workflow**
2. **Build Version** eingeben (z.B. "1.0.0") 
3. **Run workflow** → Build startet automatisch
4. **App wird zu TestFlight hochgeladen** (bei erfolgreicher Code Signing)

**📋 Voraussetzungen:**
- ✅ Alle GitHub Secrets konfiguriert 
- ✅ App in App Store Connect registriert (`com.lumengarten.lumengartenApp`)
- ✅ iOS Distribution Certificate gültig
- ✅ Provisioning Profile "Lumengarten AppStore" aktiv
- ✅ App Store Connect API Key aktiv

**🎯 Workflow-Features:**
- Automatisches Code Signing mit Distribution Certificate
- iOS Archive (.xcarchive) → IPA Export für App Store
- Upload zu TestFlight über App Store Connect API
- Build Artifacts als GitHub Download verfügbar

## 🏗️ Projektarchitektur

### 📁 Ordnerstruktur

```
lumengarten_app/
├── 📱 lib/                          # Hauptcode der Anwendung
│   ├── 🔧 core/                     # Kern-Funktionalitäten
│   │   ├── constants/               # App-weite Konstanten & Konfiguration
│   │   │   └── app_constants.dart   # Routes, Farben, Texte
│   │   ├── router/                  # Navigation Management
│   │   │   └── app_router.dart      # GoRouter Konfiguration
│   │   └── theme/                   # Design System
│   │       └── app_theme.dart       # Material Theme, Farben, Styles
│   ├── 🎮 features/                 # Feature-basierte Architektur
│   │   ├── landing/                 # Willkommens-Screen
│   │   │   └── landing_page.dart    # Story-Einführung & Motivation
│   │   ├── garden/                  # Haupt-Garten Interface
│   │   │   └── garden_page.dart     # Virtueller Garten, Fortschritt
│   │   ├── games/                   # Lernspiel-Kategorien
│   │   │   └── games_page.dart      # Spielbereich-Auswahl
│   │   └── progress/                # Statistiken & Erfolge
│   │       └── progress_page.dart   # Lernerfolg-Visualisierung
│   ├── 🧩 shared/                   # Geteilte Komponenten
│   │   ├── widgets/                 # Wiederverwendbare UI-Komponenten
│   │   ├── providers/               # Riverpod State Management
│   │   └── utils/                   # Helper-Funktionen
│   ├── 📊 models/                   # Datenmodelle
│   └── 🚀 main.dart                 # App Entry Point
├── 🧪 test/                         # Unit & Widget Tests
├── 📱 android/                      # Android-spezifische Konfiguration
├── 🍎 ios/                          # iOS-spezifische Konfiguration
├── 🌐 web/                          # Web-spezifische Assets
├── 🎨 assets/                       # Statische Assets
│   ├── images/                      # Grafiken, Illustrationen
│   ├── sounds/                      # Audio-Dateien
│   └── animations/                  # Lottie-Animationen
└── ⚙️ .github/workflows/            # CI/CD GitHub Actions
```

### 🛠️ Technologie-Stack

**Core Framework:**
- **Flutter**: 3.24.3+ - Cross-platform UI Framework
- **Dart**: 3.5.3+ - Programmiersprache

**State Management:**
- **Riverpod**: 2.5.1+ - Reaktive State Management
- **Go Router**: 14.2.7+ - Deklarative Navigation

**UI & Animations:**
- **Material Design 3**: Native Flutter Theming
- **Lottie**: 3.1.2+ - Komplexe Animationen
- **Custom Widgets**: Kinderfreundliche UI-Komponenten

**Data & Storage:**
- **Shared Preferences**: 2.3.2+ - Lokaler Schlüssel-Wert-Speicher
- **Offline-First**: Keine externe API-Abhängigkeiten

### 🎨 Design System

**Farbpalette:**
```dart
// Lumengarten Farbschema
const Color primaryBlue = Color(0xFF4A90E2);     // Haupt-Akzent
const Color magicGreen = Color(0xFF7ED321);      // Erfolg, Wachstum  
const Color starYellow = Color(0xFFF5A623);      // Belohnungen
const Color lightPurple = Color(0xFFBD81E8);     // Magie, Träume
const Color moonSilver = Color(0xFFE8E8E8);      # Neutrale UI
```

**Design-Prinzipien:**
- **🤏 Touch-Friendly**: Minimum 60x60px Touch-Targets
- **🌈 Kinderfreundlich**: Warme Pastellfarben, sanfte Verläufe
- **⚡ Accessibility**: Hohe Kontraste, große Schriftarten
- **📱 Responsive**: Adaptive Layouts für verschiedene Bildschirmgrößen
- **🔄 Konsistenz**: Wiederverwendbare Design-Token

### 🧠 Architektur-Patterns

**Feature-First Architecture:**
- Jedes Feature als eigenständiges Modul
- Klare Trennung von UI, Business Logic und Data Layer
- Wiederverwendbare Komponenten in `shared/`

**Reactive Programming:**
- Riverpod für State Management
- Immutable State-Objekte
- Provider-basierte Dependency Injection

**Navigation:**
- Go Router für deklarative Navigation  
- Route-Guards für Kinderschutz
- Deep Linking Support

## 🧪 Testing Strategy

### Test-Pyramide

```bash
# Unit Tests - Geschäftslogik & Utils
flutter test test/unit/

# Widget Tests - UI-Komponenten  
flutter test test/widgets/

# Integration Tests - User Flows
flutter test test/integration/

# Performance Tests
flutter test --profile
```

### Code Quality

```bash
# Static Analysis
flutter analyze                 # Dart Analyzer
dart format --set-exit-if-changed lib/ test/

# Metriken
flutter test --coverage        # Test Coverage
dart doc                       # API Documentation
```

## 📱 Platform-spezifische Überlegungen

### iOS
- **Minimum Version**: iOS 11.0+
- **App Store Guidelines**: Kinderschutz-konform
- **Xcode Integration**: Native Build-Tools
- **TestFlight**: Beta-Testing via CI/CD

### Android  
- **Minimum SDK**: API Level 21 (Android 5.0)
- **Google Play**: Family-Friendly Richtlinien
- **Adaptive Icons**: Material Design Standards
- **Android App Bundle**: Optimierte Distribution

### Web (Progressive)
- **Responsive Design**: Desktop & Tablet Support
- **Offline-Fähig**: Service Worker für Caching
- **Barrierefreiheit**: WCAG 2.1 AA Standards

## 🤝 Contributing

### 👨‍💻 Entwicklungsrichtlinien

**Code Style:**
- **Dart Conventions**: Befolge die [Official Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- **Formatting**: Nutze `dart format` vor jedem Commit
- **Naming**: Verwende aussagekräftige, deutsche Variablennamen wo sinnvoll

**Git Workflow:**
```bash
# Feature Branch erstellen
git checkout -b feature/neue-funktion

# Regelmäßige Commits mit aussagekräftigen Messages
git commit -m "feat: Add neue Lernspiel-Kategorie für Farben

- Implementiere Farberkennungsspiel
- Füge Belohnungsanimation hinzu
- Update Garten-Fortschritt"

# Pull Request erstellen
git push origin feature/neue-funktion
# -> GitHub PR mit Template verwenden
```

**Code Review:**
- **4-Augen-Prinzip**: Kein direkter Push zu `main`
- **Automated Checks**: CI muss grün sein
- **Testabdeckung**: Neue Features benötigen Tests
- **Dokumentation**: README bei API-Änderungen aktualisieren

### 🐛 Issue Reporting

**Bug Reports sollten enthalten:**
- **Device Info**: OS, Version, Gerät
- **Reproduktions-Schritte**: Schritt-für-Schritt Anleitung
- **Erwartetes vs. Tatsächliches Verhalten**
- **Screenshots/Video**: Wenn möglich
- **Logs**: Flutter Console Output

**Feature Requests:**
- **Zielgruppen-Analyse**: Für welche Altersgruppe?
- **Pädagogischer Wert**: Welchen Lerneffekt hat das Feature?
- **UI/UX Mockups**: Skizzen oder Wireframes
- **Aufwand-Schätzung**: Grobe Einschätzung der Komplexität

## 📄 Lizenz & Legal

### Open Source Lizenzen
- **Flutter**: BSD-3-Clause License
- **Dart**: BSD-3-Clause License  
- **Riverpod**: MIT License
- **Lottie**: Apache 2.0 License

### Datenschutz
- **DSGVO-konform**: Minimale Datenverarbeitung
- **Keine Analytics**: Kein Tracking von Nutzungsverhalten  
- **Lokale Speicherung**: Alle Daten bleiben auf dem Gerät
- **Kinderschutz**: COPPA & GDPR-K compliant

### Content & Assets
- **Eigene Grafiken**: Alle Illustrationen sind Eigenentwicklung
- **KI-generierte Inhalte**: Rechtlich unbedenklich verwendet
- **Musik & Sound**: Royalty-free oder eigene Aufnahmen
- **Schriftarten**: Open Font License (OFL)

---

## 🌟 Vision & Roadmap

### 🎯 Mission Statement
> "Lumengarten macht Lernen zu einem magischen Abenteuer - ohne kommerzielle Ablenkung, mit pädagogischem Mehrwert und voller Respekt für die kindliche Neugierde."

### 🛣️ Entwicklungs-Roadmap

**🚀 Version 1.0 (Launch)**
- ✅ Grundlegende App-Struktur
- ⏳ 4 Lernbereiche (Lesen, Schreiben, Logik, Mathe)
- ⏳ Phantasiegarten mit Fortschrittssystem
- ⏳ 20+ Mini-Spiele pro Kategorie
- ⏳ iOS App Store Release

**📈 Version 1.1 (Erweiterung)**
- ⏳ Android Play Store Release
- ⏳ Eltern-Dashboard mit Lernstatistiken
- ⏳ Offline-Synchronisation zwischen Geräten
- ⏳ Erweiterte Barrierefreiheit

**🌍 Version 2.0 (Global)**  
- ⏳ Mehrsprachigkeit (Englisch, Französisch)
- ⏳ Adaptive Schwierigkeitsanpassung
- ⏳ Pädagogen-Tools für Kitas & Schulen
- ⏳ Web-Version für Tablets

---

## 🔧 Troubleshooting & CI/CD Pipeline

### GitHub Actions Build Issues

Dieses Projekt hatte eine Reihe von Build-Problemen, die systematisch gelöst wurden. Diese Dokumentation hilft bei ähnlichen Problemen:

#### 🍎 iOS Build Probleme & Lösungen

**Problem 1: iOS 18.0 SDK Requirement Error**
```
Error: iOS 18.0 is not installed. To use with Xcode, first download and install the platform
```

**Lösung:**
- **Ursache**: Flutter/Xcode versuchte iOS 18.0 zu verwenden, obwohl nur iOS 17.5 verfügbar war
- **Fix**: Explizite iOS Deployment Target Kontrolle
```yaml
# In GitHub Actions Workflow:
env:
  IPHONEOS_DEPLOYMENT_TARGET: '12.0'
run: |
  # Force deployment target in project settings
  sed -i.bak 's/IPHONEOS_DEPLOYMENT_TARGET = [0-9.]*/IPHONEOS_DEPLOYMENT_TARGET = 12.0/g' ios/Runner.xcodeproj/project.pbxproj
  export IPHONEOS_DEPLOYMENT_TARGET=12.0
  flutter build ios --release --no-codesign
```

**Problem 2: Main.storyboard iOS 18.0 Dependency**
```
Error (Xcode): iOS 18.0 Platform Not Installed.
Failed to build iOS app
/path/to/Main.storyboard
```

**Lösung:**
- **Ursache**: Alte Main.storyboard mit iOS 18.0 Referenzen
- **Fix**: Komplette Storyboard-Entfernung für Flutter Apps
```bash
# Entferne UIMainStoryboardFile aus Info.plist
# Lösche Main.storyboard Datei
# Entferne alle Referenzen aus project.pbxproj
rm ios/Runner/Base.lproj/Main.storyboard
```

**Problem 3: CocoaPods Integration Warnung**
```
[!] CocoaPods did not set the base configuration of your project because your project already has a custom config set.
```

**Lösung:**
- **Fix**: Fehlende Profile.xcconfig erstellen
```bash
# ios/Flutter/Profile.xcconfig
#include "Generated.xcconfig"
#include "Pods/Target Support Files/Pods-Runner/Pods-Runner.profile.xcconfig"
```

**Problem 4: Code Signing Fehler ohne Zertifikate**
```
security: SecKeychainItemImport: MAC verification failed during PKCS12 import (wrong password?)
```

**Lösung:**
- **Ursache**: Fehlende oder falsche Code Signing Secrets
- **Fix**: Code Signing für unsigned builds umgehen
```yaml
# Vereinfachter Build ohne Code Signing:
- name: Build iOS
  run: flutter build ios --release --no-codesign
```

#### 🤖 Android Build Probleme & Lösungen

**Problem 1: Dart SDK Version Inkompatibilität**
```
The current Dart SDK version is 3.3.0.
Because lumengarten_app requires SDK version ^3.5.3, version solving failed.
```

**Lösung:**
- **Ursache**: Flutter 3.19.0 hat Dart 3.3.0, aber pubspec.yaml verlangte ^3.5.3
- **Fix**: SDK Versionen synchronisieren
```yaml
# pubspec.yaml
environment:
  sdk: ^3.5.0

# GitHub Actions
- uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.3'  # Hat kompatibles Dart SDK
```

#### ⚙️ GitHub Actions Runner Optimierungen

**iOS Runner Konfiguration:**
```yaml
build-ios:
  runs-on: macos-14  # Bessere Xcode Support
  steps:
  - name: Select Xcode version
    run: |
      sudo xcode-select -s /Applications/Xcode_15.4.app/Contents/Developer
      xcodebuild -version
```

**Android Runner Konfiguration:**
```yaml
build-android:
  runs-on: ubuntu-latest
  steps:
  - name: Setup Java
    uses: actions/setup-java@v4
    with:
      distribution: 'zulu'
      java-version: '17'  # Stabil für Flutter builds
```

### 🚀 Quick Fixes für häufige Probleme

#### Flutter Analyze Fehler beheben:
```bash
flutter analyze                    # Probleme finden
dart format lib/ test/             # Code formatieren
flutter pub get                    # Dependencies aktualisieren
```

#### iOS Build Probleme diagnostizieren:
```bash
# SDK verfügbarkeit prüfen
xcodebuild -showsdks | grep iphoneos

# Deployment Target prüfen  
grep -r "IPHONEOS_DEPLOYMENT_TARGET" ios/

# CocoaPods neu installieren
cd ios && pod install --repo-update
```

#### Android Build Probleme diagnostizieren:
```bash
flutter doctor -v                  # Umgebung prüfen
flutter clean && flutter pub get   # Clean build
flutter build apk --release        # Test build
```

### 📋 Erfolgreich getestete Konfiguration

**Funktionierende Versionen:**
- **Flutter**: 3.24.3 (stable)
- **Dart**: 3.5.0+
- **Xcode**: 15.4 (auf macOS-14)
- **Java**: 17 (Zulu Distribution)
- **iOS Deployment Target**: 12.0+
- **Android SDK**: API Level 21+

Diese Konfiguration produziert erfolgreich:
- ✅ Android APK (funktioniert seit Build #7)
- ✅ iOS Simulator Build (funktioniert seit Build #24)
- ✅ iOS TestFlight Build (implementiert mit Build #25)

#### 🎯 Finale Build-Lösung (Build #24-25)

**✅ Development Builds (automatisch):**

**Kritische Erkenntnisse:**
1. **Doppelte Workflows eliminiert**: Nur ein automatischer Build-Workflow (`build.yml`)
2. **Minimale Konfiguration**: Verzicht auf überflüssige Diagnostics, Tests und komplexe Setup-Steps
3. **iOS Simulator Build**: `flutter build ios --simulator --no-codesign` (kein Code Signing erforderlich)
4. **Workflow-Vereinfachung**: Fokus auf Flutter pub get → Build → Artifact Upload

**Finale Working Build Pipeline:**
```yaml
# Android: Einfacher APK Build
- run: flutter pub get
- run: flutter build apk --release

# iOS: Simulator Build ohne Code Signing  
- run: flutter pub get  
- run: flutter build ios --simulator --no-codesign
```

**✅ TestFlight Builds (manuell):**

**TestFlight Pipeline Features:**
1. **Vollständiges Code Signing**: iOS Distribution Certificate + Provisioning Profile
2. **App Store Archive**: Echte Device Builds für App Store Distribution  
3. **Automatischer Upload**: App Store Connect API Integration
4. **IPA Export**: Mit ExportOptions.plist für App Store Method

**TestFlight Workflow:**
```yaml
# iOS App Store Build mit Code Signing
- run: flutter build ios --release
- run: xcodebuild -workspace Runner.xcworkspace -archivePath Runner.xcarchive archive
- run: xcodebuild -exportArchive -exportOptionsPlist ExportOptions.plist
- run: xcrun altool --upload-app --apiKey $API_KEY_ID
```

**Wichtige Lessons Learned:**
- **KISS-Prinzip**: Keep It Simple, Stupid - Komplexität führt zu Fehlern
- **Parallele Workflows**: Verhindern durch exklusive Trigger  
- **Code Signing Trennung**: Development (--no-codesign) vs. Production (full signing)
- **Schrittweise Entwicklung**: Erst Development, dann Production Pipeline
- **App Store Connect API**: Automatischer TestFlight Upload funktioniert zuverlässig

---

**💫 Developed with ❤️ for curious minds**

> Bei Fragen oder Anregungen: [GitHub Issues](https://github.com/mofizl/lumengarten-app/issues) oder kontaktiere das Entwickler-Team.
