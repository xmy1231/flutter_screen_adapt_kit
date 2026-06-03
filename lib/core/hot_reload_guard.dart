class HotReloadGuard {
  HotReloadGuard._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static bool ensure() {
    if (_initialized) {
      return true;
    }
    _initialized = true;
    return false;
  }

  static void reset() {
    _initialized = false;
  }
}
