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

## 🚀 VORA Flutter Project Setup Guide

Follow the steps below to clone and run this project locally.

### 📥 1️⃣ Clone the Repository

Open your terminal and run:

```bash
git clone https://github.com/VB701k/VORA.git
```

### 📂 2️⃣ Open the Project

Navigate into the project folder:

```bash
cd VORA
```

Then open the folder using your preferred code editor (VS Code recommended).

Example (for VS Code):

```bash
code .
```

### 📦 3️⃣ Install Dependencies

Run the following command to install all required Flutter packages:

```bash
flutter pub get
```

### ▶️ 4️⃣ Run the Application

Make sure a device or emulator is connected, then run:

```bash
flutter run
```

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
import 'package:vora/backend/services/notification_service.dart';
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

---

## Firestore User Access System

This project uses Firebase Authentication + Cloud Firestore with secure rules that restrict users to accessing only their own document.

### Firestore Security Rules

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {

      // Allow user to read their own document
      allow read: if request.auth != null
                  && request.auth.uid == userId;

      // Allow user to create their own document
      allow create: if request.auth != null
                    && request.auth.uid == userId;

      // Allow user to update their own document
      allow update: if request.auth != null
                    && request.auth.uid == userId;

      // Prevent deleting
      allow delete: if false;
    }
  }
}
```

### System Behavior

| Operation            | Allowed? | Condition         |
| -------------------- | -------- | ----------------- |
| View own data        | Yes      | Must be logged in |
| View other user data | No       | Blocked           |
| Create own document  | Yes      | UID must match    |
| Update own document  | Yes      | UID must match    |
| Delete document      | No       | Not allowed       |

### Implementation Guide (Flutter)

#### 1. Get Current Logged-in User

Always required before Firestore operations.

```dart
final user = FirebaseAuth.instance.currentUser;

if (user == null) {
  print("No logged in user");
  return;
}
```

#### 2. Create User Document (After Signup)

Creates Firestore document using the user's UID.

```dart
Future<void> createUserDocument() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({
        'name': 'John Doe',
        'email': user.email,
        'age': 22,
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

  print("User document created");
}
```

Works because `doc(user.uid)` matches the security rule.

#### 3. Read User Data (One-Time Read)

```dart
Future<void> readUserData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (doc.exists) {
    print(doc.data());
  } else {
    print("User document not found");
  }
}
```

#### 4. Read User Data (Real-Time Stream)

Recommended for profile screens.

```dart
StreamBuilder<DocumentSnapshot>(
  stream: FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }

    final data = snapshot.data!.data() as Map<String, dynamic>;

    return Column(
      children: [
        Text("Name: ${data['name']}"),
        Text("Email: ${data['email']}"),
      ],
    );
  },
);
```

#### 5. Update Single Field

```dart
Future<void> updateUserName(String newName) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .update({
        'name': newName,
      });

  print("User updated");
}
```

#### 6. Update Multiple Fields

```dart
Future<void> updateProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .update({
        'name': 'New Name',
        'age': 25,
        'isAdmin': true,
      });
}
```

### What Will Not Work

Reading entire collection:

```dart
FirebaseFirestore.instance.collection('users').get();
```

Blocked by security rule.

Reading other user document:

```dart
FirebaseFirestore.instance
    .collection('users')
    .doc("otherUID")
    .get();
```

Blocked because UID does not match.

Deleting user document:

```dart
FirebaseFirestore.instance
    .collection('users')
    .doc(user.uid)
    .delete();
```

Blocked because:

```txt
allow delete: if false;
```

### Important Rule to Remember

All Firestore operations must use:

```dart
doc(currentUser.uid)
```

If UID does not match, Firestore will throw:

```txt
PERMISSION_DENIED
```

---

---

## 📁 Project Structure

```bash

