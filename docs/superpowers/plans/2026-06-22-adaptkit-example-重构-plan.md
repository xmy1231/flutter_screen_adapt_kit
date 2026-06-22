# AdaptKit Example 重构实施计划

> **For agentic workers:** 使用 superpowers:subagent-driven-development (推荐) 或 superpowers:executing-plans 执行此计划。步骤使用 checkbox (`- [ ]`) 语法。

**目标:** 重构 `example/lib/`,以多文件 + Tab 切换方式清晰展示文字适配、控件适配、AppBar 适配三个场景。

**架构:** 每个 Tab 为独立 StatefulWidget + Page;共享组件提取到 `widgets/`;主入口仅做 AdaptKit 包裹和 MaterialApp 配置。

**技术栈:** Flutter SDK ≥ 3.16, Material 3, flutter_screen_adapt_kit (path dependency)

---

## 文件映射

| 操作 | 文件 |
|------|------|
| 删除 | `example/lib/main_backup.dart` |
| 创建 | `example/lib/widgets/adaptive_section.dart` |
| 创建 | `example/lib/widgets/safe_app_bar.dart` |
| 创建 | `example/lib/pages/state_summary_page.dart` |
| 创建 | `example/lib/pages/text_adaptation_page.dart` |
| 创建 | `example/lib/pages/widget_adaptation_page.dart` |
| 创建 | `example/lib/pages/app_bar_adaptation_page.dart` |
| 创建 | `example/lib/home_shell.dart` |
| 创建 | `example/lib/app.dart` |
| 重写 | `example/lib/main.dart` |

---

## 实施步骤

### Task 1: 删除旧文件

- [ ] **Step 1: 删除 main_backup.dart**

```bash
rm example/lib/main_backup.dart
```

验证: `ls example/lib/` 应不包含 main_backup.dart

- [ ] **Step 2: 提交**

```bash
git add -A && git commit -m "refactor(example): delete obsolete main_backup.dart"
```

---

### Task 2: 创建 AdaptiveSection 容器组件

- [ ] **Step 1: 创建 `example/lib/widgets/adaptive_section.dart`**

