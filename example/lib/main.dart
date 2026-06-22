import 'package:flutter/material.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdaptKitExampleApp());
}

class AdaptKitExampleApp extends StatelessWidget {
  const AdaptKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptKit(
      designSize: Size(375, 812),
      child: MyApp(),
    );
  }
}