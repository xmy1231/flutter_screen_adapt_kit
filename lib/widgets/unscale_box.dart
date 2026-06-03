import 'package:flutter/widgets.dart';

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
    final contextScale = MediaQuery.textScalerOf(context).textScaleFactor;
    final uiScale = switch (mode) {
      UnscaleMode.full => dpr * 375 / designWidth,
      UnscaleMode.context => contextScale,
    };
    final inverse = uiScale == 0.0 ? 1.0 : 1.0 / uiScale;
    return Transform(
      transform: Matrix4.diagonal3Values(inverse, inverse, inverse),
      child: child,
    );
  }
}
