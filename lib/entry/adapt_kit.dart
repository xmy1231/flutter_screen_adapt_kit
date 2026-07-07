import 'dart:io' show Platform;
import 'package:flutter/widgets.dart';
import 'package:flutter_screen_adapt_kit/core/hot_reload_guard.dart';
import 'package:flutter_screen_adapt_kit/core/scale_calc.dart';
import 'package:flutter_screen_adapt_kit/core/status_bar_config.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';
import 'package:flutter_screen_adapt_kit/safe/android_classifier.dart';
import 'package:flutter_screen_adapt_kit/safe/harmony_classifier.dart';
import 'package:flutter_screen_adapt_kit/safe/ios_classifier.dart';
import 'package:flutter_screen_adapt_kit/safe/notch_classifier.dart';
import 'package:flutter_screen_adapt_kit/safe/safe_adapter.dart';
import 'package:flutter_screen_adapt_kit/text/text_scaler.dart';

class AdaptKit extends StatefulWidget {
  final Widget child;
  final Size designSize;
  final AdaptStrategy strategy;
  final TextBehavior textBehavior;
  final bool supportSystemTextScale;
  final SafeMode safeMode;
  final NotchClassifier? classifier;

  const AdaptKit({
    super.key,
    required this.child,
    this.designSize = const Size(375, 812),
    this.strategy = AdaptStrategy.width,
    this.textBehavior = TextBehavior.scale,
    this.supportSystemTextScale = true,
    this.safeMode = SafeMode.auto,
    this.classifier,
  });

  static AdaptKitState? of(BuildContext context) {
    return context.findAncestorStateOfType<AdaptKitState>();
  }

  @override
  State<AdaptKit> createState() => AdaptKitState();
}

class AdaptKitState extends State<AdaptKit> with WidgetsBindingObserver {
  ScaleResult? _result;
  SystemInfo? _info;
  NotchInfo? _notchInfo;
  bool _notchOverridden = false;

  late Size _designSize;
  late AdaptStrategy _strategy;
  late TextBehavior _textBehavior;
  late bool _supportSystemTextScale;

  ScaleResult get scaleResult => _result!;
  SystemInfo get info => _info!;
  NotchInfo get notchInfo => _notchInfo ?? NotchInfo.zero;
  double get scale => _result?.scale ?? 1.0;
  Size get designSize => _designSize;
  AdaptStrategy get strategy => _strategy;
  TextBehavior get textBehavior => _textBehavior;
  bool get supportSystemTextScale => _supportSystemTextScale;
  double get safeTop => (_notchInfo ?? NotchInfo.zero).topInset;
  double get safeBottom => (_notchInfo ?? NotchInfo.zero).bottomInset;

  NotchClassifier? get _defaultClassifier {
    final String os = Platform.operatingSystem;

    if (os == 'harmony' || os == 'harmonyos' || os == 'HarmonyOS') {
      return const HarmonyOSNotchClassifier();
    }
    if (Platform.isIOS) return const IOSNotchClassifier();
    if (Platform.isAndroid) return const AndroidNotchClassifier();

    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _designSize = widget.designSize;
    _strategy = widget.strategy;
    _textBehavior = widget.textBehavior;
    _supportSystemTextScale = widget.supportSystemTextScale;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_result == null && !HotReloadGuard.ensure()) _apply();
  }

  @override
  void didUpdateWidget(AdaptKit oldWidget) {
    super.didUpdateWidget(oldWidget);
    var needsReapply = false;
    if (widget.designSize != oldWidget.designSize) {
      _designSize = widget.designSize;
      needsReapply = true;
    }
    if (widget.strategy != oldWidget.strategy) {
      _strategy = widget.strategy;
      needsReapply = true;
    }
    if (widget.textBehavior != oldWidget.textBehavior) {
      _textBehavior = widget.textBehavior;
      needsReapply = true;
    }
    if (widget.supportSystemTextScale != oldWidget.supportSystemTextScale) {
      _supportSystemTextScale = widget.supportSystemTextScale;
      needsReapply = true;
    }
    if (!_notchOverridden && widget.classifier != oldWidget.classifier) {
      needsReapply = true;
    }
    if (needsReapply) _apply();
  }

  @override
  void didChangeMetrics() {
    _apply();
  }

  void setDesignSize(Size size, {AdaptStrategy? strategy}) {
    _designSize = size;
    if (strategy != null) _strategy = strategy;
    _apply();
  }

  void setStrategy(AdaptStrategy strategy) {
    _strategy = strategy;
    _apply();
  }

  void setTextBehavior(TextBehavior behavior) {
    _textBehavior = behavior;
    _apply();
  }

  void setSupportSystemTextScale(bool value) {
    _supportSystemTextScale = value;
    _apply();
  }

  void overrideNotch(NotchOverride override) {
    _notchOverridden = true;
    _notchInfo = NotchInfo(
      type: override.type,
      topInset: override.topInset,
      bottomInset: override.bottomInset,
      leftInset: override.leftInset,
      rightInset: override.rightInset,
      foldState: _info?.isFlat == true
          ? FoldState.flat
          : _info?.isFolded == true
              ? FoldState.halfOpened
              : FoldState.unknown,
      hingeBounds: _info?.hingeBounds,
      orientation: _info?.orientation,
    );
    _safeSetState(() {});
  }

  void resetNotch() {
    _notchOverridden = false;
    _apply();
  }

  void _safeSetState(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }

  void _apply() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final info = SystemInfo.fromFlutterView(view);
    final result = ScaleCalc.compute(info, _designSize, _strategy);

    NotchInfo? newNotchInfo;
    if (!_notchOverridden) {
      final effectiveClassifier = widget.classifier ?? _defaultClassifier;
      newNotchInfo = effectiveClassifier?.classify(info, orientation: info.orientation);
    } else {
      newNotchInfo = _notchInfo;
    }

    final bool needsUpdate = _result != result || _info != info || _notchInfo != newNotchInfo;

    if (needsUpdate) {
      setState(() {
        _result = result;
        _info = info;
        _notchInfo = newNotchInfo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_result == null && !HotReloadGuard.ensure()) {
      _apply();
    }

    final result = _result;
    final info = _info;
    if (result == null || info == null) return widget.child;

    final notchInfo = _notchInfo ?? NotchInfo.zero;
    final adaptedChild = _buildAdaptedChild(notchInfo);

    return _ScaleInherited(
      scaleResult: result,
      info: info,
      child: _NotchInherited(
        notchInfo: notchInfo,
        child: _TextInherited(
          textBehavior: _textBehavior,
          supportSystemTextScale: _supportSystemTextScale,
          child: adaptedChild,
        ),
      ),
    );
  }

  Widget _buildAdaptedChild(NotchInfo notchInfo) {
    final scale = _result?.scale ?? 1.0;
    final needsSafeAdapter = widget.classifier != null && notchInfo.type != NotchType.none;
    final needsTransform = (scale - 1.0).abs() > _kScaleThreshold;

    Widget child = widget.child;

    if (needsTransform) {
      child = ClipRect(
        child: Transform.scale(
          scale: scale,
          child: child,
        ),
      );
    }

    if (needsSafeAdapter) {
      return SafeAdapter(
        notchInfo: notchInfo,
        mode: widget.safeMode,
        child: child,
      );
    }
    return child;
  }
}

