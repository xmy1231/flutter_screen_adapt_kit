import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screen_adapt_kit/core/hot_reload_guard.dart';
import 'package:flutter_screen_adapt_kit/core/scale_calc.dart';
import 'package:flutter_screen_adapt_kit/core/scale_executor.dart';
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
  double get adaptedDpr => _result?.adaptedDpr ?? 1.0;
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

    if (!HotReloadGuard.ensure()) {
      _apply();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_result == null) _apply();
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

    final executor = ScaleExecutor();
    final config = executor.apply(result, info);
    // Apply to all render views managed by the binding (multi-view support).
    for (final view in RendererBinding.instance.renderViews) {
      view.configuration = config;
    }

    if (!_notchOverridden) {
      final effectiveClassifier = widget.classifier ?? _defaultClassifier;
      _notchInfo =
          effectiveClassifier?.classify(info, orientation: info.orientation);
    }

    setState(() {
      _result = result;
      _info = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final info = _info;
    if (result == null || info == null) return widget.child;

    final notchInfo = _notchInfo ?? NotchInfo.zero;
    final child = widget.classifier != null && notchInfo.type != NotchType.none
        ? SafeAdapter(
            notchInfo: notchInfo, mode: widget.safeMode, child: widget.child)
        : widget.child;

    return _AdaptInherited(
      scaleResult: result,
      info: info,
      notchInfo: notchInfo,
      textBehavior: _textBehavior,
      supportSystemTextScale: _supportSystemTextScale,
      child: child,
    );
  }
}

class _AdaptInherited extends InheritedWidget {
  final ScaleResult scaleResult;
  final SystemInfo info;
  final NotchInfo notchInfo;
  final TextBehavior textBehavior;
  final bool supportSystemTextScale;

  const _AdaptInherited({
    required this.scaleResult,
    required this.info,
    required this.notchInfo,
    required this.textBehavior,
    required this.supportSystemTextScale,
    required super.child,
  });

  static _AdaptInherited? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AdaptInherited>();
  }

  @override
  bool updateShouldNotify(_AdaptInherited old) {
    return scaleResult != old.scaleResult ||
        info != old.info ||
        notchInfo != old.notchInfo ||
        textBehavior != old.textBehavior ||
        supportSystemTextScale != old.supportSystemTextScale;
  }
}

extension AdaptContext on BuildContext {
  ScaleResult? get adaptScaleResult => _AdaptInherited.of(this)?.scaleResult;
  SystemInfo? get adaptSystemInfo => _AdaptInherited.of(this)?.info;
  NotchInfo? get adaptNotchInfo => _AdaptInherited.of(this)?.notchInfo;
  double get adaptScale => _AdaptInherited.of(this)?.scaleResult.scale ?? 1.0;
  double get adaptDpr =>
      _AdaptInherited.of(this)?.scaleResult.adaptedDpr ?? 1.0;
  double get adaptSafeTop => _AdaptInherited.of(this)?.notchInfo.topInset ?? 0;
  double get adaptSafeBottom =>
      _AdaptInherited.of(this)?.notchInfo.bottomInset ?? 0;
  double get adaptSafeLeft =>
      _AdaptInherited.of(this)?.notchInfo.leftInset ?? 0;
  double get adaptSafeRight =>
      _AdaptInherited.of(this)?.notchInfo.rightInset ?? 0;
  TextBehavior get adaptTextBehavior =>
      _AdaptInherited.of(this)?.textBehavior ?? TextBehavior.scale;
  bool get adaptSupportSystemTextScale =>
      _AdaptInherited.of(this)?.supportSystemTextScale ?? true;
  FoldState? get adaptFoldState =>
      _AdaptInherited.of(this)?.notchInfo.foldState;
  Rect? get adaptHingeBounds => _AdaptInherited.of(this)?.notchInfo.hingeBounds;
  bool get isFolded => _AdaptInherited.of(this)?.info.isFolded ?? false;
  bool get isFlat => _AdaptInherited.of(this)?.info.isFlat ?? true;
  Orientation get adaptOrientation =>
      _AdaptInherited.of(this)?.info.orientation ?? Orientation.portrait;

  double get statusBarHeight {
    final topInset = adaptSafeTop;
    final threshold = StatusBarConfig.currentPlatformThreshold;
    return topInset > threshold ? threshold : topInset;
  }

  double get notchHeight {
    final topInset = adaptSafeTop;
    final threshold = StatusBarConfig.currentPlatformThreshold;
    return topInset > threshold ? topInset - threshold : 0;
  }
}
