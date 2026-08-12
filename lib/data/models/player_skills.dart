class PlayerSkills {
  final int negotiationLevel; // 1-10: Pazarlık Yeteneği (alıcılardan daha yüksek teklif)
  final int eyeForDetail;     // 1-10: Ekspertiz Sezgisi (ekspertiziz gizli kusuru sezme şansı)
  final int marketSense;      // 1-10: Piyasa Tahmini (gerçek piyasa değer aralığını görme)
  final int reputation;       // 1-10: İtibar (daha sık & zengin alıcı çekme)
  final int xp;               // Deneyim Puanı

  PlayerSkills({
    this.negotiationLevel = 1,
    this.eyeForDetail = 1,
    this.marketSense = 1,
    this.reputation = 1,
    this.xp = 0,
  });

  int get availableSkillPoints => (xp / 100).floor() - (negotiationLevel + eyeForDetail + marketSense + reputation - 4);

  Map<String, dynamic> toJson() => {
        'negotiationLevel': negotiationLevel,
        'eyeForDetail': eyeForDetail,
        'marketSense': marketSense,
        'reputation': reputation,
        'xp': xp,
      };

  factory PlayerSkills.fromJson(Map<String, dynamic> json) => PlayerSkills(
        negotiationLevel: json['negotiationLevel'] as int? ?? 1,
        eyeForDetail: json['eyeForDetail'] as int? ?? 1,
        marketSense: json['marketSense'] as int? ?? 1,
        reputation: json['reputation'] as int? ?? 1,
        xp: json['xp'] as int? ?? 0,
      );

  PlayerSkills copyWith({
    int? negotiationLevel,
    int? eyeForDetail,
    int? marketSense,
    int? reputation,
    int? xp,
  }) {
    return PlayerSkills(
      negotiationLevel: negotiationLevel ?? this.negotiationLevel,
      eyeForDetail: eyeForDetail ?? this.eyeForDetail,
      marketSense: marketSense ?? this.marketSense,
      reputation: reputation ?? this.reputation,
      xp: xp ?? this.xp,
    );
  }
}
