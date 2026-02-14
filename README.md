# Project Branching & Contribution Guidelines

Welcome to the **dev branch** of this project.  
This branch is for **stable, verified code only**. Please read carefully before contributing.

---

## Most Important: Where to Start Coding (Frontend)

All frontend members only need to edit their own tab file in `lib/frontend/tabs/`.

### Fixed file (do not change)

- `lib/frontend/pages/home_page.dart`

`home_page.dart` already has:

- Bottom navigation bar
- Tab order
- All tab imports
- `_pages` list mapping

### Your tab files

- Home: `lib/frontend/tabs/home_tab.dart`
- AI Chatbot: `lib/frontend/tabs/chatbot_tab.dart`
- Pomodoro: `lib/frontend/tabs/pomodoro_tab.dart`
- Feature: `lib/frontend/tabs/feature_tab.dart`
- Profile: `lib/frontend/tabs/profile_tab.dart`

### workflow

1. Open your assigned tab file only.
2. Replace sample UI/data inside that file.
3. Keep the class name the same (example: `PomodoroTab`, `HomeTab`).
4. Do not rename the file.
5. Do not edit other tab files.
6. Do not edit `home_page.dart`.

That is all. You do not need to open or modify other code files for your tab task.

---

## Notification Service Guide

This project already has a notification setup.

### Files used

- Local notification service: `lib/backend/services/notification_service.dart`
- Firebase messaging service: `lib/backend/services/messaging_service.dart`
- App startup init: `lib/main.dart`
- Messaging init in UI: `lib/frontend/pages/login_page.dart`

### Current flow in this project

1. App starts.
2. `main.dart` runs `await NotificationService().init();`
3. In `login_page.dart`, `MessagingService.instance.initialize()` is called.
4. When FCM message arrives in foreground, app shows local notification.

### How to show a notification manually from your tab/page

1. Add import in your file:

```dart
import 'package:sdgp/backend/services/notification_service.dart';
```

2. Call this method where needed (button click, timer finish, etc.):

```dart
await NotificationService().showNotification(
  title: 'Pomodoro',
  body: 'Your session is complete.',
);
```

### Important notes

- Do not remove `await NotificationService().init();` from `main.dart`.
- Keep messaging initialization call in `login_page.dart`.
- If notifications do not appear, first check app permission settings on the device.

## 🌟 Branch Purpose

- **`dev` branch**
  - Stores **stable and verified code**.
  - **Do NOT edit or push directly here.**
  - This branch is only for **cloning** to get a reliable version of the project.

- **Personal branches**
  - Each developer should create their **own branch** for development.
  - Branch names **must start with your name** (e.g., `arkshayan_b01`).
  - You can create as many branches as needed for your tasks.

---

## 🚀 How to Work Safely

1. **Clone the stable dev branch:**

   ```bash
   git clone -b dev https://github.com/VB701k/VORA.git

   ```

2. **Create your personal branch:**

   ```bash
   git checkout -b yourname_feature

   ```

3. **Do your work on your branch:**
   - Add, commit, and push only to your branch.

   ```bash
   git add .
   git commit -m "Add new feature"
   git push -u origin yourname_feature

   ```

4. **Merging to dev:**
   - Only after branch review, changes will be merged into **`dev`**.

---

## ⚠️ Important Rules

      - Never push directly to dev/main.

      - Follow branch naming rules for personal branches.

      - Use pull requests for main branches ('dev' or 'main').

      - Keep 'dev' stable - it should always be safe to clone.

---

## 📁 Project Structure

