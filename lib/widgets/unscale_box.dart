import 'package:flutter/widgets.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';

enum UnscaleMode {
  full,
  context,
}

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
      UnscaleMode.context => MediaQuery.textScalerOf(context).scale(1.0),
    };
    final inverse = (uiScale == 0.0 || !uiScale.isFinite) ? 1.0 : 1.0 / uiScale;
    return Transform(
      transform: Matrix4.diagonal3Values(inverse, inverse, inverse),
      child: child,
    );
  }
}

extension UnscaleModeDocs on UnscaleMode {
  String get description {
    switch (this) {
      case UnscaleMode.full:
        return 'Uses AdaptKit computed UI scale. Preserves physical pixels across screen sizes.';
      case UnscaleMode.context:
        return 'Uses only system text scale factor from MediaQuery. Opts out of UI scaling but keeps text scaling.';
    }
  }
}