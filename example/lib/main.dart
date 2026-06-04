import 'package:flutter/material.dart';
import 'package:flutter_adapt_kit/debug/debug_panel.dart';
import 'package:flutter_adapt_kit/entry/adapt_kit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdaptExample());
}

class AdaptExample extends StatelessWidget {
  const AdaptExample({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptKit(
      designSize: const Size(375, 812),
      child: MaterialApp(
        title: 'AdaptKit Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final adaptState = AdaptKit.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AdaptKit Demo')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Design: 375 × 812'),
                  const SizedBox(height: 16),
                  Text('Scale: ${context.adaptScale.toStringAsFixed(4)}'),
                  const SizedBox(height: 8),
                  Text('DPR: ${context.adaptDpr.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  if (context.adaptNotchInfo != null)
                    Text('Notch: ${context.adaptNotchInfo!.type.name}'),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      adaptState?.setDesignSize(const Size(430, 932));
                    },
                    child: const Text('Switch to iPhone 14 Pro Max (430×932)'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      adaptState?.setDesignSize(const Size(375, 812));
                    },
                    child: const Text('Reset to iPhone X (375×812)'),
                  ),
                ],
              ),
            ),
          ),
          const AdaptDebugOverlay(),
        ],
      ),
    );
  }
}
