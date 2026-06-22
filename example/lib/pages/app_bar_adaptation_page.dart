import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';
import '../widgets/safe_app_bar.dart';
import '../widgets/adaptive_section.dart';

class AppBarAdaptationPage extends StatefulWidget {
  const AppBarAdaptationPage({super.key});

  @override
  State<AppBarAdaptationPage> createState() => _AppBarAdaptationPageState();
}

class _AppBarAdaptationPageState extends State<AppBarAdaptationPage> {
  bool _immersiveMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AppBar 适配')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AdaptiveSection(
            icon: Icons.view_headline,
            color: Colors.deepPurple,
            title: 'AppBar 写法对比',
            description: '三种场景的 AppBar 实现方式',
            children: [
              _AppBarScenario(
                label: '场景1: SafeAppBar (推荐)',
                description: 'showSafeTop=true, 沉浸式下自动添加 safeTop 偏移',
                child: SafeAppBar(
                  title: const Text('SafeAppBar'),
                  showSafeTop: true,
                ),
              ),
              const SizedBox(height: 12),
              _AppBarScenario(
                label: '场景2: 标准 AppBar + 自适应 toolbarHeight',
                description: '使用 context.adaptSafeTop + kToolbarHeight',
                child: AppBar(
                  title: const Text('自适应高'),
                  toolbarHeight: context.adaptSafeTop + kToolbarHeight,
                ),
              ),
              const SizedBox(height: 12),
              _AppBarScenario(
                label: '场景3: SafeAppBar (showSafeTop=false)',
                description: '关闭 safeTop 偏移,用于全屏内容页',
                child: SafeAppBar(
                  title: const Text('无偏移'),
                  showSafeTop: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AdaptiveSection(
            icon: Icons.fullscreen,
            color: Colors.deepPurple,
            title: '沉浸式模式切换',
            description: '切换后观察 AppBar 高度变化',
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _immersiveMode ? Colors.deepPurple.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _immersiveMode ? Colors.deepPurple : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _immersiveMode ? '已启用沉浸式模式' : '未启用沉浸式模式',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _immersiveMode ? Colors.deepPurple : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '当前 safeTop: ${context.adaptSafeTop.toStringAsFixed(1)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _immersiveMode,
                      onChanged: (value) async {
                        setState(() => _immersiveMode = value);
                        if (value) {
                          await SystemChrome.setEnabledSystemUIMode(
                            SystemUiMode.edgeToEdge,
                            overlays: [SystemUiOverlay.top],
                          );
                        } else {
                          await SystemChrome.setEnabledSystemUIMode(
                            SystemUiMode.edgeToEdge,
                            overlays: SystemUiOverlay.values,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AdaptiveSection(
            icon: Icons.info_outline,
            color: Colors.deepPurple,
            title: '安全区数值说明',
            children: [
              _InfoRow('statusBarHeight', '${context.statusBarHeight.toStringAsFixed(1)} (带阈值判断)'),
              _InfoRow('notchHeight', '${context.notchHeight.toStringAsFixed(1)} (安全区-阈值)'),
              _InfoRow('adaptSafeTop', '${context.adaptSafeTop.toStringAsFixed(1)} (原始刘海高度)'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppBarScenario extends StatelessWidget {
  final String label;
  final String description;
  final Widget child;

  const _AppBarScenario({
    required this.label,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: child,
        ),
      ],
    );
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