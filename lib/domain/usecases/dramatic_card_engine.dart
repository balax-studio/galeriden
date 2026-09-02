import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/car_model.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/dramatic_card_model.dart';
import '../../data/models/expertise_model.dart';
import '../../data/models/staff_model.dart';

class DramaticResolutionResult {
  final DramaticCardModel card;
  final DramaticChoiceModel choice;
  final DramaticOutcomeModel outcome;
  final DealershipModel updatedState;

  const DramaticResolutionResult({
    required this.card,
    required this.choice,
    required this.outcome,
    required this.updatedState,
  });
}

class DramaticCardEngine {
  /// Generates the daily dilemma card for the specified calendar day (Day 1 to 365+)
  static DramaticCardModel generateDailyDilemma(int day, DealershipModel state, {Random? randomInstance}) {
    // 1. Check milestone cards first
    final milestone = _getMilestoneCard(day, state);
    if (milestone != null) {
      return milestone.copyWith(dayNumber: day);
    }

    // 2. Procedural Deterministic Selection
    final daySeed = day * 7919 + 1013;
    final rng = randomInstance ?? Random(daySeed);
    
    // Cycle through 5 vibrant categories: Comedy, Drama/Loss, Opportunity, Conscience, Legacy
    final categoryIndex = day % 5;
    DramaticCardModel generatedCard;

    switch (categoryIndex) {
      case 0:
        generatedCard = _generateComedyCard(day, rng);
        break;
      case 1:
        generatedCard = _generateDramaCard(day, rng, state);
        break;
      case 2:
        generatedCard = _generateOpportunityCard(day, rng);
        break;
      case 3:
        generatedCard = _generateConscienceCard(day, rng);
        break;
      case 4:
      default:
        generatedCard = _generateLegacyCard(day, rng);
        break;
    }

    return generatedCard.copyWith(dayNumber: day);
  }

  /// Selects the next appropriate dramatic dilemma card based on player state and cycle history
  static DramaticCardModel? selectNextCard(DealershipModel state, {Random? randomInstance}) {
    return generateDailyDilemma(state.currentDay, state, randomInstance: randomInstance);
  }

