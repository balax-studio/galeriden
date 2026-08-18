import 'package:flutter/material.dart';
import '../../data/models/dealership_model.dart';

enum SmartHookType {
  dirtyCarsWash,
  damagedCarRepair,
  lowBalanceGrant,
  emptyGarageSpawn,
  viralReputationBoost,
}

class SmartHookModel {
  final SmartHookType type;
  final String title;
  final String callerName;
  final String callerRole;
  final String characterAvatar;
  final String storyDialogue;
  final String rewardDescription;
  final String rewardBadgeText;
  final String actionButtonLabel;
  final Color accentColor;

  const SmartHookModel({
    required this.type,
    required this.title,
    required this.callerName,
    required this.callerRole,
    required this.characterAvatar,
    required this.storyDialogue,
    required this.rewardDescription,
    required this.rewardBadgeText,
    required this.actionButtonLabel,
    required this.accentColor,
  });
}

class SmartOfficeHookEngine {
  /// Evaluates player's real-time state and returns the highest priority hook needed
  static SmartHookModel evaluate(DealershipModel game) {
    // 1. Check if there are dirty/unwashed cars in garage
    final unwashedCars = game.ownedCars.where((c) => !c.isRented && (!c.isWashed || !c.isPolished || !c.isDetailedCleaned)).toList();
    if (unwashedCars.isNotEmpty) {
      final count = unwashedCars.length;
      return SmartHookModel(
        type: SmartHookType.dirtyCarsWash,
        title: 'Karaköy Gece Yıkama Çetesi',
        callerName: 'Çırak Memo',
        callerRole: 'Sünger & Cila Ustası',
        characterAvatar: 'wash',
        storyDialogue: 'Ustam, vitrindeki $count aracın tozu toprağı müşteri kaçırıyor! 30 saniye bir çay molası ver, gece tayfasıyla tüm filona komple köpüklü oto kuaför ve seramik cila çekelim!',
        rewardDescription: 'Tüm garaj araçlarına anında ücretsiz profesyonel kuaför, pasta-cila & detaylı temizlik uygulanır.',
        rewardBadgeText: '$count ARAÇ KUAFÖR & CİLA',
        actionButtonLabel: 'TÜM FİLOYU PARLAT',
        accentColor: const Color(0xFF06B6D4), // Cyan
      );
    }

    // 2. Check if there is a car with low condition (<85%)
    final damagedCars = game.ownedCars.where((c) => !c.isRented && (c.expertise.engineCondition < 85 || c.expertise.transmissionCondition < 85)).toList()
      ..sort((a, b) => a.expertise.engineCondition.compareTo(b.expertise.engineCondition));
    if (damagedCars.isNotEmpty) {
      final car = damagedCars.first;
      return SmartHookModel(
        type: SmartHookType.damagedCarRepair,
        title: 'Sanayinin Efsanesi Çırak Kadir',
        callerName: 'Kadir Usta',
        callerRole: 'Kurt Revizyoncu',
        characterAvatar: 'mechanic',
        storyDialogue: 'Dükkandaki ${car.brand} ${car.modelName} aracının motorundan ses geliyor ustam! Sponsorumuzun faturasıyla araca sıfır sandık motor ve mekanik revizyonunu bedavaya getirelim!',
        rewardDescription: '${car.brand} ${car.modelName} motor ve şanzımanı anında %100 kondisyona çıkarılır.',
        rewardBadgeText: 'BEDAVA MOTOR REVİZYONU',
        actionButtonLabel: 'USTAYA ANAHTARI VER',
        accentColor: const Color(0xFFE11D48), // Rose red
      );
    }

    // 3. Check if player balance is low (< ₺50.000)
    if (game.balance < 50000) {
      return const SmartHookModel(
        type: SmartHookType.lowBalanceGrant,
        title: 'Çıkmacı İbo Dayı\'nın Acil Zulası',
        callerName: 'Çıkmacı İbo',
        callerRole: 'Hurdalık Ağası',
        characterAvatar: 'deal',
        storyDialogue: 'Kasa tamtakır kalmış be koçum! Piyasada nakitsiz durulmaz, al şu hurdalık altın fonundan ₺35.000 acil sermaye can suyunu, hemen ilk kelepir arabayı kap gel!',
        rewardDescription: 'Galeri kasasına karşılıksız +₺35.000 ekstra nakit can suyu sermayesi eklenir.',
        rewardBadgeText: '+₺35.000 CAN SUYU',
        actionButtonLabel: 'ZULAYI KASAYA ÇEK',
        accentColor: Color(0xFF10B981), // Emerald green
      );
    }

    // 4. Check if garage is low on stock (0 or 1 car)
    if (game.ownedCars.length <= 1) {
      return const SmartHookModel(
        type: SmartHookType.emptyGarageSpawn,
        title: 'Gümrük Muhafaza Kelepir Tüyosu',
        callerName: 'Gümrükçü Selim',
        callerRole: 'Yediemin Sorumlusu',
        characterAvatar: 'deal',
        storyDialogue: 'Ustam garajın bomboş kalmış, sinek avlıyorsun! Yediemin otoparkında hacizden düşme tertemiz bir fırsat aracı var, tek bir reklamla pazara %45 kelepir fiyatla düşüreyim!',
        rewardDescription: 'İkinci el pazarına %45 indirimli kelepir araç ilanı eklenir ve +₺10.000 harçlık verilir.',
        rewardBadgeText: '%45 KELEPİR ARAÇ + ₺10K',
        actionButtonLabel: 'TÜYOYU YAKALA',
        accentColor: Color(0xFFF59E0B), // Amber
      );
    }

    // 5. Default / Flourishing Dealer Hook: Influencer Viral Boost
    return const SmartHookModel(
      type: SmartHookType.viralReputationBoost,
      title: 'Oto Fenomeni Berkcan\'ın Viral Reels\'ı',
      callerName: 'Fenomen Berkcan',
      callerRole: 'Otomobil Editörü',
      characterAvatar: 'flash',
      storyDialogue: 'Abi galerinin önüne geldim, araçlar efsane duruyor! 30 saniyelik bir reels çekelim, videoya sponsor etiketini koyalım; hem +25 Prestij Puanı hem de vitrine %35 Hızlı Satış Dopingi patlatalım!',
      rewardDescription: 'Bayi itibarı anında +25 puan artar ve vitrindeki tüm araçlara 24 saatlik %35 hızlı satış dopingi uygulanır.',
      rewardBadgeText: '+25 İTİBAR & VİTRİN DOPİNGİ',
      actionButtonLabel: 'VİRAL REELS PATLAT',
      accentColor: Color(0xFFA855F7), // Purple
    );
  }
}
