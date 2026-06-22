# AdaptKit Example 重构设计

**Date:** 2026-06-22
**Status:** Approved (pending written spec review)
**Scope:** `example/lib/**` only

## Background

`flutter_screen_adapt_kit` 是一个 Flutter 屏幕适配套件,提供三类能力:
- **缩放尺寸** (`context.adaptScale`、`Transform.scale`)
- **安全区** (`context.adaptSafeTop/Bottom`、`context.statusBarHeight`、`context.notchHeight`)
- **文本行为** (`TextBehavior.{scale, system, fixed}`)

`example/lib/main.dart` 当前 1124 行,单文件展示了五个 Card:当前状态、文字适配、控件适配、布局适配、状态栏适配。但其中:

1. **AppBar 适配演示缺失且存在 bug** —— 用户重点反馈项。`SafeAppBar` 工具类被注释掉,实际生效的 `AppBar` 代码有 `??` + `+` 优先级 bug,使得 `safeTop` 在非空时被丢弃。
2. **死代码与杂项过多** —— `example/lib/main_backup.dart`(565 行),多处 `print(...)` 调试残留,大量 `_DeviceButton`、`_ApiRow` 等佐料代码。
3. **结构不便于阅读** —— 文字/控件/AppBar 三块适配逻辑分散,单文件过长。

## Goal

重构 `example/lib/`,以 **多文件 + Tab 切换 + 不变量工具组件** 的方式清晰地展示三类适配:
- 文字适配(Text Adaptation)
- 控件适配(Widget Adaptation)
- AppBar 适配(AppBar Adaptation)

保留一个简要的 **状态摘要**(State Summary)Tab 用于实时显示 Scale / DPR / 安全区值。

## Non-Goals

- 不引入任何 `lib/**` 文件修改。
- 不修改测试(`test/**`)和库 API(`lib/flutter_screen_adapt_kit.dart`)。
- 不展示折叠屏 / HarmonyOS / iOS 特定 notch 类型 runtime 切换演示 —— 仅展示跨平台通用适配。
- 不为 `SafeAppBar` 提供独立的 pub.dev 文档条目。

## Design

### File Structure

```
example/lib/
├── main.dart                              # 入口 + AdaptKit 包裹 + MaterialApp
├── app.dart                               # MaterialApp + 主题
├── home_shell.dart                        # Scaffold + NavigationBar + IndexedStack
├── widgets/
│   ├── safe_app_bar.dart                  # SafeAppBar (修复 bug + 删 debug)
│   └── adaptive_section.dart              # 通用 SectionCard 容器
└── pages/
    ├── text_adaptation_page.dart          # 文字适配 Tab
    ├── widget_adaptation_page.dart        # 控件适配 Tab
    ├── app_bar_adaptation_page.dart       # AppBar 适配 Tab
    └── state_summary_page.dart            # 状态摘要 Tab
```

被删除的文件:
- `example/lib/main_backup.dart`(565 行,旧代码已迁移到新文件)
- 注释代码块 `/SafeAppBar/`、旧 `_DeviceButton`、`_ApiRow`、`_AdaptiveText` 私有类

### Tab 切换实现

`HomeShell`:
```dart
class HomeShell extends StatefulWidget { ... }

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = <Widget>[
    TextAdaptationPage(),
    WidgetAdaptationPage(),
    AppBarAdaptationPage(),
    StateSummaryPage(),
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.text_fields), label: '文字'),
          NavigationDestination(icon: Icon(Icons.widgets), label: '控件'),
          NavigationDestination(icon: Icon(Icons.view_headline), label: 'AppBar'),
          NavigationDestination(icon: Icon(Icons.info_outline), label: '状态'),
        ],
      ),
    );
  }
}
```

每个 Tab 的页面包含一个 Scaffold,AppBar 使用新建的 `SafeAppBar`。

### SafeAppBar 工具组件

修复原 `main.dart` L37–L79 的 bug:

