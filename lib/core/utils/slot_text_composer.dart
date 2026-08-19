import 'dart:math';

/// Component-based Slot Machine Text Composer for generating thousands of non-repetitive, natural sentences.
class SlotTextComposer {
  /// Cleanses any stray parenthesis or emoji characters in accordance with project invariant rules.
  static String sanitizeText(String text) {
    return text
        .replaceAll('(', ' - ')
        .replaceAll(')', '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}|\u{1F300}-\u{1F5FF}|\u{1F680}-\u{1F6FF}|\u{2600}-\u{26FF}|\u{2700}-\u{27BF}]', unicode: true), '')
        .replaceAll('  ', ' ')
        .trim();
  }

  /// Composes a 2-part text by selecting one item from each pool.
  static String compose2({
    required List<String> slot1,
    required List<String> slot2,
    String separator = ' ',
    Random? randomInstance,
  }) {
    final rng = randomInstance ?? Random();
    final p1 = slot1.isNotEmpty ? slot1[rng.nextInt(slot1.length)] : '';
    final p2 = slot2.isNotEmpty ? slot2[rng.nextInt(slot2.length)] : '';
    return sanitizeText([p1, p2].where((s) => s.isNotEmpty).join(separator));
  }

  /// Composes a 3-part text by selecting one item from each pool.
  static String compose3({
    required List<String> slot1,
    required List<String> slot2,
    required List<String> slot3,
    String separator = ' ',
    Random? randomInstance,
  }) {
    final rng = randomInstance ?? Random();
    final p1 = slot1.isNotEmpty ? slot1[rng.nextInt(slot1.length)] : '';
    final p2 = slot2.isNotEmpty ? slot2[rng.nextInt(slot2.length)] : '';
    final p3 = slot3.isNotEmpty ? slot3[rng.nextInt(slot3.length)] : '';
    return sanitizeText([p1, p2, p3].where((s) => s.isNotEmpty).join(separator));
  }

  /// Composes a 4-part text by selecting one item from each pool.
  static String compose4({
    required List<String> slot1,
    required List<String> slot2,
    required List<String> slot3,
    required List<String> slot4,
    String separator = ' ',
    Random? randomInstance,
  }) {
    final rng = randomInstance ?? Random();
    final p1 = slot1.isNotEmpty ? slot1[rng.nextInt(slot1.length)] : '';
    final p2 = slot2.isNotEmpty ? slot2[rng.nextInt(slot2.length)] : '';
    final p3 = slot3.isNotEmpty ? slot3[rng.nextInt(slot3.length)] : '';
    final p4 = slot4.isNotEmpty ? slot4[rng.nextInt(slot4.length)] : '';
    return sanitizeText([p1, p2, p3, p4].where((s) => s.isNotEmpty).join(separator));
  }
}
