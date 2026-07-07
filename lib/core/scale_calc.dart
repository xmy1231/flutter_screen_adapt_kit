import 'package:flutter/widgets.dart';
import 'package:flutter_screen_adapt_kit/core/system_info.dart';

enum AdaptStrategy { width, height, min }

class ScaleResult {
  final double scale;
  final AdaptStrategy strategy;
  final Size designSize;
  final Size logicalSize;

  const ScaleResult({
    required this.scale,
    required this.strategy,
    required this.designSize,
    required this.logicalSize,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScaleResult &&
          scale == other.scale &&
          strategy == other.strategy &&
          designSize == other.designSize &&
          logicalSize == other.logicalSize;

  @override
  int get hashCode => Object.hash(scale, strategy, designSize, logicalSize);
}

class ScaleCalc {
  static ScaleResult compute(
    SystemInfo info,
    Size designSize,
    AdaptStrategy strategy,
  ) {
    final logicalSize = info.logicalSize;
    final scale = _calculateScale(logicalSize, designSize, strategy);
    return ScaleResult(
      scale: scale,
      strategy: strategy,
      designSize: designSize,
      logicalSize: logicalSize,
    );
  }

  static double _calculateScale(
    Size logicalSize,
    Size designSize,
    AdaptStrategy strategy,
  ) {
    switch (strategy) {
      case AdaptStrategy.width:
        if (designSize.width == 0 || logicalSize.width == 0) return 1.0;
        return logicalSize.width / designSize.width;
      case AdaptStrategy.height:
        if (designSize.height == 0 || logicalSize.height == 0) return 1.0;
        return logicalSize.height / designSize.height;
      case AdaptStrategy.min:
        final logicalMin =
            logicalSize.width < logicalSize.height
                ? logicalSize.width
                : logicalSize.height;
        final designMin =
            designSize.width < designSize.height
                ? designSize.width
                : designSize.height;
        if (logicalMin == 0 || designMin == 0) return 1.0;
        return logicalMin / designMin;
    }
  }
}
