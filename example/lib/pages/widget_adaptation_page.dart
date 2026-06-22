import 'package:flutter/material.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';
import 'package:flutter_screen_adapt_kit/widgets/unscale_box.dart';
import 'package:flutter_screen_adapt_kit/widgets/physical_pixel_box.dart';
import '../widgets/adaptive_section.dart';

class WidgetAdaptationPage extends StatelessWidget {
  const WidgetAdaptationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dpr = context.adaptSystemInfo?.dpr ?? 3.0;

    return Scaffold(
      appBar: AppBar(title: const Text('控件适配')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AdaptiveSection(
            icon: Icons.widgets,
            color: Colors.purple,
            title: '控件适配示例',
            description: '三种控件尺寸策略对比',
            children: [
              _SectionLabel('1. UnscaleBox (保持物理像素尺寸):'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  UnscaleBox(
                    dpr: dpr,
                    designWidth: 375,
                    mode: UnscaleMode.full,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          '100×100\n(物理像素)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UnscaleBox 用途:',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const Text('• 图标', style: TextStyle(fontSize: 11)),
                      const Text('• 独立控件', style: TextStyle(fontSize: 11)),
                      const Text('• 保持物理精度', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionLabel('2. PhysicalPixelBox (精确物理边框):'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhysicalPixelBox(
                    dpr: dpr,
                    width: 2,
                    color: Colors.purple,
                    child: Container(
                      width: 100,
                      height: 60,
                      color: Colors.white,
                      child: const Center(
                        child: Text('2px 边框', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  PhysicalPixelBox(
                    dpr: dpr,
                    width: 1,
                    child: Container(
                      width: 100,
                      height: 60,
                      color: Colors.white,
                      child: const Center(
                        child: Text('1px 边框', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'DPR: $dpr → 2px边框实际宽度: ${(2 / dpr).toStringAsFixed(3)} 逻辑像素',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 16),
              _SectionLabel('3. 标准缩放 (Transform.scale):'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text('整体缩放: ${context.adaptScale.toStringAsFixed(4)}'),
                    const SizedBox(height: 8),
                    Container(
                      width: 100 * context.adaptScale,
                      height: 50 * context.adaptScale,
                      color: Colors.purple,
                      child: Center(
                        child: Text(
                          '${(100 * context.adaptScale).toStringAsFixed(0)}×${(50 * context.adaptScale).toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionLabel('4. 适配 vs 不适配对比:'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '✓ 已适配',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 80 * context.adaptScale,
                            height: 40 * context.adaptScale,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '80×40 @ scale',
                            style: TextStyle(fontSize: 10, color: Colors.green.shade700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '✗ 未适配',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          const SizedBox(height: 4),
                          Container(width: 80, height: 40, color: Colors.red),
                          const SizedBox(height: 4),
                          const Text('80×40 固定', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
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