# Android Emulator Fix für Android Studio 2025

## Problem
Android Studio SDK Manager zeigt "dependant package with key emulator not found" und "packages unavailable" Fehler.

## Root Cause Analysis (Recherche vom 24.08.2025)
- **HAXM ist seit 2023 deprecated** - wird nicht mehr unterstützt
- Emulator Package ist nur im **Canary Channel (channel=3)** verfügbar
- Windows Hypervisor Platform (WHPX) ist die moderne Lösung für 2025
- Memory Integrity in Windows Security blockiert Virtualisierung

## Lösungsschritte (Administrator-Rechte erforderlich)

### 1. Windows Hypervisor Platform aktivieren
- Drücke `Win + R`, gib `appwiz.cpl` ein
- Klicke auf "Windows-Features aktivieren oder deaktivieren" 
- Aktiviere diese Checkboxen:
  - ✅ **Windows Hypervisor Platform**
  - ✅ **Virtual Machine Platform**
- Klicke OK und **COMPUTER NEUSTARTEN**

### 2. BIOS Virtualization prüfen
- Beim Neustart ins BIOS/UEFI
- Stelle sicher, dass "Intel VT-x" oder "AMD-V" aktiviert ist
- Falls "Hyper-V" oder "SVM Mode" vorhanden ist, aktiviere es

### 3. Windows Security Memory Integrity deaktivieren
- Gehe zu Windows Security → Device Security → Core Isolation
- Schalte **"Memory Integrity" auf OFF**
- **COMPUTER NEUSTARTEN**

### 4. Android Studio Emulator neu installieren
- Öffne Android Studio 
- Gehe zu Tools → SDK Manager → SDK Tools Tab
- **Deinstalliere** "Android Emulator" falls vorhanden
- **Installiere** "Android Emulator" neu
- Installiere auch "Intel x86 Emulator Accelerator (HAXM installer)" falls sichtbar

### 5. Alternative Kommandozeilen-Installation
Öffne als **Administrator** eine Eingabeaufforderung und führe aus:
```cmd
cd C:\Android\sdk\cmdline-tools\latest\bin
sdkmanager --channel=3 emulator
sdkmanager "system-images;android-31;google_apis;x86_64"
```

### 6. AVD erstellen
Nach erfolgreicher Installation:
- Tools → Device Manager → Create Virtual Device
- Wähle ein Pixel Device
- Wähle Android 31 System Image mit Google APIs
- Finish

## Wichtige Hinweise
- **WHPX ist langsamer als HAXM**, aber die einzige unterstützte Lösung für 2025
- **Hyper-V und WSL2** können parallel laufen
- **Memory Integrity** muss OFF sein für Virtualisierung
- **Neustart** nach Windows Features-Änderungen ist zwingend erforderlich

## Status
- [x] Problem analysiert und Recherche durchgeführt
- [x] Emulator Verzeichnis zurückgesetzt (C:\Android\sdk\emulator entfernt)
- [ ] Windows Hypervisor Platform aktivieren
- [ ] BIOS Virtualization prüfen  
- [ ] Memory Integrity deaktivieren
- [ ] Computer neustarten
- [ ] Android Studio Emulator neu installieren
- [ ] AVD erstellen und testen

## Quellen
- Android Developer Documentation 2025
- Stack Overflow: "Dependent package with key emulator not found"
- Microsoft WHPX Documentation
- Android Studio 2025.1.2 Release Notes