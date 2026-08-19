import 'dart:collection';
import 'dart:math';

/// Generic LRU Anti-Repetition Queue to prevent consecutive duplicate texts, IDs, or items.
class AntiRepetitionQueue<T> {
  final int capacity;
  final ListQueue<T> _recentItems = ListQueue<T>();

  AntiRepetitionQueue({this.capacity = 12});

  /// Selects the next item from the given pool, prioritizing items not recently seen.
  T selectNext(List<T> pool, {Random? randomInstance}) {
    if (pool.isEmpty) {
      throw ArgumentError('Pool cannot be empty');
    }
    if (pool.length == 1) {
      return pool.first;
    }

    final rng = randomInstance ?? Random();
    final available = pool.where((item) => !_recentItems.contains(item)).toList();
    final candidatePool = available.isNotEmpty ? available : pool;
    final selected = candidatePool[rng.nextInt(candidatePool.length)];

    push(selected);
    return selected;
  }

  /// Pushes an item into the recent items queue.
  void push(T item) {
    if (_recentItems.length >= capacity) {
      _recentItems.removeFirst();
    }
    _recentItems.addLast(item);
  }

  /// Clears the history.
  void clear() {
    _recentItems.clear();
  }

  /// Returns current history list (unmodifiable).
  List<T> get history => List.unmodifiable(_recentItems);
}
