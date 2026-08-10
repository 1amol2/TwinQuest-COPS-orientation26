# PairQuest — Flutter UI

A clean Flutter implementation of the supplied PairQuest mobile UI reference.

## Included screens

1. Home / landing
2. Waiting for pairing
3. Getting closer
4. Touch to match
5. Match result
6. Leaderboard
7. My Pair
8. Profile
9. How it works
10. Join Event
11. Nearby Pairs
12. Settings

## Folder structure

```text
pairquest_flutter/
├── assets/
│   └── images/
│       ├── hero_pair.png
│       └── puzzle_landscape.png
├── lib/
│   ├── core/
│   │   ├── app_colors.dart
│   │   ├── app_theme.dart
│   │   └── routes.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── pairing_screen.dart
│   │   ├── closer_screen.dart
│   │   ├── touch_match_screen.dart
│   │   ├── match_result_screen.dart
│   │   ├── leaderboard_screen.dart
│   │   ├── my_pair_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── how_it_works_screen.dart
│   │   ├── join_event_screen.dart
│   │   ├── nearby_pairs_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── app_button.dart
│   │   ├── app_card.dart
│   │   ├── app_header.dart
│   │   ├── avatar.dart
│   │   ├── bottom_nav.dart
│   │   ├── half_card.dart
│   │   ├── progress_row.dart
│   │   └── signal_rings.dart
│   └── main.dart
├── reference/
│   └── ui_reference.jpg
├── test/
│   └── widget_test.dart
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

## Run

Requires Flutter 3.x / Dart 3.x.

```bash
flutter pub get
flutter run
```

For a release Android APK:

```bash
flutter build apk --release
```

## Notes

- No third-party UI packages are required.
- The palette, spacing, rounded cards, buttons, signal rings, bottom navigation, and screen flow are implemented as reusable widgets.
- Two illustration assets are cropped from the user-supplied reference image to keep the visual language close to the source.
- Bluetooth, QR scanning, persistence, real pairing, and backend functionality are intentionally represented as UI interactions only.
