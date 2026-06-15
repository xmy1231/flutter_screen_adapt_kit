import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';

class AdaptDebugPanel extends StatefulWidget {
  final double designWidth;
  final double designHeight;
  final double dpr;
  final double scaleRatio;
  final String? notchType;

  const AdaptDebugPanel({
    super.key,
    required this.designWidth,
    required this.designHeight,
    required this.dpr,
    required this.scaleRatio,
    this.notchType,
  });

  @override
  State<AdaptDebugPanel> createState() => _AdaptDebugPanelState();
}

class _AdaptDebugPanelState extends State<AdaptDebugPanel> {
  double _dx = 16;
  double _dy = 100;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    final screenSize = MediaQuery.sizeOf(context);
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          left: _dx,
          top: _dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _dx = (_dx + details.delta.dx).clamp(0.0, screenSize.width);
                _dy = (_dy + details.delta.dy).clamp(0.0, screenSize.height);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Design: ${widget.designWidth}×${widget.designHeight}'),
                    Text('DPR: ${widget.dpr}'),
                    Text('Scale: ${widget.scaleRatio.toStringAsFixed(4)}'),
                    if (widget.notchType != null) Text('Notch: ${widget.notchType}'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AdaptDebugOverlay extends StatelessWidget {
  const AdaptDebugOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    final result = context.adaptScaleResult;
    final notchInfo = context.adaptNotchInfo;
    if (result == null) return const SizedBox.shrink();

    return AdaptDebugPanel(
      designWidth: result.designSize.width,
      designHeight: result.designSize.height,
      dpr: result.adaptedDpr,
      scaleRatio: result.scale,
      notchType: notchInfo?.type.name,
    );
  }
}
