import 'package:flutter/material.dart';
import 'package:flutter_screen_adapt_kit/text/text_scaler.dart';
import 'pages/text_adaptation_page.dart';
import 'pages/widget_adaptation_page.dart';
import 'pages/app_bar_adaptation_page.dart';
import 'pages/state_summary_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final ValueNotifier<TextBehavior> _textBehaviorNotifier =
      ValueNotifier(TextBehavior.scale);

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      TextAdaptationPage(textBehaviorNotifier: _textBehaviorNotifier),
      const WidgetAdaptationPage(),
      const AppBarAdaptationPage(),
      StateSummaryPage(textBehaviorNotifier: _textBehaviorNotifier),
    ];
  }

  @override
  void dispose() {
    _textBehaviorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: Colors.white,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.text_fields),
              label: '文字',
            ),
            NavigationDestination(
              icon: Icon(Icons.widgets),
              label: '控件',
            ),
            NavigationDestination(
              icon: Icon(Icons.view_headline),
              label: 'AppBar',
            ),
            NavigationDestination(
              icon: Icon(Icons.info_outline),
              label: '状态',
            ),
          ],
        ),
      ),
    );
  }
}