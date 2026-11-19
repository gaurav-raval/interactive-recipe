# Interactive Recipe Book

A simple CRUD-based Flutter application (Mobile Computing - Practical 11, Mini Project).
Users can add, view, search, edit, delete and favourite recipes. Data is stored offline using SQLite.

## Features
- Splash screen
- Home page with recipe list and search
- Add recipe (name, ingredients, instructions, cooking time, image)
- Recipe details with favourite, edit and delete
- Favorites tab and Settings tab
- Offline storage with `sqflite`

## Run the project
This repo contains only the Dart source (`lib/`) and `pubspec.yaml`.
Generate the platform folders once, then run:

```bash
cd interactive_recipe_book
flutter create .          # creates android/, ios/ etc. (keeps lib/ and pubspec.yaml)
flutter pub get
flutter run
```

If the camera option is used on iOS, add `NSCameraUsageDescription` and
`NSPhotoLibraryUsageDescription` to `ios/Runner/Info.plist`. Android needs no extra setup.

## Build APK
```bash
flutter build apk --release
```
APK path: `build/app/outputs/flutter-apk/app-release.apk`

## Folder structure
```
lib/
  main.dart
  theme/app_theme.dart
  models/recipe.dart
  database/db_helper.dart
  widgets/recipe_card.dart, recipe_image.dart
  screens/splash_screen.dart, home_screen.dart, recipe_list_page.dart,
          recipe_details_screen.dart, add_edit_recipe_screen.dart, settings_page.dart
```
