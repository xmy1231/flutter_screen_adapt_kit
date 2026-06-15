# flutter_screen_adapt_kit

A zero-code-invasion Flutter screen adaptation plugin for iOS, Android, and HarmonyOS.

## Features

- **Size Scaling**: Automatically scales your UI to fit any screen size
- **Safe Area**: Platform-aware notch/cutout handling (wide notch, dynamic island, hole punch, waterdrop)
- **Text Scaling**: Configurable text scale behavior (scale with UI, system only, or fixed)
- **Foldable Support**: Detect fold state (flat/half-opened), hinge position, and display cutouts
- **Zero Code Invasion**: Write raw design values, no `.w`/`.h` suffixes needed
- **Graceful Degradation**: All adapt APIs return `1.0` outside AdaptKit scope

## Usage

### 1. Initialize

No special binding required. Just use `WidgetsFlutterBinding.ensureInitialized()`.

### 2. Wrap your app

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    AdaptKit(
      designSize: Size(375, 812), // Your design spec
      child: MaterialApp(
        home: MyHomePage(),
      ),
    ),
  );
}
```

### 3. Use adapt APIs anywhere in your widget tree

```dart
// Get current scale ratio
final scale = context.adaptScale;

// Get adapted DPR
final dpr = context.adaptDpr;

// Get safe area insets
final safeTop = context.adaptSafeTop;
final safeBottom = context.adaptSafeBottom;

// Get notch info
final notchInfo = context.adaptNotchInfo;

// Get status bar and notch heights
final statusBar = context.statusBarHeight;  // Pure status bar (iOS: 24px, Android/HarmonyOS: 25px)
final notch = context.notchHeight;          // Notch area (total topInset - statusBar)

// Detect foldable state
final isFolded = context.isFolded;
final isFlat = context.isFlat;
final hingeBounds = context.adaptHingeBounds;
```

## Configuration

### AdaptKit Parameters

| Parameter                | Default               | Description                              |
| ------------------------ | --------------------- | ---------------------------------------- |
| `designSize`             | `Size(375, 812)`      | Your design specification                |
| `strategy`               | `AdaptStrategy.width` | Scaling strategy (width/height/min)      |
| `textBehavior`           | `TextBehavior.scale`  | Text scale behavior                      |
| `supportSystemTextScale` | `true`                | Whether to multiply by system font scale |
| `safeMode`               | `SafeMode.auto`       | Safe area handling mode                  |
| `classifier`             | `null`                | Platform-specific notch classifier       |

### Dynamic Updates

```dart
// At runtime
AdaptKit.of(context)?.setDesignSize(Size(430, 932));
AdaptKit.of(context)?.overrideNotch(NotchOverride(type: NotchType.wideNotch, topInset: 44));
AdaptKit.of(context)?.resetNotch();
```

<!-- ## Architecture

flutter_screen_adapt_kit works at the Flutter engine level by modifying `devicePixelRatio` and `ViewConfiguration`. Business code is completely unaware of screen adaptation.

## Platform Support

| Platform | Support |
|----------|---------|
| iOS | ✅ Dynamic Island, Wide Notch, Home Button, Foldable State |
| Android | ✅ Hole Punch, Waterdrop, Edge-to-Edge (15+), Foldable State |
| HarmonyOS | ✅ Hole Punch, Waterdrop, Wide Notch, Foldable State |

## Status Bar Thresholds

The `statusBarHeight` API uses platform-specific thresholds to estimate pure status bar height:

| Platform | Status Bar Threshold | Description |
|----------|---------------------|-------------|
| iOS | 24px | Traditional status bar height (non-notch devices) |
| Android | 25px | Standard status bar height |
| HarmonyOS | 25px | Standard status bar height |

The actual status bar height returned is `min(actualTopInset, threshold)`, and `notchHeight` is `max(0, actualTopInset - threshold)`. -->

## License

MIT
