import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/dealership_model.dart';
import '../../../data/models/mission_model.dart';

abstract class GameBaseNotifier extends StateNotifier<DealershipModel> {
  GameBaseNotifier(super.state);

  final Random random = Random();

  void saveState();
  void addXP(int amount);
  void checkAchievement(String id);
  void updateMissionProgress(MissionType type, int amount);
  void refreshMarketTrends();
  void triggerOrganicOffers();
  void completeTutorial();
}
