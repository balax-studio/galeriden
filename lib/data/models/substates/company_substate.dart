import '../dealership_model.dart';
import '../staff_model.dart';

/// Substate representing dealership branding, identity, staff, and RPG reputation
class CompanySubstate {
  final String playerName;
  final String dealershipName;
  final String logoEmblemId;
  final String logoBadgeShape;
  final String logoBadgeColor;
  final String dealershipTagline;
  final List<StaffModel> hiredStaff;
  final int reputationScore;
  final CharacterOrigin characterOrigin;
  final SpecializationPath specializationPath;
  final Map<String, int> npcRelationships;
  final int dynastyGeneration;
  final List<String> dynastyHistoryLog;

  const CompanySubstate({
    this.playerName = 'Usta Galerici',
    this.dealershipName = 'Galerim',
    this.logoEmblemId = 'classic_star',
    this.logoBadgeShape = 'circle',
    this.logoBadgeColor = '#FFDE59',
    this.dealershipTagline = '',
    this.hiredStaff = const [],
    this.reputationScore = 100,
    this.characterOrigin = CharacterOrigin.sanayiCiragi,
    this.specializationPath = SpecializationPath.none,
    this.npcRelationships = const {},
    this.dynastyGeneration = 1,
    this.dynastyHistoryLog = const [],
  });

  CompanySubstate copyWith({
    String? playerName,
    String? dealershipName,
    String? logoEmblemId,
    String? logoBadgeShape,
    String? logoBadgeColor,
    String? dealershipTagline,
    List<StaffModel>? hiredStaff,
    int? reputationScore,
    CharacterOrigin? characterOrigin,
    SpecializationPath? specializationPath,
    Map<String, int>? npcRelationships,
    int? dynastyGeneration,
    List<String>? dynastyHistoryLog,
  }) {
    return CompanySubstate(
      playerName: playerName ?? this.playerName,
      dealershipName: dealershipName ?? this.dealershipName,
      logoEmblemId: logoEmblemId ?? this.logoEmblemId,
      logoBadgeShape: logoBadgeShape ?? this.logoBadgeShape,
      logoBadgeColor: logoBadgeColor ?? this.logoBadgeColor,
      dealershipTagline: dealershipTagline ?? this.dealershipTagline,
      hiredStaff: hiredStaff ?? this.hiredStaff,
      reputationScore: reputationScore ?? this.reputationScore,
      characterOrigin: characterOrigin ?? this.characterOrigin,
      specializationPath: specializationPath ?? this.specializationPath,
      npcRelationships: npcRelationships ?? this.npcRelationships,
      dynastyGeneration: dynastyGeneration ?? this.dynastyGeneration,
      dynastyHistoryLog: dynastyHistoryLog ?? this.dynastyHistoryLog,
    );
  }
}