```bash



sdgp
├─ .metadata
├─ analysis_options.yaml
├─ android
│  ├─ .gradle
│  │  ├─ 8.14
│  │  │  ├─ checksums
│  │  │  │  ├─ checksums.lock
│  │  │  │  ├─ md5-checksums.bin
│  │  │  │  └─ sha1-checksums.bin
│  │  │  ├─ executionHistory
│  │  │  │  ├─ executionHistory.bin
│  │  │  │  └─ executionHistory.lock
│  │  │  ├─ expanded
│  │  │  ├─ fileChanges
│  │  │  │  └─ last-build.bin
│  │  │  ├─ fileHashes
│  │  │  │  ├─ fileHashes.bin
│  │  │  │  ├─ fileHashes.lock
│  │  │  │  └─ resourceHashesCache.bin
│  │  │  ├─ gc.properties
│  │  │  └─ vcsMetadata
│  │  ├─ 8.9
│  │  │  ├─ checksums
│  │  │  │  └─ checksums.lock
│  │  │  ├─ expanded
│  │  │  ├─ fileChanges
│  │  │  │  └─ last-build.bin
│  │  │  ├─ fileHashes
│  │  │  │  └─ fileHashes.lock
│  │  │  ├─ gc.properties
│  │  │  └─ vcsMetadata
│  │  ├─ buildOutputCleanup
│  │  │  ├─ buildOutputCleanup.lock
│  │  │  ├─ cache.properties
│  │  │  └─ outputFiles.bin
│  │  ├─ file-system.probe
│  │  ├─ noVersion
│  │  │  └─ buildLogic.lock
│  │  └─ vcs-1
│  │     └─ gc.properties
│  ├─ .kotlin
│  │  └─ sessions
│  ├─ app
│  │  ├─ build.gradle.kts
│  │  ├─ google-services.json
│  │  └─ src
│  │     ├─ debug
│  │     │  └─ AndroidManifest.xml
│  │     ├─ main
│  │     │  ├─ AndroidManifest.xml
│  │     │  ├─ java
│  │     │  │  └─ io
│  │     │  │     └─ flutter
│  │     │  │        └─ plugins
│  │     │  │           └─ GeneratedPluginRegistrant.java
│  │     │  ├─ kotlin
│  │     │  │  └─ com
│  │     │  │     └─ example
│  │     │  │        └─ sdgp
│  │     │  │           └─ MainActivity.kt
│  │     │  └─ res
│  │     │     ├─ drawable
│  │     │     │  └─ launch_background.xml
│  │     │     ├─ drawable-v21
│  │     │     │  └─ launch_background.xml
│  │     │     ├─ mipmap-hdpi
│  │     │     │  └─ ic_launcher.png
│  │     │     ├─ mipmap-mdpi
│  │     │     │  └─ ic_launcher.png
│  │     │     ├─ mipmap-xhdpi
│  │     │     │  └─ ic_launcher.png
│  │     │     ├─ mipmap-xxhdpi
│  │     │     │  └─ ic_launcher.png
│  │     │     ├─ mipmap-xxxhdpi
│  │     │     │  └─ ic_launcher.png
│  │     │     ├─ values
│  │     │     │  └─ styles.xml
│  │     │     └─ values-night
│  │     │        └─ styles.xml
│  │     └─ profile
│  │        └─ AndroidManifest.xml
│  ├─ build.gradle.kts
│  ├─ gradle
│  │  └─ wrapper
│  │     ├─ gradle-wrapper.jar
│  │     └─ gradle-wrapper.properties
│  ├─ gradle.properties
│  ├─ gradlew
│  ├─ gradlew.bat
│  ├─ local.properties
│  └─ settings.gradle.kts
├─ assets
│  └─ logo.png
├─ ios
│  ├─ Flutter
│  │  ├─ AppFrameworkInfo.plist
│  │  ├─ Debug.xcconfig
│  │  ├─ ephemeral
│  │  │  ├─ flutter_lldbinit
│  │  │  └─ flutter_lldb_helper.py
│  │  ├─ flutter_export_environment.sh
│  │  ├─ Generated.xcconfig
│  │  └─ Release.xcconfig
│  ├─ Runner
│  │  ├─ AppDelegate.swift
│  │  ├─ Assets.xcassets
│  │  │  ├─ AppIcon.appiconset
│  │  │  │  ├─ Contents.json
│  │  │  │  ├─ Icon-App-1024x1024@1x.png
│  │  │  │  ├─ Icon-App-20x20@1x.png
│  │  │  │  ├─ Icon-App-20x20@2x.png
│  │  │  │  ├─ Icon-App-20x20@3x.png
│  │  │  │  ├─ Icon-App-29x29@1x.png
│  │  │  │  ├─ Icon-App-29x29@2x.png
│  │  │  │  ├─ Icon-App-29x29@3x.png
│  │  │  │  ├─ Icon-App-40x40@1x.png
│  │  │  │  ├─ Icon-App-40x40@2x.png
│  │  │  │  ├─ Icon-App-40x40@3x.png
│  │  │  │  ├─ Icon-App-60x60@2x.png
│  │  │  │  ├─ Icon-App-60x60@3x.png
│  │  │  │  ├─ Icon-App-76x76@1x.png
│  │  │  │  ├─ Icon-App-76x76@2x.png
│  │  │  │  └─ Icon-App-83.5x83.5@2x.png
│  │  │  └─ LaunchImage.imageset
│  │  │     ├─ Contents.json
│  │  │     ├─ LaunchImage.png
│  │  │     ├─ LaunchImage@2x.png
│  │  │     ├─ LaunchImage@3x.png
│  │  │     └─ README.md
│  │  ├─ Base.lproj
│  │  │  ├─ LaunchScreen.storyboard
│  │  │  └─ Main.storyboard
│  │  ├─ GeneratedPluginRegistrant.h
│  │  ├─ GeneratedPluginRegistrant.m
│  │  ├─ Info.plist
│  │  └─ Runner-Bridging-Header.h
│  ├─ Runner.xcodeproj
│  │  ├─ project.pbxproj
│  │  ├─ project.xcworkspace
│  │  │  ├─ contents.xcworkspacedata
│  │  │  └─ xcshareddata
│  │  │     ├─ IDEWorkspaceChecks.plist
│  │  │     └─ WorkspaceSettings.xcsettings
│  │  └─ xcshareddata
│  │     └─ xcschemes
│  │        └─ Runner.xcscheme
│  ├─ Runner.xcworkspace
│  │  ├─ contents.xcworkspacedata
│  │  └─ xcshareddata
│  │     ├─ IDEWorkspaceChecks.plist
│  │     └─ WorkspaceSettings.xcsettings
│  └─ RunnerTests
│     └─ RunnerTests.swift
├─ lib
│  ├─ backend
│  │  └─ services
│  │     ├─ auth_service.dart
│  │     ├─ messaging_service.dart
│  │     └─ notification_service.dart
│  ├─ frontend
│  │  ├─ pages
│  │  │  ├─ forgot_password_page.dart
│  │  │  ├─ home_page.dart
│  │  │  ├─ login_page.dart
│  │  │  └─ signup_page.dart
│  │  └─ tabs
│  │     ├─ chatbot_tab.dart
│  │     ├─ feature_tab.dart
│  │     ├─ home_tab.dart
│  │     ├─ pomodoro_tab.dart
│  │     └─ profile_tab.dart
│  └─ main.dart
├─ linux
│  ├─ CMakeLists.txt
│  ├─ flutter
│  │  ├─ CMakeLists.txt
│  │  ├─ generated_plugins.cmake
│  │  ├─ generated_plugin_registrant.cc
│  │  └─ generated_plugin_registrant.h
│  └─ runner
│     ├─ CMakeLists.txt
│     ├─ main.cc
│     ├─ my_application.cc
│     └─ my_application.h
├─ macos
│  ├─ Flutter
│  │  ├─ ephemeral
│  │  │  ├─ Flutter-Generated.xcconfig
│  │  │  └─ flutter_export_environment.sh
│  │  ├─ Flutter-Debug.xcconfig
│  │  ├─ Flutter-Release.xcconfig
│  │  └─ GeneratedPluginRegistrant.swift
│  ├─ Runner
│  │  ├─ AppDelegate.swift
│  │  ├─ Assets.xcassets
│  │  │  └─ AppIcon.appiconset
│  │  │     ├─ app_icon_1024.png
│  │  │     ├─ app_icon_128.png
│  │  │     ├─ app_icon_16.png
│  │  │     ├─ app_icon_256.png
│  │  │     ├─ app_icon_32.png
│  │  │     ├─ app_icon_512.png
│  │  │     ├─ app_icon_64.png
│  │  │     └─ Contents.json
│  │  ├─ Base.lproj
│  │  │  └─ MainMenu.xib
│  │  ├─ Configs
│  │  │  ├─ AppInfo.xcconfig
│  │  │  ├─ Debug.xcconfig
│  │  │  ├─ Release.xcconfig
│  │  │  └─ Warnings.xcconfig
│  │  ├─ DebugProfile.entitlements
│  │  ├─ Info.plist
│  │  ├─ MainFlutterWindow.swift
│  │  └─ Release.entitlements
│  ├─ Runner.xcodeproj
│  │  ├─ project.pbxproj
│  │  ├─ project.xcworkspace
│  │  │  └─ xcshareddata
│  │  │     └─ IDEWorkspaceChecks.plist
│  │  └─ xcshareddata
│  │     └─ xcschemes
│  │        └─ Runner.xcscheme
│  ├─ Runner.xcworkspace
│  │  ├─ contents.xcworkspacedata
│  │  └─ xcshareddata
│  │     └─ IDEWorkspaceChecks.plist
│  └─ RunnerTests
│     └─ RunnerTests.swift
├─ pubspec.lock
├─ pubspec.yaml
├─ README.md
├─ test
│  └─ widget_test.dart
├─ web
│  ├─ favicon.png
│  ├─ icons
│  │  ├─ Icon-192.png
│  │  ├─ Icon-512.png
│  │  ├─ Icon-maskable-192.png
│  │  └─ Icon-maskable-512.png
│  ├─ index.html
│  └─ manifest.json
└─ windows
   ├─ CMakeLists.txt
   ├─ flutter
   │  ├─ CMakeLists.txt
   │  ├─ ephemeral
   │  │  └─ .plugin_symlinks
   │  │     ├─ cloud_firestore
   │  │     ├─ firebase_auth
   │  │     └─ firebase_core
   │  ├─ generated_plugins.cmake
   │  ├─ generated_plugin_registrant.cc
   │  └─ generated_plugin_registrant.h
   └─ runner
      ├─ CMakeLists.txt
      ├─ flutter_window.cpp
      ├─ flutter_window.h
      ├─ main.cpp
      ├─ resource.h
      ├─ resources
      │  └─ app_icon.ico
      ├─ runner.exe.manifest
      ├─ Runner.rc
      ├─ utils.cpp
      ├─ utils.h
      ├─ win32_window.cpp
      └─ win32_window.h

```
