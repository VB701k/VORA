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

vs_code
├─ flutter
│  └─ VORA
│     ├─ .dart_tool
│     │  ├─ dartpad
│     │  │  └─ web_plugin_registrant.dart
│     │  ├─ extension_discovery
│     │  │  ├─ devtools.json
│     │  │  └─ vs_code.json
│     │  ├─ flutter_build
│     │  │  ├─ acbadb08e525c357ca5de78eebe2dbbd
│     │  │  │  ├─ .filecache
│     │  │  │  ├─ app.dill
│     │  │  │  ├─ dart_build.d
│     │  │  │  ├─ dart_build.stamp
│     │  │  │  ├─ dart_build_result.json
│     │  │  │  ├─ debug_android_application.stamp
│     │  │  │  ├─ flutter_assets.d
│     │  │  │  ├─ gen_dart_plugin_registrant.stamp
│     │  │  │  ├─ gen_localizations.stamp
│     │  │  │  ├─ install_code_assets.d
│     │  │  │  ├─ install_code_assets.stamp
│     │  │  │  ├─ kernel_snapshot_program.d
│     │  │  │  ├─ kernel_snapshot_program.stamp
│     │  │  │  ├─ native_assets.json
│     │  │  │  └─ outputs.json
│     │  │  └─ dart_plugin_registrant.dart
│     │  ├─ package_config.json
│     │  ├─ package_graph.json
│     │  └─ version
│     ├─ .flutter-plugins-dependencies
│     ├─ .metadata
│     ├─ analysis_options.yaml
│     ├─ android
│     │  ├─ .gradle
│     │  │  ├─ 8.14
│     │  │  │  ├─ checksums
│     │  │  │  │  └─ checksums.lock
│     │  │  │  ├─ executionHistory
│     │  │  │  │  ├─ executionHistory.bin
│     │  │  │  │  └─ executionHistory.lock
│     │  │  │  ├─ expanded
│     │  │  │  ├─ fileChanges
│     │  │  │  │  └─ last-build.bin
│     │  │  │  ├─ fileHashes
│     │  │  │  │  ├─ fileHashes.bin
│     │  │  │  │  ├─ fileHashes.lock
│     │  │  │  │  └─ resourceHashesCache.bin
│     │  │  │  ├─ gc.properties
│     │  │  │  └─ vcsMetadata
│     │  │  ├─ buildOutputCleanup
│     │  │  │  ├─ buildOutputCleanup.lock
│     │  │  │  ├─ cache.properties
│     │  │  │  └─ outputFiles.bin
│     │  │  ├─ noVersion
│     │  │  │  └─ buildLogic.lock
│     │  │  └─ vcs-1
│     │  │     └─ gc.properties
│     │  ├─ .kotlin
│     │  │  └─ sessions
│     │  ├─ app
│     │  │  ├─ build.gradle.kts
│     │  │  ├─ google-services.json
│     │  │  └─ src
│     │  │     ├─ debug
│     │  │     │  └─ AndroidManifest.xml
│     │  │     ├─ main
│     │  │     │  ├─ AndroidManifest.xml
│     │  │     │  ├─ java
│     │  │     │  │  └─ io
│     │  │     │  │     └─ flutter
│     │  │     │  │        └─ plugins
│     │  │     │  │           └─ GeneratedPluginRegistrant.java
│     │  │     │  ├─ kotlin
│     │  │     │  │  └─ com
│     │  │     │  │     └─ example
│     │  │     │  │        └─ sdgp
│     │  │     │  │           └─ MainActivity.kt
│     │  │     │  └─ res
│     │  │     │     ├─ drawable
│     │  │     │     │  └─ launch_background.xml
│     │  │     │     ├─ drawable-v21
│     │  │     │     │  └─ launch_background.xml
│     │  │     │     ├─ mipmap-hdpi
│     │  │     │     │  └─ ic_launcher.png
│     │  │     │     ├─ mipmap-mdpi
│     │  │     │     │  └─ ic_launcher.png
│     │  │     │     ├─ mipmap-xhdpi
│     │  │     │     │  └─ ic_launcher.png
│     │  │     │     ├─ mipmap-xxhdpi
│     │  │     │     │  └─ ic_launcher.png
│     │  │     │     ├─ mipmap-xxxhdpi
│     │  │     │     │  └─ ic_launcher.png
│     │  │     │     ├─ values
│     │  │     │     │  └─ styles.xml
│     │  │     │     └─ values-night
│     │  │     │        └─ styles.xml
│     │  │     └─ profile
│     │  │        └─ AndroidManifest.xml
│     │  ├─ build.gradle.kts
│     │  ├─ gradle
│     │  │  └─ wrapper
│     │  │     ├─ gradle-wrapper.jar
│     │  │     └─ gradle-wrapper.properties
│     │  ├─ gradle.properties
│     │  ├─ gradlew
│     │  ├─ gradlew.bat
│     │  ├─ local.properties
│     │  └─ settings.gradle.kts
│     ├─ assets
│     │  └─ logo.png
│     ├─ build
│     │  ├─ .cxx
│     │  │  └─ debug
│     │  │     └─ l4kjn2f5
│     │  │        ├─ arm64-v8a
│     │  │        │  ├─ .cmake
│     │  │        │  │  └─ api
│     │  │        │  │     └─ v1
│     │  │        │  │        ├─ query
│     │  │        │  │        │  └─ client-agp
│     │  │        │  │        │     ├─ cache-v2
│     │  │        │  │        │     ├─ cmakeFiles-v1
│     │  │        │  │        │     └─ codemodel-v2
│     │  │        │  │        └─ reply
│     │  │        │  │           ├─ cache-v2-3e6ee40eb3ca4a73f93a.json
│     │  │        │  │           ├─ cmakeFiles-v1-c6e269338ad5e33ea76b.json
│     │  │        │  │           ├─ codemodel-v2-723a9552ea73a2fa9cbe.json
│     │  │        │  │           ├─ directory-.-debug-d0094a50bb2071803777.json
│     │  │        │  │           └─ index-2026-03-12T23-27-48-0250.json
│     │  │        │  ├─ additional_project_files.txt
│     │  │        │  ├─ android_gradle_build.json
│     │  │        │  ├─ android_gradle_build_mini.json
│     │  │        │  ├─ build.ninja
│     │  │        │  ├─ build_file_index.txt
│     │  │        │  ├─ CMakeCache.txt
│     │  │        │  ├─ CMakeFiles
│     │  │        │  │  ├─ 3.22.1-g37088a8-dirty
│     │  │        │  │  │  ├─ CMakeCCompiler.cmake
│     │  │        │  │  │  ├─ CMakeCXXCompiler.cmake
│     │  │        │  │  │  ├─ CMakeDetermineCompilerABI_C.bin
│     │  │        │  │  │  ├─ CMakeDetermineCompilerABI_CXX.bin
│     │  │        │  │  │  ├─ CMakeSystem.cmake
│     │  │        │  │  │  ├─ CompilerIdC
│     │  │        │  │  │  │  ├─ CMakeCCompilerId.c
│     │  │        │  │  │  │  ├─ CMakeCCompilerId.o
│     │  │        │  │  │  │  └─ tmp
│     │  │        │  │  │  └─ CompilerIdCXX
│     │  │        │  │  │     ├─ CMakeCXXCompilerId.cpp
│     │  │        │  │  │     ├─ CMakeCXXCompilerId.o
│     │  │        │  │  │     └─ tmp
│     │  │        │  │  ├─ cmake.check_cache
│     │  │        │  │  ├─ CMakeOutput.log
│     │  │        │  │  ├─ CMakeTmp
│     │  │        │  │  ├─ rules.ninja
│     │  │        │  │  └─ TargetDirectories.txt
│     │  │        │  ├─ cmake_install.cmake
│     │  │        │  ├─ configure_fingerprint.bin
│     │  │        │  ├─ metadata_generation_command.txt
│     │  │        │  ├─ prefab_config.json
│     │  │        │  └─ symbol_folder_index.txt
│     │  │        ├─ armeabi-v7a
│     │  │        │  ├─ .cmake
│     │  │        │  │  └─ api
│     │  │        │  │     └─ v1
│     │  │        │  │        ├─ query
│     │  │        │  │        │  └─ client-agp
│     │  │        │  │        │     ├─ cache-v2
│     │  │        │  │        │     ├─ cmakeFiles-v1
│     │  │        │  │        │     └─ codemodel-v2
│     │  │        │  │        └─ reply
│     │  │        │  │           ├─ cache-v2-22679ed5a682b5ea7c2b.json
│     │  │        │  │           ├─ cmakeFiles-v1-1c847f521ea04a1e6c8f.json
│     │  │        │  │           ├─ codemodel-v2-25adad43d10997254b70.json
│     │  │        │  │           ├─ directory-.-debug-d0094a50bb2071803777.json
│     │  │        │  │           └─ index-2026-03-12T23-27-49-0657.json
│     │  │        │  ├─ additional_project_files.txt
│     │  │        │  ├─ android_gradle_build.json
│     │  │        │  ├─ android_gradle_build_mini.json
│     │  │        │  ├─ build.ninja
│     │  │        │  ├─ build_file_index.txt
│     │  │        │  ├─ CMakeCache.txt
│     │  │        │  ├─ CMakeFiles
│     │  │        │  │  ├─ 3.22.1-g37088a8-dirty
│     │  │        │  │  │  ├─ CMakeCCompiler.cmake
│     │  │        │  │  │  ├─ CMakeCXXCompiler.cmake
│     │  │        │  │  │  ├─ CMakeDetermineCompilerABI_C.bin
│     │  │        │  │  │  ├─ CMakeDetermineCompilerABI_CXX.bin
│     │  │        │  │  │  ├─ CMakeSystem.cmake
│     │  │        │  │  │  ├─ CompilerIdC
│     │  │        │  │  │  │  ├─ CMakeCCompilerId.c
│     │  │        │  │  │  │  ├─ CMakeCCompilerId.o
│     │  │        │  │  │  │  └─ tmp
│     │  │        │  │  │  └─ CompilerIdCXX
│     │  │        │  │  │     ├─ CMakeCXXCompilerId.cpp
│     │  │        │  │  │     ├─ CMakeCXXCompilerId.o
│     │  │        │  │  │     └─ tmp
│     │  │        │  │  ├─ cmake.check_cache
│     │  │        │  │  ├─ CMakeOutput.log
│     │  │        │  │  ├─ CMakeTmp
│     │  │        │  │  ├─ rules.ninja
│     │  │        │  │  └─ TargetDirectories.txt
│     │  │        │  ├─ cmake_install.cmake
│     │  │        │  ├─ configure_fingerprint.bin
│     │  │        │  ├─ metadata_generation_command.txt
│     │  │        │  ├─ prefab_config.json
│     │  │        │  └─ symbol_folder_index.txt
│     │  │        ├─ hash_key.txt
│     │  │        └─ x86_64
│     │  │           ├─ .cmake
│     │  │           │  └─ api
│     │  │           │     └─ v1
│     │  │           │        ├─ query
│     │  │           │        │  └─ client-agp
│     │  │           │        │     ├─ cache-v2
│     │  │           │        │     ├─ cmakeFiles-v1
│     │  │           │        │     └─ codemodel-v2
│     │  │           │        └─ reply
│     │  │           │           ├─ cache-v2-d4ff8f675fbb76fe37fb.json
│     │  │           │           ├─ cmakeFiles-v1-550b4ace08cb365b9483.json
│     │  │           │           ├─ codemodel-v2-ce56ec9620b44bc9f176.json
│     │  │           │           ├─ directory-.-debug-d0094a50bb2071803777.json
│     │  │           │           └─ index-2026-03-12T23-27-51-0123.json
│     │  │           ├─ additional_project_files.txt
│     │  │           ├─ android_gradle_build.json
│     │  │           ├─ android_gradle_build_mini.json
│     │  │           ├─ build.ninja
│     │  │           ├─ build_file_index.txt
│     │  │           ├─ CMakeCache.txt
│     │  │           ├─ CMakeFiles
│     │  │           │  ├─ 3.22.1-g37088a8-dirty
│     │  │           │  │  ├─ CMakeCCompiler.cmake
│     │  │           │  │  ├─ CMakeCXXCompiler.cmake
│     │  │           │  │  ├─ CMakeDetermineCompilerABI_C.bin
│     │  │           │  │  ├─ CMakeDetermineCompilerABI_CXX.bin
│     │  │           │  │  ├─ CMakeSystem.cmake
│     │  │           │  │  ├─ CompilerIdC
│     │  │           │  │  │  ├─ CMakeCCompilerId.c
│     │  │           │  │  │  ├─ CMakeCCompilerId.o
│     │  │           │  │  │  └─ tmp
│     │  │           │  │  └─ CompilerIdCXX
│     │  │           │  │     ├─ CMakeCXXCompilerId.cpp
│     │  │           │  │     ├─ CMakeCXXCompilerId.o
│     │  │           │  │     └─ tmp
│     │  │           │  ├─ cmake.check_cache
│     │  │           │  ├─ CMakeOutput.log
│     │  │           │  ├─ CMakeTmp
│     │  │           │  ├─ rules.ninja
│     │  │           │  └─ TargetDirectories.txt
│     │  │           ├─ cmake_install.cmake
│     │  │           ├─ configure_fingerprint.bin
│     │  │           ├─ metadata_generation_command.txt
│     │  │           ├─ prefab_config.json
│     │  │           └─ symbol_folder_index.txt
│     │  ├─ 8ec3e477300a6f54c438f47904230833
│     │  │  ├─ gen_dart_plugin_registrant.stamp
│     │  │  ├─ gen_localizations.stamp
│     │  │  └─ _composite.stamp
│     │  ├─ app
│     │  │  ├─ deeplink.json
│     │  │  ├─ generated
│     │  │  │  ├─ ap_generated_sources
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ out
│     │  │  │  └─ res
│     │  │  │     ├─ pngs
│     │  │  │     │  └─ debug
│     │  │  │     ├─ processDebugGoogleServices
│     │  │  │     │  └─ values
│     │  │  │     │     └─ values.xml
│     │  │  │     └─ resValues
│     │  │  │        └─ debug
│     │  │  ├─ gmpAppId
│     │  │  │  └─ debug.txt
│     │  │  ├─ intermediates
│     │  │  │  ├─ aar_metadata_check
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ checkDebugAarMetadata
│     │  │  │  ├─ annotation_processor_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ javaPreCompileDebug
│     │  │  │  │        └─ annotationProcessors.json
│     │  │  │  ├─ apk_ide_redirect_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ createDebugApkListingFileRedirect
│     │  │  │  │        └─ redirect.txt
│     │  │  │  ├─ app_metadata
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ writeDebugAppMetadata
│     │  │  │  │        └─ app-metadata.properties
│     │  │  │  ├─ assets
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugAssets
│     │  │  │  │        └─ flutter_assets
│     │  │  │  │           ├─ AssetManifest.bin
│     │  │  │  │           ├─ assets
│     │  │  │  │           │  └─ logo.png
│     │  │  │  │           ├─ FontManifest.json
│     │  │  │  │           ├─ fonts
│     │  │  │  │           │  └─ MaterialIcons-Regular.otf
│     │  │  │  │           ├─ isolate_snapshot_data
│     │  │  │  │           ├─ kernel_blob.bin
│     │  │  │  │           ├─ NativeAssetsManifest.json
│     │  │  │  │           ├─ NOTICES.Z
│     │  │  │  │           ├─ packages
│     │  │  │  │           │  └─ cupertino_icons
│     │  │  │  │           │     └─ assets
│     │  │  │  │           │        └─ CupertinoIcons.ttf
│     │  │  │  │           ├─ shaders
│     │  │  │  │           │  ├─ ink_sparkle.frag
│     │  │  │  │           │  └─ stretch_effect.frag
│     │  │  │  │           └─ vm_snapshot_data
│     │  │  │  ├─ compatible_screen_manifest
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ createDebugCompatibleScreenManifests
│     │  │  │  │        └─ output-metadata.json
│     │  │  │  ├─ compile_and_runtime_not_namespaced_r_class_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugResources
│     │  │  │  │        └─ R.jar
│     │  │  │  ├─ compressed_assets
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ compressDebugAssets
│     │  │  │  │        └─ out
│     │  │  │  │           └─ assets
│     │  │  │  │              └─ flutter_assets
│     │  │  │  │                 ├─ AssetManifest.bin.jar
│     │  │  │  │                 ├─ assets
│     │  │  │  │                 │  └─ logo.png.jar
│     │  │  │  │                 ├─ FontManifest.json.jar
│     │  │  │  │                 ├─ fonts
│     │  │  │  │                 │  └─ MaterialIcons-Regular.otf.jar
│     │  │  │  │                 ├─ isolate_snapshot_data.jar
│     │  │  │  │                 ├─ kernel_blob.bin.jar
│     │  │  │  │                 ├─ NativeAssetsManifest.json.jar
│     │  │  │  │                 ├─ NOTICES.Z.jar
│     │  │  │  │                 ├─ packages
│     │  │  │  │                 │  └─ cupertino_icons
│     │  │  │  │                 │     └─ assets
│     │  │  │  │                 │        └─ CupertinoIcons.ttf.jar
│     │  │  │  │                 ├─ shaders
│     │  │  │  │                 │  ├─ ink_sparkle.frag.jar
│     │  │  │  │                 │  └─ stretch_effect.frag.jar
│     │  │  │  │                 └─ vm_snapshot_data.jar
│     │  │  │  ├─ cxx
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ l4kjn2f5
│     │  │  │  │        ├─ logs
│     │  │  │  │        │  ├─ arm64-v8a
│     │  │  │  │        │  │  ├─ build_model.json
│     │  │  │  │        │  │  ├─ configure_command.bat
│     │  │  │  │        │  │  ├─ configure_stderr.txt
│     │  │  │  │        │  │  ├─ configure_stdout.txt
│     │  │  │  │        │  │  ├─ generate_cxx_metadata_2105_timing.txt
│     │  │  │  │        │  │  ├─ generate_cxx_metadata_2607_timing.txt
│     │  │  │  │        │  │  ├─ generate_cxx_metadata_2995_timing.txt
│     │  │  │  │        │  │  └─ metadata_generation_record.json
│     │  │  │  │        │  ├─ armeabi-v7a
│     │  │  │  │        │  │  ├─ build_model.json
│     │  │  │  │        │  │  ├─ configure_command.bat
│     │  │  │  │        │  │  ├─ configure_stderr.txt
│     │  │  │  │        │  │  ├─ configure_stdout.txt
│     │  │  │  │        │  │  ├─ generate_cxx_metadata_2102_timing.txt
│     │  │  │  │        │  │  ├─ generate_cxx_metadata_2634_timing.txt
│     │  │  │  │        │  │  ├─ generate_cxx_metadata_2995_timing.txt
│     │  │  │  │        │  │  └─ metadata_generation_record.json
│     │  │  │  │        │  └─ x86_64
│     │  │  │  │        │     ├─ build_model.json
│     │  │  │  │        │     ├─ configure_command.bat
│     │  │  │  │        │     ├─ configure_stderr.txt
│     │  │  │  │        │     ├─ configure_stdout.txt
│     │  │  │  │        │     ├─ generate_cxx_metadata_2094_timing.txt
│     │  │  │  │        │     ├─ generate_cxx_metadata_2634_timing.txt
│     │  │  │  │        │     ├─ generate_cxx_metadata_2999_timing.txt
│     │  │  │  │        │     └─ metadata_generation_record.json
│     │  │  │  │        └─ obj
│     │  │  │  │           ├─ arm64-v8a
│     │  │  │  │           ├─ armeabi-v7a
│     │  │  │  │           └─ x86_64
│     │  │  │  ├─ data_binding_layout_info_type_merge
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugResources
│     │  │  │  │        └─ out
│     │  │  │  ├─ data_binding_layout_info_type_package
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  │        └─ out
│     │  │  │  ├─ desugar_graph
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ dexBuilderDebug
│     │  │  │  │        └─ out
│     │  │  │  │           ├─ currentProject
│     │  │  │  │           │  ├─ dirs_bucket_0
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ dirs_bucket_1
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ dirs_bucket_10
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ dirs_bucket_11
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ dirs_bucket_12
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ dirs_bucket_13
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ dirs_bucket_14
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ dirs_bucket_15
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ dirs_bucket_2
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ dirs_bucket_3
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ dirs_bucket_4
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ dirs_bucket_5
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ dirs_bucket_6
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ dirs_bucket_7
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ dirs_bucket_8
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ dirs_bucket_9
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_0
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_1
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_10
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_11
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_12
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_13
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_14
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_15
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_2
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_3
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_4
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_5
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_6
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_7
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  ├─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_8
│     │  │  │  │           │  │  └─ graph.bin
│     │  │  │  │           │  └─ jar_9357431e941af4da8ba48ccf113ae116ae72720bf2b2fc36964ae98b144025e0_bucket_9
│     │  │  │  │           │     └─ graph.bin
│     │  │  │  │           ├─ externalLibs
│     │  │  │  │           ├─ mixedScopes
│     │  │  │  │           └─ otherProjects
│     │  │  │  ├─ desugar_lib_dex
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ l8DexDesugarLibDebug
│     │  │  │  │        └─ classes1000.dex
│     │  │  │  ├─ dex
│     │  │  │  │  └─ debug
│     │  │  │  │     ├─ mergeExtDexDebug
│     │  │  │  │     │  ├─ classes.dex
│     │  │  │  │     │  ├─ classes2.dex
│     │  │  │  │     │  └─ classes3.dex
│     │  │  │  │     ├─ mergeLibDexDebug
│     │  │  │  │     │  ├─ 0
│     │  │  │  │     │  ├─ 1
│     │  │  │  │     │  ├─ 10
│     │  │  │  │     │  │  └─ classes.dex
│     │  │  │  │     │  ├─ 11
│     │  │  │  │     │  │  └─ classes.dex
│     │  │  │  │     │  ├─ 12
│     │  │  │  │     │  ├─ 13
│     │  │  │  │     │  │  └─ classes.dex
│     │  │  │  │     │  ├─ 14
│     │  │  │  │     │  │  └─ classes.dex
│     │  │  │  │     │  ├─ 15
│     │  │  │  │     │  ├─ 2
│     │  │  │  │     │  │  └─ classes.dex
│     │  │  │  │     │  ├─ 3
│     │  │  │  │     │  │  └─ classes.dex
│     │  │  │  │     │  ├─ 4
│     │  │  │  │     │  │  └─ classes.dex
│     │  │  │  │     │  ├─ 5
│     │  │  │  │     │  │  └─ classes.dex
│     │  │  │  │     │  ├─ 6
│     │  │  │  │     │  ├─ 7
│     │  │  │  │     │  │  └─ classes.dex
│     │  │  │  │     │  ├─ 8
│     │  │  │  │     │  └─ 9
│     │  │  │  │     └─ mergeProjectDexDebug
│     │  │  │  │        ├─ 0
│     │  │  │  │        │  └─ classes.dex
│     │  │  │  │        ├─ 1
│     │  │  │  │        │  └─ classes.dex
│     │  │  │  │        ├─ 10
│     │  │  │  │        ├─ 11
│     │  │  │  │        ├─ 12
│     │  │  │  │        ├─ 13
│     │  │  │  │        ├─ 14
│     │  │  │  │        ├─ 15
│     │  │  │  │        ├─ 2
│     │  │  │  │        ├─ 3
│     │  │  │  │        ├─ 4
│     │  │  │  │        │  └─ classes.dex
│     │  │  │  │        ├─ 5
│     │  │  │  │        ├─ 6
│     │  │  │  │        ├─ 7
│     │  │  │  │        ├─ 8
│     │  │  │  │        └─ 9
│     │  │  │  ├─ dex_archive_input_jar_hashes
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ dexBuilderDebug
│     │  │  │  │        └─ out
│     │  │  │  ├─ dex_number_of_buckets_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ dexBuilderDebug
│     │  │  │  │        └─ out
│     │  │  │  ├─ duplicate_classes_check
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ checkDebugDuplicateClasses
│     │  │  │  ├─ external_file_lib_dex_archives
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ desugarDebugFileDependencies
│     │  │  │  ├─ external_libs_dex_archive
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ dexBuilderDebug
│     │  │  │  │        └─ out
│     │  │  │  ├─ external_libs_dex_archive_with_artifact_transforms
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ dexBuilderDebug
│     │  │  │  │        └─ out
│     │  │  │  ├─ flutter
│     │  │  │  │  └─ debug
│     │  │  │  │     ├─ .last_build_id
│     │  │  │  │     ├─ flutter_assets
│     │  │  │  │     │  ├─ AssetManifest.bin
│     │  │  │  │     │  ├─ assets
│     │  │  │  │     │  │  └─ logo.png
│     │  │  │  │     │  ├─ FontManifest.json
│     │  │  │  │     │  ├─ fonts
│     │  │  │  │     │  │  └─ MaterialIcons-Regular.otf
│     │  │  │  │     │  ├─ isolate_snapshot_data
│     │  │  │  │     │  ├─ kernel_blob.bin
│     │  │  │  │     │  ├─ NativeAssetsManifest.json
│     │  │  │  │     │  ├─ NOTICES.Z
│     │  │  │  │     │  ├─ packages
│     │  │  │  │     │  │  └─ cupertino_icons
│     │  │  │  │     │  │     └─ assets
│     │  │  │  │     │  │        └─ CupertinoIcons.ttf
│     │  │  │  │     │  ├─ shaders
│     │  │  │  │     │  │  ├─ ink_sparkle.frag
│     │  │  │  │     │  │  └─ stretch_effect.frag
│     │  │  │  │     │  └─ vm_snapshot_data
│     │  │  │  │     ├─ flutter_build.d
│     │  │  │  │     └─ libs.jar
│     │  │  │  ├─ global_synthetics_dex
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugGlobalSynthetics
│     │  │  │  ├─ global_synthetics_external_lib
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ dexBuilderDebug
│     │  │  │  │        └─ out
│     │  │  │  ├─ global_synthetics_external_libs_artifact_transform
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ dexBuilderDebug
│     │  │  │  │        └─ out
│     │  │  │  ├─ global_synthetics_file_lib
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ desugarDebugFileDependencies
│     │  │  │  ├─ global_synthetics_mixed_scope
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ dexBuilderDebug
│     │  │  │  │        └─ out
│     │  │  │  ├─ global_synthetics_project
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ dexBuilderDebug
│     │  │  │  │        └─ out
│     │  │  │  ├─ global_synthetics_subproject
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ dexBuilderDebug
│     │  │  │  │        └─ out
│     │  │  │  ├─ incremental
│     │  │  │  │  ├─ debug
│     │  │  │  │  │  ├─ mergeDebugResources
│     │  │  │  │  │  │  ├─ compile-file-map.properties
│     │  │  │  │  │  │  ├─ merged.dir
│     │  │  │  │  │  │  │  ├─ values
│     │  │  │  │  │  │  │  │  └─ values.xml
│     │  │  │  │  │  │  │  ├─ values-af
│     │  │  │  │  │  │  │  │  └─ values-af.xml
│     │  │  │  │  │  │  │  ├─ values-am
│     │  │  │  │  │  │  │  │  └─ values-am.xml
│     │  │  │  │  │  │  │  ├─ values-ar
│     │  │  │  │  │  │  │  │  └─ values-ar.xml
│     │  │  │  │  │  │  │  ├─ values-as
│     │  │  │  │  │  │  │  │  └─ values-as.xml
│     │  │  │  │  │  │  │  ├─ values-az
│     │  │  │  │  │  │  │  │  └─ values-az.xml
│     │  │  │  │  │  │  │  ├─ values-b+sr+Latn
│     │  │  │  │  │  │  │  │  └─ values-b+sr+Latn.xml
│     │  │  │  │  │  │  │  ├─ values-be
│     │  │  │  │  │  │  │  │  └─ values-be.xml
│     │  │  │  │  │  │  │  ├─ values-bg
│     │  │  │  │  │  │  │  │  └─ values-bg.xml
│     │  │  │  │  │  │  │  ├─ values-bn
│     │  │  │  │  │  │  │  │  └─ values-bn.xml
│     │  │  │  │  │  │  │  ├─ values-bs
│     │  │  │  │  │  │  │  │  └─ values-bs.xml
│     │  │  │  │  │  │  │  ├─ values-ca
│     │  │  │  │  │  │  │  │  └─ values-ca.xml
│     │  │  │  │  │  │  │  ├─ values-cs
│     │  │  │  │  │  │  │  │  └─ values-cs.xml
│     │  │  │  │  │  │  │  ├─ values-da
│     │  │  │  │  │  │  │  │  └─ values-da.xml
│     │  │  │  │  │  │  │  ├─ values-de
│     │  │  │  │  │  │  │  │  └─ values-de.xml
│     │  │  │  │  │  │  │  ├─ values-el
│     │  │  │  │  │  │  │  │  └─ values-el.xml
│     │  │  │  │  │  │  │  ├─ values-en-rAU
│     │  │  │  │  │  │  │  │  └─ values-en-rAU.xml
│     │  │  │  │  │  │  │  ├─ values-en-rCA
│     │  │  │  │  │  │  │  │  └─ values-en-rCA.xml
│     │  │  │  │  │  │  │  ├─ values-en-rGB
│     │  │  │  │  │  │  │  │  └─ values-en-rGB.xml
│     │  │  │  │  │  │  │  ├─ values-en-rIN
│     │  │  │  │  │  │  │  │  └─ values-en-rIN.xml
│     │  │  │  │  │  │  │  ├─ values-en-rXC
│     │  │  │  │  │  │  │  │  └─ values-en-rXC.xml
│     │  │  │  │  │  │  │  ├─ values-es
│     │  │  │  │  │  │  │  │  └─ values-es.xml
│     │  │  │  │  │  │  │  ├─ values-es-rUS
│     │  │  │  │  │  │  │  │  └─ values-es-rUS.xml
│     │  │  │  │  │  │  │  ├─ values-et
│     │  │  │  │  │  │  │  │  └─ values-et.xml
│     │  │  │  │  │  │  │  ├─ values-eu
│     │  │  │  │  │  │  │  │  └─ values-eu.xml
│     │  │  │  │  │  │  │  ├─ values-fa
│     │  │  │  │  │  │  │  │  └─ values-fa.xml
│     │  │  │  │  │  │  │  ├─ values-fi
│     │  │  │  │  │  │  │  │  └─ values-fi.xml
│     │  │  │  │  │  │  │  ├─ values-fr
│     │  │  │  │  │  │  │  │  └─ values-fr.xml
│     │  │  │  │  │  │  │  ├─ values-fr-rCA
│     │  │  │  │  │  │  │  │  └─ values-fr-rCA.xml
│     │  │  │  │  │  │  │  ├─ values-gl
│     │  │  │  │  │  │  │  │  └─ values-gl.xml
│     │  │  │  │  │  │  │  ├─ values-gu
│     │  │  │  │  │  │  │  │  └─ values-gu.xml
│     │  │  │  │  │  │  │  ├─ values-h720dp-v13
│     │  │  │  │  │  │  │  │  └─ values-h720dp-v13.xml
│     │  │  │  │  │  │  │  ├─ values-hdpi-v4
│     │  │  │  │  │  │  │  │  └─ values-hdpi-v4.xml
│     │  │  │  │  │  │  │  ├─ values-hi
│     │  │  │  │  │  │  │  │  └─ values-hi.xml
│     │  │  │  │  │  │  │  ├─ values-hr
│     │  │  │  │  │  │  │  │  └─ values-hr.xml
│     │  │  │  │  │  │  │  ├─ values-hu
│     │  │  │  │  │  │  │  │  └─ values-hu.xml
│     │  │  │  │  │  │  │  ├─ values-hy
│     │  │  │  │  │  │  │  │  └─ values-hy.xml
│     │  │  │  │  │  │  │  ├─ values-in
│     │  │  │  │  │  │  │  │  └─ values-in.xml
│     │  │  │  │  │  │  │  ├─ values-is
│     │  │  │  │  │  │  │  │  └─ values-is.xml
│     │  │  │  │  │  │  │  ├─ values-it
│     │  │  │  │  │  │  │  │  └─ values-it.xml
│     │  │  │  │  │  │  │  ├─ values-iw
│     │  │  │  │  │  │  │  │  └─ values-iw.xml
│     │  │  │  │  │  │  │  ├─ values-ja
│     │  │  │  │  │  │  │  │  └─ values-ja.xml
│     │  │  │  │  │  │  │  ├─ values-ka
│     │  │  │  │  │  │  │  │  └─ values-ka.xml
│     │  │  │  │  │  │  │  ├─ values-kk
│     │  │  │  │  │  │  │  │  └─ values-kk.xml
│     │  │  │  │  │  │  │  ├─ values-km
│     │  │  │  │  │  │  │  │  └─ values-km.xml
│     │  │  │  │  │  │  │  ├─ values-kn
│     │  │  │  │  │  │  │  │  └─ values-kn.xml
│     │  │  │  │  │  │  │  ├─ values-ko
│     │  │  │  │  │  │  │  │  └─ values-ko.xml
│     │  │  │  │  │  │  │  ├─ values-ky
│     │  │  │  │  │  │  │  │  └─ values-ky.xml
│     │  │  │  │  │  │  │  ├─ values-land
│     │  │  │  │  │  │  │  │  └─ values-land.xml
│     │  │  │  │  │  │  │  ├─ values-large-v4
│     │  │  │  │  │  │  │  │  └─ values-large-v4.xml
│     │  │  │  │  │  │  │  ├─ values-ldltr-v21
│     │  │  │  │  │  │  │  │  └─ values-ldltr-v21.xml
│     │  │  │  │  │  │  │  ├─ values-lo
│     │  │  │  │  │  │  │  │  └─ values-lo.xml
│     │  │  │  │  │  │  │  ├─ values-lt
│     │  │  │  │  │  │  │  │  └─ values-lt.xml
│     │  │  │  │  │  │  │  ├─ values-lv
│     │  │  │  │  │  │  │  │  └─ values-lv.xml
│     │  │  │  │  │  │  │  ├─ values-mk
│     │  │  │  │  │  │  │  │  └─ values-mk.xml
│     │  │  │  │  │  │  │  ├─ values-ml
│     │  │  │  │  │  │  │  │  └─ values-ml.xml
│     │  │  │  │  │  │  │  ├─ values-mn
│     │  │  │  │  │  │  │  │  └─ values-mn.xml
│     │  │  │  │  │  │  │  ├─ values-mr
│     │  │  │  │  │  │  │  │  └─ values-mr.xml
│     │  │  │  │  │  │  │  ├─ values-ms
│     │  │  │  │  │  │  │  │  └─ values-ms.xml
│     │  │  │  │  │  │  │  ├─ values-my
│     │  │  │  │  │  │  │  │  └─ values-my.xml
│     │  │  │  │  │  │  │  ├─ values-nb
│     │  │  │  │  │  │  │  │  └─ values-nb.xml
│     │  │  │  │  │  │  │  ├─ values-ne
│     │  │  │  │  │  │  │  │  └─ values-ne.xml
│     │  │  │  │  │  │  │  ├─ values-night-v8
│     │  │  │  │  │  │  │  │  └─ values-night-v8.xml
│     │  │  │  │  │  │  │  ├─ values-nl
│     │  │  │  │  │  │  │  │  └─ values-nl.xml
│     │  │  │  │  │  │  │  ├─ values-or
│     │  │  │  │  │  │  │  │  └─ values-or.xml
│     │  │  │  │  │  │  │  ├─ values-pa
│     │  │  │  │  │  │  │  │  └─ values-pa.xml
│     │  │  │  │  │  │  │  ├─ values-pl
│     │  │  │  │  │  │  │  │  └─ values-pl.xml
│     │  │  │  │  │  │  │  ├─ values-port
│     │  │  │  │  │  │  │  │  └─ values-port.xml
│     │  │  │  │  │  │  │  ├─ values-pt
│     │  │  │  │  │  │  │  │  └─ values-pt.xml
│     │  │  │  │  │  │  │  ├─ values-pt-rBR
│     │  │  │  │  │  │  │  │  └─ values-pt-rBR.xml
│     │  │  │  │  │  │  │  ├─ values-pt-rPT
│     │  │  │  │  │  │  │  │  └─ values-pt-rPT.xml
│     │  │  │  │  │  │  │  ├─ values-ro
│     │  │  │  │  │  │  │  │  └─ values-ro.xml
│     │  │  │  │  │  │  │  ├─ values-ru
│     │  │  │  │  │  │  │  │  └─ values-ru.xml
│     │  │  │  │  │  │  │  ├─ values-si
│     │  │  │  │  │  │  │  │  └─ values-si.xml
│     │  │  │  │  │  │  │  ├─ values-sk
│     │  │  │  │  │  │  │  │  └─ values-sk.xml
│     │  │  │  │  │  │  │  ├─ values-sl
│     │  │  │  │  │  │  │  │  └─ values-sl.xml
│     │  │  │  │  │  │  │  ├─ values-sq
│     │  │  │  │  │  │  │  │  └─ values-sq.xml
│     │  │  │  │  │  │  │  ├─ values-sr
│     │  │  │  │  │  │  │  │  └─ values-sr.xml
│     │  │  │  │  │  │  │  ├─ values-sv
│     │  │  │  │  │  │  │  │  └─ values-sv.xml
│     │  │  │  │  │  │  │  ├─ values-sw
│     │  │  │  │  │  │  │  │  └─ values-sw.xml
│     │  │  │  │  │  │  │  ├─ values-sw360dp-v13
│     │  │  │  │  │  │  │  │  └─ values-sw360dp-v13.xml
│     │  │  │  │  │  │  │  ├─ values-sw600dp-v13
│     │  │  │  │  │  │  │  │  └─ values-sw600dp-v13.xml
│     │  │  │  │  │  │  │  ├─ values-ta
│     │  │  │  │  │  │  │  │  └─ values-ta.xml
│     │  │  │  │  │  │  │  ├─ values-te
│     │  │  │  │  │  │  │  │  └─ values-te.xml
│     │  │  │  │  │  │  │  ├─ values-th
│     │  │  │  │  │  │  │  │  └─ values-th.xml
│     │  │  │  │  │  │  │  ├─ values-tl
│     │  │  │  │  │  │  │  │  └─ values-tl.xml
│     │  │  │  │  │  │  │  ├─ values-tr
│     │  │  │  │  │  │  │  │  └─ values-tr.xml
│     │  │  │  │  │  │  │  ├─ values-uk
│     │  │  │  │  │  │  │  │  └─ values-uk.xml
│     │  │  │  │  │  │  │  ├─ values-ur
│     │  │  │  │  │  │  │  │  └─ values-ur.xml
│     │  │  │  │  │  │  │  ├─ values-uz
│     │  │  │  │  │  │  │  │  └─ values-uz.xml
│     │  │  │  │  │  │  │  ├─ values-v16
│     │  │  │  │  │  │  │  │  └─ values-v16.xml
│     │  │  │  │  │  │  │  ├─ values-v17
│     │  │  │  │  │  │  │  │  └─ values-v17.xml
│     │  │  │  │  │  │  │  ├─ values-v18
│     │  │  │  │  │  │  │  │  └─ values-v18.xml
│     │  │  │  │  │  │  │  ├─ values-v21
│     │  │  │  │  │  │  │  │  └─ values-v21.xml
│     │  │  │  │  │  │  │  ├─ values-v22
│     │  │  │  │  │  │  │  │  └─ values-v22.xml
│     │  │  │  │  │  │  │  ├─ values-v23
│     │  │  │  │  │  │  │  │  └─ values-v23.xml
│     │  │  │  │  │  │  │  ├─ values-v24
│     │  │  │  │  │  │  │  │  └─ values-v24.xml
│     │  │  │  │  │  │  │  ├─ values-v25
│     │  │  │  │  │  │  │  │  └─ values-v25.xml
│     │  │  │  │  │  │  │  ├─ values-v26
│     │  │  │  │  │  │  │  │  └─ values-v26.xml
│     │  │  │  │  │  │  │  ├─ values-v28
│     │  │  │  │  │  │  │  │  └─ values-v28.xml
│     │  │  │  │  │  │  │  ├─ values-vi
│     │  │  │  │  │  │  │  │  └─ values-vi.xml
│     │  │  │  │  │  │  │  ├─ values-watch-v20
│     │  │  │  │  │  │  │  │  └─ values-watch-v20.xml
│     │  │  │  │  │  │  │  ├─ values-watch-v21
│     │  │  │  │  │  │  │  │  └─ values-watch-v21.xml
│     │  │  │  │  │  │  │  ├─ values-xlarge-v4
│     │  │  │  │  │  │  │  │  └─ values-xlarge-v4.xml
│     │  │  │  │  │  │  │  ├─ values-zh-rCN
│     │  │  │  │  │  │  │  │  └─ values-zh-rCN.xml
│     │  │  │  │  │  │  │  ├─ values-zh-rHK
│     │  │  │  │  │  │  │  │  └─ values-zh-rHK.xml
│     │  │  │  │  │  │  │  ├─ values-zh-rTW
│     │  │  │  │  │  │  │  │  └─ values-zh-rTW.xml
│     │  │  │  │  │  │  │  └─ values-zu
│     │  │  │  │  │  │  │     └─ values-zu.xml
│     │  │  │  │  │  │  ├─ merger.xml
│     │  │  │  │  │  │  └─ stripped.dir
│     │  │  │  │  │  └─ packageDebugResources
│     │  │  │  │  │     ├─ compile-file-map.properties
│     │  │  │  │  │     ├─ merged.dir
│     │  │  │  │  │     │  ├─ values
│     │  │  │  │  │     │  │  └─ values.xml
│     │  │  │  │  │     │  └─ values-night-v8
│     │  │  │  │  │     │     └─ values-night-v8.xml
│     │  │  │  │  │     ├─ merger.xml
│     │  │  │  │  │     └─ stripped.dir
│     │  │  │  │  ├─ debug-mergeJavaRes
│     │  │  │  │  │  ├─ merge-state
│     │  │  │  │  │  └─ zip-cache
│     │  │  │  │  │     ├─ +BnivVweA0AeHiqxS6yvASf+eK0=
│     │  │  │  │  │     ├─ +leHdhY25U_VgcKi_WbvsJGCga4=
│     │  │  │  │  │     ├─ +TH0zUN6tTqie9ngXNuHmobW2_8=
│     │  │  │  │  │     ├─ +xReK5EUpg2Rst+qcfjXvjSQjb0=
│     │  │  │  │  │     ├─ 0iD94NzzwyaCI9V060Pz9C8tS+M=
│     │  │  │  │  │     ├─ 0WEiVv63+vhJXtzUDuVWQV9F8Eg=
│     │  │  │  │  │     ├─ 1bJIHCeSd_Q_YF0QTESYp54s1_M=
│     │  │  │  │  │     ├─ 1QFC51_FVNkM+LJjqA2wVNnfNfY=
│     │  │  │  │  │     ├─ 1wd81hdq4g1nhV+j+dCNh4hZ06g=
│     │  │  │  │  │     ├─ 2LLiaI0e2n6FIlQIw84Bf0W9tDA=
│     │  │  │  │  │     ├─ 2nOubW9FJA7fPY+PkVtxITOudcA=
│     │  │  │  │  │     ├─ 2QKvMtN9DYFNoVzCNAQ2W_5nSr4=
│     │  │  │  │  │     ├─ 2zttAV+0fO5jh_CEeL2+p95s5dc=
│     │  │  │  │  │     ├─ 31aW0xvnWKaKPvMjjUyQ6agOlRc=
│     │  │  │  │  │     ├─ 3kR2_oXjOhmareuoQeQb5zPaMjI=
│     │  │  │  │  │     ├─ 3udBHD2t8iX8qTkhor_xjVmbHuQ=
│     │  │  │  │  │     ├─ 49uhonMlEmdfLq5dNaIbZpLDqx8=
│     │  │  │  │  │     ├─ 4WvBndAaq44N9QOPqp1f1_uiY8w=
│     │  │  │  │  │     ├─ 4YF3ZX9gYAhIYMA7oQ2_YgH8QCg=
│     │  │  │  │  │     ├─ 56U3bRa1A8FhHxeexOvCmL51OWI=
│     │  │  │  │  │     ├─ 59bqe0XmLYv+UVpcIAgeAlPb7ug=
│     │  │  │  │  │     ├─ 5rDoujZz1iTf4eaqj9hg4QU8kpE=
│     │  │  │  │  │     ├─ 5u8T_Ki+Q17E0jhKzpJZ6afJjY0=
│     │  │  │  │  │     ├─ 6637THT6Q4sF8uPMTd2T6GvGEGs=
│     │  │  │  │  │     ├─ 6N6NTR8d4pRbJG6gLqwQ9wvyXBo=
│     │  │  │  │  │     ├─ 7oxYXiIjWW57koi0GVwF4eqmmZU=
│     │  │  │  │  │     ├─ 7rMSOxmsBAf1+a8+LG2MU0y++uQ=
│     │  │  │  │  │     ├─ 8e+VI2J_28RK0zBj0NiNVos3lDI=
│     │  │  │  │  │     ├─ 8ea+OKOd2XxUVZwbVJYTB6JFjMk=
│     │  │  │  │  │     ├─ 8Xvuq_oLT0_7N8pI4YJEBKOQ6IM=
│     │  │  │  │  │     ├─ 8YhOtlVO1S7X57CtGU7lRmicIaU=
│     │  │  │  │  │     ├─ 9MaC4IEuLUEvE1oZLsSUoTGulEw=
│     │  │  │  │  │     ├─ 9MhwtgO901krnbZvdNFJX2hEsdU=
│     │  │  │  │  │     ├─ 9OUSaoaRMN773VOhKGgQmKYAZu0=
│     │  │  │  │  │     ├─ 9Yn6+e5NV5pGhXD5BZ+NZ5mS17g=
│     │  │  │  │  │     ├─ a+BntUczyMLpmwctxs+FhiGIYu0=
│     │  │  │  │  │     ├─ at58HmZ_0VU9FbSq7IWNYOhAD2Q=
│     │  │  │  │  │     ├─ aUuD8KUIHoZ8i64HHOUVcDwsJ0Q=
│     │  │  │  │  │     ├─ Bi9aEk8zNBLdMRetZaYKOT9Fctw=
│     │  │  │  │  │     ├─ BqAcaMGlBmDMwtBzRluOIfOoQKw=
│     │  │  │  │  │     ├─ CoQHCSmsaFI1OUsaaEmmDYTkrvg=
│     │  │  │  │  │     ├─ D+XSXR9I2wBCDz_fx5Hk7K4jk2o=
│     │  │  │  │  │     ├─ d1pIklthZNYnkdqen0YoBDKAWsI=
│     │  │  │  │  │     ├─ d4Jn+ByjtA5DkrpfxLksKnmO6n8=
│     │  │  │  │  │     ├─ D78hvLr88Xhy3E0kmiFPcSDlJNk=
│     │  │  │  │  │     ├─ d7NFVur+68TVkwBLNikCScQSkUA=
│     │  │  │  │  │     ├─ dgCMF1WFfqBAZu55ZgJbfAvewKo=
│     │  │  │  │  │     ├─ DgtNK2JKMgbb59tr88eBwCfrBaQ=
│     │  │  │  │  │     ├─ Dmpqwx8rdbijDrUC5i2wCCWmIEY=
│     │  │  │  │  │     ├─ dtbHYamAfAhFhE9EVj577c+33yg=
│     │  │  │  │  │     ├─ dYLoh0bBW_jvkvaoU7Ip_OB+9ig=
│     │  │  │  │  │     ├─ e6WW1bPhKXOU8lY8iJxP3sRML2I=
│     │  │  │  │  │     ├─ eK6qzpskykfO_osawOLQXMhIZ0U=
│     │  │  │  │  │     ├─ eWh3repX153_Ot1zvRe6kai4+dk=
│     │  │  │  │  │     ├─ f1DlYxlfbioBOxv2MVDNxIiOf3E=
│     │  │  │  │  │     ├─ f1Z+rK5MmSqddIj+a5tMLzWE0ZQ=
│     │  │  │  │  │     ├─ f5oDwcSTx5vDF9rtKo_jxsvNZaM=
│     │  │  │  │  │     ├─ FE0Ib1auvqI+mVjey1qPALh7uGQ=
│     │  │  │  │  │     ├─ feQzeiilL_F_UV6Mc9lRdQYnh6w=
│     │  │  │  │  │     ├─ g0R+z_I8ynFEB+jg4NXa_o3nYF4=
│     │  │  │  │  │     ├─ gDcYbll5srPwCJU7gGK1by8TQTI=
│     │  │  │  │  │     ├─ gJxCnwd4l7MW59CBDlDY6oRv6Og=
│     │  │  │  │  │     ├─ GtfPA+n+ttz9ERPIittbek+ku10=
│     │  │  │  │  │     ├─ Gv3J6U965wh2rRp_LgXJhOjE7tk=
│     │  │  │  │  │     ├─ GvxsXaPwg8iKU477+GIuJTTT2bg=
│     │  │  │  │  │     ├─ H3unIHR5Io6sIHz9tMfwyxeCzu8=
│     │  │  │  │  │     ├─ HaNIDYlngIpLTaWd5oSTTCZFJkQ=
│     │  │  │  │  │     ├─ HuZIM0ZqJKgKHGOtAlf3ICMBqsg=
│     │  │  │  │  │     ├─ hWmQ6R035mrQ2BCgZdPxPYCjjhE=
│     │  │  │  │  │     ├─ hWysnkC3zVQ9766qqP+Rk2oPMdU=
│     │  │  │  │  │     ├─ hXug+dynh_CvU2eksgEX2OjKndI=
│     │  │  │  │  │     ├─ IzvGjPDlcGE_Gg0fUxmzeoGXMRg=
│     │  │  │  │  │     ├─ Jjdo48pqiB7aQlo4wnkMtRTMcaU=
│     │  │  │  │  │     ├─ JvrsgoK5sOT+GNmlq15_kd3+CQg=
│     │  │  │  │  │     ├─ JXsLGrAQcleF8MF4ezaKXVREh6g=
│     │  │  │  │  │     ├─ kFa+GEGEg8uq8ddgRSkWUf6TYoM=
│     │  │  │  │  │     ├─ kneLOruVtRUefoNdC_b9B5WpGjQ=
│     │  │  │  │  │     ├─ kZvsAvVDP74OcteA6Ex8Q+unPLM=
│     │  │  │  │  │     ├─ lL97TRq1YHxhDo4n36qxKM18P+E=
│     │  │  │  │  │     ├─ lW0ky2Vke3NXlrrtMhyssOg7Xxo=
│     │  │  │  │  │     ├─ m+EhHFIdHG3pqp2kQkrgnzrX+xA=
│     │  │  │  │  │     ├─ M4Z8aA2M5BQd9cKgmOKhahj0fuI=
│     │  │  │  │  │     ├─ MHokqP94v3Nb71uok4bbgBXu1eo=
│     │  │  │  │  │     ├─ nb3W3EI+Ky0q2QgybrvsPzRGDdc=
│     │  │  │  │  │     ├─ nCdN2Uo96TnDNZPYh5D0P969uAk=
│     │  │  │  │  │     ├─ nF+BaiXLckSg8seZe4qco8ARNJw=
│     │  │  │  │  │     ├─ ng_A_MLbhJqJFmfxwBsDBZlQbEE=
│     │  │  │  │  │     ├─ NU62LfwFR9w4Rc5EueFI0fn7lSQ=
│     │  │  │  │  │     ├─ nYwcFWJHtczUdXJKOYFtPeJPOzA=
│     │  │  │  │  │     ├─ N_LcozePiJIdTwzTqaKs+iQZn+A=
│     │  │  │  │  │     ├─ phRG8rga2eJXvmo46Fdpc8G6On4=
│     │  │  │  │  │     ├─ pKbh_KznGk7+qmggn57sn5UX7u8=
│     │  │  │  │  │     ├─ pkLX4RJPJKr_Vn2BR+NDl5ygdb4=
│     │  │  │  │  │     ├─ PYC2XA0ibl17ww7HlYIYH8g8RqM=
│     │  │  │  │  │     ├─ q3hT0woG16h3Rd979JtoDj8bZag=
│     │  │  │  │  │     ├─ QdAxsrs+QZTu+mKG4uUrH73aC2w=
│     │  │  │  │  │     ├─ r4HSfJYcKfi9357as+p5X8AHY7A=
│     │  │  │  │  │     ├─ rbcDvsEAiHCrVkk1gOwDF91nJKk=
│     │  │  │  │  │     ├─ s55bgBPqNdOdCFSeObp3cJhptFU=
│     │  │  │  │  │     ├─ S8YZVnhJndW6Y7C28PkvWMuUGFU=
│     │  │  │  │  │     ├─ sJ1Z+LilgHVRMvBufR7gXoqO5OU=
│     │  │  │  │  │     ├─ spxzw73MyHCkvBxOzjVJA25ZNik=
│     │  │  │  │  │     ├─ Tasrc3Y1Gj+xJU0g49fgb+AVUTY=
│     │  │  │  │  │     ├─ TC0rz0aAWqGJLyYnCfY8tgLrh+4=
│     │  │  │  │  │     ├─ tIjcEdaqUznI1031TiWZQ_MxQ7A=
│     │  │  │  │  │     ├─ TqOMLNi3Ynmhlmj5ikOHMCRsw7I=
│     │  │  │  │  │     ├─ UhUFPhAG93jQJFle1yk5vpGnmYk=
│     │  │  │  │  │     ├─ UkHlvJh0BoT_kLMoHALWrqFWsCA=
│     │  │  │  │  │     ├─ UNR93Ulc79vfS8wWXhmOvbiizVw=
│     │  │  │  │  │     ├─ UVOYfyTFV7AStM3_TLiky4sG9YA=
│     │  │  │  │  │     ├─ V4GsDEaebXKR0eEoIG23fN2gmA4=
│     │  │  │  │  │     ├─ vEsScS5yC4zQChA24jcBXWMdjAc=
│     │  │  │  │  │     ├─ vNU9LAvk0O8aOuiDW9EKzR+dkYE=
│     │  │  │  │  │     ├─ VQ6hjtwYTNMrrti7GRSbadEiIQ4=
│     │  │  │  │  │     ├─ vR6GWTNy6eMy00H36BLDCDCHV1s=
│     │  │  │  │  │     ├─ vUvFM6A5sl3HZzgZCKSZ8TBwMwM=
│     │  │  │  │  │     ├─ WnJlYMNtUg8wSrnn_dNwtpu44Cs=
│     │  │  │  │  │     ├─ wNnocPlgPhTp1ycUn2JSIjX8XZQ=
│     │  │  │  │  │     ├─ wofoi442XvPVGtnqtsePRLy0hWc=
│     │  │  │  │  │     ├─ WVqGecBCyDfLhE60RDdD4ye82ZM=
│     │  │  │  │  │     ├─ wWH41jLKME_1YuRByqS0zIu91W8=
│     │  │  │  │  │     ├─ Wx0csA9dpcHAF3DfUIXfQksRRFM=
│     │  │  │  │  │     ├─ XBYwoK4oXucxeq6_RNQpAkChLU0=
│     │  │  │  │  │     ├─ XR0rCSzCv18Rag4DLVvTWFnRqQ0=
│     │  │  │  │  │     ├─ XVpPLWilGw+QB2HALk7TugZ0Ze8=
│     │  │  │  │  │     ├─ y7wPoR7sQXMtMAr_VE3d_a6KI98=
│     │  │  │  │  │     ├─ YDf6g0sFlAOwsCoAZx9XyKwQ1bw=
│     │  │  │  │  │     ├─ YPXvNSh+eFJXEbLXOTAtx58dZlI=
│     │  │  │  │  │     ├─ Yqf9u1fogB6+GH5WGFfSkp6NKro=
│     │  │  │  │  │     ├─ yuLP74xfEQ+G3fbTUUzBwIJNi20=
│     │  │  │  │  │     ├─ YxhCrFP6CSBd8sEoFV1F5frlIK0=
│     │  │  │  │  │     ├─ z4_6+_BeIqgDxC4OaRxwYcbk2qY=
│     │  │  │  │  │     ├─ zckUI2Vi6zkc0VEZS0uoBqV8AtQ=
│     │  │  │  │  │     ├─ zEqJ7T2paAQOp2J5YzyS7Wx+cRc=
│     │  │  │  │  │     ├─ zJhA1iossHJuRlcYGwC7arO0pjM=
│     │  │  │  │  │     └─ _BEHK9bJkIkQnIGAo24JN2VhCM8=
│     │  │  │  │  ├─ mergeDebugAssets
│     │  │  │  │  │  └─ merger.xml
│     │  │  │  │  ├─ mergeDebugJniLibFolders
│     │  │  │  │  │  └─ merger.xml
│     │  │  │  │  ├─ mergeDebugShaders
│     │  │  │  │  │  └─ merger.xml
│     │  │  │  │  └─ packageDebug
│     │  │  │  │     └─ tmp
│     │  │  │  │        └─ debug
│     │  │  │  │           ├─ dex-renamer-state.txt
│     │  │  │  │           └─ zip-cache
│     │  │  │  │              ├─ androidResources
│     │  │  │  │              └─ javaResources0
│     │  │  │  ├─ javac
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ compileDebugJavaWithJavac
│     │  │  │  │        └─ classes
│     │  │  │  │           └─ io
│     │  │  │  │              └─ flutter
│     │  │  │  │                 └─ plugins
│     │  │  │  │                    └─ GeneratedPluginRegistrant.class
│     │  │  │  ├─ java_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugJavaRes
│     │  │  │  │        └─ out
│     │  │  │  │           ├─ com
│     │  │  │  │           │  └─ example
│     │  │  │  │           │     └─ sdgp
│     │  │  │  │           └─ META-INF
│     │  │  │  │              └─ app_debug.kotlin_module
│     │  │  │  ├─ l8_art_profile
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ l8DexDesugarLibDebug
│     │  │  │  ├─ linked_resources_binary_format
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugResources
│     │  │  │  │        ├─ linked-resources-binary-format-debug.ap_
│     │  │  │  │        └─ output-metadata.json
│     │  │  │  ├─ local_only_symbol_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ parseDebugLocalResources
│     │  │  │  │        └─ R-def.txt
│     │  │  │  ├─ manifest_merge_blame_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugMainManifest
│     │  │  │  │        └─ manifest-merger-blame-debug-report.txt
│     │  │  │  ├─ merged_java_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugJavaResource
│     │  │  │  │        └─ base.jar
│     │  │  │  ├─ merged_jni_libs
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugJniLibFolders
│     │  │  │  │        └─ out
│     │  │  │  ├─ merged_manifest
│     │  │  │  │  └─ debug
│     │  │  │  │     ├─ outputDebugAppLinkSettings
│     │  │  │  │     │  └─ AndroidManifest.xml
│     │  │  │  │     └─ processDebugMainManifest
│     │  │  │  │        └─ AndroidManifest.xml
│     │  │  │  ├─ merged_manifests
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        ├─ AndroidManifest.xml
│     │  │  │  │        └─ output-metadata.json
│     │  │  │  ├─ merged_native_libs
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugNativeLibs
│     │  │  │  │        └─ out
│     │  │  │  │           └─ lib
│     │  │  │  │              ├─ arm64-v8a
│     │  │  │  │              │  └─ libdatastore_shared_counter.so
│     │  │  │  │              ├─ armeabi-v7a
│     │  │  │  │              │  └─ libdatastore_shared_counter.so
│     │  │  │  │              ├─ x86
│     │  │  │  │              │  └─ libdatastore_shared_counter.so
│     │  │  │  │              └─ x86_64
│     │  │  │  │                 ├─ libdatastore_shared_counter.so
│     │  │  │  │                 └─ libflutter.so
│     │  │  │  ├─ merged_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugResources
│     │  │  │  │        ├─ drawable-v21_launch_background.xml.flat
│     │  │  │  │        ├─ mipmap-hdpi_ic_launcher.png.flat
│     │  │  │  │        ├─ mipmap-mdpi_ic_launcher.png.flat
│     │  │  │  │        ├─ mipmap-xhdpi_ic_launcher.png.flat
│     │  │  │  │        ├─ mipmap-xxhdpi_ic_launcher.png.flat
│     │  │  │  │        ├─ mipmap-xxxhdpi_ic_launcher.png.flat
│     │  │  │  │        ├─ values-af_values-af.arsc.flat
│     │  │  │  │        ├─ values-am_values-am.arsc.flat
│     │  │  │  │        ├─ values-ar_values-ar.arsc.flat
│     │  │  │  │        ├─ values-as_values-as.arsc.flat
│     │  │  │  │        ├─ values-az_values-az.arsc.flat
│     │  │  │  │        ├─ values-b+sr+Latn_values-b+sr+Latn.arsc.flat
│     │  │  │  │        ├─ values-be_values-be.arsc.flat
│     │  │  │  │        ├─ values-bg_values-bg.arsc.flat
│     │  │  │  │        ├─ values-bn_values-bn.arsc.flat
│     │  │  │  │        ├─ values-bs_values-bs.arsc.flat
│     │  │  │  │        ├─ values-ca_values-ca.arsc.flat
│     │  │  │  │        ├─ values-cs_values-cs.arsc.flat
│     │  │  │  │        ├─ values-da_values-da.arsc.flat
│     │  │  │  │        ├─ values-de_values-de.arsc.flat
│     │  │  │  │        ├─ values-el_values-el.arsc.flat
│     │  │  │  │        ├─ values-en-rAU_values-en-rAU.arsc.flat
│     │  │  │  │        ├─ values-en-rCA_values-en-rCA.arsc.flat
│     │  │  │  │        ├─ values-en-rGB_values-en-rGB.arsc.flat
│     │  │  │  │        ├─ values-en-rIN_values-en-rIN.arsc.flat
│     │  │  │  │        ├─ values-en-rXC_values-en-rXC.arsc.flat
│     │  │  │  │        ├─ values-es-rUS_values-es-rUS.arsc.flat
│     │  │  │  │        ├─ values-es_values-es.arsc.flat
│     │  │  │  │        ├─ values-et_values-et.arsc.flat
│     │  │  │  │        ├─ values-eu_values-eu.arsc.flat
│     │  │  │  │        ├─ values-fa_values-fa.arsc.flat
│     │  │  │  │        ├─ values-fi_values-fi.arsc.flat
│     │  │  │  │        ├─ values-fr-rCA_values-fr-rCA.arsc.flat
│     │  │  │  │        ├─ values-fr_values-fr.arsc.flat
│     │  │  │  │        ├─ values-gl_values-gl.arsc.flat
│     │  │  │  │        ├─ values-gu_values-gu.arsc.flat
│     │  │  │  │        ├─ values-h720dp-v13_values-h720dp-v13.arsc.flat
│     │  │  │  │        ├─ values-hdpi-v4_values-hdpi-v4.arsc.flat
│     │  │  │  │        ├─ values-hi_values-hi.arsc.flat
│     │  │  │  │        ├─ values-hr_values-hr.arsc.flat
│     │  │  │  │        ├─ values-hu_values-hu.arsc.flat
│     │  │  │  │        ├─ values-hy_values-hy.arsc.flat
│     │  │  │  │        ├─ values-in_values-in.arsc.flat
│     │  │  │  │        ├─ values-is_values-is.arsc.flat
│     │  │  │  │        ├─ values-it_values-it.arsc.flat
│     │  │  │  │        ├─ values-iw_values-iw.arsc.flat
│     │  │  │  │        ├─ values-ja_values-ja.arsc.flat
│     │  │  │  │        ├─ values-ka_values-ka.arsc.flat
│     │  │  │  │        ├─ values-kk_values-kk.arsc.flat
│     │  │  │  │        ├─ values-km_values-km.arsc.flat
│     │  │  │  │        ├─ values-kn_values-kn.arsc.flat
│     │  │  │  │        ├─ values-ko_values-ko.arsc.flat
│     │  │  │  │        ├─ values-ky_values-ky.arsc.flat
│     │  │  │  │        ├─ values-land_values-land.arsc.flat
│     │  │  │  │        ├─ values-large-v4_values-large-v4.arsc.flat
│     │  │  │  │        ├─ values-ldltr-v21_values-ldltr-v21.arsc.flat
│     │  │  │  │        ├─ values-lo_values-lo.arsc.flat
│     │  │  │  │        ├─ values-lt_values-lt.arsc.flat
│     │  │  │  │        ├─ values-lv_values-lv.arsc.flat
│     │  │  │  │        ├─ values-mk_values-mk.arsc.flat
│     │  │  │  │        ├─ values-ml_values-ml.arsc.flat
│     │  │  │  │        ├─ values-mn_values-mn.arsc.flat
│     │  │  │  │        ├─ values-mr_values-mr.arsc.flat
│     │  │  │  │        ├─ values-ms_values-ms.arsc.flat
│     │  │  │  │        ├─ values-my_values-my.arsc.flat
│     │  │  │  │        ├─ values-nb_values-nb.arsc.flat
│     │  │  │  │        ├─ values-ne_values-ne.arsc.flat
│     │  │  │  │        ├─ values-night-v8_values-night-v8.arsc.flat
│     │  │  │  │        ├─ values-nl_values-nl.arsc.flat
│     │  │  │  │        ├─ values-or_values-or.arsc.flat
│     │  │  │  │        ├─ values-pa_values-pa.arsc.flat
│     │  │  │  │        ├─ values-pl_values-pl.arsc.flat
│     │  │  │  │        ├─ values-port_values-port.arsc.flat
│     │  │  │  │        ├─ values-pt-rBR_values-pt-rBR.arsc.flat
│     │  │  │  │        ├─ values-pt-rPT_values-pt-rPT.arsc.flat
│     │  │  │  │        ├─ values-pt_values-pt.arsc.flat
│     │  │  │  │        ├─ values-ro_values-ro.arsc.flat
│     │  │  │  │        ├─ values-ru_values-ru.arsc.flat
│     │  │  │  │        ├─ values-si_values-si.arsc.flat
│     │  │  │  │        ├─ values-sk_values-sk.arsc.flat
│     │  │  │  │        ├─ values-sl_values-sl.arsc.flat
│     │  │  │  │        ├─ values-sq_values-sq.arsc.flat
│     │  │  │  │        ├─ values-sr_values-sr.arsc.flat
│     │  │  │  │        ├─ values-sv_values-sv.arsc.flat
│     │  │  │  │        ├─ values-sw360dp-v13_values-sw360dp-v13.arsc.flat
│     │  │  │  │        ├─ values-sw600dp-v13_values-sw600dp-v13.arsc.flat
│     │  │  │  │        ├─ values-sw_values-sw.arsc.flat
│     │  │  │  │        ├─ values-ta_values-ta.arsc.flat
│     │  │  │  │        ├─ values-te_values-te.arsc.flat
│     │  │  │  │        ├─ values-th_values-th.arsc.flat
│     │  │  │  │        ├─ values-tl_values-tl.arsc.flat
│     │  │  │  │        ├─ values-tr_values-tr.arsc.flat
│     │  │  │  │        ├─ values-uk_values-uk.arsc.flat
│     │  │  │  │        ├─ values-ur_values-ur.arsc.flat
│     │  │  │  │        ├─ values-uz_values-uz.arsc.flat
│     │  │  │  │        ├─ values-v16_values-v16.arsc.flat
│     │  │  │  │        ├─ values-v17_values-v17.arsc.flat
│     │  │  │  │        ├─ values-v18_values-v18.arsc.flat
│     │  │  │  │        ├─ values-v21_values-v21.arsc.flat
│     │  │  │  │        ├─ values-v22_values-v22.arsc.flat
│     │  │  │  │        ├─ values-v23_values-v23.arsc.flat
│     │  │  │  │        ├─ values-v24_values-v24.arsc.flat
│     │  │  │  │        ├─ values-v25_values-v25.arsc.flat
│     │  │  │  │        ├─ values-v26_values-v26.arsc.flat
│     │  │  │  │        ├─ values-v28_values-v28.arsc.flat
│     │  │  │  │        ├─ values-vi_values-vi.arsc.flat
│     │  │  │  │        ├─ values-watch-v20_values-watch-v20.arsc.flat
│     │  │  │  │        ├─ values-watch-v21_values-watch-v21.arsc.flat
│     │  │  │  │        ├─ values-xlarge-v4_values-xlarge-v4.arsc.flat
│     │  │  │  │        ├─ values-zh-rCN_values-zh-rCN.arsc.flat
│     │  │  │  │        ├─ values-zh-rHK_values-zh-rHK.arsc.flat
│     │  │  │  │        ├─ values-zh-rTW_values-zh-rTW.arsc.flat
│     │  │  │  │        ├─ values-zu_values-zu.arsc.flat
│     │  │  │  │        └─ values_values.arsc.flat
│     │  │  │  ├─ merged_res_blame_folder
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugResources
│     │  │  │  │        └─ out
│     │  │  │  │           ├─ multi-v2
│     │  │  │  │           │  ├─ mergeDebugResources.json
│     │  │  │  │           │  ├─ values-af.json
│     │  │  │  │           │  ├─ values-am.json
│     │  │  │  │           │  ├─ values-ar.json
│     │  │  │  │           │  ├─ values-as.json
│     │  │  │  │           │  ├─ values-az.json
│     │  │  │  │           │  ├─ values-b+sr+Latn.json
│     │  │  │  │           │  ├─ values-be.json
│     │  │  │  │           │  ├─ values-bg.json
│     │  │  │  │           │  ├─ values-bn.json
│     │  │  │  │           │  ├─ values-bs.json
│     │  │  │  │           │  ├─ values-ca.json
│     │  │  │  │           │  ├─ values-cs.json
│     │  │  │  │           │  ├─ values-da.json
│     │  │  │  │           │  ├─ values-de.json
│     │  │  │  │           │  ├─ values-el.json
│     │  │  │  │           │  ├─ values-en-rAU.json
│     │  │  │  │           │  ├─ values-en-rCA.json
│     │  │  │  │           │  ├─ values-en-rGB.json
│     │  │  │  │           │  ├─ values-en-rIN.json
│     │  │  │  │           │  ├─ values-en-rXC.json
│     │  │  │  │           │  ├─ values-es-rUS.json
│     │  │  │  │           │  ├─ values-es.json
│     │  │  │  │           │  ├─ values-et.json
│     │  │  │  │           │  ├─ values-eu.json
│     │  │  │  │           │  ├─ values-fa.json
│     │  │  │  │           │  ├─ values-fi.json
│     │  │  │  │           │  ├─ values-fr-rCA.json
│     │  │  │  │           │  ├─ values-fr.json
│     │  │  │  │           │  ├─ values-gl.json
│     │  │  │  │           │  ├─ values-gu.json
│     │  │  │  │           │  ├─ values-h720dp-v13.json
│     │  │  │  │           │  ├─ values-hdpi-v4.json
│     │  │  │  │           │  ├─ values-hi.json
│     │  │  │  │           │  ├─ values-hr.json
│     │  │  │  │           │  ├─ values-hu.json
│     │  │  │  │           │  ├─ values-hy.json
│     │  │  │  │           │  ├─ values-in.json
│     │  │  │  │           │  ├─ values-is.json
│     │  │  │  │           │  ├─ values-it.json
│     │  │  │  │           │  ├─ values-iw.json
│     │  │  │  │           │  ├─ values-ja.json
│     │  │  │  │           │  ├─ values-ka.json
│     │  │  │  │           │  ├─ values-kk.json
│     │  │  │  │           │  ├─ values-km.json
│     │  │  │  │           │  ├─ values-kn.json
│     │  │  │  │           │  ├─ values-ko.json
│     │  │  │  │           │  ├─ values-ky.json
│     │  │  │  │           │  ├─ values-land.json
│     │  │  │  │           │  ├─ values-large-v4.json
│     │  │  │  │           │  ├─ values-ldltr-v21.json
│     │  │  │  │           │  ├─ values-lo.json
│     │  │  │  │           │  ├─ values-lt.json
│     │  │  │  │           │  ├─ values-lv.json
│     │  │  │  │           │  ├─ values-mk.json
│     │  │  │  │           │  ├─ values-ml.json
│     │  │  │  │           │  ├─ values-mn.json
│     │  │  │  │           │  ├─ values-mr.json
│     │  │  │  │           │  ├─ values-ms.json
│     │  │  │  │           │  ├─ values-my.json
│     │  │  │  │           │  ├─ values-nb.json
│     │  │  │  │           │  ├─ values-ne.json
│     │  │  │  │           │  ├─ values-night-v8.json
│     │  │  │  │           │  ├─ values-nl.json
│     │  │  │  │           │  ├─ values-or.json
│     │  │  │  │           │  ├─ values-pa.json
│     │  │  │  │           │  ├─ values-pl.json
│     │  │  │  │           │  ├─ values-port.json
│     │  │  │  │           │  ├─ values-pt-rBR.json
│     │  │  │  │           │  ├─ values-pt-rPT.json
│     │  │  │  │           │  ├─ values-pt.json
│     │  │  │  │           │  ├─ values-ro.json
│     │  │  │  │           │  ├─ values-ru.json
│     │  │  │  │           │  ├─ values-si.json
│     │  │  │  │           │  ├─ values-sk.json
│     │  │  │  │           │  ├─ values-sl.json
│     │  │  │  │           │  ├─ values-sq.json
│     │  │  │  │           │  ├─ values-sr.json
│     │  │  │  │           │  ├─ values-sv.json
│     │  │  │  │           │  ├─ values-sw.json
│     │  │  │  │           │  ├─ values-sw360dp-v13.json
│     │  │  │  │           │  ├─ values-sw600dp-v13.json
│     │  │  │  │           │  ├─ values-ta.json
│     │  │  │  │           │  ├─ values-te.json
│     │  │  │  │           │  ├─ values-th.json
│     │  │  │  │           │  ├─ values-tl.json
│     │  │  │  │           │  ├─ values-tr.json
│     │  │  │  │           │  ├─ values-uk.json
│     │  │  │  │           │  ├─ values-ur.json
│     │  │  │  │           │  ├─ values-uz.json
│     │  │  │  │           │  ├─ values-v16.json
│     │  │  │  │           │  ├─ values-v17.json
│     │  │  │  │           │  ├─ values-v18.json
│     │  │  │  │           │  ├─ values-v21.json
│     │  │  │  │           │  ├─ values-v22.json
│     │  │  │  │           │  ├─ values-v23.json
│     │  │  │  │           │  ├─ values-v24.json
│     │  │  │  │           │  ├─ values-v25.json
│     │  │  │  │           │  ├─ values-v26.json
│     │  │  │  │           │  ├─ values-v28.json
│     │  │  │  │           │  ├─ values-vi.json
│     │  │  │  │           │  ├─ values-watch-v20.json
│     │  │  │  │           │  ├─ values-watch-v21.json
│     │  │  │  │           │  ├─ values-xlarge-v4.json
│     │  │  │  │           │  ├─ values-zh-rCN.json
│     │  │  │  │           │  ├─ values-zh-rHK.json
│     │  │  │  │           │  ├─ values-zh-rTW.json
│     │  │  │  │           │  ├─ values-zu.json
│     │  │  │  │           │  └─ values.json
│     │  │  │  │           └─ single
│     │  │  │  │              └─ mergeDebugResources.json
│     │  │  │  ├─ merged_shaders
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugShaders
│     │  │  │  │        └─ out
│     │  │  │  ├─ merged_test_only_native_libs
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugNativeLibs
│     │  │  │  │        └─ out
│     │  │  │  ├─ mixed_scope_dex_archive
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ dexBuilderDebug
│     │  │  │  │        └─ out
│     │  │  │  ├─ navigation_json
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDeepLinksDebug
│     │  │  │  │        └─ navigation.json
│     │  │  │  ├─ nested_resources_validation_report
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugResources
│     │  │  │  │        └─ nestedResourcesValidationReport.txt
│     │  │  │  ├─ packaged_manifests
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifestForPackage
│     │  │  │  │        ├─ AndroidManifest.xml
│     │  │  │  │        └─ output-metadata.json
│     │  │  │  ├─ packaged_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  │        ├─ drawable-v21
│     │  │  │  │        │  └─ launch_background.xml
│     │  │  │  │        ├─ mipmap-hdpi-v4
│     │  │  │  │        │  └─ ic_launcher.png
│     │  │  │  │        ├─ mipmap-mdpi-v4
│     │  │  │  │        │  └─ ic_launcher.png
│     │  │  │  │        ├─ mipmap-xhdpi-v4
│     │  │  │  │        │  └─ ic_launcher.png
│     │  │  │  │        ├─ mipmap-xxhdpi-v4
│     │  │  │  │        │  └─ ic_launcher.png
│     │  │  │  │        ├─ mipmap-xxxhdpi-v4
│     │  │  │  │        │  └─ ic_launcher.png
│     │  │  │  │        ├─ values
│     │  │  │  │        │  └─ values.xml
│     │  │  │  │        └─ values-night-v8
│     │  │  │  │           └─ values-night-v8.xml
│     │  │  │  ├─ project_dex_archive
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ dexBuilderDebug
│     │  │  │  │        └─ out
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_0.jar
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_1.jar
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_10.jar
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_11.jar
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_12.jar
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_13.jar
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_14.jar
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_15.jar
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_2.jar
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_3.jar
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_4.jar
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_5.jar
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_6.jar
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_7.jar
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_8.jar
│     │  │  │  │           ├─ b40971e737e4983766898d2934e554f6d8a158afef24bd43ae951a21b722a304_9.jar
│     │  │  │  │           ├─ com
│     │  │  │  │           │  └─ example
│     │  │  │  │           │     └─ sdgp
│     │  │  │  │           │        └─ MainActivity.dex
│     │  │  │  │           └─ io
│     │  │  │  │              └─ flutter
│     │  │  │  │                 └─ plugins
│     │  │  │  │                    └─ GeneratedPluginRegistrant.dex
│     │  │  │  ├─ runtime_symbol_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugResources
│     │  │  │  │        └─ R.txt
│     │  │  │  ├─ signing_config_versions
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ writeDebugSigningConfigVersions
│     │  │  │  │        └─ signing-config-versions.json
│     │  │  │  ├─ source_set_path_map
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mapDebugSourceSetPaths
│     │  │  │  │        └─ file-map.txt
│     │  │  │  ├─ stable_resource_ids_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugResources
│     │  │  │  │        └─ stableIds.txt
│     │  │  │  ├─ stripped_native_libs
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ stripDebugDebugSymbols
│     │  │  │  │        └─ out
│     │  │  │  │           └─ lib
│     │  │  │  │              ├─ arm64-v8a
│     │  │  │  │              │  └─ libdatastore_shared_counter.so
│     │  │  │  │              ├─ armeabi-v7a
│     │  │  │  │              │  └─ libdatastore_shared_counter.so
│     │  │  │  │              ├─ x86
│     │  │  │  │              │  └─ libdatastore_shared_counter.so
│     │  │  │  │              └─ x86_64
│     │  │  │  │                 ├─ libdatastore_shared_counter.so
│     │  │  │  │                 └─ libflutter.so
│     │  │  │  ├─ sub_project_dex_archive
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ dexBuilderDebug
│     │  │  │  │        └─ out
│     │  │  │  ├─ symbol_list_with_package_name
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugResources
│     │  │  │  │        └─ package-aware-r.txt
│     │  │  │  └─ validate_signing_config
│     │  │  │     └─ debug
│     │  │  │        └─ validateSigningDebug
│     │  │  ├─ kotlin
│     │  │  │  └─ compileDebugKotlin
│     │  │  │     ├─ cacheable
│     │  │  │     │  ├─ caches-jvm
│     │  │  │     │  │  ├─ inputs
│     │  │  │     │  │  │  ├─ source-to-output.tab
│     │  │  │     │  │  │  ├─ source-to-output.tab.keystream
│     │  │  │     │  │  │  ├─ source-to-output.tab.keystream.len
│     │  │  │     │  │  │  ├─ source-to-output.tab.len
│     │  │  │     │  │  │  ├─ source-to-output.tab.values.at
│     │  │  │     │  │  │  ├─ source-to-output.tab_i
│     │  │  │     │  │  │  └─ source-to-output.tab_i.len
│     │  │  │     │  │  ├─ jvm
│     │  │  │     │  │  │  └─ kotlin
│     │  │  │     │  │  │     ├─ class-attributes.tab
│     │  │  │     │  │  │     ├─ class-attributes.tab.keystream
│     │  │  │     │  │  │     ├─ class-attributes.tab.keystream.len
│     │  │  │     │  │  │     ├─ class-attributes.tab.len
│     │  │  │     │  │  │     ├─ class-attributes.tab.values.at
│     │  │  │     │  │  │     ├─ class-attributes.tab_i
│     │  │  │     │  │  │     ├─ class-attributes.tab_i.len
│     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab
│     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab.keystream
│     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab.keystream.len
│     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab.len
│     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab.values.at
│     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab_i
│     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab_i.len
│     │  │  │     │  │  │     ├─ internal-name-to-source.tab
│     │  │  │     │  │  │     ├─ internal-name-to-source.tab.keystream
│     │  │  │     │  │  │     ├─ internal-name-to-source.tab.keystream.len
│     │  │  │     │  │  │     ├─ internal-name-to-source.tab.len
│     │  │  │     │  │  │     ├─ internal-name-to-source.tab.values.at
│     │  │  │     │  │  │     ├─ internal-name-to-source.tab_i
│     │  │  │     │  │  │     ├─ internal-name-to-source.tab_i.len
│     │  │  │     │  │  │     ├─ proto.tab
│     │  │  │     │  │  │     ├─ proto.tab.keystream
│     │  │  │     │  │  │     ├─ proto.tab.keystream.len
│     │  │  │     │  │  │     ├─ proto.tab.len
│     │  │  │     │  │  │     ├─ proto.tab.values.at
│     │  │  │     │  │  │     ├─ proto.tab_i
│     │  │  │     │  │  │     ├─ proto.tab_i.len
│     │  │  │     │  │  │     ├─ source-to-classes.tab
│     │  │  │     │  │  │     ├─ source-to-classes.tab.keystream
│     │  │  │     │  │  │     ├─ source-to-classes.tab.keystream.len
│     │  │  │     │  │  │     ├─ source-to-classes.tab.len
│     │  │  │     │  │  │     ├─ source-to-classes.tab.values.at
│     │  │  │     │  │  │     ├─ source-to-classes.tab_i
│     │  │  │     │  │  │     ├─ source-to-classes.tab_i.len
│     │  │  │     │  │  │     ├─ subtypes.tab
│     │  │  │     │  │  │     ├─ subtypes.tab.keystream
│     │  │  │     │  │  │     ├─ subtypes.tab.keystream.len
│     │  │  │     │  │  │     ├─ subtypes.tab.len
│     │  │  │     │  │  │     ├─ subtypes.tab.values.at
│     │  │  │     │  │  │     ├─ subtypes.tab_i
│     │  │  │     │  │  │     ├─ subtypes.tab_i.len
│     │  │  │     │  │  │     ├─ supertypes.tab
│     │  │  │     │  │  │     ├─ supertypes.tab.keystream
│     │  │  │     │  │  │     ├─ supertypes.tab.keystream.len
│     │  │  │     │  │  │     ├─ supertypes.tab.len
│     │  │  │     │  │  │     ├─ supertypes.tab.values.at
│     │  │  │     │  │  │     ├─ supertypes.tab_i
│     │  │  │     │  │  │     └─ supertypes.tab_i.len
│     │  │  │     │  │  └─ lookups
│     │  │  │     │  │     ├─ counters.tab
│     │  │  │     │  │     ├─ file-to-id.tab
│     │  │  │     │  │     ├─ file-to-id.tab.keystream
│     │  │  │     │  │     ├─ file-to-id.tab.keystream.len
│     │  │  │     │  │     ├─ file-to-id.tab.len
│     │  │  │     │  │     ├─ file-to-id.tab.values.at
│     │  │  │     │  │     ├─ file-to-id.tab_i
│     │  │  │     │  │     ├─ file-to-id.tab_i.len
│     │  │  │     │  │     ├─ id-to-file.tab
│     │  │  │     │  │     ├─ id-to-file.tab.keystream
│     │  │  │     │  │     ├─ id-to-file.tab.keystream.len
│     │  │  │     │  │     ├─ id-to-file.tab.len
│     │  │  │     │  │     ├─ id-to-file.tab.values.at
│     │  │  │     │  │     ├─ id-to-file.tab_i.len
│     │  │  │     │  │     ├─ lookups.tab
│     │  │  │     │  │     ├─ lookups.tab.keystream
│     │  │  │     │  │     ├─ lookups.tab.keystream.len
│     │  │  │     │  │     ├─ lookups.tab.len
│     │  │  │     │  │     ├─ lookups.tab.values.at
│     │  │  │     │  │     ├─ lookups.tab_i
│     │  │  │     │  │     └─ lookups.tab_i.len
│     │  │  │     │  └─ last-build.bin
│     │  │  │     ├─ classpath-snapshot
│     │  │  │     │  └─ shrunk-classpath-snapshot.bin
│     │  │  │     └─ local-state
│     │  │  ├─ outputs
│     │  │  │  ├─ apk
│     │  │  │  │  └─ debug
│     │  │  │  │     ├─ app-debug.apk
│     │  │  │  │     └─ output-metadata.json
│     │  │  │  ├─ flutter-apk
│     │  │  │  │  ├─ app-debug.apk
│     │  │  │  │  └─ app-debug.apk.sha1
│     │  │  │  └─ logs
│     │  │  │     └─ manifest-merger-debug-report.txt
│     │  │  └─ tmp
│     │  │     ├─ compileDebugJavaWithJavac
│     │  │     │  └─ previous-compilation-data.bin
│     │  │     ├─ kotlin-classes
│     │  │     │  └─ debug
│     │  │     │     ├─ com
│     │  │     │     │  └─ example
│     │  │     │     │     └─ sdgp
│     │  │     │     │        └─ MainActivity.class
│     │  │     │     └─ META-INF
│     │  │     │        └─ app_debug.kotlin_module
│     │  │     └─ packJniLibsflutterBuildDebug
│     │  │        └─ MANIFEST.MF
│     │  ├─ b91b994338c11c54cf5c76fd8ba5acce.cache.dill.track.dill
│     │  ├─ cloud_firestore
│     │  │  ├─ .transforms
│     │  │  │  ├─ 5b694f9e143c607cc2d2c9d6983e1184
│     │  │  │  │  ├─ results.bin
│     │  │  │  │  └─ transformed
│     │  │  │  │     └─ bundleLibRuntimeToDirDebug
│     │  │  │  │        ├─ bundleLibRuntimeToDirDebug_dex
│     │  │  │  │        │  └─ io
│     │  │  │  │        │     └─ flutter
│     │  │  │  │        │        └─ plugins
│     │  │  │  │        │           └─ firebase
│     │  │  │  │        │              └─ firestore
│     │  │  │  │        │                 ├─ BuildConfig.dex
│     │  │  │  │        │                 ├─ FlutterFirebaseFirestoreException$1.dex
│     │  │  │  │        │                 ├─ FlutterFirebaseFirestoreException.dex
│     │  │  │  │        │                 ├─ FlutterFirebaseFirestoreExtension.dex
│     │  │  │  │        │                 ├─ FlutterFirebaseFirestoreMessageCodec$1.dex
│     │  │  │  │        │                 ├─ FlutterFirebaseFirestoreMessageCodec.dex
│     │  │  │  │        │                 ├─ FlutterFirebaseFirestorePlugin$1.dex
│     │  │  │  │        │                 ├─ FlutterFirebaseFirestorePlugin.dex
│     │  │  │  │        │                 ├─ FlutterFirebaseFirestoreRegistrar.dex
│     │  │  │  │        │                 ├─ FlutterFirebaseFirestoreTransactionResult.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$AggregateQuery$Builder.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$AggregateQuery.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$AggregateQueryResponse$Builder.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$AggregateQueryResponse.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$AggregateSource.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$AggregateType.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$DocumentChangeType.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$DocumentReferenceRequest$Builder.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$DocumentReferenceRequest.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$1.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$10.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$11.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$12.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$13.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$14.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$15.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$16.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$17.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$18.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$19.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$2.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$20.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$21.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$22.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$23.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$3.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$4.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$5.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$6.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$7.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$8.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$9.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApiCodec.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirestorePigeonFirebaseApp$Builder.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirestorePigeonFirebaseApp.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FlutterError.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$ListenSource.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PersistenceCacheIndexManagerRequest.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentChange$Builder.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentChange.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentOption$Builder.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentOption.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentSnapshot$Builder.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentSnapshot.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonFirebaseSettings$Builder.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonFirebaseSettings.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonGetOptions$Builder.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonGetOptions.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonQueryParameters$Builder.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonQueryParameters.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonQuerySnapshot$Builder.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonQuerySnapshot.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonSnapshotMetadata$Builder.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonSnapshotMetadata.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionCommand$Builder.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionCommand.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionResult.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionType.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$Result.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$ServerTimestampBehavior.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$Source.dex
│     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore.dex
│     │  │  │  │        │                 ├─ streamhandler
│     │  │  │  │        │                 │  ├─ DocumentSnapshotsStreamHandler.dex
│     │  │  │  │        │                 │  ├─ LoadBundleStreamHandler.dex
│     │  │  │  │        │                 │  ├─ OnTransactionResultListener.dex
│     │  │  │  │        │                 │  ├─ QuerySnapshotsStreamHandler.dex
│     │  │  │  │        │                 │  ├─ SnapshotsInSyncStreamHandler.dex
│     │  │  │  │        │                 │  ├─ TransactionStreamHandler$1.dex
│     │  │  │  │        │                 │  ├─ TransactionStreamHandler$OnTransactionStartedListener.dex
│     │  │  │  │        │                 │  └─ TransactionStreamHandler.dex
│     │  │  │  │        │                 └─ utils
│     │  │  │  │        │                    ├─ ExceptionConverter.dex
│     │  │  │  │        │                    ├─ PigeonParser$1.dex
│     │  │  │  │        │                    ├─ PigeonParser.dex
│     │  │  │  │        │                    └─ ServerTimestampBehaviorConverter.dex
│     │  │  │  │        ├─ bundleLibRuntimeToDirDebug_global-synthetics
│     │  │  │  │        └─ desugar_graph.bin
│     │  │  │  └─ d1a818ccf4e38b4637e0a0a609aa1144
│     │  │  │     ├─ results.bin
│     │  │  │     └─ transformed
│     │  │  │        └─ classes
│     │  │  │           ├─ classes_dex
│     │  │  │           │  └─ classes.dex
│     │  │  │           └─ classes_global-synthetics
│     │  │  ├─ generated
│     │  │  │  ├─ ap_generated_sources
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ out
│     │  │  │  ├─ res
│     │  │  │  │  ├─ pngs
│     │  │  │  │  │  └─ debug
│     │  │  │  │  └─ resValues
│     │  │  │  │     └─ debug
│     │  │  │  └─ source
│     │  │  │     └─ buildConfig
│     │  │  │        └─ debug
│     │  │  │           └─ io
│     │  │  │              └─ flutter
│     │  │  │                 └─ plugins
│     │  │  │                    └─ firebase
│     │  │  │                       └─ firestore
│     │  │  │                          └─ BuildConfig.java
│     │  │  ├─ intermediates
│     │  │  │  ├─ aapt_friendly_merged_manifests
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ aapt
│     │  │  │  │           ├─ AndroidManifest.xml
│     │  │  │  │           └─ output-metadata.json
│     │  │  │  ├─ aar_libs_directory
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ syncDebugLibJars
│     │  │  │  │        └─ libs
│     │  │  │  ├─ aar_main_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ syncDebugLibJars
│     │  │  │  │        └─ classes.jar
│     │  │  │  ├─ aar_metadata
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ writeDebugAarMetadata
│     │  │  │  │        └─ aar-metadata.properties
│     │  │  │  ├─ annotations_typedef_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDebugAnnotations
│     │  │  │  │        └─ typedefs.txt
│     │  │  │  ├─ annotations_zip
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDebugAnnotations
│     │  │  │  ├─ annotation_processor_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ javaPreCompileDebug
│     │  │  │  │        └─ annotationProcessors.json
│     │  │  │  ├─ assets
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugAssets
│     │  │  │  ├─ compiled_local_resources
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ compileDebugLibraryResources
│     │  │  │  │        └─ out
│     │  │  │  ├─ compile_library_classes_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibCompileToJarDebug
│     │  │  │  │        └─ classes.jar
│     │  │  │  ├─ compile_r_class_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugRFile
│     │  │  │  │        └─ R.jar
│     │  │  │  ├─ compile_symbol_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugRFile
│     │  │  │  │        └─ R.txt
│     │  │  │  ├─ data_binding_layout_info_type_package
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  │        └─ out
│     │  │  │  ├─ incremental
│     │  │  │  │  ├─ debug
│     │  │  │  │  │  └─ packageDebugResources
│     │  │  │  │  │     ├─ compile-file-map.properties
│     │  │  │  │  │     ├─ merged.dir
│     │  │  │  │  │     ├─ merger.xml
│     │  │  │  │  │     └─ stripped.dir
│     │  │  │  │  ├─ debug-mergeJavaRes
│     │  │  │  │  │  ├─ merge-state
│     │  │  │  │  │  └─ zip-cache
│     │  │  │  │  ├─ mergeDebugAssets
│     │  │  │  │  │  └─ merger.xml
│     │  │  │  │  ├─ mergeDebugJniLibFolders
│     │  │  │  │  │  └─ merger.xml
│     │  │  │  │  └─ mergeDebugShaders
│     │  │  │  │     └─ merger.xml
│     │  │  │  ├─ javac
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ compileDebugJavaWithJavac
│     │  │  │  │        └─ classes
│     │  │  │  │           └─ io
│     │  │  │  │              └─ flutter
│     │  │  │  │                 └─ plugins
│     │  │  │  │                    └─ firebase
│     │  │  │  │                       └─ firestore
│     │  │  │  │                          ├─ BuildConfig.class
│     │  │  │  │                          ├─ FlutterFirebaseFirestoreException$1.class
│     │  │  │  │                          ├─ FlutterFirebaseFirestoreException.class
│     │  │  │  │                          ├─ FlutterFirebaseFirestoreExtension.class
│     │  │  │  │                          ├─ FlutterFirebaseFirestoreMessageCodec$1.class
│     │  │  │  │                          ├─ FlutterFirebaseFirestoreMessageCodec.class
│     │  │  │  │                          ├─ FlutterFirebaseFirestorePlugin$1.class
│     │  │  │  │                          ├─ FlutterFirebaseFirestorePlugin.class
│     │  │  │  │                          ├─ FlutterFirebaseFirestoreRegistrar.class
│     │  │  │  │                          ├─ FlutterFirebaseFirestoreTransactionResult.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$AggregateQuery$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$AggregateQuery.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$AggregateQueryResponse$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$AggregateQueryResponse.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$AggregateSource.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$AggregateType.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$DocumentChangeType.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$DocumentReferenceRequest$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$DocumentReferenceRequest.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$1.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$10.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$11.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$12.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$13.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$14.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$15.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$16.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$17.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$18.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$19.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$2.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$20.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$21.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$22.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$23.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$3.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$4.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$5.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$6.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$7.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$8.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$9.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApiCodec.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirestorePigeonFirebaseApp$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirestorePigeonFirebaseApp.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FlutterError.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$ListenSource.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PersistenceCacheIndexManagerRequest.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentChange$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentChange.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentOption$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentOption.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentSnapshot$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentSnapshot.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonFirebaseSettings$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonFirebaseSettings.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonGetOptions$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonGetOptions.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonQueryParameters$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonQueryParameters.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonQuerySnapshot$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonQuerySnapshot.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonSnapshotMetadata$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonSnapshotMetadata.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionCommand$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionCommand.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionResult.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionType.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$Result.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$ServerTimestampBehavior.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$Source.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore.class
│     │  │  │  │                          ├─ streamhandler
│     │  │  │  │                          │  ├─ DocumentSnapshotsStreamHandler.class
│     │  │  │  │                          │  ├─ LoadBundleStreamHandler.class
│     │  │  │  │                          │  ├─ OnTransactionResultListener.class
│     │  │  │  │                          │  ├─ QuerySnapshotsStreamHandler.class
│     │  │  │  │                          │  ├─ SnapshotsInSyncStreamHandler.class
│     │  │  │  │                          │  ├─ TransactionStreamHandler$1.class
│     │  │  │  │                          │  ├─ TransactionStreamHandler$OnTransactionStartedListener.class
│     │  │  │  │                          │  └─ TransactionStreamHandler.class
│     │  │  │  │                          └─ utils
│     │  │  │  │                             ├─ ExceptionConverter.class
│     │  │  │  │                             ├─ PigeonParser$1.class
│     │  │  │  │                             ├─ PigeonParser.class
│     │  │  │  │                             └─ ServerTimestampBehaviorConverter.class
│     │  │  │  ├─ library_and_local_jars_jni
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ copyDebugJniLibsProjectAndLocalJars
│     │  │  │  │        └─ jni
│     │  │  │  ├─ library_jni
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ copyDebugJniLibsProjectOnly
│     │  │  │  │        └─ jni
│     │  │  │  ├─ local_only_symbol_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ parseDebugLocalResources
│     │  │  │  │        └─ R-def.txt
│     │  │  │  ├─ manifest_merge_blame_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ manifest-merger-blame-debug-report.txt
│     │  │  │  ├─ merged_java_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugJavaResource
│     │  │  │  │        └─ feature-cloud_firestore.jar
│     │  │  │  ├─ merged_jni_libs
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugJniLibFolders
│     │  │  │  │        └─ out
│     │  │  │  ├─ merged_manifest
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ AndroidManifest.xml
│     │  │  │  ├─ merged_shaders
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugShaders
│     │  │  │  │        └─ out
│     │  │  │  ├─ navigation_json
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDeepLinksDebug
│     │  │  │  │        └─ navigation.json
│     │  │  │  ├─ nested_resources_validation_report
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugResources
│     │  │  │  │        └─ nestedResourcesValidationReport.txt
│     │  │  │  ├─ packaged_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  ├─ public_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  ├─ runtime_library_classes_dir
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibRuntimeToDirDebug
│     │  │  │  │        └─ io
│     │  │  │  │           └─ flutter
│     │  │  │  │              └─ plugins
│     │  │  │  │                 └─ firebase
│     │  │  │  │                    └─ firestore
│     │  │  │  │                       ├─ BuildConfig.class
│     │  │  │  │                       ├─ FlutterFirebaseFirestoreException$1.class
│     │  │  │  │                       ├─ FlutterFirebaseFirestoreException.class
│     │  │  │  │                       ├─ FlutterFirebaseFirestoreExtension.class
│     │  │  │  │                       ├─ FlutterFirebaseFirestoreMessageCodec$1.class
│     │  │  │  │                       ├─ FlutterFirebaseFirestoreMessageCodec.class
│     │  │  │  │                       ├─ FlutterFirebaseFirestorePlugin$1.class
│     │  │  │  │                       ├─ FlutterFirebaseFirestorePlugin.class
│     │  │  │  │                       ├─ FlutterFirebaseFirestoreRegistrar.class
│     │  │  │  │                       ├─ FlutterFirebaseFirestoreTransactionResult.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$AggregateQuery$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$AggregateQuery.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$AggregateQueryResponse$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$AggregateQueryResponse.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$AggregateSource.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$AggregateType.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$DocumentChangeType.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$DocumentReferenceRequest$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$DocumentReferenceRequest.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$1.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$10.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$11.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$12.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$13.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$14.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$15.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$16.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$17.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$18.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$19.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$2.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$20.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$21.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$22.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$23.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$3.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$4.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$5.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$6.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$7.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$8.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$9.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApiCodec.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirestorePigeonFirebaseApp$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirestorePigeonFirebaseApp.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FlutterError.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$ListenSource.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PersistenceCacheIndexManagerRequest.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentChange$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentChange.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentOption$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentOption.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentSnapshot$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentSnapshot.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonFirebaseSettings$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonFirebaseSettings.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonGetOptions$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonGetOptions.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonQueryParameters$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonQueryParameters.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonQuerySnapshot$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonQuerySnapshot.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonSnapshotMetadata$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonSnapshotMetadata.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionCommand$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionCommand.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionResult.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionType.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$Result.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$ServerTimestampBehavior.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$Source.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore.class
│     │  │  │  │                       ├─ streamhandler
│     │  │  │  │                       │  ├─ DocumentSnapshotsStreamHandler.class
│     │  │  │  │                       │  ├─ LoadBundleStreamHandler.class
│     │  │  │  │                       │  ├─ OnTransactionResultListener.class
│     │  │  │  │                       │  ├─ QuerySnapshotsStreamHandler.class
│     │  │  │  │                       │  ├─ SnapshotsInSyncStreamHandler.class
│     │  │  │  │                       │  ├─ TransactionStreamHandler$1.class
│     │  │  │  │                       │  ├─ TransactionStreamHandler$OnTransactionStartedListener.class
│     │  │  │  │                       │  └─ TransactionStreamHandler.class
│     │  │  │  │                       └─ utils
│     │  │  │  │                          ├─ ExceptionConverter.class
│     │  │  │  │                          ├─ PigeonParser$1.class
│     │  │  │  │                          ├─ PigeonParser.class
│     │  │  │  │                          └─ ServerTimestampBehaviorConverter.class
│     │  │  │  ├─ runtime_library_classes_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibRuntimeToJarDebug
│     │  │  │  │        └─ classes.jar
│     │  │  │  └─ symbol_list_with_package_name
│     │  │  │     └─ debug
│     │  │  │        └─ generateDebugRFile
│     │  │  │           └─ package-aware-r.txt
│     │  │  ├─ outputs
│     │  │  │  ├─ aar
│     │  │  │  │  └─ cloud_firestore-debug.aar
│     │  │  │  └─ logs
│     │  │  │     └─ manifest-merger-debug-report.txt
│     │  │  └─ tmp
│     │  │     └─ compileDebugJavaWithJavac
│     │  │        └─ previous-compilation-data.bin
│     │  ├─ firebase_auth
│     │  │  ├─ .transforms
│     │  │  │  ├─ a005f9f0e9c8e204278fa2c7eb90b319
│     │  │  │  │  ├─ results.bin
│     │  │  │  │  └─ transformed
│     │  │  │  │     └─ classes
│     │  │  │  │        ├─ classes_dex
│     │  │  │  │        │  └─ classes.dex
│     │  │  │  │        └─ classes_global-synthetics
│     │  │  │  └─ f973ddd4db61ca2a447e86a64d1e0398
│     │  │  │     ├─ results.bin
│     │  │  │     └─ transformed
│     │  │  │        └─ bundleLibRuntimeToDirDebug
│     │  │  │           ├─ bundleLibRuntimeToDirDebug_dex
│     │  │  │           │  └─ io
│     │  │  │           │     └─ flutter
│     │  │  │           │        └─ plugins
│     │  │  │           │           └─ firebase
│     │  │  │           │              └─ auth
│     │  │  │           │                 ├─ AuthStateChannelStreamHandler.dex
│     │  │  │           │                 ├─ BuildConfig.dex
│     │  │  │           │                 ├─ Constants.dex
│     │  │  │           │                 ├─ FlutterFirebaseAuthPlugin.dex
│     │  │  │           │                 ├─ FlutterFirebaseAuthPluginException.dex
│     │  │  │           │                 ├─ FlutterFirebaseAuthRegistrar.dex
│     │  │  │           │                 ├─ FlutterFirebaseAuthUser.dex
│     │  │  │           │                 ├─ FlutterFirebaseMultiFactor.dex
│     │  │  │           │                 ├─ FlutterFirebaseTotpMultiFactor.dex
│     │  │  │           │                 ├─ FlutterFirebaseTotpSecret.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$ActionCodeInfoOperation.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$AuthPigeonFirebaseApp$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$AuthPigeonFirebaseApp.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$CanIgnoreReturnValue.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$1.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$10.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$11.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$12.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$13.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$14.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$15.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$16.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$17.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$18.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$19.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$2.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$20.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$21.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$22.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$23.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$3.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$4.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$5.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$6.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$7.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$8.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$9.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApiCodec.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$1.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$10.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$11.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$12.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$13.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$14.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$2.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$3.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$4.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$5.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$6.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$7.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$8.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$9.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApiCodec.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$FlutterError.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$GenerateInterfaces.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$GenerateInterfacesCodec.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApi$1.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApi.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApiCodec.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$1.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$2.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$3.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApiCodec.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi$1.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi$2.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$1.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$2.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$3.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$4.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$5.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApiCodec.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$NullableResult.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfo$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfo.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfoData$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfoData.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeSettings$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeSettings.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonAdditionalUserInfo$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonAdditionalUserInfo.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonAuthCredential$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonAuthCredential.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonFirebaseAuthSettings$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonFirebaseAuthSettings.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonIdTokenResult$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonIdTokenResult.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorInfo$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorInfo.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorSession$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorSession.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonPhoneMultiFactorAssertion$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonPhoneMultiFactorAssertion.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonSignInProvider$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonSignInProvider.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonTotpSecret$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonTotpSecret.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserCredential$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserCredential.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserDetails$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserDetails.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserInfo$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserInfo.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserProfile$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserProfile.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$Result.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth$VoidResult.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseAuth.dex
│     │  │  │           │                 ├─ IdTokenChannelStreamHandler.dex
│     │  │  │           │                 ├─ PhoneNumberVerificationStreamHandler$1.dex
│     │  │  │           │                 ├─ PhoneNumberVerificationStreamHandler$OnCredentialsListener.dex
│     │  │  │           │                 ├─ PhoneNumberVerificationStreamHandler.dex
│     │  │  │           │                 └─ PigeonParser.dex
│     │  │  │           ├─ bundleLibRuntimeToDirDebug_global-synthetics
│     │  │  │           └─ desugar_graph.bin
│     │  │  ├─ generated
│     │  │  │  ├─ ap_generated_sources
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ out
│     │  │  │  ├─ res
│     │  │  │  │  ├─ pngs
│     │  │  │  │  │  └─ debug
│     │  │  │  │  └─ resValues
│     │  │  │  │     └─ debug
│     │  │  │  └─ source
│     │  │  │     └─ buildConfig
│     │  │  │        └─ debug
│     │  │  │           └─ io
│     │  │  │              └─ flutter
│     │  │  │                 └─ plugins
│     │  │  │                    └─ firebase
│     │  │  │                       └─ auth
│     │  │  │                          └─ BuildConfig.java
│     │  │  ├─ intermediates
│     │  │  │  ├─ aapt_friendly_merged_manifests
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ aapt
│     │  │  │  │           ├─ AndroidManifest.xml
│     │  │  │  │           └─ output-metadata.json
│     │  │  │  ├─ aar_libs_directory
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ syncDebugLibJars
│     │  │  │  │        └─ libs
│     │  │  │  ├─ aar_main_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ syncDebugLibJars
│     │  │  │  │        └─ classes.jar
│     │  │  │  ├─ aar_metadata
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ writeDebugAarMetadata
│     │  │  │  │        └─ aar-metadata.properties
│     │  │  │  ├─ annotations_typedef_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDebugAnnotations
│     │  │  │  │        └─ typedefs.txt
│     │  │  │  ├─ annotations_zip
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDebugAnnotations
│     │  │  │  ├─ annotation_processor_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ javaPreCompileDebug
│     │  │  │  │        └─ annotationProcessors.json
│     │  │  │  ├─ assets
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugAssets
│     │  │  │  ├─ compiled_local_resources
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ compileDebugLibraryResources
│     │  │  │  │        └─ out
│     │  │  │  ├─ compile_library_classes_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibCompileToJarDebug
│     │  │  │  │        └─ classes.jar
│     │  │  │  ├─ compile_r_class_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugRFile
│     │  │  │  │        └─ R.jar
│     │  │  │  ├─ compile_symbol_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugRFile
│     │  │  │  │        └─ R.txt
│     │  │  │  ├─ data_binding_layout_info_type_package
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  │        └─ out
│     │  │  │  ├─ incremental
│     │  │  │  │  ├─ debug
│     │  │  │  │  │  └─ packageDebugResources
│     │  │  │  │  │     ├─ compile-file-map.properties
│     │  │  │  │  │     ├─ merged.dir
│     │  │  │  │  │     ├─ merger.xml
│     │  │  │  │  │     └─ stripped.dir
│     │  │  │  │  ├─ debug-mergeJavaRes
│     │  │  │  │  │  ├─ merge-state
│     │  │  │  │  │  └─ zip-cache
│     │  │  │  │  ├─ mergeDebugAssets
│     │  │  │  │  │  └─ merger.xml
│     │  │  │  │  ├─ mergeDebugJniLibFolders
│     │  │  │  │  │  └─ merger.xml
│     │  │  │  │  └─ mergeDebugShaders
│     │  │  │  │     └─ merger.xml
│     │  │  │  ├─ javac
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ compileDebugJavaWithJavac
│     │  │  │  │        └─ classes
│     │  │  │  │           └─ io
│     │  │  │  │              └─ flutter
│     │  │  │  │                 └─ plugins
│     │  │  │  │                    └─ firebase
│     │  │  │  │                       └─ auth
│     │  │  │  │                          ├─ AuthStateChannelStreamHandler.class
│     │  │  │  │                          ├─ BuildConfig.class
│     │  │  │  │                          ├─ Constants.class
│     │  │  │  │                          ├─ FlutterFirebaseAuthPlugin.class
│     │  │  │  │                          ├─ FlutterFirebaseAuthPluginException.class
│     │  │  │  │                          ├─ FlutterFirebaseAuthRegistrar.class
│     │  │  │  │                          ├─ FlutterFirebaseAuthUser.class
│     │  │  │  │                          ├─ FlutterFirebaseMultiFactor.class
│     │  │  │  │                          ├─ FlutterFirebaseTotpMultiFactor.class
│     │  │  │  │                          ├─ FlutterFirebaseTotpSecret.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$ActionCodeInfoOperation.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$AuthPigeonFirebaseApp$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$AuthPigeonFirebaseApp.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$CanIgnoreReturnValue.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$1.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$10.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$11.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$12.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$13.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$14.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$15.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$16.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$17.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$18.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$19.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$2.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$20.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$21.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$22.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$23.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$3.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$4.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$5.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$6.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$7.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$8.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$9.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApiCodec.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$1.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$10.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$11.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$12.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$13.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$14.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$2.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$3.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$4.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$5.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$6.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$7.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$8.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$9.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApiCodec.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FlutterError.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$GenerateInterfaces.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$GenerateInterfacesCodec.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApi$1.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApi.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApiCodec.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$1.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$2.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$3.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApiCodec.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi$1.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi$2.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$1.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$2.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$3.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$4.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$5.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApiCodec.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$NullableResult.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfo$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfo.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfoData$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfoData.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeSettings$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeSettings.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonAdditionalUserInfo$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonAdditionalUserInfo.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonAuthCredential$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonAuthCredential.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonFirebaseAuthSettings$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonFirebaseAuthSettings.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonIdTokenResult$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonIdTokenResult.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorInfo$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorInfo.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorSession$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorSession.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonPhoneMultiFactorAssertion$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonPhoneMultiFactorAssertion.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonSignInProvider$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonSignInProvider.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonTotpSecret$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonTotpSecret.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserCredential$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserCredential.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserDetails$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserDetails.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserInfo$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserInfo.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserProfile$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserProfile.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$Result.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$VoidResult.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth.class
│     │  │  │  │                          ├─ IdTokenChannelStreamHandler.class
│     │  │  │  │                          ├─ PhoneNumberVerificationStreamHandler$1.class
│     │  │  │  │                          ├─ PhoneNumberVerificationStreamHandler$OnCredentialsListener.class
│     │  │  │  │                          ├─ PhoneNumberVerificationStreamHandler.class
│     │  │  │  │                          └─ PigeonParser.class
│     │  │  │  ├─ library_and_local_jars_jni
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ copyDebugJniLibsProjectAndLocalJars
│     │  │  │  │        └─ jni
│     │  │  │  ├─ library_jni
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ copyDebugJniLibsProjectOnly
│     │  │  │  │        └─ jni
│     │  │  │  ├─ local_only_symbol_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ parseDebugLocalResources
│     │  │  │  │        └─ R-def.txt
│     │  │  │  ├─ manifest_merge_blame_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ manifest-merger-blame-debug-report.txt
│     │  │  │  ├─ merged_java_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugJavaResource
│     │  │  │  │        └─ feature-firebase_auth.jar
│     │  │  │  ├─ merged_jni_libs
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugJniLibFolders
│     │  │  │  │        └─ out
│     │  │  │  ├─ merged_manifest
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ AndroidManifest.xml
│     │  │  │  ├─ merged_shaders
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugShaders
│     │  │  │  │        └─ out
│     │  │  │  ├─ navigation_json
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDeepLinksDebug
│     │  │  │  │        └─ navigation.json
│     │  │  │  ├─ nested_resources_validation_report
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugResources
│     │  │  │  │        └─ nestedResourcesValidationReport.txt
│     │  │  │  ├─ packaged_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  ├─ public_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  ├─ runtime_library_classes_dir
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibRuntimeToDirDebug
│     │  │  │  │        └─ io
│     │  │  │  │           └─ flutter
│     │  │  │  │              └─ plugins
│     │  │  │  │                 └─ firebase
│     │  │  │  │                    └─ auth
│     │  │  │  │                       ├─ AuthStateChannelStreamHandler.class
│     │  │  │  │                       ├─ BuildConfig.class
│     │  │  │  │                       ├─ Constants.class
│     │  │  │  │                       ├─ FlutterFirebaseAuthPlugin.class
│     │  │  │  │                       ├─ FlutterFirebaseAuthPluginException.class
│     │  │  │  │                       ├─ FlutterFirebaseAuthRegistrar.class
│     │  │  │  │                       ├─ FlutterFirebaseAuthUser.class
│     │  │  │  │                       ├─ FlutterFirebaseMultiFactor.class
│     │  │  │  │                       ├─ FlutterFirebaseTotpMultiFactor.class
│     │  │  │  │                       ├─ FlutterFirebaseTotpSecret.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$ActionCodeInfoOperation.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$AuthPigeonFirebaseApp$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$AuthPigeonFirebaseApp.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$CanIgnoreReturnValue.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$1.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$10.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$11.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$12.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$13.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$14.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$15.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$16.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$17.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$18.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$19.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$2.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$20.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$21.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$22.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$23.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$3.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$4.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$5.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$6.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$7.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$8.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$9.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApiCodec.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$1.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$10.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$11.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$12.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$13.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$14.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$2.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$3.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$4.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$5.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$6.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$7.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$8.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$9.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApiCodec.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FlutterError.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$GenerateInterfaces.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$GenerateInterfacesCodec.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApi$1.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApi.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApiCodec.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$1.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$2.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$3.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApiCodec.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi$1.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi$2.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$1.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$2.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$3.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$4.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$5.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApiCodec.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$NullableResult.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfo$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfo.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfoData$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfoData.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeSettings$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeSettings.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonAdditionalUserInfo$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonAdditionalUserInfo.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonAuthCredential$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonAuthCredential.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonFirebaseAuthSettings$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonFirebaseAuthSettings.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonIdTokenResult$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonIdTokenResult.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorInfo$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorInfo.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorSession$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorSession.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonPhoneMultiFactorAssertion$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonPhoneMultiFactorAssertion.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonSignInProvider$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonSignInProvider.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonTotpSecret$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonTotpSecret.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserCredential$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserCredential.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserDetails$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserDetails.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserInfo$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserInfo.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserProfile$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserProfile.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$Result.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$VoidResult.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth.class
│     │  │  │  │                       ├─ IdTokenChannelStreamHandler.class
│     │  │  │  │                       ├─ PhoneNumberVerificationStreamHandler$1.class
│     │  │  │  │                       ├─ PhoneNumberVerificationStreamHandler$OnCredentialsListener.class
│     │  │  │  │                       ├─ PhoneNumberVerificationStreamHandler.class
│     │  │  │  │                       └─ PigeonParser.class
│     │  │  │  ├─ runtime_library_classes_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibRuntimeToJarDebug
│     │  │  │  │        └─ classes.jar
│     │  │  │  └─ symbol_list_with_package_name
│     │  │  │     └─ debug
│     │  │  │        └─ generateDebugRFile
│     │  │  │           └─ package-aware-r.txt
│     │  │  ├─ outputs
│     │  │  │  ├─ aar
│     │  │  │  │  └─ firebase_auth-debug.aar
│     │  │  │  └─ logs
│     │  │  │     └─ manifest-merger-debug-report.txt
│     │  │  └─ tmp
│     │  │     └─ compileDebugJavaWithJavac
│     │  │        └─ previous-compilation-data.bin
│     │  ├─ firebase_core
│     │  │  ├─ .transforms
│     │  │  │  ├─ 34655ee15063681225c4e403dd29cb14
│     │  │  │  │  ├─ results.bin
│     │  │  │  │  └─ transformed
│     │  │  │  │     └─ classes
│     │  │  │  │        ├─ classes_dex
│     │  │  │  │        │  └─ classes.dex
│     │  │  │  │        └─ classes_global-synthetics
│     │  │  │  └─ 9de140a76788d205b43249a6cb6ef96b
│     │  │  │     ├─ results.bin
│     │  │  │     └─ transformed
│     │  │  │        └─ bundleLibRuntimeToDirDebug
│     │  │  │           ├─ bundleLibRuntimeToDirDebug_dex
│     │  │  │           │  └─ io
│     │  │  │           │     └─ flutter
│     │  │  │           │        └─ plugins
│     │  │  │           │           └─ firebase
│     │  │  │           │              └─ core
│     │  │  │           │                 ├─ BuildConfig.dex
│     │  │  │           │                 ├─ FlutterFirebaseCorePlugin.dex
│     │  │  │           │                 ├─ FlutterFirebaseCoreRegistrar.dex
│     │  │  │           │                 ├─ FlutterFirebasePlugin.dex
│     │  │  │           │                 ├─ FlutterFirebasePluginRegistry.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$CanIgnoreReturnValue.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$CoreFirebaseOptions$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$CoreFirebaseOptions.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$CoreInitializeResponse$Builder.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$CoreInitializeResponse.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$1.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$2.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$3.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$1.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$2.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$3.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$FlutterError.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$NullableResult.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$PigeonCodec.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$Result.dex
│     │  │  │           │                 ├─ GeneratedAndroidFirebaseCore$VoidResult.dex
│     │  │  │           │                 └─ GeneratedAndroidFirebaseCore.dex
│     │  │  │           ├─ bundleLibRuntimeToDirDebug_global-synthetics
│     │  │  │           └─ desugar_graph.bin
│     │  │  ├─ generated
│     │  │  │  ├─ ap_generated_sources
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ out
│     │  │  │  ├─ res
│     │  │  │  │  ├─ pngs
│     │  │  │  │  │  └─ debug
│     │  │  │  │  └─ resValues
│     │  │  │  │     └─ debug
│     │  │  │  └─ source
│     │  │  │     └─ buildConfig
│     │  │  │        └─ debug
│     │  │  │           └─ io
│     │  │  │              └─ flutter
│     │  │  │                 └─ plugins
│     │  │  │                    └─ firebase
│     │  │  │                       └─ core
│     │  │  │                          └─ BuildConfig.java
│     │  │  ├─ intermediates
│     │  │  │  ├─ aapt_friendly_merged_manifests
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ aapt
│     │  │  │  │           ├─ AndroidManifest.xml
│     │  │  │  │           └─ output-metadata.json
│     │  │  │  ├─ aar_libs_directory
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ syncDebugLibJars
│     │  │  │  │        └─ libs
│     │  │  │  ├─ aar_main_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ syncDebugLibJars
│     │  │  │  │        └─ classes.jar
│     │  │  │  ├─ aar_metadata
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ writeDebugAarMetadata
│     │  │  │  │        └─ aar-metadata.properties
│     │  │  │  ├─ annotations_typedef_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDebugAnnotations
│     │  │  │  │        └─ typedefs.txt
│     │  │  │  ├─ annotations_zip
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDebugAnnotations
│     │  │  │  ├─ annotation_processor_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ javaPreCompileDebug
│     │  │  │  │        └─ annotationProcessors.json
│     │  │  │  ├─ assets
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugAssets
│     │  │  │  ├─ compiled_local_resources
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ compileDebugLibraryResources
│     │  │  │  │        └─ out
│     │  │  │  ├─ compile_library_classes_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibCompileToJarDebug
│     │  │  │  │        └─ classes.jar
│     │  │  │  ├─ compile_r_class_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugRFile
│     │  │  │  │        └─ R.jar
│     │  │  │  ├─ compile_symbol_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugRFile
│     │  │  │  │        └─ R.txt
│     │  │  │  ├─ data_binding_layout_info_type_package
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  │        └─ out
│     │  │  │  ├─ incremental
│     │  │  │  │  ├─ debug
│     │  │  │  │  │  └─ packageDebugResources
│     │  │  │  │  │     ├─ compile-file-map.properties
│     │  │  │  │  │     ├─ merged.dir
│     │  │  │  │  │     ├─ merger.xml
│     │  │  │  │  │     └─ stripped.dir
│     │  │  │  │  ├─ debug-mergeJavaRes
│     │  │  │  │  │  ├─ merge-state
│     │  │  │  │  │  └─ zip-cache
│     │  │  │  │  ├─ mergeDebugAssets
│     │  │  │  │  │  └─ merger.xml
│     │  │  │  │  ├─ mergeDebugJniLibFolders
│     │  │  │  │  │  └─ merger.xml
│     │  │  │  │  └─ mergeDebugShaders
│     │  │  │  │     └─ merger.xml
│     │  │  │  ├─ javac
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ compileDebugJavaWithJavac
│     │  │  │  │        └─ classes
│     │  │  │  │           └─ io
│     │  │  │  │              └─ flutter
│     │  │  │  │                 └─ plugins
│     │  │  │  │                    └─ firebase
│     │  │  │  │                       └─ core
│     │  │  │  │                          ├─ BuildConfig.class
│     │  │  │  │                          ├─ FlutterFirebaseCorePlugin.class
│     │  │  │  │                          ├─ FlutterFirebaseCoreRegistrar.class
│     │  │  │  │                          ├─ FlutterFirebasePlugin.class
│     │  │  │  │                          ├─ FlutterFirebasePluginRegistry.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$CanIgnoreReturnValue.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$CoreFirebaseOptions$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$CoreFirebaseOptions.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$CoreInitializeResponse$Builder.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$CoreInitializeResponse.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$1.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$2.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$3.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$1.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$2.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$3.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FlutterError.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$NullableResult.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$PigeonCodec.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$Result.class
│     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$VoidResult.class
│     │  │  │  │                          └─ GeneratedAndroidFirebaseCore.class
│     │  │  │  ├─ library_and_local_jars_jni
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ copyDebugJniLibsProjectAndLocalJars
│     │  │  │  │        └─ jni
│     │  │  │  ├─ library_jni
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ copyDebugJniLibsProjectOnly
│     │  │  │  │        └─ jni
│     │  │  │  ├─ local_only_symbol_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ parseDebugLocalResources
│     │  │  │  │        └─ R-def.txt
│     │  │  │  ├─ manifest_merge_blame_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ manifest-merger-blame-debug-report.txt
│     │  │  │  ├─ merged_java_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugJavaResource
│     │  │  │  │        └─ feature-firebase_core.jar
│     │  │  │  ├─ merged_jni_libs
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugJniLibFolders
│     │  │  │  │        └─ out
│     │  │  │  ├─ merged_manifest
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ AndroidManifest.xml
│     │  │  │  ├─ merged_shaders
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugShaders
│     │  │  │  │        └─ out
│     │  │  │  ├─ navigation_json
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDeepLinksDebug
│     │  │  │  │        └─ navigation.json
│     │  │  │  ├─ nested_resources_validation_report
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugResources
│     │  │  │  │        └─ nestedResourcesValidationReport.txt
│     │  │  │  ├─ packaged_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  ├─ public_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  ├─ runtime_library_classes_dir
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibRuntimeToDirDebug
│     │  │  │  │        └─ io
│     │  │  │  │           └─ flutter
│     │  │  │  │              └─ plugins
│     │  │  │  │                 └─ firebase
│     │  │  │  │                    └─ core
│     │  │  │  │                       ├─ BuildConfig.class
│     │  │  │  │                       ├─ FlutterFirebaseCorePlugin.class
│     │  │  │  │                       ├─ FlutterFirebaseCoreRegistrar.class
│     │  │  │  │                       ├─ FlutterFirebasePlugin.class
│     │  │  │  │                       ├─ FlutterFirebasePluginRegistry.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$CanIgnoreReturnValue.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$CoreFirebaseOptions$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$CoreFirebaseOptions.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$CoreInitializeResponse$Builder.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$CoreInitializeResponse.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$1.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$2.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$3.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$1.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$2.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$3.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FlutterError.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$NullableResult.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$PigeonCodec.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$Result.class
│     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$VoidResult.class
│     │  │  │  │                       └─ GeneratedAndroidFirebaseCore.class
│     │  │  │  ├─ runtime_library_classes_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibRuntimeToJarDebug
│     │  │  │  │        └─ classes.jar
│     │  │  │  └─ symbol_list_with_package_name
│     │  │  │     └─ debug
│     │  │  │        └─ generateDebugRFile
│     │  │  │           └─ package-aware-r.txt
│     │  │  ├─ outputs
│     │  │  │  ├─ aar
│     │  │  │  │  └─ firebase_core-debug.aar
│     │  │  │  └─ logs
│     │  │  │     └─ manifest-merger-debug-report.txt
│     │  │  └─ tmp
│     │  │     └─ compileDebugJavaWithJavac
│     │  │        └─ previous-compilation-data.bin
│     │  ├─ firebase_messaging
│     │  │  ├─ .transforms
│     │  │  │  ├─ 5047ccbfb39c47897e4a58d80ba32294
│     │  │  │  │  ├─ results.bin
│     │  │  │  │  └─ transformed
│     │  │  │  │     └─ classes
│     │  │  │  │        ├─ classes_dex
│     │  │  │  │        │  └─ classes.dex
│     │  │  │  │        └─ classes_global-synthetics
│     │  │  │  └─ b47bc48438c8101201e7aa9e4c1578bb
│     │  │  │     ├─ results.bin
│     │  │  │     └─ transformed
│     │  │  │        └─ bundleLibRuntimeToDirDebug
│     │  │  │           ├─ bundleLibRuntimeToDirDebug_dex
│     │  │  │           │  └─ io
│     │  │  │           │     └─ flutter
│     │  │  │           │        └─ plugins
│     │  │  │           │           └─ firebase
│     │  │  │           │              └─ messaging
│     │  │  │           │                 ├─ BuildConfig.dex
│     │  │  │           │                 ├─ ContextHolder.dex
│     │  │  │           │                 ├─ ErrorCallback.dex
│     │  │  │           │                 ├─ FlutterFirebaseAppRegistrar.dex
│     │  │  │           │                 ├─ FlutterFirebaseMessagingBackgroundExecutor$1.dex
│     │  │  │           │                 ├─ FlutterFirebaseMessagingBackgroundExecutor$2.dex
│     │  │  │           │                 ├─ FlutterFirebaseMessagingBackgroundExecutor.dex
│     │  │  │           │                 ├─ FlutterFirebaseMessagingBackgroundService.dex
│     │  │  │           │                 ├─ FlutterFirebaseMessagingInitProvider.dex
│     │  │  │           │                 ├─ FlutterFirebaseMessagingPlugin$1.dex
│     │  │  │           │                 ├─ FlutterFirebaseMessagingPlugin$2.dex
│     │  │  │           │                 ├─ FlutterFirebaseMessagingPlugin.dex
│     │  │  │           │                 ├─ FlutterFirebaseMessagingReceiver.dex
│     │  │  │           │                 ├─ FlutterFirebaseMessagingService.dex
│     │  │  │           │                 ├─ FlutterFirebaseMessagingStore.dex
│     │  │  │           │                 ├─ FlutterFirebaseMessagingUtils.dex
│     │  │  │           │                 ├─ FlutterFirebasePermissionManager$RequestPermissionsSuccessCallback.dex
│     │  │  │           │                 ├─ FlutterFirebasePermissionManager.dex
│     │  │  │           │                 ├─ FlutterFirebaseRemoteMessageLiveData.dex
│     │  │  │           │                 ├─ FlutterFirebaseTokenLiveData.dex
│     │  │  │           │                 ├─ JobIntentService$CommandProcessor$1$1.dex
│     │  │  │           │                 ├─ JobIntentService$CommandProcessor$1.dex
│     │  │  │           │                 ├─ JobIntentService$CommandProcessor.dex
│     │  │  │           │                 ├─ JobIntentService$CompatJobEngine.dex
│     │  │  │           │                 ├─ JobIntentService$CompatWorkEnqueuer.dex
│     │  │  │           │                 ├─ JobIntentService$CompatWorkItem.dex
│     │  │  │           │                 ├─ JobIntentService$ComponentNameWithWakeful.dex
│     │  │  │           │                 ├─ JobIntentService$GenericWorkItem.dex
│     │  │  │           │                 ├─ JobIntentService$JobServiceEngineImpl$WrapperWorkItem.dex
│     │  │  │           │                 ├─ JobIntentService$JobServiceEngineImpl.dex
│     │  │  │           │                 ├─ JobIntentService$JobWorkEnqueuer.dex
│     │  │  │           │                 ├─ JobIntentService$WorkEnqueuer.dex
│     │  │  │           │                 ├─ JobIntentService.dex
│     │  │  │           │                 └─ PluginRegistrantException.dex
│     │  │  │           ├─ bundleLibRuntimeToDirDebug_global-synthetics
│     │  │  │           └─ desugar_graph.bin
│     │  │  ├─ generated
│     │  │  │  ├─ ap_generated_sources
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ out
│     │  │  │  ├─ res
│     │  │  │  │  ├─ pngs
│     │  │  │  │  │  └─ debug
│     │  │  │  │  └─ resValues
│     │  │  │  │     └─ debug
│     │  │  │  └─ source
│     │  │  │     └─ buildConfig
│     │  │  │        └─ debug
│     │  │  │           └─ io
│     │  │  │              └─ flutter
│     │  │  │                 └─ plugins
│     │  │  │                    └─ firebase
│     │  │  │                       └─ messaging
│     │  │  │                          └─ BuildConfig.java
│     │  │  ├─ intermediates
│     │  │  │  ├─ aapt_friendly_merged_manifests
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ aapt
│     │  │  │  │           ├─ AndroidManifest.xml
│     │  │  │  │           └─ output-metadata.json
│     │  │  │  ├─ aar_libs_directory
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ syncDebugLibJars
│     │  │  │  │        └─ libs
│     │  │  │  ├─ aar_main_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ syncDebugLibJars
│     │  │  │  │        └─ classes.jar
│     │  │  │  ├─ aar_metadata
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ writeDebugAarMetadata
│     │  │  │  │        └─ aar-metadata.properties
│     │  │  │  ├─ annotations_typedef_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDebugAnnotations
│     │  │  │  │        └─ typedefs.txt
│     │  │  │  ├─ annotations_zip
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDebugAnnotations
│     │  │  │  ├─ annotation_processor_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ javaPreCompileDebug
│     │  │  │  │        └─ annotationProcessors.json
│     │  │  │  ├─ assets
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugAssets
│     │  │  │  ├─ compiled_local_resources
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ compileDebugLibraryResources
│     │  │  │  │        └─ out
│     │  │  │  ├─ compile_library_classes_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibCompileToJarDebug
│     │  │  │  │        └─ classes.jar
│     │  │  │  ├─ compile_r_class_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugRFile
│     │  │  │  │        └─ R.jar
│     │  │  │  ├─ compile_symbol_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugRFile
│     │  │  │  │        └─ R.txt
│     │  │  │  ├─ data_binding_layout_info_type_package
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  │        └─ out
│     │  │  │  ├─ incremental
│     │  │  │  │  ├─ debug
│     │  │  │  │  │  └─ packageDebugResources
│     │  │  │  │  │     ├─ compile-file-map.properties
│     │  │  │  │  │     ├─ merged.dir
│     │  │  │  │  │     ├─ merger.xml
│     │  │  │  │  │     └─ stripped.dir
│     │  │  │  │  ├─ debug-mergeJavaRes
│     │  │  │  │  │  ├─ merge-state
│     │  │  │  │  │  └─ zip-cache
│     │  │  │  │  ├─ mergeDebugAssets
│     │  │  │  │  │  └─ merger.xml
│     │  │  │  │  ├─ mergeDebugJniLibFolders
│     │  │  │  │  │  └─ merger.xml
│     │  │  │  │  └─ mergeDebugShaders
│     │  │  │  │     └─ merger.xml
│     │  │  │  ├─ javac
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ compileDebugJavaWithJavac
│     │  │  │  │        └─ classes
│     │  │  │  │           └─ io
│     │  │  │  │              └─ flutter
│     │  │  │  │                 └─ plugins
│     │  │  │  │                    └─ firebase
│     │  │  │  │                       └─ messaging
│     │  │  │  │                          ├─ BuildConfig.class
│     │  │  │  │                          ├─ ContextHolder.class
│     │  │  │  │                          ├─ ErrorCallback.class
│     │  │  │  │                          ├─ FlutterFirebaseAppRegistrar.class
│     │  │  │  │                          ├─ FlutterFirebaseMessagingBackgroundExecutor$1.class
│     │  │  │  │                          ├─ FlutterFirebaseMessagingBackgroundExecutor$2.class
│     │  │  │  │                          ├─ FlutterFirebaseMessagingBackgroundExecutor.class
│     │  │  │  │                          ├─ FlutterFirebaseMessagingBackgroundService.class
│     │  │  │  │                          ├─ FlutterFirebaseMessagingInitProvider.class
│     │  │  │  │                          ├─ FlutterFirebaseMessagingPlugin$1.class
│     │  │  │  │                          ├─ FlutterFirebaseMessagingPlugin$2.class
│     │  │  │  │                          ├─ FlutterFirebaseMessagingPlugin.class
│     │  │  │  │                          ├─ FlutterFirebaseMessagingReceiver.class
│     │  │  │  │                          ├─ FlutterFirebaseMessagingService.class
│     │  │  │  │                          ├─ FlutterFirebaseMessagingStore.class
│     │  │  │  │                          ├─ FlutterFirebaseMessagingUtils.class
│     │  │  │  │                          ├─ FlutterFirebasePermissionManager$RequestPermissionsSuccessCallback.class
│     │  │  │  │                          ├─ FlutterFirebasePermissionManager.class
│     │  │  │  │                          ├─ FlutterFirebaseRemoteMessageLiveData.class
│     │  │  │  │                          ├─ FlutterFirebaseTokenLiveData.class
│     │  │  │  │                          ├─ JobIntentService$CommandProcessor$1$1.class
│     │  │  │  │                          ├─ JobIntentService$CommandProcessor$1.class
│     │  │  │  │                          ├─ JobIntentService$CommandProcessor.class
│     │  │  │  │                          ├─ JobIntentService$CompatJobEngine.class
│     │  │  │  │                          ├─ JobIntentService$CompatWorkEnqueuer.class
│     │  │  │  │                          ├─ JobIntentService$CompatWorkItem.class
│     │  │  │  │                          ├─ JobIntentService$ComponentNameWithWakeful.class
│     │  │  │  │                          ├─ JobIntentService$GenericWorkItem.class
│     │  │  │  │                          ├─ JobIntentService$JobServiceEngineImpl$WrapperWorkItem.class
│     │  │  │  │                          ├─ JobIntentService$JobServiceEngineImpl.class
│     │  │  │  │                          ├─ JobIntentService$JobWorkEnqueuer.class
│     │  │  │  │                          ├─ JobIntentService$WorkEnqueuer.class
│     │  │  │  │                          ├─ JobIntentService.class
│     │  │  │  │                          └─ PluginRegistrantException.class
│     │  │  │  ├─ library_and_local_jars_jni
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ copyDebugJniLibsProjectAndLocalJars
│     │  │  │  │        └─ jni
│     │  │  │  ├─ library_jni
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ copyDebugJniLibsProjectOnly
│     │  │  │  │        └─ jni
│     │  │  │  ├─ local_only_symbol_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ parseDebugLocalResources
│     │  │  │  │        └─ R-def.txt
│     │  │  │  ├─ manifest_merge_blame_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ manifest-merger-blame-debug-report.txt
│     │  │  │  ├─ merged_java_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugJavaResource
│     │  │  │  │        └─ feature-firebase_messaging.jar
│     │  │  │  ├─ merged_jni_libs
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugJniLibFolders
│     │  │  │  │        └─ out
│     │  │  │  ├─ merged_manifest
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ AndroidManifest.xml
│     │  │  │  ├─ merged_shaders
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugShaders
│     │  │  │  │        └─ out
│     │  │  │  ├─ navigation_json
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDeepLinksDebug
│     │  │  │  │        └─ navigation.json
│     │  │  │  ├─ nested_resources_validation_report
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugResources
│     │  │  │  │        └─ nestedResourcesValidationReport.txt
│     │  │  │  ├─ packaged_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  ├─ public_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  ├─ runtime_library_classes_dir
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibRuntimeToDirDebug
│     │  │  │  │        └─ io
│     │  │  │  │           └─ flutter
│     │  │  │  │              └─ plugins
│     │  │  │  │                 └─ firebase
│     │  │  │  │                    └─ messaging
│     │  │  │  │                       ├─ BuildConfig.class
│     │  │  │  │                       ├─ ContextHolder.class
│     │  │  │  │                       ├─ ErrorCallback.class
│     │  │  │  │                       ├─ FlutterFirebaseAppRegistrar.class
│     │  │  │  │                       ├─ FlutterFirebaseMessagingBackgroundExecutor$1.class
│     │  │  │  │                       ├─ FlutterFirebaseMessagingBackgroundExecutor$2.class
│     │  │  │  │                       ├─ FlutterFirebaseMessagingBackgroundExecutor.class
│     │  │  │  │                       ├─ FlutterFirebaseMessagingBackgroundService.class
│     │  │  │  │                       ├─ FlutterFirebaseMessagingInitProvider.class
│     │  │  │  │                       ├─ FlutterFirebaseMessagingPlugin$1.class
│     │  │  │  │                       ├─ FlutterFirebaseMessagingPlugin$2.class
│     │  │  │  │                       ├─ FlutterFirebaseMessagingPlugin.class
│     │  │  │  │                       ├─ FlutterFirebaseMessagingReceiver.class
│     │  │  │  │                       ├─ FlutterFirebaseMessagingService.class
│     │  │  │  │                       ├─ FlutterFirebaseMessagingStore.class
│     │  │  │  │                       ├─ FlutterFirebaseMessagingUtils.class
│     │  │  │  │                       ├─ FlutterFirebasePermissionManager$RequestPermissionsSuccessCallback.class
│     │  │  │  │                       ├─ FlutterFirebasePermissionManager.class
│     │  │  │  │                       ├─ FlutterFirebaseRemoteMessageLiveData.class
│     │  │  │  │                       ├─ FlutterFirebaseTokenLiveData.class
│     │  │  │  │                       ├─ JobIntentService$CommandProcessor$1$1.class
│     │  │  │  │                       ├─ JobIntentService$CommandProcessor$1.class
│     │  │  │  │                       ├─ JobIntentService$CommandProcessor.class
│     │  │  │  │                       ├─ JobIntentService$CompatJobEngine.class
│     │  │  │  │                       ├─ JobIntentService$CompatWorkEnqueuer.class
│     │  │  │  │                       ├─ JobIntentService$CompatWorkItem.class
│     │  │  │  │                       ├─ JobIntentService$ComponentNameWithWakeful.class
│     │  │  │  │                       ├─ JobIntentService$GenericWorkItem.class
│     │  │  │  │                       ├─ JobIntentService$JobServiceEngineImpl$WrapperWorkItem.class
│     │  │  │  │                       ├─ JobIntentService$JobServiceEngineImpl.class
│     │  │  │  │                       ├─ JobIntentService$JobWorkEnqueuer.class
│     │  │  │  │                       ├─ JobIntentService$WorkEnqueuer.class
│     │  │  │  │                       ├─ JobIntentService.class
│     │  │  │  │                       └─ PluginRegistrantException.class
│     │  │  │  ├─ runtime_library_classes_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibRuntimeToJarDebug
│     │  │  │  │        └─ classes.jar
│     │  │  │  └─ symbol_list_with_package_name
│     │  │  │     └─ debug
│     │  │  │        └─ generateDebugRFile
│     │  │  │           └─ package-aware-r.txt
│     │  │  ├─ outputs
│     │  │  │  ├─ aar
│     │  │  │  │  └─ firebase_messaging-debug.aar
│     │  │  │  └─ logs
│     │  │  │     └─ manifest-merger-debug-report.txt
│     │  │  └─ tmp
│     │  │     └─ compileDebugJavaWithJavac
│     │  │        └─ previous-compilation-data.bin
│     │  ├─ flutter_local_notifications
│     │  │  ├─ .transforms
│     │  │  │  ├─ 7e224b8b111db7e1e6f800de838e3745
│     │  │  │  │  ├─ results.bin
│     │  │  │  │  └─ transformed
│     │  │  │  │     └─ classes
│     │  │  │  │        ├─ classes_dex
│     │  │  │  │        │  └─ classes.dex
│     │  │  │  │        └─ classes_global-synthetics
│     │  │  │  └─ f928fabde5ccbeb4a43d84b3be0e20a0
│     │  │  │     ├─ results.bin
│     │  │  │     └─ transformed
│     │  │  │        └─ bundleLibRuntimeToDirDebug
│     │  │  │           ├─ bundleLibRuntimeToDirDebug_dex
│     │  │  │           │  └─ com
│     │  │  │           │     └─ dexterous
│     │  │  │           │        └─ flutterlocalnotifications
│     │  │  │           │           ├─ ActionBroadcastReceiver$1.dex
│     │  │  │           │           ├─ ActionBroadcastReceiver$ActionEventSink.dex
│     │  │  │           │           ├─ ActionBroadcastReceiver.dex
│     │  │  │           │           ├─ FlutterLocalNotificationsPlugin$1.dex
│     │  │  │           │           ├─ FlutterLocalNotificationsPlugin$2.dex
│     │  │  │           │           ├─ FlutterLocalNotificationsPlugin$3.dex
│     │  │  │           │           ├─ FlutterLocalNotificationsPlugin$4.dex
│     │  │  │           │           ├─ FlutterLocalNotificationsPlugin$5.dex
│     │  │  │           │           ├─ FlutterLocalNotificationsPlugin$ExactAlarmPermissionException.dex
│     │  │  │           │           ├─ FlutterLocalNotificationsPlugin$PermissionRequestProgress.dex
│     │  │  │           │           ├─ FlutterLocalNotificationsPlugin$PluginException.dex
│     │  │  │           │           ├─ FlutterLocalNotificationsPlugin.dex
│     │  │  │           │           ├─ ForegroundService.dex
│     │  │  │           │           ├─ ForegroundServiceStartParameter.dex
│     │  │  │           │           ├─ isolate
│     │  │  │           │           │  └─ IsolatePreferences.dex
│     │  │  │           │           ├─ models
│     │  │  │           │           │  ├─ BitmapSource.dex
│     │  │  │           │           │  ├─ DateTimeComponents.dex
│     │  │  │           │           │  ├─ IconSource.dex
│     │  │  │           │           │  ├─ MessageDetails.dex
│     │  │  │           │           │  ├─ NotificationAction$NotificationActionInput.dex
│     │  │  │           │           │  ├─ NotificationAction.dex
│     │  │  │           │           │  ├─ NotificationChannelAction.dex
│     │  │  │           │           │  ├─ NotificationChannelDetails.dex
│     │  │  │           │           │  ├─ NotificationChannelGroupDetails.dex
│     │  │  │           │           │  ├─ NotificationDetails.dex
│     │  │  │           │           │  ├─ NotificationStyle.dex
│     │  │  │           │           │  ├─ PersonDetails.dex
│     │  │  │           │           │  ├─ RepeatInterval.dex
│     │  │  │           │           │  ├─ ScheduledNotificationRepeatFrequency.dex
│     │  │  │           │           │  ├─ ScheduleMode$Deserializer.dex
│     │  │  │           │           │  ├─ ScheduleMode.dex
│     │  │  │           │           │  ├─ SoundSource.dex
│     │  │  │           │           │  ├─ styles
│     │  │  │           │           │  │  ├─ BigPictureStyleInformation.dex
│     │  │  │           │           │  │  ├─ BigTextStyleInformation.dex
│     │  │  │           │           │  │  ├─ DefaultStyleInformation.dex
│     │  │  │           │           │  │  ├─ InboxStyleInformation.dex
│     │  │  │           │           │  │  ├─ MessagingStyleInformation.dex
│     │  │  │           │           │  │  └─ StyleInformation.dex
│     │  │  │           │           │  └─ Time.dex
│     │  │  │           │           ├─ PermissionRequestListener.dex
│     │  │  │           │           ├─ RuntimeTypeAdapterFactory$1.dex
│     │  │  │           │           ├─ RuntimeTypeAdapterFactory.dex
│     │  │  │           │           ├─ ScheduledNotificationBootReceiver.dex
│     │  │  │           │           ├─ ScheduledNotificationReceiver$1.dex
│     │  │  │           │           ├─ ScheduledNotificationReceiver.dex
│     │  │  │           │           └─ utils
│     │  │  │           │              ├─ BooleanUtils.dex
│     │  │  │           │              ├─ LongUtils.dex
│     │  │  │           │              └─ StringUtils.dex
│     │  │  │           ├─ bundleLibRuntimeToDirDebug_global-synthetics
│     │  │  │           └─ desugar_graph.bin
│     │  │  ├─ generated
│     │  │  │  ├─ ap_generated_sources
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ out
│     │  │  │  └─ res
│     │  │  │     ├─ pngs
│     │  │  │     │  └─ debug
│     │  │  │     └─ resValues
│     │  │  │        └─ debug
│     │  │  ├─ intermediates
│     │  │  │  ├─ aapt_friendly_merged_manifests
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ aapt
│     │  │  │  │           ├─ AndroidManifest.xml
│     │  │  │  │           └─ output-metadata.json
│     │  │  │  ├─ aar_libs_directory
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ syncDebugLibJars
│     │  │  │  │        └─ libs
│     │  │  │  ├─ aar_main_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ syncDebugLibJars
│     │  │  │  │        └─ classes.jar
│     │  │  │  ├─ aar_metadata
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ writeDebugAarMetadata
│     │  │  │  │        └─ aar-metadata.properties
│     │  │  │  ├─ annotations_typedef_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDebugAnnotations
│     │  │  │  │        └─ typedefs.txt
│     │  │  │  ├─ annotations_zip
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDebugAnnotations
│     │  │  │  ├─ annotation_processor_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ javaPreCompileDebug
│     │  │  │  │        └─ annotationProcessors.json
│     │  │  │  ├─ assets
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugAssets
│     │  │  │  ├─ compiled_local_resources
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ compileDebugLibraryResources
│     │  │  │  │        └─ out
│     │  │  │  ├─ compile_library_classes_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibCompileToJarDebug
│     │  │  │  │        └─ classes.jar
│     │  │  │  ├─ compile_r_class_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugRFile
│     │  │  │  │        └─ R.jar
│     │  │  │  ├─ compile_symbol_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugRFile
│     │  │  │  │        └─ R.txt
│     │  │  │  ├─ data_binding_layout_info_type_package
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  │        └─ out
│     │  │  │  ├─ incremental
│     │  │  │  │  ├─ debug
│     │  │  │  │  │  └─ packageDebugResources
│     │  │  │  │  │     ├─ compile-file-map.properties
│     │  │  │  │  │     ├─ merged.dir
│     │  │  │  │  │     ├─ merger.xml
│     │  │  │  │  │     └─ stripped.dir
│     │  │  │  │  ├─ debug-mergeJavaRes
│     │  │  │  │  │  ├─ merge-state
│     │  │  │  │  │  └─ zip-cache
│     │  │  │  │  ├─ mergeDebugAssets
│     │  │  │  │  │  └─ merger.xml
│     │  │  │  │  ├─ mergeDebugJniLibFolders
│     │  │  │  │  │  └─ merger.xml
│     │  │  │  │  └─ mergeDebugShaders
│     │  │  │  │     └─ merger.xml
│     │  │  │  ├─ javac
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ compileDebugJavaWithJavac
│     │  │  │  │        └─ classes
│     │  │  │  │           └─ com
│     │  │  │  │              └─ dexterous
│     │  │  │  │                 └─ flutterlocalnotifications
│     │  │  │  │                    ├─ ActionBroadcastReceiver$1.class
│     │  │  │  │                    ├─ ActionBroadcastReceiver$ActionEventSink.class
│     │  │  │  │                    ├─ ActionBroadcastReceiver.class
│     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$1.class
│     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$2.class
│     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$3.class
│     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$4.class
│     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$5.class
│     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$ExactAlarmPermissionException.class
│     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$PermissionRequestProgress.class
│     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$PluginException.class
│     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin.class
│     │  │  │  │                    ├─ ForegroundService.class
│     │  │  │  │                    ├─ ForegroundServiceStartParameter.class
│     │  │  │  │                    ├─ isolate
│     │  │  │  │                    │  └─ IsolatePreferences.class
│     │  │  │  │                    ├─ models
│     │  │  │  │                    │  ├─ BitmapSource.class
│     │  │  │  │                    │  ├─ DateTimeComponents.class
│     │  │  │  │                    │  ├─ IconSource.class
│     │  │  │  │                    │  ├─ MessageDetails.class
│     │  │  │  │                    │  ├─ NotificationAction$NotificationActionInput.class
│     │  │  │  │                    │  ├─ NotificationAction.class
│     │  │  │  │                    │  ├─ NotificationChannelAction.class
│     │  │  │  │                    │  ├─ NotificationChannelDetails.class
│     │  │  │  │                    │  ├─ NotificationChannelGroupDetails.class
│     │  │  │  │                    │  ├─ NotificationDetails.class
│     │  │  │  │                    │  ├─ NotificationStyle.class
│     │  │  │  │                    │  ├─ PersonDetails.class
│     │  │  │  │                    │  ├─ RepeatInterval.class
│     │  │  │  │                    │  ├─ ScheduledNotificationRepeatFrequency.class
│     │  │  │  │                    │  ├─ ScheduleMode$Deserializer.class
│     │  │  │  │                    │  ├─ ScheduleMode.class
│     │  │  │  │                    │  ├─ SoundSource.class
│     │  │  │  │                    │  ├─ styles
│     │  │  │  │                    │  │  ├─ BigPictureStyleInformation.class
│     │  │  │  │                    │  │  ├─ BigTextStyleInformation.class
│     │  │  │  │                    │  │  ├─ DefaultStyleInformation.class
│     │  │  │  │                    │  │  ├─ InboxStyleInformation.class
│     │  │  │  │                    │  │  ├─ MessagingStyleInformation.class
│     │  │  │  │                    │  │  └─ StyleInformation.class
│     │  │  │  │                    │  └─ Time.class
│     │  │  │  │                    ├─ PermissionRequestListener.class
│     │  │  │  │                    ├─ RuntimeTypeAdapterFactory$1.class
│     │  │  │  │                    ├─ RuntimeTypeAdapterFactory.class
│     │  │  │  │                    ├─ ScheduledNotificationBootReceiver.class
│     │  │  │  │                    ├─ ScheduledNotificationReceiver$1.class
│     │  │  │  │                    ├─ ScheduledNotificationReceiver.class
│     │  │  │  │                    └─ utils
│     │  │  │  │                       ├─ BooleanUtils.class
│     │  │  │  │                       ├─ LongUtils.class
│     │  │  │  │                       └─ StringUtils.class
│     │  │  │  ├─ library_and_local_jars_jni
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ copyDebugJniLibsProjectAndLocalJars
│     │  │  │  │        └─ jni
│     │  │  │  ├─ library_jni
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ copyDebugJniLibsProjectOnly
│     │  │  │  │        └─ jni
│     │  │  │  ├─ local_only_symbol_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ parseDebugLocalResources
│     │  │  │  │        └─ R-def.txt
│     │  │  │  ├─ manifest_merge_blame_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ manifest-merger-blame-debug-report.txt
│     │  │  │  ├─ merged_java_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugJavaResource
│     │  │  │  │        └─ feature-flutter_local_notifications.jar
│     │  │  │  ├─ merged_jni_libs
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugJniLibFolders
│     │  │  │  │        └─ out
│     │  │  │  ├─ merged_manifest
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ AndroidManifest.xml
│     │  │  │  ├─ merged_shaders
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugShaders
│     │  │  │  │        └─ out
│     │  │  │  ├─ navigation_json
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDeepLinksDebug
│     │  │  │  │        └─ navigation.json
│     │  │  │  ├─ nested_resources_validation_report
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugResources
│     │  │  │  │        └─ nestedResourcesValidationReport.txt
│     │  │  │  ├─ packaged_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  ├─ public_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  ├─ runtime_library_classes_dir
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibRuntimeToDirDebug
│     │  │  │  │        └─ com
│     │  │  │  │           └─ dexterous
│     │  │  │  │              └─ flutterlocalnotifications
│     │  │  │  │                 ├─ ActionBroadcastReceiver$1.class
│     │  │  │  │                 ├─ ActionBroadcastReceiver$ActionEventSink.class
│     │  │  │  │                 ├─ ActionBroadcastReceiver.class
│     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$1.class
│     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$2.class
│     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$3.class
│     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$4.class
│     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$5.class
│     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$ExactAlarmPermissionException.class
│     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$PermissionRequestProgress.class
│     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$PluginException.class
│     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin.class
│     │  │  │  │                 ├─ ForegroundService.class
│     │  │  │  │                 ├─ ForegroundServiceStartParameter.class
│     │  │  │  │                 ├─ isolate
│     │  │  │  │                 │  └─ IsolatePreferences.class
│     │  │  │  │                 ├─ models
│     │  │  │  │                 │  ├─ BitmapSource.class
│     │  │  │  │                 │  ├─ DateTimeComponents.class
│     │  │  │  │                 │  ├─ IconSource.class
│     │  │  │  │                 │  ├─ MessageDetails.class
│     │  │  │  │                 │  ├─ NotificationAction$NotificationActionInput.class
│     │  │  │  │                 │  ├─ NotificationAction.class
│     │  │  │  │                 │  ├─ NotificationChannelAction.class
│     │  │  │  │                 │  ├─ NotificationChannelDetails.class
│     │  │  │  │                 │  ├─ NotificationChannelGroupDetails.class
│     │  │  │  │                 │  ├─ NotificationDetails.class
│     │  │  │  │                 │  ├─ NotificationStyle.class
│     │  │  │  │                 │  ├─ PersonDetails.class
│     │  │  │  │                 │  ├─ RepeatInterval.class
│     │  │  │  │                 │  ├─ ScheduledNotificationRepeatFrequency.class
│     │  │  │  │                 │  ├─ ScheduleMode$Deserializer.class
│     │  │  │  │                 │  ├─ ScheduleMode.class
│     │  │  │  │                 │  ├─ SoundSource.class
│     │  │  │  │                 │  ├─ styles
│     │  │  │  │                 │  │  ├─ BigPictureStyleInformation.class
│     │  │  │  │                 │  │  ├─ BigTextStyleInformation.class
│     │  │  │  │                 │  │  ├─ DefaultStyleInformation.class
│     │  │  │  │                 │  │  ├─ InboxStyleInformation.class
│     │  │  │  │                 │  │  ├─ MessagingStyleInformation.class
│     │  │  │  │                 │  │  └─ StyleInformation.class
│     │  │  │  │                 │  └─ Time.class
│     │  │  │  │                 ├─ PermissionRequestListener.class
│     │  │  │  │                 ├─ RuntimeTypeAdapterFactory$1.class
│     │  │  │  │                 ├─ RuntimeTypeAdapterFactory.class
│     │  │  │  │                 ├─ ScheduledNotificationBootReceiver.class
│     │  │  │  │                 ├─ ScheduledNotificationReceiver$1.class
│     │  │  │  │                 ├─ ScheduledNotificationReceiver.class
│     │  │  │  │                 └─ utils
│     │  │  │  │                    ├─ BooleanUtils.class
│     │  │  │  │                    ├─ LongUtils.class
│     │  │  │  │                    └─ StringUtils.class
│     │  │  │  ├─ runtime_library_classes_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibRuntimeToJarDebug
│     │  │  │  │        └─ classes.jar
│     │  │  │  └─ symbol_list_with_package_name
│     │  │  │     └─ debug
│     │  │  │        └─ generateDebugRFile
│     │  │  │           └─ package-aware-r.txt
│     │  │  ├─ outputs
│     │  │  │  ├─ aar
│     │  │  │  │  └─ flutter_local_notifications-debug.aar
│     │  │  │  └─ logs
│     │  │  │     └─ manifest-merger-debug-report.txt
│     │  │  └─ tmp
│     │  │     └─ compileDebugJavaWithJavac
│     │  │        └─ previous-compilation-data.bin
│     │  ├─ flutter_timezone
│     │  │  ├─ .transforms
│     │  │  │  ├─ 1e3f177887866dbcc0dbc03bff0946db
│     │  │  │  │  ├─ results.bin
│     │  │  │  │  └─ transformed
│     │  │  │  │     └─ classes
│     │  │  │  │        ├─ classes_dex
│     │  │  │  │        │  └─ classes.dex
│     │  │  │  │        └─ classes_global-synthetics
│     │  │  │  └─ 61fb49db480503f86eed714283a7f59b
│     │  │  │     ├─ results.bin
│     │  │  │     └─ transformed
│     │  │  │        └─ bundleLibRuntimeToDirDebug
│     │  │  │           ├─ bundleLibRuntimeToDirDebug_dex
│     │  │  │           │  └─ net
│     │  │  │           │     └─ wolverinebeach
│     │  │  │           │        └─ flutter_timezone
│     │  │  │           │           └─ FlutterTimezonePlugin.dex
│     │  │  │           ├─ bundleLibRuntimeToDirDebug_global-synthetics
│     │  │  │           └─ desugar_graph.bin
│     │  │  ├─ generated
│     │  │  │  └─ res
│     │  │  │     ├─ pngs
│     │  │  │     │  └─ debug
│     │  │  │     └─ resValues
│     │  │  │        └─ debug
│     │  │  ├─ intermediates
│     │  │  │  ├─ aapt_friendly_merged_manifests
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ aapt
│     │  │  │  │           ├─ AndroidManifest.xml
│     │  │  │  │           └─ output-metadata.json
│     │  │  │  ├─ aar_libs_directory
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ syncDebugLibJars
│     │  │  │  │        └─ libs
│     │  │  │  ├─ aar_main_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ syncDebugLibJars
│     │  │  │  │        └─ classes.jar
│     │  │  │  ├─ aar_metadata
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ writeDebugAarMetadata
│     │  │  │  │        └─ aar-metadata.properties
│     │  │  │  ├─ annotations_typedef_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDebugAnnotations
│     │  │  │  │        └─ typedefs.txt
│     │  │  │  ├─ annotations_zip
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDebugAnnotations
│     │  │  │  ├─ annotation_processor_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ javaPreCompileDebug
│     │  │  │  │        └─ annotationProcessors.json
│     │  │  │  ├─ assets
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugAssets
│     │  │  │  ├─ compiled_local_resources
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ compileDebugLibraryResources
│     │  │  │  │        └─ out
│     │  │  │  ├─ compile_library_classes_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibCompileToJarDebug
│     │  │  │  │        └─ classes.jar
│     │  │  │  ├─ compile_r_class_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugRFile
│     │  │  │  │        └─ R.jar
│     │  │  │  ├─ compile_symbol_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugRFile
│     │  │  │  │        └─ R.txt
│     │  │  │  ├─ data_binding_layout_info_type_package
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  │        └─ out
│     │  │  │  ├─ incremental
│     │  │  │  │  ├─ debug
│     │  │  │  │  │  └─ packageDebugResources
│     │  │  │  │  │     ├─ compile-file-map.properties
│     │  │  │  │  │     ├─ merged.dir
│     │  │  │  │  │     ├─ merger.xml
│     │  │  │  │  │     └─ stripped.dir
│     │  │  │  │  ├─ debug-mergeJavaRes
│     │  │  │  │  │  ├─ merge-state
│     │  │  │  │  │  └─ zip-cache
│     │  │  │  │  ├─ mergeDebugAssets
│     │  │  │  │  │  └─ merger.xml
│     │  │  │  │  ├─ mergeDebugJniLibFolders
│     │  │  │  │  │  └─ merger.xml
│     │  │  │  │  └─ mergeDebugShaders
│     │  │  │  │     └─ merger.xml
│     │  │  │  ├─ java_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugJavaRes
│     │  │  │  │        └─ out
│     │  │  │  │           ├─ META-INF
│     │  │  │  │           │  └─ flutter_timezone_debug.kotlin_module
│     │  │  │  │           └─ net
│     │  │  │  │              └─ wolverinebeach
│     │  │  │  │                 └─ flutter_timezone
│     │  │  │  ├─ library_and_local_jars_jni
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ copyDebugJniLibsProjectAndLocalJars
│     │  │  │  │        └─ jni
│     │  │  │  ├─ library_jni
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ copyDebugJniLibsProjectOnly
│     │  │  │  │        └─ jni
│     │  │  │  ├─ local_only_symbol_list
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ parseDebugLocalResources
│     │  │  │  │        └─ R-def.txt
│     │  │  │  ├─ manifest_merge_blame_file
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ manifest-merger-blame-debug-report.txt
│     │  │  │  ├─ merged_java_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugJavaResource
│     │  │  │  │        └─ feature-flutter_timezone.jar
│     │  │  │  ├─ merged_jni_libs
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugJniLibFolders
│     │  │  │  │        └─ out
│     │  │  │  ├─ merged_manifest
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ processDebugManifest
│     │  │  │  │        └─ AndroidManifest.xml
│     │  │  │  ├─ merged_shaders
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ mergeDebugShaders
│     │  │  │  │        └─ out
│     │  │  │  ├─ navigation_json
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ extractDeepLinksDebug
│     │  │  │  │        └─ navigation.json
│     │  │  │  ├─ nested_resources_validation_report
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ generateDebugResources
│     │  │  │  │        └─ nestedResourcesValidationReport.txt
│     │  │  │  ├─ packaged_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  ├─ public_res
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ packageDebugResources
│     │  │  │  ├─ runtime_library_classes_dir
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibRuntimeToDirDebug
│     │  │  │  │        ├─ META-INF
│     │  │  │  │        │  └─ flutter_timezone_debug.kotlin_module
│     │  │  │  │        └─ net
│     │  │  │  │           └─ wolverinebeach
│     │  │  │  │              └─ flutter_timezone
│     │  │  │  │                 └─ FlutterTimezonePlugin.class
│     │  │  │  ├─ runtime_library_classes_jar
│     │  │  │  │  └─ debug
│     │  │  │  │     └─ bundleLibRuntimeToJarDebug
│     │  │  │  │        └─ classes.jar
│     │  │  │  └─ symbol_list_with_package_name
│     │  │  │     └─ debug
│     │  │  │        └─ generateDebugRFile
│     │  │  │           └─ package-aware-r.txt
│     │  │  ├─ kotlin
│     │  │  │  └─ compileDebugKotlin
│     │  │  │     ├─ cacheable
│     │  │  │     │  ├─ caches-jvm
│     │  │  │     │  │  ├─ inputs
│     │  │  │     │  │  │  ├─ source-to-output.tab
│     │  │  │     │  │  │  ├─ source-to-output.tab.keystream
│     │  │  │     │  │  │  ├─ source-to-output.tab.keystream.len
│     │  │  │     │  │  │  ├─ source-to-output.tab.len
│     │  │  │     │  │  │  ├─ source-to-output.tab.values.at
│     │  │  │     │  │  │  ├─ source-to-output.tab_i
│     │  │  │     │  │  │  └─ source-to-output.tab_i.len
│     │  │  │     │  │  ├─ jvm
│     │  │  │     │  │  │  └─ kotlin
│     │  │  │     │  │  │     ├─ class-attributes.tab
│     │  │  │     │  │  │     ├─ class-attributes.tab.keystream
│     │  │  │     │  │  │     ├─ class-attributes.tab.keystream.len
│     │  │  │     │  │  │     ├─ class-attributes.tab.len
│     │  │  │     │  │  │     ├─ class-attributes.tab.values.at
│     │  │  │     │  │  │     ├─ class-attributes.tab_i
│     │  │  │     │  │  │     ├─ class-attributes.tab_i.len
│     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab
│     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab.keystream
│     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab.keystream.len
│     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab.len
│     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab.values.at
│     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab_i
│     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab_i.len
│     │  │  │     │  │  │     ├─ internal-name-to-source.tab
│     │  │  │     │  │  │     ├─ internal-name-to-source.tab.keystream
│     │  │  │     │  │  │     ├─ internal-name-to-source.tab.keystream.len
│     │  │  │     │  │  │     ├─ internal-name-to-source.tab.len
│     │  │  │     │  │  │     ├─ internal-name-to-source.tab.values.at
│     │  │  │     │  │  │     ├─ internal-name-to-source.tab_i
│     │  │  │     │  │  │     ├─ internal-name-to-source.tab_i.len
│     │  │  │     │  │  │     ├─ proto.tab
│     │  │  │     │  │  │     ├─ proto.tab.keystream
│     │  │  │     │  │  │     ├─ proto.tab.keystream.len
│     │  │  │     │  │  │     ├─ proto.tab.len
│     │  │  │     │  │  │     ├─ proto.tab.values.at
│     │  │  │     │  │  │     ├─ proto.tab_i
│     │  │  │     │  │  │     ├─ proto.tab_i.len
│     │  │  │     │  │  │     ├─ source-to-classes.tab
│     │  │  │     │  │  │     ├─ source-to-classes.tab.keystream
│     │  │  │     │  │  │     ├─ source-to-classes.tab.keystream.len
│     │  │  │     │  │  │     ├─ source-to-classes.tab.len
│     │  │  │     │  │  │     ├─ source-to-classes.tab.values.at
│     │  │  │     │  │  │     ├─ source-to-classes.tab_i
│     │  │  │     │  │  │     ├─ source-to-classes.tab_i.len
│     │  │  │     │  │  │     ├─ subtypes.tab
│     │  │  │     │  │  │     ├─ subtypes.tab.keystream
│     │  │  │     │  │  │     ├─ subtypes.tab.keystream.len
│     │  │  │     │  │  │     ├─ subtypes.tab.len
│     │  │  │     │  │  │     ├─ subtypes.tab.values.at
│     │  │  │     │  │  │     ├─ subtypes.tab_i
│     │  │  │     │  │  │     ├─ subtypes.tab_i.len
│     │  │  │     │  │  │     ├─ supertypes.tab
│     │  │  │     │  │  │     ├─ supertypes.tab.keystream
│     │  │  │     │  │  │     ├─ supertypes.tab.keystream.len
│     │  │  │     │  │  │     ├─ supertypes.tab.len
│     │  │  │     │  │  │     ├─ supertypes.tab.values.at
│     │  │  │     │  │  │     ├─ supertypes.tab_i
│     │  │  │     │  │  │     └─ supertypes.tab_i.len
│     │  │  │     │  │  └─ lookups
│     │  │  │     │  │     ├─ counters.tab
│     │  │  │     │  │     ├─ file-to-id.tab
│     │  │  │     │  │     ├─ file-to-id.tab.keystream
│     │  │  │     │  │     ├─ file-to-id.tab.keystream.len
│     │  │  │     │  │     ├─ file-to-id.tab.len
│     │  │  │     │  │     ├─ file-to-id.tab.values.at
│     │  │  │     │  │     ├─ file-to-id.tab_i
│     │  │  │     │  │     ├─ file-to-id.tab_i.len
│     │  │  │     │  │     ├─ id-to-file.tab
│     │  │  │     │  │     ├─ id-to-file.tab.keystream
│     │  │  │     │  │     ├─ id-to-file.tab.keystream.len
│     │  │  │     │  │     ├─ id-to-file.tab.len
│     │  │  │     │  │     ├─ id-to-file.tab.values.at
│     │  │  │     │  │     ├─ id-to-file.tab_i.len
│     │  │  │     │  │     ├─ lookups.tab
│     │  │  │     │  │     ├─ lookups.tab.keystream
│     │  │  │     │  │     ├─ lookups.tab.keystream.len
│     │  │  │     │  │     ├─ lookups.tab.len
│     │  │  │     │  │     ├─ lookups.tab.values.at
│     │  │  │     │  │     ├─ lookups.tab_i
│     │  │  │     │  │     └─ lookups.tab_i.len
│     │  │  │     │  └─ last-build.bin
│     │  │  │     ├─ classpath-snapshot
│     │  │  │     │  └─ shrunk-classpath-snapshot.bin
│     │  │  │     └─ local-state
│     │  │  ├─ outputs
│     │  │  │  ├─ aar
│     │  │  │  │  └─ flutter_timezone-debug.aar
│     │  │  │  └─ logs
│     │  │  │     └─ manifest-merger-debug-report.txt
│     │  │  └─ tmp
│     │  │     └─ kotlin-classes
│     │  │        └─ debug
│     │  │           ├─ META-INF
│     │  │           │  └─ flutter_timezone_debug.kotlin_module
│     │  │           └─ net
│     │  │              └─ wolverinebeach
│     │  │                 └─ flutter_timezone
│     │  │                    └─ FlutterTimezonePlugin.class
│     │  ├─ native_assets
│     │  │  └─ android
│     │  ├─ reports
│     │  │  └─ problems
│     │  │     └─ problems-report.html
│     │  └─ shared_preferences_android
│     │     ├─ .transforms
│     │     │  ├─ 2e1d22822015323a09ddfd0edc695229
│     │     │  │  ├─ results.bin
│     │     │  │  └─ transformed
│     │     │  │     └─ bundleLibRuntimeToDirDebug
│     │     │  │        ├─ bundleLibRuntimeToDirDebug_dex
│     │     │  │        │  └─ io
│     │     │  │        │     └─ flutter
│     │     │  │        │        └─ plugins
│     │     │  │        │           └─ sharedpreferences
│     │     │  │        │              ├─ LegacySharedPreferencesPlugin$ListEncoder.dex
│     │     │  │        │              ├─ LegacySharedPreferencesPlugin.dex
│     │     │  │        │              ├─ ListEncoder.dex
│     │     │  │        │              ├─ Messages$FlutterError.dex
│     │     │  │        │              ├─ Messages$PigeonCodec.dex
│     │     │  │        │              ├─ Messages$SharedPreferencesApi.dex
│     │     │  │        │              ├─ Messages.dex
│     │     │  │        │              ├─ MessagesAsyncPigeonCodec.dex
│     │     │  │        │              ├─ MessagesAsyncPigeonUtils.dex
│     │     │  │        │              ├─ SharedPreferencesAsyncApi$Companion.dex
│     │     │  │        │              ├─ SharedPreferencesAsyncApi.dex
│     │     │  │        │              ├─ SharedPreferencesBackend.dex
│     │     │  │        │              ├─ SharedPreferencesError.dex
│     │     │  │        │              ├─ SharedPreferencesListEncoder.dex
│     │     │  │        │              ├─ SharedPreferencesPigeonOptions$Companion.dex
│     │     │  │        │              ├─ SharedPreferencesPigeonOptions.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$clear$1$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$clear$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$dataStoreSetString$2.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getAll$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getBool$1$invokeSuspend$$inlined$map$1$2$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getBool$1$invokeSuspend$$inlined$map$1$2.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getBool$1$invokeSuspend$$inlined$map$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getBool$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getDouble$1$invokeSuspend$$inlined$map$1$2$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getDouble$1$invokeSuspend$$inlined$map$1$2.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getDouble$1$invokeSuspend$$inlined$map$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getDouble$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getInt$1$invokeSuspend$$inlined$map$1$2$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getInt$1$invokeSuspend$$inlined$map$1$2.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getInt$1$invokeSuspend$$inlined$map$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getInt$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getKeys$prefs$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getPrefs$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getString$1$invokeSuspend$$inlined$map$1$2$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getString$1$invokeSuspend$$inlined$map$1$2.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getString$1$invokeSuspend$$inlined$map$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getString$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getValueByKey$$inlined$map$1$2$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getValueByKey$$inlined$map$1$2.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$getValueByKey$$inlined$map$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$readAllKeys$$inlined$map$1$2$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$readAllKeys$$inlined$map$1$2.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$readAllKeys$$inlined$map$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$setBool$1$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$setBool$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$setDeprecatedStringList$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$setDouble$1$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$setDouble$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$setEncodedStringList$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$setInt$1$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$setInt$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin$setString$1.dex
│     │     │  │        │              ├─ SharedPreferencesPlugin.dex
│     │     │  │        │              ├─ SharedPreferencesPluginKt.dex
│     │     │  │        │              ├─ StringListLookupResultType$Companion.dex
│     │     │  │        │              ├─ StringListLookupResultType.dex
│     │     │  │        │              ├─ StringListObjectInputStream.dex
│     │     │  │        │              ├─ StringListResult$Companion.dex
│     │     │  │        │              └─ StringListResult.dex
│     │     │  │        ├─ bundleLibRuntimeToDirDebug_global-synthetics
│     │     │  │        └─ desugar_graph.bin
│     │     │  └─ a274e12671598ded009417d3256a1e06
│     │     │     ├─ results.bin
│     │     │     └─ transformed
│     │     │        └─ classes
│     │     │           ├─ classes_dex
│     │     │           │  └─ classes.dex
│     │     │           └─ classes_global-synthetics
│     │     ├─ generated
│     │     │  ├─ ap_generated_sources
│     │     │  │  └─ debug
│     │     │  │     └─ out
│     │     │  └─ res
│     │     │     ├─ pngs
│     │     │     │  └─ debug
│     │     │     └─ resValues
│     │     │        └─ debug
│     │     ├─ intermediates
│     │     │  ├─ aapt_friendly_merged_manifests
│     │     │  │  └─ debug
│     │     │  │     └─ processDebugManifest
│     │     │  │        └─ aapt
│     │     │  │           ├─ AndroidManifest.xml
│     │     │  │           └─ output-metadata.json
│     │     │  ├─ aar_libs_directory
│     │     │  │  └─ debug
│     │     │  │     └─ syncDebugLibJars
│     │     │  │        └─ libs
│     │     │  ├─ aar_main_jar
│     │     │  │  └─ debug
│     │     │  │     └─ syncDebugLibJars
│     │     │  │        └─ classes.jar
│     │     │  ├─ aar_metadata
│     │     │  │  └─ debug
│     │     │  │     └─ writeDebugAarMetadata
│     │     │  │        └─ aar-metadata.properties
│     │     │  ├─ annotations_typedef_file
│     │     │  │  └─ debug
│     │     │  │     └─ extractDebugAnnotations
│     │     │  │        └─ typedefs.txt
│     │     │  ├─ annotations_zip
│     │     │  │  └─ debug
│     │     │  │     └─ extractDebugAnnotations
│     │     │  ├─ annotation_processor_list
│     │     │  │  └─ debug
│     │     │  │     └─ javaPreCompileDebug
│     │     │  │        └─ annotationProcessors.json
│     │     │  ├─ assets
│     │     │  │  └─ debug
│     │     │  │     └─ mergeDebugAssets
│     │     │  ├─ compiled_local_resources
│     │     │  │  └─ debug
│     │     │  │     └─ compileDebugLibraryResources
│     │     │  │        └─ out
│     │     │  ├─ compile_library_classes_jar
│     │     │  │  └─ debug
│     │     │  │     └─ bundleLibCompileToJarDebug
│     │     │  │        └─ classes.jar
│     │     │  ├─ compile_r_class_jar
│     │     │  │  └─ debug
│     │     │  │     └─ generateDebugRFile
│     │     │  │        └─ R.jar
│     │     │  ├─ compile_symbol_list
│     │     │  │  └─ debug
│     │     │  │     └─ generateDebugRFile
│     │     │  │        └─ R.txt
│     │     │  ├─ data_binding_layout_info_type_package
│     │     │  │  └─ debug
│     │     │  │     └─ packageDebugResources
│     │     │  │        └─ out
│     │     │  ├─ incremental
│     │     │  │  ├─ debug
│     │     │  │  │  └─ packageDebugResources
│     │     │  │  │     ├─ compile-file-map.properties
│     │     │  │  │     ├─ merged.dir
│     │     │  │  │     ├─ merger.xml
│     │     │  │  │     └─ stripped.dir
│     │     │  │  ├─ debug-mergeJavaRes
│     │     │  │  │  ├─ merge-state
│     │     │  │  │  └─ zip-cache
│     │     │  │  ├─ mergeDebugAssets
│     │     │  │  │  └─ merger.xml
│     │     │  │  ├─ mergeDebugJniLibFolders
│     │     │  │  │  └─ merger.xml
│     │     │  │  └─ mergeDebugShaders
│     │     │  │     └─ merger.xml
│     │     │  ├─ javac
│     │     │  │  └─ debug
│     │     │  │     └─ compileDebugJavaWithJavac
│     │     │  │        └─ classes
│     │     │  │           └─ io
│     │     │  │              └─ flutter
│     │     │  │                 └─ plugins
│     │     │  │                    └─ sharedpreferences
│     │     │  │                       ├─ LegacySharedPreferencesPlugin$ListEncoder.class
│     │     │  │                       ├─ LegacySharedPreferencesPlugin.class
│     │     │  │                       ├─ Messages$FlutterError.class
│     │     │  │                       ├─ Messages$PigeonCodec.class
│     │     │  │                       ├─ Messages$SharedPreferencesApi.class
│     │     │  │                       ├─ Messages.class
│     │     │  │                       └─ SharedPreferencesListEncoder.class
│     │     │  ├─ java_res
│     │     │  │  └─ debug
│     │     │  │     └─ processDebugJavaRes
│     │     │  │        └─ out
│     │     │  │           ├─ io
│     │     │  │           │  └─ flutter
│     │     │  │           │     └─ plugins
│     │     │  │           │        └─ sharedpreferences
│     │     │  │           └─ META-INF
│     │     │  │              └─ shared_preferences_android_debug.kotlin_module
│     │     │  ├─ library_and_local_jars_jni
│     │     │  │  └─ debug
│     │     │  │     └─ copyDebugJniLibsProjectAndLocalJars
│     │     │  │        └─ jni
│     │     │  ├─ library_jni
│     │     │  │  └─ debug
│     │     │  │     └─ copyDebugJniLibsProjectOnly
│     │     │  │        └─ jni
│     │     │  ├─ local_only_symbol_list
│     │     │  │  └─ debug
│     │     │  │     └─ parseDebugLocalResources
│     │     │  │        └─ R-def.txt
│     │     │  ├─ manifest_merge_blame_file
│     │     │  │  └─ debug
│     │     │  │     └─ processDebugManifest
│     │     │  │        └─ manifest-merger-blame-debug-report.txt
│     │     │  ├─ merged_java_res
│     │     │  │  └─ debug
│     │     │  │     └─ mergeDebugJavaResource
│     │     │  │        └─ feature-shared_preferences_android.jar
│     │     │  ├─ merged_jni_libs
│     │     │  │  └─ debug
│     │     │  │     └─ mergeDebugJniLibFolders
│     │     │  │        └─ out
│     │     │  ├─ merged_manifest
│     │     │  │  └─ debug
│     │     │  │     └─ processDebugManifest
│     │     │  │        └─ AndroidManifest.xml
│     │     │  ├─ merged_shaders
│     │     │  │  └─ debug
│     │     │  │     └─ mergeDebugShaders
│     │     │  │        └─ out
│     │     │  ├─ navigation_json
│     │     │  │  └─ debug
│     │     │  │     └─ extractDeepLinksDebug
│     │     │  │        └─ navigation.json
│     │     │  ├─ nested_resources_validation_report
│     │     │  │  └─ debug
│     │     │  │     └─ generateDebugResources
│     │     │  │        └─ nestedResourcesValidationReport.txt
│     │     │  ├─ packaged_res
│     │     │  │  └─ debug
│     │     │  │     └─ packageDebugResources
│     │     │  ├─ public_res
│     │     │  │  └─ debug
│     │     │  │     └─ packageDebugResources
│     │     │  ├─ runtime_library_classes_dir
│     │     │  │  └─ debug
│     │     │  │     └─ bundleLibRuntimeToDirDebug
│     │     │  │        ├─ io
│     │     │  │        │  └─ flutter
│     │     │  │        │     └─ plugins
│     │     │  │        │        └─ sharedpreferences
│     │     │  │        │           ├─ LegacySharedPreferencesPlugin$ListEncoder.class
│     │     │  │        │           ├─ LegacySharedPreferencesPlugin.class
│     │     │  │        │           ├─ ListEncoder.class
│     │     │  │        │           ├─ Messages$FlutterError.class
│     │     │  │        │           ├─ Messages$PigeonCodec.class
│     │     │  │        │           ├─ Messages$SharedPreferencesApi.class
│     │     │  │        │           ├─ Messages.class
│     │     │  │        │           ├─ MessagesAsyncPigeonCodec.class
│     │     │  │        │           ├─ MessagesAsyncPigeonUtils.class
│     │     │  │        │           ├─ SharedPreferencesAsyncApi$Companion.class
│     │     │  │        │           ├─ SharedPreferencesAsyncApi.class
│     │     │  │        │           ├─ SharedPreferencesBackend.class
│     │     │  │        │           ├─ SharedPreferencesError.class
│     │     │  │        │           ├─ SharedPreferencesListEncoder.class
│     │     │  │        │           ├─ SharedPreferencesPigeonOptions$Companion.class
│     │     │  │        │           ├─ SharedPreferencesPigeonOptions.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$clear$1$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$clear$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$dataStoreSetString$2.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getAll$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getBool$1$invokeSuspend$$inlined$map$1$2$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getBool$1$invokeSuspend$$inlined$map$1$2.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getBool$1$invokeSuspend$$inlined$map$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getBool$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getDouble$1$invokeSuspend$$inlined$map$1$2$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getDouble$1$invokeSuspend$$inlined$map$1$2.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getDouble$1$invokeSuspend$$inlined$map$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getDouble$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getInt$1$invokeSuspend$$inlined$map$1$2$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getInt$1$invokeSuspend$$inlined$map$1$2.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getInt$1$invokeSuspend$$inlined$map$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getInt$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getKeys$prefs$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getPrefs$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getString$1$invokeSuspend$$inlined$map$1$2$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getString$1$invokeSuspend$$inlined$map$1$2.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getString$1$invokeSuspend$$inlined$map$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getString$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getValueByKey$$inlined$map$1$2$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getValueByKey$$inlined$map$1$2.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$getValueByKey$$inlined$map$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$readAllKeys$$inlined$map$1$2$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$readAllKeys$$inlined$map$1$2.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$readAllKeys$$inlined$map$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$setBool$1$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$setBool$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$setDeprecatedStringList$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$setDouble$1$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$setDouble$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$setEncodedStringList$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$setInt$1$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$setInt$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin$setString$1.class
│     │     │  │        │           ├─ SharedPreferencesPlugin.class
│     │     │  │        │           ├─ SharedPreferencesPluginKt.class
│     │     │  │        │           ├─ StringListLookupResultType$Companion.class
│     │     │  │        │           ├─ StringListLookupResultType.class
│     │     │  │        │           ├─ StringListObjectInputStream.class
│     │     │  │        │           ├─ StringListResult$Companion.class
│     │     │  │        │           └─ StringListResult.class
│     │     │  │        └─ META-INF
│     │     │  │           └─ shared_preferences_android_debug.kotlin_module
│     │     │  ├─ runtime_library_classes_jar
│     │     │  │  └─ debug
│     │     │  │     └─ bundleLibRuntimeToJarDebug
│     │     │  │        └─ classes.jar
│     │     │  └─ symbol_list_with_package_name
│     │     │     └─ debug
│     │     │        └─ generateDebugRFile
│     │     │           └─ package-aware-r.txt
│     │     ├─ kotlin
│     │     │  └─ compileDebugKotlin
│     │     │     ├─ cacheable
│     │     │     │  ├─ caches-jvm
│     │     │     │  │  ├─ inputs
│     │     │     │  │  │  ├─ source-to-output.tab
│     │     │     │  │  │  ├─ source-to-output.tab.keystream
│     │     │     │  │  │  ├─ source-to-output.tab.keystream.len
│     │     │     │  │  │  ├─ source-to-output.tab.len
│     │     │     │  │  │  ├─ source-to-output.tab.values.at
│     │     │     │  │  │  ├─ source-to-output.tab_i
│     │     │     │  │  │  └─ source-to-output.tab_i.len
│     │     │     │  │  ├─ jvm
│     │     │     │  │  │  └─ kotlin
│     │     │     │  │  │     ├─ class-attributes.tab
│     │     │     │  │  │     ├─ class-attributes.tab.keystream
│     │     │     │  │  │     ├─ class-attributes.tab.keystream.len
│     │     │     │  │  │     ├─ class-attributes.tab.len
│     │     │     │  │  │     ├─ class-attributes.tab.values.at
│     │     │     │  │  │     ├─ class-attributes.tab_i
│     │     │     │  │  │     ├─ class-attributes.tab_i.len
│     │     │     │  │  │     ├─ class-fq-name-to-source.tab
│     │     │     │  │  │     ├─ class-fq-name-to-source.tab.keystream
│     │     │     │  │  │     ├─ class-fq-name-to-source.tab.keystream.len
│     │     │     │  │  │     ├─ class-fq-name-to-source.tab.len
│     │     │     │  │  │     ├─ class-fq-name-to-source.tab.values.at
│     │     │     │  │  │     ├─ class-fq-name-to-source.tab_i
│     │     │     │  │  │     ├─ class-fq-name-to-source.tab_i.len
│     │     │     │  │  │     ├─ constants.tab
│     │     │     │  │  │     ├─ constants.tab.keystream
│     │     │     │  │  │     ├─ constants.tab.keystream.len
│     │     │     │  │  │     ├─ constants.tab.len
│     │     │     │  │  │     ├─ constants.tab.values.at
│     │     │     │  │  │     ├─ constants.tab_i
│     │     │     │  │  │     ├─ constants.tab_i.len
│     │     │     │  │  │     ├─ internal-name-to-source.tab
│     │     │     │  │  │     ├─ internal-name-to-source.tab.keystream
│     │     │     │  │  │     ├─ internal-name-to-source.tab.keystream.len
│     │     │     │  │  │     ├─ internal-name-to-source.tab.len
│     │     │     │  │  │     ├─ internal-name-to-source.tab.values.at
│     │     │     │  │  │     ├─ internal-name-to-source.tab_i
│     │     │     │  │  │     ├─ internal-name-to-source.tab_i.len
│     │     │     │  │  │     ├─ package-parts.tab
│     │     │     │  │  │     ├─ package-parts.tab.keystream
│     │     │     │  │  │     ├─ package-parts.tab.keystream.len
│     │     │     │  │  │     ├─ package-parts.tab.len
│     │     │     │  │  │     ├─ package-parts.tab.values.at
│     │     │     │  │  │     ├─ package-parts.tab_i
│     │     │     │  │  │     ├─ package-parts.tab_i.len
│     │     │     │  │  │     ├─ proto.tab
│     │     │     │  │  │     ├─ proto.tab.keystream
│     │     │     │  │  │     ├─ proto.tab.keystream.len
│     │     │     │  │  │     ├─ proto.tab.len
│     │     │     │  │  │     ├─ proto.tab.values.at
│     │     │     │  │  │     ├─ proto.tab_i
│     │     │     │  │  │     ├─ proto.tab_i.len
│     │     │     │  │  │     ├─ source-to-classes.tab
│     │     │     │  │  │     ├─ source-to-classes.tab.keystream
│     │     │     │  │  │     ├─ source-to-classes.tab.keystream.len
│     │     │     │  │  │     ├─ source-to-classes.tab.len
│     │     │     │  │  │     ├─ source-to-classes.tab.values.at
│     │     │     │  │  │     ├─ source-to-classes.tab_i
│     │     │     │  │  │     ├─ source-to-classes.tab_i.len
│     │     │     │  │  │     ├─ subtypes.tab
│     │     │     │  │  │     ├─ subtypes.tab.keystream
│     │     │     │  │  │     ├─ subtypes.tab.keystream.len
│     │     │     │  │  │     ├─ subtypes.tab.len
│     │     │     │  │  │     ├─ subtypes.tab.values.at
│     │     │     │  │  │     ├─ subtypes.tab_i
│     │     │     │  │  │     ├─ subtypes.tab_i.len
│     │     │     │  │  │     ├─ supertypes.tab
│     │     │     │  │  │     ├─ supertypes.tab.keystream
│     │     │     │  │  │     ├─ supertypes.tab.keystream.len
│     │     │     │  │  │     ├─ supertypes.tab.len
│     │     │     │  │  │     ├─ supertypes.tab.values.at
│     │     │     │  │  │     ├─ supertypes.tab_i
│     │     │     │  │  │     └─ supertypes.tab_i.len
│     │     │     │  │  └─ lookups
│     │     │     │  │     ├─ counters.tab
│     │     │     │  │     ├─ file-to-id.tab
│     │     │     │  │     ├─ file-to-id.tab.keystream
│     │     │     │  │     ├─ file-to-id.tab.keystream.len
│     │     │     │  │     ├─ file-to-id.tab.len
│     │     │     │  │     ├─ file-to-id.tab.values.at
│     │     │     │  │     ├─ file-to-id.tab_i
│     │     │     │  │     ├─ file-to-id.tab_i.len
│     │     │     │  │     ├─ id-to-file.tab
│     │     │     │  │     ├─ id-to-file.tab.keystream
│     │     │     │  │     ├─ id-to-file.tab.keystream.len
│     │     │     │  │     ├─ id-to-file.tab.len
│     │     │     │  │     ├─ id-to-file.tab.values.at
│     │     │     │  │     ├─ id-to-file.tab_i
│     │     │     │  │     ├─ id-to-file.tab_i.len
│     │     │     │  │     ├─ lookups.tab
│     │     │     │  │     ├─ lookups.tab.keystream
│     │     │     │  │     ├─ lookups.tab.keystream.len
│     │     │     │  │     ├─ lookups.tab.len
│     │     │     │  │     ├─ lookups.tab.values.at
│     │     │     │  │     ├─ lookups.tab_i
│     │     │     │  │     └─ lookups.tab_i.len
│     │     │     │  └─ last-build.bin
│     │     │     ├─ classpath-snapshot
│     │     │     │  └─ shrunk-classpath-snapshot.bin
│     │     │     └─ local-state
│     │     ├─ outputs
│     │     │  ├─ aar
│     │     │  │  └─ shared_preferences_android-debug.aar
│     │     │  └─ logs
│     │     │     └─ manifest-merger-debug-report.txt
│     │     └─ tmp
│     │        ├─ compileDebugJavaWithJavac
│     │        │  └─ previous-compilation-data.bin
│     │        └─ kotlin-classes
│     │           └─ debug
│     │              ├─ io
│     │              │  └─ flutter
│     │              │     └─ plugins
│     │              │        └─ sharedpreferences
│     │              │           ├─ ListEncoder.class
│     │              │           ├─ MessagesAsyncPigeonCodec.class
│     │              │           ├─ MessagesAsyncPigeonUtils.class
│     │              │           ├─ SharedPreferencesAsyncApi$Companion.class
│     │              │           ├─ SharedPreferencesAsyncApi.class
│     │              │           ├─ SharedPreferencesBackend.class
│     │              │           ├─ SharedPreferencesError.class
│     │              │           ├─ SharedPreferencesPigeonOptions$Companion.class
│     │              │           ├─ SharedPreferencesPigeonOptions.class
│     │              │           ├─ SharedPreferencesPlugin$clear$1$1.class
│     │              │           ├─ SharedPreferencesPlugin$clear$1.class
│     │              │           ├─ SharedPreferencesPlugin$dataStoreSetString$2.class
│     │              │           ├─ SharedPreferencesPlugin$getAll$1.class
│     │              │           ├─ SharedPreferencesPlugin$getBool$1$invokeSuspend$$inlined$map$1$2$1.class
│     │              │           ├─ SharedPreferencesPlugin$getBool$1$invokeSuspend$$inlined$map$1$2.class
│     │              │           ├─ SharedPreferencesPlugin$getBool$1$invokeSuspend$$inlined$map$1.class
│     │              │           ├─ SharedPreferencesPlugin$getBool$1.class
│     │              │           ├─ SharedPreferencesPlugin$getDouble$1$invokeSuspend$$inlined$map$1$2$1.class
│     │              │           ├─ SharedPreferencesPlugin$getDouble$1$invokeSuspend$$inlined$map$1$2.class
│     │              │           ├─ SharedPreferencesPlugin$getDouble$1$invokeSuspend$$inlined$map$1.class
│     │              │           ├─ SharedPreferencesPlugin$getDouble$1.class
│     │              │           ├─ SharedPreferencesPlugin$getInt$1$invokeSuspend$$inlined$map$1$2$1.class
│     │              │           ├─ SharedPreferencesPlugin$getInt$1$invokeSuspend$$inlined$map$1$2.class
│     │              │           ├─ SharedPreferencesPlugin$getInt$1$invokeSuspend$$inlined$map$1.class
│     │              │           ├─ SharedPreferencesPlugin$getInt$1.class
│     │              │           ├─ SharedPreferencesPlugin$getKeys$prefs$1.class
│     │              │           ├─ SharedPreferencesPlugin$getPrefs$1.class
│     │              │           ├─ SharedPreferencesPlugin$getString$1$invokeSuspend$$inlined$map$1$2$1.class
│     │              │           ├─ SharedPreferencesPlugin$getString$1$invokeSuspend$$inlined$map$1$2.class
│     │              │           ├─ SharedPreferencesPlugin$getString$1$invokeSuspend$$inlined$map$1.class
│     │              │           ├─ SharedPreferencesPlugin$getString$1.class
│     │              │           ├─ SharedPreferencesPlugin$getValueByKey$$inlined$map$1$2$1.class
│     │              │           ├─ SharedPreferencesPlugin$getValueByKey$$inlined$map$1$2.class
│     │              │           ├─ SharedPreferencesPlugin$getValueByKey$$inlined$map$1.class
│     │              │           ├─ SharedPreferencesPlugin$readAllKeys$$inlined$map$1$2$1.class
│     │              │           ├─ SharedPreferencesPlugin$readAllKeys$$inlined$map$1$2.class
│     │              │           ├─ SharedPreferencesPlugin$readAllKeys$$inlined$map$1.class
│     │              │           ├─ SharedPreferencesPlugin$setBool$1$1.class
│     │              │           ├─ SharedPreferencesPlugin$setBool$1.class
│     │              │           ├─ SharedPreferencesPlugin$setDeprecatedStringList$1.class
│     │              │           ├─ SharedPreferencesPlugin$setDouble$1$1.class
│     │              │           ├─ SharedPreferencesPlugin$setDouble$1.class
│     │              │           ├─ SharedPreferencesPlugin$setEncodedStringList$1.class
│     │              │           ├─ SharedPreferencesPlugin$setInt$1$1.class
│     │              │           ├─ SharedPreferencesPlugin$setInt$1.class
│     │              │           ├─ SharedPreferencesPlugin$setString$1.class
│     │              │           ├─ SharedPreferencesPlugin.class
│     │              │           ├─ SharedPreferencesPluginKt.class
│     │              │           ├─ StringListLookupResultType$Companion.class
│     │              │           ├─ StringListLookupResultType.class
│     │              │           ├─ StringListObjectInputStream.class
│     │              │           ├─ StringListResult$Companion.class
│     │              │           └─ StringListResult.class
│     │              └─ META-INF
│     │                 └─ shared_preferences_android_debug.kotlin_module
│     ├─ devtools_options.yaml
│     ├─ firestore
│     │  └─ rule.txt
│     ├─ ios
│     │  ├─ Flutter
│     │  │  ├─ AppFrameworkInfo.plist
│     │  │  ├─ Debug.xcconfig
│     │  │  ├─ ephemeral
│     │  │  │  ├─ flutter_lldbinit
│     │  │  │  └─ flutter_lldb_helper.py
│     │  │  ├─ flutter_export_environment.sh
│     │  │  ├─ Generated.xcconfig
│     │  │  └─ Release.xcconfig
│     │  ├─ Podfile
│     │  ├─ Runner
│     │  │  ├─ AppDelegate.swift
│     │  │  ├─ Assets.xcassets
│     │  │  │  ├─ AppIcon.appiconset
│     │  │  │  │  ├─ Contents.json
│     │  │  │  │  ├─ Icon-App-1024x1024@1x.png
│     │  │  │  │  ├─ Icon-App-20x20@1x.png
│     │  │  │  │  ├─ Icon-App-20x20@2x.png
│     │  │  │  │  ├─ Icon-App-20x20@3x.png
│     │  │  │  │  ├─ Icon-App-29x29@1x.png
│     │  │  │  │  ├─ Icon-App-29x29@2x.png
│     │  │  │  │  ├─ Icon-App-29x29@3x.png
│     │  │  │  │  ├─ Icon-App-40x40@1x.png
│     │  │  │  │  ├─ Icon-App-40x40@2x.png
│     │  │  │  │  ├─ Icon-App-40x40@3x.png
│     │  │  │  │  ├─ Icon-App-60x60@2x.png
│     │  │  │  │  ├─ Icon-App-60x60@3x.png
│     │  │  │  │  ├─ Icon-App-76x76@1x.png
│     │  │  │  │  ├─ Icon-App-76x76@2x.png
│     │  │  │  │  └─ Icon-App-83.5x83.5@2x.png
│     │  │  │  └─ LaunchImage.imageset
│     │  │  │     ├─ Contents.json
│     │  │  │     ├─ LaunchImage.png
│     │  │  │     ├─ LaunchImage@2x.png
│     │  │  │     ├─ LaunchImage@3x.png
│     │  │  │     └─ README.md
│     │  │  ├─ Base.lproj
│     │  │  │  ├─ LaunchScreen.storyboard
│     │  │  │  └─ Main.storyboard
│     │  │  ├─ GeneratedPluginRegistrant.h
│     │  │  ├─ GeneratedPluginRegistrant.m
│     │  │  ├─ Info.plist
│     │  │  └─ Runner-Bridging-Header.h
│     │  ├─ Runner.xcodeproj
│     │  │  ├─ project.pbxproj
│     │  │  ├─ project.xcworkspace
│     │  │  │  ├─ contents.xcworkspacedata
│     │  │  │  └─ xcshareddata
│     │  │  │     ├─ IDEWorkspaceChecks.plist
│     │  │  │     └─ WorkspaceSettings.xcsettings
│     │  │  └─ xcshareddata
│     │  │     └─ xcschemes
│     │  │        └─ Runner.xcscheme
│     │  ├─ Runner.xcworkspace
│     │  │  ├─ contents.xcworkspacedata
│     │  │  └─ xcshareddata
│     │  │     ├─ IDEWorkspaceChecks.plist
│     │  │     └─ WorkspaceSettings.xcsettings
│     │  └─ RunnerTests
│     │     └─ RunnerTests.swift
│     ├─ lib
│     │  ├─ backend
│     │  │  ├─ models
│     │  │  │  ├─ app_task.dart
│     │  │  │  ├─ breathing_session_entry.dart
│     │  │  │  ├─ calendar_schedule.dart
│     │  │  │  ├─ chat_session.dart
│     │  │  │  ├─ weekly_analysis_data.dart
│     │  │  │  └─ wellness_mood_entry.dart
│     │  │  └─ services
│     │  │     ├─ ai_chat_firestore_service.dart
│     │  │     ├─ ai_chat_service.dart
│     │  │     ├─ auth_service.dart
│     │  │     ├─ calendar_service.dart
│     │  │     ├─ home_profile_service.dart
│     │  │     ├─ messaging_service.dart
│     │  │     ├─ notification_service.dart
│     │  │     ├─ pomodoro_service.dart
│     │  │     ├─ profilePage_services.dart
│     │  │     ├─ study_session_service.dart
│     │  │     ├─ task_firestore_service.dart
│     │  │     ├─ weekly_analysis_services.dart
│     │  │     └─ wellness_service.dart
│     │  ├─ frontend
│     │  │  ├─ main_screens
│     │  │  │  ├─ ai_screen.dart
│     │  │  │  ├─ home_screen.dart
│     │  │  │  ├─ profile_screen.dart
│     │  │  │  └─ search_screen.dart
│     │  │  └─ pages
│     │  │     ├─ ai_history_screen.dart
│     │  │     ├─ box_breathing_screen.dart
│     │  │     ├─ calendar_screen.dart
│     │  │     ├─ coursework_breakdown_screen.dart
│     │  │     ├─ forgot_password_page.dart
│     │  │     ├─ home_page.dart
│     │  │     ├─ login_page.dart
│     │  │     ├─ mood_tracker.dart
│     │  │     ├─ pomodoro_tab.dart
│     │  │     ├─ signup_page.dart
│     │  │     ├─ task_manager_screen.dart
│     │  │     ├─ weekly_analysis_screen.dart
│     │  │     └─ wellness_hub_screen.dart
│     │  └─ main.dart
│     ├─ linux
│     │  ├─ CMakeLists.txt
│     │  ├─ flutter
│     │  │  ├─ CMakeLists.txt
│     │  │  ├─ generated_plugins.cmake
│     │  │  ├─ generated_plugin_registrant.cc
│     │  │  └─ generated_plugin_registrant.h
│     │  └─ runner
│     │     ├─ CMakeLists.txt
│     │     ├─ main.cc
│     │     ├─ my_application.cc
│     │     └─ my_application.h
│     ├─ macos
│     │  ├─ Flutter
│     │  │  ├─ ephemeral
│     │  │  │  ├─ Flutter-Generated.xcconfig
│     │  │  │  └─ flutter_export_environment.sh
│     │  │  ├─ Flutter-Debug.xcconfig
│     │  │  ├─ Flutter-Release.xcconfig
│     │  │  └─ GeneratedPluginRegistrant.swift
│     │  ├─ Podfile
│     │  ├─ Runner
│     │  │  ├─ AppDelegate.swift
│     │  │  ├─ Assets.xcassets
│     │  │  │  └─ AppIcon.appiconset
│     │  │  │     ├─ app_icon_1024.png
│     │  │  │     ├─ app_icon_128.png
│     │  │  │     ├─ app_icon_16.png
│     │  │  │     ├─ app_icon_256.png
│     │  │  │     ├─ app_icon_32.png
│     │  │  │     ├─ app_icon_512.png
│     │  │  │     ├─ app_icon_64.png
│     │  │  │     └─ Contents.json
│     │  │  ├─ Base.lproj
│     │  │  │  └─ MainMenu.xib
│     │  │  ├─ Configs
│     │  │  │  ├─ AppInfo.xcconfig
│     │  │  │  ├─ Debug.xcconfig
│     │  │  │  ├─ Release.xcconfig
│     │  │  │  └─ Warnings.xcconfig
│     │  │  ├─ DebugProfile.entitlements
│     │  │  ├─ Info.plist
│     │  │  ├─ MainFlutterWindow.swift
│     │  │  └─ Release.entitlements
│     │  ├─ Runner.xcodeproj
│     │  │  ├─ project.pbxproj
│     │  │  ├─ project.xcworkspace
│     │  │  │  └─ xcshareddata
│     │  │  │     └─ IDEWorkspaceChecks.plist
│     │  │  └─ xcshareddata
│     │  │     └─ xcschemes
│     │  │        └─ Runner.xcscheme
│     │  ├─ Runner.xcworkspace
│     │  │  ├─ contents.xcworkspacedata
│     │  │  └─ xcshareddata
│     │  │     └─ IDEWorkspaceChecks.plist
│     │  └─ RunnerTests
│     │     └─ RunnerTests.swift
│     ├─ pubspec.lock
│     ├─ pubspec.yaml
│     ├─ README.md
│     ├─ test
│     │  └─ widget_test.dart
│     ├─ web
│     │  ├─ favicon.png
│     │  ├─ icons
│     │  │  ├─ Icon-192.png
│     │  │  ├─ Icon-512.png
│     │  │  ├─ Icon-maskable-192.png
│     │  │  └─ Icon-maskable-512.png
│     │  ├─ index.html
│     │  └─ manifest.json
│     └─ windows
│        ├─ CMakeLists.txt
│        ├─ flutter
│        │  ├─ CMakeLists.txt
│        │  ├─ ephemeral
│        │  │  └─ .plugin_symlinks
│        │  │     ├─ cloud_firestore
│        │  │     │  ├─ android
│        │  │     │  │  ├─ .gradle
│        │  │     │  │  │  ├─ 8.9
│        │  │     │  │  │  │  ├─ checksums
│        │  │     │  │  │  │  │  └─ checksums.lock
│        │  │     │  │  │  │  ├─ fileChanges
│        │  │     │  │  │  │  │  └─ last-build.bin
│        │  │     │  │  │  │  ├─ fileHashes
│        │  │     │  │  │  │  │  └─ fileHashes.lock
│        │  │     │  │  │  │  ├─ gc.properties
│        │  │     │  │  │  │  └─ vcsMetadata
│        │  │     │  │  │  ├─ buildOutputCleanup
│        │  │     │  │  │  │  ├─ buildOutputCleanup.lock
│        │  │     │  │  │  │  └─ cache.properties
│        │  │     │  │  │  └─ vcs-1
│        │  │     │  │  │     └─ gc.properties
│        │  │     │  │  ├─ build.gradle
│        │  │     │  │  ├─ local-config.gradle
│        │  │     │  │  ├─ settings.gradle
│        │  │     │  │  ├─ src
│        │  │     │  │  │  └─ main
│        │  │     │  │  │     ├─ AndroidManifest.xml
│        │  │     │  │  │     └─ java
│        │  │     │  │  │        └─ io
│        │  │     │  │  │           └─ flutter
│        │  │     │  │  │              └─ plugins
│        │  │     │  │  │                 └─ firebase
│        │  │     │  │  │                    └─ firestore
│        │  │     │  │  │                       ├─ FlutterFirebaseFirestoreException.java
│        │  │     │  │  │                       ├─ FlutterFirebaseFirestoreExtension.java
│        │  │     │  │  │                       ├─ FlutterFirebaseFirestoreMessageCodec.java
│        │  │     │  │  │                       ├─ FlutterFirebaseFirestorePlugin.java
│        │  │     │  │  │                       ├─ FlutterFirebaseFirestoreRegistrar.java
│        │  │     │  │  │                       ├─ FlutterFirebaseFirestoreTransactionResult.java
│        │  │     │  │  │                       ├─ GeneratedAndroidFirebaseFirestore.java
│        │  │     │  │  │                       ├─ streamhandler
│        │  │     │  │  │                       │  ├─ DocumentSnapshotsStreamHandler.java
│        │  │     │  │  │                       │  ├─ LoadBundleStreamHandler.java
│        │  │     │  │  │                       │  ├─ OnTransactionResultListener.java
│        │  │     │  │  │                       │  ├─ QuerySnapshotsStreamHandler.java
│        │  │     │  │  │                       │  ├─ SnapshotsInSyncStreamHandler.java
│        │  │     │  │  │                       │  └─ TransactionStreamHandler.java
│        │  │     │  │  │                       └─ utils
│        │  │     │  │  │                          ├─ ExceptionConverter.java
│        │  │     │  │  │                          ├─ PigeonParser.java
│        │  │     │  │  │                          └─ ServerTimestampBehaviorConverter.java
│        │  │     │  │  └─ user-agent.gradle
│        │  │     │  ├─ CHANGELOG.md
│        │  │     │  ├─ dartpad
│        │  │     │  │  ├─ dartpad_metadata.yaml
│        │  │     │  │  └─ lib
│        │  │     │  │     └─ main.dart
│        │  │     │  ├─ example
│        │  │     │  │  ├─ analysis_options.yaml
│        │  │     │  │  ├─ android
│        │  │     │  │  │  ├─ app
│        │  │     │  │  │  │  ├─ build.gradle
│        │  │     │  │  │  │  ├─ google-services.json
│        │  │     │  │  │  │  └─ src
│        │  │     │  │  │  │     ├─ debug
│        │  │     │  │  │  │     │  └─ AndroidManifest.xml
│        │  │     │  │  │  │     ├─ main
│        │  │     │  │  │  │     │  ├─ AndroidManifest.xml
│        │  │     │  │  │  │     │  ├─ java
│        │  │     │  │  │  │     │  │  └─ io
│        │  │     │  │  │  │     │  │     └─ flutter
│        │  │     │  │  │  │     │  │        └─ plugins
│        │  │     │  │  │  │     │  ├─ kotlin
│        │  │     │  │  │  │     │  │  └─ io
│        │  │     │  │  │  │     │  │     └─ flutter
│        │  │     │  │  │  │     │  │        └─ plugins
│        │  │     │  │  │  │     │  │           └─ firebase
│        │  │     │  │  │  │     │  │              └─ firestore
│        │  │     │  │  │  │     │  │                 └─ example
│        │  │     │  │  │  │     │  │                    └─ MainActivity.kt
│        │  │     │  │  │  │     │  └─ res
│        │  │     │  │  │  │     │     ├─ drawable
│        │  │     │  │  │  │     │     │  └─ launch_background.xml
│        │  │     │  │  │  │     │     ├─ drawable-v21
│        │  │     │  │  │  │     │     │  └─ launch_background.xml
│        │  │     │  │  │  │     │     ├─ mipmap-hdpi
│        │  │     │  │  │  │     │     │  └─ ic_launcher.png
│        │  │     │  │  │  │     │     ├─ mipmap-mdpi
│        │  │     │  │  │  │     │     │  └─ ic_launcher.png
│        │  │     │  │  │  │     │     ├─ mipmap-xhdpi
│        │  │     │  │  │  │     │     │  └─ ic_launcher.png
│        │  │     │  │  │  │     │     ├─ mipmap-xxhdpi
│        │  │     │  │  │  │     │     │  └─ ic_launcher.png
│        │  │     │  │  │  │     │     ├─ mipmap-xxxhdpi
│        │  │     │  │  │  │     │     │  └─ ic_launcher.png
│        │  │     │  │  │  │     │     ├─ values
│        │  │     │  │  │  │     │     │  └─ styles.xml
│        │  │     │  │  │  │     │     └─ values-night
│        │  │     │  │  │  │     │        └─ styles.xml
│        │  │     │  │  │  │     └─ profile
│        │  │     │  │  │  │        └─ AndroidManifest.xml
│        │  │     │  │  │  ├─ build.gradle
│        │  │     │  │  │  ├─ gradle
│        │  │     │  │  │  │  └─ wrapper
│        │  │     │  │  │  │     └─ gradle-wrapper.properties
│        │  │     │  │  │  ├─ gradle.properties
│        │  │     │  │  │  └─ settings.gradle
│        │  │     │  │  ├─ firebase.json
│        │  │     │  │  ├─ integration_test
│        │  │     │  │  │  ├─ collection_reference_e2e.dart
│        │  │     │  │  │  ├─ document_change_e2e.dart
│        │  │     │  │  │  ├─ document_reference_e2e.dart
│        │  │     │  │  │  ├─ e2e_test.dart
│        │  │     │  │  │  ├─ field_value_e2e.dart
│        │  │     │  │  │  ├─ firebase_options.dart
│        │  │     │  │  │  ├─ firebase_options_secondary.dart
│        │  │     │  │  │  ├─ geo_point_e2e.dart
│        │  │     │  │  │  ├─ instance_e2e.dart
│        │  │     │  │  │  ├─ load_bundle_e2e.dart
│        │  │     │  │  │  ├─ query_e2e.dart
│        │  │     │  │  │  ├─ second_database.dart
│        │  │     │  │  │  ├─ settings_e2e.dart
│        │  │     │  │  │  ├─ snapshot_metadata_e2e.dart
│        │  │     │  │  │  ├─ timestamp_e2e.dart
│        │  │     │  │  │  ├─ transaction_e2e.dart
│        │  │     │  │  │  ├─ vector_value_e2e.dart
│        │  │     │  │  │  ├─ web_snapshot_listeners.dart
│        │  │     │  │  │  └─ write_batch_e2e.dart
│        │  │     │  │  ├─ ios
│        │  │     │  │  │  ├─ firebase_app_id_file.json
│        │  │     │  │  │  ├─ Flutter
│        │  │     │  │  │  │  ├─ AppFrameworkInfo.plist
│        │  │     │  │  │  │  ├─ Debug.xcconfig
│        │  │     │  │  │  │  └─ Release.xcconfig
│        │  │     │  │  │  ├─ Podfile
│        │  │     │  │  │  ├─ Runner
│        │  │     │  │  │  │  ├─ AppDelegate.swift
│        │  │     │  │  │  │  ├─ Assets.xcassets
│        │  │     │  │  │  │  │  ├─ AppIcon.appiconset
│        │  │     │  │  │  │  │  │  ├─ Contents.json
│        │  │     │  │  │  │  │  │  ├─ Icon-App-1024x1024@1x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@1x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@2x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@3x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@1x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@2x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@3x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@1x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@2x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@3x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-60x60@2x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-60x60@3x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-76x76@1x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-76x76@2x.png
│        │  │     │  │  │  │  │  │  └─ Icon-App-83.5x83.5@2x.png
│        │  │     │  │  │  │  │  └─ LaunchImage.imageset
│        │  │     │  │  │  │  │     ├─ Contents.json
│        │  │     │  │  │  │  │     ├─ LaunchImage.png
│        │  │     │  │  │  │  │     ├─ LaunchImage@2x.png
│        │  │     │  │  │  │  │     ├─ LaunchImage@3x.png
│        │  │     │  │  │  │  │     └─ README.md
│        │  │     │  │  │  │  ├─ Base.lproj
│        │  │     │  │  │  │  │  ├─ LaunchScreen.storyboard
│        │  │     │  │  │  │  │  └─ Main.storyboard
│        │  │     │  │  │  │  ├─ GoogleService-Info.plist
│        │  │     │  │  │  │  ├─ Info.plist
│        │  │     │  │  │  │  └─ Runner-Bridging-Header.h
│        │  │     │  │  │  ├─ Runner.xcodeproj
│        │  │     │  │  │  │  ├─ project.pbxproj
│        │  │     │  │  │  │  ├─ project.xcworkspace
│        │  │     │  │  │  │  │  ├─ contents.xcworkspacedata
│        │  │     │  │  │  │  │  └─ xcshareddata
│        │  │     │  │  │  │  │     ├─ IDEWorkspaceChecks.plist
│        │  │     │  │  │  │  │     ├─ swiftpm
│        │  │     │  │  │  │  │     │  └─ configuration
│        │  │     │  │  │  │  │     └─ WorkspaceSettings.xcsettings
│        │  │     │  │  │  │  └─ xcshareddata
│        │  │     │  │  │  │     └─ xcschemes
│        │  │     │  │  │  │        └─ Runner.xcscheme
│        │  │     │  │  │  └─ Runner.xcworkspace
│        │  │     │  │  │     ├─ contents.xcworkspacedata
│        │  │     │  │  │     └─ xcshareddata
│        │  │     │  │  │        ├─ IDEWorkspaceChecks.plist
│        │  │     │  │  │        ├─ swiftpm
│        │  │     │  │  │        │  └─ configuration
│        │  │     │  │  │        └─ WorkspaceSettings.xcsettings
│        │  │     │  │  ├─ lib
│        │  │     │  │  │  ├─ firebase_options.dart
│        │  │     │  │  │  └─ main.dart
│        │  │     │  │  ├─ macos
│        │  │     │  │  │  ├─ firebase_app_id_file.json
│        │  │     │  │  │  ├─ Flutter
│        │  │     │  │  │  │  ├─ Flutter-Debug.xcconfig
│        │  │     │  │  │  │  └─ Flutter-Release.xcconfig
│        │  │     │  │  │  ├─ Podfile
│        │  │     │  │  │  ├─ Runner
│        │  │     │  │  │  │  ├─ AppDelegate.swift
│        │  │     │  │  │  │  ├─ Assets.xcassets
│        │  │     │  │  │  │  │  └─ AppIcon.appiconset
│        │  │     │  │  │  │  │     ├─ app_icon_1024.png
│        │  │     │  │  │  │  │     ├─ app_icon_128.png
│        │  │     │  │  │  │  │     ├─ app_icon_16.png
│        │  │     │  │  │  │  │     ├─ app_icon_256.png
│        │  │     │  │  │  │  │     ├─ app_icon_32.png
│        │  │     │  │  │  │  │     ├─ app_icon_512.png
│        │  │     │  │  │  │  │     ├─ app_icon_64.png
│        │  │     │  │  │  │  │     └─ Contents.json
│        │  │     │  │  │  │  ├─ Base.lproj
│        │  │     │  │  │  │  │  └─ MainMenu.xib
│        │  │     │  │  │  │  ├─ Configs
│        │  │     │  │  │  │  │  ├─ AppInfo.xcconfig
│        │  │     │  │  │  │  │  ├─ Debug.xcconfig
│        │  │     │  │  │  │  │  ├─ Release.xcconfig
│        │  │     │  │  │  │  │  └─ Warnings.xcconfig
│        │  │     │  │  │  │  ├─ DebugProfile.entitlements
│        │  │     │  │  │  │  ├─ GoogleService-Info.plist
│        │  │     │  │  │  │  ├─ Info.plist
│        │  │     │  │  │  │  ├─ MainFlutterWindow.swift
│        │  │     │  │  │  │  └─ Release.entitlements
│        │  │     │  │  │  ├─ Runner.xcodeproj
│        │  │     │  │  │  │  ├─ project.pbxproj
│        │  │     │  │  │  │  ├─ project.xcworkspace
│        │  │     │  │  │  │  │  └─ xcshareddata
│        │  │     │  │  │  │  │     ├─ IDEWorkspaceChecks.plist
│        │  │     │  │  │  │  │     └─ swiftpm
│        │  │     │  │  │  │  │        └─ configuration
│        │  │     │  │  │  │  └─ xcshareddata
│        │  │     │  │  │  │     └─ xcschemes
│        │  │     │  │  │  │        └─ Runner.xcscheme
│        │  │     │  │  │  ├─ Runner.xcworkspace
│        │  │     │  │  │  │  ├─ contents.xcworkspacedata
│        │  │     │  │  │  │  └─ xcshareddata
│        │  │     │  │  │  │     ├─ IDEWorkspaceChecks.plist
│        │  │     │  │  │  │     └─ swiftpm
│        │  │     │  │  │  │        └─ configuration
│        │  │     │  │  │  └─ RunnerTests
│        │  │     │  │  │     └─ RunnerTests.swift
│        │  │     │  │  ├─ pubspec.yaml
│        │  │     │  │  ├─ README.md
│        │  │     │  │  ├─ test_driver
│        │  │     │  │  │  └─ integration_test.dart
│        │  │     │  │  ├─ web
│        │  │     │  │  │  ├─ favicon.png
│        │  │     │  │  │  ├─ icons
│        │  │     │  │  │  │  ├─ Icon-192.png
│        │  │     │  │  │  │  ├─ Icon-512.png
│        │  │     │  │  │  │  ├─ Icon-maskable-192.png
│        │  │     │  │  │  │  └─ Icon-maskable-512.png
│        │  │     │  │  │  ├─ index.html
│        │  │     │  │  │  ├─ manifest.json
│        │  │     │  │  │  └─ wasm_index.html
│        │  │     │  │  └─ windows
│        │  │     │  │     ├─ CMakeLists.txt
│        │  │     │  │     ├─ flutter
│        │  │     │  │     │  └─ CMakeLists.txt
│        │  │     │  │     └─ runner
│        │  │     │  │        ├─ CMakeLists.txt
│        │  │     │  │        ├─ flutter_window.cpp
│        │  │     │  │        ├─ flutter_window.h
│        │  │     │  │        ├─ main.cpp
│        │  │     │  │        ├─ resource.h
│        │  │     │  │        ├─ resources
│        │  │     │  │        │  └─ app_icon.ico
│        │  │     │  │        ├─ runner.exe.manifest
│        │  │     │  │        ├─ Runner.rc
│        │  │     │  │        ├─ utils.cpp
│        │  │     │  │        ├─ utils.h
│        │  │     │  │        ├─ win32_window.cpp
│        │  │     │  │        └─ win32_window.h
│        │  │     │  ├─ ios
│        │  │     │  │  ├─ cloud_firestore
│        │  │     │  │  │  ├─ Package.swift
│        │  │     │  │  │  └─ Sources
│        │  │     │  │  │     └─ cloud_firestore
│        │  │     │  │  │        ├─ FirestoreMessages.g.m
│        │  │     │  │  │        ├─ FirestorePigeonParser.m
│        │  │     │  │  │        ├─ FLTDocumentSnapshotStreamHandler.m
│        │  │     │  │  │        ├─ FLTFirebaseFirestoreExtension.m
│        │  │     │  │  │        ├─ FLTFirebaseFirestorePlugin.m
│        │  │     │  │  │        ├─ FLTFirebaseFirestoreReader.m
│        │  │     │  │  │        ├─ FLTFirebaseFirestoreUtils.m
│        │  │     │  │  │        ├─ FLTFirebaseFirestoreWriter.m
│        │  │     │  │  │        ├─ FLTFirestoreClientLanguage.mm
│        │  │     │  │  │        ├─ FLTLoadBundleStreamHandler.m
│        │  │     │  │  │        ├─ FLTQuerySnapshotStreamHandler.m
│        │  │     │  │  │        ├─ FLTSnapshotsInSyncStreamHandler.m
│        │  │     │  │  │        ├─ FLTTransactionStreamHandler.m
│        │  │     │  │  │        ├─ include
│        │  │     │  │  │        │  └─ cloud_firestore
│        │  │     │  │  │        │     ├─ Private
│        │  │     │  │  │        │     │  ├─ FirestorePigeonParser.h
│        │  │     │  │  │        │     │  ├─ FLTDocumentSnapshotStreamHandler.h
│        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreExtension.h
│        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreReader.h
│        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreUtils.h
│        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreWriter.h
│        │  │     │  │  │        │     │  ├─ FLTLoadBundleStreamHandler.h
│        │  │     │  │  │        │     │  ├─ FLTQuerySnapshotStreamHandler.h
│        │  │     │  │  │        │     │  ├─ FLTSnapshotsInSyncStreamHandler.h
│        │  │     │  │  │        │     │  └─ FLTTransactionStreamHandler.h
│        │  │     │  │  │        │     └─ Public
│        │  │     │  │  │        │        ├─ CustomPigeonHeaderFirestore.h
│        │  │     │  │  │        │        ├─ FirestoreMessages.g.h
│        │  │     │  │  │        │        └─ FLTFirebaseFirestorePlugin.h
│        │  │     │  │  │        └─ Resources
│        │  │     │  │  ├─ cloud_firestore.podspec
│        │  │     │  │  └─ generated_firebase_sdk_version.txt
│        │  │     │  ├─ lib
│        │  │     │  │  ├─ cloud_firestore.dart
│        │  │     │  │  └─ src
│        │  │     │  │     ├─ aggregate_query.dart
│        │  │     │  │     ├─ aggregate_query_snapshot.dart
│        │  │     │  │     ├─ collection_reference.dart
│        │  │     │  │     ├─ document_change.dart
│        │  │     │  │     ├─ document_reference.dart
│        │  │     │  │     ├─ document_snapshot.dart
│        │  │     │  │     ├─ field_value.dart
│        │  │     │  │     ├─ filters.dart
│        │  │     │  │     ├─ firestore.dart
│        │  │     │  │     ├─ load_bundle_task.dart
│        │  │     │  │     ├─ load_bundle_task_snapshot.dart
│        │  │     │  │     ├─ persistent_cache_index_manager.dart
│        │  │     │  │     ├─ query.dart
│        │  │     │  │     ├─ query_document_snapshot.dart
│        │  │     │  │     ├─ query_snapshot.dart
│        │  │     │  │     ├─ snapshot_metadata.dart
│        │  │     │  │     ├─ transaction.dart
│        │  │     │  │     ├─ utils
│        │  │     │  │     │  └─ codec_utility.dart
│        │  │     │  │     └─ write_batch.dart
│        │  │     │  ├─ LICENSE
│        │  │     │  ├─ macos
│        │  │     │  │  ├─ cloud_firestore
│        │  │     │  │  │  ├─ Package.swift
│        │  │     │  │  │  └─ Sources
│        │  │     │  │  │     └─ cloud_firestore
│        │  │     │  │  │        ├─ FirestoreMessages.g.m
│        │  │     │  │  │        ├─ FirestorePigeonParser.m
│        │  │     │  │  │        ├─ FLTDocumentSnapshotStreamHandler.m
│        │  │     │  │  │        ├─ FLTFirebaseFirestoreExtension.m
│        │  │     │  │  │        ├─ FLTFirebaseFirestorePlugin.m
│        │  │     │  │  │        ├─ FLTFirebaseFirestoreReader.m
│        │  │     │  │  │        ├─ FLTFirebaseFirestoreUtils.m
│        │  │     │  │  │        ├─ FLTFirebaseFirestoreWriter.m
│        │  │     │  │  │        ├─ FLTLoadBundleStreamHandler.m
│        │  │     │  │  │        ├─ FLTQuerySnapshotStreamHandler.m
│        │  │     │  │  │        ├─ FLTSnapshotsInSyncStreamHandler.m
│        │  │     │  │  │        ├─ FLTTransactionStreamHandler.m
│        │  │     │  │  │        ├─ include
│        │  │     │  │  │        │  └─ cloud_firestore
│        │  │     │  │  │        │     ├─ Private
│        │  │     │  │  │        │     │  ├─ FirestorePigeonParser.h
│        │  │     │  │  │        │     │  ├─ FLTDocumentSnapshotStreamHandler.h
│        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreExtension.h
│        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreReader.h
│        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreUtils.h
│        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreWriter.h
│        │  │     │  │  │        │     │  ├─ FLTLoadBundleStreamHandler.h
│        │  │     │  │  │        │     │  ├─ FLTQuerySnapshotStreamHandler.h
│        │  │     │  │  │        │     │  ├─ FLTSnapshotsInSyncStreamHandler.h
│        │  │     │  │  │        │     │  └─ FLTTransactionStreamHandler.h
│        │  │     │  │  │        │     └─ Public
│        │  │     │  │  │        │        ├─ CustomPigeonHeaderFirestore.h
│        │  │     │  │  │        │        ├─ FirestoreMessages.g.h
│        │  │     │  │  │        │        └─ FLTFirebaseFirestorePlugin.h
│        │  │     │  │  │        └─ Resources
│        │  │     │  │  └─ cloud_firestore.podspec
│        │  │     │  ├─ pubspec.yaml
│        │  │     │  ├─ README.md
│        │  │     │  ├─ test
│        │  │     │  │  ├─ cloud_firestore_test.dart
│        │  │     │  │  ├─ collection_reference_test.dart
│        │  │     │  │  ├─ field_value_test.dart
│        │  │     │  │  ├─ mock.dart
│        │  │     │  │  ├─ query_test.dart
│        │  │     │  │  └─ test_firestore_message_codec.dart
│        │  │     │  └─ windows
│        │  │     │     ├─ cloud_firestore_plugin.cpp
│        │  │     │     ├─ cloud_firestore_plugin.h
│        │  │     │     ├─ cloud_firestore_plugin_c_api.cpp
│        │  │     │     ├─ CMakeLists.txt
│        │  │     │     ├─ firestore_codec.cpp
│        │  │     │     ├─ firestore_codec.h
│        │  │     │     ├─ include
│        │  │     │     │  └─ cloud_firestore
│        │  │     │     │     └─ cloud_firestore_plugin_c_api.h
│        │  │     │     ├─ messages.g.cpp
│        │  │     │     ├─ messages.g.h
│        │  │     │     ├─ plugin_version.h.in
│        │  │     │     └─ test
│        │  │     │        └─ cloud_firestore_plugin_test.cpp
│        │  │     ├─ firebase_auth
│        │  │     │  ├─ android
│        │  │     │  │  ├─ .gradle
│        │  │     │  │  │  ├─ 8.4
│        │  │     │  │  │  │  ├─ checksums
│        │  │     │  │  │  │  │  └─ checksums.lock
│        │  │     │  │  │  │  ├─ fileChanges
│        │  │     │  │  │  │  │  └─ last-build.bin
│        │  │     │  │  │  │  ├─ fileHashes
│        │  │     │  │  │  │  │  └─ fileHashes.lock
│        │  │     │  │  │  │  ├─ gc.properties
│        │  │     │  │  │  │  └─ vcsMetadata
│        │  │     │  │  │  └─ vcs-1
│        │  │     │  │  │     └─ gc.properties
│        │  │     │  │  ├─ build.gradle
│        │  │     │  │  ├─ gradle
│        │  │     │  │  │  └─ wrapper
│        │  │     │  │  │     └─ gradle-wrapper.properties
│        │  │     │  │  ├─ gradle.properties
│        │  │     │  │  ├─ settings.gradle
│        │  │     │  │  ├─ src
│        │  │     │  │  │  └─ main
│        │  │     │  │  │     ├─ AndroidManifest.xml
│        │  │     │  │  │     └─ java
│        │  │     │  │  │        └─ io
│        │  │     │  │  │           └─ flutter
│        │  │     │  │  │              └─ plugins
│        │  │     │  │  │                 └─ firebase
│        │  │     │  │  │                    └─ auth
│        │  │     │  │  │                       ├─ AuthStateChannelStreamHandler.java
│        │  │     │  │  │                       ├─ Constants.java
│        │  │     │  │  │                       ├─ FlutterFirebaseAuthPlugin.java
│        │  │     │  │  │                       ├─ FlutterFirebaseAuthPluginException.java
│        │  │     │  │  │                       ├─ FlutterFirebaseAuthRegistrar.java
│        │  │     │  │  │                       ├─ FlutterFirebaseAuthUser.java
│        │  │     │  │  │                       ├─ FlutterFirebaseMultiFactor.java
│        │  │     │  │  │                       ├─ FlutterFirebaseTotpMultiFactor.java
│        │  │     │  │  │                       ├─ FlutterFirebaseTotpSecret.java
│        │  │     │  │  │                       ├─ GeneratedAndroidFirebaseAuth.java
│        │  │     │  │  │                       ├─ IdTokenChannelStreamHandler.java
│        │  │     │  │  │                       ├─ PhoneNumberVerificationStreamHandler.java
│        │  │     │  │  │                       └─ PigeonParser.java
│        │  │     │  │  └─ user-agent.gradle
│        │  │     │  ├─ CHANGELOG.md
│        │  │     │  ├─ example
│        │  │     │  │  ├─ analysis_options.yaml
│        │  │     │  │  ├─ android
│        │  │     │  │  │  ├─ app
│        │  │     │  │  │  │  ├─ build.gradle
│        │  │     │  │  │  │  ├─ google-services.json
│        │  │     │  │  │  │  └─ src
│        │  │     │  │  │  │     ├─ debug
│        │  │     │  │  │  │     │  └─ AndroidManifest.xml
│        │  │     │  │  │  │     ├─ main
│        │  │     │  │  │  │     │  ├─ AndroidManifest.xml
│        │  │     │  │  │  │     │  ├─ java
│        │  │     │  │  │  │     │  │  └─ io
│        │  │     │  │  │  │     │  │     └─ flutter
│        │  │     │  │  │  │     │  │        └─ plugins
│        │  │     │  │  │  │     │  ├─ kotlin
│        │  │     │  │  │  │     │  │  └─ io
│        │  │     │  │  │  │     │  │     └─ flutter
│        │  │     │  │  │  │     │  │        └─ plugins
│        │  │     │  │  │  │     │  │           └─ firebase
│        │  │     │  │  │  │     │  │              └─ auth
│        │  │     │  │  │  │     │  │                 └─ example
│        │  │     │  │  │  │     │  │                    └─ MainActivity.kt
│        │  │     │  │  │  │     │  └─ res
│        │  │     │  │  │  │     │     ├─ drawable
│        │  │     │  │  │  │     │     │  └─ launch_background.xml
│        │  │     │  │  │  │     │     ├─ drawable-v21
│        │  │     │  │  │  │     │     │  └─ launch_background.xml
│        │  │     │  │  │  │     │     ├─ mipmap-hdpi
│        │  │     │  │  │  │     │     │  └─ ic_launcher.png
│        │  │     │  │  │  │     │     ├─ mipmap-mdpi
│        │  │     │  │  │  │     │     │  └─ ic_launcher.png
│        │  │     │  │  │  │     │     ├─ mipmap-xhdpi
│        │  │     │  │  │  │     │     │  └─ ic_launcher.png
│        │  │     │  │  │  │     │     ├─ mipmap-xxhdpi
│        │  │     │  │  │  │     │     │  └─ ic_launcher.png
│        │  │     │  │  │  │     │     ├─ mipmap-xxxhdpi
│        │  │     │  │  │  │     │     │  └─ ic_launcher.png
│        │  │     │  │  │  │     │     ├─ values
│        │  │     │  │  │  │     │     │  └─ styles.xml
│        │  │     │  │  │  │     │     └─ values-night
│        │  │     │  │  │  │     │        └─ styles.xml
│        │  │     │  │  │  │     └─ profile
│        │  │     │  │  │  │        └─ AndroidManifest.xml
│        │  │     │  │  │  ├─ build.gradle
│        │  │     │  │  │  ├─ gradle
│        │  │     │  │  │  │  └─ wrapper
│        │  │     │  │  │  │     └─ gradle-wrapper.properties
│        │  │     │  │  │  ├─ gradle.properties
│        │  │     │  │  │  └─ settings.gradle
│        │  │     │  │  ├─ ios
│        │  │     │  │  │  ├─ firebase_app_id_file.json
│        │  │     │  │  │  ├─ Flutter
│        │  │     │  │  │  │  ├─ AppFrameworkInfo.plist
│        │  │     │  │  │  │  ├─ Debug.xcconfig
│        │  │     │  │  │  │  └─ Release.xcconfig
│        │  │     │  │  │  ├─ Podfile
│        │  │     │  │  │  ├─ Runner
│        │  │     │  │  │  │  ├─ AppDelegate.h
│        │  │     │  │  │  │  ├─ AppDelegate.m
│        │  │     │  │  │  │  ├─ AppDelegate.swift
│        │  │     │  │  │  │  ├─ Assets.xcassets
│        │  │     │  │  │  │  │  ├─ AppIcon.appiconset
│        │  │     │  │  │  │  │  │  ├─ Contents.json
│        │  │     │  │  │  │  │  │  ├─ Icon-App-1024x1024@1x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@1x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@2x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@3x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@1x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@2x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@3x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@1x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@2x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@3x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-60x60@2x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-60x60@3x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-76x76@1x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-76x76@2x.png
│        │  │     │  │  │  │  │  │  └─ Icon-App-83.5x83.5@2x.png
│        │  │     │  │  │  │  │  └─ LaunchImage.imageset
│        │  │     │  │  │  │  │     ├─ Contents.json
│        │  │     │  │  │  │  │     ├─ LaunchImage.png
│        │  │     │  │  │  │  │     ├─ LaunchImage@2x.png
│        │  │     │  │  │  │  │     ├─ LaunchImage@3x.png
│        │  │     │  │  │  │  │     └─ README.md
│        │  │     │  │  │  │  ├─ Base.lproj
│        │  │     │  │  │  │  │  ├─ LaunchScreen.storyboard
│        │  │     │  │  │  │  │  └─ Main.storyboard
│        │  │     │  │  │  │  ├─ GoogleService-Info.plist
│        │  │     │  │  │  │  ├─ Info.plist
│        │  │     │  │  │  │  ├─ main.m
│        │  │     │  │  │  │  ├─ Runner-Bridging-Header.h
│        │  │     │  │  │  │  └─ Runner.entitlements
│        │  │     │  │  │  ├─ Runner.xcodeproj
│        │  │     │  │  │  │  ├─ project.pbxproj
│        │  │     │  │  │  │  ├─ project.xcworkspace
│        │  │     │  │  │  │  │  ├─ contents.xcworkspacedata
│        │  │     │  │  │  │  │  └─ xcshareddata
│        │  │     │  │  │  │  │     ├─ IDEWorkspaceChecks.plist
│        │  │     │  │  │  │  │     ├─ swiftpm
│        │  │     │  │  │  │  │     │  └─ configuration
│        │  │     │  │  │  │  │     └─ WorkspaceSettings.xcsettings
│        │  │     │  │  │  │  └─ xcshareddata
│        │  │     │  │  │  │     └─ xcschemes
│        │  │     │  │  │  │        └─ Runner.xcscheme
│        │  │     │  │  │  └─ Runner.xcworkspace
│        │  │     │  │  │     ├─ contents.xcworkspacedata
│        │  │     │  │  │     └─ xcshareddata
│        │  │     │  │  │        ├─ IDEWorkspaceChecks.plist
│        │  │     │  │  │        ├─ swiftpm
│        │  │     │  │  │        │  └─ configuration
│        │  │     │  │  │        └─ WorkspaceSettings.xcsettings
│        │  │     │  │  ├─ lib
│        │  │     │  │  │  ├─ auth.dart
│        │  │     │  │  │  ├─ firebase_options.dart
│        │  │     │  │  │  ├─ main.dart
│        │  │     │  │  │  └─ profile.dart
│        │  │     │  │  ├─ macos
│        │  │     │  │  │  ├─ firebase_app_id_file.json
│        │  │     │  │  │  ├─ Flutter
│        │  │     │  │  │  │  ├─ Flutter-Debug.xcconfig
│        │  │     │  │  │  │  └─ Flutter-Release.xcconfig
│        │  │     │  │  │  ├─ Podfile
│        │  │     │  │  │  ├─ Runner
│        │  │     │  │  │  │  ├─ AppDelegate.swift
│        │  │     │  │  │  │  ├─ Assets.xcassets
│        │  │     │  │  │  │  │  └─ AppIcon.appiconset
│        │  │     │  │  │  │  │     ├─ app_icon_1024.png
│        │  │     │  │  │  │  │     ├─ app_icon_128.png
│        │  │     │  │  │  │  │     ├─ app_icon_16.png
│        │  │     │  │  │  │  │     ├─ app_icon_256.png
│        │  │     │  │  │  │  │     ├─ app_icon_32.png
│        │  │     │  │  │  │  │     ├─ app_icon_512.png
│        │  │     │  │  │  │  │     ├─ app_icon_64.png
│        │  │     │  │  │  │  │     └─ Contents.json
│        │  │     │  │  │  │  ├─ Base.lproj
│        │  │     │  │  │  │  │  └─ MainMenu.xib
│        │  │     │  │  │  │  ├─ Configs
│        │  │     │  │  │  │  │  ├─ AppInfo.xcconfig
│        │  │     │  │  │  │  │  ├─ Debug.xcconfig
│        │  │     │  │  │  │  │  ├─ Release.xcconfig
│        │  │     │  │  │  │  │  └─ Warnings.xcconfig
│        │  │     │  │  │  │  ├─ DebugProfile.entitlements
│        │  │     │  │  │  │  ├─ GoogleService-Info.plist
│        │  │     │  │  │  │  ├─ Info.plist
│        │  │     │  │  │  │  ├─ MainFlutterWindow.swift
│        │  │     │  │  │  │  └─ Release.entitlements
│        │  │     │  │  │  ├─ Runner.xcodeproj
│        │  │     │  │  │  │  ├─ project.pbxproj
│        │  │     │  │  │  │  ├─ project.xcworkspace
│        │  │     │  │  │  │  │  ├─ contents.xcworkspacedata
│        │  │     │  │  │  │  │  └─ xcshareddata
│        │  │     │  │  │  │  │     └─ IDEWorkspaceChecks.plist
│        │  │     │  │  │  │  └─ xcshareddata
│        │  │     │  │  │  │     └─ xcschemes
│        │  │     │  │  │  │        └─ Runner.xcscheme
│        │  │     │  │  │  └─ Runner.xcworkspace
│        │  │     │  │  │     ├─ contents.xcworkspacedata
│        │  │     │  │  │     └─ xcshareddata
│        │  │     │  │  │        ├─ IDEWorkspaceChecks.plist
│        │  │     │  │  │        └─ WorkspaceSettings.xcsettings
│        │  │     │  │  ├─ pubspec.yaml
│        │  │     │  │  ├─ README.md
│        │  │     │  │  ├─ web
│        │  │     │  │  │  ├─ favicon.png
│        │  │     │  │  │  ├─ icons
│        │  │     │  │  │  │  ├─ Icon-192.png
│        │  │     │  │  │  │  ├─ Icon-512.png
│        │  │     │  │  │  │  ├─ Icon-maskable-192.png
│        │  │     │  │  │  │  └─ Icon-maskable-512.png
│        │  │     │  │  │  ├─ index.html
│        │  │     │  │  │  └─ manifest.json
│        │  │     │  │  └─ windows
│        │  │     │  │     ├─ CMakeLists.txt
│        │  │     │  │     ├─ flutter
│        │  │     │  │     │  └─ CMakeLists.txt
│        │  │     │  │     └─ runner
│        │  │     │  │        ├─ CMakeLists.txt
│        │  │     │  │        ├─ flutter_window.cpp
│        │  │     │  │        ├─ flutter_window.h
│        │  │     │  │        ├─ main.cpp
│        │  │     │  │        ├─ resource.h
│        │  │     │  │        ├─ resources
│        │  │     │  │        │  └─ app_icon.ico
│        │  │     │  │        ├─ runner.exe.manifest
│        │  │     │  │        ├─ Runner.rc
│        │  │     │  │        ├─ utils.cpp
│        │  │     │  │        ├─ utils.h
│        │  │     │  │        ├─ win32_window.cpp
│        │  │     │  │        └─ win32_window.h
│        │  │     │  ├─ ios
│        │  │     │  │  ├─ firebase_auth
│        │  │     │  │  │  ├─ Package.swift
│        │  │     │  │  │  └─ Sources
│        │  │     │  │  │     └─ firebase_auth
│        │  │     │  │  │        ├─ firebase_auth_messages.g.m
│        │  │     │  │  │        ├─ FLTAuthStateChannelStreamHandler.m
│        │  │     │  │  │        ├─ FLTFirebaseAuthPlugin.m
│        │  │     │  │  │        ├─ FLTIdTokenChannelStreamHandler.m
│        │  │     │  │  │        ├─ FLTPhoneNumberVerificationStreamHandler.m
│        │  │     │  │  │        ├─ include
│        │  │     │  │  │        │  ├─ Private
│        │  │     │  │  │        │  │  ├─ FLTAuthStateChannelStreamHandler.h
│        │  │     │  │  │        │  │  ├─ FLTIdTokenChannelStreamHandler.h
│        │  │     │  │  │        │  │  ├─ FLTPhoneNumberVerificationStreamHandler.h
│        │  │     │  │  │        │  │  └─ PigeonParser.h
│        │  │     │  │  │        │  └─ Public
│        │  │     │  │  │        │     ├─ CustomPigeonHeader.h
│        │  │     │  │  │        │     ├─ firebase_auth_messages.g.h
│        │  │     │  │  │        │     └─ FLTFirebaseAuthPlugin.h
│        │  │     │  │  │        ├─ PigeonParser.m
│        │  │     │  │  │        └─ Resources
│        │  │     │  │  ├─ firebase_auth.podspec
│        │  │     │  │  └─ generated_firebase_sdk_version.txt
│        │  │     │  ├─ lib
│        │  │     │  │  ├─ firebase_auth.dart
│        │  │     │  │  └─ src
│        │  │     │  │     ├─ confirmation_result.dart
│        │  │     │  │     ├─ firebase_auth.dart
│        │  │     │  │     ├─ multi_factor.dart
│        │  │     │  │     ├─ recaptcha_verifier.dart
│        │  │     │  │     ├─ user.dart
│        │  │     │  │     └─ user_credential.dart
│        │  │     │  ├─ LICENSE
│        │  │     │  ├─ macos
│        │  │     │  │  ├─ firebase_auth
│        │  │     │  │  │  ├─ Package.swift
│        │  │     │  │  │  └─ Sources
│        │  │     │  │  │     └─ firebase_auth
│        │  │     │  │  │        ├─ firebase_auth_messages.g.m
│        │  │     │  │  │        ├─ FLTAuthStateChannelStreamHandler.m
│        │  │     │  │  │        ├─ FLTFirebaseAuthPlugin.m
│        │  │     │  │  │        ├─ FLTIdTokenChannelStreamHandler.m
│        │  │     │  │  │        ├─ FLTPhoneNumberVerificationStreamHandler.m
│        │  │     │  │  │        ├─ include
│        │  │     │  │  │        │  ├─ Private
│        │  │     │  │  │        │  │  ├─ FLTAuthStateChannelStreamHandler.h
│        │  │     │  │  │        │  │  ├─ FLTIdTokenChannelStreamHandler.h
│        │  │     │  │  │        │  │  ├─ FLTPhoneNumberVerificationStreamHandler.h
│        │  │     │  │  │        │  │  └─ PigeonParser.h
│        │  │     │  │  │        │  └─ Public
│        │  │     │  │  │        │     ├─ CustomPigeonHeader.h
│        │  │     │  │  │        │     ├─ firebase_auth_messages.g.h
│        │  │     │  │  │        │     └─ FLTFirebaseAuthPlugin.h
│        │  │     │  │  │        ├─ PigeonParser.m
│        │  │     │  │  │        └─ Resource
│        │  │     │  │  └─ firebase_auth.podspec
│        │  │     │  ├─ pubspec.yaml
│        │  │     │  ├─ README.md
│        │  │     │  ├─ test
│        │  │     │  │  ├─ firebase_auth_test.dart
│        │  │     │  │  ├─ mock.dart
│        │  │     │  │  └─ user_test.dart
│        │  │     │  └─ windows
│        │  │     │     ├─ CMakeLists.txt
│        │  │     │     ├─ firebase_auth_plugin.cpp
│        │  │     │     ├─ firebase_auth_plugin.h
│        │  │     │     ├─ firebase_auth_plugin_c_api.cpp
│        │  │     │     ├─ include
│        │  │     │     │  └─ firebase_auth
│        │  │     │     │     └─ firebase_auth_plugin_c_api.h
│        │  │     │     ├─ messages.g.cpp
│        │  │     │     ├─ messages.g.h
│        │  │     │     ├─ plugin_version.h.in
│        │  │     │     └─ test
│        │  │     │        └─ firebase_auth_plugin_test.cpp
│        │  │     ├─ firebase_core
│        │  │     │  ├─ android
│        │  │     │  │  ├─ .gradle
│        │  │     │  │  │  ├─ 8.4
│        │  │     │  │  │  │  ├─ checksums
│        │  │     │  │  │  │  │  └─ checksums.lock
│        │  │     │  │  │  │  ├─ fileChanges
│        │  │     │  │  │  │  │  └─ last-build.bin
│        │  │     │  │  │  │  ├─ fileHashes
│        │  │     │  │  │  │  │  └─ fileHashes.lock
│        │  │     │  │  │  │  ├─ gc.properties
│        │  │     │  │  │  │  └─ vcsMetadata
│        │  │     │  │  │  └─ vcs-1
│        │  │     │  │  │     └─ gc.properties
│        │  │     │  │  ├─ build.gradle
│        │  │     │  │  ├─ gradle
│        │  │     │  │  │  └─ wrapper
│        │  │     │  │  │     └─ gradle-wrapper.properties
│        │  │     │  │  ├─ gradle.properties
│        │  │     │  │  ├─ local-config.gradle
│        │  │     │  │  ├─ settings.gradle
│        │  │     │  │  ├─ src
│        │  │     │  │  │  └─ main
│        │  │     │  │  │     ├─ AndroidManifest.xml
│        │  │     │  │  │     └─ java
│        │  │     │  │  │        └─ io
│        │  │     │  │  │           └─ flutter
│        │  │     │  │  │              └─ plugins
│        │  │     │  │  │                 └─ firebase
│        │  │     │  │  │                    └─ core
│        │  │     │  │  │                       ├─ FlutterFirebaseCorePlugin.java
│        │  │     │  │  │                       ├─ FlutterFirebaseCoreRegistrar.java
│        │  │     │  │  │                       ├─ FlutterFirebasePlugin.java
│        │  │     │  │  │                       ├─ FlutterFirebasePluginRegistry.java
│        │  │     │  │  │                       └─ GeneratedAndroidFirebaseCore.java
│        │  │     │  │  └─ user-agent.gradle
│        │  │     │  ├─ CHANGELOG.md
│        │  │     │  ├─ example
│        │  │     │  │  ├─ analysis_options.yaml
│        │  │     │  │  ├─ android
│        │  │     │  │  │  ├─ app
│        │  │     │  │  │  │  ├─ build.gradle
│        │  │     │  │  │  │  ├─ google-services.json
│        │  │     │  │  │  │  └─ src
│        │  │     │  │  │  │     ├─ debug
│        │  │     │  │  │  │     │  └─ AndroidManifest.xml
│        │  │     │  │  │  │     ├─ main
│        │  │     │  │  │  │     │  ├─ AndroidManifest.xml
│        │  │     │  │  │  │     │  ├─ java
│        │  │     │  │  │  │     │  │  └─ io
│        │  │     │  │  │  │     │  │     └─ flutter
│        │  │     │  │  │  │     │  │        └─ plugins
│        │  │     │  │  │  │     │  ├─ kotlin
│        │  │     │  │  │  │     │  │  └─ io
│        │  │     │  │  │  │     │  │     └─ flutter
│        │  │     │  │  │  │     │  │        └─ plugins
│        │  │     │  │  │  │     │  │           └─ firebasecoreexample
│        │  │     │  │  │  │     │  │              └─ MainActivity.kt
│        │  │     │  │  │  │     │  └─ res
│        │  │     │  │  │  │     │     ├─ drawable
│        │  │     │  │  │  │     │     │  └─ launch_background.xml
│        │  │     │  │  │  │     │     ├─ drawable-v21
│        │  │     │  │  │  │     │     │  └─ launch_background.xml
│        │  │     │  │  │  │     │     ├─ mipmap-hdpi
│        │  │     │  │  │  │     │     │  └─ ic_launcher.png
│        │  │     │  │  │  │     │     ├─ mipmap-mdpi
│        │  │     │  │  │  │     │     │  └─ ic_launcher.png
│        │  │     │  │  │  │     │     ├─ mipmap-xhdpi
│        │  │     │  │  │  │     │     │  └─ ic_launcher.png
│        │  │     │  │  │  │     │     ├─ mipmap-xxhdpi
│        │  │     │  │  │  │     │     │  └─ ic_launcher.png
│        │  │     │  │  │  │     │     ├─ mipmap-xxxhdpi
│        │  │     │  │  │  │     │     │  └─ ic_launcher.png
│        │  │     │  │  │  │     │     ├─ values
│        │  │     │  │  │  │     │     │  └─ styles.xml
│        │  │     │  │  │  │     │     └─ values-night
│        │  │     │  │  │  │     │        └─ styles.xml
│        │  │     │  │  │  │     └─ profile
│        │  │     │  │  │  │        └─ AndroidManifest.xml
│        │  │     │  │  │  ├─ build.gradle
│        │  │     │  │  │  ├─ gradle
│        │  │     │  │  │  │  └─ wrapper
│        │  │     │  │  │  │     └─ gradle-wrapper.properties
│        │  │     │  │  │  ├─ gradle.properties
│        │  │     │  │  │  └─ settings.gradle
│        │  │     │  │  ├─ ios
│        │  │     │  │  │  ├─ Flutter
│        │  │     │  │  │  │  ├─ AppFrameworkInfo.plist
│        │  │     │  │  │  │  ├─ Debug.xcconfig
│        │  │     │  │  │  │  └─ Release.xcconfig
│        │  │     │  │  │  ├─ Podfile
│        │  │     │  │  │  ├─ Runner
│        │  │     │  │  │  │  ├─ AppDelegate.h
│        │  │     │  │  │  │  ├─ AppDelegate.m
│        │  │     │  │  │  │  ├─ Assets.xcassets
│        │  │     │  │  │  │  │  ├─ AppIcon.appiconset
│        │  │     │  │  │  │  │  │  ├─ Contents.json
│        │  │     │  │  │  │  │  │  ├─ Icon-App-1024x1024@1x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@1x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@2x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@3x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@1x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@2x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@3x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@1x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@2x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@3x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-60x60@2x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-60x60@3x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-76x76@1x.png
│        │  │     │  │  │  │  │  │  ├─ Icon-App-76x76@2x.png
│        │  │     │  │  │  │  │  │  └─ Icon-App-83.5x83.5@2x.png
│        │  │     │  │  │  │  │  └─ LaunchImage.imageset
│        │  │     │  │  │  │  │     ├─ Contents.json
│        │  │     │  │  │  │  │     ├─ LaunchImage.png
│        │  │     │  │  │  │  │     ├─ LaunchImage@2x.png
│        │  │     │  │  │  │  │     ├─ LaunchImage@3x.png
│        │  │     │  │  │  │  │     └─ README.md
│        │  │     │  │  │  │  ├─ Base.lproj
│        │  │     │  │  │  │  │  ├─ LaunchScreen.storyboard
│        │  │     │  │  │  │  │  └─ Main.storyboard
│        │  │     │  │  │  │  ├─ Info.plist
│        │  │     │  │  │  │  └─ main.m
│        │  │     │  │  │  ├─ Runner.xcodeproj
│        │  │     │  │  │  │  ├─ project.pbxproj
│        │  │     │  │  │  │  ├─ project.xcworkspace
│        │  │     │  │  │  │  │  ├─ contents.xcworkspacedata
│        │  │     │  │  │  │  │  └─ xcshareddata
│        │  │     │  │  │  │  │     └─ IDEWorkspaceChecks.plist
│        │  │     │  │  │  │  └─ xcshareddata
│        │  │     │  │  │  │     └─ xcschemes
│        │  │     │  │  │  │        └─ Runner.xcscheme
│        │  │     │  │  │  └─ Runner.xcworkspace
│        │  │     │  │  │     ├─ contents.xcworkspacedata
│        │  │     │  │  │     └─ xcshareddata
│        │  │     │  │  │        └─ IDEWorkspaceChecks.plist
│        │  │     │  │  ├─ lib
│        │  │     │  │  │  ├─ firebase_options.dart
│        │  │     │  │  │  └─ main.dart
│        │  │     │  │  ├─ macos
│        │  │     │  │  │  ├─ Flutter
│        │  │     │  │  │  │  ├─ Flutter-Debug.xcconfig
│        │  │     │  │  │  │  └─ Flutter-Release.xcconfig
│        │  │     │  │  │  ├─ Podfile
│        │  │     │  │  │  ├─ Runner
│        │  │     │  │  │  │  ├─ AppDelegate.swift
│        │  │     │  │  │  │  ├─ Assets.xcassets
│        │  │     │  │  │  │  │  └─ AppIcon.appiconset
│        │  │     │  │  │  │  │     ├─ app_icon_1024.png
│        │  │     │  │  │  │  │     ├─ app_icon_128.png
│        │  │     │  │  │  │  │     ├─ app_icon_16.png
│        │  │     │  │  │  │  │     ├─ app_icon_256.png
│        │  │     │  │  │  │  │     ├─ app_icon_32.png
│        │  │     │  │  │  │  │     ├─ app_icon_512.png
│        │  │     │  │  │  │  │     ├─ app_icon_64.png
│        │  │     │  │  │  │  │     └─ Contents.json
│        │  │     │  │  │  │  ├─ Base.lproj
│        │  │     │  │  │  │  │  └─ MainMenu.xib
│        │  │     │  │  │  │  ├─ Configs
│        │  │     │  │  │  │  │  ├─ AppInfo.xcconfig
│        │  │     │  │  │  │  │  ├─ Debug.xcconfig
│        │  │     │  │  │  │  │  ├─ Release.xcconfig
│        │  │     │  │  │  │  │  └─ Warnings.xcconfig
│        │  │     │  │  │  │  ├─ DebugProfile.entitlements
│        │  │     │  │  │  │  ├─ Info.plist
│        │  │     │  │  │  │  ├─ MainFlutterWindow.swift
│        │  │     │  │  │  │  └─ Release.entitlements
│        │  │     │  │  │  ├─ Runner.xcodeproj
│        │  │     │  │  │  │  ├─ project.pbxproj
│        │  │     │  │  │  │  ├─ project.xcworkspace
│        │  │     │  │  │  │  │  ├─ contents.xcworkspacedata
│        │  │     │  │  │  │  │  └─ xcshareddata
│        │  │     │  │  │  │  │     └─ IDEWorkspaceChecks.plist
│        │  │     │  │  │  │  └─ xcshareddata
│        │  │     │  │  │  │     └─ xcschemes
│        │  │     │  │  │  │        └─ Runner.xcscheme
│        │  │     │  │  │  └─ Runner.xcworkspace
│        │  │     │  │  │     ├─ contents.xcworkspacedata
│        │  │     │  │  │     └─ xcshareddata
│        │  │     │  │  │        ├─ IDEWorkspaceChecks.plist
│        │  │     │  │  │        └─ WorkspaceSettings.xcsettings
│        │  │     │  │  ├─ pubspec.yaml
│        │  │     │  │  ├─ README.md
│        │  │     │  │  ├─ web
│        │  │     │  │  │  ├─ favicon.png
│        │  │     │  │  │  ├─ icons
│        │  │     │  │  │  │  ├─ Icon-192.png
│        │  │     │  │  │  │  ├─ Icon-512.png
│        │  │     │  │  │  │  ├─ Icon-maskable-192.png
│        │  │     │  │  │  │  └─ Icon-maskable-512.png
│        │  │     │  │  │  ├─ index.html
│        │  │     │  │  │  └─ manifest.json
│        │  │     │  │  └─ windows
│        │  │     │  │     ├─ CMakeLists.txt
│        │  │     │  │     ├─ flutter
│        │  │     │  │     │  └─ CMakeLists.txt
│        │  │     │  │     └─ runner
│        │  │     │  │        ├─ CMakeLists.txt
│        │  │     │  │        ├─ flutter_window.cpp
│        │  │     │  │        ├─ flutter_window.h
│        │  │     │  │        ├─ main.cpp
│        │  │     │  │        ├─ resource.h
│        │  │     │  │        ├─ resources
│        │  │     │  │        │  └─ app_icon.ico
│        │  │     │  │        ├─ runner.exe.manifest
│        │  │     │  │        ├─ Runner.rc
│        │  │     │  │        ├─ utils.cpp
│        │  │     │  │        ├─ utils.h
│        │  │     │  │        ├─ win32_window.cpp
│        │  │     │  │        └─ win32_window.h
│        │  │     │  ├─ ios
│        │  │     │  │  ├─ firebase_core
│        │  │     │  │  │  ├─ Package.swift
│        │  │     │  │  │  └─ Sources
│        │  │     │  │  │     └─ firebase_core
│        │  │     │  │  │        ├─ dummy.m
│        │  │     │  │  │        ├─ FLTFirebaseCorePlugin.m
│        │  │     │  │  │        ├─ FLTFirebasePlugin.m
│        │  │     │  │  │        ├─ FLTFirebasePluginRegistry.m
│        │  │     │  │  │        ├─ include
│        │  │     │  │  │        │  └─ firebase_core
│        │  │     │  │  │        │     ├─ dummy.h
│        │  │     │  │  │        │     ├─ FLTFirebaseCorePlugin.h
│        │  │     │  │  │        │     ├─ FLTFirebasePlugin.h
│        │  │     │  │  │        │     ├─ FLTFirebasePluginRegistry.h
│        │  │     │  │  │        │     └─ messages.g.h
│        │  │     │  │  │        ├─ messages.g.m
│        │  │     │  │  │        └─ Resources
│        │  │     │  │  ├─ firebase_core.podspec
│        │  │     │  │  └─ firebase_sdk_version.rb
│        │  │     │  ├─ lib
│        │  │     │  │  ├─ firebase_core.dart
│        │  │     │  │  └─ src
│        │  │     │  │     ├─ firebase.dart
│        │  │     │  │     ├─ firebase_app.dart
│        │  │     │  │     └─ port_mapping.dart
│        │  │     │  ├─ LICENSE
│        │  │     │  ├─ macos
│        │  │     │  │  ├─ firebase_core
│        │  │     │  │  │  ├─ Package.swift
│        │  │     │  │  │  └─ Sources
│        │  │     │  │  │     └─ firebase_core
│        │  │     │  │  │        ├─ dummy.m
│        │  │     │  │  │        ├─ FLTFirebaseCorePlugin.m
│        │  │     │  │  │        ├─ FLTFirebasePlugin.m
│        │  │     │  │  │        ├─ FLTFirebasePluginRegistry.m
│        │  │     │  │  │        ├─ include
│        │  │     │  │  │        │  ├─ dummy.h
│        │  │     │  │  │        │  └─ firebase_core
│        │  │     │  │  │        │     ├─ FLTFirebaseCorePlugin.h
│        │  │     │  │  │        │     ├─ FLTFirebasePlugin.h
│        │  │     │  │  │        │     ├─ FLTFirebasePluginRegistry.h
│        │  │     │  │  │        │     └─ messages.g.h
│        │  │     │  │  │        ├─ messages.g.m
│        │  │     │  │  │        └─ Resources
│        │  │     │  │  └─ firebase_core.podspec
│        │  │     │  ├─ pubspec.yaml
│        │  │     │  ├─ README.md
│        │  │     │  ├─ test
│        │  │     │  │  └─ firebase_core_test.dart
│        │  │     │  └─ windows
│        │  │     │     ├─ CMakeLists.txt
│        │  │     │     ├─ firebase_core_plugin.cpp
│        │  │     │     ├─ firebase_core_plugin.h
│        │  │     │     ├─ firebase_core_plugin_c_api.cpp
│        │  │     │     ├─ include
│        │  │     │     │  └─ firebase_core
│        │  │     │     │     └─ firebase_core_plugin_c_api.h
│        │  │     │     ├─ messages.g.cpp
│        │  │     │     ├─ messages.g.h
│        │  │     │     └─ plugin_version.h.in
│        │  │     ├─ flutter_timezone
│        │  │     │  ├─ analysis_options.yaml
│        │  │     │  ├─ android
│        │  │     │  │  ├─ build.gradle
│        │  │     │  │  ├─ gradle.properties
│        │  │     │  │  ├─ settings.gradle
│        │  │     │  │  └─ src
│        │  │     │  │     └─ main
│        │  │     │  │        ├─ AndroidManifest.xml
│        │  │     │  │        └─ kotlin
│        │  │     │  │           └─ net
│        │  │     │  │              └─ wolverinebeach
│        │  │     │  │                 └─ flutter_timezone
│        │  │     │  │                    └─ FlutterTimezonePlugin.kt
│        │  │     │  ├─ CHANGELOG.md
│        │  │     │  ├─ example
│        │  │     │  │  └─ lib
│        │  │     │  │     └─ main.dart
│        │  │     │  ├─ example_spm
│        │  │     │  ├─ ios
│        │  │     │  │  ├─ flutter_timezone
│        │  │     │  │  │  ├─ Package.swift
│        │  │     │  │  │  └─ Sources
│        │  │     │  │  │     └─ flutter_timezone
│        │  │     │  │  │        ├─ FlutterTimezonePlugin.m
│        │  │     │  │  │        ├─ include
│        │  │     │  │  │        │  └─ flutter_timezone
│        │  │     │  │  │        │     └─ FlutterTimezonePlugin.h
│        │  │     │  │  │        └─ PrivacyInfo.xcprivacy
│        │  │     │  │  └─ flutter_timezone.podspec
│        │  │     │  ├─ lib
│        │  │     │  │  ├─ flutter_timezone.dart
│        │  │     │  │  └─ flutter_timezone_web.dart
│        │  │     │  ├─ LICENSE
│        │  │     │  ├─ linux
│        │  │     │  │  ├─ CMakeLists.txt
│        │  │     │  │  ├─ flutter_timezone_plugin.cc
│        │  │     │  │  ├─ flutter_timezone_plugin_private.h
│        │  │     │  │  ├─ include
│        │  │     │  │  │  └─ flutter_timezone
│        │  │     │  │  │     └─ flutter_timezone_plugin.h
│        │  │     │  │  └─ test
│        │  │     │  │     └─ flutter_timezone_plugin_test.cc
│        │  │     │  ├─ macos
│        │  │     │  │  ├─ flutter_timezone
│        │  │     │  │  │  ├─ Package.swift
│        │  │     │  │  │  └─ Sources
│        │  │     │  │  │     └─ flutter_timezone
│        │  │     │  │  │        ├─ FlutterTimezonePlugin.swift
│        │  │     │  │  │        └─ PrivacyInfo.xcprivacy
│        │  │     │  │  └─ flutter_timezone.podspec
│        │  │     │  ├─ pubspec.yaml
│        │  │     │  ├─ README.md
│        │  │     │  ├─ test
│        │  │     │  └─ windows
│        │  │     │     ├─ CMakeLists.txt
│        │  │     │     ├─ flutter_timezone_plugin.cpp
│        │  │     │     ├─ flutter_timezone_plugin.h
│        │  │     │     ├─ flutter_timezone_plugin_c_api.cpp
│        │  │     │     ├─ include
│        │  │     │     │  └─ flutter_timezone
│        │  │     │     │     └─ flutter_timezone_plugin_c_api.h
│        │  │     │     └─ test
│        │  │     │        └─ flutter_timezone_plugin_test.cpp
│        │  │     ├─ path_provider_windows
│        │  │     │  ├─ AUTHORS
│        │  │     │  ├─ CHANGELOG.md
│        │  │     │  ├─ example
│        │  │     │  │  ├─ integration_test
│        │  │     │  │  │  └─ path_provider_test.dart
│        │  │     │  │  ├─ lib
│        │  │     │  │  │  └─ main.dart
│        │  │     │  │  ├─ pubspec.yaml
│        │  │     │  │  ├─ README.md
│        │  │     │  │  ├─ test_driver
│        │  │     │  │  │  └─ integration_test.dart
│        │  │     │  │  └─ windows
│        │  │     │  │     ├─ CMakeLists.txt
│        │  │     │  │     ├─ flutter
│        │  │     │  │     │  ├─ CMakeLists.txt
│        │  │     │  │     │  └─ generated_plugins.cmake
│        │  │     │  │     └─ runner
│        │  │     │  │        ├─ CMakeLists.txt
│        │  │     │  │        ├─ flutter_window.cpp
│        │  │     │  │        ├─ flutter_window.h
│        │  │     │  │        ├─ main.cpp
│        │  │     │  │        ├─ resource.h
│        │  │     │  │        ├─ resources
│        │  │     │  │        │  └─ app_icon.ico
│        │  │     │  │        ├─ runner.exe.manifest
│        │  │     │  │        ├─ Runner.rc
│        │  │     │  │        ├─ run_loop.cpp
│        │  │     │  │        ├─ run_loop.h
│        │  │     │  │        ├─ utils.cpp
│        │  │     │  │        ├─ utils.h
│        │  │     │  │        ├─ win32_window.cpp
│        │  │     │  │        └─ win32_window.h
│        │  │     │  ├─ lib
│        │  │     │  │  ├─ path_provider_windows.dart
│        │  │     │  │  └─ src
│        │  │     │  │     ├─ folders.dart
│        │  │     │  │     ├─ folders_stub.dart
│        │  │     │  │     ├─ guid.dart
│        │  │     │  │     ├─ path_provider_windows_real.dart
│        │  │     │  │     ├─ path_provider_windows_stub.dart
│        │  │     │  │     └─ win32_wrappers.dart
│        │  │     │  ├─ LICENSE
│        │  │     │  ├─ pubspec.yaml
│        │  │     │  ├─ README.md
│        │  │     │  └─ test
│        │  │     │     ├─ guid_test.dart
│        │  │     │     └─ path_provider_windows_test.dart
│        │  │     └─ shared_preferences_windows
│        │  │        ├─ AUTHORS
│        │  │        ├─ CHANGELOG.md
│        │  │        ├─ example
│        │  │        │  ├─ AUTHORS
│        │  │        │  ├─ integration_test
│        │  │        │  │  └─ shared_preferences_test.dart
│        │  │        │  ├─ lib
│        │  │        │  │  └─ main.dart
│        │  │        │  ├─ LICENSE
│        │  │        │  ├─ pubspec.yaml
│        │  │        │  ├─ README.md
│        │  │        │  ├─ test_driver
│        │  │        │  │  └─ integration_test.dart
│        │  │        │  └─ windows
│        │  │        │     ├─ CMakeLists.txt
│        │  │        │     ├─ flutter
│        │  │        │     │  ├─ CMakeLists.txt
│        │  │        │     │  └─ generated_plugins.cmake
│        │  │        │     └─ runner
│        │  │        │        ├─ CMakeLists.txt
│        │  │        │        ├─ flutter_window.cpp
│        │  │        │        ├─ flutter_window.h
│        │  │        │        ├─ main.cpp
│        │  │        │        ├─ resource.h
│        │  │        │        ├─ resources
│        │  │        │        │  └─ app_icon.ico
│        │  │        │        ├─ runner.exe.manifest
│        │  │        │        ├─ Runner.rc
│        │  │        │        ├─ run_loop.cpp
│        │  │        │        ├─ run_loop.h
│        │  │        │        ├─ utils.cpp
│        │  │        │        ├─ utils.h
│        │  │        │        ├─ win32_window.cpp
│        │  │        │        └─ win32_window.h
│        │  │        ├─ lib
│        │  │        │  └─ shared_preferences_windows.dart
│        │  │        ├─ LICENSE
│        │  │        ├─ pubspec.yaml
│        │  │        ├─ README.md
│        │  │        └─ test
│        │  │           ├─ fake_path_provider_windows.dart
│        │  │           ├─ legacy_shared_preferences_windows_test.dart
│        │  │           └─ shared_preferences_windows_async_test.dart
│        │  ├─ generated_plugins.cmake
│        │  ├─ generated_plugin_registrant.cc
│        │  └─ generated_plugin_registrant.h
│        └─ runner
│           ├─ CMakeLists.txt
│           ├─ flutter_window.cpp
│           ├─ flutter_window.h
│           ├─ main.cpp
│           ├─ resource.h
│           ├─ resources
│           │  └─ app_icon.ico
│           ├─ runner.exe.manifest
│           ├─ Runner.rc
│           ├─ utils.cpp
│           ├─ utils.h
│           ├─ win32_window.cpp
│           └─ win32_window.h
├─ ini
│  └─ t1.ini
├─ java
│  └─ tt.java
├─ npm
│  └─ goGreen
│     ├─ data.json
│     ├─ index.js
│     ├─ LICENSE
│     ├─ package-lock.json
│     ├─ package.json
│     └─ README.md
├─ python
│  ├─ BCatMeo
│  │  └─ v1
│  │     ├─ 11serviceAccountKey.json
│  │     └─ v1.py
│  ├─ ml
│  │  ├─ c1.ipynb
│  │  └─ Loan_approval_demo_data.csv
│  └─ sam.py
├─ sql
├─ web
│  ├─ homteq
│  │  ├─ aboutus.php
│  │  ├─ bgimg.jpg
│  │  ├─ bgimg2.jpg
│  │  ├─ db.php
│  │  ├─ footfile.html
│  │  ├─ headfile.html
│  │  ├─ homteq_logo.png
│  │  ├─ images
│  │  │  ├─ macbook_large.jpg
│  │  │  ├─ macbook_small.jpg
│  │  │  ├─ s24_large.jpg
│  │  │  ├─ s24_small.jpg
│  │  │  ├─ sony_large.jpg
│  │  │  ├─ sony_small.jpg
│  │  │  ├─ tv_large.jpg
│  │  │  └─ tv_small.jpg
│  │  ├─ index.php
│  │  ├─ mystylesheet.css
│  │  └─ template copy.php
│  ├─ notes
│  │  └─ server-side
│  │     ├─ week1
│  │     │  ├─ 25_5COSC024W_homteq_Brief&Specs.pdf
│  │     │  ├─ 25_5COSC024W_LECT01&02.pdf
│  │     │  ├─ 25_5COSC024W_Tut01.pdf
│  │     │  ├─ 25_5COSC024W_Tut01_Answ.pdf
│  │     │  ├─ 25_5COSC024W_Tut01_Diagr.pdf
│  │     │  ├─ mystylesheet
│  │     │  │  └─ mystylesheet.css
│  │     │  └─ mystylesheet.zip
│  │     ├─ week3
│  │     │  └─ 25_5COSC024W_LECT03(1)-1.pdf
│  │     └─ week4
│  │        └─ 25_5COSC024W_LECT04.pdf
│  ├─ php
│  │  ├─ db.php
│  │  ├─ index.php
│  │  ├─ s1.php
│  │  └─ T1 - sql & php
│  │     ├─ GET
│  │     │  ├─ db.php
│  │     │  ├─ product.php
│  │     │  └─ testpage.php
│  │     ├─ isset
│  │     │  ├─ drop-down.php
│  │     │  └─ isset.php
│  │     ├─ POST
│  │     │  ├─ db.php
│  │     │  ├─ drop-down-oput.php
│  │     │  ├─ drop-down.php
│  │     │  ├─ post_in.php
│  │     │  └─ testpage.php
│  │     └─ session
│  │        ├─ s1.php
│  │        └─ session_p.php
│  └─ web_s1
│     ├─ index.html
│     ├─ script.js
│     └─ style.css
└─ ws2
   ├─ EzGit
   │  ├─ build
   │  │  ├─ EzGit
   │  │  │  ├─ Analysis-00.toc
   │  │  │  ├─ base_library.zip
   │  │  │  ├─ EXE-00.toc
   │  │  │  ├─ EzGit.pkg
   │  │  │  ├─ localpycs
   │  │  │  │  ├─ pyimod01_archive.pyc
   │  │  │  │  ├─ pyimod02_importers.pyc
   │  │  │  │  ├─ pyimod03_ctypes.pyc
   │  │  │  │  ├─ pyimod04_pywin32.pyc
   │  │  │  │  └─ struct.pyc
   │  │  │  ├─ PKG-00.toc
   │  │  │  ├─ PYZ-00.pyz
   │  │  │  ├─ PYZ-00.toc
   │  │  │  ├─ warn-EzGit.txt
   │  │  │  └─ xref-EzGit.html
   │  │  └─ EzGitLogin
   │  │     ├─ Analysis-00.toc
   │  │     ├─ base_library.zip
   │  │     ├─ EXE-00.toc
   │  │     ├─ EzGitLogin.pkg
   │  │     ├─ localpycs
   │  │     │  ├─ pyimod01_archive.pyc
   │  │     │  ├─ pyimod02_importers.pyc
   │  │     │  ├─ pyimod03_ctypes.pyc
   │  │     │  ├─ pyimod04_pywin32.pyc
   │  │     │  └─ struct.pyc
   │  │     ├─ PKG-00.toc
   │  │     ├─ PYZ-00.pyz
   │  │     ├─ PYZ-00.toc
   │  │     ├─ warn-EzGitLogin.txt
   │  │     └─ xref-EzGitLogin.html
   │  ├─ dist
   │  │  └─ EzGit.exe
   │  ├─ EzGit.spec
   │  ├─ EzGitInstaller.iss
   │  ├─ EzGitLogin.spec
   │  ├─ file_utils.py
   │  ├─ git_utils.py
   │  ├─ gui.py
   │  ├─ installer-output
   │  │  └─ EzGit-Setup.exe
   │  ├─ main2.py
   │  ├─ README.md
   │  ├─ user_login.py
   │  ├─ user_login.spec
   │  ├─ zc.ico
   │  └─ __pycache__
   │     ├─ gui.cpython-314.pyc
   │     ├─ main2.cpython-314.pyc
   │     └─ user_login.cpython-314.pyc
   ├─ flutter
   │  └─ VORA
   │     ├─ .dart_tool
   │     │  ├─ dartpad
   │     │  │  └─ web_plugin_registrant.dart
   │     │  ├─ extension_discovery
   │     │  │  ├─ devtools.json
   │     │  │  └─ vs_code.json
   │     │  ├─ flutter_build
   │     │  │  ├─ 12403bf1135134f2ac446e5d98870f4e
   │     │  │  │  ├─ .filecache
   │     │  │  │  ├─ app.dill
   │     │  │  │  ├─ dart_build.d
   │     │  │  │  ├─ dart_build.stamp
   │     │  │  │  ├─ dart_build_result.json
   │     │  │  │  ├─ debug_android_application.stamp
   │     │  │  │  ├─ flutter_assets.d
   │     │  │  │  ├─ gen_dart_plugin_registrant.stamp
   │     │  │  │  ├─ gen_localizations.stamp
   │     │  │  │  ├─ install_code_assets.d
   │     │  │  │  ├─ install_code_assets.stamp
   │     │  │  │  ├─ kernel_snapshot_program.d
   │     │  │  │  ├─ kernel_snapshot_program.stamp
   │     │  │  │  ├─ native_assets.json
   │     │  │  │  └─ outputs.json
   │     │  │  └─ dart_plugin_registrant.dart
   │     │  ├─ package_config.json
   │     │  ├─ package_graph.json
   │     │  └─ version
   │     ├─ .flutter-plugins-dependencies
   │     ├─ .metadata
   │     ├─ analysis_options.yaml
   │     ├─ android
   │     │  ├─ .gradle
   │     │  │  ├─ 8.14
   │     │  │  │  ├─ checksums
   │     │  │  │  │  └─ checksums.lock
   │     │  │  │  ├─ executionHistory
   │     │  │  │  │  ├─ executionHistory.bin
   │     │  │  │  │  └─ executionHistory.lock
   │     │  │  │  ├─ expanded
   │     │  │  │  ├─ fileChanges
   │     │  │  │  │  └─ last-build.bin
   │     │  │  │  ├─ fileHashes
   │     │  │  │  │  ├─ fileHashes.bin
   │     │  │  │  │  ├─ fileHashes.lock
   │     │  │  │  │  └─ resourceHashesCache.bin
   │     │  │  │  ├─ gc.properties
   │     │  │  │  └─ vcsMetadata
   │     │  │  ├─ buildOutputCleanup
   │     │  │  │  ├─ buildOutputCleanup.lock
   │     │  │  │  ├─ cache.properties
   │     │  │  │  └─ outputFiles.bin
   │     │  │  ├─ file-system.probe
   │     │  │  ├─ noVersion
   │     │  │  │  └─ buildLogic.lock
   │     │  │  └─ vcs-1
   │     │  │     └─ gc.properties
   │     │  ├─ .kotlin
   │     │  │  └─ sessions
   │     │  ├─ app
   │     │  │  ├─ build.gradle.kts
   │     │  │  ├─ google-services.json
   │     │  │  └─ src
   │     │  │     ├─ debug
   │     │  │     │  └─ AndroidManifest.xml
   │     │  │     ├─ main
   │     │  │     │  ├─ AndroidManifest.xml
   │     │  │     │  ├─ java
   │     │  │     │  │  └─ io
   │     │  │     │  │     └─ flutter
   │     │  │     │  │        └─ plugins
   │     │  │     │  │           └─ GeneratedPluginRegistrant.java
   │     │  │     │  ├─ kotlin
   │     │  │     │  │  └─ com
   │     │  │     │  │     └─ example
   │     │  │     │  │        └─ sdgp
   │     │  │     │  │           └─ MainActivity.kt
   │     │  │     │  └─ res
   │     │  │     │     ├─ drawable
   │     │  │     │     │  └─ launch_background.xml
   │     │  │     │     ├─ drawable-v21
   │     │  │     │     │  └─ launch_background.xml
   │     │  │     │     ├─ mipmap-hdpi
   │     │  │     │     │  └─ ic_launcher.png
   │     │  │     │     ├─ mipmap-mdpi
   │     │  │     │     │  └─ ic_launcher.png
   │     │  │     │     ├─ mipmap-xhdpi
   │     │  │     │     │  └─ ic_launcher.png
   │     │  │     │     ├─ mipmap-xxhdpi
   │     │  │     │     │  └─ ic_launcher.png
   │     │  │     │     ├─ mipmap-xxxhdpi
   │     │  │     │     │  └─ ic_launcher.png
   │     │  │     │     ├─ values
   │     │  │     │     │  └─ styles.xml
   │     │  │     │     └─ values-night
   │     │  │     │        └─ styles.xml
   │     │  │     └─ profile
   │     │  │        └─ AndroidManifest.xml
   │     │  ├─ build.gradle.kts
   │     │  ├─ gradle
   │     │  │  └─ wrapper
   │     │  │     ├─ gradle-wrapper.jar
   │     │  │     └─ gradle-wrapper.properties
   │     │  ├─ gradle.properties
   │     │  ├─ gradlew
   │     │  ├─ gradlew.bat
   │     │  ├─ local.properties
   │     │  └─ settings.gradle.kts
   │     ├─ assets
   │     │  └─ logo.png
   │     ├─ build
   │     │  ├─ .cxx
   │     │  │  └─ debug
   │     │  │     └─ f21243e6
   │     │  │        ├─ arm64-v8a
   │     │  │        │  ├─ .cmake
   │     │  │        │  │  └─ api
   │     │  │        │  │     └─ v1
   │     │  │        │  │        ├─ query
   │     │  │        │  │        │  └─ client-agp
   │     │  │        │  │        │     ├─ cache-v2
   │     │  │        │  │        │     ├─ cmakeFiles-v1
   │     │  │        │  │        │     └─ codemodel-v2
   │     │  │        │  │        └─ reply
   │     │  │        │  │           ├─ cache-v2-685f5c32fae9358da1e2.json
   │     │  │        │  │           ├─ cmakeFiles-v1-a5beac281895c2d2d721.json
   │     │  │        │  │           ├─ codemodel-v2-90d0a7ce2f61abd98a96.json
   │     │  │        │  │           ├─ directory-.-debug-d0094a50bb2071803777.json
   │     │  │        │  │           └─ index-2026-02-25T06-29-51-0792.json
   │     │  │        │  ├─ additional_project_files.txt
   │     │  │        │  ├─ android_gradle_build.json
   │     │  │        │  ├─ android_gradle_build_mini.json
   │     │  │        │  ├─ build.ninja
   │     │  │        │  ├─ build_file_index.txt
   │     │  │        │  ├─ CMakeCache.txt
   │     │  │        │  ├─ CMakeFiles
   │     │  │        │  │  ├─ 3.22.1-g37088a8-dirty
   │     │  │        │  │  │  ├─ CMakeCCompiler.cmake
   │     │  │        │  │  │  ├─ CMakeCXXCompiler.cmake
   │     │  │        │  │  │  ├─ CMakeDetermineCompilerABI_C.bin
   │     │  │        │  │  │  ├─ CMakeDetermineCompilerABI_CXX.bin
   │     │  │        │  │  │  ├─ CMakeSystem.cmake
   │     │  │        │  │  │  ├─ CompilerIdC
   │     │  │        │  │  │  │  ├─ CMakeCCompilerId.c
   │     │  │        │  │  │  │  ├─ CMakeCCompilerId.o
   │     │  │        │  │  │  │  └─ tmp
   │     │  │        │  │  │  └─ CompilerIdCXX
   │     │  │        │  │  │     ├─ CMakeCXXCompilerId.cpp
   │     │  │        │  │  │     ├─ CMakeCXXCompilerId.o
   │     │  │        │  │  │     └─ tmp
   │     │  │        │  │  ├─ cmake.check_cache
   │     │  │        │  │  ├─ CMakeOutput.log
   │     │  │        │  │  ├─ CMakeTmp
   │     │  │        │  │  ├─ rules.ninja
   │     │  │        │  │  └─ TargetDirectories.txt
   │     │  │        │  ├─ cmake_install.cmake
   │     │  │        │  ├─ configure_fingerprint.bin
   │     │  │        │  ├─ metadata_generation_command.txt
   │     │  │        │  ├─ prefab_config.json
   │     │  │        │  └─ symbol_folder_index.txt
   │     │  │        ├─ armeabi-v7a
   │     │  │        │  ├─ .cmake
   │     │  │        │  │  └─ api
   │     │  │        │  │     └─ v1
   │     │  │        │  │        ├─ query
   │     │  │        │  │        │  └─ client-agp
   │     │  │        │  │        │     ├─ cache-v2
   │     │  │        │  │        │     ├─ cmakeFiles-v1
   │     │  │        │  │        │     └─ codemodel-v2
   │     │  │        │  │        └─ reply
   │     │  │        │  │           ├─ cache-v2-24d70022971026b50a55.json
   │     │  │        │  │           ├─ cmakeFiles-v1-d15f2fb71def2f844364.json
   │     │  │        │  │           ├─ codemodel-v2-c17a49dea81cb874d408.json
   │     │  │        │  │           ├─ directory-.-debug-d0094a50bb2071803777.json
   │     │  │        │  │           └─ index-2026-02-25T06-29-53-0015.json
   │     │  │        │  ├─ additional_project_files.txt
   │     │  │        │  ├─ android_gradle_build.json
   │     │  │        │  ├─ android_gradle_build_mini.json
   │     │  │        │  ├─ build.ninja
   │     │  │        │  ├─ build_file_index.txt
   │     │  │        │  ├─ CMakeCache.txt
   │     │  │        │  ├─ CMakeFiles
   │     │  │        │  │  ├─ 3.22.1-g37088a8-dirty
   │     │  │        │  │  │  ├─ CMakeCCompiler.cmake
   │     │  │        │  │  │  ├─ CMakeCXXCompiler.cmake
   │     │  │        │  │  │  ├─ CMakeDetermineCompilerABI_C.bin
   │     │  │        │  │  │  ├─ CMakeDetermineCompilerABI_CXX.bin
   │     │  │        │  │  │  ├─ CMakeSystem.cmake
   │     │  │        │  │  │  ├─ CompilerIdC
   │     │  │        │  │  │  │  ├─ CMakeCCompilerId.c
   │     │  │        │  │  │  │  ├─ CMakeCCompilerId.o
   │     │  │        │  │  │  │  └─ tmp
   │     │  │        │  │  │  └─ CompilerIdCXX
   │     │  │        │  │  │     ├─ CMakeCXXCompilerId.cpp
   │     │  │        │  │  │     ├─ CMakeCXXCompilerId.o
   │     │  │        │  │  │     └─ tmp
   │     │  │        │  │  ├─ cmake.check_cache
   │     │  │        │  │  ├─ CMakeOutput.log
   │     │  │        │  │  ├─ CMakeTmp
   │     │  │        │  │  ├─ rules.ninja
   │     │  │        │  │  └─ TargetDirectories.txt
   │     │  │        │  ├─ cmake_install.cmake
   │     │  │        │  ├─ configure_fingerprint.bin
   │     │  │        │  ├─ metadata_generation_command.txt
   │     │  │        │  ├─ prefab_config.json
   │     │  │        │  └─ symbol_folder_index.txt
   │     │  │        ├─ hash_key.txt
   │     │  │        └─ x86_64
   │     │  │           ├─ .cmake
   │     │  │           │  └─ api
   │     │  │           │     └─ v1
   │     │  │           │        ├─ query
   │     │  │           │        │  └─ client-agp
   │     │  │           │        │     ├─ cache-v2
   │     │  │           │        │     ├─ cmakeFiles-v1
   │     │  │           │        │     └─ codemodel-v2
   │     │  │           │        └─ reply
   │     │  │           │           ├─ cache-v2-966396b1d435a99421b2.json
   │     │  │           │           ├─ cmakeFiles-v1-6b37dafeb3bc94369252.json
   │     │  │           │           ├─ codemodel-v2-c0a30dc38f0b5c1b7b59.json
   │     │  │           │           ├─ directory-.-debug-d0094a50bb2071803777.json
   │     │  │           │           └─ index-2026-02-25T06-29-54-0185.json
   │     │  │           ├─ additional_project_files.txt
   │     │  │           ├─ android_gradle_build.json
   │     │  │           ├─ android_gradle_build_mini.json
   │     │  │           ├─ build.ninja
   │     │  │           ├─ build_file_index.txt
   │     │  │           ├─ CMakeCache.txt
   │     │  │           ├─ CMakeFiles
   │     │  │           │  ├─ 3.22.1-g37088a8-dirty
   │     │  │           │  │  ├─ CMakeCCompiler.cmake
   │     │  │           │  │  ├─ CMakeCXXCompiler.cmake
   │     │  │           │  │  ├─ CMakeDetermineCompilerABI_C.bin
   │     │  │           │  │  ├─ CMakeDetermineCompilerABI_CXX.bin
   │     │  │           │  │  ├─ CMakeSystem.cmake
   │     │  │           │  │  ├─ CompilerIdC
   │     │  │           │  │  │  ├─ CMakeCCompilerId.c
   │     │  │           │  │  │  ├─ CMakeCCompilerId.o
   │     │  │           │  │  │  └─ tmp
   │     │  │           │  │  └─ CompilerIdCXX
   │     │  │           │  │     ├─ CMakeCXXCompilerId.cpp
   │     │  │           │  │     ├─ CMakeCXXCompilerId.o
   │     │  │           │  │     └─ tmp
   │     │  │           │  ├─ cmake.check_cache
   │     │  │           │  ├─ CMakeOutput.log
   │     │  │           │  ├─ CMakeTmp
   │     │  │           │  ├─ rules.ninja
   │     │  │           │  └─ TargetDirectories.txt
   │     │  │           ├─ cmake_install.cmake
   │     │  │           ├─ configure_fingerprint.bin
   │     │  │           ├─ metadata_generation_command.txt
   │     │  │           ├─ prefab_config.json
   │     │  │           └─ symbol_folder_index.txt
   │     │  ├─ a86154e4534e06258ebaa2c23063b787
   │     │  │  ├─ gen_dart_plugin_registrant.stamp
   │     │  │  ├─ gen_localizations.stamp
   │     │  │  └─ _composite.stamp
   │     │  ├─ app
   │     │  │  ├─ deeplink.json
   │     │  │  ├─ generated
   │     │  │  │  ├─ ap_generated_sources
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ out
   │     │  │  │  └─ res
   │     │  │  │     ├─ pngs
   │     │  │  │     │  └─ debug
   │     │  │  │     ├─ processDebugGoogleServices
   │     │  │  │     │  └─ values
   │     │  │  │     │     └─ values.xml
   │     │  │  │     └─ resValues
   │     │  │  │        └─ debug
   │     │  │  ├─ gmpAppId
   │     │  │  │  └─ debug.txt
   │     │  │  ├─ intermediates
   │     │  │  │  ├─ aar_metadata_check
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ checkDebugAarMetadata
   │     │  │  │  ├─ annotation_processor_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ javaPreCompileDebug
   │     │  │  │  │        └─ annotationProcessors.json
   │     │  │  │  ├─ apk_ide_redirect_file
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ createDebugApkListingFileRedirect
   │     │  │  │  │        └─ redirect.txt
   │     │  │  │  ├─ app_metadata
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ writeDebugAppMetadata
   │     │  │  │  │        └─ app-metadata.properties
   │     │  │  │  ├─ assets
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugAssets
   │     │  │  │  │        └─ flutter_assets
   │     │  │  │  │           ├─ AssetManifest.bin
   │     │  │  │  │           ├─ assets
   │     │  │  │  │           │  └─ logo.png
   │     │  │  │  │           ├─ FontManifest.json
   │     │  │  │  │           ├─ fonts
   │     │  │  │  │           │  └─ MaterialIcons-Regular.otf
   │     │  │  │  │           ├─ isolate_snapshot_data
   │     │  │  │  │           ├─ kernel_blob.bin
   │     │  │  │  │           ├─ NativeAssetsManifest.json
   │     │  │  │  │           ├─ NOTICES.Z
   │     │  │  │  │           ├─ packages
   │     │  │  │  │           │  └─ cupertino_icons
   │     │  │  │  │           │     └─ assets
   │     │  │  │  │           │        └─ CupertinoIcons.ttf
   │     │  │  │  │           ├─ shaders
   │     │  │  │  │           │  ├─ ink_sparkle.frag
   │     │  │  │  │           │  └─ stretch_effect.frag
   │     │  │  │  │           └─ vm_snapshot_data
   │     │  │  │  ├─ compatible_screen_manifest
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ createDebugCompatibleScreenManifests
   │     │  │  │  │        └─ output-metadata.json
   │     │  │  │  ├─ compile_and_runtime_not_namespaced_r_class_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugResources
   │     │  │  │  │        └─ R.jar
   │     │  │  │  ├─ compressed_assets
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ compressDebugAssets
   │     │  │  │  │        └─ out
   │     │  │  │  │           └─ assets
   │     │  │  │  │              └─ flutter_assets
   │     │  │  │  │                 ├─ AssetManifest.bin.jar
   │     │  │  │  │                 ├─ assets
   │     │  │  │  │                 │  └─ logo.png.jar
   │     │  │  │  │                 ├─ FontManifest.json.jar
   │     │  │  │  │                 ├─ fonts
   │     │  │  │  │                 │  └─ MaterialIcons-Regular.otf.jar
   │     │  │  │  │                 ├─ isolate_snapshot_data.jar
   │     │  │  │  │                 ├─ kernel_blob.bin.jar
   │     │  │  │  │                 ├─ NativeAssetsManifest.json.jar
   │     │  │  │  │                 ├─ NOTICES.Z.jar
   │     │  │  │  │                 ├─ packages
   │     │  │  │  │                 │  └─ cupertino_icons
   │     │  │  │  │                 │     └─ assets
   │     │  │  │  │                 │        └─ CupertinoIcons.ttf.jar
   │     │  │  │  │                 ├─ shaders
   │     │  │  │  │                 │  ├─ ink_sparkle.frag.jar
   │     │  │  │  │                 │  └─ stretch_effect.frag.jar
   │     │  │  │  │                 └─ vm_snapshot_data.jar
   │     │  │  │  ├─ cxx
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ f21243e6
   │     │  │  │  │        ├─ logs
   │     │  │  │  │        │  ├─ arm64-v8a
   │     │  │  │  │        │  │  ├─ build_model.json
   │     │  │  │  │        │  │  ├─ configure_command.bat
   │     │  │  │  │        │  │  ├─ configure_stderr.txt
   │     │  │  │  │        │  │  ├─ configure_stdout.txt
   │     │  │  │  │        │  │  ├─ generate_cxx_metadata_2894_timing.txt
   │     │  │  │  │        │  │  └─ metadata_generation_record.json
   │     │  │  │  │        │  ├─ armeabi-v7a
   │     │  │  │  │        │  │  ├─ build_model.json
   │     │  │  │  │        │  │  ├─ configure_command.bat
   │     │  │  │  │        │  │  ├─ configure_stderr.txt
   │     │  │  │  │        │  │  ├─ configure_stdout.txt
   │     │  │  │  │        │  │  ├─ generate_cxx_metadata_2889_timing.txt
   │     │  │  │  │        │  │  └─ metadata_generation_record.json
   │     │  │  │  │        │  └─ x86_64
   │     │  │  │  │        │     ├─ build_model.json
   │     │  │  │  │        │     ├─ configure_command.bat
   │     │  │  │  │        │     ├─ configure_stderr.txt
   │     │  │  │  │        │     ├─ configure_stdout.txt
   │     │  │  │  │        │     ├─ generate_cxx_metadata_2903_timing.txt
   │     │  │  │  │        │     └─ metadata_generation_record.json
   │     │  │  │  │        └─ obj
   │     │  │  │  │           ├─ arm64-v8a
   │     │  │  │  │           ├─ armeabi-v7a
   │     │  │  │  │           └─ x86_64
   │     │  │  │  ├─ data_binding_layout_info_type_merge
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugResources
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ data_binding_layout_info_type_package
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ desugar_graph
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ dexBuilderDebug
   │     │  │  │  │        └─ out
   │     │  │  │  │           ├─ currentProject
   │     │  │  │  │           │  ├─ dirs_bucket_0
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ dirs_bucket_1
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ dirs_bucket_10
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ dirs_bucket_11
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ dirs_bucket_12
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ dirs_bucket_13
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ dirs_bucket_14
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ dirs_bucket_15
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ dirs_bucket_2
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ dirs_bucket_3
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ dirs_bucket_4
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ dirs_bucket_5
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ dirs_bucket_6
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ dirs_bucket_7
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ dirs_bucket_8
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ dirs_bucket_9
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_0
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_1
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_10
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_11
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_12
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_13
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_14
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_15
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_2
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_3
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_4
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_5
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_6
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_7
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  ├─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_8
   │     │  │  │  │           │  │  └─ graph.bin
   │     │  │  │  │           │  └─ jar_d8b2c262ae0394daa98fb019519976c3783a83a9ac8c5ca86dd3e49285e2ebc6_bucket_9
   │     │  │  │  │           │     └─ graph.bin
   │     │  │  │  │           ├─ externalLibs
   │     │  │  │  │           ├─ mixedScopes
   │     │  │  │  │           └─ otherProjects
   │     │  │  │  ├─ desugar_lib_dex
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ l8DexDesugarLibDebug
   │     │  │  │  │        └─ classes1000.dex
   │     │  │  │  ├─ dex
   │     │  │  │  │  └─ debug
   │     │  │  │  │     ├─ mergeExtDexDebug
   │     │  │  │  │     │  ├─ classes.dex
   │     │  │  │  │     │  ├─ classes2.dex
   │     │  │  │  │     │  └─ classes3.dex
   │     │  │  │  │     ├─ mergeLibDexDebug
   │     │  │  │  │     │  ├─ 0
   │     │  │  │  │     │  ├─ 1
   │     │  │  │  │     │  ├─ 10
   │     │  │  │  │     │  │  └─ classes.dex
   │     │  │  │  │     │  ├─ 11
   │     │  │  │  │     │  │  └─ classes.dex
   │     │  │  │  │     │  ├─ 12
   │     │  │  │  │     │  ├─ 13
   │     │  │  │  │     │  │  └─ classes.dex
   │     │  │  │  │     │  ├─ 14
   │     │  │  │  │     │  │  └─ classes.dex
   │     │  │  │  │     │  ├─ 15
   │     │  │  │  │     │  ├─ 2
   │     │  │  │  │     │  │  └─ classes.dex
   │     │  │  │  │     │  ├─ 3
   │     │  │  │  │     │  │  └─ classes.dex
   │     │  │  │  │     │  ├─ 4
   │     │  │  │  │     │  │  └─ classes.dex
   │     │  │  │  │     │  ├─ 5
   │     │  │  │  │     │  ├─ 6
   │     │  │  │  │     │  ├─ 7
   │     │  │  │  │     │  │  └─ classes.dex
   │     │  │  │  │     │  ├─ 8
   │     │  │  │  │     │  └─ 9
   │     │  │  │  │     └─ mergeProjectDexDebug
   │     │  │  │  │        ├─ 0
   │     │  │  │  │        │  └─ classes.dex
   │     │  │  │  │        ├─ 1
   │     │  │  │  │        │  └─ classes.dex
   │     │  │  │  │        ├─ 10
   │     │  │  │  │        ├─ 11
   │     │  │  │  │        ├─ 12
   │     │  │  │  │        ├─ 13
   │     │  │  │  │        ├─ 14
   │     │  │  │  │        ├─ 15
   │     │  │  │  │        ├─ 2
   │     │  │  │  │        ├─ 3
   │     │  │  │  │        ├─ 4
   │     │  │  │  │        │  └─ classes.dex
   │     │  │  │  │        ├─ 5
   │     │  │  │  │        ├─ 6
   │     │  │  │  │        ├─ 7
   │     │  │  │  │        ├─ 8
   │     │  │  │  │        └─ 9
   │     │  │  │  ├─ dex_archive_input_jar_hashes
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ dexBuilderDebug
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ dex_number_of_buckets_file
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ dexBuilderDebug
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ duplicate_classes_check
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ checkDebugDuplicateClasses
   │     │  │  │  ├─ external_file_lib_dex_archives
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ desugarDebugFileDependencies
   │     │  │  │  ├─ external_libs_dex_archive
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ dexBuilderDebug
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ external_libs_dex_archive_with_artifact_transforms
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ dexBuilderDebug
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ flutter
   │     │  │  │  │  └─ debug
   │     │  │  │  │     ├─ .last_build_id
   │     │  │  │  │     ├─ flutter_assets
   │     │  │  │  │     │  ├─ AssetManifest.bin
   │     │  │  │  │     │  ├─ assets
   │     │  │  │  │     │  │  └─ logo.png
   │     │  │  │  │     │  ├─ FontManifest.json
   │     │  │  │  │     │  ├─ fonts
   │     │  │  │  │     │  │  └─ MaterialIcons-Regular.otf
   │     │  │  │  │     │  ├─ isolate_snapshot_data
   │     │  │  │  │     │  ├─ kernel_blob.bin
   │     │  │  │  │     │  ├─ NativeAssetsManifest.json
   │     │  │  │  │     │  ├─ NOTICES.Z
   │     │  │  │  │     │  ├─ packages
   │     │  │  │  │     │  │  └─ cupertino_icons
   │     │  │  │  │     │  │     └─ assets
   │     │  │  │  │     │  │        └─ CupertinoIcons.ttf
   │     │  │  │  │     │  ├─ shaders
   │     │  │  │  │     │  │  ├─ ink_sparkle.frag
   │     │  │  │  │     │  │  └─ stretch_effect.frag
   │     │  │  │  │     │  └─ vm_snapshot_data
   │     │  │  │  │     ├─ flutter_build.d
   │     │  │  │  │     └─ libs.jar
   │     │  │  │  ├─ global_synthetics_dex
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugGlobalSynthetics
   │     │  │  │  ├─ global_synthetics_external_lib
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ dexBuilderDebug
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ global_synthetics_external_libs_artifact_transform
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ dexBuilderDebug
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ global_synthetics_file_lib
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ desugarDebugFileDependencies
   │     │  │  │  ├─ global_synthetics_mixed_scope
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ dexBuilderDebug
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ global_synthetics_project
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ dexBuilderDebug
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ global_synthetics_subproject
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ dexBuilderDebug
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ incremental
   │     │  │  │  │  ├─ debug
   │     │  │  │  │  │  ├─ mergeDebugResources
   │     │  │  │  │  │  │  ├─ compile-file-map.properties
   │     │  │  │  │  │  │  ├─ merged.dir
   │     │  │  │  │  │  │  │  ├─ values
   │     │  │  │  │  │  │  │  │  └─ values.xml
   │     │  │  │  │  │  │  │  ├─ values-af
   │     │  │  │  │  │  │  │  │  └─ values-af.xml
   │     │  │  │  │  │  │  │  ├─ values-am
   │     │  │  │  │  │  │  │  │  └─ values-am.xml
   │     │  │  │  │  │  │  │  ├─ values-ar
   │     │  │  │  │  │  │  │  │  └─ values-ar.xml
   │     │  │  │  │  │  │  │  ├─ values-as
   │     │  │  │  │  │  │  │  │  └─ values-as.xml
   │     │  │  │  │  │  │  │  ├─ values-az
   │     │  │  │  │  │  │  │  │  └─ values-az.xml
   │     │  │  │  │  │  │  │  ├─ values-b+sr+Latn
   │     │  │  │  │  │  │  │  │  └─ values-b+sr+Latn.xml
   │     │  │  │  │  │  │  │  ├─ values-be
   │     │  │  │  │  │  │  │  │  └─ values-be.xml
   │     │  │  │  │  │  │  │  ├─ values-bg
   │     │  │  │  │  │  │  │  │  └─ values-bg.xml
   │     │  │  │  │  │  │  │  ├─ values-bn
   │     │  │  │  │  │  │  │  │  └─ values-bn.xml
   │     │  │  │  │  │  │  │  ├─ values-bs
   │     │  │  │  │  │  │  │  │  └─ values-bs.xml
   │     │  │  │  │  │  │  │  ├─ values-ca
   │     │  │  │  │  │  │  │  │  └─ values-ca.xml
   │     │  │  │  │  │  │  │  ├─ values-cs
   │     │  │  │  │  │  │  │  │  └─ values-cs.xml
   │     │  │  │  │  │  │  │  ├─ values-da
   │     │  │  │  │  │  │  │  │  └─ values-da.xml
   │     │  │  │  │  │  │  │  ├─ values-de
   │     │  │  │  │  │  │  │  │  └─ values-de.xml
   │     │  │  │  │  │  │  │  ├─ values-el
   │     │  │  │  │  │  │  │  │  └─ values-el.xml
   │     │  │  │  │  │  │  │  ├─ values-en-rAU
   │     │  │  │  │  │  │  │  │  └─ values-en-rAU.xml
   │     │  │  │  │  │  │  │  ├─ values-en-rCA
   │     │  │  │  │  │  │  │  │  └─ values-en-rCA.xml
   │     │  │  │  │  │  │  │  ├─ values-en-rGB
   │     │  │  │  │  │  │  │  │  └─ values-en-rGB.xml
   │     │  │  │  │  │  │  │  ├─ values-en-rIN
   │     │  │  │  │  │  │  │  │  └─ values-en-rIN.xml
   │     │  │  │  │  │  │  │  ├─ values-en-rXC
   │     │  │  │  │  │  │  │  │  └─ values-en-rXC.xml
   │     │  │  │  │  │  │  │  ├─ values-es
   │     │  │  │  │  │  │  │  │  └─ values-es.xml
   │     │  │  │  │  │  │  │  ├─ values-es-rUS
   │     │  │  │  │  │  │  │  │  └─ values-es-rUS.xml
   │     │  │  │  │  │  │  │  ├─ values-et
   │     │  │  │  │  │  │  │  │  └─ values-et.xml
   │     │  │  │  │  │  │  │  ├─ values-eu
   │     │  │  │  │  │  │  │  │  └─ values-eu.xml
   │     │  │  │  │  │  │  │  ├─ values-fa
   │     │  │  │  │  │  │  │  │  └─ values-fa.xml
   │     │  │  │  │  │  │  │  ├─ values-fi
   │     │  │  │  │  │  │  │  │  └─ values-fi.xml
   │     │  │  │  │  │  │  │  ├─ values-fr
   │     │  │  │  │  │  │  │  │  └─ values-fr.xml
   │     │  │  │  │  │  │  │  ├─ values-fr-rCA
   │     │  │  │  │  │  │  │  │  └─ values-fr-rCA.xml
   │     │  │  │  │  │  │  │  ├─ values-gl
   │     │  │  │  │  │  │  │  │  └─ values-gl.xml
   │     │  │  │  │  │  │  │  ├─ values-gu
   │     │  │  │  │  │  │  │  │  └─ values-gu.xml
   │     │  │  │  │  │  │  │  ├─ values-hi
   │     │  │  │  │  │  │  │  │  └─ values-hi.xml
   │     │  │  │  │  │  │  │  ├─ values-hr
   │     │  │  │  │  │  │  │  │  └─ values-hr.xml
   │     │  │  │  │  │  │  │  ├─ values-hu
   │     │  │  │  │  │  │  │  │  └─ values-hu.xml
   │     │  │  │  │  │  │  │  ├─ values-hy
   │     │  │  │  │  │  │  │  │  └─ values-hy.xml
   │     │  │  │  │  │  │  │  ├─ values-in
   │     │  │  │  │  │  │  │  │  └─ values-in.xml
   │     │  │  │  │  │  │  │  ├─ values-is
   │     │  │  │  │  │  │  │  │  └─ values-is.xml
   │     │  │  │  │  │  │  │  ├─ values-it
   │     │  │  │  │  │  │  │  │  └─ values-it.xml
   │     │  │  │  │  │  │  │  ├─ values-iw
   │     │  │  │  │  │  │  │  │  └─ values-iw.xml
   │     │  │  │  │  │  │  │  ├─ values-ja
   │     │  │  │  │  │  │  │  │  └─ values-ja.xml
   │     │  │  │  │  │  │  │  ├─ values-ka
   │     │  │  │  │  │  │  │  │  └─ values-ka.xml
   │     │  │  │  │  │  │  │  ├─ values-kk
   │     │  │  │  │  │  │  │  │  └─ values-kk.xml
   │     │  │  │  │  │  │  │  ├─ values-km
   │     │  │  │  │  │  │  │  │  └─ values-km.xml
   │     │  │  │  │  │  │  │  ├─ values-kn
   │     │  │  │  │  │  │  │  │  └─ values-kn.xml
   │     │  │  │  │  │  │  │  ├─ values-ko
   │     │  │  │  │  │  │  │  │  └─ values-ko.xml
   │     │  │  │  │  │  │  │  ├─ values-ky
   │     │  │  │  │  │  │  │  │  └─ values-ky.xml
   │     │  │  │  │  │  │  │  ├─ values-lo
   │     │  │  │  │  │  │  │  │  └─ values-lo.xml
   │     │  │  │  │  │  │  │  ├─ values-lt
   │     │  │  │  │  │  │  │  │  └─ values-lt.xml
   │     │  │  │  │  │  │  │  ├─ values-lv
   │     │  │  │  │  │  │  │  │  └─ values-lv.xml
   │     │  │  │  │  │  │  │  ├─ values-mk
   │     │  │  │  │  │  │  │  │  └─ values-mk.xml
   │     │  │  │  │  │  │  │  ├─ values-ml
   │     │  │  │  │  │  │  │  │  └─ values-ml.xml
   │     │  │  │  │  │  │  │  ├─ values-mn
   │     │  │  │  │  │  │  │  │  └─ values-mn.xml
   │     │  │  │  │  │  │  │  ├─ values-mr
   │     │  │  │  │  │  │  │  │  └─ values-mr.xml
   │     │  │  │  │  │  │  │  ├─ values-ms
   │     │  │  │  │  │  │  │  │  └─ values-ms.xml
   │     │  │  │  │  │  │  │  ├─ values-my
   │     │  │  │  │  │  │  │  │  └─ values-my.xml
   │     │  │  │  │  │  │  │  ├─ values-nb
   │     │  │  │  │  │  │  │  │  └─ values-nb.xml
   │     │  │  │  │  │  │  │  ├─ values-ne
   │     │  │  │  │  │  │  │  │  └─ values-ne.xml
   │     │  │  │  │  │  │  │  ├─ values-night-v8
   │     │  │  │  │  │  │  │  │  └─ values-night-v8.xml
   │     │  │  │  │  │  │  │  ├─ values-nl
   │     │  │  │  │  │  │  │  │  └─ values-nl.xml
   │     │  │  │  │  │  │  │  ├─ values-or
   │     │  │  │  │  │  │  │  │  └─ values-or.xml
   │     │  │  │  │  │  │  │  ├─ values-pa
   │     │  │  │  │  │  │  │  │  └─ values-pa.xml
   │     │  │  │  │  │  │  │  ├─ values-pl
   │     │  │  │  │  │  │  │  │  └─ values-pl.xml
   │     │  │  │  │  │  │  │  ├─ values-pt
   │     │  │  │  │  │  │  │  │  └─ values-pt.xml
   │     │  │  │  │  │  │  │  ├─ values-pt-rBR
   │     │  │  │  │  │  │  │  │  └─ values-pt-rBR.xml
   │     │  │  │  │  │  │  │  ├─ values-pt-rPT
   │     │  │  │  │  │  │  │  │  └─ values-pt-rPT.xml
   │     │  │  │  │  │  │  │  ├─ values-ro
   │     │  │  │  │  │  │  │  │  └─ values-ro.xml
   │     │  │  │  │  │  │  │  ├─ values-ru
   │     │  │  │  │  │  │  │  │  └─ values-ru.xml
   │     │  │  │  │  │  │  │  ├─ values-si
   │     │  │  │  │  │  │  │  │  └─ values-si.xml
   │     │  │  │  │  │  │  │  ├─ values-sk
   │     │  │  │  │  │  │  │  │  └─ values-sk.xml
   │     │  │  │  │  │  │  │  ├─ values-sl
   │     │  │  │  │  │  │  │  │  └─ values-sl.xml
   │     │  │  │  │  │  │  │  ├─ values-sq
   │     │  │  │  │  │  │  │  │  └─ values-sq.xml
   │     │  │  │  │  │  │  │  ├─ values-sr
   │     │  │  │  │  │  │  │  │  └─ values-sr.xml
   │     │  │  │  │  │  │  │  ├─ values-sv
   │     │  │  │  │  │  │  │  │  └─ values-sv.xml
   │     │  │  │  │  │  │  │  ├─ values-sw
   │     │  │  │  │  │  │  │  │  └─ values-sw.xml
   │     │  │  │  │  │  │  │  ├─ values-ta
   │     │  │  │  │  │  │  │  │  └─ values-ta.xml
   │     │  │  │  │  │  │  │  ├─ values-te
   │     │  │  │  │  │  │  │  │  └─ values-te.xml
   │     │  │  │  │  │  │  │  ├─ values-th
   │     │  │  │  │  │  │  │  │  └─ values-th.xml
   │     │  │  │  │  │  │  │  ├─ values-tl
   │     │  │  │  │  │  │  │  │  └─ values-tl.xml
   │     │  │  │  │  │  │  │  ├─ values-tr
   │     │  │  │  │  │  │  │  │  └─ values-tr.xml
   │     │  │  │  │  │  │  │  ├─ values-uk
   │     │  │  │  │  │  │  │  │  └─ values-uk.xml
   │     │  │  │  │  │  │  │  ├─ values-ur
   │     │  │  │  │  │  │  │  │  └─ values-ur.xml
   │     │  │  │  │  │  │  │  ├─ values-uz
   │     │  │  │  │  │  │  │  │  └─ values-uz.xml
   │     │  │  │  │  │  │  │  ├─ values-v21
   │     │  │  │  │  │  │  │  │  └─ values-v21.xml
   │     │  │  │  │  │  │  │  ├─ values-v24
   │     │  │  │  │  │  │  │  │  └─ values-v24.xml
   │     │  │  │  │  │  │  │  ├─ values-vi
   │     │  │  │  │  │  │  │  │  └─ values-vi.xml
   │     │  │  │  │  │  │  │  ├─ values-watch-v20
   │     │  │  │  │  │  │  │  │  └─ values-watch-v20.xml
   │     │  │  │  │  │  │  │  ├─ values-zh-rCN
   │     │  │  │  │  │  │  │  │  └─ values-zh-rCN.xml
   │     │  │  │  │  │  │  │  ├─ values-zh-rHK
   │     │  │  │  │  │  │  │  │  └─ values-zh-rHK.xml
   │     │  │  │  │  │  │  │  ├─ values-zh-rTW
   │     │  │  │  │  │  │  │  │  └─ values-zh-rTW.xml
   │     │  │  │  │  │  │  │  └─ values-zu
   │     │  │  │  │  │  │  │     └─ values-zu.xml
   │     │  │  │  │  │  │  ├─ merger.xml
   │     │  │  │  │  │  │  └─ stripped.dir
   │     │  │  │  │  │  └─ packageDebugResources
   │     │  │  │  │  │     ├─ compile-file-map.properties
   │     │  │  │  │  │     ├─ merged.dir
   │     │  │  │  │  │     │  ├─ values
   │     │  │  │  │  │     │  │  └─ values.xml
   │     │  │  │  │  │     │  └─ values-night-v8
   │     │  │  │  │  │     │     └─ values-night-v8.xml
   │     │  │  │  │  │     ├─ merger.xml
   │     │  │  │  │  │     └─ stripped.dir
   │     │  │  │  │  ├─ debug-mergeJavaRes
   │     │  │  │  │  │  ├─ merge-state
   │     │  │  │  │  │  └─ zip-cache
   │     │  │  │  │  │     ├─ +BnivVweA0AeHiqxS6yvASf+eK0=
   │     │  │  │  │  │     ├─ +leHdhY25U_VgcKi_WbvsJGCga4=
   │     │  │  │  │  │     ├─ +TH0zUN6tTqie9ngXNuHmobW2_8=
   │     │  │  │  │  │     ├─ +xReK5EUpg2Rst+qcfjXvjSQjb0=
   │     │  │  │  │  │     ├─ 0iD94NzzwyaCI9V060Pz9C8tS+M=
   │     │  │  │  │  │     ├─ 0WEiVv63+vhJXtzUDuVWQV9F8Eg=
   │     │  │  │  │  │     ├─ 1bJIHCeSd_Q_YF0QTESYp54s1_M=
   │     │  │  │  │  │     ├─ 1wd81hdq4g1nhV+j+dCNh4hZ06g=
   │     │  │  │  │  │     ├─ 2LLiaI0e2n6FIlQIw84Bf0W9tDA=
   │     │  │  │  │  │     ├─ 2nOubW9FJA7fPY+PkVtxITOudcA=
   │     │  │  │  │  │     ├─ 2QKvMtN9DYFNoVzCNAQ2W_5nSr4=
   │     │  │  │  │  │     ├─ 2zttAV+0fO5jh_CEeL2+p95s5dc=
   │     │  │  │  │  │     ├─ 31aW0xvnWKaKPvMjjUyQ6agOlRc=
   │     │  │  │  │  │     ├─ 3udBHD2t8iX8qTkhor_xjVmbHuQ=
   │     │  │  │  │  │     ├─ 49uhonMlEmdfLq5dNaIbZpLDqx8=
   │     │  │  │  │  │     ├─ 4WvBndAaq44N9QOPqp1f1_uiY8w=
   │     │  │  │  │  │     ├─ 4YF3ZX9gYAhIYMA7oQ2_YgH8QCg=
   │     │  │  │  │  │     ├─ 56U3bRa1A8FhHxeexOvCmL51OWI=
   │     │  │  │  │  │     ├─ 59bqe0XmLYv+UVpcIAgeAlPb7ug=
   │     │  │  │  │  │     ├─ 5rDoujZz1iTf4eaqj9hg4QU8kpE=
   │     │  │  │  │  │     ├─ 5u8T_Ki+Q17E0jhKzpJZ6afJjY0=
   │     │  │  │  │  │     ├─ 6637THT6Q4sF8uPMTd2T6GvGEGs=
   │     │  │  │  │  │     ├─ 6N6NTR8d4pRbJG6gLqwQ9wvyXBo=
   │     │  │  │  │  │     ├─ 8e+VI2J_28RK0zBj0NiNVos3lDI=
   │     │  │  │  │  │     ├─ 8ea+OKOd2XxUVZwbVJYTB6JFjMk=
   │     │  │  │  │  │     ├─ 8Xvuq_oLT0_7N8pI4YJEBKOQ6IM=
   │     │  │  │  │  │     ├─ 8YhOtlVO1S7X57CtGU7lRmicIaU=
   │     │  │  │  │  │     ├─ 9MaC4IEuLUEvE1oZLsSUoTGulEw=
   │     │  │  │  │  │     ├─ 9OUSaoaRMN773VOhKGgQmKYAZu0=
   │     │  │  │  │  │     ├─ a+BntUczyMLpmwctxs+FhiGIYu0=
   │     │  │  │  │  │     ├─ at58HmZ_0VU9FbSq7IWNYOhAD2Q=
   │     │  │  │  │  │     ├─ aUuD8KUIHoZ8i64HHOUVcDwsJ0Q=
   │     │  │  │  │  │     ├─ Bi9aEk8zNBLdMRetZaYKOT9Fctw=
   │     │  │  │  │  │     ├─ D+XSXR9I2wBCDz_fx5Hk7K4jk2o=
   │     │  │  │  │  │     ├─ d1pIklthZNYnkdqen0YoBDKAWsI=
   │     │  │  │  │  │     ├─ d4Jn+ByjtA5DkrpfxLksKnmO6n8=
   │     │  │  │  │  │     ├─ D78hvLr88Xhy3E0kmiFPcSDlJNk=
   │     │  │  │  │  │     ├─ dgCMF1WFfqBAZu55ZgJbfAvewKo=
   │     │  │  │  │  │     ├─ DgtNK2JKMgbb59tr88eBwCfrBaQ=
   │     │  │  │  │  │     ├─ Dmpqwx8rdbijDrUC5i2wCCWmIEY=
   │     │  │  │  │  │     ├─ dtbHYamAfAhFhE9EVj577c+33yg=
   │     │  │  │  │  │     ├─ e6WW1bPhKXOU8lY8iJxP3sRML2I=
   │     │  │  │  │  │     ├─ eK6qzpskykfO_osawOLQXMhIZ0U=
   │     │  │  │  │  │     ├─ eWh3repX153_Ot1zvRe6kai4+dk=
   │     │  │  │  │  │     ├─ f1DlYxlfbioBOxv2MVDNxIiOf3E=
   │     │  │  │  │  │     ├─ f1Z+rK5MmSqddIj+a5tMLzWE0ZQ=
   │     │  │  │  │  │     ├─ feQzeiilL_F_UV6Mc9lRdQYnh6w=
   │     │  │  │  │  │     ├─ gJxCnwd4l7MW59CBDlDY6oRv6Og=
   │     │  │  │  │  │     ├─ GtfPA+n+ttz9ERPIittbek+ku10=
   │     │  │  │  │  │     ├─ Gv3J6U965wh2rRp_LgXJhOjE7tk=
   │     │  │  │  │  │     ├─ GvxsXaPwg8iKU477+GIuJTTT2bg=
   │     │  │  │  │  │     ├─ H3unIHR5Io6sIHz9tMfwyxeCzu8=
   │     │  │  │  │  │     ├─ HaNIDYlngIpLTaWd5oSTTCZFJkQ=
   │     │  │  │  │  │     ├─ hSfJ9uiajhdYFwU1t1ZqAXDtJJg=
   │     │  │  │  │  │     ├─ HuZIM0ZqJKgKHGOtAlf3ICMBqsg=
   │     │  │  │  │  │     ├─ hWmQ6R035mrQ2BCgZdPxPYCjjhE=
   │     │  │  │  │  │     ├─ hWysnkC3zVQ9766qqP+Rk2oPMdU=
   │     │  │  │  │  │     ├─ hXug+dynh_CvU2eksgEX2OjKndI=
   │     │  │  │  │  │     ├─ IzvGjPDlcGE_Gg0fUxmzeoGXMRg=
   │     │  │  │  │  │     ├─ JvrsgoK5sOT+GNmlq15_kd3+CQg=
   │     │  │  │  │  │     ├─ JXsLGrAQcleF8MF4ezaKXVREh6g=
   │     │  │  │  │  │     ├─ kFa+GEGEg8uq8ddgRSkWUf6TYoM=
   │     │  │  │  │  │     ├─ kneLOruVtRUefoNdC_b9B5WpGjQ=
   │     │  │  │  │  │     ├─ kZvsAvVDP74OcteA6Ex8Q+unPLM=
   │     │  │  │  │  │     ├─ lL97TRq1YHxhDo4n36qxKM18P+E=
   │     │  │  │  │  │     ├─ lW0ky2Vke3NXlrrtMhyssOg7Xxo=
   │     │  │  │  │  │     ├─ m+EhHFIdHG3pqp2kQkrgnzrX+xA=
   │     │  │  │  │  │     ├─ M4Z8aA2M5BQd9cKgmOKhahj0fuI=
   │     │  │  │  │  │     ├─ MHokqP94v3Nb71uok4bbgBXu1eo=
   │     │  │  │  │  │     ├─ nb3W3EI+Ky0q2QgybrvsPzRGDdc=
   │     │  │  │  │  │     ├─ nCdN2Uo96TnDNZPYh5D0P969uAk=
   │     │  │  │  │  │     ├─ nF+BaiXLckSg8seZe4qco8ARNJw=
   │     │  │  │  │  │     ├─ ng_A_MLbhJqJFmfxwBsDBZlQbEE=
   │     │  │  │  │  │     ├─ NU62LfwFR9w4Rc5EueFI0fn7lSQ=
   │     │  │  │  │  │     ├─ nYwcFWJHtczUdXJKOYFtPeJPOzA=
   │     │  │  │  │  │     ├─ N_LcozePiJIdTwzTqaKs+iQZn+A=
   │     │  │  │  │  │     ├─ OY7ztqJWZqF6JmPKr5UAZ46JfAw=
   │     │  │  │  │  │     ├─ pKbh_KznGk7+qmggn57sn5UX7u8=
   │     │  │  │  │  │     ├─ PYC2XA0ibl17ww7HlYIYH8g8RqM=
   │     │  │  │  │  │     ├─ q3hT0woG16h3Rd979JtoDj8bZag=
   │     │  │  │  │  │     ├─ QdAxsrs+QZTu+mKG4uUrH73aC2w=
   │     │  │  │  │  │     ├─ r4HSfJYcKfi9357as+p5X8AHY7A=
   │     │  │  │  │  │     ├─ rbcDvsEAiHCrVkk1gOwDF91nJKk=
   │     │  │  │  │  │     ├─ S8YZVnhJndW6Y7C28PkvWMuUGFU=
   │     │  │  │  │  │     ├─ sJ1Z+LilgHVRMvBufR7gXoqO5OU=
   │     │  │  │  │  │     ├─ spxzw73MyHCkvBxOzjVJA25ZNik=
   │     │  │  │  │  │     ├─ TC0rz0aAWqGJLyYnCfY8tgLrh+4=
   │     │  │  │  │  │     ├─ tIjcEdaqUznI1031TiWZQ_MxQ7A=
   │     │  │  │  │  │     ├─ TqOMLNi3Ynmhlmj5ikOHMCRsw7I=
   │     │  │  │  │  │     ├─ UhUFPhAG93jQJFle1yk5vpGnmYk=
   │     │  │  │  │  │     ├─ UkHlvJh0BoT_kLMoHALWrqFWsCA=
   │     │  │  │  │  │     ├─ UNR93Ulc79vfS8wWXhmOvbiizVw=
   │     │  │  │  │  │     ├─ UVOYfyTFV7AStM3_TLiky4sG9YA=
   │     │  │  │  │  │     ├─ V4GsDEaebXKR0eEoIG23fN2gmA4=
   │     │  │  │  │  │     ├─ vEsScS5yC4zQChA24jcBXWMdjAc=
   │     │  │  │  │  │     ├─ vNU9LAvk0O8aOuiDW9EKzR+dkYE=
   │     │  │  │  │  │     ├─ VQ6hjtwYTNMrrti7GRSbadEiIQ4=
   │     │  │  │  │  │     ├─ vR6GWTNy6eMy00H36BLDCDCHV1s=
   │     │  │  │  │  │     ├─ vUvFM6A5sl3HZzgZCKSZ8TBwMwM=
   │     │  │  │  │  │     ├─ WnJlYMNtUg8wSrnn_dNwtpu44Cs=
   │     │  │  │  │  │     ├─ wNnocPlgPhTp1ycUn2JSIjX8XZQ=
   │     │  │  │  │  │     ├─ wofoi442XvPVGtnqtsePRLy0hWc=
   │     │  │  │  │  │     ├─ WVqGecBCyDfLhE60RDdD4ye82ZM=
   │     │  │  │  │  │     ├─ wWH41jLKME_1YuRByqS0zIu91W8=
   │     │  │  │  │  │     ├─ Wx0csA9dpcHAF3DfUIXfQksRRFM=
   │     │  │  │  │  │     ├─ XBYwoK4oXucxeq6_RNQpAkChLU0=
   │     │  │  │  │  │     ├─ XR0rCSzCv18Rag4DLVvTWFnRqQ0=
   │     │  │  │  │  │     ├─ XVpPLWilGw+QB2HALk7TugZ0Ze8=
   │     │  │  │  │  │     ├─ y7wPoR7sQXMtMAr_VE3d_a6KI98=
   │     │  │  │  │  │     ├─ YDf6g0sFlAOwsCoAZx9XyKwQ1bw=
   │     │  │  │  │  │     ├─ Yqf9u1fogB6+GH5WGFfSkp6NKro=
   │     │  │  │  │  │     ├─ YxhCrFP6CSBd8sEoFV1F5frlIK0=
   │     │  │  │  │  │     ├─ z4_6+_BeIqgDxC4OaRxwYcbk2qY=
   │     │  │  │  │  │     ├─ zckUI2Vi6zkc0VEZS0uoBqV8AtQ=
   │     │  │  │  │  │     ├─ zEqJ7T2paAQOp2J5YzyS7Wx+cRc=
   │     │  │  │  │  │     └─ _BEHK9bJkIkQnIGAo24JN2VhCM8=
   │     │  │  │  │  ├─ mergeDebugAssets
   │     │  │  │  │  │  └─ merger.xml
   │     │  │  │  │  ├─ mergeDebugJniLibFolders
   │     │  │  │  │  │  └─ merger.xml
   │     │  │  │  │  ├─ mergeDebugShaders
   │     │  │  │  │  │  └─ merger.xml
   │     │  │  │  │  └─ packageDebug
   │     │  │  │  │     └─ tmp
   │     │  │  │  │        └─ debug
   │     │  │  │  │           ├─ dex-renamer-state.txt
   │     │  │  │  │           └─ zip-cache
   │     │  │  │  │              ├─ androidResources
   │     │  │  │  │              └─ javaResources0
   │     │  │  │  ├─ javac
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ compileDebugJavaWithJavac
   │     │  │  │  │        └─ classes
   │     │  │  │  │           └─ io
   │     │  │  │  │              └─ flutter
   │     │  │  │  │                 └─ plugins
   │     │  │  │  │                    └─ GeneratedPluginRegistrant.class
   │     │  │  │  ├─ java_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugJavaRes
   │     │  │  │  │        └─ out
   │     │  │  │  │           ├─ com
   │     │  │  │  │           │  └─ example
   │     │  │  │  │           │     └─ sdgp
   │     │  │  │  │           └─ META-INF
   │     │  │  │  │              └─ app_debug.kotlin_module
   │     │  │  │  ├─ l8_art_profile
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ l8DexDesugarLibDebug
   │     │  │  │  ├─ linked_resources_binary_format
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugResources
   │     │  │  │  │        ├─ linked-resources-binary-format-debug.ap_
   │     │  │  │  │        └─ output-metadata.json
   │     │  │  │  ├─ local_only_symbol_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ parseDebugLocalResources
   │     │  │  │  │        └─ R-def.txt
   │     │  │  │  ├─ manifest_merge_blame_file
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugMainManifest
   │     │  │  │  │        └─ manifest-merger-blame-debug-report.txt
   │     │  │  │  ├─ merged_java_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugJavaResource
   │     │  │  │  │        └─ base.jar
   │     │  │  │  ├─ merged_jni_libs
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugJniLibFolders
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ merged_manifest
   │     │  │  │  │  └─ debug
   │     │  │  │  │     ├─ outputDebugAppLinkSettings
   │     │  │  │  │     │  └─ AndroidManifest.xml
   │     │  │  │  │     └─ processDebugMainManifest
   │     │  │  │  │        └─ AndroidManifest.xml
   │     │  │  │  ├─ merged_manifests
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        ├─ AndroidManifest.xml
   │     │  │  │  │        └─ output-metadata.json
   │     │  │  │  ├─ merged_native_libs
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugNativeLibs
   │     │  │  │  │        └─ out
   │     │  │  │  │           └─ lib
   │     │  │  │  │              ├─ arm64-v8a
   │     │  │  │  │              │  └─ libdatastore_shared_counter.so
   │     │  │  │  │              ├─ armeabi-v7a
   │     │  │  │  │              │  └─ libdatastore_shared_counter.so
   │     │  │  │  │              ├─ x86
   │     │  │  │  │              │  └─ libdatastore_shared_counter.so
   │     │  │  │  │              └─ x86_64
   │     │  │  │  │                 ├─ libdatastore_shared_counter.so
   │     │  │  │  │                 └─ libflutter.so
   │     │  │  │  ├─ merged_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugResources
   │     │  │  │  │        ├─ drawable-v21_launch_background.xml.flat
   │     │  │  │  │        ├─ mipmap-hdpi_ic_launcher.png.flat
   │     │  │  │  │        ├─ mipmap-mdpi_ic_launcher.png.flat
   │     │  │  │  │        ├─ mipmap-xhdpi_ic_launcher.png.flat
   │     │  │  │  │        ├─ mipmap-xxhdpi_ic_launcher.png.flat
   │     │  │  │  │        ├─ mipmap-xxxhdpi_ic_launcher.png.flat
   │     │  │  │  │        ├─ values-af_values-af.arsc.flat
   │     │  │  │  │        ├─ values-am_values-am.arsc.flat
   │     │  │  │  │        ├─ values-ar_values-ar.arsc.flat
   │     │  │  │  │        ├─ values-as_values-as.arsc.flat
   │     │  │  │  │        ├─ values-az_values-az.arsc.flat
   │     │  │  │  │        ├─ values-b+sr+Latn_values-b+sr+Latn.arsc.flat
   │     │  │  │  │        ├─ values-be_values-be.arsc.flat
   │     │  │  │  │        ├─ values-bg_values-bg.arsc.flat
   │     │  │  │  │        ├─ values-bn_values-bn.arsc.flat
   │     │  │  │  │        ├─ values-bs_values-bs.arsc.flat
   │     │  │  │  │        ├─ values-ca_values-ca.arsc.flat
   │     │  │  │  │        ├─ values-cs_values-cs.arsc.flat
   │     │  │  │  │        ├─ values-da_values-da.arsc.flat
   │     │  │  │  │        ├─ values-de_values-de.arsc.flat
   │     │  │  │  │        ├─ values-el_values-el.arsc.flat
   │     │  │  │  │        ├─ values-en-rAU_values-en-rAU.arsc.flat
   │     │  │  │  │        ├─ values-en-rCA_values-en-rCA.arsc.flat
   │     │  │  │  │        ├─ values-en-rGB_values-en-rGB.arsc.flat
   │     │  │  │  │        ├─ values-en-rIN_values-en-rIN.arsc.flat
   │     │  │  │  │        ├─ values-en-rXC_values-en-rXC.arsc.flat
   │     │  │  │  │        ├─ values-es-rUS_values-es-rUS.arsc.flat
   │     │  │  │  │        ├─ values-es_values-es.arsc.flat
   │     │  │  │  │        ├─ values-et_values-et.arsc.flat
   │     │  │  │  │        ├─ values-eu_values-eu.arsc.flat
   │     │  │  │  │        ├─ values-fa_values-fa.arsc.flat
   │     │  │  │  │        ├─ values-fi_values-fi.arsc.flat
   │     │  │  │  │        ├─ values-fr-rCA_values-fr-rCA.arsc.flat
   │     │  │  │  │        ├─ values-fr_values-fr.arsc.flat
   │     │  │  │  │        ├─ values-gl_values-gl.arsc.flat
   │     │  │  │  │        ├─ values-gu_values-gu.arsc.flat
   │     │  │  │  │        ├─ values-hi_values-hi.arsc.flat
   │     │  │  │  │        ├─ values-hr_values-hr.arsc.flat
   │     │  │  │  │        ├─ values-hu_values-hu.arsc.flat
   │     │  │  │  │        ├─ values-hy_values-hy.arsc.flat
   │     │  │  │  │        ├─ values-in_values-in.arsc.flat
   │     │  │  │  │        ├─ values-is_values-is.arsc.flat
   │     │  │  │  │        ├─ values-it_values-it.arsc.flat
   │     │  │  │  │        ├─ values-iw_values-iw.arsc.flat
   │     │  │  │  │        ├─ values-ja_values-ja.arsc.flat
   │     │  │  │  │        ├─ values-ka_values-ka.arsc.flat
   │     │  │  │  │        ├─ values-kk_values-kk.arsc.flat
   │     │  │  │  │        ├─ values-km_values-km.arsc.flat
   │     │  │  │  │        ├─ values-kn_values-kn.arsc.flat
   │     │  │  │  │        ├─ values-ko_values-ko.arsc.flat
   │     │  │  │  │        ├─ values-ky_values-ky.arsc.flat
   │     │  │  │  │        ├─ values-lo_values-lo.arsc.flat
   │     │  │  │  │        ├─ values-lt_values-lt.arsc.flat
   │     │  │  │  │        ├─ values-lv_values-lv.arsc.flat
   │     │  │  │  │        ├─ values-mk_values-mk.arsc.flat
   │     │  │  │  │        ├─ values-ml_values-ml.arsc.flat
   │     │  │  │  │        ├─ values-mn_values-mn.arsc.flat
   │     │  │  │  │        ├─ values-mr_values-mr.arsc.flat
   │     │  │  │  │        ├─ values-ms_values-ms.arsc.flat
   │     │  │  │  │        ├─ values-my_values-my.arsc.flat
   │     │  │  │  │        ├─ values-nb_values-nb.arsc.flat
   │     │  │  │  │        ├─ values-ne_values-ne.arsc.flat
   │     │  │  │  │        ├─ values-night-v8_values-night-v8.arsc.flat
   │     │  │  │  │        ├─ values-nl_values-nl.arsc.flat
   │     │  │  │  │        ├─ values-or_values-or.arsc.flat
   │     │  │  │  │        ├─ values-pa_values-pa.arsc.flat
   │     │  │  │  │        ├─ values-pl_values-pl.arsc.flat
   │     │  │  │  │        ├─ values-pt-rBR_values-pt-rBR.arsc.flat
   │     │  │  │  │        ├─ values-pt-rPT_values-pt-rPT.arsc.flat
   │     │  │  │  │        ├─ values-pt_values-pt.arsc.flat
   │     │  │  │  │        ├─ values-ro_values-ro.arsc.flat
   │     │  │  │  │        ├─ values-ru_values-ru.arsc.flat
   │     │  │  │  │        ├─ values-si_values-si.arsc.flat
   │     │  │  │  │        ├─ values-sk_values-sk.arsc.flat
   │     │  │  │  │        ├─ values-sl_values-sl.arsc.flat
   │     │  │  │  │        ├─ values-sq_values-sq.arsc.flat
   │     │  │  │  │        ├─ values-sr_values-sr.arsc.flat
   │     │  │  │  │        ├─ values-sv_values-sv.arsc.flat
   │     │  │  │  │        ├─ values-sw_values-sw.arsc.flat
   │     │  │  │  │        ├─ values-ta_values-ta.arsc.flat
   │     │  │  │  │        ├─ values-te_values-te.arsc.flat
   │     │  │  │  │        ├─ values-th_values-th.arsc.flat
   │     │  │  │  │        ├─ values-tl_values-tl.arsc.flat
   │     │  │  │  │        ├─ values-tr_values-tr.arsc.flat
   │     │  │  │  │        ├─ values-uk_values-uk.arsc.flat
   │     │  │  │  │        ├─ values-ur_values-ur.arsc.flat
   │     │  │  │  │        ├─ values-uz_values-uz.arsc.flat
   │     │  │  │  │        ├─ values-v21_values-v21.arsc.flat
   │     │  │  │  │        ├─ values-v24_values-v24.arsc.flat
   │     │  │  │  │        ├─ values-vi_values-vi.arsc.flat
   │     │  │  │  │        ├─ values-watch-v20_values-watch-v20.arsc.flat
   │     │  │  │  │        ├─ values-zh-rCN_values-zh-rCN.arsc.flat
   │     │  │  │  │        ├─ values-zh-rHK_values-zh-rHK.arsc.flat
   │     │  │  │  │        ├─ values-zh-rTW_values-zh-rTW.arsc.flat
   │     │  │  │  │        ├─ values-zu_values-zu.arsc.flat
   │     │  │  │  │        └─ values_values.arsc.flat
   │     │  │  │  ├─ merged_res_blame_folder
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugResources
   │     │  │  │  │        └─ out
   │     │  │  │  │           ├─ multi-v2
   │     │  │  │  │           │  ├─ mergeDebugResources.json
   │     │  │  │  │           │  ├─ values-af.json
   │     │  │  │  │           │  ├─ values-am.json
   │     │  │  │  │           │  ├─ values-ar.json
   │     │  │  │  │           │  ├─ values-as.json
   │     │  │  │  │           │  ├─ values-az.json
   │     │  │  │  │           │  ├─ values-b+sr+Latn.json
   │     │  │  │  │           │  ├─ values-be.json
   │     │  │  │  │           │  ├─ values-bg.json
   │     │  │  │  │           │  ├─ values-bn.json
   │     │  │  │  │           │  ├─ values-bs.json
   │     │  │  │  │           │  ├─ values-ca.json
   │     │  │  │  │           │  ├─ values-cs.json
   │     │  │  │  │           │  ├─ values-da.json
   │     │  │  │  │           │  ├─ values-de.json
   │     │  │  │  │           │  ├─ values-el.json
   │     │  │  │  │           │  ├─ values-en-rAU.json
   │     │  │  │  │           │  ├─ values-en-rCA.json
   │     │  │  │  │           │  ├─ values-en-rGB.json
   │     │  │  │  │           │  ├─ values-en-rIN.json
   │     │  │  │  │           │  ├─ values-en-rXC.json
   │     │  │  │  │           │  ├─ values-es-rUS.json
   │     │  │  │  │           │  ├─ values-es.json
   │     │  │  │  │           │  ├─ values-et.json
   │     │  │  │  │           │  ├─ values-eu.json
   │     │  │  │  │           │  ├─ values-fa.json
   │     │  │  │  │           │  ├─ values-fi.json
   │     │  │  │  │           │  ├─ values-fr-rCA.json
   │     │  │  │  │           │  ├─ values-fr.json
   │     │  │  │  │           │  ├─ values-gl.json
   │     │  │  │  │           │  ├─ values-gu.json
   │     │  │  │  │           │  ├─ values-hi.json
   │     │  │  │  │           │  ├─ values-hr.json
   │     │  │  │  │           │  ├─ values-hu.json
   │     │  │  │  │           │  ├─ values-hy.json
   │     │  │  │  │           │  ├─ values-in.json
   │     │  │  │  │           │  ├─ values-is.json
   │     │  │  │  │           │  ├─ values-it.json
   │     │  │  │  │           │  ├─ values-iw.json
   │     │  │  │  │           │  ├─ values-ja.json
   │     │  │  │  │           │  ├─ values-ka.json
   │     │  │  │  │           │  ├─ values-kk.json
   │     │  │  │  │           │  ├─ values-km.json
   │     │  │  │  │           │  ├─ values-kn.json
   │     │  │  │  │           │  ├─ values-ko.json
   │     │  │  │  │           │  ├─ values-ky.json
   │     │  │  │  │           │  ├─ values-lo.json
   │     │  │  │  │           │  ├─ values-lt.json
   │     │  │  │  │           │  ├─ values-lv.json
   │     │  │  │  │           │  ├─ values-mk.json
   │     │  │  │  │           │  ├─ values-ml.json
   │     │  │  │  │           │  ├─ values-mn.json
   │     │  │  │  │           │  ├─ values-mr.json
   │     │  │  │  │           │  ├─ values-ms.json
   │     │  │  │  │           │  ├─ values-my.json
   │     │  │  │  │           │  ├─ values-nb.json
   │     │  │  │  │           │  ├─ values-ne.json
   │     │  │  │  │           │  ├─ values-night-v8.json
   │     │  │  │  │           │  ├─ values-nl.json
   │     │  │  │  │           │  ├─ values-or.json
   │     │  │  │  │           │  ├─ values-pa.json
   │     │  │  │  │           │  ├─ values-pl.json
   │     │  │  │  │           │  ├─ values-pt-rBR.json
   │     │  │  │  │           │  ├─ values-pt-rPT.json
   │     │  │  │  │           │  ├─ values-pt.json
   │     │  │  │  │           │  ├─ values-ro.json
   │     │  │  │  │           │  ├─ values-ru.json
   │     │  │  │  │           │  ├─ values-si.json
   │     │  │  │  │           │  ├─ values-sk.json
   │     │  │  │  │           │  ├─ values-sl.json
   │     │  │  │  │           │  ├─ values-sq.json
   │     │  │  │  │           │  ├─ values-sr.json
   │     │  │  │  │           │  ├─ values-sv.json
   │     │  │  │  │           │  ├─ values-sw.json
   │     │  │  │  │           │  ├─ values-ta.json
   │     │  │  │  │           │  ├─ values-te.json
   │     │  │  │  │           │  ├─ values-th.json
   │     │  │  │  │           │  ├─ values-tl.json
   │     │  │  │  │           │  ├─ values-tr.json
   │     │  │  │  │           │  ├─ values-uk.json
   │     │  │  │  │           │  ├─ values-ur.json
   │     │  │  │  │           │  ├─ values-uz.json
   │     │  │  │  │           │  ├─ values-v21.json
   │     │  │  │  │           │  ├─ values-v24.json
   │     │  │  │  │           │  ├─ values-vi.json
   │     │  │  │  │           │  ├─ values-watch-v20.json
   │     │  │  │  │           │  ├─ values-zh-rCN.json
   │     │  │  │  │           │  ├─ values-zh-rHK.json
   │     │  │  │  │           │  ├─ values-zh-rTW.json
   │     │  │  │  │           │  ├─ values-zu.json
   │     │  │  │  │           │  └─ values.json
   │     │  │  │  │           └─ single
   │     │  │  │  │              └─ mergeDebugResources.json
   │     │  │  │  ├─ merged_shaders
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugShaders
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ merged_test_only_native_libs
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugNativeLibs
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ mixed_scope_dex_archive
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ dexBuilderDebug
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ navigation_json
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDeepLinksDebug
   │     │  │  │  │        └─ navigation.json
   │     │  │  │  ├─ nested_resources_validation_report
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugResources
   │     │  │  │  │        └─ nestedResourcesValidationReport.txt
   │     │  │  │  ├─ packaged_manifests
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifestForPackage
   │     │  │  │  │        ├─ AndroidManifest.xml
   │     │  │  │  │        └─ output-metadata.json
   │     │  │  │  ├─ packaged_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  │        ├─ drawable-v21
   │     │  │  │  │        │  └─ launch_background.xml
   │     │  │  │  │        ├─ mipmap-hdpi-v4
   │     │  │  │  │        │  └─ ic_launcher.png
   │     │  │  │  │        ├─ mipmap-mdpi-v4
   │     │  │  │  │        │  └─ ic_launcher.png
   │     │  │  │  │        ├─ mipmap-xhdpi-v4
   │     │  │  │  │        │  └─ ic_launcher.png
   │     │  │  │  │        ├─ mipmap-xxhdpi-v4
   │     │  │  │  │        │  └─ ic_launcher.png
   │     │  │  │  │        ├─ mipmap-xxxhdpi-v4
   │     │  │  │  │        │  └─ ic_launcher.png
   │     │  │  │  │        ├─ values
   │     │  │  │  │        │  └─ values.xml
   │     │  │  │  │        └─ values-night-v8
   │     │  │  │  │           └─ values-night-v8.xml
   │     │  │  │  ├─ project_dex_archive
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ dexBuilderDebug
   │     │  │  │  │        └─ out
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_0.jar
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_1.jar
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_10.jar
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_11.jar
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_12.jar
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_13.jar
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_14.jar
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_15.jar
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_2.jar
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_3.jar
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_4.jar
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_5.jar
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_6.jar
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_7.jar
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_8.jar
   │     │  │  │  │           ├─ 3686737419afe4d2793eced94644158bd24cf1078bf545c1626b9d959994d661_9.jar
   │     │  │  │  │           ├─ com
   │     │  │  │  │           │  └─ example
   │     │  │  │  │           │     └─ sdgp
   │     │  │  │  │           │        └─ MainActivity.dex
   │     │  │  │  │           └─ io
   │     │  │  │  │              └─ flutter
   │     │  │  │  │                 └─ plugins
   │     │  │  │  │                    └─ GeneratedPluginRegistrant.dex
   │     │  │  │  ├─ runtime_symbol_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugResources
   │     │  │  │  │        └─ R.txt
   │     │  │  │  ├─ signing_config_versions
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ writeDebugSigningConfigVersions
   │     │  │  │  │        └─ signing-config-versions.json
   │     │  │  │  ├─ source_set_path_map
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mapDebugSourceSetPaths
   │     │  │  │  │        └─ file-map.txt
   │     │  │  │  ├─ stable_resource_ids_file
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugResources
   │     │  │  │  │        └─ stableIds.txt
   │     │  │  │  ├─ stripped_native_libs
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ stripDebugDebugSymbols
   │     │  │  │  │        └─ out
   │     │  │  │  │           └─ lib
   │     │  │  │  │              ├─ arm64-v8a
   │     │  │  │  │              │  └─ libdatastore_shared_counter.so
   │     │  │  │  │              ├─ armeabi-v7a
   │     │  │  │  │              │  └─ libdatastore_shared_counter.so
   │     │  │  │  │              ├─ x86
   │     │  │  │  │              │  └─ libdatastore_shared_counter.so
   │     │  │  │  │              └─ x86_64
   │     │  │  │  │                 ├─ libdatastore_shared_counter.so
   │     │  │  │  │                 └─ libflutter.so
   │     │  │  │  ├─ sub_project_dex_archive
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ dexBuilderDebug
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ symbol_list_with_package_name
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugResources
   │     │  │  │  │        └─ package-aware-r.txt
   │     │  │  │  └─ validate_signing_config
   │     │  │  │     └─ debug
   │     │  │  │        └─ validateSigningDebug
   │     │  │  ├─ kotlin
   │     │  │  │  └─ compileDebugKotlin
   │     │  │  │     ├─ cacheable
   │     │  │  │     │  ├─ caches-jvm
   │     │  │  │     │  │  ├─ inputs
   │     │  │  │     │  │  │  ├─ source-to-output.tab
   │     │  │  │     │  │  │  ├─ source-to-output.tab.keystream
   │     │  │  │     │  │  │  ├─ source-to-output.tab.keystream.len
   │     │  │  │     │  │  │  ├─ source-to-output.tab.len
   │     │  │  │     │  │  │  ├─ source-to-output.tab.values.at
   │     │  │  │     │  │  │  ├─ source-to-output.tab_i
   │     │  │  │     │  │  │  └─ source-to-output.tab_i.len
   │     │  │  │     │  │  ├─ jvm
   │     │  │  │     │  │  │  └─ kotlin
   │     │  │  │     │  │  │     ├─ class-attributes.tab
   │     │  │  │     │  │  │     ├─ class-attributes.tab.keystream
   │     │  │  │     │  │  │     ├─ class-attributes.tab.keystream.len
   │     │  │  │     │  │  │     ├─ class-attributes.tab.len
   │     │  │  │     │  │  │     ├─ class-attributes.tab.values.at
   │     │  │  │     │  │  │     ├─ class-attributes.tab_i
   │     │  │  │     │  │  │     ├─ class-attributes.tab_i.len
   │     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab
   │     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab.keystream
   │     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab.keystream.len
   │     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab.len
   │     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab.values.at
   │     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab_i
   │     │  │  │     │  │  │     ├─ class-fq-name-to-source.tab_i.len
   │     │  │  │     │  │  │     ├─ internal-name-to-source.tab
   │     │  │  │     │  │  │     ├─ internal-name-to-source.tab.keystream
   │     │  │  │     │  │  │     ├─ internal-name-to-source.tab.keystream.len
   │     │  │  │     │  │  │     ├─ internal-name-to-source.tab.len
   │     │  │  │     │  │  │     ├─ internal-name-to-source.tab.values.at
   │     │  │  │     │  │  │     ├─ internal-name-to-source.tab_i
   │     │  │  │     │  │  │     ├─ internal-name-to-source.tab_i.len
   │     │  │  │     │  │  │     ├─ proto.tab
   │     │  │  │     │  │  │     ├─ proto.tab.keystream
   │     │  │  │     │  │  │     ├─ proto.tab.keystream.len
   │     │  │  │     │  │  │     ├─ proto.tab.len
   │     │  │  │     │  │  │     ├─ proto.tab.values.at
   │     │  │  │     │  │  │     ├─ proto.tab_i
   │     │  │  │     │  │  │     ├─ proto.tab_i.len
   │     │  │  │     │  │  │     ├─ source-to-classes.tab
   │     │  │  │     │  │  │     ├─ source-to-classes.tab.keystream
   │     │  │  │     │  │  │     ├─ source-to-classes.tab.keystream.len
   │     │  │  │     │  │  │     ├─ source-to-classes.tab.len
   │     │  │  │     │  │  │     ├─ source-to-classes.tab.values.at
   │     │  │  │     │  │  │     ├─ source-to-classes.tab_i
   │     │  │  │     │  │  │     ├─ source-to-classes.tab_i.len
   │     │  │  │     │  │  │     ├─ subtypes.tab
   │     │  │  │     │  │  │     ├─ subtypes.tab.keystream
   │     │  │  │     │  │  │     ├─ subtypes.tab.keystream.len
   │     │  │  │     │  │  │     ├─ subtypes.tab.len
   │     │  │  │     │  │  │     ├─ subtypes.tab.values.at
   │     │  │  │     │  │  │     ├─ subtypes.tab_i
   │     │  │  │     │  │  │     ├─ subtypes.tab_i.len
   │     │  │  │     │  │  │     ├─ supertypes.tab
   │     │  │  │     │  │  │     ├─ supertypes.tab.keystream
   │     │  │  │     │  │  │     ├─ supertypes.tab.keystream.len
   │     │  │  │     │  │  │     ├─ supertypes.tab.len
   │     │  │  │     │  │  │     ├─ supertypes.tab.values.at
   │     │  │  │     │  │  │     ├─ supertypes.tab_i
   │     │  │  │     │  │  │     └─ supertypes.tab_i.len
   │     │  │  │     │  │  └─ lookups
   │     │  │  │     │  │     ├─ counters.tab
   │     │  │  │     │  │     ├─ file-to-id.tab
   │     │  │  │     │  │     ├─ file-to-id.tab.keystream
   │     │  │  │     │  │     ├─ file-to-id.tab.keystream.len
   │     │  │  │     │  │     ├─ file-to-id.tab.len
   │     │  │  │     │  │     ├─ file-to-id.tab.values.at
   │     │  │  │     │  │     ├─ file-to-id.tab_i
   │     │  │  │     │  │     ├─ file-to-id.tab_i.len
   │     │  │  │     │  │     ├─ id-to-file.tab
   │     │  │  │     │  │     ├─ id-to-file.tab.keystream
   │     │  │  │     │  │     ├─ id-to-file.tab.keystream.len
   │     │  │  │     │  │     ├─ id-to-file.tab.len
   │     │  │  │     │  │     ├─ id-to-file.tab.values.at
   │     │  │  │     │  │     ├─ id-to-file.tab_i.len
   │     │  │  │     │  │     ├─ lookups.tab
   │     │  │  │     │  │     ├─ lookups.tab.keystream
   │     │  │  │     │  │     ├─ lookups.tab.keystream.len
   │     │  │  │     │  │     ├─ lookups.tab.len
   │     │  │  │     │  │     ├─ lookups.tab.values.at
   │     │  │  │     │  │     ├─ lookups.tab_i
   │     │  │  │     │  │     └─ lookups.tab_i.len
   │     │  │  │     │  └─ last-build.bin
   │     │  │  │     ├─ classpath-snapshot
   │     │  │  │     │  └─ shrunk-classpath-snapshot.bin
   │     │  │  │     └─ local-state
   │     │  │  ├─ outputs
   │     │  │  │  ├─ apk
   │     │  │  │  │  └─ debug
   │     │  │  │  │     ├─ app-debug.apk
   │     │  │  │  │     └─ output-metadata.json
   │     │  │  │  ├─ flutter-apk
   │     │  │  │  │  ├─ app-debug.apk
   │     │  │  │  │  └─ app-debug.apk.sha1
   │     │  │  │  └─ logs
   │     │  │  │     └─ manifest-merger-debug-report.txt
   │     │  │  └─ tmp
   │     │  │     ├─ compileDebugJavaWithJavac
   │     │  │     │  └─ previous-compilation-data.bin
   │     │  │     ├─ kotlin-classes
   │     │  │     │  └─ debug
   │     │  │     │     ├─ com
   │     │  │     │     │  └─ example
   │     │  │     │     │     └─ sdgp
   │     │  │     │     │        └─ MainActivity.class
   │     │  │     │     └─ META-INF
   │     │  │     │        └─ app_debug.kotlin_module
   │     │  │     └─ packJniLibsflutterBuildDebug
   │     │  │        └─ MANIFEST.MF
   │     │  ├─ b91b994338c11c54cf5c76fd8ba5acce.cache.dill.track.dill
   │     │  ├─ cloud_firestore
   │     │  │  ├─ .transforms
   │     │  │  │  ├─ 266cbc0099cbe5062f5482bf4c9c5398
   │     │  │  │  │  ├─ results.bin
   │     │  │  │  │  └─ transformed
   │     │  │  │  │     └─ bundleLibRuntimeToDirDebug
   │     │  │  │  │        ├─ bundleLibRuntimeToDirDebug_dex
   │     │  │  │  │        │  └─ io
   │     │  │  │  │        │     └─ flutter
   │     │  │  │  │        │        └─ plugins
   │     │  │  │  │        │           └─ firebase
   │     │  │  │  │        │              └─ firestore
   │     │  │  │  │        │                 ├─ BuildConfig.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseFirestoreException$1.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseFirestoreException.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseFirestoreExtension.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseFirestoreMessageCodec$1.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseFirestoreMessageCodec.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseFirestorePlugin$1.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseFirestorePlugin.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseFirestoreRegistrar.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseFirestoreTransactionResult.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$AggregateQuery$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$AggregateQuery.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$AggregateQueryResponse$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$AggregateQueryResponse.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$AggregateSource.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$AggregateType.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$DocumentChangeType.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$DocumentReferenceRequest$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$DocumentReferenceRequest.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$1.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$10.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$11.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$12.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$13.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$14.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$15.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$16.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$17.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$18.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$19.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$2.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$20.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$21.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$22.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$23.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$3.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$4.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$5.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$6.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$7.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$8.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$9.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApiCodec.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirestorePigeonFirebaseApp$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FirestorePigeonFirebaseApp.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$FlutterError.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$ListenSource.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PersistenceCacheIndexManagerRequest.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentChange$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentChange.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentOption$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentOption.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentSnapshot$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentSnapshot.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonFirebaseSettings$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonFirebaseSettings.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonGetOptions$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonGetOptions.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonQueryParameters$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonQueryParameters.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonQuerySnapshot$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonQuerySnapshot.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonSnapshotMetadata$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonSnapshotMetadata.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionCommand$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionCommand.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionResult.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionType.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$Result.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$ServerTimestampBehavior.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore$Source.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseFirestore.dex
   │     │  │  │  │        │                 ├─ streamhandler
   │     │  │  │  │        │                 │  ├─ DocumentSnapshotsStreamHandler.dex
   │     │  │  │  │        │                 │  ├─ LoadBundleStreamHandler.dex
   │     │  │  │  │        │                 │  ├─ OnTransactionResultListener.dex
   │     │  │  │  │        │                 │  ├─ QuerySnapshotsStreamHandler.dex
   │     │  │  │  │        │                 │  ├─ SnapshotsInSyncStreamHandler.dex
   │     │  │  │  │        │                 │  ├─ TransactionStreamHandler$1.dex
   │     │  │  │  │        │                 │  ├─ TransactionStreamHandler$OnTransactionStartedListener.dex
   │     │  │  │  │        │                 │  └─ TransactionStreamHandler.dex
   │     │  │  │  │        │                 └─ utils
   │     │  │  │  │        │                    ├─ ExceptionConverter.dex
   │     │  │  │  │        │                    ├─ PigeonParser$1.dex
   │     │  │  │  │        │                    ├─ PigeonParser.dex
   │     │  │  │  │        │                    └─ ServerTimestampBehaviorConverter.dex
   │     │  │  │  │        ├─ bundleLibRuntimeToDirDebug_global-synthetics
   │     │  │  │  │        └─ desugar_graph.bin
   │     │  │  │  └─ 8ab4f9b8d574857d1a129655b4ced4b2
   │     │  │  │     ├─ results.bin
   │     │  │  │     └─ transformed
   │     │  │  │        └─ classes
   │     │  │  │           ├─ classes_dex
   │     │  │  │           │  └─ classes.dex
   │     │  │  │           └─ classes_global-synthetics
   │     │  │  ├─ generated
   │     │  │  │  ├─ ap_generated_sources
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ out
   │     │  │  │  ├─ res
   │     │  │  │  │  ├─ pngs
   │     │  │  │  │  │  └─ debug
   │     │  │  │  │  └─ resValues
   │     │  │  │  │     └─ debug
   │     │  │  │  └─ source
   │     │  │  │     └─ buildConfig
   │     │  │  │        └─ debug
   │     │  │  │           └─ io
   │     │  │  │              └─ flutter
   │     │  │  │                 └─ plugins
   │     │  │  │                    └─ firebase
   │     │  │  │                       └─ firestore
   │     │  │  │                          └─ BuildConfig.java
   │     │  │  ├─ intermediates
   │     │  │  │  ├─ aapt_friendly_merged_manifests
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        └─ aapt
   │     │  │  │  │           ├─ AndroidManifest.xml
   │     │  │  │  │           └─ output-metadata.json
   │     │  │  │  ├─ aar_libs_directory
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ syncDebugLibJars
   │     │  │  │  │        └─ libs
   │     │  │  │  ├─ aar_main_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ syncDebugLibJars
   │     │  │  │  │        └─ classes.jar
   │     │  │  │  ├─ aar_metadata
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ writeDebugAarMetadata
   │     │  │  │  │        └─ aar-metadata.properties
   │     │  │  │  ├─ annotations_typedef_file
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDebugAnnotations
   │     │  │  │  │        └─ typedefs.txt
   │     │  │  │  ├─ annotations_zip
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDebugAnnotations
   │     │  │  │  ├─ annotation_processor_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ javaPreCompileDebug
   │     │  │  │  │        └─ annotationProcessors.json
   │     │  │  │  ├─ assets
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugAssets
   │     │  │  │  ├─ compiled_local_resources
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ compileDebugLibraryResources
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ compile_library_classes_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ bundleLibCompileToJarDebug
   │     │  │  │  │        └─ classes.jar
   │     │  │  │  ├─ compile_r_class_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugRFile
   │     │  │  │  │        └─ R.jar
   │     │  │  │  ├─ compile_symbol_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugRFile
   │     │  │  │  │        └─ R.txt
   │     │  │  │  ├─ data_binding_layout_info_type_package
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ incremental
   │     │  │  │  │  ├─ debug
   │     │  │  │  │  │  └─ packageDebugResources
   │     │  │  │  │  │     ├─ compile-file-map.properties
   │     │  │  │  │  │     ├─ merged.dir
   │     │  │  │  │  │     ├─ merger.xml
   │     │  │  │  │  │     └─ stripped.dir
   │     │  │  │  │  ├─ debug-mergeJavaRes
   │     │  │  │  │  │  ├─ merge-state
   │     │  │  │  │  │  └─ zip-cache
   │     │  │  │  │  ├─ mergeDebugAssets
   │     │  │  │  │  │  └─ merger.xml
   │     │  │  │  │  ├─ mergeDebugJniLibFolders
   │     │  │  │  │  │  └─ merger.xml
   │     │  │  │  │  └─ mergeDebugShaders
   │     │  │  │  │     └─ merger.xml
   │     │  │  │  ├─ javac
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ compileDebugJavaWithJavac
   │     │  │  │  │        └─ classes
   │     │  │  │  │           └─ io
   │     │  │  │  │              └─ flutter
   │     │  │  │  │                 └─ plugins
   │     │  │  │  │                    └─ firebase
   │     │  │  │  │                       └─ firestore
   │     │  │  │  │                          ├─ BuildConfig.class
   │     │  │  │  │                          ├─ FlutterFirebaseFirestoreException$1.class
   │     │  │  │  │                          ├─ FlutterFirebaseFirestoreException.class
   │     │  │  │  │                          ├─ FlutterFirebaseFirestoreExtension.class
   │     │  │  │  │                          ├─ FlutterFirebaseFirestoreMessageCodec$1.class
   │     │  │  │  │                          ├─ FlutterFirebaseFirestoreMessageCodec.class
   │     │  │  │  │                          ├─ FlutterFirebaseFirestorePlugin$1.class
   │     │  │  │  │                          ├─ FlutterFirebaseFirestorePlugin.class
   │     │  │  │  │                          ├─ FlutterFirebaseFirestoreRegistrar.class
   │     │  │  │  │                          ├─ FlutterFirebaseFirestoreTransactionResult.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$AggregateQuery$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$AggregateQuery.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$AggregateQueryResponse$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$AggregateQueryResponse.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$AggregateSource.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$AggregateType.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$DocumentChangeType.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$DocumentReferenceRequest$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$DocumentReferenceRequest.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$1.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$10.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$11.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$12.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$13.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$14.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$15.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$16.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$17.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$18.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$19.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$2.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$20.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$21.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$22.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$23.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$3.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$4.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$5.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$6.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$7.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$8.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$9.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApiCodec.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirestorePigeonFirebaseApp$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FirestorePigeonFirebaseApp.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$FlutterError.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$ListenSource.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PersistenceCacheIndexManagerRequest.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentChange$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentChange.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentOption$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentOption.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentSnapshot$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentSnapshot.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonFirebaseSettings$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonFirebaseSettings.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonGetOptions$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonGetOptions.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonQueryParameters$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonQueryParameters.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonQuerySnapshot$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonQuerySnapshot.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonSnapshotMetadata$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonSnapshotMetadata.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionCommand$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionCommand.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionResult.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionType.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$Result.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$ServerTimestampBehavior.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore$Source.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseFirestore.class
   │     │  │  │  │                          ├─ streamhandler
   │     │  │  │  │                          │  ├─ DocumentSnapshotsStreamHandler.class
   │     │  │  │  │                          │  ├─ LoadBundleStreamHandler.class
   │     │  │  │  │                          │  ├─ OnTransactionResultListener.class
   │     │  │  │  │                          │  ├─ QuerySnapshotsStreamHandler.class
   │     │  │  │  │                          │  ├─ SnapshotsInSyncStreamHandler.class
   │     │  │  │  │                          │  ├─ TransactionStreamHandler$1.class
   │     │  │  │  │                          │  ├─ TransactionStreamHandler$OnTransactionStartedListener.class
   │     │  │  │  │                          │  └─ TransactionStreamHandler.class
   │     │  │  │  │                          └─ utils
   │     │  │  │  │                             ├─ ExceptionConverter.class
   │     │  │  │  │                             ├─ PigeonParser$1.class
   │     │  │  │  │                             ├─ PigeonParser.class
   │     │  │  │  │                             └─ ServerTimestampBehaviorConverter.class
   │     │  │  │  ├─ library_and_local_jars_jni
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ copyDebugJniLibsProjectAndLocalJars
   │     │  │  │  │        └─ jni
   │     │  │  │  ├─ library_jni
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ copyDebugJniLibsProjectOnly
   │     │  │  │  │        └─ jni
   │     │  │  │  ├─ local_only_symbol_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ parseDebugLocalResources
   │     │  │  │  │        └─ R-def.txt
   │     │  │  │  ├─ manifest_merge_blame_file
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        └─ manifest-merger-blame-debug-report.txt
   │     │  │  │  ├─ merged_java_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugJavaResource
   │     │  │  │  │        └─ feature-cloud_firestore.jar
   │     │  │  │  ├─ merged_jni_libs
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugJniLibFolders
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ merged_manifest
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        └─ AndroidManifest.xml
   │     │  │  │  ├─ merged_shaders
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugShaders
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ navigation_json
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDeepLinksDebug
   │     │  │  │  │        └─ navigation.json
   │     │  │  │  ├─ nested_resources_validation_report
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugResources
   │     │  │  │  │        └─ nestedResourcesValidationReport.txt
   │     │  │  │  ├─ packaged_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  ├─ public_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  ├─ runtime_library_classes_dir
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ bundleLibRuntimeToDirDebug
   │     │  │  │  │        └─ io
   │     │  │  │  │           └─ flutter
   │     │  │  │  │              └─ plugins
   │     │  │  │  │                 └─ firebase
   │     │  │  │  │                    └─ firestore
   │     │  │  │  │                       ├─ BuildConfig.class
   │     │  │  │  │                       ├─ FlutterFirebaseFirestoreException$1.class
   │     │  │  │  │                       ├─ FlutterFirebaseFirestoreException.class
   │     │  │  │  │                       ├─ FlutterFirebaseFirestoreExtension.class
   │     │  │  │  │                       ├─ FlutterFirebaseFirestoreMessageCodec$1.class
   │     │  │  │  │                       ├─ FlutterFirebaseFirestoreMessageCodec.class
   │     │  │  │  │                       ├─ FlutterFirebaseFirestorePlugin$1.class
   │     │  │  │  │                       ├─ FlutterFirebaseFirestorePlugin.class
   │     │  │  │  │                       ├─ FlutterFirebaseFirestoreRegistrar.class
   │     │  │  │  │                       ├─ FlutterFirebaseFirestoreTransactionResult.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$AggregateQuery$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$AggregateQuery.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$AggregateQueryResponse$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$AggregateQueryResponse.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$AggregateSource.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$AggregateType.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$DocumentChangeType.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$DocumentReferenceRequest$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$DocumentReferenceRequest.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$1.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$10.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$11.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$12.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$13.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$14.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$15.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$16.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$17.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$18.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$19.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$2.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$20.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$21.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$22.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$23.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$3.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$4.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$5.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$6.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$7.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$8.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi$9.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApi.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirebaseFirestoreHostApiCodec.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirestorePigeonFirebaseApp$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FirestorePigeonFirebaseApp.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$FlutterError.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$ListenSource.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PersistenceCacheIndexManagerRequest.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentChange$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentChange.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentOption$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentOption.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentSnapshot$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonDocumentSnapshot.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonFirebaseSettings$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonFirebaseSettings.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonGetOptions$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonGetOptions.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonQueryParameters$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonQueryParameters.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonQuerySnapshot$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonQuerySnapshot.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonSnapshotMetadata$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonSnapshotMetadata.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionCommand$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionCommand.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionResult.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$PigeonTransactionType.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$Result.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$ServerTimestampBehavior.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore$Source.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseFirestore.class
   │     │  │  │  │                       ├─ streamhandler
   │     │  │  │  │                       │  ├─ DocumentSnapshotsStreamHandler.class
   │     │  │  │  │                       │  ├─ LoadBundleStreamHandler.class
   │     │  │  │  │                       │  ├─ OnTransactionResultListener.class
   │     │  │  │  │                       │  ├─ QuerySnapshotsStreamHandler.class
   │     │  │  │  │                       │  ├─ SnapshotsInSyncStreamHandler.class
   │     │  │  │  │                       │  ├─ TransactionStreamHandler$1.class
   │     │  │  │  │                       │  ├─ TransactionStreamHandler$OnTransactionStartedListener.class
   │     │  │  │  │                       │  └─ TransactionStreamHandler.class
   │     │  │  │  │                       └─ utils
   │     │  │  │  │                          ├─ ExceptionConverter.class
   │     │  │  │  │                          ├─ PigeonParser$1.class
   │     │  │  │  │                          ├─ PigeonParser.class
   │     │  │  │  │                          └─ ServerTimestampBehaviorConverter.class
   │     │  │  │  ├─ runtime_library_classes_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ bundleLibRuntimeToJarDebug
   │     │  │  │  │        └─ classes.jar
   │     │  │  │  └─ symbol_list_with_package_name
   │     │  │  │     └─ debug
   │     │  │  │        └─ generateDebugRFile
   │     │  │  │           └─ package-aware-r.txt
   │     │  │  ├─ outputs
   │     │  │  │  ├─ aar
   │     │  │  │  │  └─ cloud_firestore-debug.aar
   │     │  │  │  └─ logs
   │     │  │  │     └─ manifest-merger-debug-report.txt
   │     │  │  └─ tmp
   │     │  │     └─ compileDebugJavaWithJavac
   │     │  │        └─ previous-compilation-data.bin
   │     │  ├─ firebase_auth
   │     │  │  ├─ .transforms
   │     │  │  │  ├─ 5272304d608d66adcebcebdc1e8a9421
   │     │  │  │  │  ├─ results.bin
   │     │  │  │  │  └─ transformed
   │     │  │  │  │     └─ bundleLibRuntimeToDirDebug
   │     │  │  │  │        ├─ bundleLibRuntimeToDirDebug_dex
   │     │  │  │  │        │  └─ io
   │     │  │  │  │        │     └─ flutter
   │     │  │  │  │        │        └─ plugins
   │     │  │  │  │        │           └─ firebase
   │     │  │  │  │        │              └─ auth
   │     │  │  │  │        │                 ├─ AuthStateChannelStreamHandler.dex
   │     │  │  │  │        │                 ├─ BuildConfig.dex
   │     │  │  │  │        │                 ├─ Constants.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseAuthPlugin.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseAuthPluginException.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseAuthRegistrar.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseAuthUser.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseMultiFactor.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseTotpMultiFactor.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseTotpSecret.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$ActionCodeInfoOperation.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$AuthPigeonFirebaseApp$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$AuthPigeonFirebaseApp.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$CanIgnoreReturnValue.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$1.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$10.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$11.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$12.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$13.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$14.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$15.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$16.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$17.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$18.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$19.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$2.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$20.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$21.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$22.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$23.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$3.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$4.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$5.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$6.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$7.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$8.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$9.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApiCodec.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$1.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$10.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$11.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$12.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$13.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$14.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$2.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$3.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$4.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$5.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$6.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$7.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$8.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$9.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApiCodec.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$FlutterError.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$GenerateInterfaces.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$GenerateInterfacesCodec.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApi$1.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApi.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApiCodec.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$1.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$2.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$3.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApiCodec.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi$1.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi$2.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$1.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$2.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$3.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$4.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$5.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApiCodec.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$NullableResult.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfo$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfo.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfoData$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfoData.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeSettings$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeSettings.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonAdditionalUserInfo$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonAdditionalUserInfo.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonAuthCredential$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonAuthCredential.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonFirebaseAuthSettings$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonFirebaseAuthSettings.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonIdTokenResult$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonIdTokenResult.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorInfo$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorInfo.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorSession$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorSession.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonPhoneMultiFactorAssertion$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonPhoneMultiFactorAssertion.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonSignInProvider$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonSignInProvider.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonTotpSecret$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonTotpSecret.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserCredential$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserCredential.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserDetails$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserDetails.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserInfo$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserInfo.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserProfile$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonUserProfile.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$Result.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth$VoidResult.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseAuth.dex
   │     │  │  │  │        │                 ├─ IdTokenChannelStreamHandler.dex
   │     │  │  │  │        │                 ├─ PhoneNumberVerificationStreamHandler$1.dex
   │     │  │  │  │        │                 ├─ PhoneNumberVerificationStreamHandler$OnCredentialsListener.dex
   │     │  │  │  │        │                 ├─ PhoneNumberVerificationStreamHandler.dex
   │     │  │  │  │        │                 └─ PigeonParser.dex
   │     │  │  │  │        ├─ bundleLibRuntimeToDirDebug_global-synthetics
   │     │  │  │  │        └─ desugar_graph.bin
   │     │  │  │  └─ f64949209a5508d74f4fc6f9ecc51c85
   │     │  │  │     ├─ results.bin
   │     │  │  │     └─ transformed
   │     │  │  │        └─ classes
   │     │  │  │           ├─ classes_dex
   │     │  │  │           │  └─ classes.dex
   │     │  │  │           └─ classes_global-synthetics
   │     │  │  ├─ generated
   │     │  │  │  ├─ ap_generated_sources
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ out
   │     │  │  │  ├─ res
   │     │  │  │  │  ├─ pngs
   │     │  │  │  │  │  └─ debug
   │     │  │  │  │  └─ resValues
   │     │  │  │  │     └─ debug
   │     │  │  │  └─ source
   │     │  │  │     └─ buildConfig
   │     │  │  │        └─ debug
   │     │  │  │           └─ io
   │     │  │  │              └─ flutter
   │     │  │  │                 └─ plugins
   │     │  │  │                    └─ firebase
   │     │  │  │                       └─ auth
   │     │  │  │                          └─ BuildConfig.java
   │     │  │  ├─ intermediates
   │     │  │  │  ├─ aapt_friendly_merged_manifests
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        └─ aapt
   │     │  │  │  │           ├─ AndroidManifest.xml
   │     │  │  │  │           └─ output-metadata.json
   │     │  │  │  ├─ aar_libs_directory
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ syncDebugLibJars
   │     │  │  │  │        └─ libs
   │     │  │  │  ├─ aar_main_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ syncDebugLibJars
   │     │  │  │  │        └─ classes.jar
   │     │  │  │  ├─ aar_metadata
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ writeDebugAarMetadata
   │     │  │  │  │        └─ aar-metadata.properties
   │     │  │  │  ├─ annotations_typedef_file
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDebugAnnotations
   │     │  │  │  │        └─ typedefs.txt
   │     │  │  │  ├─ annotations_zip
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDebugAnnotations
   │     │  │  │  ├─ annotation_processor_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ javaPreCompileDebug
   │     │  │  │  │        └─ annotationProcessors.json
   │     │  │  │  ├─ assets
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugAssets
   │     │  │  │  ├─ compiled_local_resources
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ compileDebugLibraryResources
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ compile_library_classes_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ bundleLibCompileToJarDebug
   │     │  │  │  │        └─ classes.jar
   │     │  │  │  ├─ compile_r_class_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugRFile
   │     │  │  │  │        └─ R.jar
   │     │  │  │  ├─ compile_symbol_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugRFile
   │     │  │  │  │        └─ R.txt
   │     │  │  │  ├─ data_binding_layout_info_type_package
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ incremental
   │     │  │  │  │  ├─ debug
   │     │  │  │  │  │  └─ packageDebugResources
   │     │  │  │  │  │     ├─ compile-file-map.properties
   │     │  │  │  │  │     ├─ merged.dir
   │     │  │  │  │  │     ├─ merger.xml
   │     │  │  │  │  │     └─ stripped.dir
   │     │  │  │  │  ├─ debug-mergeJavaRes
   │     │  │  │  │  │  ├─ merge-state
   │     │  │  │  │  │  └─ zip-cache
   │     │  │  │  │  ├─ mergeDebugAssets
   │     │  │  │  │  │  └─ merger.xml
   │     │  │  │  │  ├─ mergeDebugJniLibFolders
   │     │  │  │  │  │  └─ merger.xml
   │     │  │  │  │  └─ mergeDebugShaders
   │     │  │  │  │     └─ merger.xml
   │     │  │  │  ├─ javac
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ compileDebugJavaWithJavac
   │     │  │  │  │        └─ classes
   │     │  │  │  │           └─ io
   │     │  │  │  │              └─ flutter
   │     │  │  │  │                 └─ plugins
   │     │  │  │  │                    └─ firebase
   │     │  │  │  │                       └─ auth
   │     │  │  │  │                          ├─ AuthStateChannelStreamHandler.class
   │     │  │  │  │                          ├─ BuildConfig.class
   │     │  │  │  │                          ├─ Constants.class
   │     │  │  │  │                          ├─ FlutterFirebaseAuthPlugin.class
   │     │  │  │  │                          ├─ FlutterFirebaseAuthPluginException.class
   │     │  │  │  │                          ├─ FlutterFirebaseAuthRegistrar.class
   │     │  │  │  │                          ├─ FlutterFirebaseAuthUser.class
   │     │  │  │  │                          ├─ FlutterFirebaseMultiFactor.class
   │     │  │  │  │                          ├─ FlutterFirebaseTotpMultiFactor.class
   │     │  │  │  │                          ├─ FlutterFirebaseTotpSecret.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$ActionCodeInfoOperation.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$AuthPigeonFirebaseApp$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$AuthPigeonFirebaseApp.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$CanIgnoreReturnValue.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$1.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$10.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$11.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$12.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$13.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$14.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$15.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$16.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$17.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$18.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$19.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$2.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$20.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$21.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$22.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$23.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$3.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$4.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$5.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$6.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$7.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$8.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$9.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApiCodec.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$1.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$10.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$11.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$12.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$13.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$14.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$2.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$3.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$4.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$5.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$6.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$7.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$8.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$9.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApiCodec.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$FlutterError.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$GenerateInterfaces.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$GenerateInterfacesCodec.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApi$1.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApi.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApiCodec.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$1.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$2.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$3.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApiCodec.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi$1.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi$2.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$1.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$2.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$3.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$4.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$5.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApiCodec.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$NullableResult.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfo$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfo.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfoData$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfoData.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeSettings$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeSettings.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonAdditionalUserInfo$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonAdditionalUserInfo.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonAuthCredential$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonAuthCredential.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonFirebaseAuthSettings$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonFirebaseAuthSettings.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonIdTokenResult$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonIdTokenResult.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorInfo$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorInfo.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorSession$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorSession.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonPhoneMultiFactorAssertion$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonPhoneMultiFactorAssertion.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonSignInProvider$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonSignInProvider.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonTotpSecret$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonTotpSecret.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserCredential$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserCredential.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserDetails$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserDetails.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserInfo$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserInfo.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserProfile$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonUserProfile.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$Result.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth$VoidResult.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseAuth.class
   │     │  │  │  │                          ├─ IdTokenChannelStreamHandler.class
   │     │  │  │  │                          ├─ PhoneNumberVerificationStreamHandler$1.class
   │     │  │  │  │                          ├─ PhoneNumberVerificationStreamHandler$OnCredentialsListener.class
   │     │  │  │  │                          ├─ PhoneNumberVerificationStreamHandler.class
   │     │  │  │  │                          └─ PigeonParser.class
   │     │  │  │  ├─ library_and_local_jars_jni
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ copyDebugJniLibsProjectAndLocalJars
   │     │  │  │  │        └─ jni
   │     │  │  │  ├─ library_jni
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ copyDebugJniLibsProjectOnly
   │     │  │  │  │        └─ jni
   │     │  │  │  ├─ local_only_symbol_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ parseDebugLocalResources
   │     │  │  │  │        └─ R-def.txt
   │     │  │  │  ├─ manifest_merge_blame_file
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        └─ manifest-merger-blame-debug-report.txt
   │     │  │  │  ├─ merged_java_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugJavaResource
   │     │  │  │  │        └─ feature-firebase_auth.jar
   │     │  │  │  ├─ merged_jni_libs
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugJniLibFolders
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ merged_manifest
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        └─ AndroidManifest.xml
   │     │  │  │  ├─ merged_shaders
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugShaders
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ navigation_json
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDeepLinksDebug
   │     │  │  │  │        └─ navigation.json
   │     │  │  │  ├─ nested_resources_validation_report
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugResources
   │     │  │  │  │        └─ nestedResourcesValidationReport.txt
   │     │  │  │  ├─ packaged_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  ├─ public_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  ├─ runtime_library_classes_dir
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ bundleLibRuntimeToDirDebug
   │     │  │  │  │        └─ io
   │     │  │  │  │           └─ flutter
   │     │  │  │  │              └─ plugins
   │     │  │  │  │                 └─ firebase
   │     │  │  │  │                    └─ auth
   │     │  │  │  │                       ├─ AuthStateChannelStreamHandler.class
   │     │  │  │  │                       ├─ BuildConfig.class
   │     │  │  │  │                       ├─ Constants.class
   │     │  │  │  │                       ├─ FlutterFirebaseAuthPlugin.class
   │     │  │  │  │                       ├─ FlutterFirebaseAuthPluginException.class
   │     │  │  │  │                       ├─ FlutterFirebaseAuthRegistrar.class
   │     │  │  │  │                       ├─ FlutterFirebaseAuthUser.class
   │     │  │  │  │                       ├─ FlutterFirebaseMultiFactor.class
   │     │  │  │  │                       ├─ FlutterFirebaseTotpMultiFactor.class
   │     │  │  │  │                       ├─ FlutterFirebaseTotpSecret.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$ActionCodeInfoOperation.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$AuthPigeonFirebaseApp$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$AuthPigeonFirebaseApp.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$CanIgnoreReturnValue.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$1.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$10.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$11.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$12.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$13.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$14.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$15.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$16.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$17.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$18.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$19.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$2.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$20.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$21.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$22.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$23.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$3.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$4.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$5.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$6.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$7.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$8.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi$9.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApi.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthHostApiCodec.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$1.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$10.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$11.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$12.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$13.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$14.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$2.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$3.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$4.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$5.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$6.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$7.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$8.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi$9.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApi.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FirebaseAuthUserHostApiCodec.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$FlutterError.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$GenerateInterfaces.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$GenerateInterfacesCodec.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApi$1.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApi.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactoResolverHostApiCodec.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$1.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$2.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi$3.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApi.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpHostApiCodec.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi$1.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi$2.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorTotpSecretHostApi.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$1.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$2.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$3.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$4.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi$5.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApi.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$MultiFactorUserHostApiCodec.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$NullableResult.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfo$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfo.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfoData$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeInfoData.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeSettings$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonActionCodeSettings.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonAdditionalUserInfo$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonAdditionalUserInfo.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonAuthCredential$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonAuthCredential.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonFirebaseAuthSettings$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonFirebaseAuthSettings.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonIdTokenResult$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonIdTokenResult.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorInfo$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorInfo.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorSession$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonMultiFactorSession.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonPhoneMultiFactorAssertion$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonPhoneMultiFactorAssertion.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonSignInProvider$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonSignInProvider.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonTotpSecret$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonTotpSecret.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserCredential$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserCredential.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserDetails$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserDetails.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserInfo$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserInfo.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserProfile$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonUserProfile.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$Result.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth$VoidResult.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseAuth.class
   │     │  │  │  │                       ├─ IdTokenChannelStreamHandler.class
   │     │  │  │  │                       ├─ PhoneNumberVerificationStreamHandler$1.class
   │     │  │  │  │                       ├─ PhoneNumberVerificationStreamHandler$OnCredentialsListener.class
   │     │  │  │  │                       ├─ PhoneNumberVerificationStreamHandler.class
   │     │  │  │  │                       └─ PigeonParser.class
   │     │  │  │  ├─ runtime_library_classes_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ bundleLibRuntimeToJarDebug
   │     │  │  │  │        └─ classes.jar
   │     │  │  │  └─ symbol_list_with_package_name
   │     │  │  │     └─ debug
   │     │  │  │        └─ generateDebugRFile
   │     │  │  │           └─ package-aware-r.txt
   │     │  │  ├─ outputs
   │     │  │  │  ├─ aar
   │     │  │  │  │  └─ firebase_auth-debug.aar
   │     │  │  │  └─ logs
   │     │  │  │     └─ manifest-merger-debug-report.txt
   │     │  │  └─ tmp
   │     │  │     └─ compileDebugJavaWithJavac
   │     │  │        └─ previous-compilation-data.bin
   │     │  ├─ firebase_core
   │     │  │  ├─ .transforms
   │     │  │  │  ├─ 33ae1c85de3a120294159d7adf0fef6b
   │     │  │  │  │  ├─ results.bin
   │     │  │  │  │  └─ transformed
   │     │  │  │  │     └─ bundleLibRuntimeToDirDebug
   │     │  │  │  │        ├─ bundleLibRuntimeToDirDebug_dex
   │     │  │  │  │        │  └─ io
   │     │  │  │  │        │     └─ flutter
   │     │  │  │  │        │        └─ plugins
   │     │  │  │  │        │           └─ firebase
   │     │  │  │  │        │              └─ core
   │     │  │  │  │        │                 ├─ BuildConfig.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseCorePlugin.dex
   │     │  │  │  │        │                 ├─ FlutterFirebaseCoreRegistrar.dex
   │     │  │  │  │        │                 ├─ FlutterFirebasePlugin.dex
   │     │  │  │  │        │                 ├─ FlutterFirebasePluginRegistry.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$CanIgnoreReturnValue.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$CoreFirebaseOptions$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$CoreFirebaseOptions.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$CoreInitializeResponse$Builder.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$CoreInitializeResponse.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$1.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$2.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$3.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$1.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$2.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$3.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$FlutterError.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$NullableResult.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$PigeonCodec.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$Result.dex
   │     │  │  │  │        │                 ├─ GeneratedAndroidFirebaseCore$VoidResult.dex
   │     │  │  │  │        │                 └─ GeneratedAndroidFirebaseCore.dex
   │     │  │  │  │        ├─ bundleLibRuntimeToDirDebug_global-synthetics
   │     │  │  │  │        └─ desugar_graph.bin
   │     │  │  │  └─ b81f131b32bcb18db0d58315434a652e
   │     │  │  │     ├─ results.bin
   │     │  │  │     └─ transformed
   │     │  │  │        └─ classes
   │     │  │  │           ├─ classes_dex
   │     │  │  │           │  └─ classes.dex
   │     │  │  │           └─ classes_global-synthetics
   │     │  │  ├─ generated
   │     │  │  │  ├─ ap_generated_sources
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ out
   │     │  │  │  ├─ res
   │     │  │  │  │  ├─ pngs
   │     │  │  │  │  │  └─ debug
   │     │  │  │  │  └─ resValues
   │     │  │  │  │     └─ debug
   │     │  │  │  └─ source
   │     │  │  │     └─ buildConfig
   │     │  │  │        └─ debug
   │     │  │  │           └─ io
   │     │  │  │              └─ flutter
   │     │  │  │                 └─ plugins
   │     │  │  │                    └─ firebase
   │     │  │  │                       └─ core
   │     │  │  │                          └─ BuildConfig.java
   │     │  │  ├─ intermediates
   │     │  │  │  ├─ aapt_friendly_merged_manifests
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        └─ aapt
   │     │  │  │  │           ├─ AndroidManifest.xml
   │     │  │  │  │           └─ output-metadata.json
   │     │  │  │  ├─ aar_libs_directory
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ syncDebugLibJars
   │     │  │  │  │        └─ libs
   │     │  │  │  ├─ aar_main_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ syncDebugLibJars
   │     │  │  │  │        └─ classes.jar
   │     │  │  │  ├─ aar_metadata
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ writeDebugAarMetadata
   │     │  │  │  │        └─ aar-metadata.properties
   │     │  │  │  ├─ annotations_typedef_file
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDebugAnnotations
   │     │  │  │  │        └─ typedefs.txt
   │     │  │  │  ├─ annotations_zip
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDebugAnnotations
   │     │  │  │  ├─ annotation_processor_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ javaPreCompileDebug
   │     │  │  │  │        └─ annotationProcessors.json
   │     │  │  │  ├─ assets
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugAssets
   │     │  │  │  ├─ compiled_local_resources
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ compileDebugLibraryResources
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ compile_library_classes_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ bundleLibCompileToJarDebug
   │     │  │  │  │        └─ classes.jar
   │     │  │  │  ├─ compile_r_class_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugRFile
   │     │  │  │  │        └─ R.jar
   │     │  │  │  ├─ compile_symbol_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugRFile
   │     │  │  │  │        └─ R.txt
   │     │  │  │  ├─ data_binding_layout_info_type_package
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ incremental
   │     │  │  │  │  ├─ debug
   │     │  │  │  │  │  └─ packageDebugResources
   │     │  │  │  │  │     ├─ compile-file-map.properties
   │     │  │  │  │  │     ├─ merged.dir
   │     │  │  │  │  │     ├─ merger.xml
   │     │  │  │  │  │     └─ stripped.dir
   │     │  │  │  │  ├─ debug-mergeJavaRes
   │     │  │  │  │  │  ├─ merge-state
   │     │  │  │  │  │  └─ zip-cache
   │     │  │  │  │  ├─ mergeDebugAssets
   │     │  │  │  │  │  └─ merger.xml
   │     │  │  │  │  ├─ mergeDebugJniLibFolders
   │     │  │  │  │  │  └─ merger.xml
   │     │  │  │  │  └─ mergeDebugShaders
   │     │  │  │  │     └─ merger.xml
   │     │  │  │  ├─ javac
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ compileDebugJavaWithJavac
   │     │  │  │  │        └─ classes
   │     │  │  │  │           └─ io
   │     │  │  │  │              └─ flutter
   │     │  │  │  │                 └─ plugins
   │     │  │  │  │                    └─ firebase
   │     │  │  │  │                       └─ core
   │     │  │  │  │                          ├─ BuildConfig.class
   │     │  │  │  │                          ├─ FlutterFirebaseCorePlugin.class
   │     │  │  │  │                          ├─ FlutterFirebaseCoreRegistrar.class
   │     │  │  │  │                          ├─ FlutterFirebasePlugin.class
   │     │  │  │  │                          ├─ FlutterFirebasePluginRegistry.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$CanIgnoreReturnValue.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$CoreFirebaseOptions$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$CoreFirebaseOptions.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$CoreInitializeResponse$Builder.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$CoreInitializeResponse.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$1.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$2.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$3.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$1.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$2.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$3.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$FlutterError.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$NullableResult.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$PigeonCodec.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$Result.class
   │     │  │  │  │                          ├─ GeneratedAndroidFirebaseCore$VoidResult.class
   │     │  │  │  │                          └─ GeneratedAndroidFirebaseCore.class
   │     │  │  │  ├─ library_and_local_jars_jni
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ copyDebugJniLibsProjectAndLocalJars
   │     │  │  │  │        └─ jni
   │     │  │  │  ├─ library_jni
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ copyDebugJniLibsProjectOnly
   │     │  │  │  │        └─ jni
   │     │  │  │  ├─ local_only_symbol_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ parseDebugLocalResources
   │     │  │  │  │        └─ R-def.txt
   │     │  │  │  ├─ manifest_merge_blame_file
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        └─ manifest-merger-blame-debug-report.txt
   │     │  │  │  ├─ merged_java_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugJavaResource
   │     │  │  │  │        └─ feature-firebase_core.jar
   │     │  │  │  ├─ merged_jni_libs
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugJniLibFolders
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ merged_manifest
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        └─ AndroidManifest.xml
   │     │  │  │  ├─ merged_shaders
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugShaders
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ navigation_json
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDeepLinksDebug
   │     │  │  │  │        └─ navigation.json
   │     │  │  │  ├─ nested_resources_validation_report
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugResources
   │     │  │  │  │        └─ nestedResourcesValidationReport.txt
   │     │  │  │  ├─ packaged_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  ├─ public_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  ├─ runtime_library_classes_dir
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ bundleLibRuntimeToDirDebug
   │     │  │  │  │        └─ io
   │     │  │  │  │           └─ flutter
   │     │  │  │  │              └─ plugins
   │     │  │  │  │                 └─ firebase
   │     │  │  │  │                    └─ core
   │     │  │  │  │                       ├─ BuildConfig.class
   │     │  │  │  │                       ├─ FlutterFirebaseCorePlugin.class
   │     │  │  │  │                       ├─ FlutterFirebaseCoreRegistrar.class
   │     │  │  │  │                       ├─ FlutterFirebasePlugin.class
   │     │  │  │  │                       ├─ FlutterFirebasePluginRegistry.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$CanIgnoreReturnValue.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$CoreFirebaseOptions$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$CoreFirebaseOptions.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$CoreInitializeResponse$Builder.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$CoreInitializeResponse.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$1.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$2.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi$3.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseAppHostApi.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$1.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$2.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi$3.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FirebaseCoreHostApi.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$FlutterError.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$NullableResult.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$PigeonCodec.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$Result.class
   │     │  │  │  │                       ├─ GeneratedAndroidFirebaseCore$VoidResult.class
   │     │  │  │  │                       └─ GeneratedAndroidFirebaseCore.class
   │     │  │  │  ├─ runtime_library_classes_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ bundleLibRuntimeToJarDebug
   │     │  │  │  │        └─ classes.jar
   │     │  │  │  └─ symbol_list_with_package_name
   │     │  │  │     └─ debug
   │     │  │  │        └─ generateDebugRFile
   │     │  │  │           └─ package-aware-r.txt
   │     │  │  ├─ outputs
   │     │  │  │  ├─ aar
   │     │  │  │  │  └─ firebase_core-debug.aar
   │     │  │  │  └─ logs
   │     │  │  │     └─ manifest-merger-debug-report.txt
   │     │  │  └─ tmp
   │     │  │     └─ compileDebugJavaWithJavac
   │     │  │        └─ previous-compilation-data.bin
   │     │  ├─ firebase_messaging
   │     │  │  ├─ .transforms
   │     │  │  │  ├─ 62b879b1d3c599ad626995e2b2cbcdb2
   │     │  │  │  │  ├─ results.bin
   │     │  │  │  │  └─ transformed
   │     │  │  │  │     └─ classes
   │     │  │  │  │        ├─ classes_dex
   │     │  │  │  │        │  └─ classes.dex
   │     │  │  │  │        └─ classes_global-synthetics
   │     │  │  │  └─ 942df067ae8ce2a7f8e105f711a21f30
   │     │  │  │     ├─ results.bin
   │     │  │  │     └─ transformed
   │     │  │  │        └─ bundleLibRuntimeToDirDebug
   │     │  │  │           ├─ bundleLibRuntimeToDirDebug_dex
   │     │  │  │           │  └─ io
   │     │  │  │           │     └─ flutter
   │     │  │  │           │        └─ plugins
   │     │  │  │           │           └─ firebase
   │     │  │  │           │              └─ messaging
   │     │  │  │           │                 ├─ BuildConfig.dex
   │     │  │  │           │                 ├─ ContextHolder.dex
   │     │  │  │           │                 ├─ ErrorCallback.dex
   │     │  │  │           │                 ├─ FlutterFirebaseAppRegistrar.dex
   │     │  │  │           │                 ├─ FlutterFirebaseMessagingBackgroundExecutor$1.dex
   │     │  │  │           │                 ├─ FlutterFirebaseMessagingBackgroundExecutor$2.dex
   │     │  │  │           │                 ├─ FlutterFirebaseMessagingBackgroundExecutor.dex
   │     │  │  │           │                 ├─ FlutterFirebaseMessagingBackgroundService.dex
   │     │  │  │           │                 ├─ FlutterFirebaseMessagingInitProvider.dex
   │     │  │  │           │                 ├─ FlutterFirebaseMessagingPlugin$1.dex
   │     │  │  │           │                 ├─ FlutterFirebaseMessagingPlugin$2.dex
   │     │  │  │           │                 ├─ FlutterFirebaseMessagingPlugin.dex
   │     │  │  │           │                 ├─ FlutterFirebaseMessagingReceiver.dex
   │     │  │  │           │                 ├─ FlutterFirebaseMessagingService.dex
   │     │  │  │           │                 ├─ FlutterFirebaseMessagingStore.dex
   │     │  │  │           │                 ├─ FlutterFirebaseMessagingUtils.dex
   │     │  │  │           │                 ├─ FlutterFirebasePermissionManager$RequestPermissionsSuccessCallback.dex
   │     │  │  │           │                 ├─ FlutterFirebasePermissionManager.dex
   │     │  │  │           │                 ├─ FlutterFirebaseRemoteMessageLiveData.dex
   │     │  │  │           │                 ├─ FlutterFirebaseTokenLiveData.dex
   │     │  │  │           │                 ├─ JobIntentService$CommandProcessor$1$1.dex
   │     │  │  │           │                 ├─ JobIntentService$CommandProcessor$1.dex
   │     │  │  │           │                 ├─ JobIntentService$CommandProcessor.dex
   │     │  │  │           │                 ├─ JobIntentService$CompatJobEngine.dex
   │     │  │  │           │                 ├─ JobIntentService$CompatWorkEnqueuer.dex
   │     │  │  │           │                 ├─ JobIntentService$CompatWorkItem.dex
   │     │  │  │           │                 ├─ JobIntentService$ComponentNameWithWakeful.dex
   │     │  │  │           │                 ├─ JobIntentService$GenericWorkItem.dex
   │     │  │  │           │                 ├─ JobIntentService$JobServiceEngineImpl$WrapperWorkItem.dex
   │     │  │  │           │                 ├─ JobIntentService$JobServiceEngineImpl.dex
   │     │  │  │           │                 ├─ JobIntentService$JobWorkEnqueuer.dex
   │     │  │  │           │                 ├─ JobIntentService$WorkEnqueuer.dex
   │     │  │  │           │                 ├─ JobIntentService.dex
   │     │  │  │           │                 └─ PluginRegistrantException.dex
   │     │  │  │           ├─ bundleLibRuntimeToDirDebug_global-synthetics
   │     │  │  │           └─ desugar_graph.bin
   │     │  │  ├─ generated
   │     │  │  │  ├─ ap_generated_sources
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ out
   │     │  │  │  ├─ res
   │     │  │  │  │  ├─ pngs
   │     │  │  │  │  │  └─ debug
   │     │  │  │  │  └─ resValues
   │     │  │  │  │     └─ debug
   │     │  │  │  └─ source
   │     │  │  │     └─ buildConfig
   │     │  │  │        └─ debug
   │     │  │  │           └─ io
   │     │  │  │              └─ flutter
   │     │  │  │                 └─ plugins
   │     │  │  │                    └─ firebase
   │     │  │  │                       └─ messaging
   │     │  │  │                          └─ BuildConfig.java
   │     │  │  ├─ intermediates
   │     │  │  │  ├─ aapt_friendly_merged_manifests
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        └─ aapt
   │     │  │  │  │           ├─ AndroidManifest.xml
   │     │  │  │  │           └─ output-metadata.json
   │     │  │  │  ├─ aar_libs_directory
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ syncDebugLibJars
   │     │  │  │  │        └─ libs
   │     │  │  │  ├─ aar_main_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ syncDebugLibJars
   │     │  │  │  │        └─ classes.jar
   │     │  │  │  ├─ aar_metadata
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ writeDebugAarMetadata
   │     │  │  │  │        └─ aar-metadata.properties
   │     │  │  │  ├─ annotations_typedef_file
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDebugAnnotations
   │     │  │  │  │        └─ typedefs.txt
   │     │  │  │  ├─ annotations_zip
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDebugAnnotations
   │     │  │  │  ├─ annotation_processor_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ javaPreCompileDebug
   │     │  │  │  │        └─ annotationProcessors.json
   │     │  │  │  ├─ assets
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugAssets
   │     │  │  │  ├─ compiled_local_resources
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ compileDebugLibraryResources
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ compile_library_classes_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ bundleLibCompileToJarDebug
   │     │  │  │  │        └─ classes.jar
   │     │  │  │  ├─ compile_r_class_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugRFile
   │     │  │  │  │        └─ R.jar
   │     │  │  │  ├─ compile_symbol_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugRFile
   │     │  │  │  │        └─ R.txt
   │     │  │  │  ├─ data_binding_layout_info_type_package
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ incremental
   │     │  │  │  │  ├─ debug
   │     │  │  │  │  │  └─ packageDebugResources
   │     │  │  │  │  │     ├─ compile-file-map.properties
   │     │  │  │  │  │     ├─ merged.dir
   │     │  │  │  │  │     ├─ merger.xml
   │     │  │  │  │  │     └─ stripped.dir
   │     │  │  │  │  ├─ debug-mergeJavaRes
   │     │  │  │  │  │  ├─ merge-state
   │     │  │  │  │  │  └─ zip-cache
   │     │  │  │  │  ├─ mergeDebugAssets
   │     │  │  │  │  │  └─ merger.xml
   │     │  │  │  │  ├─ mergeDebugJniLibFolders
   │     │  │  │  │  │  └─ merger.xml
   │     │  │  │  │  └─ mergeDebugShaders
   │     │  │  │  │     └─ merger.xml
   │     │  │  │  ├─ javac
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ compileDebugJavaWithJavac
   │     │  │  │  │        └─ classes
   │     │  │  │  │           └─ io
   │     │  │  │  │              └─ flutter
   │     │  │  │  │                 └─ plugins
   │     │  │  │  │                    └─ firebase
   │     │  │  │  │                       └─ messaging
   │     │  │  │  │                          ├─ BuildConfig.class
   │     │  │  │  │                          ├─ ContextHolder.class
   │     │  │  │  │                          ├─ ErrorCallback.class
   │     │  │  │  │                          ├─ FlutterFirebaseAppRegistrar.class
   │     │  │  │  │                          ├─ FlutterFirebaseMessagingBackgroundExecutor$1.class
   │     │  │  │  │                          ├─ FlutterFirebaseMessagingBackgroundExecutor$2.class
   │     │  │  │  │                          ├─ FlutterFirebaseMessagingBackgroundExecutor.class
   │     │  │  │  │                          ├─ FlutterFirebaseMessagingBackgroundService.class
   │     │  │  │  │                          ├─ FlutterFirebaseMessagingInitProvider.class
   │     │  │  │  │                          ├─ FlutterFirebaseMessagingPlugin$1.class
   │     │  │  │  │                          ├─ FlutterFirebaseMessagingPlugin$2.class
   │     │  │  │  │                          ├─ FlutterFirebaseMessagingPlugin.class
   │     │  │  │  │                          ├─ FlutterFirebaseMessagingReceiver.class
   │     │  │  │  │                          ├─ FlutterFirebaseMessagingService.class
   │     │  │  │  │                          ├─ FlutterFirebaseMessagingStore.class
   │     │  │  │  │                          ├─ FlutterFirebaseMessagingUtils.class
   │     │  │  │  │                          ├─ FlutterFirebasePermissionManager$RequestPermissionsSuccessCallback.class
   │     │  │  │  │                          ├─ FlutterFirebasePermissionManager.class
   │     │  │  │  │                          ├─ FlutterFirebaseRemoteMessageLiveData.class
   │     │  │  │  │                          ├─ FlutterFirebaseTokenLiveData.class
   │     │  │  │  │                          ├─ JobIntentService$CommandProcessor$1$1.class
   │     │  │  │  │                          ├─ JobIntentService$CommandProcessor$1.class
   │     │  │  │  │                          ├─ JobIntentService$CommandProcessor.class
   │     │  │  │  │                          ├─ JobIntentService$CompatJobEngine.class
   │     │  │  │  │                          ├─ JobIntentService$CompatWorkEnqueuer.class
   │     │  │  │  │                          ├─ JobIntentService$CompatWorkItem.class
   │     │  │  │  │                          ├─ JobIntentService$ComponentNameWithWakeful.class
   │     │  │  │  │                          ├─ JobIntentService$GenericWorkItem.class
   │     │  │  │  │                          ├─ JobIntentService$JobServiceEngineImpl$WrapperWorkItem.class
   │     │  │  │  │                          ├─ JobIntentService$JobServiceEngineImpl.class
   │     │  │  │  │                          ├─ JobIntentService$JobWorkEnqueuer.class
   │     │  │  │  │                          ├─ JobIntentService$WorkEnqueuer.class
   │     │  │  │  │                          ├─ JobIntentService.class
   │     │  │  │  │                          └─ PluginRegistrantException.class
   │     │  │  │  ├─ library_and_local_jars_jni
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ copyDebugJniLibsProjectAndLocalJars
   │     │  │  │  │        └─ jni
   │     │  │  │  ├─ library_jni
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ copyDebugJniLibsProjectOnly
   │     │  │  │  │        └─ jni
   │     │  │  │  ├─ local_only_symbol_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ parseDebugLocalResources
   │     │  │  │  │        └─ R-def.txt
   │     │  │  │  ├─ manifest_merge_blame_file
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        └─ manifest-merger-blame-debug-report.txt
   │     │  │  │  ├─ merged_java_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugJavaResource
   │     │  │  │  │        └─ feature-firebase_messaging.jar
   │     │  │  │  ├─ merged_jni_libs
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugJniLibFolders
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ merged_manifest
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        └─ AndroidManifest.xml
   │     │  │  │  ├─ merged_shaders
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugShaders
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ navigation_json
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDeepLinksDebug
   │     │  │  │  │        └─ navigation.json
   │     │  │  │  ├─ nested_resources_validation_report
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugResources
   │     │  │  │  │        └─ nestedResourcesValidationReport.txt
   │     │  │  │  ├─ packaged_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  ├─ public_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  ├─ runtime_library_classes_dir
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ bundleLibRuntimeToDirDebug
   │     │  │  │  │        └─ io
   │     │  │  │  │           └─ flutter
   │     │  │  │  │              └─ plugins
   │     │  │  │  │                 └─ firebase
   │     │  │  │  │                    └─ messaging
   │     │  │  │  │                       ├─ BuildConfig.class
   │     │  │  │  │                       ├─ ContextHolder.class
   │     │  │  │  │                       ├─ ErrorCallback.class
   │     │  │  │  │                       ├─ FlutterFirebaseAppRegistrar.class
   │     │  │  │  │                       ├─ FlutterFirebaseMessagingBackgroundExecutor$1.class
   │     │  │  │  │                       ├─ FlutterFirebaseMessagingBackgroundExecutor$2.class
   │     │  │  │  │                       ├─ FlutterFirebaseMessagingBackgroundExecutor.class
   │     │  │  │  │                       ├─ FlutterFirebaseMessagingBackgroundService.class
   │     │  │  │  │                       ├─ FlutterFirebaseMessagingInitProvider.class
   │     │  │  │  │                       ├─ FlutterFirebaseMessagingPlugin$1.class
   │     │  │  │  │                       ├─ FlutterFirebaseMessagingPlugin$2.class
   │     │  │  │  │                       ├─ FlutterFirebaseMessagingPlugin.class
   │     │  │  │  │                       ├─ FlutterFirebaseMessagingReceiver.class
   │     │  │  │  │                       ├─ FlutterFirebaseMessagingService.class
   │     │  │  │  │                       ├─ FlutterFirebaseMessagingStore.class
   │     │  │  │  │                       ├─ FlutterFirebaseMessagingUtils.class
   │     │  │  │  │                       ├─ FlutterFirebasePermissionManager$RequestPermissionsSuccessCallback.class
   │     │  │  │  │                       ├─ FlutterFirebasePermissionManager.class
   │     │  │  │  │                       ├─ FlutterFirebaseRemoteMessageLiveData.class
   │     │  │  │  │                       ├─ FlutterFirebaseTokenLiveData.class
   │     │  │  │  │                       ├─ JobIntentService$CommandProcessor$1$1.class
   │     │  │  │  │                       ├─ JobIntentService$CommandProcessor$1.class
   │     │  │  │  │                       ├─ JobIntentService$CommandProcessor.class
   │     │  │  │  │                       ├─ JobIntentService$CompatJobEngine.class
   │     │  │  │  │                       ├─ JobIntentService$CompatWorkEnqueuer.class
   │     │  │  │  │                       ├─ JobIntentService$CompatWorkItem.class
   │     │  │  │  │                       ├─ JobIntentService$ComponentNameWithWakeful.class
   │     │  │  │  │                       ├─ JobIntentService$GenericWorkItem.class
   │     │  │  │  │                       ├─ JobIntentService$JobServiceEngineImpl$WrapperWorkItem.class
   │     │  │  │  │                       ├─ JobIntentService$JobServiceEngineImpl.class
   │     │  │  │  │                       ├─ JobIntentService$JobWorkEnqueuer.class
   │     │  │  │  │                       ├─ JobIntentService$WorkEnqueuer.class
   │     │  │  │  │                       ├─ JobIntentService.class
   │     │  │  │  │                       └─ PluginRegistrantException.class
   │     │  │  │  ├─ runtime_library_classes_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ bundleLibRuntimeToJarDebug
   │     │  │  │  │        └─ classes.jar
   │     │  │  │  └─ symbol_list_with_package_name
   │     │  │  │     └─ debug
   │     │  │  │        └─ generateDebugRFile
   │     │  │  │           └─ package-aware-r.txt
   │     │  │  ├─ outputs
   │     │  │  │  ├─ aar
   │     │  │  │  │  └─ firebase_messaging-debug.aar
   │     │  │  │  └─ logs
   │     │  │  │     └─ manifest-merger-debug-report.txt
   │     │  │  └─ tmp
   │     │  │     └─ compileDebugJavaWithJavac
   │     │  │        └─ previous-compilation-data.bin
   │     │  ├─ flutter_local_notifications
   │     │  │  ├─ .transforms
   │     │  │  │  ├─ a981b18d836fd303baf6e272259742c6
   │     │  │  │  │  ├─ results.bin
   │     │  │  │  │  └─ transformed
   │     │  │  │  │     └─ bundleLibRuntimeToDirDebug
   │     │  │  │  │        ├─ bundleLibRuntimeToDirDebug_dex
   │     │  │  │  │        │  └─ com
   │     │  │  │  │        │     └─ dexterous
   │     │  │  │  │        │        └─ flutterlocalnotifications
   │     │  │  │  │        │           ├─ ActionBroadcastReceiver$1.dex
   │     │  │  │  │        │           ├─ ActionBroadcastReceiver$ActionEventSink.dex
   │     │  │  │  │        │           ├─ ActionBroadcastReceiver.dex
   │     │  │  │  │        │           ├─ FlutterLocalNotificationsPlugin$1.dex
   │     │  │  │  │        │           ├─ FlutterLocalNotificationsPlugin$2.dex
   │     │  │  │  │        │           ├─ FlutterLocalNotificationsPlugin$3.dex
   │     │  │  │  │        │           ├─ FlutterLocalNotificationsPlugin$4.dex
   │     │  │  │  │        │           ├─ FlutterLocalNotificationsPlugin$5.dex
   │     │  │  │  │        │           ├─ FlutterLocalNotificationsPlugin$ExactAlarmPermissionException.dex
   │     │  │  │  │        │           ├─ FlutterLocalNotificationsPlugin$PermissionRequestProgress.dex
   │     │  │  │  │        │           ├─ FlutterLocalNotificationsPlugin$PluginException.dex
   │     │  │  │  │        │           ├─ FlutterLocalNotificationsPlugin.dex
   │     │  │  │  │        │           ├─ ForegroundService.dex
   │     │  │  │  │        │           ├─ ForegroundServiceStartParameter.dex
   │     │  │  │  │        │           ├─ isolate
   │     │  │  │  │        │           │  └─ IsolatePreferences.dex
   │     │  │  │  │        │           ├─ models
   │     │  │  │  │        │           │  ├─ BitmapSource.dex
   │     │  │  │  │        │           │  ├─ DateTimeComponents.dex
   │     │  │  │  │        │           │  ├─ IconSource.dex
   │     │  │  │  │        │           │  ├─ MessageDetails.dex
   │     │  │  │  │        │           │  ├─ NotificationAction$NotificationActionInput.dex
   │     │  │  │  │        │           │  ├─ NotificationAction.dex
   │     │  │  │  │        │           │  ├─ NotificationChannelAction.dex
   │     │  │  │  │        │           │  ├─ NotificationChannelDetails.dex
   │     │  │  │  │        │           │  ├─ NotificationChannelGroupDetails.dex
   │     │  │  │  │        │           │  ├─ NotificationDetails.dex
   │     │  │  │  │        │           │  ├─ NotificationStyle.dex
   │     │  │  │  │        │           │  ├─ PersonDetails.dex
   │     │  │  │  │        │           │  ├─ RepeatInterval.dex
   │     │  │  │  │        │           │  ├─ ScheduledNotificationRepeatFrequency.dex
   │     │  │  │  │        │           │  ├─ ScheduleMode$Deserializer.dex
   │     │  │  │  │        │           │  ├─ ScheduleMode.dex
   │     │  │  │  │        │           │  ├─ SoundSource.dex
   │     │  │  │  │        │           │  ├─ styles
   │     │  │  │  │        │           │  │  ├─ BigPictureStyleInformation.dex
   │     │  │  │  │        │           │  │  ├─ BigTextStyleInformation.dex
   │     │  │  │  │        │           │  │  ├─ DefaultStyleInformation.dex
   │     │  │  │  │        │           │  │  ├─ InboxStyleInformation.dex
   │     │  │  │  │        │           │  │  ├─ MessagingStyleInformation.dex
   │     │  │  │  │        │           │  │  └─ StyleInformation.dex
   │     │  │  │  │        │           │  └─ Time.dex
   │     │  │  │  │        │           ├─ PermissionRequestListener.dex
   │     │  │  │  │        │           ├─ RuntimeTypeAdapterFactory$1.dex
   │     │  │  │  │        │           ├─ RuntimeTypeAdapterFactory.dex
   │     │  │  │  │        │           ├─ ScheduledNotificationBootReceiver.dex
   │     │  │  │  │        │           ├─ ScheduledNotificationReceiver$1.dex
   │     │  │  │  │        │           ├─ ScheduledNotificationReceiver.dex
   │     │  │  │  │        │           └─ utils
   │     │  │  │  │        │              ├─ BooleanUtils.dex
   │     │  │  │  │        │              ├─ LongUtils.dex
   │     │  │  │  │        │              └─ StringUtils.dex
   │     │  │  │  │        ├─ bundleLibRuntimeToDirDebug_global-synthetics
   │     │  │  │  │        └─ desugar_graph.bin
   │     │  │  │  └─ fbdf92fccfea1b1ca0250081bf54af98
   │     │  │  │     ├─ results.bin
   │     │  │  │     └─ transformed
   │     │  │  │        └─ classes
   │     │  │  │           ├─ classes_dex
   │     │  │  │           │  └─ classes.dex
   │     │  │  │           └─ classes_global-synthetics
   │     │  │  ├─ generated
   │     │  │  │  ├─ ap_generated_sources
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ out
   │     │  │  │  └─ res
   │     │  │  │     ├─ pngs
   │     │  │  │     │  └─ debug
   │     │  │  │     └─ resValues
   │     │  │  │        └─ debug
   │     │  │  ├─ intermediates
   │     │  │  │  ├─ aapt_friendly_merged_manifests
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        └─ aapt
   │     │  │  │  │           ├─ AndroidManifest.xml
   │     │  │  │  │           └─ output-metadata.json
   │     │  │  │  ├─ aar_libs_directory
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ syncDebugLibJars
   │     │  │  │  │        └─ libs
   │     │  │  │  ├─ aar_main_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ syncDebugLibJars
   │     │  │  │  │        └─ classes.jar
   │     │  │  │  ├─ aar_metadata
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ writeDebugAarMetadata
   │     │  │  │  │        └─ aar-metadata.properties
   │     │  │  │  ├─ annotations_typedef_file
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDebugAnnotations
   │     │  │  │  │        └─ typedefs.txt
   │     │  │  │  ├─ annotations_zip
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDebugAnnotations
   │     │  │  │  ├─ annotation_processor_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ javaPreCompileDebug
   │     │  │  │  │        └─ annotationProcessors.json
   │     │  │  │  ├─ assets
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugAssets
   │     │  │  │  ├─ compiled_local_resources
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ compileDebugLibraryResources
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ compile_library_classes_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ bundleLibCompileToJarDebug
   │     │  │  │  │        └─ classes.jar
   │     │  │  │  ├─ compile_r_class_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugRFile
   │     │  │  │  │        └─ R.jar
   │     │  │  │  ├─ compile_symbol_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugRFile
   │     │  │  │  │        └─ R.txt
   │     │  │  │  ├─ data_binding_layout_info_type_package
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ incremental
   │     │  │  │  │  ├─ debug
   │     │  │  │  │  │  └─ packageDebugResources
   │     │  │  │  │  │     ├─ compile-file-map.properties
   │     │  │  │  │  │     ├─ merged.dir
   │     │  │  │  │  │     ├─ merger.xml
   │     │  │  │  │  │     └─ stripped.dir
   │     │  │  │  │  ├─ debug-mergeJavaRes
   │     │  │  │  │  │  ├─ merge-state
   │     │  │  │  │  │  └─ zip-cache
   │     │  │  │  │  ├─ mergeDebugAssets
   │     │  │  │  │  │  └─ merger.xml
   │     │  │  │  │  ├─ mergeDebugJniLibFolders
   │     │  │  │  │  │  └─ merger.xml
   │     │  │  │  │  └─ mergeDebugShaders
   │     │  │  │  │     └─ merger.xml
   │     │  │  │  ├─ javac
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ compileDebugJavaWithJavac
   │     │  │  │  │        └─ classes
   │     │  │  │  │           └─ com
   │     │  │  │  │              └─ dexterous
   │     │  │  │  │                 └─ flutterlocalnotifications
   │     │  │  │  │                    ├─ ActionBroadcastReceiver$1.class
   │     │  │  │  │                    ├─ ActionBroadcastReceiver$ActionEventSink.class
   │     │  │  │  │                    ├─ ActionBroadcastReceiver.class
   │     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$1.class
   │     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$2.class
   │     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$3.class
   │     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$4.class
   │     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$5.class
   │     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$ExactAlarmPermissionException.class
   │     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$PermissionRequestProgress.class
   │     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin$PluginException.class
   │     │  │  │  │                    ├─ FlutterLocalNotificationsPlugin.class
   │     │  │  │  │                    ├─ ForegroundService.class
   │     │  │  │  │                    ├─ ForegroundServiceStartParameter.class
   │     │  │  │  │                    ├─ isolate
   │     │  │  │  │                    │  └─ IsolatePreferences.class
   │     │  │  │  │                    ├─ models
   │     │  │  │  │                    │  ├─ BitmapSource.class
   │     │  │  │  │                    │  ├─ DateTimeComponents.class
   │     │  │  │  │                    │  ├─ IconSource.class
   │     │  │  │  │                    │  ├─ MessageDetails.class
   │     │  │  │  │                    │  ├─ NotificationAction$NotificationActionInput.class
   │     │  │  │  │                    │  ├─ NotificationAction.class
   │     │  │  │  │                    │  ├─ NotificationChannelAction.class
   │     │  │  │  │                    │  ├─ NotificationChannelDetails.class
   │     │  │  │  │                    │  ├─ NotificationChannelGroupDetails.class
   │     │  │  │  │                    │  ├─ NotificationDetails.class
   │     │  │  │  │                    │  ├─ NotificationStyle.class
   │     │  │  │  │                    │  ├─ PersonDetails.class
   │     │  │  │  │                    │  ├─ RepeatInterval.class
   │     │  │  │  │                    │  ├─ ScheduledNotificationRepeatFrequency.class
   │     │  │  │  │                    │  ├─ ScheduleMode$Deserializer.class
   │     │  │  │  │                    │  ├─ ScheduleMode.class
   │     │  │  │  │                    │  ├─ SoundSource.class
   │     │  │  │  │                    │  ├─ styles
   │     │  │  │  │                    │  │  ├─ BigPictureStyleInformation.class
   │     │  │  │  │                    │  │  ├─ BigTextStyleInformation.class
   │     │  │  │  │                    │  │  ├─ DefaultStyleInformation.class
   │     │  │  │  │                    │  │  ├─ InboxStyleInformation.class
   │     │  │  │  │                    │  │  ├─ MessagingStyleInformation.class
   │     │  │  │  │                    │  │  └─ StyleInformation.class
   │     │  │  │  │                    │  └─ Time.class
   │     │  │  │  │                    ├─ PermissionRequestListener.class
   │     │  │  │  │                    ├─ RuntimeTypeAdapterFactory$1.class
   │     │  │  │  │                    ├─ RuntimeTypeAdapterFactory.class
   │     │  │  │  │                    ├─ ScheduledNotificationBootReceiver.class
   │     │  │  │  │                    ├─ ScheduledNotificationReceiver$1.class
   │     │  │  │  │                    ├─ ScheduledNotificationReceiver.class
   │     │  │  │  │                    └─ utils
   │     │  │  │  │                       ├─ BooleanUtils.class
   │     │  │  │  │                       ├─ LongUtils.class
   │     │  │  │  │                       └─ StringUtils.class
   │     │  │  │  ├─ library_and_local_jars_jni
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ copyDebugJniLibsProjectAndLocalJars
   │     │  │  │  │        └─ jni
   │     │  │  │  ├─ library_jni
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ copyDebugJniLibsProjectOnly
   │     │  │  │  │        └─ jni
   │     │  │  │  ├─ local_only_symbol_list
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ parseDebugLocalResources
   │     │  │  │  │        └─ R-def.txt
   │     │  │  │  ├─ manifest_merge_blame_file
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        └─ manifest-merger-blame-debug-report.txt
   │     │  │  │  ├─ merged_java_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugJavaResource
   │     │  │  │  │        └─ feature-flutter_local_notifications.jar
   │     │  │  │  ├─ merged_jni_libs
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugJniLibFolders
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ merged_manifest
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ processDebugManifest
   │     │  │  │  │        └─ AndroidManifest.xml
   │     │  │  │  ├─ merged_shaders
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ mergeDebugShaders
   │     │  │  │  │        └─ out
   │     │  │  │  ├─ navigation_json
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ extractDeepLinksDebug
   │     │  │  │  │        └─ navigation.json
   │     │  │  │  ├─ nested_resources_validation_report
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ generateDebugResources
   │     │  │  │  │        └─ nestedResourcesValidationReport.txt
   │     │  │  │  ├─ packaged_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  ├─ public_res
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ packageDebugResources
   │     │  │  │  ├─ runtime_library_classes_dir
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ bundleLibRuntimeToDirDebug
   │     │  │  │  │        └─ com
   │     │  │  │  │           └─ dexterous
   │     │  │  │  │              └─ flutterlocalnotifications
   │     │  │  │  │                 ├─ ActionBroadcastReceiver$1.class
   │     │  │  │  │                 ├─ ActionBroadcastReceiver$ActionEventSink.class
   │     │  │  │  │                 ├─ ActionBroadcastReceiver.class
   │     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$1.class
   │     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$2.class
   │     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$3.class
   │     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$4.class
   │     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$5.class
   │     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$ExactAlarmPermissionException.class
   │     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$PermissionRequestProgress.class
   │     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin$PluginException.class
   │     │  │  │  │                 ├─ FlutterLocalNotificationsPlugin.class
   │     │  │  │  │                 ├─ ForegroundService.class
   │     │  │  │  │                 ├─ ForegroundServiceStartParameter.class
   │     │  │  │  │                 ├─ isolate
   │     │  │  │  │                 │  └─ IsolatePreferences.class
   │     │  │  │  │                 ├─ models
   │     │  │  │  │                 │  ├─ BitmapSource.class
   │     │  │  │  │                 │  ├─ DateTimeComponents.class
   │     │  │  │  │                 │  ├─ IconSource.class
   │     │  │  │  │                 │  ├─ MessageDetails.class
   │     │  │  │  │                 │  ├─ NotificationAction$NotificationActionInput.class
   │     │  │  │  │                 │  ├─ NotificationAction.class
   │     │  │  │  │                 │  ├─ NotificationChannelAction.class
   │     │  │  │  │                 │  ├─ NotificationChannelDetails.class
   │     │  │  │  │                 │  ├─ NotificationChannelGroupDetails.class
   │     │  │  │  │                 │  ├─ NotificationDetails.class
   │     │  │  │  │                 │  ├─ NotificationStyle.class
   │     │  │  │  │                 │  ├─ PersonDetails.class
   │     │  │  │  │                 │  ├─ RepeatInterval.class
   │     │  │  │  │                 │  ├─ ScheduledNotificationRepeatFrequency.class
   │     │  │  │  │                 │  ├─ ScheduleMode$Deserializer.class
   │     │  │  │  │                 │  ├─ ScheduleMode.class
   │     │  │  │  │                 │  ├─ SoundSource.class
   │     │  │  │  │                 │  ├─ styles
   │     │  │  │  │                 │  │  ├─ BigPictureStyleInformation.class
   │     │  │  │  │                 │  │  ├─ BigTextStyleInformation.class
   │     │  │  │  │                 │  │  ├─ DefaultStyleInformation.class
   │     │  │  │  │                 │  │  ├─ InboxStyleInformation.class
   │     │  │  │  │                 │  │  ├─ MessagingStyleInformation.class
   │     │  │  │  │                 │  │  └─ StyleInformation.class
   │     │  │  │  │                 │  └─ Time.class
   │     │  │  │  │                 ├─ PermissionRequestListener.class
   │     │  │  │  │                 ├─ RuntimeTypeAdapterFactory$1.class
   │     │  │  │  │                 ├─ RuntimeTypeAdapterFactory.class
   │     │  │  │  │                 ├─ ScheduledNotificationBootReceiver.class
   │     │  │  │  │                 ├─ ScheduledNotificationReceiver$1.class
   │     │  │  │  │                 ├─ ScheduledNotificationReceiver.class
   │     │  │  │  │                 └─ utils
   │     │  │  │  │                    ├─ BooleanUtils.class
   │     │  │  │  │                    ├─ LongUtils.class
   │     │  │  │  │                    └─ StringUtils.class
   │     │  │  │  ├─ runtime_library_classes_jar
   │     │  │  │  │  └─ debug
   │     │  │  │  │     └─ bundleLibRuntimeToJarDebug
   │     │  │  │  │        └─ classes.jar
   │     │  │  │  └─ symbol_list_with_package_name
   │     │  │  │     └─ debug
   │     │  │  │        └─ generateDebugRFile
   │     │  │  │           └─ package-aware-r.txt
   │     │  │  ├─ outputs
   │     │  │  │  ├─ aar
   │     │  │  │  │  └─ flutter_local_notifications-debug.aar
   │     │  │  │  └─ logs
   │     │  │  │     └─ manifest-merger-debug-report.txt
   │     │  │  └─ tmp
   │     │  │     └─ compileDebugJavaWithJavac
   │     │  │        └─ previous-compilation-data.bin
   │     │  ├─ native_assets
   │     │  │  └─ android
   │     │  └─ reports
   │     │     └─ problems
   │     │        └─ problems-report.html
   │     ├─ firestore
   │     │  └─ rule.txt
   │     ├─ ios
   │     │  ├─ Flutter
   │     │  │  ├─ AppFrameworkInfo.plist
   │     │  │  ├─ Debug.xcconfig
   │     │  │  ├─ ephemeral
   │     │  │  │  ├─ flutter_lldbinit
   │     │  │  │  └─ flutter_lldb_helper.py
   │     │  │  ├─ flutter_export_environment.sh
   │     │  │  ├─ Generated.xcconfig
   │     │  │  └─ Release.xcconfig
   │     │  ├─ Runner
   │     │  │  ├─ AppDelegate.swift
   │     │  │  ├─ Assets.xcassets
   │     │  │  │  ├─ AppIcon.appiconset
   │     │  │  │  │  ├─ Contents.json
   │     │  │  │  │  ├─ Icon-App-1024x1024@1x.png
   │     │  │  │  │  ├─ Icon-App-20x20@1x.png
   │     │  │  │  │  ├─ Icon-App-20x20@2x.png
   │     │  │  │  │  ├─ Icon-App-20x20@3x.png
   │     │  │  │  │  ├─ Icon-App-29x29@1x.png
   │     │  │  │  │  ├─ Icon-App-29x29@2x.png
   │     │  │  │  │  ├─ Icon-App-29x29@3x.png
   │     │  │  │  │  ├─ Icon-App-40x40@1x.png
   │     │  │  │  │  ├─ Icon-App-40x40@2x.png
   │     │  │  │  │  ├─ Icon-App-40x40@3x.png
   │     │  │  │  │  ├─ Icon-App-60x60@2x.png
   │     │  │  │  │  ├─ Icon-App-60x60@3x.png
   │     │  │  │  │  ├─ Icon-App-76x76@1x.png
   │     │  │  │  │  ├─ Icon-App-76x76@2x.png
   │     │  │  │  │  └─ Icon-App-83.5x83.5@2x.png
   │     │  │  │  └─ LaunchImage.imageset
   │     │  │  │     ├─ Contents.json
   │     │  │  │     ├─ LaunchImage.png
   │     │  │  │     ├─ LaunchImage@2x.png
   │     │  │  │     ├─ LaunchImage@3x.png
   │     │  │  │     └─ README.md
   │     │  │  ├─ Base.lproj
   │     │  │  │  ├─ LaunchScreen.storyboard
   │     │  │  │  └─ Main.storyboard
   │     │  │  ├─ GeneratedPluginRegistrant.h
   │     │  │  ├─ GeneratedPluginRegistrant.m
   │     │  │  ├─ Info.plist
   │     │  │  └─ Runner-Bridging-Header.h
   │     │  ├─ Runner.xcodeproj
   │     │  │  ├─ project.pbxproj
   │     │  │  ├─ project.xcworkspace
   │     │  │  │  ├─ contents.xcworkspacedata
   │     │  │  │  └─ xcshareddata
   │     │  │  │     ├─ IDEWorkspaceChecks.plist
   │     │  │  │     └─ WorkspaceSettings.xcsettings
   │     │  │  └─ xcshareddata
   │     │  │     └─ xcschemes
   │     │  │        └─ Runner.xcscheme
   │     │  ├─ Runner.xcworkspace
   │     │  │  ├─ contents.xcworkspacedata
   │     │  │  └─ xcshareddata
   │     │  │     ├─ IDEWorkspaceChecks.plist
   │     │  │     └─ WorkspaceSettings.xcsettings
   │     │  └─ RunnerTests
   │     │     └─ RunnerTests.swift
   │     ├─ lib
   │     │  ├─ backend
   │     │  │  └─ services
   │     │  │     ├─ auth_service.dart
   │     │  │     ├─ messaging_service.dart
   │     │  │     └─ notification_service.dart
   │     │  ├─ frontend
   │     │  │  ├─ main_screens
   │     │  │  │  ├─ ai_screen.dart
   │     │  │  │  ├─ home_screen.dart
   │     │  │  │  ├─ profile_screen.dart
   │     │  │  │  └─ search_screen.dart
   │     │  │  └─ pages
   │     │  │     ├─ forgot_password_page.dart
   │     │  │     ├─ home_page.dart
   │     │  │     ├─ login_page.dart
   │     │  │     └─ signup_page.dart
   │     │  └─ main.dart
   │     ├─ linux
   │     │  ├─ CMakeLists.txt
   │     │  ├─ flutter
   │     │  │  ├─ CMakeLists.txt
   │     │  │  ├─ generated_plugins.cmake
   │     │  │  ├─ generated_plugin_registrant.cc
   │     │  │  └─ generated_plugin_registrant.h
   │     │  └─ runner
   │     │     ├─ CMakeLists.txt
   │     │     ├─ main.cc
   │     │     ├─ my_application.cc
   │     │     └─ my_application.h
   │     ├─ macos
   │     │  ├─ Flutter
   │     │  │  ├─ ephemeral
   │     │  │  │  ├─ Flutter-Generated.xcconfig
   │     │  │  │  └─ flutter_export_environment.sh
   │     │  │  ├─ Flutter-Debug.xcconfig
   │     │  │  ├─ Flutter-Release.xcconfig
   │     │  │  └─ GeneratedPluginRegistrant.swift
   │     │  ├─ Runner
   │     │  │  ├─ AppDelegate.swift
   │     │  │  ├─ Assets.xcassets
   │     │  │  │  └─ AppIcon.appiconset
   │     │  │  │     ├─ app_icon_1024.png
   │     │  │  │     ├─ app_icon_128.png
   │     │  │  │     ├─ app_icon_16.png
   │     │  │  │     ├─ app_icon_256.png
   │     │  │  │     ├─ app_icon_32.png
   │     │  │  │     ├─ app_icon_512.png
   │     │  │  │     ├─ app_icon_64.png
   │     │  │  │     └─ Contents.json
   │     │  │  ├─ Base.lproj
   │     │  │  │  └─ MainMenu.xib
   │     │  │  ├─ Configs
   │     │  │  │  ├─ AppInfo.xcconfig
   │     │  │  │  ├─ Debug.xcconfig
   │     │  │  │  ├─ Release.xcconfig
   │     │  │  │  └─ Warnings.xcconfig
   │     │  │  ├─ DebugProfile.entitlements
   │     │  │  ├─ Info.plist
   │     │  │  ├─ MainFlutterWindow.swift
   │     │  │  └─ Release.entitlements
   │     │  ├─ Runner.xcodeproj
   │     │  │  ├─ project.pbxproj
   │     │  │  ├─ project.xcworkspace
   │     │  │  │  └─ xcshareddata
   │     │  │  │     └─ IDEWorkspaceChecks.plist
   │     │  │  └─ xcshareddata
   │     │  │     └─ xcschemes
   │     │  │        └─ Runner.xcscheme
   │     │  ├─ Runner.xcworkspace
   │     │  │  ├─ contents.xcworkspacedata
   │     │  │  └─ xcshareddata
   │     │  │     └─ IDEWorkspaceChecks.plist
   │     │  └─ RunnerTests
   │     │     └─ RunnerTests.swift
   │     ├─ pubspec.lock
   │     ├─ pubspec.yaml
   │     ├─ README.md
   │     ├─ test
   │     │  └─ widget_test.dart
   │     ├─ web
   │     │  ├─ favicon.png
   │     │  ├─ icons
   │     │  │  ├─ Icon-192.png
   │     │  │  ├─ Icon-512.png
   │     │  │  ├─ Icon-maskable-192.png
   │     │  │  └─ Icon-maskable-512.png
   │     │  ├─ index.html
   │     │  └─ manifest.json
   │     └─ windows
   │        ├─ CMakeLists.txt
   │        ├─ flutter
   │        │  ├─ CMakeLists.txt
   │        │  ├─ ephemeral
   │        │  │  └─ .plugin_symlinks
   │        │  │     ├─ cloud_firestore
   │        │  │     │  ├─ android
   │        │  │     │  │  ├─ .gradle
   │        │  │     │  │  │  ├─ 8.9
   │        │  │     │  │  │  │  ├─ checksums
   │        │  │     │  │  │  │  │  └─ checksums.lock
   │        │  │     │  │  │  │  ├─ fileChanges
   │        │  │     │  │  │  │  │  └─ last-build.bin
   │        │  │     │  │  │  │  ├─ fileHashes
   │        │  │     │  │  │  │  │  └─ fileHashes.lock
   │        │  │     │  │  │  │  ├─ gc.properties
   │        │  │     │  │  │  │  └─ vcsMetadata
   │        │  │     │  │  │  ├─ buildOutputCleanup
   │        │  │     │  │  │  │  ├─ buildOutputCleanup.lock
   │        │  │     │  │  │  │  └─ cache.properties
   │        │  │     │  │  │  └─ vcs-1
   │        │  │     │  │  │     └─ gc.properties
   │        │  │     │  │  ├─ build.gradle
   │        │  │     │  │  ├─ local-config.gradle
   │        │  │     │  │  ├─ settings.gradle
   │        │  │     │  │  ├─ src
   │        │  │     │  │  │  └─ main
   │        │  │     │  │  │     ├─ AndroidManifest.xml
   │        │  │     │  │  │     └─ java
   │        │  │     │  │  │        └─ io
   │        │  │     │  │  │           └─ flutter
   │        │  │     │  │  │              └─ plugins
   │        │  │     │  │  │                 └─ firebase
   │        │  │     │  │  │                    └─ firestore
   │        │  │     │  │  │                       ├─ FlutterFirebaseFirestoreException.java
   │        │  │     │  │  │                       ├─ FlutterFirebaseFirestoreExtension.java
   │        │  │     │  │  │                       ├─ FlutterFirebaseFirestoreMessageCodec.java
   │        │  │     │  │  │                       ├─ FlutterFirebaseFirestorePlugin.java
   │        │  │     │  │  │                       ├─ FlutterFirebaseFirestoreRegistrar.java
   │        │  │     │  │  │                       ├─ FlutterFirebaseFirestoreTransactionResult.java
   │        │  │     │  │  │                       ├─ GeneratedAndroidFirebaseFirestore.java
   │        │  │     │  │  │                       ├─ streamhandler
   │        │  │     │  │  │                       │  ├─ DocumentSnapshotsStreamHandler.java
   │        │  │     │  │  │                       │  ├─ LoadBundleStreamHandler.java
   │        │  │     │  │  │                       │  ├─ OnTransactionResultListener.java
   │        │  │     │  │  │                       │  ├─ QuerySnapshotsStreamHandler.java
   │        │  │     │  │  │                       │  ├─ SnapshotsInSyncStreamHandler.java
   │        │  │     │  │  │                       │  └─ TransactionStreamHandler.java
   │        │  │     │  │  │                       └─ utils
   │        │  │     │  │  │                          ├─ ExceptionConverter.java
   │        │  │     │  │  │                          ├─ PigeonParser.java
   │        │  │     │  │  │                          └─ ServerTimestampBehaviorConverter.java
   │        │  │     │  │  └─ user-agent.gradle
   │        │  │     │  ├─ CHANGELOG.md
   │        │  │     │  ├─ dartpad
   │        │  │     │  │  ├─ dartpad_metadata.yaml
   │        │  │     │  │  └─ lib
   │        │  │     │  │     └─ main.dart
   │        │  │     │  ├─ example
   │        │  │     │  │  ├─ analysis_options.yaml
   │        │  │     │  │  ├─ android
   │        │  │     │  │  │  ├─ app
   │        │  │     │  │  │  │  ├─ build.gradle
   │        │  │     │  │  │  │  ├─ google-services.json
   │        │  │     │  │  │  │  └─ src
   │        │  │     │  │  │  │     ├─ debug
   │        │  │     │  │  │  │     │  └─ AndroidManifest.xml
   │        │  │     │  │  │  │     ├─ main
   │        │  │     │  │  │  │     │  ├─ AndroidManifest.xml
   │        │  │     │  │  │  │     │  ├─ java
   │        │  │     │  │  │  │     │  │  └─ io
   │        │  │     │  │  │  │     │  │     └─ flutter
   │        │  │     │  │  │  │     │  │        └─ plugins
   │        │  │     │  │  │  │     │  ├─ kotlin
   │        │  │     │  │  │  │     │  │  └─ io
   │        │  │     │  │  │  │     │  │     └─ flutter
   │        │  │     │  │  │  │     │  │        └─ plugins
   │        │  │     │  │  │  │     │  │           └─ firebase
   │        │  │     │  │  │  │     │  │              └─ firestore
   │        │  │     │  │  │  │     │  │                 └─ example
   │        │  │     │  │  │  │     │  │                    └─ MainActivity.kt
   │        │  │     │  │  │  │     │  └─ res
   │        │  │     │  │  │  │     │     ├─ drawable
   │        │  │     │  │  │  │     │     │  └─ launch_background.xml
   │        │  │     │  │  │  │     │     ├─ drawable-v21
   │        │  │     │  │  │  │     │     │  └─ launch_background.xml
   │        │  │     │  │  │  │     │     ├─ mipmap-hdpi
   │        │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │        │  │     │  │  │  │     │     ├─ mipmap-mdpi
   │        │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │        │  │     │  │  │  │     │     ├─ mipmap-xhdpi
   │        │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │        │  │     │  │  │  │     │     ├─ mipmap-xxhdpi
   │        │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │        │  │     │  │  │  │     │     ├─ mipmap-xxxhdpi
   │        │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │        │  │     │  │  │  │     │     ├─ values
   │        │  │     │  │  │  │     │     │  └─ styles.xml
   │        │  │     │  │  │  │     │     └─ values-night
   │        │  │     │  │  │  │     │        └─ styles.xml
   │        │  │     │  │  │  │     └─ profile
   │        │  │     │  │  │  │        └─ AndroidManifest.xml
   │        │  │     │  │  │  ├─ build.gradle
   │        │  │     │  │  │  ├─ gradle
   │        │  │     │  │  │  │  └─ wrapper
   │        │  │     │  │  │  │     └─ gradle-wrapper.properties
   │        │  │     │  │  │  ├─ gradle.properties
   │        │  │     │  │  │  └─ settings.gradle
   │        │  │     │  │  ├─ firebase.json
   │        │  │     │  │  ├─ integration_test
   │        │  │     │  │  │  ├─ collection_reference_e2e.dart
   │        │  │     │  │  │  ├─ document_change_e2e.dart
   │        │  │     │  │  │  ├─ document_reference_e2e.dart
   │        │  │     │  │  │  ├─ e2e_test.dart
   │        │  │     │  │  │  ├─ field_value_e2e.dart
   │        │  │     │  │  │  ├─ firebase_options.dart
   │        │  │     │  │  │  ├─ firebase_options_secondary.dart
   │        │  │     │  │  │  ├─ geo_point_e2e.dart
   │        │  │     │  │  │  ├─ instance_e2e.dart
   │        │  │     │  │  │  ├─ load_bundle_e2e.dart
   │        │  │     │  │  │  ├─ query_e2e.dart
   │        │  │     │  │  │  ├─ second_database.dart
   │        │  │     │  │  │  ├─ settings_e2e.dart
   │        │  │     │  │  │  ├─ snapshot_metadata_e2e.dart
   │        │  │     │  │  │  ├─ timestamp_e2e.dart
   │        │  │     │  │  │  ├─ transaction_e2e.dart
   │        │  │     │  │  │  ├─ vector_value_e2e.dart
   │        │  │     │  │  │  ├─ web_snapshot_listeners.dart
   │        │  │     │  │  │  └─ write_batch_e2e.dart
   │        │  │     │  │  ├─ ios
   │        │  │     │  │  │  ├─ firebase_app_id_file.json
   │        │  │     │  │  │  ├─ Flutter
   │        │  │     │  │  │  │  ├─ AppFrameworkInfo.plist
   │        │  │     │  │  │  │  ├─ Debug.xcconfig
   │        │  │     │  │  │  │  └─ Release.xcconfig
   │        │  │     │  │  │  ├─ Podfile
   │        │  │     │  │  │  ├─ Runner
   │        │  │     │  │  │  │  ├─ AppDelegate.swift
   │        │  │     │  │  │  │  ├─ Assets.xcassets
   │        │  │     │  │  │  │  │  ├─ AppIcon.appiconset
   │        │  │     │  │  │  │  │  │  ├─ Contents.json
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-1024x1024@1x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@1x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@2x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@3x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@1x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@2x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@3x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@1x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@2x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@3x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-60x60@2x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-60x60@3x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-76x76@1x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-76x76@2x.png
   │        │  │     │  │  │  │  │  │  └─ Icon-App-83.5x83.5@2x.png
   │        │  │     │  │  │  │  │  └─ LaunchImage.imageset
   │        │  │     │  │  │  │  │     ├─ Contents.json
   │        │  │     │  │  │  │  │     ├─ LaunchImage.png
   │        │  │     │  │  │  │  │     ├─ LaunchImage@2x.png
   │        │  │     │  │  │  │  │     ├─ LaunchImage@3x.png
   │        │  │     │  │  │  │  │     └─ README.md
   │        │  │     │  │  │  │  ├─ Base.lproj
   │        │  │     │  │  │  │  │  ├─ LaunchScreen.storyboard
   │        │  │     │  │  │  │  │  └─ Main.storyboard
   │        │  │     │  │  │  │  ├─ GoogleService-Info.plist
   │        │  │     │  │  │  │  ├─ Info.plist
   │        │  │     │  │  │  │  └─ Runner-Bridging-Header.h
   │        │  │     │  │  │  ├─ Runner.xcodeproj
   │        │  │     │  │  │  │  ├─ project.pbxproj
   │        │  │     │  │  │  │  ├─ project.xcworkspace
   │        │  │     │  │  │  │  │  ├─ contents.xcworkspacedata
   │        │  │     │  │  │  │  │  └─ xcshareddata
   │        │  │     │  │  │  │  │     ├─ IDEWorkspaceChecks.plist
   │        │  │     │  │  │  │  │     ├─ swiftpm
   │        │  │     │  │  │  │  │     │  └─ configuration
   │        │  │     │  │  │  │  │     └─ WorkspaceSettings.xcsettings
   │        │  │     │  │  │  │  └─ xcshareddata
   │        │  │     │  │  │  │     └─ xcschemes
   │        │  │     │  │  │  │        └─ Runner.xcscheme
   │        │  │     │  │  │  └─ Runner.xcworkspace
   │        │  │     │  │  │     ├─ contents.xcworkspacedata
   │        │  │     │  │  │     └─ xcshareddata
   │        │  │     │  │  │        ├─ IDEWorkspaceChecks.plist
   │        │  │     │  │  │        ├─ swiftpm
   │        │  │     │  │  │        │  └─ configuration
   │        │  │     │  │  │        └─ WorkspaceSettings.xcsettings
   │        │  │     │  │  ├─ lib
   │        │  │     │  │  │  ├─ firebase_options.dart
   │        │  │     │  │  │  └─ main.dart
   │        │  │     │  │  ├─ macos
   │        │  │     │  │  │  ├─ firebase_app_id_file.json
   │        │  │     │  │  │  ├─ Flutter
   │        │  │     │  │  │  │  ├─ Flutter-Debug.xcconfig
   │        │  │     │  │  │  │  └─ Flutter-Release.xcconfig
   │        │  │     │  │  │  ├─ Podfile
   │        │  │     │  │  │  ├─ Runner
   │        │  │     │  │  │  │  ├─ AppDelegate.swift
   │        │  │     │  │  │  │  ├─ Assets.xcassets
   │        │  │     │  │  │  │  │  └─ AppIcon.appiconset
   │        │  │     │  │  │  │  │     ├─ app_icon_1024.png
   │        │  │     │  │  │  │  │     ├─ app_icon_128.png
   │        │  │     │  │  │  │  │     ├─ app_icon_16.png
   │        │  │     │  │  │  │  │     ├─ app_icon_256.png
   │        │  │     │  │  │  │  │     ├─ app_icon_32.png
   │        │  │     │  │  │  │  │     ├─ app_icon_512.png
   │        │  │     │  │  │  │  │     ├─ app_icon_64.png
   │        │  │     │  │  │  │  │     └─ Contents.json
   │        │  │     │  │  │  │  ├─ Base.lproj
   │        │  │     │  │  │  │  │  └─ MainMenu.xib
   │        │  │     │  │  │  │  ├─ Configs
   │        │  │     │  │  │  │  │  ├─ AppInfo.xcconfig
   │        │  │     │  │  │  │  │  ├─ Debug.xcconfig
   │        │  │     │  │  │  │  │  ├─ Release.xcconfig
   │        │  │     │  │  │  │  │  └─ Warnings.xcconfig
   │        │  │     │  │  │  │  ├─ DebugProfile.entitlements
   │        │  │     │  │  │  │  ├─ GoogleService-Info.plist
   │        │  │     │  │  │  │  ├─ Info.plist
   │        │  │     │  │  │  │  ├─ MainFlutterWindow.swift
   │        │  │     │  │  │  │  └─ Release.entitlements
   │        │  │     │  │  │  ├─ Runner.xcodeproj
   │        │  │     │  │  │  │  ├─ project.pbxproj
   │        │  │     │  │  │  │  ├─ project.xcworkspace
   │        │  │     │  │  │  │  │  └─ xcshareddata
   │        │  │     │  │  │  │  │     ├─ IDEWorkspaceChecks.plist
   │        │  │     │  │  │  │  │     └─ swiftpm
   │        │  │     │  │  │  │  │        └─ configuration
   │        │  │     │  │  │  │  └─ xcshareddata
   │        │  │     │  │  │  │     └─ xcschemes
   │        │  │     │  │  │  │        └─ Runner.xcscheme
   │        │  │     │  │  │  ├─ Runner.xcworkspace
   │        │  │     │  │  │  │  ├─ contents.xcworkspacedata
   │        │  │     │  │  │  │  └─ xcshareddata
   │        │  │     │  │  │  │     ├─ IDEWorkspaceChecks.plist
   │        │  │     │  │  │  │     └─ swiftpm
   │        │  │     │  │  │  │        └─ configuration
   │        │  │     │  │  │  └─ RunnerTests
   │        │  │     │  │  │     └─ RunnerTests.swift
   │        │  │     │  │  ├─ pubspec.yaml
   │        │  │     │  │  ├─ README.md
   │        │  │     │  │  ├─ test_driver
   │        │  │     │  │  │  └─ integration_test.dart
   │        │  │     │  │  ├─ web
   │        │  │     │  │  │  ├─ favicon.png
   │        │  │     │  │  │  ├─ icons
   │        │  │     │  │  │  │  ├─ Icon-192.png
   │        │  │     │  │  │  │  ├─ Icon-512.png
   │        │  │     │  │  │  │  ├─ Icon-maskable-192.png
   │        │  │     │  │  │  │  └─ Icon-maskable-512.png
   │        │  │     │  │  │  ├─ index.html
   │        │  │     │  │  │  ├─ manifest.json
   │        │  │     │  │  │  └─ wasm_index.html
   │        │  │     │  │  └─ windows
   │        │  │     │  │     ├─ CMakeLists.txt
   │        │  │     │  │     ├─ flutter
   │        │  │     │  │     │  └─ CMakeLists.txt
   │        │  │     │  │     └─ runner
   │        │  │     │  │        ├─ CMakeLists.txt
   │        │  │     │  │        ├─ flutter_window.cpp
   │        │  │     │  │        ├─ flutter_window.h
   │        │  │     │  │        ├─ main.cpp
   │        │  │     │  │        ├─ resource.h
   │        │  │     │  │        ├─ resources
   │        │  │     │  │        │  └─ app_icon.ico
   │        │  │     │  │        ├─ runner.exe.manifest
   │        │  │     │  │        ├─ Runner.rc
   │        │  │     │  │        ├─ utils.cpp
   │        │  │     │  │        ├─ utils.h
   │        │  │     │  │        ├─ win32_window.cpp
   │        │  │     │  │        └─ win32_window.h
   │        │  │     │  ├─ ios
   │        │  │     │  │  ├─ cloud_firestore
   │        │  │     │  │  │  ├─ Package.swift
   │        │  │     │  │  │  └─ Sources
   │        │  │     │  │  │     └─ cloud_firestore
   │        │  │     │  │  │        ├─ FirestoreMessages.g.m
   │        │  │     │  │  │        ├─ FirestorePigeonParser.m
   │        │  │     │  │  │        ├─ FLTDocumentSnapshotStreamHandler.m
   │        │  │     │  │  │        ├─ FLTFirebaseFirestoreExtension.m
   │        │  │     │  │  │        ├─ FLTFirebaseFirestorePlugin.m
   │        │  │     │  │  │        ├─ FLTFirebaseFirestoreReader.m
   │        │  │     │  │  │        ├─ FLTFirebaseFirestoreUtils.m
   │        │  │     │  │  │        ├─ FLTFirebaseFirestoreWriter.m
   │        │  │     │  │  │        ├─ FLTFirestoreClientLanguage.mm
   │        │  │     │  │  │        ├─ FLTLoadBundleStreamHandler.m
   │        │  │     │  │  │        ├─ FLTQuerySnapshotStreamHandler.m
   │        │  │     │  │  │        ├─ FLTSnapshotsInSyncStreamHandler.m
   │        │  │     │  │  │        ├─ FLTTransactionStreamHandler.m
   │        │  │     │  │  │        ├─ include
   │        │  │     │  │  │        │  └─ cloud_firestore
   │        │  │     │  │  │        │     ├─ Private
   │        │  │     │  │  │        │     │  ├─ FirestorePigeonParser.h
   │        │  │     │  │  │        │     │  ├─ FLTDocumentSnapshotStreamHandler.h
   │        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreExtension.h
   │        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreReader.h
   │        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreUtils.h
   │        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreWriter.h
   │        │  │     │  │  │        │     │  ├─ FLTLoadBundleStreamHandler.h
   │        │  │     │  │  │        │     │  ├─ FLTQuerySnapshotStreamHandler.h
   │        │  │     │  │  │        │     │  ├─ FLTSnapshotsInSyncStreamHandler.h
   │        │  │     │  │  │        │     │  └─ FLTTransactionStreamHandler.h
   │        │  │     │  │  │        │     └─ Public
   │        │  │     │  │  │        │        ├─ CustomPigeonHeaderFirestore.h
   │        │  │     │  │  │        │        ├─ FirestoreMessages.g.h
   │        │  │     │  │  │        │        └─ FLTFirebaseFirestorePlugin.h
   │        │  │     │  │  │        └─ Resources
   │        │  │     │  │  ├─ cloud_firestore.podspec
   │        │  │     │  │  └─ generated_firebase_sdk_version.txt
   │        │  │     │  ├─ lib
   │        │  │     │  │  ├─ cloud_firestore.dart
   │        │  │     │  │  └─ src
   │        │  │     │  │     ├─ aggregate_query.dart
   │        │  │     │  │     ├─ aggregate_query_snapshot.dart
   │        │  │     │  │     ├─ collection_reference.dart
   │        │  │     │  │     ├─ document_change.dart
   │        │  │     │  │     ├─ document_reference.dart
   │        │  │     │  │     ├─ document_snapshot.dart
   │        │  │     │  │     ├─ field_value.dart
   │        │  │     │  │     ├─ filters.dart
   │        │  │     │  │     ├─ firestore.dart
   │        │  │     │  │     ├─ load_bundle_task.dart
   │        │  │     │  │     ├─ load_bundle_task_snapshot.dart
   │        │  │     │  │     ├─ persistent_cache_index_manager.dart
   │        │  │     │  │     ├─ query.dart
   │        │  │     │  │     ├─ query_document_snapshot.dart
   │        │  │     │  │     ├─ query_snapshot.dart
   │        │  │     │  │     ├─ snapshot_metadata.dart
   │        │  │     │  │     ├─ transaction.dart
   │        │  │     │  │     ├─ utils
   │        │  │     │  │     │  └─ codec_utility.dart
   │        │  │     │  │     └─ write_batch.dart
   │        │  │     │  ├─ LICENSE
   │        │  │     │  ├─ macos
   │        │  │     │  │  ├─ cloud_firestore
   │        │  │     │  │  │  ├─ Package.swift
   │        │  │     │  │  │  └─ Sources
   │        │  │     │  │  │     └─ cloud_firestore
   │        │  │     │  │  │        ├─ FirestoreMessages.g.m
   │        │  │     │  │  │        ├─ FirestorePigeonParser.m
   │        │  │     │  │  │        ├─ FLTDocumentSnapshotStreamHandler.m
   │        │  │     │  │  │        ├─ FLTFirebaseFirestoreExtension.m
   │        │  │     │  │  │        ├─ FLTFirebaseFirestorePlugin.m
   │        │  │     │  │  │        ├─ FLTFirebaseFirestoreReader.m
   │        │  │     │  │  │        ├─ FLTFirebaseFirestoreUtils.m
   │        │  │     │  │  │        ├─ FLTFirebaseFirestoreWriter.m
   │        │  │     │  │  │        ├─ FLTLoadBundleStreamHandler.m
   │        │  │     │  │  │        ├─ FLTQuerySnapshotStreamHandler.m
   │        │  │     │  │  │        ├─ FLTSnapshotsInSyncStreamHandler.m
   │        │  │     │  │  │        ├─ FLTTransactionStreamHandler.m
   │        │  │     │  │  │        ├─ include
   │        │  │     │  │  │        │  └─ cloud_firestore
   │        │  │     │  │  │        │     ├─ Private
   │        │  │     │  │  │        │     │  ├─ FirestorePigeonParser.h
   │        │  │     │  │  │        │     │  ├─ FLTDocumentSnapshotStreamHandler.h
   │        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreExtension.h
   │        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreReader.h
   │        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreUtils.h
   │        │  │     │  │  │        │     │  ├─ FLTFirebaseFirestoreWriter.h
   │        │  │     │  │  │        │     │  ├─ FLTLoadBundleStreamHandler.h
   │        │  │     │  │  │        │     │  ├─ FLTQuerySnapshotStreamHandler.h
   │        │  │     │  │  │        │     │  ├─ FLTSnapshotsInSyncStreamHandler.h
   │        │  │     │  │  │        │     │  └─ FLTTransactionStreamHandler.h
   │        │  │     │  │  │        │     └─ Public
   │        │  │     │  │  │        │        ├─ CustomPigeonHeaderFirestore.h
   │        │  │     │  │  │        │        ├─ FirestoreMessages.g.h
   │        │  │     │  │  │        │        └─ FLTFirebaseFirestorePlugin.h
   │        │  │     │  │  │        └─ Resources
   │        │  │     │  │  └─ cloud_firestore.podspec
   │        │  │     │  ├─ pubspec.yaml
   │        │  │     │  ├─ README.md
   │        │  │     │  ├─ test
   │        │  │     │  │  ├─ cloud_firestore_test.dart
   │        │  │     │  │  ├─ collection_reference_test.dart
   │        │  │     │  │  ├─ field_value_test.dart
   │        │  │     │  │  ├─ mock.dart
   │        │  │     │  │  ├─ query_test.dart
   │        │  │     │  │  └─ test_firestore_message_codec.dart
   │        │  │     │  └─ windows
   │        │  │     │     ├─ cloud_firestore_plugin.cpp
   │        │  │     │     ├─ cloud_firestore_plugin.h
   │        │  │     │     ├─ cloud_firestore_plugin_c_api.cpp
   │        │  │     │     ├─ CMakeLists.txt
   │        │  │     │     ├─ firestore_codec.cpp
   │        │  │     │     ├─ firestore_codec.h
   │        │  │     │     ├─ include
   │        │  │     │     │  └─ cloud_firestore
   │        │  │     │     │     └─ cloud_firestore_plugin_c_api.h
   │        │  │     │     ├─ messages.g.cpp
   │        │  │     │     ├─ messages.g.h
   │        │  │     │     ├─ plugin_version.h.in
   │        │  │     │     └─ test
   │        │  │     │        └─ cloud_firestore_plugin_test.cpp
   │        │  │     ├─ firebase_auth
   │        │  │     │  ├─ android
   │        │  │     │  │  ├─ .gradle
   │        │  │     │  │  │  ├─ 8.4
   │        │  │     │  │  │  │  ├─ checksums
   │        │  │     │  │  │  │  │  └─ checksums.lock
   │        │  │     │  │  │  │  ├─ fileChanges
   │        │  │     │  │  │  │  │  └─ last-build.bin
   │        │  │     │  │  │  │  ├─ fileHashes
   │        │  │     │  │  │  │  │  └─ fileHashes.lock
   │        │  │     │  │  │  │  ├─ gc.properties
   │        │  │     │  │  │  │  └─ vcsMetadata
   │        │  │     │  │  │  └─ vcs-1
   │        │  │     │  │  │     └─ gc.properties
   │        │  │     │  │  ├─ build.gradle
   │        │  │     │  │  ├─ gradle
   │        │  │     │  │  │  └─ wrapper
   │        │  │     │  │  │     └─ gradle-wrapper.properties
   │        │  │     │  │  ├─ gradle.properties
   │        │  │     │  │  ├─ settings.gradle
   │        │  │     │  │  ├─ src
   │        │  │     │  │  │  └─ main
   │        │  │     │  │  │     ├─ AndroidManifest.xml
   │        │  │     │  │  │     └─ java
   │        │  │     │  │  │        └─ io
   │        │  │     │  │  │           └─ flutter
   │        │  │     │  │  │              └─ plugins
   │        │  │     │  │  │                 └─ firebase
   │        │  │     │  │  │                    └─ auth
   │        │  │     │  │  │                       ├─ AuthStateChannelStreamHandler.java
   │        │  │     │  │  │                       ├─ Constants.java
   │        │  │     │  │  │                       ├─ FlutterFirebaseAuthPlugin.java
   │        │  │     │  │  │                       ├─ FlutterFirebaseAuthPluginException.java
   │        │  │     │  │  │                       ├─ FlutterFirebaseAuthRegistrar.java
   │        │  │     │  │  │                       ├─ FlutterFirebaseAuthUser.java
   │        │  │     │  │  │                       ├─ FlutterFirebaseMultiFactor.java
   │        │  │     │  │  │                       ├─ FlutterFirebaseTotpMultiFactor.java
   │        │  │     │  │  │                       ├─ FlutterFirebaseTotpSecret.java
   │        │  │     │  │  │                       ├─ GeneratedAndroidFirebaseAuth.java
   │        │  │     │  │  │                       ├─ IdTokenChannelStreamHandler.java
   │        │  │     │  │  │                       ├─ PhoneNumberVerificationStreamHandler.java
   │        │  │     │  │  │                       └─ PigeonParser.java
   │        │  │     │  │  └─ user-agent.gradle
   │        │  │     │  ├─ CHANGELOG.md
   │        │  │     │  ├─ example
   │        │  │     │  │  ├─ analysis_options.yaml
   │        │  │     │  │  ├─ android
   │        │  │     │  │  │  ├─ app
   │        │  │     │  │  │  │  ├─ build.gradle
   │        │  │     │  │  │  │  ├─ google-services.json
   │        │  │     │  │  │  │  └─ src
   │        │  │     │  │  │  │     ├─ debug
   │        │  │     │  │  │  │     │  └─ AndroidManifest.xml
   │        │  │     │  │  │  │     ├─ main
   │        │  │     │  │  │  │     │  ├─ AndroidManifest.xml
   │        │  │     │  │  │  │     │  ├─ java
   │        │  │     │  │  │  │     │  │  └─ io
   │        │  │     │  │  │  │     │  │     └─ flutter
   │        │  │     │  │  │  │     │  │        └─ plugins
   │        │  │     │  │  │  │     │  ├─ kotlin
   │        │  │     │  │  │  │     │  │  └─ io
   │        │  │     │  │  │  │     │  │     └─ flutter
   │        │  │     │  │  │  │     │  │        └─ plugins
   │        │  │     │  │  │  │     │  │           └─ firebase
   │        │  │     │  │  │  │     │  │              └─ auth
   │        │  │     │  │  │  │     │  │                 └─ example
   │        │  │     │  │  │  │     │  │                    └─ MainActivity.kt
   │        │  │     │  │  │  │     │  └─ res
   │        │  │     │  │  │  │     │     ├─ drawable
   │        │  │     │  │  │  │     │     │  └─ launch_background.xml
   │        │  │     │  │  │  │     │     ├─ drawable-v21
   │        │  │     │  │  │  │     │     │  └─ launch_background.xml
   │        │  │     │  │  │  │     │     ├─ mipmap-hdpi
   │        │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │        │  │     │  │  │  │     │     ├─ mipmap-mdpi
   │        │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │        │  │     │  │  │  │     │     ├─ mipmap-xhdpi
   │        │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │        │  │     │  │  │  │     │     ├─ mipmap-xxhdpi
   │        │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │        │  │     │  │  │  │     │     ├─ mipmap-xxxhdpi
   │        │  │     │  │  │  │     │     │  └─ ic_launcher.png
   │        │  │     │  │  │  │     │     ├─ values
   │        │  │     │  │  │  │     │     │  └─ styles.xml
   │        │  │     │  │  │  │     │     └─ values-night
   │        │  │     │  │  │  │     │        └─ styles.xml
   │        │  │     │  │  │  │     └─ profile
   │        │  │     │  │  │  │        └─ AndroidManifest.xml
   │        │  │     │  │  │  ├─ build.gradle
   │        │  │     │  │  │  ├─ gradle
   │        │  │     │  │  │  │  └─ wrapper
   │        │  │     │  │  │  │     └─ gradle-wrapper.properties
   │        │  │     │  │  │  ├─ gradle.properties
   │        │  │     │  │  │  └─ settings.gradle
   │        │  │     │  │  ├─ ios
   │        │  │     │  │  │  ├─ firebase_app_id_file.json
   │        │  │     │  │  │  ├─ Flutter
   │        │  │     │  │  │  │  ├─ AppFrameworkInfo.plist
   │        │  │     │  │  │  │  ├─ Debug.xcconfig
   │        │  │     │  │  │  │  └─ Release.xcconfig
   │        │  │     │  │  │  ├─ Podfile
   │        │  │     │  │  │  ├─ Runner
   │        │  │     │  │  │  │  ├─ AppDelegate.h
   │        │  │     │  │  │  │  ├─ AppDelegate.m
   │        │  │     │  │  │  │  ├─ AppDelegate.swift
   │        │  │     │  │  │  │  ├─ Assets.xcassets
   │        │  │     │  │  │  │  │  ├─ AppIcon.appiconset
   │        │  │     │  │  │  │  │  │  ├─ Contents.json
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-1024x1024@1x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@1x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@2x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-20x20@3x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@1x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@2x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-29x29@3x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@1x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@2x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-40x40@3x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-60x60@2x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-60x60@3x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-76x76@1x.png
   │        │  │     │  │  │  │  │  │  ├─ Icon-App-76x76@2x.png
   │        │  │     │  │  │  │  │  │  └─ Icon-App-83.5x83.5@2x.png
   │        │  │     │  │  │  │  │  └─ LaunchImage.imageset
   │        │  │     │  │  │  │  │     ├─ Contents.json
   │        │  │     │  │  │  │  │     ├─ LaunchImage.png
   │        │  │     │  │  │  │  │     ├─ LaunchImage@2x.png
   │        │  │     │  │  │  │  │     ├─ LaunchImage@3x.png
   │        │  │     │  │  │  │  │     └─ README.md
   │        │  │     │  │  │  │  ├─ Base.lproj
   │        │  │     │  │  │  │  │  ├─ LaunchScreen.storyboard
   │        │  │     │  │  │  │  │  └─ Main.storyboard
   │        │  │     │  │  │  │  ├─ GoogleService-Info.plist
   │        │  │     │  │  │  │  ├─ Info.plist
   │        │  │     │  │  │  │  ├─ main.m
   │        │  │     │  │  │  │  ├─ Runner-Bridging-Header.h
   │        │  │     │  │  │  │  └─ Runner.entitlements
   │        │  │     │  │  │  ├─ Runner.xcodeproj
   │        │  │     │  │  │  │  ├─ project.pbxproj
   │        │  │     │  │  │  │  ├─ project.xcworkspace
   │        │  │     │  │  │  │  │  ├─ contents.xcworkspacedata
   │        │  │     │  │  │  │  │  └─ xcshareddata
   │        │  │     │  │  │  │  │     ├─ IDEWorkspaceChecks.plist
   │        │  │     │  │  │  │  │     ├─ swiftpm
   │        │  │     │  │  │  │  │     │  └─ configuration
   │        │  │     │  │  │  │  │     └─ WorkspaceSettings.xcsettings
   │        │  │     │  │  │  │  └─ xcshareddata
   │        │  │     │  │  │  │     └─ xcschemes
   │        │  │     │  │  │  │        └─ Runner.xcscheme
   │        │  │     │  │  │  └─ Runner.xcworkspace
   │        │  │     │  │  │     ├─ contents.xcworkspacedata
   │        │  │     │  │  │     └─ xcshareddata
   │        │  │     │  │  │        ├─ IDEWorkspaceChecks.plist
   │        │  │     │  │  │        ├─ swiftpm
   │        │  │     │  │  │        │  └─ configuration
   │        │  │     │  │  │        └─ WorkspaceSettings.xcsettings
   │        │  │     │  │  ├─ lib
   │        │  │     │  │  │  ├─ auth.dart
   │        │  │     │  │  │  ├─ firebase_options.dart
   │        │  │     │  │  │  ├─ main.dart
   │        │  │     │  │  │  └─ profile.dart
   │        │  │     │  │  ├─ macos
   │        │  │     │  │  │  ├─ firebase_app_id_file.json
   │        │  │     │  │  │  ├─ Flutter
   │        │  │     │  │  │  │  ├─ Flutter-Debug.xcconfig
   │        │  │     │  │  │  │  └─ Flutter-Release.xcconfig
   │        │  │     │  │  │  ├─ Podfile
   │        │  │     │  │  │  ├─ Runner
   │        │  │     │  │  │  │  ├─ AppDelegate.swift
   │        │  │     │  │  │  │  ├─ Assets.xcassets
   │        │  │     │  │  │  │  │  └─ AppIcon.appiconset
   │        │  │     │  │  │  │  │     ├─ app_icon_1024.png
   │        │  │     │  │  │  │  │     ├─ app_icon_128.png
   │        │  │     │  │  │  │  │     ├─ app_icon_16.png
   │        │  │     │  │  │  │  │     ├─ app_icon_256.png
   │        │  │     │  │  │  │  │     ├─ app_icon_32.png
   │        │  │     │  │  │  │  │     ├─ app_icon_512.png
   │        │  │     │  │  │  │  │     ├─ app_icon_64.png
   │        │  │     │  │  │  │  │     └─ Contents.json
   │        │  │     │  │  │  │  ├─ Base.lproj
   │        │  │     │  │  │  │  │  └─ MainMenu.xib
   │        │  │     │  │  │  │  ├─ Configs
   │        │  │     │  │  │  │  │  ├─ AppInfo.xcconfig
   │        │  │     │  │  │  │  │  ├─ Debug.xcconfig
   │        │  │     │  │  │  │  │  ├─ Release.xcconfig
   │        │  │     │  │  │  │  │  └─ Warnings.xcconfig
   │        │  │     │  │  │  │  ├─ DebugProfile.entitlements
   │        │  │     │  │  │  │  ├─ GoogleService-Info.plist
   │        │  │     │  │  │  │  ├─ Info.plist
   │        │  │     │  │  │  │  ├─ MainFlutterWindow.swift
   │        │  │     │  │  │  │  └─ Release.entitlements
   │        │  │     │  │  │  ├─ Runner.xcodeproj
   │        │  │     │  │  │  │  ├─ project.pbxproj
   │        │  │     │  │  │  │  ├─ project.xcworkspace
   │        │  │     │  │  │  │  │  ├─ contents.xcworkspacedata
   │        │  │     │  │  │  │  │  └─ xcshareddata
   │        │  │     │  │  │  │  │     └─ IDEWorkspaceChecks.plist
   │        │  │     │  │  │  │  └─ xcshareddata
   │        │  │     │  │  │  │     └─ xcschemes
   │        │  │     │  │  │  │        └─ Runner.xcscheme
   │        │  │     │  │  │  └─ Runner.xcworkspace
   │        │  │     │  │  │     ├─ contents.xcworkspacedata
   │        │  │     │  │  │     └─ xcshareddata
   │        │  │     │  │  │        ├─ IDEWorkspaceChecks.plist
   │        │  │     │  │  │        └─ WorkspaceSettings.xcsettings
   │        │  │     │  │  ├─ pubspec.yaml
   │        │  │     │  │  ├─ README.md
   │        │  │     │  │  ├─ web
   │        │  │     │  │  │  ├─ favicon.png
   │        │  │     │  │  │  ├─ icons
   │        │  │     │  │  │  │  ├─ Icon-192.png
   │        │  │     │  │  │  │  ├─ Icon-512.png
   │        │  │     │  │  │  │  ├─ Icon-maskable-192.png
   │        │  │     │  │  │  │  └─ Icon-maskable-512.png
   │        │  │     │  │  │  ├─ index.html
   │        │  │     │  │  │  └─ manifest.json
   │        │  │     │  │  └─ windows
   │        │  │     │  │     ├─ CMakeLists.txt
   │        │  │     │  │     ├─ flutter
   │        │  │     │  │     │  └─ CMakeLists.txt
   │        │  │     │  │     └─ runner
   │        │  │     │  │        ├─ CMakeLists.txt
   │        │  │     │  │        ├─ flutter_window.cpp
   │        │  │     │  │        ├─ flutter_window.h
   │        │  │     │  │        ├─ main.cpp
   │        │  │     │  │        ├─ resource.h
   │        │  │     │  │        ├─ resources
   │        │  │     │  │        │  └─ app_icon.ico
   │        │  │     │  │        ├─ runner.exe.manifest
   │        │  │     │  │        ├─ Runner.rc
   │        │  │     │  │        ├─ utils.cpp
   │        │  │     │  │        ├─ utils.h
   │        │  │     │  │        ├─ win32_window.cpp
   │        │  │     │  │        └─ win32_window.h
   │        │  │     │  ├─ ios
   │        │  │     │  │  ├─ firebase_auth
   │        │  │     │  │  │  ├─ Package.swift
   │        │  │     │  │  │  └─ Sources
   │        │  │     │  │  │     └─ firebase_auth
   │        │  │     │  │  │        ├─ firebase_auth_messages.g.m
   │        │  │     │  │  │        ├─ FLTAuthStateChannelStreamHandler.m
   │        │  │     │  │  │        ├─ FLTFirebaseAuthPlugin.m
   │        │  │     │  │  │        ├─ FLTIdTokenChannelStreamHandler.m
   │        │  │     │  │  │        ├─ FLTPhoneNumberVerificationStreamHandler.m
   │        │  │     │  │  │        ├─ include
   │        │  │     │  │  │        │  ├─ Private
   │        │  │     │  │  │        │  │  ├─ FLTAuthStateChannelStreamHandler.h
   │        │  │     │  │  │        │  │  ├─ FLTIdTokenChannelStreamHandler.h
   │        │  │     │  │  │        │  │  ├─ FLTPhoneNumberVerificationStreamHandler.h
   │        │  │     │  │  │        │  │  └─ PigeonParser.h
   │        │  │     │  │  │        │  └─ Public
   │        │  │     │  │  │        │     ├─ CustomPigeonHeader.h
   │        │  │     │  │  │        │     ├─ firebase_auth_messages.g.h
   │        │  │     │  │  │        │     └─ FLTFirebaseAuthPlugin.h
   │        │  │     │  │  │        ├─ PigeonParser.m
   │        │  │     │  │  │        └─ Resources
   │        │  │     │  │  ├─ firebase_auth.podspec
   │        │  │     │  │  └─ generated_firebase_sdk_version.txt
   │        │  │     │  ├─ lib
   │        │  │     │  │  ├─ firebase_auth.dart
   │        │  │     │  │  └─ src
   │        │  │     │  │     ├─ confirmation_result.dart
   │        │  │     │  │     ├─ firebase_auth.dart
   │        │  │     │  │     ├─ multi_factor.dart
   │        │  │     │  │     ├─ recaptcha_verifier.dart
   │        │  │     │  │     ├─ user.dart
   │        │  │     │  │     └─ user_credential.dart
   │        │  │     │  ├─ LICENSE
   │        │  │     │  ├─ macos
   │        │  │     │  │  ├─ firebase_auth
   │        │  │     │  │  │  ├─ Package.swift
   │        │  │     │  │  │  └─ Sources
   │        │  │     │  │  │     └─ firebase_auth
   │        │  │     │  │  │        ├─ firebase_auth_messages.g.m
   │        │  │     │  │  │        ├─ FLTAuthStateChannelStreamHandler.m
   │        │  │     │  │  │        ├─ FLTFirebaseAuthPlugin.m
   │        │  │     │  │  │        ├─ FLTIdTokenChannelStreamHandler.m
   │        │  │     │  │  │        ├─ FLTPhoneNumberVerificationStreamHandler.m
   │        │  │     │  │  │        ├─ include
   │        │  │     │  │  │        │  ├─ Private
   │        │  │     │  │  │        │  │  ├─ FLTAuthStateChannelStreamHandler.h
   │        │  │     │  │  │        │  │  ├─ FLTIdTokenChannelStreamHandler.h
   │        │  │     │  │  │        │  │  ├─ FLTPhoneNumberVerificationStreamHandler.h
   │        │  │     │  │  │        │  │  └─ PigeonParser.h
   │        │  │     │  │  │        │  └─ Public
   │        │  │     │  │  │        │     ├─ CustomPigeonHeader.h
   │        │  │     │  │  │        │     ├─ firebase_auth_messages.g.h
   │        │  │     │  │  │        │     └─ FLTFirebaseAuthPlugin.h
   │        │  │     │  │  │        ├─ PigeonParser.m
   │        │  │     │  │  │        └─ Resource
   │        │  │     │  │  └─ firebase_auth.podspec
   │        │  │     │  ├─ pubspec.yaml
   │        │  │     │  ├─ README.md
   │        │  │     │  ├─ test
   │        │  │     │  │  ├─ firebase_auth_test.dart
   │        │  │     │  │  ├─ mock.dart
   │        │  │     │  │  └─ user_test.dart
   │        │  │     │  └─ windows
   │        │  │     │     ├─ CMakeLists.txt
   │        │  │     │     ├─ firebase_auth_plugin.cpp
   │        │  │     │     ├─ firebase_auth_plugin.h
   │        │  │     │     ├─ firebase_auth_plugin_c_api.cpp
   │        │  │     │     ├─ include
   │        │  │     │     │  └─ firebase_auth
   │        │  │     │     │     └─ firebase_auth_plugin_c_api.h
   │        │  │     │     ├─ messages.g.cpp
   │        │  │     │     ├─ messages.g.h
   │        │  │     │     ├─ plugin_version.h.in
   │        │  │     │     └─ test
   │        │  │     │        └─ firebase_auth_plugin_test.cpp
   │        │  │     └─ firebase_core
   │        │  │        ├─ android
   │        │  │        │  ├─ .gradle
   │        │  │        │  │  ├─ 8.4
   │        │  │        │  │  │  ├─ checksums
   │        │  │        │  │  │  │  └─ checksums.lock
   │        │  │        │  │  │  ├─ fileChanges
   │        │  │        │  │  │  │  └─ last-build.bin
   │        │  │        │  │  │  ├─ fileHashes
   │        │  │        │  │  │  │  └─ fileHashes.lock
   │        │  │        │  │  │  ├─ gc.properties
   │        │  │        │  │  │  └─ vcsMetadata
   │        │  │        │  │  └─ vcs-1
   │        │  │        │  │     └─ gc.properties
   │        │  │        │  ├─ build.gradle
   │        │  │        │  ├─ gradle
   │        │  │        │  │  └─ wrapper
   │        │  │        │  │     └─ gradle-wrapper.properties
   │        │  │        │  ├─ gradle.properties
   │        │  │        │  ├─ local-config.gradle
   │        │  │        │  ├─ settings.gradle
   │        │  │        │  ├─ src
   │        │  │        │  │  └─ main
   │        │  │        │  │     ├─ AndroidManifest.xml
   │        │  │        │  │     └─ java
   │        │  │        │  │        └─ io
   │        │  │        │  │           └─ flutter
   │        │  │        │  │              └─ plugins
   │        │  │        │  │                 └─ firebase
   │        │  │        │  │                    └─ core
   │        │  │        │  │                       ├─ FlutterFirebaseCorePlugin.java
   │        │  │        │  │                       ├─ FlutterFirebaseCoreRegistrar.java
   │        │  │        │  │                       ├─ FlutterFirebasePlugin.java
   │        │  │        │  │                       ├─ FlutterFirebasePluginRegistry.java
   │        │  │        │  │                       └─ GeneratedAndroidFirebaseCore.java
   │        │  │        │  └─ user-agent.gradle
   │        │  │        ├─ CHANGELOG.md
   │        │  │        ├─ example
   │        │  │        │  ├─ analysis_options.yaml
   │        │  │        │  ├─ android
   │        │  │        │  │  ├─ app
   │        │  │        │  │  │  ├─ build.gradle
   │        │  │        │  │  │  ├─ google-services.json
   │        │  │        │  │  │  └─ src
   │        │  │        │  │  │     ├─ debug
   │        │  │        │  │  │     │  └─ AndroidManifest.xml
   │        │  │        │  │  │     ├─ main
   │        │  │        │  │  │     │  ├─ AndroidManifest.xml
   │        │  │        │  │  │     │  ├─ java
   │        │  │        │  │  │     │  │  └─ io
   │        │  │        │  │  │     │  │     └─ flutter
   │        │  │        │  │  │     │  │        └─ plugins
   │        │  │        │  │  │     │  ├─ kotlin
   │        │  │        │  │  │     │  │  └─ io
   │        │  │        │  │  │     │  │     └─ flutter
   │        │  │        │  │  │     │  │        └─ plugins
   │        │  │        │  │  │     │  │           └─ firebasecoreexample
   │        │  │        │  │  │     │  │              └─ MainActivity.kt
   │        │  │        │  │  │     │  └─ res
   │        │  │        │  │  │     │     ├─ drawable
   │        │  │        │  │  │     │     │  └─ launch_background.xml
   │        │  │        │  │  │     │     ├─ drawable-v21
   │        │  │        │  │  │     │     │  └─ launch_background.xml
   │        │  │        │  │  │     │     ├─ mipmap-hdpi
   │        │  │        │  │  │     │     │  └─ ic_launcher.png
   │        │  │        │  │  │     │     ├─ mipmap-mdpi
   │        │  │        │  │  │     │     │  └─ ic_launcher.png
   │        │  │        │  │  │     │     ├─ mipmap-xhdpi
   │        │  │        │  │  │     │     │  └─ ic_launcher.png
   │        │  │        │  │  │     │     ├─ mipmap-xxhdpi
   │        │  │        │  │  │     │     │  └─ ic_launcher.png
   │        │  │        │  │  │     │     ├─ mipmap-xxxhdpi
   │        │  │        │  │  │     │     │  └─ ic_launcher.png
   │        │  │        │  │  │     │     ├─ values
   │        │  │        │  │  │     │     │  └─ styles.xml
   │        │  │        │  │  │     │     └─ values-night
   │        │  │        │  │  │     │        └─ styles.xml
   │        │  │        │  │  │     └─ profile
   │        │  │        │  │  │        └─ AndroidManifest.xml
   │        │  │        │  │  ├─ build.gradle
   │        │  │        │  │  ├─ gradle
   │        │  │        │  │  │  └─ wrapper
   │        │  │        │  │  │     └─ gradle-wrapper.properties
   │        │  │        │  │  ├─ gradle.properties
   │        │  │        │  │  └─ settings.gradle
   │        │  │        │  ├─ ios
   │        │  │        │  │  ├─ Flutter
   │        │  │        │  │  │  ├─ AppFrameworkInfo.plist
   │        │  │        │  │  │  ├─ Debug.xcconfig
   │        │  │        │  │  │  └─ Release.xcconfig
   │        │  │        │  │  ├─ Podfile
   │        │  │        │  │  ├─ Runner
   │        │  │        │  │  │  ├─ AppDelegate.h
   │        │  │        │  │  │  ├─ AppDelegate.m
   │        │  │        │  │  │  ├─ Assets.xcassets
   │        │  │        │  │  │  │  ├─ AppIcon.appiconset
   │        │  │        │  │  │  │  │  ├─ Contents.json
   │        │  │        │  │  │  │  │  ├─ Icon-App-1024x1024@1x.png
   │        │  │        │  │  │  │  │  ├─ Icon-App-20x20@1x.png
   │        │  │        │  │  │  │  │  ├─ Icon-App-20x20@2x.png
   │        │  │        │  │  │  │  │  ├─ Icon-App-20x20@3x.png
   │        │  │        │  │  │  │  │  ├─ Icon-App-29x29@1x.png
   │        │  │        │  │  │  │  │  ├─ Icon-App-29x29@2x.png
   │        │  │        │  │  │  │  │  ├─ Icon-App-29x29@3x.png
   │        │  │        │  │  │  │  │  ├─ Icon-App-40x40@1x.png
   │        │  │        │  │  │  │  │  ├─ Icon-App-40x40@2x.png
   │        │  │        │  │  │  │  │  ├─ Icon-App-40x40@3x.png
   │        │  │        │  │  │  │  │  ├─ Icon-App-60x60@2x.png
   │        │  │        │  │  │  │  │  ├─ Icon-App-60x60@3x.png
   │        │  │        │  │  │  │  │  ├─ Icon-App-76x76@1x.png
   │        │  │        │  │  │  │  │  ├─ Icon-App-76x76@2x.png
   │        │  │        │  │  │  │  │  └─ Icon-App-83.5x83.5@2x.png
   │        │  │        │  │  │  │  └─ LaunchImage.imageset
   │        │  │        │  │  │  │     ├─ Contents.json
   │        │  │        │  │  │  │     ├─ LaunchImage.png
   │        │  │        │  │  │  │     ├─ LaunchImage@2x.png
   │        │  │        │  │  │  │     ├─ LaunchImage@3x.png
   │        │  │        │  │  │  │     └─ README.md
   │        │  │        │  │  │  ├─ Base.lproj
   │        │  │        │  │  │  │  ├─ LaunchScreen.storyboard
   │        │  │        │  │  │  │  └─ Main.storyboard
   │        │  │        │  │  │  ├─ Info.plist
   │        │  │        │  │  │  └─ main.m
   │        │  │        │  │  ├─ Runner.xcodeproj
   │        │  │        │  │  │  ├─ project.pbxproj
   │        │  │        │  │  │  ├─ project.xcworkspace
   │        │  │        │  │  │  │  ├─ contents.xcworkspacedata
   │        │  │        │  │  │  │  └─ xcshareddata
   │        │  │        │  │  │  │     └─ IDEWorkspaceChecks.plist
   │        │  │        │  │  │  └─ xcshareddata
   │        │  │        │  │  │     └─ xcschemes
   │        │  │        │  │  │        └─ Runner.xcscheme
   │        │  │        │  │  └─ Runner.xcworkspace
   │        │  │        │  │     ├─ contents.xcworkspacedata
   │        │  │        │  │     └─ xcshareddata
   │        │  │        │  │        └─ IDEWorkspaceChecks.plist
   │        │  │        │  ├─ lib
   │        │  │        │  │  ├─ firebase_options.dart
   │        │  │        │  │  └─ main.dart
   │        │  │        │  ├─ macos
   │        │  │        │  │  ├─ Flutter
   │        │  │        │  │  │  ├─ Flutter-Debug.xcconfig
   │        │  │        │  │  │  └─ Flutter-Release.xcconfig
   │        │  │        │  │  ├─ Podfile
   │        │  │        │  │  ├─ Runner
   │        │  │        │  │  │  ├─ AppDelegate.swift
   │        │  │        │  │  │  ├─ Assets.xcassets
   │        │  │        │  │  │  │  └─ AppIcon.appiconset
   │        │  │        │  │  │  │     ├─ app_icon_1024.png
   │        │  │        │  │  │  │     ├─ app_icon_128.png
   │        │  │        │  │  │  │     ├─ app_icon_16.png
   │        │  │        │  │  │  │     ├─ app_icon_256.png
   │        │  │        │  │  │  │     ├─ app_icon_32.png
   │        │  │        │  │  │  │     ├─ app_icon_512.png
   │        │  │        │  │  │  │     ├─ app_icon_64.png
   │        │  │        │  │  │  │     └─ Contents.json
   │        │  │        │  │  │  ├─ Base.lproj
   │        │  │        │  │  │  │  └─ MainMenu.xib
   │        │  │        │  │  │  ├─ Configs
   │        │  │        │  │  │  │  ├─ AppInfo.xcconfig
   │        │  │        │  │  │  │  ├─ Debug.xcconfig
   │        │  │        │  │  │  │  ├─ Release.xcconfig
   │        │  │        │  │  │  │  └─ Warnings.xcconfig
   │        │  │        │  │  │  ├─ DebugProfile.entitlements
   │        │  │        │  │  │  ├─ Info.plist
   │        │  │        │  │  │  ├─ MainFlutterWindow.swift
   │        │  │        │  │  │  └─ Release.entitlements
   │        │  │        │  │  ├─ Runner.xcodeproj
   │        │  │        │  │  │  ├─ project.pbxproj
   │        │  │        │  │  │  ├─ project.xcworkspace
   │        │  │        │  │  │  │  ├─ contents.xcworkspacedata
   │        │  │        │  │  │  │  └─ xcshareddata
   │        │  │        │  │  │  │     └─ IDEWorkspaceChecks.plist
   │        │  │        │  │  │  └─ xcshareddata
   │        │  │        │  │  │     └─ xcschemes
   │        │  │        │  │  │        └─ Runner.xcscheme
   │        │  │        │  │  └─ Runner.xcworkspace
   │        │  │        │  │     ├─ contents.xcworkspacedata
   │        │  │        │  │     └─ xcshareddata
   │        │  │        │  │        ├─ IDEWorkspaceChecks.plist
   │        │  │        │  │        └─ WorkspaceSettings.xcsettings
   │        │  │        │  ├─ pubspec.yaml
   │        │  │        │  ├─ README.md
   │        │  │        │  ├─ web
   │        │  │        │  │  ├─ favicon.png
   │        │  │        │  │  ├─ icons
   │        │  │        │  │  │  ├─ Icon-192.png
   │        │  │        │  │  │  ├─ Icon-512.png
   │        │  │        │  │  │  ├─ Icon-maskable-192.png
   │        │  │        │  │  │  └─ Icon-maskable-512.png
   │        │  │        │  │  ├─ index.html
   │        │  │        │  │  └─ manifest.json
   │        │  │        │  └─ windows
   │        │  │        │     ├─ CMakeLists.txt
   │        │  │        │     ├─ flutter
   │        │  │        │     │  └─ CMakeLists.txt
   │        │  │        │     └─ runner
   │        │  │        │        ├─ CMakeLists.txt
   │        │  │        │        ├─ flutter_window.cpp
   │        │  │        │        ├─ flutter_window.h
   │        │  │        │        ├─ main.cpp
   │        │  │        │        ├─ resource.h
   │        │  │        │        ├─ resources
   │        │  │        │        │  └─ app_icon.ico
   │        │  │        │        ├─ runner.exe.manifest
   │        │  │        │        ├─ Runner.rc
   │        │  │        │        ├─ utils.cpp
   │        │  │        │        ├─ utils.h
   │        │  │        │        ├─ win32_window.cpp
   │        │  │        │        └─ win32_window.h
   │        │  │        ├─ ios
   │        │  │        │  ├─ firebase_core
   │        │  │        │  │  ├─ Package.swift
   │        │  │        │  │  └─ Sources
   │        │  │        │  │     └─ firebase_core
   │        │  │        │  │        ├─ dummy.m
   │        │  │        │  │        ├─ FLTFirebaseCorePlugin.m
   │        │  │        │  │        ├─ FLTFirebasePlugin.m
   │        │  │        │  │        ├─ FLTFirebasePluginRegistry.m
   │        │  │        │  │        ├─ include
   │        │  │        │  │        │  └─ firebase_core
   │        │  │        │  │        │     ├─ dummy.h
   │        │  │        │  │        │     ├─ FLTFirebaseCorePlugin.h
   │        │  │        │  │        │     ├─ FLTFirebasePlugin.h
   │        │  │        │  │        │     ├─ FLTFirebasePluginRegistry.h
   │        │  │        │  │        │     └─ messages.g.h
   │        │  │        │  │        ├─ messages.g.m
   │        │  │        │  │        └─ Resources
   │        │  │        │  ├─ firebase_core.podspec
   │        │  │        │  └─ firebase_sdk_version.rb
   │        │  │        ├─ lib
   │        │  │        │  ├─ firebase_core.dart
   │        │  │        │  └─ src
   │        │  │        │     ├─ firebase.dart
   │        │  │        │     ├─ firebase_app.dart
   │        │  │        │     └─ port_mapping.dart
   │        │  │        ├─ LICENSE
   │        │  │        ├─ macos
   │        │  │        │  ├─ firebase_core
   │        │  │        │  │  ├─ Package.swift
   │        │  │        │  │  └─ Sources
   │        │  │        │  │     └─ firebase_core
   │        │  │        │  │        ├─ dummy.m
   │        │  │        │  │        ├─ FLTFirebaseCorePlugin.m
   │        │  │        │  │        ├─ FLTFirebasePlugin.m
   │        │  │        │  │        ├─ FLTFirebasePluginRegistry.m
   │        │  │        │  │        ├─ include
   │        │  │        │  │        │  ├─ dummy.h
   │        │  │        │  │        │  └─ firebase_core
   │        │  │        │  │        │     ├─ FLTFirebaseCorePlugin.h
   │        │  │        │  │        │     ├─ FLTFirebasePlugin.h
   │        │  │        │  │        │     ├─ FLTFirebasePluginRegistry.h
   │        │  │        │  │        │     └─ messages.g.h
   │        │  │        │  │        ├─ messages.g.m
   │        │  │        │  │        └─ Resources
   │        │  │        │  └─ firebase_core.podspec
   │        │  │        ├─ pubspec.yaml
   │        │  │        ├─ README.md
   │        │  │        ├─ test
   │        │  │        │  └─ firebase_core_test.dart
   │        │  │        └─ windows
   │        │  │           ├─ CMakeLists.txt
   │        │  │           ├─ firebase_core_plugin.cpp
   │        │  │           ├─ firebase_core_plugin.h
   │        │  │           ├─ firebase_core_plugin_c_api.cpp
   │        │  │           ├─ include
   │        │  │           │  └─ firebase_core
   │        │  │           │     └─ firebase_core_plugin_c_api.h
   │        │  │           ├─ messages.g.cpp
   │        │  │           ├─ messages.g.h
   │        │  │           └─ plugin_version.h.in
   │        │  ├─ generated_plugins.cmake
   │        │  ├─ generated_plugin_registrant.cc
   │        │  └─ generated_plugin_registrant.h
   │        └─ runner
   │           ├─ CMakeLists.txt
   │           ├─ flutter_window.cpp
   │           ├─ flutter_window.h
   │           ├─ main.cpp
   │           ├─ resource.h
   │           ├─ resources
   │           │  └─ app_icon.ico
   │           ├─ runner.exe.manifest
   │           ├─ Runner.rc
   │           ├─ utils.cpp
   │           ├─ utils.h
   │           ├─ win32_window.cpp
   │           └─ win32_window.h
   ├─ zc-login-admin
   │  ├─ admin.py
   │  ├─ zerocrow22a01-firebase-adminsdk-fbsvc-f4f939aa03.json
   │  └─ __pycache__
   │     └─ admin.cpython-314.pyc
   └─ zc-login-user
      ├─ example.py
      ├─ user_login.py
      ├─ zc.ico
      └─ __pycache__
         └─ user_login.cpython-314.pyc

```
