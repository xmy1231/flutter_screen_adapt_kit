enum TextBehavior { scale, system, fixed }

class TextScaleDecider {
  static double compute({
    required double uiScale,
    double systemTextScale = 1.0,
    TextBehavior behavior = TextBehavior.scale,
    bool supportSystemTextScale = true,
  }) {
    switch (behavior) {
      case TextBehavior.fixed:
        return 1.0;
      case TextBehavior.system:
        return systemTextScale;
      case TextBehavior.scale:
        if (supportSystemTextScale) {
          return uiScale * systemTextScale;
        }
        return uiScale;
    }
  }
}
