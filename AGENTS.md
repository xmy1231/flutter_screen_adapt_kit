# flutter_screen_adapt_kit

## Project Type
Single-package Flutter plugin for cross-platform screen adaptation.

## Standard Commands
- `flutter pub get` - Install dependencies
- `flutter analyze` - Run static analysis
- `flutter test` - Run all tests
- `flutter test test/<path>/<file>_test.dart` - Run specific test file

## Architecture
- Main entry: `lib/flutter_screen_adapt_kit.dart` (barrel file)
- Core adaptation logic: `lib/core/`
- Safe area handling & platform classifiers: `lib/safe/` (iOS, Android, HarmonyOS)
- Widgets: `lib/widgets/`
- Debug panel: `lib/debug/`

## Example App
Located in `example/` - depends on local plugin via path `../`. Run with `flutter run` from that directory.

## Testing
Tests mirror `lib/` structure in `test/`. Run full suite with `flutter test`.