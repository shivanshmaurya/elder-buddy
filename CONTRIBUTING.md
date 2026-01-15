# Contributing to Elder Buddy

Thank you for your interest in contributing to Elder Buddy! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.

## How to Contribute

### Reporting Bugs

Before creating a bug report, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title** describing the issue
- **Steps to reproduce** the behavior
- **Expected behavior** vs actual behavior
- **Screenshots** if applicable
- **Device information** (Android version, device model)
- **Flutter version** (`flutter --version`)

Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md) when creating issues.

### Suggesting Features

Feature requests are welcome! Please:

- Check existing issues and discussions first
- Describe the feature and its benefits
- Consider the elderly user focus of this app
- Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md)

### Pull Requests

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Make your changes** following our coding standards
5. **Test** your changes thoroughly
6. **Commit** with clear, descriptive messages
7. **Push** to your fork
8. **Open a Pull Request** against the `main` branch

## Development Setup

### Prerequisites

- Flutter SDK 3.3.0 or higher
- Dart SDK (included with Flutter)
- Android Studio or VS Code
- Git

### Getting Started

```bash
# Clone your fork
git clone https://github.com/shivanshmaurya/elder-buddy.git
cd elder-buddy

# Add upstream remote
git remote add upstream https://github.com/shivanshmaurya/elder-buddy.git

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run the app
flutter run
```

### Keeping Your Fork Updated

```bash
git fetch upstream
git checkout main
git merge upstream/main
```

## Coding Standards

### Dart/Flutter Guidelines

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` to check for issues
- Format code with `dart format .`
- Write meaningful comments for complex logic
- Prefer `const` constructors where possible

### Project Structure

Follow the existing feature-based structure:

```
lib/
├── core/           # Shared utilities, themes, widgets
├── features/       # Feature modules (contacts, call, settings)
└── storage/        # Data persistence services
```

### Accessibility Focus

This app is designed for elderly users. When contributing:

- Use large, readable fonts (minimum 18sp for body text)
- Ensure high contrast (WCAG AA minimum)
- Add TTS support for new interactive elements
- Include confirmation dialogs for destructive actions
- Keep UI simple and uncluttered
- Test with accessibility tools

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `camelCase` or `SCREAMING_SNAKE_CASE`

### Commit Messages

Write clear, concise commit messages:

```
feat: add voice command support for calling
fix: resolve contact photo not displaying on Android 12+
docs: update installation instructions
refactor: extract contact tile into separate widget
test: add unit tests for ContactStorageService
```

Prefixes:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `test:` - Test additions/changes
- `chore:` - Maintenance tasks

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Writing Tests

- Add tests for new features
- Maintain existing test coverage
- Use descriptive test names
- Mock external dependencies

## Review Process

1. All PRs require at least one review
2. CI checks must pass (linting, tests, build)
3. PRs should be focused and reasonably sized
4. Update documentation if needed
5. Add tests for new functionality

## Questions?

If you have questions about contributing:

1. Check existing [issues](https://github.com/shivanshmaurya/elder-buddy/issues)
2. Start a [discussion](https://github.com/shivanshmaurya/elder-buddy/discussions)
3. Reach out to maintainers

Thank you for helping make Elder Buddy better for elderly users!
