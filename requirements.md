# Easy Call - Elderly-Friendly Contacts App

## Project Overview
**Easy Call** is a Flutter mobile app designed for elderly users.  
It displays contacts in **large, high-contrast tiles** with photos and nicknames, enabling **simple calling** and interaction.

---

## 1. Features

### Core Features
1. Display contacts in **scrollable GridView** with **large tiles**.
2. **Add / Remove contact** from the list:
   - Always select from the current phone contacts.
   - If multiple numbers exist, allow the user to choose one.
3. **Dial contact** when tapping on a contact tile.
4. **High-contrast theme** with large font for readability.
5. **Text-to-Speech (TTS)** for accessibility.
6. **Call confirmation screen** to prevent accidental calls.
7. **Persistent storage** (optional) using `shared_preferences`.
8. Responsive layout for portrait and landscape modes.

### Optional / Future Features
- Contact photos with cropping (image_picker or custom UI)
- Favorites / frequently called contacts
- Voice commands integration
- Emergency contact quick dial
- Multi-language support

---

## 2. Dependencies

- **Flutter & Dart**
- **flutter_contacts** – for accessing phone contacts
- **url_launcher** – for dialing numbers
- **flutter_tts** – Text-to-Speech support
- **image_picker** – (optional) for contact photos
- **shared_preferences** – for storing app data persistently

> **Note:** Avoid `image_cropper` for now due to Android embedding issues.

---

## 3. Permissions (Android)

Add to `AndroidManifest.xml` **above `<application>`**:

```xml
<uses-permission android:name="android.permission.READ_CONTACTS"/>
```

## 4. Project Structure (Recommended)
```
lib/
├── main.dart
├── app.dart
├── core/
│   └── theme/
│       └── app_theme.dart
├── features/
│   ├── contacts/
│   │   ├── models/
│   │   │   └── contact_tile_model.dart
│   │   ├── widgets/
│   │   │   └── contact_tile.dart
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   └── contact_picker_service.dart
│   ├── calls/
│   │   └── call_confirmation_screen.dart
│   └── tts/
│       └── tts_service.dart
```

## 5. UI / UX Guidelines

Tile size: Large enough to tap easily (~80px radius for avatars, ~22pt font for nickname)

High contrast: Black text on white background or vice versa

Minimalist interface: Only essential buttons and icons

Accidental touches: Confirmation screens before calling

Text-to-Speech: Optional audio feedback for selections

## 6. Coding Guidelines

Follow SOLID principles and clean code

Prefer stateless widgets where possible

Handle nulls, denied permissions, empty lists

Use reusable widgets for contact tiles, dialogs, and screens

Maintain separate services for contact picker, TTS, and calls

Keep business logic separate from UI

## 7. Build / Run Instructions

Install Flutter SDK (latest stable)

Clone the repository

Run:
```
flutter clean
flutter pub get
flutter run
```

Tap + ADD CONTACT to pick a contact

Select a number (if multiple exist)

Tap contact to call (after confirmation screen)

## 8. AI / Developer Agent Guidelines

Suggest Flutter/Dart code snippets

Generate widgets, models, and services

Maintain consistent file structure

Focus on elderly-friendly UI

Handle permissions, nulls, and empty data gracefully

Suggest high-contrast colors and large fonts