```dart
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
    // 注: preferredSize 通常不包含 safeTop —— safeTop 由 Container padding 处理
    // 不在 Scaffold.appBar 里贡献给 layout,以避免与 Scaffold/Edge-to-Edge 冲突
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
1. **删所有 `print('build SafeAppBar${...}')`** 调试语句。
2. **`showSafeTop` 开关**让用户可在沉浸式(edge-to-edge)模式下不叠加状态栏偏移。
3. **`backgroundColor: Colors.transparent`** 让 SafeAppBar 外层 Container 的颜色穿透到 AppBar,提供可视化边界。
4. **`Scaffold.resizeToAvoidBottomInset`** 默认行为保留(不强制改)。
5. **优雅降级**:`context.adaptSafeTop` 在 AdaptKit 作用域外返回 0。✅ 保持现有契约。

### 三类适配 Tab 内容

#### TextAdaptationPage
- **顶部行为切换**(3 个按钮):`Scale` / `Fixed` / `System`,点击调用 `AdaptKit.of(context).setTextBehavior(...)`。
- **6 个滚动 section**(沿用 `AdaptiveSection`):
  1. `fontSize: 14 * context.adaptScale` 手动计算(展示对比)
  2. 通过 `MediaQuery.textScalerOf(context)` 自动适配
  3. 多字号对比(12/14/18/24),用 `_AdaptiveText` 私有类
  4. `TextBehavior.scale` 数值说明
  5. `TextBehavior.fixed` 不随 UI 缩放
  6. `TextBehavior.system` 只跟系统字体缩放

#### WidgetAdaptationPage
- **3 个 section** 三种控件尺寸策略对比:
  1. **`UnscaleBox`** —— 反缩放保持物理像素尺寸(适合图标 / 小控件)
  2. **`PhysicalPixelBox`** —— 精确物理边框(适合分隔线 1px / 2px)
  3. **手写 `size: 24 * context.adaptScale`** —— 标准缩放

#### AppBarAdaptationPage (新增,核心)
提供三种 AppBar 写法对比:

| 场景 | 实现 | 现象 |
|------|------|------|
| 沉浸式(Edge-to-Edge) | `SafeAppBar(showSafeTop: true)` | 系统 UI 全隐藏,toolbar 顶部 padding = safeTop |
| 非沉浸式 | `SafeAppBar(showSafeTop: true)` + 默认 `SystemUiMode` | 系统渲染状态栏,toolbar 仍自添加 safeTop 偏移(可能双倍,但为对照示例) |
| 标准 AppBar | `AppBar(toolbarHeight: context.adaptSafeTop + kToolbarHeight)` | 普通 AppBar 但自适应高 |

- **沉浸式 Switch**:切换 `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [...])`,实时看到高度跳变以解释适配意义。

#### StateSummaryPage
原 `_buildCurrentStateCard` 子集,实时显示:
- Scale (toStringAsFixed 6)
- DPR
- 逻辑尺寸 `W × H`
- 设计尺寸 `375 × 812`
- 方向 (portrait / landscape)
- 文字模式 (由 HomeShell 的 ValueNotifier 共享)
- 安全区顶部 / 底部
- Notch 类型
- Transform 创建状态(`(scale - 1.0).abs() > 0.0001` ? '需要' : '不需要 (0开销)')

文字模式:父层 `_HomeShellState` 持有 `final ValueNotifier<TextBehavior> textBehaviorNotifier = ValueNotifier(TextBehavior.scale)`。TextAdaptationPage 的按钮 `onPressed` 写入 `AdaptKit.of(context).setTextBehavior(...)` 同时 `textBehaviorNotifier.value = ...`。StateSummaryPage 与 TextAdaptationPage 都用 `ValueListenableBuilder<TextBehavior>(valueListenable: textBehaviorNotifier, builder: ...)` 读取显示值。

### Section 容器 `AdaptiveSection`

```dart
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

  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ]),
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

### main.dart 简化

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

`app.dart` 只负责 `MaterialApp`:`title`、`theme`、`home: HomeShell()`。
不导出 `AdaptKit`,只导出 `MyApp`。

