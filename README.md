# Elder Buddy

[![CI](https://github.com/shivanshmaurya/elder-buddy/actions/workflows/ci.yml/badge.svg)](https://github.com/shivanshmaurya/elder-buddy/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.3+-02569B?logo=flutter)](https://flutter.dev)

A Flutter mobile app designed for elderly users, featuring large contact tiles, high-contrast UI, and text-to-speech accessibility.

<!-- Add screenshots here -->
<!-- ![App Screenshot](screenshots/home.png) -->

## Features

- **Large Contact Tiles** - Easy-to-tap contacts displayed in a scrollable grid
- **High-Contrast Theme** - Clear, readable UI with large fonts optimized for visibility
- **Text-to-Speech** - Audio feedback for contact names and actions
- **Call Confirmation** - Prevents accidental calls with a confirmation screen
- **Contact Management** - Add contacts from your phone book, remove with long-press
- **Photo Support** - Custom photos for each contact
- **Persistent Storage** - Contacts are saved locally between sessions
- **Dark Mode** - Full dark theme support

## Screenshots

<!-- 
Add your screenshots to a `screenshots/` folder and uncomment below:

| Home Screen | Call Confirmation | Settings |
|-------------|-------------------|----------|
| ![Home](screenshots/home.png) | ![Call](screenshots/call.png) | ![Settings](screenshots/settings.png) |
-->

*Screenshots coming soon*

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.3.0 or higher)
- Android Studio or VS Code with Flutter extensions
- An Android device or emulator (API 21+)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/shivanshmaurya/elder-buddy.git
   cd elder-buddy
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Release

```bash
flutter build apk --release
```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`

## Usage

1. **Add a Contact** - Tap the "+" button to select a contact from your phone book
2. **Select Phone Number** - If the contact has multiple numbers, choose which one to use
3. **Make a Call** - Tap on any contact tile to initiate a call
4. **Confirm Call** - Review the contact details and confirm to proceed
5. **Remove Contact** - Long-press on a contact tile to remove it from the app
6. **Settings** - Access settings to customize TTS, theme, and more

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # MaterialApp configuration
├── core/
│   ├── theme/
│   │   └── app_theme.dart    # Light and dark theme definitions
│   ├── utils/
│   │   └── page_transitions.dart
│   └── widgets/
│       └── animated_press_button.dart
├── features/
│   ├── call/
│   │   ├── screens/
│   │   │   └── call_confirmation_screen.dart
│   │   └── services/
│   │       ├── direct_call_service.dart
│   │       └── tts_service.dart
│   ├── contacts/
│   │   ├── models/
│   │   │   └── contact_tile_model.dart
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   ├── widgets/
│   │   │   ├── add_contact_dialog.dart
│   │   │   ├── contact_picker_dialog.dart
│   │   │   ├── contact_tile.dart
│   │   │   └── phone_number_picker_dialog.dart
│   │   └── contact_picker_service.dart
│   └── settings/
│       └── screens/
│           └── settings_screen.dart
└── storage/
    ├── contact_storage_service.dart
    └── photo_storage_service.dart
```

## Permissions

### Android

The app requires the following permissions (configured in `AndroidManifest.xml`):

- `READ_CONTACTS` - Access phone contacts
- `CALL_PHONE` - Initiate phone calls

### iOS

Add the following to `Info.plist` for iOS support:

```xml
<key>NSContactsUsageDescription</key>
<string>This app needs access to contacts to display and call them.</string>
```

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting a pull request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Flutter](https://flutter.dev)
- Icons from [Material Design Icons](https://material.io/icons)
- Inspired by the need for accessible technology for elderly users

## Support

If you encounter any issues or have questions:

1. Check [existing issues](https://github.com/shivanshmaurya/elder-buddy/issues)
2. Create a [new issue](https://github.com/shivanshmaurya/elder-buddy/issues/new/choose)

---

Made with care for our elderly loved ones.
