import 'package:flutter/material.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';
import 'package:flutter_screen_adapt_kit/text/text_scaler.dart';
import '../widgets/adaptive_section.dart';
import '../widgets/safe_app_bar.dart';

class TextAdaptationPage extends StatelessWidget {
  final ValueNotifier<TextBehavior> textBehaviorNotifier;

  const TextAdaptationPage({
    super.key,
    required this.textBehaviorNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SafeAppBar(
        title: const Text('文字适配'),
        showSafeTop: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AdaptiveSection(
            icon: Icons.text_fields,
            color: Colors.orange,
            title: '文字行为切换',
            description: '点击切换,实时生效',
            children: [
              ValueListenableBuilder<TextBehavior>(
                valueListenable: textBehaviorNotifier,
                builder: (context, current, _) {
                  return Wrap(
                    spacing: 8,
                    children: TextBehavior.values.map((behavior) {
                      final isSelected = behavior == current;
                      return ChoiceChip(
                        label: Text(_label(behavior)),
                        selected: isSelected,
                        onSelected: (_) {
                          textBehaviorNotifier.value = behavior;
                          AdaptKit.of(context)?.setTextBehavior(behavior);
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          AdaptiveSection(
            icon: Icons.text_fields,
            color: Colors.orange,
            title: '文字适配示例',
            children: [
              _SectionLabel('1. 手动 scale 计算:'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '这段文字使用手动 scale 计算: ${context.adaptScale.toStringAsFixed(3)}',
                  style: TextStyle(
                    fontSize: 16 * context.adaptScale,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _SectionLabel('2. MediaQuery.textScaler (Flutter 3.22+):'),
              Builder(
                builder: (context) {
                  final textScaler = MediaQuery.textScalerOf(context);
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '使用 textScaler 自动适配',
                      style: const TextStyle(fontSize: 16, fontFamily: '.SF Pro Text'),
                    ).scalWith(textScaler),
                  );
                },
              ),
              const SizedBox(height: 12),
              _SectionLabel('3. 不同字号对比 (都已自动适配):'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _AdaptiveText('小字 12sp', textStyle: TextStyle(fontSize: 12 * context.adaptScale)),
                  _AdaptiveText('正常 14sp', textStyle: TextStyle(fontSize: 14 * context.adaptScale)),
                  _AdaptiveText('大号 18sp', textStyle: TextStyle(fontSize: 18 * context.adaptScale)),
                  _AdaptiveText('标题 24sp', textStyle: TextStyle(
                    fontSize: 24 * context.adaptScale,
                    fontWeight: FontWeight.bold,
                  )),
                ],
              ),
              const SizedBox(height: 12),
              _SectionLabel('4. Fixed 模式 (不随 UI 缩放):'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '这段文字固定14sp,不随UI缩放 (在 Fixed 模式下)',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _label(TextBehavior behavior) {
    switch (behavior) {
      case TextBehavior.scale:
        return 'Scale';
      case TextBehavior.fixed:
        return 'Fixed';
      case TextBehavior.system:
        return 'System';
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}

class _AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;

  const _AdaptiveText(this.text, {this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textStyle?.copyWith(
        fontSize: (textStyle?.fontSize ?? 14) * context.adaptScale,
      ),
    );
  }
}

extension _TextWidgetExtension on Text {
  Widget scalWith(TextScaler scaler) {
    return Text(
      data!,
      style: style,
      textScaler: scaler,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}