### 边缘案例与风险

1. **`context.adaptSafeTop` 在 AdaptKit 外返回 0**:`SafeAppBar` 必须测试在脱离 AdaptKit 的情况下不崩溃。当前 API 保证返回 0。✅
2. **`Scaffold.appBar` 与 `Container` 高度**:`SafeAppBar` 把 height 计算放在自身 Container 内部,`Scaffold` 接收 `preferredSize`,后者不包含 safeTop。这避免了当 Scaffold 计算 AppBar 总高时把 safeTop 算进去导致的 detail overflow。⚠️ 需 `flutter run` 折叠屏 + 旋转测试,确保非刘海设备安全区为 0 时不产生 3px 白边。
3. **`AdaptKit.of(context).setTextBehavior` 要求在 build 期间触发**:State summary 页的文字模式与 TextAdaptation 页一致。用 `ValueNotifier<TextBehavior>` 在 HomeShell 持有,各页面通过 `ValueListenableBuilder` 读取。✅
4. **`IndexedStack` 保留所有页面状态**:页面切换不丢失用户的滚动位置 / 输入框值。✅
5. **iOS 系统字体**:`fontFamily: '.SF Pro Text'` 兼容 iOS,Android 走 Roboto。保留原设置。✅

## 失败准则 / Verification

| 验证项 | 命令 | 期望 |
|--------|------|------|
| `flutter analyze` 零 warning | `cd example && flutter analyze` | `No issues found!` |
| 库测试不变 | `flutter test` | 现有 test/ 全部通过 |
| 关键 type-pass | `cd example && dart analyze lib/` | `No issues found!` |
| 视觉对照 | (手动) edge-to-edge 开关时 AppBar 高度正确跳变 | safeTop = 状态栏悬浮;非沉浸式下 safeTop = 系统渲染区域 |

不要求实际 `flutter run`(无法在 CI 中验证 iOS/Android 设备 notch 渲染)。

## 实施步骤(执行阶段)

顺序由 1–11 串行执行,每步独立可验证:
1. 删除 `example/lib/main_backup.dart`
2. 创建 `example/lib/widgets/adaptive_section.dart`
3. 创建 `example/lib/widgets/safe_app_bar.dart`(包含 bug 修复)
4. 创建 `example/lib/pages/state_summary_page.dart`(无依赖)
5. 创建 `example/lib/pages/text_adaptation_page.dart`(依赖 adaptive_section)
6. 创建 `example/lib/pages/widget_adaptation_page.dart`(依赖 adaptive_section, UnscaleBox, PhysicalPixelBox)
7. 创建 `example/lib/pages/app_bar_adaptation_page.dart`(依赖 safe_app_bar, 自定义沉浸式 switch)
8. 创建 `example/lib/home_shell.dart`(依赖 4 个 page)
9. 创建 `example/lib/app.dart` + 重写 `example/lib/main.dart`(依赖 home_shell)
10. 执行 `cd example && flutter analyze` 验证零 warning
11. 执行 `flutter test`(根目录)确认库测试不变

## Out of Scope

- 不动的文件:`lib/**`、`test/**`、`pubspec.yaml`、`README*.md`、`CHANGELOG.md`。
- 不动的平台项目:`example/android/**`、`example/ios/**`、`example/macos/**`、`example/linux/**`、`example/web/**`、`example/windows/**`。
- 不引入新依赖(全部走当前 `pubspec.yaml` 已有)。

## 风险与未来工作

| 风险 | 缓解 |
|------|------|
| `SafeAppBar` 在 foldable 设备 halfOpened 状态下可能与 Scaffold 行为冲突 | 当前阶段不演示 foldable halfOpened;后续 Stage 添加 |
| 不同平台 safe inset 数值差异可能让 AppBar 在 Android 上有 visual artifact | 提交 dart-side unit test 验证 preferredSize W 贡献给 Scaffold |
| README 示例截图未生成 | 当前阶段不强制,后续 stage |
