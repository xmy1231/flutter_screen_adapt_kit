import 'package:flutter/material.dart';

class PhysicalPixelBox extends StatelessWidget {
  final Widget child;
  final double dpr;
  final Color color;
  final double width;

  const PhysicalPixelBox({
    super.key,
    required this.child,
    this.dpr = 3.0,
    this.color = const Color(0xFFE0E0E0),
    this.width = 1.0,
  }) : assert(width >= 0);

  double get _physicalWidth {
    if (width == 0) return 0;
    if (dpr == 0 || !dpr.isFinite) return 0;
    return width / dpr;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: color,
          width: _physicalWidth,
        ),
      ),
      child: child,
    );
  }
}
