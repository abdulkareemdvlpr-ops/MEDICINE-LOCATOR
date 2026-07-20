# TRITEC Medicine Locator (Flutter + SQLite)

A fully offline mobile/desktop medicine inventory app built with Flutter and a local SQLite database. This is a conversion of the original Laravel web app into a simpler, installable app.

## Features

- Dashboard with stats, category breakdown, and cabinet breakdown
- Full CRUD for medicines and categories
- Storage location hierarchy: Cabinet → Rack → Drawer → Shelf → Box
- Category location inheritance (medicines inherit category defaults when blank)
- Search medicines by brand, generic name, or formula
- Filter medicines by category (including uncategorized)
- CSV / TXT import
- Bulk delete for medicines and categories
- Works 100% offline — no internet required

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.10 or newer
- Dart (comes with Flutter)
- Android Studio / Xcode (for mobile) or a desktop setup (for Windows/macOS/Linux)

## Run the app

1. Unzip the project.
2. Open a terminal in the `medicine_locator_flutter` folder.
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run:
   ```bash
   flutter run
   ```

If you are missing platform directories (android, ios, web, etc.), generate them first:

```bash
flutter create .
```

## Build for devices

```bash
# Android APK
flutter build apk

# Android app bundle
flutter build appbundle

# iOS (requires macOS + Xcode)
flutter build ios

# Windows / macOS / Linux desktop
flutter build windows
flutter build macos
flutter build linux
```

## Import file format

A simple CSV with a header row, for example:

```csv
brand_name,generic_name,formula,strength,manufacturer,category,cabinet,rack,drawer,shelf,box,quantity,notes
Panadol,Paracetamol,Paracetamol,500mg,SKF,Painkillers,C1,R2,D3,S4,B5,100,Keep dry
```

Header names are normalized (spaces become underscores, lowercase), so `Brand Name`, `brand_name`, or `brand` all work.

## Project structure

- `lib/main.dart` — app entry point
- `lib/models/` — `Medicine` and `Category` models
- `lib/database/` — SQLite helper with all CRUD operations
- `lib/screens/` — UI screens (dashboard, lists, forms, import)
- `lib/utils/csv_import.dart` — CSV import logic
- `pubspec.yaml` — dependencies (sqflite, file_picker, csv, intl)