sdgp - Copy
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
├─ firestore
│  └─ rule.txt
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
   │  │     │  ├─ android
   │  │     │  │  ├─ .gradle
   │  │     │  │  │  ├─ 8.9
   │  │     │  │  │  │  ├─ checksums
   │  │     │  │  │  │  │  └─ checksums.lock
   │  │     │  │  │  │  ├─ fileChanges
   │  │     │  │  │  │  │  └─ last-build.bin
   │  │     │  │  │  │  ├─ fileHashes
   │  │     │  │  │  │  │  └─ fileHashes.lock
   │  │     │  │  │  │  ├─ gc.properties
   │  │     │  │  │  │  └─ vcsMetadata
   │  │     │  │  │  ├─ buildOutputCleanup
   │  │     │  │  │  │  ├─ buildOutputCleanup.lock
   │  │     │  │  │  │  └─ cache.properties
   │  │     │  │  │  └─ vcs-1
   │  │     │  │  │     └─ gc.properties
   │  │     │  │  ├─ build.gradle
   │  │     │  │  ├─ local-config.gradle
   │  │     │  │  ├─ settings.gradle
   │  │     │  │  ├─ src
   │  │     │  │  │  └─ main
   │  │     │  │  │     ├─ AndroidManifest.xml
   │  │     │  │  │     └─ java
   │  │     │  │  │        └─ io
   │  │     │  │  │           └─ flutter
   │  │     │  │  │              └─ plugins
   │  │     │  │  │                 └─ firebase
   │  │     │  │  │                    └─ firestore
   │  │     │  │  │                       ├─ FlutterFirebaseFirestoreException.java
   │  │     │  │  │                       ├─ FlutterFirebaseFirestoreExtension.java
   │  │     │  │  │                       ├─ FlutterFirebaseFirestoreMessageCodec.java
   │  │     │  │  │                       ├─ FlutterFirebaseFirestorePlugin.java
   │  │     │  │  │                       ├─ FlutterFirebaseFirestoreRegistrar.java
   │  │     │  │  │                       ├─ FlutterFirebaseFirestoreTransactionResult.java
   │  │     │  │  │                       ├─ GeneratedAndroidFirebaseFirestore.java
   │  │     │  │  │                       ├─ streamhandler
   │  │     │  │  │                       │  ├─ DocumentSnapshotsStreamHandler.java
   │  │     │  │  │                       │  ├─ LoadBundleStreamHandler.java
   │  │     │  │  │                       │  ├─ OnTransactionResultListener.java
   │  │     │  │  │                       │  ├─ QuerySnapshotsStreamHandler.java
   │  │     │  │  │                       │  ├─ SnapshotsInSyncStreamHandler.java
   │  │     │  │  │                       │  └─ TransactionStreamHandler.java
   │  │     │  │  │                       └─ utils
   │  │     │  │  │                          ├─ ExceptionConverter.java
   │  │     │  │  │                          ├─ PigeonParser.java
   │  │     │  │  │                          └─ ServerTimestampBehaviorConverter.java
   │  │     │  │  └─ user-agent.gradle
   │  │     │  ├─ CHANGELOG.md
   │  │     │  ├─ dartpad
   │  │     │  │  ├─ dartpad_metadata.yaml
   │  │     │  │  └─ lib
   │  │     │  │     └─ main.dart
   │  │     │  ├─ example
   │  │     │  │  ├─ analysis_options.yaml
   │  │     │  │  ├─ android
   │  │     │  │  │  ├─ app
   │  │     │  │  │  │  ├─ build.gradle
   │  │     │  │  │  │  ├─ google-services.json
   │  │     │  │  │  │  └─ src
   │  │     │  │  │  │     ├─ debug
   │  │     │  │  │  │     │  └─ AndroidManifest.xml
   │  │     │  │  │  │     ├─ main
   │  │     │  │  │  │     │  ├─ AndroidManifest.xml
   │  │     │  │  │  │     │  ├─ java
   │  │     │  │  │  │     │  │  └─ io
   │  │     │  │  │  │     │  │     └─ flutter
   │  │     │  │  │  │     │  │        └─ plugins
   │  │     │  │  │  │     │  ├─ kotlin
   │  │     │  │  │  │     │  │  └─ io
   │  │     │  │  │  │     │  │     └─ flutter
   │  │     │  │  │  │     │  │        └─ plugins
   │  │     │  │  │  │     │  │           └─ firebase
   │  │     │  │  │  │     │  │              └─ firestore
   │  │     │  │  │  │     │  │                 └─ example
   │  │     │  │  │  │     │  │                    └─ MainActivity.kt
   │  │     │  │  │  │     │  └─ res
   │  │     │  │  │  │     │     ├─ drawable
   │  │     │  │  │  │     │     │  └─ launch_background.xml
   │  │     │  │  │  │     │     ├─ drawable-v21
   │  │     │  │  │  │     │     │  └─ launch_background.xml
   │  │     │  │  │  │     │     ├─ mipmap-hdpi
   │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │  │     │  │  │  │     │     ├─ mipmap-mdpi
   │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │  │     │  │  │  │     │     ├─ mipmap-xhdpi
   │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │  │     │  │  │  │     │     ├─ mipmap-xxhdpi
   │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │  │     │  │  │  │     │     ├─ mipmap-xxxhdpi
   │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │  │     │  │  │  │     │     ├─ values
   │  │     │  │  │  │     │     │  └─ styles.xml
   │  │     │  │  │  │     │     └─ values-night
   │  │     │  │  │  │     │        └─ styles.xml
   │  │     │  │  │  │     └─ profile
   │  │     │  │  │  │        └─ AndroidManifest.xml
   │  │     │  │  │  ├─ build.gradle
   │  │     │  │  │  ├─ gradle
   │  │     │  │  │  │  └─ wrapper
   │  │     │  │  │  │     └─ gradle-wrapper.properties
   │  │     │  │  │  ├─ gradle.properties
   │  │     │  │  │  └─ settings.gradle
   │  │     │  │  ├─ firebase.json
   │  │     │  │  ├─ integration_test
   │  │     │  │  │  ├─ collection_reference_e2e.dart
   │  │     │  │  │  ├─ document_change_e2e.dart
   │  │     │  │  │  ├─ document_reference_e2e.dart
   │  │     │  │  │  ├─ e2e_test.dart
   │  │     │  │  │  ├─ field_value_e2e.dart
   │  │     │  │  │  ├─ firebase_options.dart
   │  │     │  │  │  ├─ firebase_options_secondary.dart
   │  │     │  │  │  ├─ geo_point_e2e.dart
   │  │     │  │  │  ├─ instance_e2e.dart
   │  │     │  │  │  ├─ load_bundle_e2e.dart
   │  │     │  │  │  ├─ query_e2e.dart
   │  │     │  │  │  ├─ second_database.dart
   │  │     │  │  │  ├─ settings_e2e.dart
   │  │     │  │  │  ├─ snapshot_metadata_e2e.dart
   │  │     │  │  │  ├─ timestamp_e2e.dart
   │  │     │  │  │  ├─ transaction_e2e.dart
   │  │     │  │  │  ├─ vector_value_e2e.dart
   │  │     │  │  │  ├─ web_snapshot_listeners.dart
   │  │     │  │  │  └─ write_batch_e2e.dart
   │  │     │  │  ├─ ios
   │  │     │  │  │  ├─ firebase_app_id_file.json
   │  │     │  │  │  ├─ Flutter
   │  │     │  │  │  │  ├─ AppFrameworkInfo.plist
   │  │     │  │  │  │  ├─ Debug.xcconfig
   │  │     │  │  │  │  └─ Release.xcconfig
   │  │     │  │  │  ├─ Podfile
   │  │     │  │  │  ├─ Runner
   │  │     │  │  │  │  ├─ AppDelegate.swift
   │  │     │  │  │  │  ├─ Assets.xcassets
   │  │     │  │  │  │  │  ├─ AppIcon.appiconset
   │  │     │  │  │  │  │  │  ├─ Contents.json
   │  │     │  │  │  │  │  │  ├─ Icon-App-1024x1024@1x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@1x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@2x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@3x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@1x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@2x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@3x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@1x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@2x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@3x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-60x60@2x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-60x60@3x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-76x76@1x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-76x76@2x.png
   │  │     │  │  │  │  │  │  └─ Icon-App-83.5x83.5@2x.png
   │  │     │  │  │  │  │  └─ LaunchImage.imageset
   │  │     │  │  │  │  │     ├─ Contents.json
   │  │     │  │  │  │  │     ├─ LaunchImage.png
   │  │     │  │  │  │  │     ├─ LaunchImage@2x.png
   │  │     │  │  │  │  │     ├─ LaunchImage@3x.png
   │  │     │  │  │  │  │     └─ README.md
   │  │     │  │  │  │  ├─ Base.lproj
   │  │     │  │  │  │  │  ├─ LaunchScreen.storyboard
   │  │     │  │  │  │  │  └─ Main.storyboard
   │  │     │  │  │  │  ├─ GoogleService-Info.plist
   │  │     │  │  │  │  ├─ Info.plist
   │  │     │  │  │  │  └─ Runner-Bridging-Header.h
   │  │     │  │  │  ├─ Runner.xcodeproj
   │  │     │  │  │  │  ├─ project.pbxproj
   │  │     │  │  │  │  ├─ project.xcworkspace
   │  │     │  │  │  │  │  ├─ contents.xcworkspacedata
   │  │     │  │  │  │  │  └─ xcshareddata
   │  │     │  │  │  │  │     ├─ IDEWorkspaceChecks.plist
   │  │     │  │  │  │  │     ├─ swiftpm
   │  │     │  │  │  │  │     │  └─ configuration
   │  │     │  │  │  │  │     └─ WorkspaceSettings.xcsettings
   │  │     │  │  │  │  └─ xcshareddata
   │  │     │  │  │  │     └─ xcschemes
   │  │     │  │  │  │        └─ Runner.xcscheme
   │  │     │  │  │  └─ Runner.xcworkspace
   │  │     │  │  │     ├─ contents.xcworkspacedata
   │  │     │  │  │     └─ xcshareddata
   │  │     │  │  │        ├─ IDEWorkspaceChecks.plist
   │  │     │  │  │        ├─ swiftpm
   │  │     │  │  │        │  └─ configuration
   │  │     │  │  │        └─ WorkspaceSettings.xcsettings
   │  │     │  │  ├─ lib
   │  │     │  │  │  ├─ firebase_options.dart
   │  │     │  │  │  └─ main.dart
   │  │     │  │  ├─ macos
   │  │     │  │  │  ├─ firebase_app_id_file.json
   │  │     │  │  │  ├─ Flutter
   │  │     │  │  │  │  ├─ Flutter-Debug.xcconfig
   │  │     │  │  │  │  └─ Flutter-Release.xcconfig
   │  │     │  │  │  ├─ Podfile
   │  │     │  │  │  ├─ Runner
   │  │     │  │  │  │  ├─ AppDelegate.swift
   │  │     │  │  │  │  ├─ Assets.xcassets
   │  │     │  │  │  │  │  └─ AppIcon.appiconset
   │  │     │  │  │  │  │     ├─ app_icon_1024.png
   │  │     │  │  │  │  │     ├─ app_icon_128.png
   │  │     │  │  │  │  │     ├─ app_icon_16.png
   │  │     │  │  │  │  │     ├─ app_icon_256.png
   │  │     │  │  │  │  │     ├─ app_icon_32.png
   │  │     │  │  │  │  │     ├─ app_icon_512.png
   │  │     │  │  │  │  │     ├─ app_icon_64.png
   │  │     │  │  │  │  │     └─ Contents.json
   │  │     │  │  │  │  ├─ Base.lproj
   │  │     │  │  │  │  │  └─ MainMenu.xib
   │  │     │  │  │  │  ├─ Configs
   │  │     │  │  │  │  │  ├─ AppInfo.xcconfig
   │  │     │  │  │  │  │  ├─ Debug.xcconfig
   │  │     │  │  │  │  │  ├─ Release.xcconfig
   │  │     │  │  │  │  │  └─ Warnings.xcconfig
   │  │     │  │  │  │  ├─ DebugProfile.entitlements
   │  │     │  │  │  │  ├─ GoogleService-Info.plist
   │  │     │  │  │  │  ├─ Info.plist
   │  │     │  │  │  │  ├─ MainFlutterWindow.swift
   │  │     │  │  │  │  └─ Release.entitlements
   │  │     │  │  │  ├─ Runner.xcodeproj
   │  │     │  │  │  │  ├─ project.pbxproj
   │  │     │  │  │  │  ├─ project.xcworkspace
   │  │     │  │  │  │  │  └─ xcshareddata
   │  │     │  │  │  │  │     ├─ IDEWorkspaceChecks.plist
   │  │     │  │  │  │  │     └─ swiftpm
   │  │     │  │  │  │  │        └─ configuration
   │  │     │  │  │  │  └─ xcshareddata
   │  │     │  │  │  │     └─ xcschemes
   │  │     │  │  │  │        └─ Runner.xcscheme
   │  │     │  │  │  ├─ Runner.xcworkspace
   │  │     │  │  │  │  ├─ contents.xcworkspacedata
   │  │     │  │  │  │  └─ xcshareddata
   │  │     │  │  │  │     ├─ IDEWorkspaceChecks.plist
   │  │     │  │  │  │     └─ swiftpm
   │  │     │  │  │  │        └─ configuration
   │  │     │  │  │  └─ RunnerTests
   │  │     │  │  │     └─ RunnerTests.swift
   │  │     │  │  ├─ pubspec.yaml
   │  │     │  │  ├─ README.md
   │  │     │  │  ├─ test_driver
   │  │     │  │  │  └─ integration_test.dart
   │  │     │  │  ├─ web
   │  │     │  │  │  ├─ favicon.png
   │  │     │  │  │  ├─ icons
   │  │     │  │  │  │  ├─ Icon-192.png
   │  │     │  │  │  │  ├─ Icon-512.png
   │  │     │  │  │  │  ├─ Icon-maskable-192.png
   │  │     │  │  │  │  └─ Icon-maskable-512.png
   │  │     │  │  │  ├─ index.html
   │  │     │  │  │  ├─ manifest.json
   │  │     │  │  │  └─ wasm_index.html
   │  │     │  │  └─ windows
   │  │     │  │     ├─ CMakeLists.txt
   │  │     │  │     ├─ flutter
   │  │     │  │     │  └─ CMakeLists.txt
   │  │     │  │     └─ runner
   │  │     │  │        ├─ CMakeLists.txt
   │  │     │  │        ├─ flutter_window.cpp
   │  │     │  │        ├─ flutter_window.h
   │  │     │  │        ├─ main.cpp
   │  │     │  │        ├─ resource.h
   │  │     │  │        ├─ resources
   │  │     │  │        │  └─ app_icon.ico
   │  │     │  │        ├─ runner.exe.manifest
   │  │     │  │        ├─ Runner.rc
   │  │     │  │        ├─ utils.cpp
   │  │     │  │        ├─ utils.h
   │  │     │  │        ├─ win32_window.cpp
   │  │     │  │        └─ win32_window.h
   │  │     │  ├─ ios
   │  │     │  │  ├─ cloud_firestore
   │  │     │  │  │  ├─ Package.swift
   │  │     │  │  │  └─ Sources
   │  │     │  │  │     └─ cloud_firestore
   │  │     │  │  │        ├─ FirestoreMessages.g.m
   │  │     │  │  │        ├─ FirestorePigeonParser.m
   │  │     │  │  │        ├─ FLTDocumentSnapshotStreamHandler.m
   │  │     │  │  │        ├─ FLTFirebaseFirestoreExtension.m
   │  │     │  │  │        ├─ FLTFirebaseFirestorePlugin.m
   │  │     │  │  │        ├─ FLTFirebaseFirestoreReader.m
   │  │     │  │  │        ├─ FLTFirebaseFirestoreUtils.m
   │  │     │  │  │        ├─ FLTFirebaseFirestoreWriter.m
   │  │     │  │  │        ├─ FLTFirestoreClientLanguage.mm
   │  │     │  │  │        ├─ FLTLoadBundleStreamHandler.m
   │  │     │  │  │        ├─ FLTQuerySnapshotStreamHandler.m
   │  │     │  │  │        ├─ FLTSnapshotsInSyncStreamHandler.m
   │  │     │  │  │        ├─ FLTTransactionStreamHandler.m
   │  │     │  │  │        ├─ include
   │  │     │  │  │        │  └─ cloud_firestore
   │  │     │  │  │        │     ├─ Private
   │  │     │  │  │        │     │  ├─ FirestorePigeonParser.h
   │  │     │  │  │        │     │  ├─ FLTDocumentSnapshotStreamHandler.h
   │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreExtension.h
   │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreReader.h
   │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreUtils.h
   │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreWriter.h
   │  │     │  │  │        │     │  ├─ FLTLoadBundleStreamHandler.h
   │  │     │  │  │        │     │  ├─ FLTQuerySnapshotStreamHandler.h
   │  │     │  │  │        │     │  ├─ FLTSnapshotsInSyncStreamHandler.h
   │  │     │  │  │        │     │  └─ FLTTransactionStreamHandler.h
   │  │     │  │  │        │     └─ Public
   │  │     │  │  │        │        ├─ CustomPigeonHeaderFirestore.h
   │  │     │  │  │        │        ├─ FirestoreMessages.g.h
   │  │     │  │  │        │        └─ FLTFirebaseFirestorePlugin.h
   │  │     │  │  │        └─ Resources
   │  │     │  │  ├─ cloud_firestore.podspec
   │  │     │  │  └─ generated_firebase_sdk_version.txt
   │  │     │  ├─ lib
   │  │     │  │  ├─ cloud_firestore.dart
   │  │     │  │  └─ src
   │  │     │  │     ├─ aggregate_query.dart
   │  │     │  │     ├─ aggregate_query_snapshot.dart
   │  │     │  │     ├─ collection_reference.dart
   │  │     │  │     ├─ document_change.dart
   │  │     │  │     ├─ document_reference.dart
   │  │     │  │     ├─ document_snapshot.dart
   │  │     │  │     ├─ field_value.dart
   │  │     │  │     ├─ filters.dart
   │  │     │  │     ├─ firestore.dart
   │  │     │  │     ├─ load_bundle_task.dart
   │  │     │  │     ├─ load_bundle_task_snapshot.dart
   │  │     │  │     ├─ persistent_cache_index_manager.dart
   │  │     │  │     ├─ query.dart
   │  │     │  │     ├─ query_document_snapshot.dart
   │  │     │  │     ├─ query_snapshot.dart
   │  │     │  │     ├─ snapshot_metadata.dart
   │  │     │  │     ├─ transaction.dart
   │  │     │  │     ├─ utils
   │  │     │  │     │  └─ codec_utility.dart
   │  │     │  │     └─ write_batch.dart
   │  │     │  ├─ LICENSE
   │  │     │  ├─ macos
   │  │     │  │  ├─ cloud_firestore
   │  │     │  │  │  ├─ Package.swift
   │  │     │  │  │  └─ Sources
   │  │     │  │  │     └─ cloud_firestore
   │  │     │  │  │        ├─ FirestoreMessages.g.m
   │  │     │  │  │        ├─ FirestorePigeonParser.m
   │  │     │  │  │        ├─ FLTDocumentSnapshotStreamHandler.m
   │  │     │  │  │        ├─ FLTFirebaseFirestoreExtension.m
   │  │     │  │  │        ├─ FLTFirebaseFirestorePlugin.m
   │  │     │  │  │        ├─ FLTFirebaseFirestoreReader.m
   │  │     │  │  │        ├─ FLTFirebaseFirestoreUtils.m
   │  │     │  │  │        ├─ FLTFirebaseFirestoreWriter.m
   │  │     │  │  │        ├─ FLTLoadBundleStreamHandler.m
   │  │     │  │  │        ├─ FLTQuerySnapshotStreamHandler.m
   │  │     │  │  │        ├─ FLTSnapshotsInSyncStreamHandler.m
   │  │     │  │  │        ├─ FLTTransactionStreamHandler.m
   │  │     │  │  │        ├─ include
   │  │     │  │  │        │  └─ cloud_firestore
   │  │     │  │  │        │     ├─ Private
   │  │     │  │  │        │     │  ├─ FirestorePigeonParser.h
   │  │     │  │  │        │     │  ├─ FLTDocumentSnapshotStreamHandler.h
   │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreExtension.h
   │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreReader.h
   │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreUtils.h
   │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreWriter.h
   │  │     │  │  │        │     │  ├─ FLTLoadBundleStreamHandler.h
   │  │     │  │  │        │     │  ├─ FLTQuerySnapshotStreamHandler.h
   │  │     │  │  │        │     │  ├─ FLTSnapshotsInSyncStreamHandler.h
   │  │     │  │  │        │     │  └─ FLTTransactionStreamHandler.h
   │  │     │  │  │        │     └─ Public
   │  │     │  │  │        │        ├─ CustomPigeonHeaderFirestore.h
   │  │     │  │  │        │        ├─ FirestoreMessages.g.h
   │  │     │  │  │        │        └─ FLTFirebaseFirestorePlugin.h
   │  │     │  │  │        └─ Resources
   │  │     │  │  └─ cloud_firestore.podspec
   │  │     │  ├─ pubspec.yaml
   │  │     │  ├─ README.md
   │  │     │  ├─ test
   │  │     │  │  ├─ cloud_firestore_test.dart
   │  │     │  │  ├─ collection_reference_test.dart
   │  │     │  │  ├─ field_value_test.dart
   │  │     │  │  ├─ mock.dart
   │  │     │  │  ├─ query_test.dart
   │  │     │  │  └─ test_firestore_message_codec.dart
   │  │     │  └─ windows
   │  │     │     ├─ cloud_firestore_plugin.cpp
   │  │     │     ├─ cloud_firestore_plugin.h
   │  │     │     ├─ cloud_firestore_plugin_c_api.cpp
   │  │     │     ├─ CMakeLists.txt
   │  │     │     ├─ firestore_codec.cpp
   │  │     │     ├─ firestore_codec.h
   │  │     │     ├─ include
   │  │     │     │  └─ cloud_firestore
   │  │     │     │     └─ cloud_firestore_plugin_c_api.h
   │  │     │     ├─ messages.g.cpp
   │  │     │     ├─ messages.g.h
   │  │     │     ├─ plugin_version.h.in
   │  │     │     └─ test
   │  │     │        └─ cloud_firestore_plugin_test.cpp
   │  │     ├─ firebase_auth
   │  │     │  ├─ android
   │  │     │  │  ├─ .gradle
   │  │     │  │  │  ├─ 8.4
   │  │     │  │  │  │  ├─ checksums
   │  │     │  │  │  │  │  └─ checksums.lock
   │  │     │  │  │  │  ├─ fileChanges
   │  │     │  │  │  │  │  └─ last-build.bin
   │  │     │  │  │  │  ├─ fileHashes
   │  │     │  │  │  │  │  └─ fileHashes.lock
   │  │     │  │  │  │  ├─ gc.properties
   │  │     │  │  │  │  └─ vcsMetadata
   │  │     │  │  │  └─ vcs-1
   │  │     │  │  │     └─ gc.properties
   │  │     │  │  ├─ build.gradle
   │  │     │  │  ├─ gradle
   │  │     │  │  │  └─ wrapper
   │  │     │  │  │     └─ gradle-wrapper.properties
   │  │     │  │  ├─ gradle.properties
   │  │     │  │  ├─ settings.gradle
   │  │     │  │  ├─ src
   │  │     │  │  │  └─ main
   │  │     │  │  │     ├─ AndroidManifest.xml
   │  │     │  │  │     └─ java
   │  │     │  │  │        └─ io
   │  │     │  │  │           └─ flutter
   │  │     │  │  │              └─ plugins
   │  │     │  │  │                 └─ firebase
   │  │     │  │  │                    └─ auth
   │  │     │  │  │                       ├─ AuthStateChannelStreamHandler.java
   │  │     │  │  │                       ├─ Constants.java
   │  │     │  │  │                       ├─ FlutterFirebaseAuthPlugin.java
   │  │     │  │  │                       ├─ FlutterFirebaseAuthPluginException.java
   │  │     │  │  │                       ├─ FlutterFirebaseAuthRegistrar.java
   │  │     │  │  │                       ├─ FlutterFirebaseAuthUser.java
   │  │     │  │  │                       ├─ FlutterFirebaseMultiFactor.java
   │  │     │  │  │                       ├─ FlutterFirebaseTotpMultiFactor.java
   │  │     │  │  │                       ├─ FlutterFirebaseTotpSecret.java
   │  │     │  │  │                       ├─ GeneratedAndroidFirebaseAuth.java
   │  │     │  │  │                       ├─ IdTokenChannelStreamHandler.java
   │  │     │  │  │                       ├─ PhoneNumberVerificationStreamHandler.java
   │  │     │  │  │                       └─ PigeonParser.java
   │  │     │  │  └─ user-agent.gradle
   │  │     │  ├─ CHANGELOG.md
   │  │     │  ├─ example
   │  │     │  │  ├─ analysis_options.yaml
   │  │     │  │  ├─ android
   │  │     │  │  │  ├─ app
   │  │     │  │  │  │  ├─ build.gradle
   │  │     │  │  │  │  ├─ google-services.json
   │  │     │  │  │  │  └─ src
   │  │     │  │  │  │     ├─ debug
   │  │     │  │  │  │     │  └─ AndroidManifest.xml
   │  │     │  │  │  │     ├─ main
   │  │     │  │  │  │     │  ├─ AndroidManifest.xml
   │  │     │  │  │  │     │  ├─ java
   │  │     │  │  │  │     │  │  └─ io
   │  │     │  │  │  │     │  │     └─ flutter
   │  │     │  │  │  │     │  │        └─ plugins
   │  │     │  │  │  │     │  ├─ kotlin
   │  │     │  │  │  │     │  │  └─ io
   │  │     │  │  │  │     │  │     └─ flutter
   │  │     │  │  │  │     │  │        └─ plugins
   │  │     │  │  │  │     │  │           └─ firebase
   │  │     │  │  │  │     │  │              └─ auth
   │  │     │  │  │  │     │  │                 └─ example
   │  │     │  │  │  │     │  │                    └─ MainActivity.kt
   │  │     │  │  │  │     │  └─ res
   │  │     │  │  │  │     │     ├─ drawable
   │  │     │  │  │  │     │     │  └─ launch_background.xml
   │  │     │  │  │  │     │     ├─ drawable-v21
   │  │     │  │  │  │     │     │  └─ launch_background.xml
   │  │     │  │  │  │     │     ├─ mipmap-hdpi
   │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │  │     │  │  │  │     │     ├─ mipmap-mdpi
   │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │  │     │  │  │  │     │     ├─ mipmap-xhdpi
   │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │  │     │  │  │  │     │     ├─ mipmap-xxhdpi
   │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │  │     │  │  │  │     │     ├─ mipmap-xxxhdpi
   │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │  │     │  │  │  │     │     ├─ values
   │  │     │  │  │  │     │     │  └─ styles.xml
   │  │     │  │  │  │     │     └─ values-night
   │  │     │  │  │  │     │        └─ styles.xml
   │  │     │  │  │  │     └─ profile
   │  │     │  │  │  │        └─ AndroidManifest.xml
   │  │     │  │  │  ├─ build.gradle
   │  │     │  │  │  ├─ gradle
   │  │     │  │  │  │  └─ wrapper
   │  │     │  │  │  │     └─ gradle-wrapper.properties
   │  │     │  │  │  ├─ gradle.properties
   │  │     │  │  │  └─ settings.gradle
   │  │     │  │  ├─ ios
   │  │     │  │  │  ├─ firebase_app_id_file.json
   │  │     │  │  │  ├─ Flutter
   │  │     │  │  │  │  ├─ AppFrameworkInfo.plist
   │  │     │  │  │  │  ├─ Debug.xcconfig
   │  │     │  │  │  │  └─ Release.xcconfig
   │  │     │  │  │  ├─ Podfile
   │  │     │  │  │  ├─ Runner
   │  │     │  │  │  │  ├─ AppDelegate.h
   │  │     │  │  │  │  ├─ AppDelegate.m
   │  │     │  │  │  │  ├─ AppDelegate.swift
   │  │     │  │  │  │  ├─ Assets.xcassets
   │  │     │  │  │  │  │  ├─ AppIcon.appiconset
   │  │     │  │  │  │  │  │  ├─ Contents.json
   │  │     │  │  │  │  │  │  ├─ Icon-App-1024x1024@1x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@1x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@2x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@3x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@1x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@2x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@3x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@1x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@2x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@3x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-60x60@2x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-60x60@3x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-76x76@1x.png
   │  │     │  │  │  │  │  │  ├─ Icon-App-76x76@2x.png
   │  │     │  │  │  │  │  │  └─ Icon-App-83.5x83.5@2x.png
   │  │     │  │  │  │  │  └─ LaunchImage.imageset
   │  │     │  │  │  │  │     ├─ Contents.json
   │  │     │  │  │  │  │     ├─ LaunchImage.png
   │  │     │  │  │  │  │     ├─ LaunchImage@2x.png
   │  │     │  │  │  │  │     ├─ LaunchImage@3x.png
   │  │     │  │  │  │  │     └─ README.md
   │  │     │  │  │  │  ├─ Base.lproj
   │  │     │  │  │  │  │  ├─ LaunchScreen.storyboard
   │  │     │  │  │  │  │  └─ Main.storyboard
   │  │     │  │  │  │  ├─ GoogleService-Info.plist
   │  │     │  │  │  │  ├─ Info.plist
   │  │     │  │  │  │  ├─ main.m
   │  │     │  │  │  │  ├─ Runner-Bridging-Header.h
   │  │     │  │  │  │  └─ Runner.entitlements
   │  │     │  │  │  ├─ Runner.xcodeproj
   │  │     │  │  │  │  ├─ project.pbxproj
   │  │     │  │  │  │  ├─ project.xcworkspace
   │  │     │  │  │  │  │  ├─ contents.xcworkspacedata
   │  │     │  │  │  │  │  └─ xcshareddata
   │  │     │  │  │  │  │     ├─ IDEWorkspaceChecks.plist
   │  │     │  │  │  │  │     ├─ swiftpm
   │  │     │  │  │  │  │     │  └─ configuration
   │  │     │  │  │  │  │     └─ WorkspaceSettings.xcsettings
   │  │     │  │  │  │  └─ xcshareddata
   │  │     │  │  │  │     └─ xcschemes
   │  │     │  │  │  │        └─ Runner.xcscheme
   │  │     │  │  │  └─ Runner.xcworkspace
   │  │     │  │  │     ├─ contents.xcworkspacedata
   │  │     │  │  │     └─ xcshareddata
   │  │     │  │  │        ├─ IDEWorkspaceChecks.plist
   │  │     │  │  │        ├─ swiftpm
   │  │     │  │  │        │  └─ configuration
   │  │     │  │  │        └─ WorkspaceSettings.xcsettings
   │  │     │  │  ├─ lib
   │  │     │  │  │  ├─ auth.dart
   │  │     │  │  │  ├─ firebase_options.dart
   │  │     │  │  │  ├─ main.dart
   │  │     │  │  │  └─ profile.dart
   │  │     │  │  ├─ macos
   │  │     │  │  │  ├─ firebase_app_id_file.json
   │  │     │  │  │  ├─ Flutter
   │  │     │  │  │  │  ├─ Flutter-Debug.xcconfig
   │  │     │  │  │  │  └─ Flutter-Release.xcconfig
   │  │     │  │  │  ├─ Podfile
   │  │     │  │  │  ├─ Runner
   │  │     │  │  │  │  ├─ AppDelegate.swift
   │  │     │  │  │  │  ├─ Assets.xcassets
   │  │     │  │  │  │  │  └─ AppIcon.appiconset
   │  │     │  │  │  │  │     ├─ app_icon_1024.png
   │  │     │  │  │  │  │     ├─ app_icon_128.png
   │  │     │  │  │  │  │     ├─ app_icon_16.png
   │  │     │  │  │  │  │     ├─ app_icon_256.png
   │  │     │  │  │  │  │     ├─ app_icon_32.png
   │  │     │  │  │  │  │     ├─ app_icon_512.png
   │  │     │  │  │  │  │     ├─ app_icon_64.png
   │  │     │  │  │  │  │     └─ Contents.json
   │  │     │  │  │  │  ├─ Base.lproj
   │  │     │  │  │  │  │  └─ MainMenu.xib
   │  │     │  │  │  │  ├─ Configs
   │  │     │  │  │  │  │  ├─ AppInfo.xcconfig
   │  │     │  │  │  │  │  ├─ Debug.xcconfig
   │  │     │  │  │  │  │  ├─ Release.xcconfig
   │  │     │  │  │  │  │  └─ Warnings.xcconfig
   │  │     │  │  │  │  ├─ DebugProfile.entitlements
   │  │     │  │  │  │  ├─ GoogleService-Info.plist
   │  │     │  │  │  │  ├─ Info.plist
   │  │     │  │  │  │  ├─ MainFlutterWindow.swift
   │  │     │  │  │  │  └─ Release.entitlements
   │  │     │  │  │  ├─ Runner.xcodeproj
   │  │     │  │  │  │  ├─ project.pbxproj
   │  │     │  │  │  │  ├─ project.xcworkspace
   │  │     │  │  │  │  │  ├─ contents.xcworkspacedata
   │  │     │  │  │  │  │  └─ xcshareddata
   │  │     │  │  │  │  │     └─ IDEWorkspaceChecks.plist
   │  │     │  │  │  │  └─ xcshareddata
   │  │     │  │  │  │     └─ xcschemes
   │  │     │  │  │  │        └─ Runner.xcscheme
   │  │     │  │  │  └─ Runner.xcworkspace
   │  │     │  │  │     ├─ contents.xcworkspacedata
   │  │     │  │  │     └─ xcshareddata
   │  │     │  │  │        ├─ IDEWorkspaceChecks.plist
   │  │     │  │  │        └─ WorkspaceSettings.xcsettings
   │  │     │  │  ├─ pubspec.yaml
   │  │     │  │  ├─ README.md
   │  │     │  │  ├─ web
   │  │     │  │  │  ├─ favicon.png
   │  │     │  │  │  ├─ icons
   │  │     │  │  │  │  ├─ Icon-192.png
   │  │     │  │  │  │  ├─ Icon-512.png
   │  │     │  │  │  │  ├─ Icon-maskable-192.png
   │  │     │  │  │  │  └─ Icon-maskable-512.png
   │  │     │  │  │  ├─ index.html
   │  │     │  │  │  └─ manifest.json
   │  │     │  │  └─ windows
   │  │     │  │     ├─ CMakeLists.txt
   │  │     │  │     ├─ flutter
   │  │     │  │     │  └─ CMakeLists.txt
   │  │     │  │     └─ runner
   │  │     │  │        ├─ CMakeLists.txt
   │  │     │  │        ├─ flutter_window.cpp
   │  │     │  │        ├─ flutter_window.h
   │  │     │  │        ├─ main.cpp
   │  │     │  │        ├─ resource.h
   │  │     │  │        ├─ resources
   │  │     │  │        │  └─ app_icon.ico
   │  │     │  │        ├─ runner.exe.manifest
   │  │     │  │        ├─ Runner.rc
   │  │     │  │        ├─ utils.cpp
   │  │     │  │        ├─ utils.h
   │  │     │  │        ├─ win32_window.cpp
   │  │     │  │        └─ win32_window.h
   │  │     │  ├─ ios
   │  │     │  │  ├─ firebase_auth
   │  │     │  │  │  ├─ Package.swift
   │  │     │  │  │  └─ Sources
   │  │     │  │  │     └─ firebase_auth
   │  │     │  │  │        ├─ firebase_auth_messages.g.m
   │  │     │  │  │        ├─ FLTAuthStateChannelStreamHandler.m
   │  │     │  │  │        ├─ FLTFirebaseAuthPlugin.m
   │  │     │  │  │        ├─ FLTIdTokenChannelStreamHandler.m
   │  │     │  │  │        ├─ FLTPhoneNumberVerificationStreamHandler.m
   │  │     │  │  │        ├─ include
   │  │     │  │  │        │  ├─ Private
   │  │     │  │  │        │  │  ├─ FLTAuthStateChannelStreamHandler.h
   │  │     │  │  │        │  │  ├─ FLTIdTokenChannelStreamHandler.h
   │  │     │  │  │        │  │  ├─ FLTPhoneNumberVerificationStreamHandler.h
   │  │     │  │  │        │  │  └─ PigeonParser.h
   │  │     │  │  │        │  └─ Public
   │  │     │  │  │        │     ├─ CustomPigeonHeader.h
   │  │     │  │  │        │     ├─ firebase_auth_messages.g.h
   │  │     │  │  │        │     └─ FLTFirebaseAuthPlugin.h
   │  │     │  │  │        ├─ PigeonParser.m
   │  │     │  │  │        └─ Resources
   │  │     │  │  ├─ firebase_auth.podspec
   │  │     │  │  └─ generated_firebase_sdk_version.txt
   │  │     │  ├─ lib
   │  │     │  │  ├─ firebase_auth.dart
   │  │     │  │  └─ src
   │  │     │  │     ├─ confirmation_result.dart
   │  │     │  │     ├─ firebase_auth.dart
   │  │     │  │     ├─ multi_factor.dart
   │  │     │  │     ├─ recaptcha_verifier.dart
   │  │     │  │     ├─ user.dart
   │  │     │  │     └─ user_credential.dart
   │  │     │  ├─ LICENSE
   │  │     │  ├─ macos
   │  │     │  │  ├─ firebase_auth
   │  │     │  │  │  ├─ Package.swift
   │  │     │  │  │  └─ Sources
   │  │     │  │  │     └─ firebase_auth
   │  │     │  │  │        ├─ firebase_auth_messages.g.m
   │  │     │  │  │        ├─ FLTAuthStateChannelStreamHandler.m
   │  │     │  │  │        ├─ FLTFirebaseAuthPlugin.m
   │  │     │  │  │        ├─ FLTIdTokenChannelStreamHandler.m
   │  │     │  │  │        ├─ FLTPhoneNumberVerificationStreamHandler.m
   │  │     │  │  │        ├─ include
   │  │     │  │  │        │  ├─ Private
   │  │     │  │  │        │  │  ├─ FLTAuthStateChannelStreamHandler.h
   │  │     │  │  │        │  │  ├─ FLTIdTokenChannelStreamHandler.h
   │  │     │  │  │        │  │  ├─ FLTPhoneNumberVerificationStreamHandler.h
   │  │     │  │  │        │  │  └─ PigeonParser.h
   │  │     │  │  │        │  └─ Public
   │  │     │  │  │        │     ├─ CustomPigeonHeader.h
   │  │     │  │  │        │     ├─ firebase_auth_messages.g.h
   │  │     │  │  │        │     └─ FLTFirebaseAuthPlugin.h
   │  │     │  │  │        ├─ PigeonParser.m
   │  │     │  │  │        └─ Resource
   │  │     │  │  └─ firebase_auth.podspec
   │  │     │  ├─ pubspec.yaml
   │  │     │  ├─ README.md
   │  │     │  ├─ test
   │  │     │  │  ├─ firebase_auth_test.dart
   │  │     │  │  ├─ mock.dart
   │  │     │  │  └─ user_test.dart
   │  │     │  └─ windows
   │  │     │     ├─ CMakeLists.txt
   │  │     │     ├─ firebase_auth_plugin.cpp
   │  │     │     ├─ firebase_auth_plugin.h
   │  │     │     ├─ firebase_auth_plugin_c_api.cpp
   │  │     │     ├─ include
   │  │     │     │  └─ firebase_auth
   │  │     │     │     └─ firebase_auth_plugin_c_api.h
   │  │     │     ├─ messages.g.cpp
   │  │     │     ├─ messages.g.h
   │  │     │     ├─ plugin_version.h.in
   │  │     │     └─ test
   │  │     │        └─ firebase_auth_plugin_test.cpp
   │  │     └─ firebase_core
   │  │        ├─ android
   │  │        │  ├─ .gradle
   │  │        │  │  ├─ 8.4
   │  │        │  │  │  ├─ checksums
   │  │        │  │  │  │  └─ checksums.lock
   │  │        │  │  │  ├─ fileChanges
   │  │        │  │  │  │  └─ last-build.bin
   │  │        │  │  │  ├─ fileHashes
   │  │        │  │  │  │  └─ fileHashes.lock
   │  │        │  │  │  ├─ gc.properties
   │  │        │  │  │  └─ vcsMetadata
   │  │        │  │  └─ vcs-1
   │  │        │  │     └─ gc.properties
   │  │        │  ├─ build.gradle
   │  │        │  ├─ gradle
   │  │        │  │  └─ wrapper
   │  │        │  │     └─ gradle-wrapper.properties
   │  │        │  ├─ gradle.properties
   │  │        │  ├─ local-config.gradle
   │  │        │  ├─ settings.gradle
   │  │        │  ├─ src
   │  │        │  │  └─ main
   │  │        │  │     ├─ AndroidManifest.xml
   │  │        │  │     └─ java
   │  │        │  │        └─ io
   │  │        │  │           └─ flutter
   │  │        │  │              └─ plugins
   │  │        │  │                 └─ firebase
   │  │        │  │                    └─ core
   │  │        │  │                       ├─ FlutterFirebaseCorePlugin.java
   │  │        │  │                       ├─ FlutterFirebaseCoreRegistrar.java
   │  │        │  │                       ├─ FlutterFirebasePlugin.java
   │  │        │  │                       ├─ FlutterFirebasePluginRegistry.java
   │  │        │  │                       └─ GeneratedAndroidFirebaseCore.java
   │  │        │  └─ user-agent.gradle
   │  │        ├─ CHANGELOG.md
   │  │        ├─ example
   │  │        │  ├─ analysis_options.yaml
   │  │        │  ├─ android
   │  │        │  │  ├─ app
   │  │        │  │  │  ├─ build.gradle
   │  │        │  │  │  ├─ google-services.json
   │  │        │  │  │  └─ src
   │  │        │  │  │     ├─ debug
   │  │        │  │  │     │  └─ AndroidManifest.xml
   │  │        │  │  │     ├─ main
   │  │        │  │  │     │  ├─ AndroidManifest.xml
   │  │        │  │  │     │  ├─ java
   │  │        │  │  │     │  │  └─ io
   │  │        │  │  │     │  │     └─ flutter
   │  │        │  │  │     │  │        └─ plugins
   │  │        │  │  │     │  ├─ kotlin
   │  │        │  │  │     │  │  └─ io
   │  │        │  │  │     │  │     └─ flutter
   │  │        │  │  │     │  │        └─ plugins
   │  │        │  │  │     │  │           └─ firebasecoreexample
   │  │        │  │  │     │  │              └─ MainActivity.kt
   │  │        │  │  │     │  └─ res
   │  │        │  │  │     │     ├─ drawable
   │  │        │  │  │     │     │  └─ launch_background.xml
   │  │        │  │  │     │     ├─ drawable-v21
   │  │        │  │  │     │     │  └─ launch_background.xml
   │  │        │  │  │     │     ├─ mipmap-hdpi
   │  │        │  │  │     │     │  └─ ic_launcher.png
   │  │        │  │  │     │     ├─ mipmap-mdpi
   │  │        │  │  │     │     │  └─ ic_launcher.png
   │  │        │  │  │     │     ├─ mipmap-xhdpi
   │  │        │  │  │     │     │  └─ ic_launcher.png
   │  │        │  │  │     │     ├─ mipmap-xxhdpi
   │  │        │  │  │     │     │  └─ ic_launcher.png
   │  │        │  │  │     │     ├─ mipmap-xxxhdpi
   │  │        │  │  │     │     │  └─ ic_launcher.png
   │  │        │  │  │     │     ├─ values
   │  │        │  │  │     │     │  └─ styles.xml
   │  │        │  │  │     │     └─ values-night
   │  │        │  │  │     │        └─ styles.xml
   │  │        │  │  │     └─ profile
   │  │        │  │  │        └─ AndroidManifest.xml
   │  │        │  │  ├─ build.gradle
   │  │        │  │  ├─ gradle
   │  │        │  │  │  └─ wrapper
   │  │        │  │  │     └─ gradle-wrapper.properties
   │  │        │  │  ├─ gradle.properties
   │  │        │  │  └─ settings.gradle
   │  │        │  ├─ ios
   │  │        │  │  ├─ Flutter
   │  │        │  │  │  ├─ AppFrameworkInfo.plist
   │  │        │  │  │  ├─ Debug.xcconfig
   │  │        │  │  │  └─ Release.xcconfig
   │  │        │  │  ├─ Podfile
   │  │        │  │  ├─ Runner
   │  │        │  │  │  ├─ AppDelegate.h
   │  │        │  │  │  ├─ AppDelegate.m
   │  │        │  │  │  ├─ Assets.xcassets
   │  │        │  │  │  │  ├─ AppIcon.appiconset
   │  │        │  │  │  │  │  ├─ Contents.json
   │  │        │  │  │  │  │  ├─ Icon-App-1024x1024@1x.png
   │  │        │  │  │  │  │  ├─ Icon-App-20x20@1x.png
   │  │        │  │  │  │  │  ├─ Icon-App-20x20@2x.png
   │  │        │  │  │  │  │  ├─ Icon-App-20x20@3x.png
   │  │        │  │  │  │  │  ├─ Icon-App-29x29@1x.png
   │  │        │  │  │  │  │  ├─ Icon-App-29x29@2x.png
   │  │        │  │  │  │  │  ├─ Icon-App-29x29@3x.png
   │  │        │  │  │  │  │  ├─ Icon-App-40x40@1x.png
   │  │        │  │  │  │  │  ├─ Icon-App-40x40@2x.png
   │  │        │  │  │  │  │  ├─ Icon-App-40x40@3x.png
   │  │        │  │  │  │  │  ├─ Icon-App-60x60@2x.png
   │  │        │  │  │  │  │  ├─ Icon-App-60x60@3x.png
   │  │        │  │  │  │  │  ├─ Icon-App-76x76@1x.png
   │  │        │  │  │  │  │  ├─ Icon-App-76x76@2x.png
   │  │        │  │  │  │  │  └─ Icon-App-83.5x83.5@2x.png
   │  │        │  │  │  │  └─ LaunchImage.imageset
   │  │        │  │  │  │     ├─ Contents.json
   │  │        │  │  │  │     ├─ LaunchImage.png
   │  │        │  │  │  │     ├─ LaunchImage@2x.png
   │  │        │  │  │  │     ├─ LaunchImage@3x.png
   │  │        │  │  │  │     └─ README.md
   │  │        │  │  │  ├─ Base.lproj
   │  │        │  │  │  │  ├─ LaunchScreen.storyboard
   │  │        │  │  │  │  └─ Main.storyboard
   │  │        │  │  │  ├─ Info.plist
   │  │        │  │  │  └─ main.m
   │  │        │  │  ├─ Runner.xcodeproj
   │  │        │  │  │  ├─ project.pbxproj
   │  │        │  │  │  ├─ project.xcworkspace
   │  │        │  │  │  │  ├─ contents.xcworkspacedata
   │  │        │  │  │  │  └─ xcshareddata
   │  │        │  │  │  │     └─ IDEWorkspaceChecks.plist
   │  │        │  │  │  └─ xcshareddata
   │  │        │  │  │     └─ xcschemes
   │  │        │  │  │        └─ Runner.xcscheme
   │  │        │  │  └─ Runner.xcworkspace
   │  │        │  │     ├─ contents.xcworkspacedata
   │  │        │  │     └─ xcshareddata
   │  │        │  │        └─ IDEWorkspaceChecks.plist
   │  │        │  ├─ lib
   │  │        │  │  ├─ firebase_options.dart
   │  │        │  │  └─ main.dart
   │  │        │  ├─ macos
   │  │        │  │  ├─ Flutter
   │  │        │  │  │  ├─ Flutter-Debug.xcconfig
   │  │        │  │  │  └─ Flutter-Release.xcconfig
   │  │        │  │  ├─ Podfile
   │  │        │  │  ├─ Runner
   │  │        │  │  │  ├─ AppDelegate.swift
   │  │        │  │  │  ├─ Assets.xcassets
   │  │        │  │  │  │  └─ AppIcon.appiconset
   │  │        │  │  │  │     ├─ app_icon_1024.png
   │  │        │  │  │  │     ├─ app_icon_128.png
   │  │        │  │  │  │     ├─ app_icon_16.png
   │  │        │  │  │  │     ├─ app_icon_256.png
   │  │        │  │  │  │     ├─ app_icon_32.png
   │  │        │  │  │  │     ├─ app_icon_512.png
   │  │        │  │  │  │     ├─ app_icon_64.png
   │  │        │  │  │  │     └─ Contents.json
   │  │        │  │  │  ├─ Base.lproj
   │  │        │  │  │  │  └─ MainMenu.xib
   │  │        │  │  │  ├─ Configs
   │  │        │  │  │  │  ├─ AppInfo.xcconfig
   │  │        │  │  │  │  ├─ Debug.xcconfig
   │  │        │  │  │  │  ├─ Release.xcconfig
   │  │        │  │  │  │  └─ Warnings.xcconfig
   │  │        │  │  │  ├─ DebugProfile.entitlements
   │  │        │  │  │  ├─ Info.plist
   │  │        │  │  │  ├─ MainFlutterWindow.swift
   │  │        │  │  │  └─ Release.entitlements
   │  │        │  │  ├─ Runner.xcodeproj
   │  │        │  │  │  ├─ project.pbxproj
   │  │        │  │  │  ├─ project.xcworkspace
   │  │        │  │  │  │  ├─ contents.xcworkspacedata
   │  │        │  │  │  │  └─ xcshareddata
   │  │        │  │  │  │     └─ IDEWorkspaceChecks.plist
   │  │        │  │  │  └─ xcshareddata
   │  │        │  │  │     └─ xcschemes
   │  │        │  │  │        └─ Runner.xcscheme
   │  │        │  │  └─ Runner.xcworkspace
   │  │        │  │     ├─ contents.xcworkspacedata
   │  │        │  │     └─ xcshareddata
   │  │        │  │        ├─ IDEWorkspaceChecks.plist
   │  │        │  │        └─ WorkspaceSettings.xcsettings
   │  │        │  ├─ pubspec.yaml
   │  │        │  ├─ README.md
   │  │        │  ├─ web
   │  │        │  │  ├─ favicon.png
   │  │        │  │  ├─ icons
   │  │        │  │  │  ├─ Icon-192.png
   │  │        │  │  │  ├─ Icon-512.png
   │  │        │  │  │  ├─ Icon-maskable-192.png
   │  │        │  │  │  └─ Icon-maskable-512.png
   │  │        │  │  ├─ index.html
   │  │        │  │  └─ manifest.json
   │  │        │  └─ windows
   │  │        │     ├─ CMakeLists.txt
   │  │        │     ├─ flutter
   │  │        │     │  └─ CMakeLists.txt
   │  │        │     └─ runner
   │  │        │        ├─ CMakeLists.txt
   │  │        │        ├─ flutter_window.cpp
   │  │        │        ├─ flutter_window.h
   │  │        │        ├─ main.cpp
   │  │        │        ├─ resource.h
   │  │        │        ├─ resources
   │  │        │        │  └─ app_icon.ico
   │  │        │        ├─ runner.exe.manifest
   │  │        │        ├─ Runner.rc
   │  │        │        ├─ utils.cpp
   │  │        │        ├─ utils.h
   │  │        │        ├─ win32_window.cpp
   │  │        │        └─ win32_window.h
   │  │        ├─ ios
   │  │        │  ├─ firebase_core
   │  │        │  │  ├─ Package.swift
   │  │        │  │  └─ Sources
   │  │        │  │     └─ firebase_core
   │  │        │  │        ├─ dummy.m
   │  │        │  │        ├─ FLTFirebaseCorePlugin.m
   │  │        │  │        ├─ FLTFirebasePlugin.m
   │  │        │  │        ├─ FLTFirebasePluginRegistry.m
   │  │        │  │        ├─ include
   │  │        │  │        │  └─ firebase_core
   │  │        │  │        │     ├─ dummy.h
   │  │        │  │        │     ├─ FLTFirebaseCorePlugin.h
   │  │        │  │        │     ├─ FLTFirebasePlugin.h
   │  │        │  │        │     ├─ FLTFirebasePluginRegistry.h
   │  │        │  │        │     └─ messages.g.h
   │  │        │  │        ├─ messages.g.m
   │  │        │  │        └─ Resources
   │  │        │  ├─ firebase_core.podspec
   │  │        │  └─ firebase_sdk_version.rb
   │  │        ├─ lib
   │  │        │  ├─ firebase_core.dart
   │  │        │  └─ src
   │  │        │     ├─ firebase.dart
   │  │        │     ├─ firebase_app.dart
   │  │        │     └─ port_mapping.dart
   │  │        ├─ LICENSE
   │  │        ├─ macos
   │  │        │  ├─ firebase_core
   │  │        │  │  ├─ Package.swift
   │  │        │  │  └─ Sources
   │  │        │  │     └─ firebase_core
   │  │        │  │        ├─ dummy.m
   │  │        │  │        ├─ FLTFirebaseCorePlugin.m
   │  │        │  │        ├─ FLTFirebasePlugin.m
   │  │        │  │        ├─ FLTFirebasePluginRegistry.m
   │  │        │  │        ├─ include
   │  │        │  │        │  ├─ dummy.h
   │  │        │  │        │  └─ firebase_core
   │  │        │  │        │     ├─ FLTFirebaseCorePlugin.h
   │  │        │  │        │     ├─ FLTFirebasePlugin.h
   │  │        │  │        │     ├─ FLTFirebasePluginRegistry.h
   │  │        │  │        │     └─ messages.g.h
   │  │        │  │        ├─ messages.g.m
   │  │        │  │        └─ Resources
   │  │        │  └─ firebase_core.podspec
   │  │        ├─ pubspec.yaml
   │  │        ├─ README.md
   │  │        ├─ test
   │  │        │  └─ firebase_core_test.dart
   │  │        └─ windows
   │  │           ├─ CMakeLists.txt
   │  │           ├─ firebase_core_plugin.cpp
   │  │           ├─ firebase_core_plugin.h
   │  │           ├─ firebase_core_plugin_c_api.cpp
   │  │           ├─ include
   │  │           │  └─ firebase_core
   │  │           │     └─ firebase_core_plugin_c_api.h
   │  │           ├─ messages.g.cpp
   │  │           ├─ messages.g.h
   │  │           └─ plugin_version.h.in
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
