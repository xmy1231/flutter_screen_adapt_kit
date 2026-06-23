import 'package:flutter/material.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';

class SafeAppBar extends StatelessWidget implements PreferredSizeWidget {
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
  Size get preferredSize {
    return Size.fromHeight((height ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = showSafeTop ? context.adaptSafeTop : 0.0;
    final h = height ?? kToolbarHeight;
    return Container(
      height: h + safeTop,
      color: Colors.white,
      child: AppBar(
        title: title,
        actions: actions,
        bottom: bottom,
        toolbarHeight: h,
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        titleSpacing: 16,
      ),
    );
  }
}