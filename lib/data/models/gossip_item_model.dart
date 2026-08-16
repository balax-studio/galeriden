enum GossipType {
  marketTrend, // Piyasa tüyosu
  rivalIntel,  // Rakip istihbaratı
  bargainTip,  // Kelepir araç ihbarı
  hiddenDefect // Gizli kusur uyarısı
}

class GossipItemModel {
  final String id;
  final String sourceNpc;
  final String sourceNpcName;
  final String sourceAvatar;
  final String title;
  final String teaser;
  final String content;
  final double cost;
  final double accuracy; // 0.0 - 1.0 (accuracy rating)
  final GossipType type;
  final String? targetCarId;
  final String? targetSegment;
  final bool isPurchased;
  final int inGameDay;

  String get sourceTitle => title;
  String get teaserText => teaser;
  String get fullContent => content;
  double get accuracyRate => accuracy;

  const GossipItemModel({
    required this.id,
    required this.sourceNpc,
    required this.sourceNpcName,
    required this.sourceAvatar,
    required this.title,
    required this.teaser,
    required this.content,
    required this.cost,
    required this.accuracy,
    required this.type,
    this.targetCarId,
    this.targetSegment,
    this.isPurchased = false,
    required this.inGameDay,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceNpc': sourceNpc,
      'sourceNpcName': sourceNpcName,
      'sourceAvatar': sourceAvatar,
      'title': title,
      'teaser': teaser,
      'content': content,
      'cost': cost,
      'accuracy': accuracy,
      'type': type.name,
      'targetCarId': targetCarId,
      'targetSegment': targetSegment,
      'isPurchased': isPurchased,
      'inGameDay': inGameDay,
    };
  }

  factory GossipItemModel.fromJson(Map<String, dynamic> json) {
    return GossipItemModel(
      id: json['id'] as String? ?? 'gossip_${DateTime.now().millisecondsSinceEpoch}',
      sourceNpc: json['sourceNpc'] as String? ?? 'cayci_necati',
      sourceNpcName: json['sourceNpcName'] as String? ?? 'Çaycı Necati',
      sourceAvatar: json['sourceAvatar'] as String? ?? '☕',
      title: json['title'] as String? ?? 'Sanayi Dedikodusu',
      teaser: json['teaser'] as String? ?? 'Bir şeyler duydum usta...',
      content: json['content'] as String? ?? 'Piyasa hareketlenecek.',
      cost: (json['cost'] as num?)?.toDouble() ?? 2000.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.75,
      type: GossipType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GossipType.marketTrend,
      ),
      targetCarId: json['targetCarId'] as String?,
      targetSegment: json['targetSegment'] as String?,
      isPurchased: json['isPurchased'] as bool? ?? false,
      inGameDay: json['inGameDay'] as int? ?? 1,
    );
  }

  GossipItemModel copyWith({
    String? id,
    String? sourceNpc,
    String? sourceNpcName,
    String? sourceAvatar,
    String? title,
    String? teaser,
    String? content,
    double? cost,
    double? accuracy,
    GossipType? type,
    String? targetCarId,
    String? targetSegment,
    bool? isPurchased,
    int? inGameDay,
  }) {
    return GossipItemModel(
      id: id ?? this.id,
      sourceNpc: sourceNpc ?? this.sourceNpc,
      sourceNpcName: sourceNpcName ?? this.sourceNpcName,
      sourceAvatar: sourceAvatar ?? this.sourceAvatar,
      title: title ?? this.title,
      teaser: teaser ?? this.teaser,
      content: content ?? this.content,
      cost: cost ?? this.cost,
      accuracy: accuracy ?? this.accuracy,
      type: type ?? this.type,
      targetCarId: targetCarId ?? this.targetCarId,
      targetSegment: targetSegment ?? this.targetSegment,
      isPurchased: isPurchased ?? this.isPurchased,
      inGameDay: inGameDay ?? this.inGameDay,
    );
  }
}
