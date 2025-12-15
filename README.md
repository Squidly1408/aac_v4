# AAC v4

Augmentative and Alternative Communication (AAC) app built with Flutter. This project provides a fast, touch-friendly interface for constructing phrases, speaking aloud, and customizing tiles, categories, and quick actions across platforms.

## Overview

- Cross-platform Flutter app: Android, iOS, Web, Windows, macOS, Linux
- Core flows include: Speak, Keyboard, Quick access, Settings, Tile actions
- Persistence via `storage_service.dart` with local storage

## Features

- Phrase building with tile buttons and categories
- Quick screen for frequently used phrases
- On-screen keyboard input mode
- Speech output (via platform TTS plugins)
- Configurable tiles/categories and actions sheet
- Responsive layout optimized for touch

## Tech Stack

- Framework: Flutter
- Language: Dart
- Platforms: mobile, desktop, web (configured in `pubspec.yaml` and platform folders)

## Project Structure

```
lib/
	main.dart                   # App entry
	models/                     # Core data models (e.g., tile, phrase)
	screens/                    # UI screens (home shell, speak, keyboard, quick, settings)
	services/                   # App services (e.g., storage)
	state/                      # Controllers/state management
	widgets/                    # Reusable widgets (tile buttons, message strip)
android/, ios/, web/, windows/, macos/, linux/  # Platform folders
pubspec.yaml                  # Dependencies and assets
analysis_options.yaml         # Lints and static analysis
```

Key files of interest:

- `lib/screens/speak_screen.dart`: phrase construction and speech output
- `lib/screens/keyboard_screen.dart`: keyboard-based entry
- `lib/screens/quick_screen.dart`: quick access to common phrases
- `lib/screens/tile_actions_sheet.dart`: tile edit/actions UI
- `lib/services/storage_service.dart`: persistence layer
- `lib/state/app_controller.dart`: app-level state


## License

Copyright © 2025 Squidly1408 - Lucas Newman, All rights reserved.
Unauthorized use, copying, or distribution is prohibited.