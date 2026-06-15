# flutter_screen_adapt_kit

Flutter 零侵入式屏幕适配插件，支持 iOS、Android 和 HarmonyOS。

## 功能特性

- **尺寸缩放**：自动缩放 UI 以适应任意屏幕尺寸
- **安全区域**：平台级刘海/挖孔处理（宽刘海、灵动岛、挖孔屏、水滴屏）
- **文本缩放**：可配置的文本缩放行为（随 UI 缩放、仅系统缩放或固定）
- **折叠屏支持**：检测折叠状态（展开/半开）、铰链位置和屏幕挖孔区域
- **零侵入**：直接编写设计稿数值，无需 `.w`/`.h` 后缀
- **优雅降级**：在 AdaptKit 范围外，所有 adapt API 返回 `1.0`

## 使用方法

### 1. 初始化

无需特殊绑定，直接使用 `WidgetsFlutterBinding.ensureInitialized()`。

### 2. 包裹应用

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    AdaptKit(
      designSize: Size(375, 812), // 设计稿尺寸
      child: MaterialApp(
        home: MyHomePage(),
      ),
    ),
  );
}
```

### 3. 在 widget 树中任意位置使用 adapt API

```dart
// 获取当前缩放比例
final scale = context.adaptScale;

// 获取适配后的 DPR
final dpr = context.adaptDpr;

// 获取安全区域 insets
final safeTop = context.adaptSafeTop;
final safeBottom = context.adaptSafeBottom;

// 获取刘海信息
final notchInfo = context.adaptNotchInfo;

// 获取状态栏高度和刘海高度
final statusBar = context.statusBarHeight;  // 纯状态栏高度（iOS: 24px, Android/HarmonyOS: 25px）
final notch = context.notchHeight;          // 刘海区域高度（总 topInset - 状态栏）

// 检测折叠屏状态
final isFolded = context.isFolded;          // 是否处于折叠状态
final isFlat = context.isFlat;              // 是否处于展开状态
final hingeBounds = context.adaptHingeBounds; // 铰链区域 bounds
```

## 配置参数

### AdaptKit 参数

| 参数                     | 默认值                | 说明                         |
| ------------------------ | --------------------- | ---------------------------- |
| `designSize`             | `Size(375, 812)`      | 设计稿尺寸                   |
| `strategy`               | `AdaptStrategy.width` | 缩放策略（width/height/min） |
| `textBehavior`           | `TextBehavior.scale`  | 文本缩放行为                 |
| `supportSystemTextScale` | `true`                | 是否乘以系统字体缩放         |
| `safeMode`               | `SafeMode.auto`       | 安全区域处理模式             |
| `classifier`             | `null`                | 平台刘海分类器               |

### 动态更新

```dart
// 运行时调整
AdaptKit.of(context)?.setDesignSize(Size(430, 932));
AdaptKit.of(context)?.overrideNotch(NotchOverride(type: NotchType.wideNotch, topInset: 44));
AdaptKit.of(context)?.resetNotch();
```

<!-- ## 架构原理

flutter_screen_adapt_kit 通过修改 `devicePixelRatio` 和 `ViewConfiguration` 在 Flutter 引擎层面工作。业务代码完全感知不到屏幕适配的存在。

## 平台支持

| 平台      | 支持情况                                      |
| --------- | --------------------------------------------- |
| iOS       | ✅ 灵动岛、宽刘海、Home Button、折叠屏状态   |
| Android   | ✅ 挖孔屏、水滴屏、边缘到边缘（15+）、折叠屏状态 |
| HarmonyOS | ✅ 挖孔屏、水滴屏、宽刘海、折叠屏状态         |

## 状态栏阈值

`statusBarHeight` API 使用平台特定阈值来估算纯状态栏高度：

| 平台      | 状态栏阈值 | 说明                   |
| --------- | ---------- | ---------------------- |
| iOS       | 24px       | 传统状态栏高度（非刘海设备） |
| Android   | 25px       | 标准状态栏高度         |
| HarmonyOS | 25px       | 标准状态栏高度         |

实际返回的状态栏高度为 `min(实际topInset, 阈值)`，刘海高度为 `max(0, 实际topInset - 阈值)`。 -->

## 许可证

MIT
