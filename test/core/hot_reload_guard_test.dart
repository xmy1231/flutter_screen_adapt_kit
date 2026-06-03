import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_adapt_kit/core/hot_reload_guard.dart';

void main() {
  group('HotReloadGuard', () {
    setUp(() {
      HotReloadGuard.reset();
    });

    test('initial state is not initialized', () {
      expect(HotReloadGuard.isInitialized, false);
    });

    test('ensure marks as initialized', () {
      HotReloadGuard.ensure();
      expect(HotReloadGuard.isInitialized, true);
    });

    test('ensure returns false on first call, true on subsequent', () {
      expect(HotReloadGuard.ensure(), false);
      expect(HotReloadGuard.ensure(), true);
    });
  });
}
