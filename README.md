# Lumengarten 🌟🌱

Eine kinderfreundliche Lern-App für Vorschulkinder (4-6 Jahre) ohne nervige In-App-Käufe.

## ✨ Features

- **Phantasiegarten**: Magischer Garten der mit Lernerfolg wächst
- **Logik-Spiele**: Fokus auf logisches Denken statt schnöder Rechenaufgaben  
- **KI-generierte Assets**: Individuelle Grafiken und Charaktere
- **Cross-Platform**: iOS & Android Support
- **Ehrlich**: Einmaliger Kaufpreis, keine versteckten Kosten

## 🛠️ Entwicklungsumgebung

### Voraussetzungen
- Flutter 3.24.3+
- Dart 3.5.3+
- Xcode (für iOS)
- Android Studio (für Android)

### Installation
```bash
# Repository klonen
git clone <repository-url>
cd lumengarten_app

# Dependencies installieren
flutter pub get

# App starten
flutter run
```

### GitHub Actions Setup

Für automatische Builds zu App Store Connect:

#### Required Secrets
**iOS:**
- `IOS_CERTIFICATE_BASE64`: Base64-encodiertes iOS Distribution Certificate (.p12)
- `IOS_CERTIFICATE_PASSWORD`: Passwort für das Certificate
- `IOS_PROVISIONING_PROFILE_BASE64`: Base64-encodiertes Provisioning Profile
- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API Key ID
- `APP_STORE_CONNECT_API_ISSUER_ID`: App Store Connect API Issuer ID  
- `APP_STORE_CONNECT_API_KEY_BASE64`: Base64-encodierter API Key (.p8)

**Android:**
- `ANDROID_KEYSTORE_BASE64`: Base64-encodierte Keystore-Datei (.jks)
- `ANDROID_KEY_ALIAS`: Key Alias
- `ANDROID_STORE_PASSWORD`: Keystore Passwort
- `ANDROID_KEY_PASSWORD`: Key Passwort

#### Workflow auslösen
```bash
# Automatisch bei Push zu main
git push origin main

# Manuell über GitHub Actions Tab
# -> "Build and Deploy to App Stores" -> "Run workflow"
```

## 🏗️ Projektstruktur

```
lib/
├── core/
│   ├── constants/     # App-Konstanten
│   ├── router/        # Navigation (go_router)
│   └── theme/         # Design System
├── features/
│   ├── landing/       # Startseite mit Geschichte
│   ├── garden/        # Phantasiegarten
│   ├── games/         # Lernspiele
│   └── progress/      # Fortschritts-Tracking
├── shared/
│   ├── widgets/       # Wiederverwendbare Widgets
│   ├── providers/     # Riverpod State Management
│   └── utils/         # Hilfsfunktionen
└── models/            # Datenmodelle
```

## 🎨 Design Prinzipien

- **Kinderfreundlich**: Große Touch-Targets (min. 60px)
- **Magische Farbpalette**: Pastellfarben, warme Töne
- **Abgerundete Formen**: Sanfte, einladende UI
- **Minimaler Text**: Visuell orientierte Navigation

## 🚀 Deployment

### TestFlight (iOS)
```bash
# Manueller Workflow für TestFlight
# GitHub Actions -> Build and Deploy -> TestFlight
```

### Google Play Console (Android)
```bash
# AAB-Datei wird automatisch als Artifact hochgeladen
# Manueller Upload über Play Console erforderlich
```