const double _kScaleThreshold = 0.0001;

class _ScaleInherited extends InheritedWidget {
  final ScaleResult scaleResult;
  final SystemInfo info;

  const _ScaleInherited({
    required this.scaleResult,
    required this.info,
    required super.child,
  });

  static _ScaleInherited? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ScaleInherited>();
  }

  @override
  bool updateShouldNotify(_ScaleInherited old) {
    return scaleResult != old.scaleResult || info != old.info;
  }
}

class _NotchInherited extends InheritedWidget {
  final NotchInfo notchInfo;

  const _NotchInherited({
    required this.notchInfo,
    required super.child,
  });

  static _NotchInherited? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_NotchInherited>();
  }

  @override
  bool updateShouldNotify(_NotchInherited old) {
    return notchInfo != old.notchInfo;
  }
}

class _TextInherited extends InheritedWidget {
  final TextBehavior textBehavior;
  final bool supportSystemTextScale;

  const _TextInherited({
    required this.textBehavior,
    required this.supportSystemTextScale,
    required super.child,
  });

  static _TextInherited? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_TextInherited>();
  }

  @override
  bool updateShouldNotify(_TextInherited old) {
    return textBehavior != old.textBehavior ||
        supportSystemTextScale != old.supportSystemTextScale;
  }
}

extension AdaptContext on BuildContext {
  ScaleResult? get adaptScaleResult => _ScaleInherited.of(this)?.scaleResult;
  SystemInfo? get adaptSystemInfo => _ScaleInherited.of(this)?.info;
  NotchInfo? get adaptNotchInfo => _NotchInherited.of(this)?.notchInfo;
  double get adaptScale => _ScaleInherited.of(this)?.scaleResult.scale ?? 1.0;
  double get adaptSafeTop => _NotchInherited.of(this)?.notchInfo.topInset ?? 0;
  double get adaptSafeBottom =>
      _NotchInherited.of(this)?.notchInfo.bottomInset ?? 0;
  double get adaptSafeLeft =>
      _NotchInherited.of(this)?.notchInfo.leftInset ?? 0;
  double get adaptSafeRight =>
      _NotchInherited.of(this)?.notchInfo.rightInset ?? 0;
  TextBehavior get adaptTextBehavior =>
      _TextInherited.of(this)?.textBehavior ?? TextBehavior.scale;
  bool get adaptSupportSystemTextScale =>
      _TextInherited.of(this)?.supportSystemTextScale ?? true;
  FoldState? get adaptFoldState =>
      _NotchInherited.of(this)?.notchInfo.foldState;
  Rect? get adaptHingeBounds =>
      _NotchInherited.of(this)?.notchInfo.hingeBounds;
  bool get isFolded => _ScaleInherited.of(this)?.info.isFolded ?? false;
  bool get isFlat => _ScaleInherited.of(this)?.info.isFlat ?? true;
  Orientation get adaptOrientation =>
      _ScaleInherited.of(this)?.info.orientation ?? Orientation.portrait;

  /// Height of the status bar area.
/// Returns the platform-specific threshold (e.g., 24pt on iOS, 25pt on Android)
/// if the top inset exceeds it, otherwise returns the raw top inset value.
/// Use this when you need the actual status bar height for layout calculations.
  double get statusBarHeight {
    final topInset = adaptSafeTop;
    final threshold = StatusBarConfig.currentPlatformThreshold;
    return topInset > threshold ? threshold : topInset;
  }

/// Height of the notch (刘海) area specifically.
/// Returns (topInset - statusBarThreshold) when topInset exceeds the threshold,
/// otherwise returns 0.
/// Use this when you need to know how much the notch extends beyond the status bar.
  double get notchHeight {
    final topInset = adaptSafeTop;
    final threshold = StatusBarConfig.currentPlatformThreshold;
    return topInset > threshold ? topInset - threshold : 0;
  }
}
