import 'package:flutter/foundation.dart';

class StatusBarConfig {
  static const double iOS = 24.0;
  static const double android = 25.0;
  static const double harmonyOS = 25.0;

  static const double defaultThreshold = 25.0;

  static double forPlatform(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
        return iOS;
      case TargetPlatform.android:
        return android;
      default:
        return defaultThreshold;
    }
  }

  static double get currentPlatformThreshold =>
      forPlatform(defaultTargetPlatform);
}