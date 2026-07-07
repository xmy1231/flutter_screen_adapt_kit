import 'package:flutter/material.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';
import 'package:flutter_screen_adapt_kit/text/text_scaler.dart';
import '../widgets/adaptive_section.dart';
import '../widgets/safe_app_bar.dart';

const double _kScaleThreshold = 0.0001;

class StateSummaryPage extends StatelessWidget {
  final ValueNotifier<TextBehavior> textBehaviorNotifier;

  const StateSummaryPage({
    super.key,
    required this.textBehaviorNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SafeAppBar(
        title: const Text('状态摘要'),
        showSafeTop: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AdaptiveSection(
            icon: Icons.info_outline,
            color: Colors.blue,
            title: '当前状态',
            children: [
              _InfoRow('Scale', context.adaptScale.toStringAsFixed(6)),
              _InfoRow('DPR', (context.adaptSystemInfo?.dpr ?? 1.0).toStringAsFixed(2)),
              _InfoRow('逻辑尺寸', _logicalSizeStr(context)),
              _InfoRow('设计尺寸', '375 × 812'),
              _InfoRow('方向', context.adaptOrientation == Orientation.portrait ? '竖屏' : '横屏'),
              ValueListenableBuilder<TextBehavior>(
                valueListenable: textBehaviorNotifier,
                builder: (context, behavior, _) {
                  return _InfoRow('文字模式', _textBehaviorLabel(behavior));
                },
              ),
              _InfoRow('安全区顶部', context.adaptSafeTop.toStringAsFixed(1)),
              _InfoRow('安全区底部', context.adaptSafeBottom.toStringAsFixed(1)),
              _InfoRow('Notch类型', context.adaptNotchInfo?.type.name ?? 'none'),
              _InfoRow('Transform创建', (context.adaptScale - 1.0).abs() > _kScaleThreshold ? '需要' : '不需要 (0开销)'),
            ],
          ),
        ],
      ),
    );
  }

  String _logicalSizeStr(BuildContext context) {
    final size = context.adaptSystemInfo?.logicalSize ?? Size.zero;
    return '${size.width.toStringAsFixed(0)} × ${size.height.toStringAsFixed(0)}';
  }

  String _textBehaviorLabel(TextBehavior behavior) {
    switch (behavior) {
      case TextBehavior.scale:
        return 'Scale (UI × 系统)';
      case TextBehavior.fixed:
        return 'Fixed (固定1.0)';
      case TextBehavior.system:
        return 'System (仅系统)';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}