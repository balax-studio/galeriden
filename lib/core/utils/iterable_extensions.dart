/// Bulletproof Iterable Extensions for Web & Native Dart Runtimes
extension SafeIterableExtension<T> on Iterable<T> {
  /// Returns the first element satisfying [test], or null if none found.
  /// Does not throw StateError or NoSuchMethodError.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

/// Standalone top-level helper for dynamic or typed iterables
T? findFirstWhere<T>(Iterable<T> items, bool Function(T element) test) {
  for (final element in items) {
    if (test(element)) return element;
  }
  return null;
}
