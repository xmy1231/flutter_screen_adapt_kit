import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';

class SafeAppBar extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;
  final double? height;
  final bool showSafeTop;

  const SafeAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.bottom,
    this.height,
    this.showSafeTop = true,
  });

  @override
  Widget build(BuildContext context) {
    final safeTop = showSafeTop ? context.adaptSafeTop : 0.0;
    final h = height ?? kToolbarHeight;
    return AppBar(
      title: title,
      actions: actions,
      bottom: bottom,
      toolbarHeight: h + safeTop,
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      titleSpacing: 16,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }
}