  /// Resolves the player's choice on a dramatic card, determining probabilistic outcomes and applying mutations
  static DramaticResolutionResult resolveChoice(
    DealershipModel state,
    DramaticCardModel card,
    DramaticChoiceModel choice, {
    double? fixedRoll,
    Random? randomInstance,
  }) {
    final rng = randomInstance ?? Random();
    final roll = fixedRoll ?? rng.nextDouble();

    // 1. Determine matching outcome from probability ranges
    DramaticOutcomeModel selectedOutcome = choice.outcomes.first;
    double cumulativeProbability = 0.0;
    for (final outcome in choice.outcomes) {
      cumulativeProbability += outcome.probability;
      if (roll <= cumulativeProbability || outcome == choice.outcomes.last) {
        selectedOutcome = outcome;
        break;
      }
    }

    // 2. Mutate Dealership State
    // Strict upfront cost deduction - prevent ₺0 balance exploit where expensive choices are taken for free
    final double upfrontCost = choice.upfrontCost;
    double newBalance = state.balance - upfrontCost + selectedOutcome.moneyDelta;
    // Allow debt if upfront cost was paid, but if player had 0, they incur realistic debt

    int newReputation = (state.reputation + selectedOutcome.reputationDelta).clamp(0, 1000);
    int newXP = state.experience + selectedOutcome.xpReward;

    List<CarModel> updatedCars = List.from(state.ownedCars);

    // Handle vehicle loss / damage (heirloom / locked cars are protected from theft)
    if (selectedOutcome.loseTargetCar && updatedCars.isNotEmpty) {
      final candidateCars = updatedCars.where((c) => !c.isLockedInShowcase).toList();
      if (candidateCars.isNotEmpty) {
        candidateCars.sort((a, b) => b.estimatedRealValue.compareTo(a.estimatedRealValue));
        final carToLose = candidateCars.first;
        updatedCars.removeWhere((c) => c.id == carToLose.id);
      }
    } else if (selectedOutcome.recoverCarValueMultiplier != null && updatedCars.isNotEmpty) {
      final candidateCars = updatedCars.where((c) => !c.isLockedInShowcase).toList();
      final targetList = candidateCars.isNotEmpty ? candidateCars : updatedCars;
      targetList.sort((a, b) => b.estimatedRealValue.compareTo(a.estimatedRealValue));
      final car = targetList.first;
      final idx = updatedCars.indexWhere((c) => c.id == car.id);
      if (idx != -1) {
        updatedCars[idx] = car.copyWith(
          baseMarketValue: car.baseMarketValue * selectedOutcome.recoverCarValueMultiplier!,
        );
      }
    }

    // Handle family heirloom status locking
    if (selectedOutcome.makeFamilyHeirloom && updatedCars.isNotEmpty) {
      final heirloomIndex = updatedCars.indexWhere((c) =>
          c.brand.toLowerCase().contains('tofaş') ||
          c.modelName.toLowerCase().contains('murat 124') ||
          c.modelName.toLowerCase().contains('124') ||
          c.isRare);
      final targetIndex = heirloomIndex != -1 ? heirloomIndex : 0;
      final targetCar = updatedCars[targetIndex];
      updatedCars[targetIndex] = targetCar.copyWith(
        isLockedInShowcase: true,
        clearListingPrice: true,
      );
    }

    // Handle staff salary multiplier
    List<StaffModel> updatedStaff = List.from(state.hiredStaff);
    if (selectedOutcome.staffSalaryMultiplier != null && updatedStaff.isNotEmpty) {
      updatedStaff = updatedStaff.map((s) {
        if (s.role == StaffRole.masterMechanic || s.role == StaffRole.apprentice) {
          return s.copyWith(salaryMultiplier: s.salaryMultiplier * selectedOutcome.staffSalaryMultiplier!);
        }
        return s;
      }).toList();
    }

    // Handle spawn bargain car
    if (selectedOutcome.spawnBargainCar && updatedCars.length < state.maxGarageSlots) {
      final bargainCar = CarModel(
        id: 'bargain_${DateTime.now().millisecondsSinceEpoch}',
        brand: 'Volk',
        modelName: 'Golf GTI Klasiği',
        modelYear: 2018,
        bodyType: 'Hatchback',
        colorHex: 'D90429',
        colorDisplayName: 'Lansman Kırmızısı',
        colorRarity: 'rare',
        plateNumber: '06 GTI 18',
        plateRarity: 'legendary',
        currentPurchasePrice: 60000.0,
        baseMarketValue: 120000.0,
        expertise: ExpertiseReport(
          engineCondition: 92.0,
          transmissionCondition: 90.0,
          tramerAmount: 2500,
          mileage: 65000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );
      updatedCars.add(bargainCar);
    }

    // Update seen card IDs
    final updatedSeenIds = List<String>.from(state.seenDramaticCardIds);
    if (!updatedSeenIds.contains(card.id)) {
      updatedSeenIds.add(card.id);
    }

    // Mutate NPC relationships dynamically based on choices (§2.4)
    final updatedNpc = Map<String, int>.from(state.npcRelationships);
    final charLower = card.characterName.toLowerCase();
    if (charLower.contains('necati')) {
      if (choice.id.contains('give') || choice.id.contains('accept')) {
        updatedNpc['necati'] = selectedOutcome.isSuccess
            ? ((updatedNpc['necati'] ?? 50) + 35).clamp(0, 100)
            : 0;
      } else {
        updatedNpc['necati'] = ((updatedNpc['necati'] ?? 50) - 30).clamp(0, 100);
      }
    } else if (charLower.contains('berk') || charLower.contains('vlogger')) {
      if (choice.id.contains('sponsor') || choice.id.contains('accept') || choice.id.contains('give')) {
        updatedNpc['vlogger_berk'] = ((updatedNpc['vlogger_berk'] ?? 50) + 25).clamp(0, 100);
      } else {
        updatedNpc['vlogger_berk'] = ((updatedNpc['vlogger_berk'] ?? 50) - 15).clamp(0, 100);
      }
    } else if (charLower.contains('gölge') || charLower.contains('ibrahim')) {
      if (selectedOutcome.isSuccess) {
        updatedNpc['golge_ibrahim'] = ((updatedNpc['golge_ibrahim'] ?? 50) + 20).clamp(0, 100);
      }
    } else if (charLower.contains('haydar')) {
      updatedNpc['haydar_usta'] = ((updatedNpc['haydar_usta'] ?? 50) + (selectedOutcome.isSuccess ? 15 : -10)).clamp(0, 100);
    }

    final updatedState = state.copyWith(
      balance: newBalance,
      reputationScore: newReputation,
      skills: state.skills.copyWith(xp: newXP),
      ownedCars: updatedCars,
      hiredStaff: updatedStaff,
      npcRelationships: updatedNpc,
      seenDramaticCardIds: updatedSeenIds,
      clearPendingDramaticCard: true,
    );

    return DramaticResolutionResult(
      card: card,
      choice: choice,
      outcome: selectedOutcome,
      updatedState: updatedState,
    );
  }

  // -------------------------------------------------------------
  // MILESTONE CARDS (Dönüm Noktası Günleri)
  // -------------------------------------------------------------
  static DramaticCardModel? _getMilestoneCard(int day, DealershipModel state) {
    switch (day) {
      case 1:
        return const DramaticCardModel(
          id: 'milestone_day_1',
          dayNumber: 1,
          category: DramaticCategory.legacy,
          severity: DramaticSeverity.low,
          title: 'İlk Ruhsat & Tabela Seçimi',
          characterName: 'Muhtar Şerafettin',
          characterRole: 'Sanayi Muhtarı',
          characterAvatar: 'suit',
          icon: Icons.storefront_rounded,
          dialogue:
              '"Hayırlı olsun evlat! Galerinin ilk günündesin. Sanayi adetidir; ya esnafa ziyafet verip dualarını alırsın ya da tüm bütçeyi devasa ışıklı tabelaya yatırırsın."',
          foreshadowHint: 'İlk günün kararı galerinin esnaf arasındaki ilk izlenimini belirler.',
          choices: [
            DramaticChoiceModel(
              id: 'm1_treat',
              label: 'Esnafa Çay ve Simit İkramı • -₺500',
              shortDescription: 'Sanayi esnafıyla sıcak bağlar kurulur • +5 İtibar, +30 Deneyim.',
              upfrontCost: 500.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Bereketli Başlangıç',
                  message: 'Sanayi esnafı dükkanına akın etti, hayır dualarını aldın. İtibarın yükseldi!',
                  isSuccess: true,
                  reputationDelta: 5,
                  xpReward: 30,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm1_sign',
              label: 'Görkemli Işıklı Tabela • -₺2.500',
              shortDescription: 'Yoldan geçen müşterilerin dikkatini çeker • +3 İtibar, +80 Deneyim.',
              upfrontCost: 2500.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Göz Alıcı Showroom',
                  message: 'Tabela caddenin en parlak noktası oldu. Çevreden geçenler vitrine bakmadan geçmiyor.',
                  isSuccess: true,
                  reputationDelta: 3,
                  xpReward: 80,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm1_frugal',
              label: 'Sade ve Sessiz Başlangıç • Masrafsız',
              shortDescription: 'Tasarruflu başla ve sermayeni koru • +15 Deneyim.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Tasarruflu Adım',
                  message: 'Tek kuruş harcamadan kepengi açtın. Sermayen ilk araç alımın için güvende.',
                  isSuccess: true,
                  xpReward: 15,
                ),
              ],
            ),
          ],
        );

      case 7:
        return const DramaticCardModel(
          id: 'milestone_day_7',
          dayNumber: 7,
          category: DramaticCategory.comedy,
          severity: DramaticSeverity.medium,
          title: 'İlk Çırak İkilemi',
          characterName: 'Çırak Caner',
          characterRole: 'Acemi Eleman',
          characterAvatar: 'wrench',
          icon: Icons.cleaning_services_rounded,
          dialogue:
              '"Ustam valla bilerek olmadı... Vitrindeki aracı parlatayım derken zımpara süngerini sürmüşüm, sol kapıda ufak bir çizik var."',
          foreshadowHint: 'Çırak gözlerini kaçırıyor ama dürüstçe gelip söyledi.',
          choices: [
            DramaticChoiceModel(
              id: 'm7_forgive',
              label: 'Affet ve Eğit • -₺1.000 Pasta Cila',
              shortDescription: 'Çırağın sadakati artar, usta-çırak bağı güçlenir • +4 İtibar.',
              upfrontCost: 1000.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Esnaf Babalığı',
                  message: 'Çırağı azarlamak yerine doğrusunu gösterdin. Caner artık dükkana dört elle sarılıyor.',
                  isSuccess: true,
                  reputationDelta: 4,
                  xpReward: 60,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm7_punish',
              label: 'Maaşından Kes • -₺1.000 Kesinti',
              shortDescription: 'Zararını karşılarsın ancak çırağın morali bozulur • -2 İtibar.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Sert Disiplin',
                  message: 'Paranı kurtardın ama dükkanda soğuk bir hava esmeye başladı.',
                  isSuccess: true,
                  reputationDelta: -2,
                  xpReward: 30,
                ),
              ],
            ),
          ],
        );

      case 14:
        return const DramaticCardModel(
          id: 'milestone_day_14',
          dayNumber: 14,
          category: DramaticCategory.loss,
          severity: DramaticSeverity.medium,
          title: 'Maliye İlk Yoklaması',
          characterName: 'Müfettiş Selim Bey',
          characterRole: 'Vergi Denetmeni',
          characterAvatar: 'briefcase',
          icon: Icons.receipt_long_rounded,
          dialogue:
              '"Kolay gelsin galerici bey. İki haftalık faaliyet evraklarınızı, noter sözleşmelerinizi ve fatura koçanlarınızı inceleyeceğiz."',
          foreshadowHint: 'Evraklar ne kadar düzenliyse denetim o kadar hızlı biter.',
          choices: [
            DramaticChoiceModel(
              id: 'm14_transparent',
              label: 'Tüm Defterleri Şeffafça Aç',
              shortDescription: '%85 kusursuz geçer • +6 İtibar, %15 ufak gecikme harcı • -₺2.000.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 0.85,
                  title: 'Kusursuz Defter Raporu',
                  message: 'Müfettiş düzenli kayıtları görünce teşekkür edip ayrıldı. Sanayide güvenin tescillendi!',
                  isSuccess: true,
                  reputationDelta: 6,
                  xpReward: 90,
                ),
                DramaticOutcomeModel(
                  probability: 0.15,
                  title: 'Ufak Evrak Eksikliği',
                  message: 'Geçmiş bir faturadaki eksik imza yüzünden ₺2.000 usulsüzlük harcı kesildi.',
                  isSuccess: false,
                  moneyDelta: -2000.0,
                  reputationDelta: 1,
                  xpReward: 40,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm14_accountant',
              label: 'Muhasebeci Eşliğinde İncele • -₺1.500',
              shortDescription: 'Profesyonel danışmanlık ile sıfır riskli denetim • +4 İtibar.',
              upfrontCost: 1500.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Temiz Denetim Onayı',
                  message: 'Muhasebeciniz tüm soruları profesyonelce yanıtladı ve denetim pürüzsüz kapandı.',
                  isSuccess: true,
                  reputationDelta: 4,
                  xpReward: 70,
                ),
              ],
            ),
          ],
        );

      case 30:
        return const DramaticCardModel(
          id: 'milestone_day_30',
          dayNumber: 30,
          category: DramaticCategory.opportunity,
          severity: DramaticSeverity.medium,
          title: 'İlk Ay Sonu Kasa Kapatma',
          characterName: 'Banka Müdürü Vedat Bey',
          characterRole: 'Şube Müdürü',
          characterAvatar: 'detective',
          icon: Icons.account_balance_rounded,
          dialogue:
              '"Tebrikler! Galeriniz ilk ayını başarıyla tamamladı. Bankamız size özel düşük faizli bir esnaf döner sermaye paketi tahsis edebilir."',
          foreshadowHint: 'İlk ay performansı gelecekteki kredi limitlerini etkiler.',
          choices: [
            DramaticChoiceModel(
              id: 'm30_celebrate',
              label: 'Ekiple Ay Sonu Yemeği • -₺3.000',
              shortDescription: 'Tüm ekibin morali ve enerjisi tazelenir • +8 İtibar, +100 Deneyim.',
              upfrontCost: 3000.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Birlik & Beraberlik',
                  message: 'Sanayi lokantasında unutulmaz bir akşam yaşandı. Personel galeriyi kendi işi gibi benimsedi!',
                  isSuccess: true,
                  reputationDelta: 8,
                  xpReward: 100,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm30_reinvest',
              label: 'Kârı Kasada Tut • Büyüme Odaklı',
              shortDescription: 'Sermayeni korursun, sıfır harcama ile yeni araçlara hazırlan • +40 Deneyim.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Sağlam Kasa',
                  message: 'Nakit gücünü korudun. Gelecek fırsat araçları için hazır durumdasın.',
                  isSuccess: true,
                  reputationDelta: 2,
                  xpReward: 40,
                ),
              ],
            ),
          ],
        );

      case 50:
        return const DramaticCardModel(
          id: 'milestone_day_50',
          dayNumber: 50,
          category: DramaticCategory.opportunity,
          severity: DramaticSeverity.medium,
          title: 'Oto Galericiler Sitesi Yönetimi',
          characterName: 'Site Başkanı Hamdi Bey',
          characterRole: 'Galeri Sitesi Başkanı',
          characterAvatar: 'suit',
          icon: Icons.groups_rounded,
          dialogue:
              '"50 gündür aramızdasın ve performansın dikkat çekiyor. Site denetim kuruluna katılmanı istiyoruz. Ortak tanıtım bütçesine ₺10.000 katkı yaparsan seni vitrine çıkarırız."',
          foreshadowHint: 'Site yönetiminde yer almak müşteri akışını doğrudan artırır.',
          choices: [
            DramaticChoiceModel(
              id: 'm50_join',
              label: 'Yönetime Katıl & Sponsor Ol • -₺10.000',
              shortDescription: 'Site giriş panolarında galeriniz öne çıkarılır • +15 İtibar, +150 Deneyim.',
              upfrontCost: 10000.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Site Yönetiminde Söz Sahibi!',
                  message: 'Girişteki dev tabelada galerinin adı parlıyor. Ziyaretçi akışı hissedilir derecede arttı!',
                  isSuccess: true,
                  reputationDelta: 15,
                  xpReward: 150,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm50_decline',
              label: 'Nazikçe Reddet • Bağımsız Kal',
              shortDescription: 'Paran cebinde kalır, bağımsız bir esnaf olarak devam edersin.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Kendi Yolunda',
                  message: 'Bürokrasiye girmemeyi tercih ettin. Dükkanında müşteriyle birebir ilgilenmeye devam.',
                  isSuccess: true,
                  reputationDelta: 0,
                  xpReward: 50,
                ),
              ],
            ),
          ],
        );

      case 100:
        return const DramaticCardModel(
          id: 'milestone_day_100',
          dayNumber: 100,
          category: DramaticCategory.legacy,
          severity: DramaticSeverity.high,
          title: 'Dalya Kutlaması & Sanayi Pilavı',
          characterName: 'Usta Başı Haydar',
          characterRole: 'Sanayi Sözcüsü',
          characterAvatar: 'wrench',
          icon: Icons.celebration_rounded,
          dialogue:
              '"100. günü devirdik patron! Sanayide adın duyuldu, galerinin önünde tüm çarşıya lokma ve etli pilav döktürelim, namımız yürüsün!"',
          foreshadowHint: '100 günlük esnaflık geleneği tüm şehirde yankı bulur.',
          choices: [
            DramaticChoiceModel(
              id: 'm100_feast',
              label: 'Büyük Sanayi Ziyafeti • -₺15.000',
              shortDescription: 'Tüm sanayi çarşısına ziyafet • +25 İtibar, Kelepir Araç Tüyosu!',
              upfrontCost: 15000.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Efsanevi Dalya Şöleni!',
                  message: 'Kazanlar kaynadı, tüm esnaf dükkanındaydı. Bir usta sana gizli bir kelepir araç tüyosu fısıldadı!',
                  isSuccess: true,
                  spawnBargainCar: true,
                  reputationDelta: 25,
                  xpReward: 250,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm100_modest',
              label: 'Mütevazı Kutlama • -₺2.500',
              shortDescription: 'Sadece dükkan çalışanlarıyla pasta kesimi • +8 İtibar.',
              upfrontCost: 2500.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Sıcak Dükkan Kutlaması',
                  message: 'Ekipçe çay pasta eşliğinde 100. günü kutladınız. Moraller zirvede!',
                  isSuccess: true,
                  reputationDelta: 8,
                  xpReward: 100,
                ),
              ],
            ),
          ],
        );

      case 365:
        return const DramaticCardModel(
          id: 'milestone_day_365',
          dayNumber: 365,
          category: DramaticCategory.legacy,
          severity: DramaticSeverity.extreme,
          title: 'Yılın Galericisi Gala Gecesi',
          characterName: 'Otomotiv Derneği Başkanı',
          characterRole: 'Jüri Başkanı',
          characterAvatar: 'suit',
          icon: Icons.military_tech_rounded,
          dialogue:
              '"Koskoca 1 yılı geride bıraktınız! Şehrin en prestijli otomotiv ödülleri töreninde Altın Anahtar Galericilik Ödülü\'ne aday gösterildiniz."',
          foreshadowHint: '365 günlük emeğin taçlandığı tarihi an.',
          choices: [
            DramaticChoiceModel(
              id: 'm365_gala',
              label: 'Gala Gecesine Katıl • -₺20.000',
              shortDescription: 'Şehrin seçkin iş insanlarıyla buluş • +50 İtibar, Efsanevi Prestij!',
              upfrontCost: 20000.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Yılın En İyi Galericisi Ödülü!',
                  message: 'Alkışlar eşliğinde Altın Anahtar ödülünü kaldırdın. Artık şehrin bir numaralı galerisisin!',
                  isSuccess: true,
                  reputationDelta: 50,
                  xpReward: 500,
                  spawnBargainCar: true,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm365_cash',
              label: 'Ödülü Dükkandan Karşıla • Mütevazı',
              shortDescription: 'Gala masrafı yerine parayı kârda tut • +20 İtibar, +200 Deneyim.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Sessiz Ustalık',
                  message: 'Ödülün kargoyla dükkanına geldi ve vitrinin en güzel köşesine yerleşti.',
                  isSuccess: true,
                  reputationDelta: 20,
                  xpReward: 200,
                ),
              ],
            ),
          ],
        );

      default:
        return null;
    }
  }

  // -------------------------------------------------------------
  // PROCEDURAL CATEGORY GENERATORS
  // -------------------------------------------------------------

  static DramaticCardModel _generateComedyCard(int day, Random rng) {
    final variations = [
      (
        title: 'Seyyar Köftecinin Dumanı',
        characterName: 'Köfteci İlyas',
        characterRole: 'Seyyar Esnaf',
        characterAvatar: 'mustache',
        icon: Icons.outdoor_grill_rounded,
        dialogue:
            '"Selamünaleyküm komşu! Tam galerinin girişine tezgahı açtım, cızbız dumanı vitrindeki arabaları biraz tütsüledi ama müşteriye ekmek arası köfte ısmarlarız!"',
        hint: 'Köfte kokusu galeriyi sardı ama sanayi esnafı dükkanın önüne toplanmaya başladı.',
        c1Label: 'Köfteciyle Anlaş • Ortak Kampanya',
        c1Desc: 'Araba bakan her müşteriye köfte ikramı • +4 İtibar, -₺800 Masraf.',
        c1Cost: 800.0,
        c1Title: 'Esnaf Lezzeti Satışı Patlattı!',
        c1Msg: 'Köfte kokusuna gelen müşteriler showroomu doldurdu, iki teklif birden aldın!',
        c1Rep: 4,
        c1Money: 2500.0,
        c2Label: 'Tezgahı Başka Yere Kaldırt',
        c2Desc: 'Arabalar temiz kalır, köfteci hafif bozulur • +1 İtibar.',
        c2Cost: 0.0,
        c2Title: 'Vitrinde Temiz Hava',
        c2Msg: 'İlyas tezgahını sokağın başına taşıdı, camlar pırıl pırıl kaldı.',
        c2Rep: 1,
        c2Money: 0.0,
      ),
      (
        title: 'Çırağın Ters Pasta Cilası',
        characterName: 'Çırak Rıza',
        characterRole: 'Hevesli Çırak',
        characterAvatar: 'wrench',
        icon: Icons.auto_fix_high_rounded,
        dialogue:
            '"Usta... cilayı arabanın kaputuna sürerken keçeyi ters takmışım, araba parlayacağına mat askeri kamuflaj gibi oldu!"',
        hint: 'Müşteri görmek üzere, hızlı bir karar vermek gerek.',
        c1Label: 'Özel Mat Kaplama Diye Pazarla',
        c1Desc: '%60 müşteri bayılır ekstra kâr bırakır, %40 fark eder • -5 İtibar.',
        c1Cost: 0.0,
        c1Title: 'Trend Tasarım Satışı!',
        c1Msg: 'Genç bir müşteri mat görünüşe hayran kaldı ve aracı hemen aldı!',
        c1Rep: 3,
        c1Money: 4000.0,
        c2Label: 'Hemen Usta Çağır & Düzelt • -₺1.200',
        c2Desc: 'Orijinal parlaklığa döner, sıfır risk • +3 İtibar.',
        c2Cost: 1200.0,
        c2Title: 'Kusursuz Ayna Efekti',
        c2Msg: 'Usta yarım saatte boyayı düzeltti ve araç vitrinde ayna gibi parladı.',
        c2Rep: 3,
        c2Money: 0.0,
      ),
      (
        title: 'Tabeladaki Harf Düşmesi',
        characterName: 'Tabelacı Fehmi',
        characterRole: 'Reklamcı Esnafı',
        characterAvatar: 'suit',
        icon: Icons.font_download_rounded,
        dialogue:
            '"Patron, gece rüzgardan tabelanın iki harfi düşmüş, caddedekiler fotoğraf çekip sosyal medyada gülüyor!"',
        hint: 'Kötü reklam da reklam mıdır, yoksa hemen tamir mi edilmeli?',
        c1Label: 'Fotoğrafı Sosyal Medyaya At • Viral Ol',
        c1Desc: 'Mizahi bir dille paylaş • +8 İtibar, +80 Deneyim.',
        c1Cost: 0.0,
        c1Title: 'Sanayinin Viral Fenomeni!',
        c1Msg: 'Paylaşımın binlerce beğeni aldı. Galerinin ismi tüm şehre yayıldı!',
        c1Rep: 8,
        c1Money: 0.0,
        c2Label: 'Acil Vinç Çağır & Onar • -₺1.500',
        c2Desc: 'Ciddi ve kurumsal duruş korunur • +2 İtibar.',
        c2Cost: 1500.0,
        c2Title: 'Kurumsal Düzen Sağlandı',
        c2Msg: 'Tabela bir saat içinde onarıldı, prestijin korundu.',
        c2Rep: 2,
        c2Money: 0.0,
      ),
    ];

    final pick = variations[rng.nextInt(variations.length)];
    return DramaticCardModel(
      id: 'comedy_day_$day',
      category: DramaticCategory.comedy,
      severity: DramaticSeverity.low,
      title: pick.title,
      characterName: pick.characterName,
      characterRole: pick.characterRole,
      characterAvatar: pick.characterAvatar,
      icon: pick.icon,
      dialogue: pick.dialogue,
      foreshadowHint: pick.hint,
      choices: [
        DramaticChoiceModel(
          id: 'c_${day}_1',
          label: pick.c1Label,
          shortDescription: pick.c1Desc,
          upfrontCost: pick.c1Cost,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: pick.c1Title,
              message: pick.c1Msg,
              isSuccess: true,
              moneyDelta: pick.c1Money,
              reputationDelta: pick.c1Rep,
              xpReward: 50,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'c_${day}_2',
          label: pick.c2Label,
          shortDescription: pick.c2Desc,
          upfrontCost: pick.c2Cost,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: pick.c2Title,
              message: pick.c2Msg,
              isSuccess: true,
              moneyDelta: pick.c2Money,
              reputationDelta: pick.c2Rep,
              xpReward: 35,
            ),
          ],
        ),
      ],
    );
  }

  static DramaticCardModel _generateDramaCard(int day, Random rng, DealershipModel state) {
    final variations = [
      (
        title: 'Gece Yarısı Alarm Çığlığı',
        characterName: 'Bekçi Kazım Dayı',
        characterRole: 'Sanayi Gece Bekçisi',
        characterAvatar: 'flashlight',
        icon: Icons.security_rounded,
        dialogue:
            '"Patron koş! Arka tel örgüleri kesmeye çalışan iki şüpheli gördüm, alarmı çalıştırdım ama kaçtılar. Kamera kayıtlarını inceleyelim mi?"',
        hint: 'Güvenliği artırmak gelecekteki hırsızlık risklerini sıfırlar.',
        c1Label: 'Güvenlik Kamerasını Güçlendir • -₺3.500',
        c1Desc: 'Showroom güvenliği en üst seviyeye çıkar • +5 İtibar.',
        c1Cost: 3500.0,
        c1Title: 'Tam Korumalı Tesis',
        c1Msg: 'Yüksek çözünürlüklü kameralar kuruldu. Artık dükkan kuş uçurtmaz!',
        c1Rep: 5,
        c1Money: 0.0,
        c2Label: 'Sadece Polise Tutanak Tuttur',
        c2Desc: 'Masrafsız çözüm ancak hırsızlar tekrar deneyebilir.',
        c2Cost: 0.0,
        c2Title: 'Tutanak Kaydedildi',
        c2Msg: 'Ekipler devriye attı. Masraf yapmadın ancak tedbiri elden bırakmamak gerek.',
        c2Rep: 1,
        c2Money: 0.0,
      ),
      (
        title: 'Sahte Para Şüphesi',
        characterName: 'Veznedar Melahat Hanım',
        characterRole: 'Kasa Sorumlusu',
        characterAvatar: 'briefcase',
        icon: Icons.payments_rounded,
        dialogue:
            '"Patron, az önce kapora bırakan müşterinin ₺20.000 destesinde 3 adet banknot şüpheli duruyor. Bankaya götüreyim mi yoksa iade mi edelim?"',
        hint: 'Sahte banknotu piyasaya sürmek ağır suçtur, dürüstlük şarttır.',
        c1Label: 'Bankaya Doğrulat & Polise Bildir',
        c1Desc: 'Zararı üstlenirsin ancak dürüst esnaf itibarın tescillenir • +8 İtibar.',
        c1Cost: 600.0,
        c1Title: 'Örnek Esnaf Tavrı',
        c1Msg: 'Sahte banknotlar imha edildi, emniyet duyarlılığınız için teşekkür etti.',
        c1Rep: 8,
        c1Money: 0.0,
        c2Label: 'Müşteriyi Arayıp Parayı Değiştirttir',
        c2Desc: '%80 müşteri özür dileyip yenisini verir, %20 inkar eder.',
        c2Cost: 0.0,
        c2Title: 'Tatlıya Bağlandı',
        c2Msg: 'Müşteri bankamatikten çektiğini söyleyip parayı anında değiştirdi.',
        c2Rep: 2,
        c2Money: 0.0,
      ),
    ];

    final pick = variations[rng.nextInt(variations.length)];
    return DramaticCardModel(
      id: 'drama_day_$day',
      category: DramaticCategory.betrayal,
      severity: DramaticSeverity.medium,
      title: pick.title,
      characterName: pick.characterName,
      characterRole: pick.characterRole,
      characterAvatar: pick.characterAvatar,
      icon: pick.icon,
      dialogue: pick.dialogue,
      foreshadowHint: pick.hint,
      choices: [
        DramaticChoiceModel(
          id: 'dr_${day}_1',
          label: pick.c1Label,
          shortDescription: pick.c1Desc,
          upfrontCost: pick.c1Cost,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: pick.c1Title,
              message: pick.c1Msg,
              isSuccess: true,
              moneyDelta: pick.c1Money,
              reputationDelta: pick.c1Rep,
              xpReward: 60,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'dr_${day}_2',
          label: pick.c2Label,
          shortDescription: pick.c2Desc,
          upfrontCost: pick.c2Cost,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: pick.c2Title,
              message: pick.c2Msg,
              isSuccess: true,
              moneyDelta: pick.c2Money,
              reputationDelta: pick.c2Rep,
              xpReward: 40,
            ),
          ],
        ),
      ],
    );
  }

  static DramaticCardModel _generateOpportunityCard(int day, Random rng) {
    final variations = [
      (
        title: 'Gümrük Tasfiye Tüyosu',
        characterName: 'Gümrük Komisyoncusu Tarık',
        characterRole: 'Liman Temsilcisi',
        characterAvatar: 'detective',
        icon: Icons.directions_boat_rounded,
        dialogue:
            '"Ustam limanda tasfiye listesine girmiş temiz bir Alman klasiği var. İhale öncesi ₺12.000 dosya masrafını ödersen aracı doğrudan galerine bağlarız."',
        hint: 'Gümrük tasfiyeleri yüksek kâr marjı veya masraflı sürprizler barındırır.',
        c1Label: 'Dosya Masrafını Öde • -₺12.000',
        c1Desc: '%75 kelepir araç portföye eklenir • +₺30.000 Kâr, %25 evrak uzar.',
        c1Cost: 12000.0,
        c1Title: 'Liman Fırsatı Kasada!',
        c1Msg: 'Evraklar onaylandı ve tertemiz araç galerine çekildi. Harika bir kâr fırsatı!',
        c1Rep: 4,
        c1Money: 30000.0,
        c1Bargain: true,
        c2Label: 'Riske Girme • Teklifi Pas Geç',
        c2Desc: 'Nakitini korursun, sıfır risk.',
        c2Cost: 0.0,
        c2Title: 'Temkinli Karar',
        c2Msg: 'Bilinmeyen araç yerine mevcut vitrine odaklanmayı seçtin.',
        c2Rep: 0,
        c2Money: 0.0,
        c2Bargain: false,
      ),
      (
        title: 'İflas Eden Şirketin Filo Teklifi',
        characterName: 'Avukat Cengiz Bey',
        characterRole: 'İflas Masası Avukatı',
        characterAvatar: 'briefcase',
        icon: Icons.car_rental_rounded,
        dialogue:
            '"Müvekkil şirket tasfiye sürecinde. 3 adet ticari aracı piyasa değerinin %40 altına nakit kapatabilirsiniz. ₺25.000 peşinat gerekiyor."',
        hint: 'Hızlı nakit dönüşü sağlayabilecek büyük bir ticaret kapısı.',
        c1Label: 'Peşinatı Yatır & Fırsatı Kapat • -₺25.000',
        c1Desc: 'Filo satışından yüksek komisyon ve kâr • +₺50.000 Değer.',
        c1Cost: 25000.0,
        c1Title: 'Büyük Filo Kazancı!',
        c1Msg: 'Araçlar portföyüne geçti ve hızlıca satılarak büyük kâr getirdi!',
        c1Rep: 8,
        c1Money: 50000.0,
        c1Bargain: true,
        c2Label: 'Nakit Akışını Riske Atma',
        c2Desc: 'Sermayeni korursun.',
        c2Cost: 0.0,
        c2Title: 'Kasa Güvende',
        c2Msg: 'Büyük riske girmeden düzenli ticaretine devam ettin.',
        c2Rep: 0,
        c2Money: 0.0,
        c2Bargain: false,
      ),
    ];

    final pick = variations[rng.nextInt(variations.length)];
    return DramaticCardModel(
      id: 'opp_day_$day',
      category: DramaticCategory.opportunity,
      severity: DramaticSeverity.medium,
      title: pick.title,
      characterName: pick.characterName,
      characterRole: pick.characterRole,
      characterAvatar: pick.characterAvatar,
      icon: pick.icon,
      dialogue: pick.dialogue,
      foreshadowHint: pick.hint,
      choices: [
        DramaticChoiceModel(
          id: 'op_${day}_1',
          label: pick.c1Label,
          shortDescription: pick.c1Desc,
          upfrontCost: pick.c1Cost,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: pick.c1Title,
              message: pick.c1Msg,
              isSuccess: true,
              moneyDelta: pick.c1Money,
              reputationDelta: pick.c1Rep,
              xpReward: 80,
              spawnBargainCar: pick.c1Bargain,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'op_${day}_2',
          label: pick.c2Label,
          shortDescription: pick.c2Desc,
          upfrontCost: pick.c2Cost,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: pick.c2Title,
              message: pick.c2Msg,
              isSuccess: true,
              moneyDelta: pick.c2Money,
              reputationDelta: pick.c2Rep,
              xpReward: 30,
            ),
          ],
        ),
      ],
    );
  }

  static DramaticCardModel _generateConscienceCard(int day, Random rng) {
    final variations = [
      (
        title: 'Emekli Öğretmenin Hayali',
        characterName: 'Muallim Şükrü Bey',
        characterRole: 'Emekli Öğretmen',
        characterAvatar: 'grandma',
        icon: Icons.favorite_rounded,
        dialogue:
            '"Evladım, 30 yıllık ikramiyemle torunuma araba almak istiyorum. Bütçem ₺10.000 eksik kalıyor, bana bir kolaylık sağlar mısın?"',
        hint: 'Esnaflık sadece para değil, insanların hayatına dokunmaktır.',
        c1Label: 'İndirim Yap & Duasını Al • -₺10.000 Kâr',
        c1Desc: 'Büyük itibar ve esnaf saygınlığı kazanırsın • +12 İtibar.',
        c1Cost: 0.0,
        c1Title: 'Gönüllerin Galericisi',
        c1Msg: 'Şükrü Hoca gözyaşlarıyla teşekkür etti. Şehirde dürüst esnaflığın dilden dile yayıldı!',
        c1Rep: 12,
        c1Money: 0.0,
        c2Label: 'Fiyatı Sabit Tut • Ticari Duruş',
        c2Desc: 'Piyasa kurallarını uygularsın, kârından feragat etmezsin.',
        c2Cost: 0.0,
        c2Title: 'Profesyonel Satış',
        c2Msg: 'Piyasa koşullarında satış tamamlandı.',
        c2Rep: 0,
        c2Money: 0.0,
      ),
      (
        title: 'Köy Okuluna Tamirhane Desteği',
        characterName: 'Köy Muhtarı Bekir',
        characterRole: 'Köy Heyeti Temsilcisi',
        characterAvatar: 'mustache',
        icon: Icons.school_rounded,
        dialogue:
            '"Galerici bey, köyümüzün servis minibüsünün motoru arızalandı, çocuklar karda kışta yürüyor. ₺4.000 parça desteği yapabilir misiniz?"',
        hint: 'Toplumsal dayanışma galerinin marka değerini katlar.',
        c1Label: 'Parça Desteğini Karşıla • -₺4.000',
        c1Desc: 'Minibüs yola çıkar, çocuklar sevinir • +15 İtibar, +120 Deneyim.',
        c1Cost: 4000.0,
        c1Title: 'Çocukların Kahramanı!',
        c1Msg: 'Köy servisi tamir edildi. Yerel basında galerinizin cömertliği manşet oldu!',
        c1Rep: 15,
        c1Money: 0.0,
        c2Label: 'Bütçemiz Müsait Değil De',
        c2Desc: 'Paran kasada kalır.',
        c2Cost: 0.0,
        c2Title: 'Masrafsız Tercih',
        c2Msg: 'Muhtar anlayışla karşılayıp ayrıldı.',
        c2Rep: 0,
        c2Money: 0.0,
      ),
    ];

    final pick = variations[rng.nextInt(variations.length)];
    return DramaticCardModel(
      id: 'conscience_day_$day',
      category: DramaticCategory.conscience,
      severity: DramaticSeverity.low,
      title: pick.title,
      characterName: pick.characterName,
      characterRole: pick.characterRole,
      characterAvatar: pick.characterAvatar,
      icon: pick.icon,
      dialogue: pick.dialogue,
      foreshadowHint: pick.hint,
      choices: [
        DramaticChoiceModel(
          id: 'cn_${day}_1',
          label: pick.c1Label,
          shortDescription: pick.c1Desc,
          upfrontCost: pick.c1Cost,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: pick.c1Title,
              message: pick.c1Msg,
              isSuccess: true,
              moneyDelta: pick.c1Money,
              reputationDelta: pick.c1Rep,
              xpReward: 90,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'cn_${day}_2',
          label: pick.c2Label,
          shortDescription: pick.c2Desc,
          upfrontCost: pick.c2Cost,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: pick.c2Title,
              message: pick.c2Msg,
              isSuccess: true,
              moneyDelta: pick.c2Money,
              reputationDelta: pick.c2Rep,
              xpReward: 25,
            ),
          ],
        ),
      ],
    );
  }

  static DramaticCardModel _generateLegacyCard(int day, Random rng) {
    final variations = [
      (
        title: 'Televizyon Programı Çekim Teklifi',
        characterName: 'Yönetmen Barış',
        characterRole: 'Oto Dünyası Yapımcısı',
        characterAvatar: 'sunglasses',
        icon: Icons.videocam_rounded,
        dialogue:
            '"Merhaba! Ulusal kanalda yayınlanan Oto Dünyası programı için galerinizde bir bölüm çekmek istiyoruz. Sponsorluk payı ₺8.000."',
        hint: 'Milyonlarca izleyiciye ulaşarak showroom bilinirliğini artırabilir.',
        c1Label: 'Programa Sponsor Ol • -₺8.000',
        c1Desc: 'Tüm Türkiye galerini tanır • +20 İtibar, +150 Deneyim.',
        c1Cost: 800.0,
        c1Title: 'Ekranların Yıldız Galerisi!',
        c1Msg: 'Program prime-time kuşağında yayınlandı. Telefonlar kilitlendi, müşteri trafiği patladı!',
        c1Rep: 20,
        c1Money: 0.0,
        c2Label: 'Teklifi Geri Çevir',
        c2Desc: 'Sakin ve mütevazı çalışmaya devam.',
        c2Cost: 0.0,
        c2Title: 'Mütevazı Esnaf',
        c2Msg: 'Ekran ışıltısı yerine dükkanın huzurunu tercih ettin.',
        c2Rep: 0,
        c2Money: 0.0,
      ),
      (
        title: 'Klasik Otomobil Rallisi Sponsorluğu',
        characterName: 'Ralli Komiseri Vedat',
        characterRole: 'Klasik Oto Kulübü Başkanı',
        characterAvatar: 'suit',
        icon: Icons.sports_motorsports_rounded,
        dialogue:
            '"Geleneksel Şehirlerarası Klasik Otomobil Rallisi bu pazar başlıyor. Galerinizin adını ana sponsor yapmak ister misiniz? Katılım bedeli ₺10.000."',
        hint: 'Zengin ve koleksiyoncu kitleye doğrudan ulaşma imkanı.',
        c1Label: 'Ana Sponsor Ol • -₺10.000',
        c1Desc: 'Koleksiyoner müşterilerin güvenini kazan • +18 İtibar, Kelepir Klasik Tüyosu!',
        c1Cost: 10000.0,
        c1Title: 'Rallide Adın Yankılandı!',
        c1Msg: 'Kupalar galerinin standında verildi. Zengin bir koleksiyoner sana özel aracını emanet etti!',
        c1Rep: 18,
        c1Money: 0.0,
        c2Label: 'Sponsorluktan Çekil',
        c2Desc: 'Paran kasada kalır.',
        c2Cost: 0.0,
        c2Title: 'Kasa Korundu',
        c2Msg: 'Masrafsız bir hafta sonu geçirdin.',
        c2Rep: 0,
        c2Money: 0.0,
      ),
    ];

    final pick = variations[rng.nextInt(variations.length)];
    return DramaticCardModel(
      id: 'legacy_day_$day',
      category: DramaticCategory.legacy,
      severity: DramaticSeverity.medium,
      title: pick.title,
      characterName: pick.characterName,
      characterRole: pick.characterRole,
      characterAvatar: pick.characterAvatar,
      icon: pick.icon,
      dialogue: pick.dialogue,
      foreshadowHint: pick.hint,
      choices: [
        DramaticChoiceModel(
          id: 'lg_${day}_1',
          label: pick.c1Label,
          shortDescription: pick.c1Desc,
          upfrontCost: pick.c1Cost,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: pick.c1Title,
              message: pick.c1Msg,
              isSuccess: true,
              moneyDelta: pick.c1Money,
              reputationDelta: pick.c1Rep,
              xpReward: 100,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'lg_${day}_2',
          label: pick.c2Label,
          shortDescription: pick.c2Desc,
          upfrontCost: pick.c2Cost,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: pick.c2Title,
              message: pick.c2Msg,
              isSuccess: true,
              moneyDelta: pick.c2Money,
              reputationDelta: pick.c2Rep,
              xpReward: 35,
            ),
          ],
        ),
      ],
    );
  }
}
