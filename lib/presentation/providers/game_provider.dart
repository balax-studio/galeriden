export 'game/game_core_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dealership_model.dart';
import 'game/game_core_provider.dart';

typedef GameNotifier = GameCoreNotifier;

final gameProvider = StateNotifierProvider<GameNotifier, DealershipModel>((ref) {
  return GameNotifier();
});
