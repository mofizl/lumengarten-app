# iOS TestFlight Build Hang Fix

## Problem
iOS Build hängt seit 1h 38min bei "Running script Run Script" - das ist ein bekannter Flutter 3.27.x Bug.

## Sofortmaßnahmen

### 1. Build abbrechen
- Gehe zu GitHub → Actions → Current running workflow
- Klicke "Cancel workflow" 
- Der Build ist definitiv gehängt (normal: 5-15min, aktuell: >1.5h)

### 2. Flutter Version Fix
Das Problem tritt bei Flutter 3.27.x auf wegen Null-Check-Operator Fehler in xcode_backend.dart.

**Option A: Flutter Version downgrade (empfohlen)**
```yaml
# In .github/workflows/ios.yml
- uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.3'  # Stabile Version verwenden
    channel: 'stable'
```

**Option B: Environment Variable Fix**
```yaml
# In .github/workflows/ios.yml vor dem Build
- name: Set Flutter Environment
  run: |
    export FLUTTER_ROOT=$FLUTTER_HOME
    echo "FLUTTER_ROOT=$FLUTTER_HOME" >> $GITHUB_ENV
```

### 3. CocoaPods Cache leeren
```yaml
# In .github/workflows/ios.yml
- name: Clean CocoaPods Cache
  run: |
    cd lumengarten_app/ios
    pod cache clean --all
    rm -rf Pods
    rm -f Podfile.lock
```

### 4. Build Configuration Fix
```yaml
# In .github/workflows/ios.yml
- name: Flutter Clean and Build
  run: |
    cd lumengarten_app
    flutter clean
    flutter pub get
    cd ios
    pod install --repo-update
```

## Temporary Workaround
Falls das Problem weiterhin auftritt, verwende **Flutter 3.24.3** statt 3.27.x.

## Nächster Build Test
1. Brich aktuellen Build ab
2. Ändere Flutter Version auf 3.24.3
3. Committe und pushe
4. Neuen Build starten

## Status
- [x] Problem identifiziert (Flutter 3.27.x Null-Check Bug)
- [x] Research abgeschlossen
- [ ] Build abbrechen
- [ ] Flutter Version downgrade auf 3.24.3  
- [ ] Neuen Build testen