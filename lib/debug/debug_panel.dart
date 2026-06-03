import 'package:flutter/material.dart';

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
    return Stack(
      children: [
        Positioned(
          left: _dx,
          top: _dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _dx += details.delta.dx;
                _dy += details.delta.dy;
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
