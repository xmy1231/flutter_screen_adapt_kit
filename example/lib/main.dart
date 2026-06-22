import 'package:flutter/material.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';
import 'package:flutter_screen_adapt_kit/safe/android_classifier.dart';
import 'package:flutter_screen_adapt_kit/safe/ios_classifier.dart';
import 'package:flutter_screen_adapt_kit/safe/harmony_classifier.dart';
import 'app.dart';
import 'dart:io' show Platform;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdaptKitExampleApp());
}

class AdaptKitExampleApp extends StatelessWidget {
  const AdaptKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptKit(
      designSize: const Size(375, 812),
      classifier: _buildClassifier(),
      child: const MyApp(),
    );
  }

  static dynamic _buildClassifier() {
    final os = Platform.operatingSystem;
    if (os == 'harmony' || os == 'harmonyos' || os == 'HarmonyOS') {
      return const HarmonyOSNotchClassifier();
    }
    if (Platform.isIOS) return const IOSNotchClassifier();
    if (Platform.isAndroid) return const AndroidNotchClassifier();
    return null;
  }
}