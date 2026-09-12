import 'dart:math' as math;
import '../../data/models/car_model.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/expertise_model.dart';

/// Halil Usta Özel Anlatı Görevi Veri Modeli (§SPEC-2026-09-12-HALIL-USTA-DEEP-MENTOR)
class MentorNarrativeQuest {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final String loreKey;
  final int targetGoal;
  final int currentProgress;
  final int rewardMoney;
  final int rewardXP;
  final String rewardBadge;
  final bool isCompleted;
  final bool isClaimed;

  const MentorNarrativeQuest({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.loreKey,
    required this.targetGoal,
    required this.currentProgress,
    required this.rewardMoney,
    required this.rewardXP,
    required this.rewardBadge,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  double get progressPercent => targetGoal == 0
      ? 1.0
      : (currentProgress / targetGoal).clamp(0.0, 1.0);

  MentorNarrativeQuest copyWith({
    String? id,
    String? titleKey,
    String? descriptionKey,
    String? loreKey,
    int? targetGoal,
    int? currentProgress,
    int? rewardMoney,
    int? rewardXP,
    String? rewardBadge,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return MentorNarrativeQuest(
      id: id ?? this.id,
      titleKey: titleKey ?? this.titleKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      loreKey: loreKey ?? this.loreKey,
      targetGoal: targetGoal ?? this.targetGoal,
      currentProgress: currentProgress ?? this.currentProgress,
      rewardMoney: rewardMoney ?? this.rewardMoney,
      rewardXP: rewardXP ?? this.rewardXP,
      rewardBadge: rewardBadge ?? this.rewardBadge,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

/// Halil Usta Anlatı Görevleri Motoru
class MentorQuestEngine {
  static const String questHeritageRestore = 'm_quest_halil_heritage_restore';
  static const String questBargainSniper = 'm_quest_halil_bargain_sniper';
  static const String questTeaHospitality = 'm_quest_halil_tea_hospitality';

  static const List<String> allQuestIds = [
    questHeritageRestore,
    questBargainSniper,
    questTeaHospitality,
  ];

  /// Oyuncunun mevcut seviyesine ve durumuna göre aktif olan anlatı görevini döner
  static MentorNarrativeQuest? getActiveQuest(DealershipModel game) {
    if (!game.tutorialCompleted) return null;

    final memory = game.mentorMemory;
    final completed = (memory['completedQuestIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toSet() ??
        const <String>{};

    final claimed = (memory['claimedQuestIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toSet() ??
        const <String>{};

    for (final qId in allQuestIds) {
      if (!claimed.contains(qId)) {
        return _buildQuestInstance(game, qId, completed.contains(qId));
      }
    }
    return null;
  }

  /// Araç satın alındığında kelepir durumunu inceleyip usta hafızasını günceller
  static DealershipModel onCarPurchased(
    DealershipModel game,
    CarModel car,
    double purchasePrice,
  ) {
    if (purchasePrice <= car.baseMarketValue * 0.80) {
      final memory = Map<String, dynamic>.from(game.mentorMemory);
      final count = ((memory['bargainsBoughtCount'] as num?)?.toInt() ?? 0) + 1;
      memory['bargainsBoughtCount'] = count;

      if (count >= 2) {
        final completed = Set<String>.from(
          (memory['completedQuestIds'] as List<dynamic>?)?.map((e) => e.toString()) ?? const [],
        )..add(questBargainSniper);
        memory['completedQuestIds'] = completed.toList();
      }
      return game.copyWith(mentorMemory: memory);
    }
    return game;
  }

  /// Garajdaki araçlar kontrol edilerek restorasyon görevi tamamlandıysa hafızaya kalıcı işler
  static DealershipModel checkAndPersistRestorationProgress(DealershipModel game) {
    final memory = Map<String, dynamic>.from(game.mentorMemory);
    final completed = Set<String>.from(
      (memory['completedQuestIds'] as List<dynamic>?)?.map((e) => e.toString()) ?? const [],
    );

    if (completed.contains(questHeritageRestore)) return game;

    final hasRestored = game.ownedCars.any((c) =>
        c.expertise.engineCondition >= 85 &&
        c.expertise.transmissionCondition >= 80 &&
        !c.expertise.bodyParts.values.any((p) => p == PartStatus.damaged));

    if (hasRestored) {
      completed.add(questHeritageRestore);
      memory['completedQuestIds'] = completed.toList();
      return game.copyWith(mentorMemory: memory);
    }
    return game;
  }

  static MentorNarrativeQuest _buildQuestInstance(
    DealershipModel game,
    String questId,
    bool isCompletedAlready,
  ) {
    final memory = game.mentorMemory;

    switch (questId) {
      case questHeritageRestore:
        // Garajda motor ve kaporta kondisyonu >= 85 olan restore edilmiş araç var mı?
        final hasRestored = game.ownedCars.any((c) =>
            c.expertise.engineCondition >= 85 &&
            c.expertise.transmissionCondition >= 80 &&
            !c.expertise.bodyParts.values.any((p) => p == PartStatus.damaged));
        final completed = isCompletedAlready || hasRestored;
        final progress = completed ? 1 : (hasRestored ? 1 : 0);

        return MentorNarrativeQuest(
          id: questHeritageRestore,
          titleKey: 'quest_halil_heritage_title',
          descriptionKey: 'quest_halil_heritage_desc',
          loreKey: 'quest_halil_heritage_lore',
          targetGoal: 1,
          currentProgress: progress,
          rewardMoney: 45000,
          rewardXP: 150,
          rewardBadge: 'badge_master_restorer',
          isCompleted: completed,
        );

      case questBargainSniper:
        final count = (memory['bargainsBoughtCount'] as num?)?.toInt() ?? 0;
        final completed = isCompletedAlready || count >= 2;

        return MentorNarrativeQuest(
          id: questBargainSniper,
          titleKey: 'quest_halil_bargain_title',
          descriptionKey: 'quest_halil_bargain_desc',
          loreKey: 'quest_halil_bargain_lore',
          targetGoal: 2,
          currentProgress: math.min(count, 2),
          rewardMoney: 60000,
          rewardXP: 200,
          rewardBadge: 'badge_bargain_hunter',
          isCompleted: completed,
        );

      case questTeaHospitality:
      default:
        final teaCount = (memory['teaServedCount'] as num?)?.toInt() ?? 0;
        final completed = isCompletedAlready || teaCount >= 3;

        return MentorNarrativeQuest(
          id: questTeaHospitality,
          titleKey: 'quest_halil_tea_title',
          descriptionKey: 'quest_halil_tea_desc',
          loreKey: 'quest_halil_tea_lore',
          targetGoal: 3,
          currentProgress: math.min(teaCount, 3),
          rewardMoney: 25000,
          rewardXP: 100,
          rewardBadge: 'badge_esnaf_bereket',
          isCompleted: completed,
        );
    }
  }

  /// Halil Usta'ya bugün çay ısmarlanabilir mi kontrolü
  static bool canServeTea(DealershipModel game) {
    if (!game.tutorialCompleted) return false;
    final memory = game.mentorMemory;
    final lastTeaDay = (memory['lastTeaServedDay'] as num?)?.toInt() ?? 0;
    return game.currentDay > lastTeaDay || lastTeaDay == 0;
  }

  /// Halil Usta'ya bugün çay ikram edildi mi kontrolü
  static bool hasServedTeaToday(DealershipModel game) {
    final memory = game.mentorMemory;
    final lastTeaDay = (memory['lastTeaServedDay'] as num?)?.toInt() ?? 0;
    return lastTeaDay == game.currentDay && lastTeaDay > 0;
  }

  /// Halil Usta'ya çay ikram etme aksiyonu
  static DealershipModel serveTeaToHalil(DealershipModel game) {
    final memory = Map<String, dynamic>.from(game.mentorMemory);
    final teaCount = (memory['teaServedCount'] as num?)?.toInt() ?? 0;
    final lastTeaDay = (memory['lastTeaServedDay'] as num?)?.toInt() ?? 0;

    if (game.currentDay <= lastTeaDay && lastTeaDay > 0) {
      // Günde en fazla 1 kez çay ikram edilebilir
      return game;
    }

    memory['teaServedCount'] = teaCount + 1;
    memory['lastTeaServedDay'] = game.currentDay;

    // Görev durumunu kontrol et
    final active = getActiveQuest(game.copyWith(mentorMemory: memory));
    if (active != null && active.id == questTeaHospitality && (teaCount + 1) >= 3) {
      final completed = Set<String>.from(
        (memory['completedQuestIds'] as List<dynamic>?)?.map((e) => e.toString()) ?? const [],
      )..add(questTeaHospitality);
      memory['completedQuestIds'] = completed.toList();
    }

    return game.copyWith(
      mentorMemory: memory,
      skills: game.skills.copyWith(xp: game.skills.xp + 10),
    );
  }

  /// Görev ödülünü toplama aksiyonu
  static DealershipModel claimQuestReward(DealershipModel game, String questId) {
    final memory = Map<String, dynamic>.from(game.mentorMemory);
    final claimed = Set<String>.from(
      (memory['claimedQuestIds'] as List<dynamic>?)?.map((e) => e.toString()) ?? const [],
    );

    if (claimed.contains(questId)) return game;

    final quest = _buildQuestInstance(game, questId, true);
    claimed.add(questId);
    memory['claimedQuestIds'] = claimed.toList();

    final earnedBadges = Set<String>.from(
      (memory['earnedBadges'] as List<dynamic>?)?.map((e) => e.toString()) ?? const [],
    )..add(quest.rewardBadge);
    memory['earnedBadges'] = earnedBadges.toList();

    return game.copyWith(
      balance: game.balance + quest.rewardMoney,
      totalProfit: game.totalProfit + quest.rewardMoney,
      skills: game.skills.copyWith(xp: game.skills.xp + quest.rewardXP),
      mentorMemory: memory,
    );
  }
}
