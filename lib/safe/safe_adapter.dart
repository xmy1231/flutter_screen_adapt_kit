import 'package:flutter/widgets.dart';
import 'package:flutter_adapt_kit/safe/notch_classifier.dart';

enum SafeMode { auto, minimum, maximum, none }

class SafeAdapter extends StatelessWidget {
  final Widget child;
  final SafeMode mode;
  final NotchInfo notchInfo;

  const SafeAdapter({
    super.key,
    required this.child,
    this.mode = SafeMode.auto,
    this.notchInfo = NotchInfo.zero,
  });

  EdgeInsets _resolveInsets() {
    switch (mode) {
      case SafeMode.none:
        return EdgeInsets.zero;
      case SafeMode.minimum:
        return EdgeInsets.only(
          top: notchInfo.topInset,
          bottom: notchInfo.bottomInset,
        );
      case SafeMode.maximum:
        return notchInfo.insets;
      case SafeMode.auto:
        if (notchInfo.type == NotchType.none) return EdgeInsets.zero;
        return notchInfo.insets;
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = _resolveInsets();
    if (insets == EdgeInsets.zero) return child;
    return Padding(
      padding: insets,
      child: child,
    );
  }
}
