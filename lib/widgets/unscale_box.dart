import 'package:flutter/widgets.dart';
import 'package:flutter_adapt_kit/entry/adapt_kit.dart';

enum UnscaleMode { full, context }

class UnscaleBox extends StatelessWidget {
  final double dpr;
  final double designWidth;
  final UnscaleMode mode;
  final Widget child;

  const UnscaleBox({
    super.key,
    required this.child,
    this.dpr = 3.0,
    this.designWidth = 375,
    this.mode = UnscaleMode.full,
  });

  @override
  Widget build(BuildContext context) {
    final adaptScale = context.adaptScaleResult?.scale;
    final uiScale = switch (mode) {
      UnscaleMode.full => adaptScale ?? (dpr * 375 / designWidth),
      UnscaleMode.context => MediaQuery.textScalerOf(context).textScaleFactor,
    };
    final inverse = uiScale == 0.0 ? 1.0 : 1.0 / uiScale;
    return Transform(
      transform: Matrix4.diagonal3Values(inverse, inverse, inverse),
      child: child,
    );
  }
}
