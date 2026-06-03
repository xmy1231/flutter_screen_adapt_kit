import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_adapt_kit/core/scale_calc.dart';
import 'package:flutter_adapt_kit/core/system_info.dart';

class ScaleExecutor {
  ViewConfiguration apply(ScaleResult result, SystemInfo info) {
    final physicalConstraints = BoxConstraints.tight(info.physicalSize);
    final adaptedDpr = result.adaptedDpr;
    return ViewConfiguration(
      physicalConstraints: physicalConstraints,
      logicalConstraints: physicalConstraints / adaptedDpr,
      devicePixelRatio: adaptedDpr,
    );
  }
}
