# Project Branching & Contribution Guidelines

Welcome to the **dev branch** of this project.  
This branch is for **stable, verified code only**. Please read carefully before contributing.

---

## 🌟 Branch Purpose

- **`dev` branch**
  - Stores **stable and verified code**.
  - **Do NOT edit or push directly here.**
  - This branch is only for **cloning** to get a reliable version of the project.

- **Team branches**
  - **`frontend_dev`** → For frontend team’s final files.
  - **`backend_dev`** → For backend team’s final files.
  - Team members **create pull requests (PRs) to these branches** before merging into `dev`.

- **Personal branches**
  - Each developer should create their **own branch** for development.
  - Branch names **must start with your name** (e.g., `arkshayan_b01`).
  - You can create as many branches as needed for your tasks.
  - Branches not following this naming rule may be removed.

---

## 🚀 How to Work Safely

1. **Clone the stable dev branch:**

   ```bash
   git clone -b dev https://github.com/USERNAME/REPO_NAME.git

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

4. **Team contribution**
   - Frontend → PR to **`frontend_dev`**
   - Backend → PR to **`backend_dev`**

5. **Merging to dev:**
   - Only after team branch review (**`frontend_dev`** or **`backend_dev`**) are changes merged into **`dev`**.

---

## ⚠️ Important Rules

      - Never push directly to dev.

      - Follow branch naming rules for personal branches.

      - Use pull requests for team branches ('frontend_dev' or 'backend_dev').

      - Keep 'dev' stable - it should always be safe to clone.

---

## 📁 Project Structure

```bash
sdgp/                     # Project root
 ├── android/              # Android platform files
 │   ├── app/
 │   ├── gradle/           # ignored by .gitignore
 │   ├── build/            # ignored
 │   └── local.properties  # ignored
 ├── ios/                  # iOS platform files
 │   ├── Pods/             # ignored
 │   └── Runner.xcworkspace
 ├── lib/                  # Your main Flutter code (REQUIRED)
 │   ├── main.dart
 │   ├── home_screen.dart
 ├── assets/               # Optional, include images/fonts/etc.
 │   ├── images/
 │   └── fonts/
 ├── test/                 # Optional, for unit/widget tests
 │   └── main_test.dart
 ├── web/                  # Optional, for Flutter web
 ├── windows/              # Optional, for Windows desktop
 ├── macos/                # Optional, for MacOS desktop
 ├── linux/                # Optional, for Linux desktop
 ├── pubspec.yaml          # Required
 ├── pubspec.lock          # Recommended
 ├── .gitignore            # Required to ignore build files
 ├── README.md             # Required
 └── analysis_options.yaml # Optional
```
