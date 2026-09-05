import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/dealership_model.dart';
import '../../../data/models/mission_model.dart';

abstract class GameBaseNotifier extends StateNotifier<DealershipModel> {
  GameBaseNotifier(super.state);

  final Random random = Random();

  bool get isLoaded => true;
  void saveState();
  void addXP(int amount);
  void checkAchievement(String id);
  void updateMissionProgress(MissionType type, int amount);
  bool checkAndAwardFirstTimeAction(
    String actionKey, {
    String? label,
    double bonusMoney = 5000.0,
    int bonusXP = 5,
  });
  void refreshMarketTrends();
  void triggerOrganicOffers();
  void completeTutorial();
  void skipTutorial();
  void markFeatureSeen(String route);

  void adjustNpcRelationship(String npcId, int delta) {
    final current = state.npcRelationships[npcId] ?? 50;
    final newRelation = (current + delta).clamp(0, 100);
    final updated = Map<String, int>.from(state.npcRelationships);
    updated[npcId] = newRelation;
    state = state.copyWith(npcRelationships: updated);
    saveState();
  }
}