```dart
import 'package:flutter/material.dart';

class AdaptiveSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? description;
  final List<Widget> children;

  const AdaptiveSection({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const Divider(),
            if (description != null) ...[
              Text(description!),
              const SizedBox(height: 16),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 验证**

```bash
cd example && flutter analyze lib/widgets/adaptive_section.dart
```

期望: `No issues found!`

- [ ] **Step 3: 提交**

```bash
git add lib/widgets/adaptive_section.dart && git commit -m "feat(example): add AdaptiveSection container widget"
```

---

### Task 3: 创建 SafeAppBar 工具组件 (含 bug 修复)

- [ ] **Step 1: 创建 `example/lib/widgets/safe_app_bar.dart`**

```dart
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
    final h = height ?? kToolbarHeight;
    final bottomH = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(h + bottomH);
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = showSafeTop ? context.adaptSafeTop : 0.0;
    final h = height ?? kToolbarHeight;
    final bottomH = bottom?.preferredSize.height ?? 0;
    return Container(
      height: h + bottomH + safeTop,
      padding: EdgeInsets.only(top: safeTop),
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
```

修复要点:
1. 原 `main.dart` L101 bug: `toolbarHeight: AdaptKit.of(context)?.safeTop ?? 0 + kToolbarHeight` 解析为 `safeTop ?? (0 + kToolbarHeight)`,safeTop 非空时失效。新代码直接使用 `context.adaptSafeTop`。
2. 删除所有 `print('build SafeAppBar...')` 调试语句。
3. `backgroundColor: Colors.transparent` 让外层 Container 颜色穿透。
4. `showSafeTop` 开关用于沉浸式/非沉浸式切换演示。

- [ ] **Step 2: 验证**

```bash
cd example && flutter analyze lib/widgets/safe_app_bar.dart
```

期望: `No issues found!`

- [ ] **Step 3: 提交**

```bash
git add lib/widgets/safe_app_bar.dart && git commit -m "fix(example): add SafeAppBar with safeTop bug fix and showSafeTop toggle"
```

---

### Task 4: 创建 StateSummaryPage

- [ ] **Step 1: 创建 `example/lib/pages/state_summary_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';
import 'package:flutter_screen_adapt_kit/text/text_scaler.dart';
import '../widgets/adaptive_section.dart';

class StateSummaryPage extends StatelessWidget {
  final ValueNotifier<TextBehavior> textBehaviorNotifier;

  const StateSummaryPage({
    super.key,
    required this.textBehaviorNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('状态摘要')),
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
              _InfoRow('Transform创建', (context.adaptScale - 1.0).abs() > 0.0001 ? '需要' : '不需要 (0开销)'),
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
```

- [ ] **Step 2: 验证**

```bash
cd example && flutter analyze lib/pages/state_summary_page.dart
```

期望: `No issues found!`

- [ ] **Step 3: 提交**

```bash
git add lib/pages/state_summary_page.dart && git commit -m "feat(example): add StateSummaryPage"
```

---

### Task 5: 创建 TextAdaptationPage

- [ ] **Step 1: 创建 `example/lib/pages/text_adaptation_page.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';
import 'package:flutter_screen_adapt_kit/text/text_scaler.dart';
import '../widgets/adaptive_section.dart';

class TextAdaptationPage extends StatelessWidget {
  final ValueNotifier<TextBehavior> textBehaviorNotifier;

  const TextAdaptationPage({
    super.key,
    required this.textBehaviorNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文字适配')),
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
                  _AdaptiveText('小字 12sp', TextStyle(fontSize: 12 * context.adaptScale)),
                  _AdaptiveText('正常 14sp', TextStyle(fontSize: 14 * context.adaptScale)),
                  _AdaptiveText('大号 18sp', TextStyle(fontSize: 18 * context.adaptScale)),
                  _AdaptiveText('标题 24sp', TextStyle(
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
    return Text(data!, style: style, textScaler: scaler);
  }
}
```

- [ ] **Step 2: 验证**

```bash
cd example && flutter analyze lib/pages/text_adaptation_page.dart
```

期望: `No issues found!`

- [ ] **Step 3: 提交**

```bash
git add lib/pages/text_adaptation_page.dart && git commit -m "feat(example): add TextAdaptationPage with behavior switching"
```

---

### Task 6: 创建 WidgetAdaptationPage

- [ ] **Step 1: 创建 `example/lib/pages/widget_adaptation_page.dart`**

```dart
import 'package:flutter/material.dart';
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
```

- [ ] **Step 2: 验证**

```bash
cd example && flutter analyze lib/pages/widget_adaptation_page.dart
```

期望: `No issues found!`

- [ ] **Step 3: 提交**

```bash
git add lib/pages/widget_adaptation_page.dart && git commit -m "feat(example): add WidgetAdaptationPage with UnscaleBox/PhysicalPixelBox demos"
```

---

### Task 7: 创建 AppBarAdaptationPage (核心新增)

- [ ] **Step 1: 创建 `example/lib/pages/app_bar_adaptation_page.dart`**

```dart
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
```

- [ ] **Step 2: 验证**

```bash
cd example && flutter analyze lib/pages/app_bar_adaptation_page.dart
```

期望: `No issues found!`

- [ ] **Step 3: 提交**

```bash
git add lib/pages/app_bar_adaptation_page.dart && git commit -m "feat(example): add AppBarAdaptationPage with three scenario demos"
```

---

### Task 8: 创建 HomeShell

- [ ] **Step 1: 创建 `example/lib/home_shell.dart`**

```dart
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

  static const _pages = <Widget>[
    TextAdaptationPage(textBehaviorNotifier: _textBehaviorNotifier),
    WidgetAdaptationPage(),
    AppBarAdaptationPage(),
    StateSummaryPage(textBehaviorNotifier: _textBehaviorNotifier),
  ];

  @override
  void dispose() {
    _textBehaviorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
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
    );
  }
}
```

注意: `_pages` 中的 const 构造需要移除,因为 `TextAdaptationPage` 和 `StateSummaryPage` 接收 `ValueNotifier` 参数。

- [ ] **Step 2: 验证 + 修复**

`const _pages` 会因 `_textBehaviorNotifier` 引用报错。修正为:

```dart
  final List<Widget> _pages = <Widget>[
    TextAdaptationPage(textBehaviorNotifier: _textBehaviorNotifier),
    const WidgetAdaptationPage(),
    const AppBarAdaptationPage(),
    StateSummaryPage(textBehaviorNotifier: _textBehaviorNotifier),
  ];
```

- [ ] **Step 3: 验证**

```bash
cd example && flutter analyze lib/home_shell.dart
```

期望: `No issues found!`

- [ ] **Step 4: 提交**

```bash
git add lib/home_shell.dart && git commit -m "feat(example): add HomeShell with NavigationBar tab switching"
```

---

### Task 9: 创建 app.dart 和重写 main.dart

- [ ] **Step 1: 创建 `example/lib/app.dart`**

```dart
import 'package:flutter/material.dart';
import 'home_shell.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdaptKit Showcase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        fontFamily: '.SF Pro Text',
      ),
      home: const HomeShell(),
    );
  }
}
```

- [ ] **Step 2: 重写 `example/lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screen_adapt_kit/entry/adapt_kit.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdaptKitExampleApp());
}

class AdaptKitExampleApp extends StatelessWidget {
  const AdaptKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptKit(
      designSize: Size(375, 812),
      child: MyApp(),
    );
  }
}
```

- [ ] **Step 3: 验证**

```bash
cd example && flutter analyze lib/main.dart lib/app.dart
```

期望: `No issues found!`

- [ ] **Step 4: 提交**

```bash
git add lib/main.dart lib/app.dart && git commit -m "refactor(example): extract AdaptKit wrapper and MaterialApp into separate files"
```

---

### Task 10: 最终验证

- [ ] **Step 1: 全量分析**

```bash
cd example && flutter analyze lib/
```

期望: `No issues found!` (12 个分析问题以内)

- [ ] **Step 2: 库测试验证**

```bash
flutter test
```

期望: 所有现有测试通过

- [ ] **Step 3: 提交最终状态**

```bash
git add -A && git commit -m "feat(example): complete refactor to 4-tab structure (text/widget/appBar/state)"
```

---

## Self-Review Checklist

- [ ] 所有 spec 要求已覆盖 (文件结构 / SafeAppBar / 三类 Tab / StateSummary)
- [ ] 无 placeholder (TBD/TODO/FIXME)
- [ ] 类型一致性 (ValueNotifier<TextBehavior> 在 HomeShell/TextAdaptationPage/StateSummaryPage 中一致)
- [ ] SafeAppBar bug 修复已应用 (无 `?? 0 + kToolbarHeight`)
- [ ] `flutter analyze` 每次文件创建后均通过