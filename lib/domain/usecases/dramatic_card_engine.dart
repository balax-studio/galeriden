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
  /// Generates the daily dilemma card for the specified calendar day • Day 1 to 365+
  static DramaticCardModel generateDailyDilemma(int day, DealershipModel state, {Random? randomInstance}) {
    // 1. Check milestone cards first
    final milestone = _getMilestoneCard(day, state);
    if (milestone != null) {
      return milestone.copyWith(dayNumber: day);
    }

    // 2. Procedural Deterministic Selection
    final daySeed = day * 7919 + 1013;
    final rng = randomInstance ?? Random(daySeed);
    
    // Cycle dynamically through 5 vibrant categories: Comedy, Drama/Loss, Opportunity, Conscience, Legacy
    final categoryIndex = ((day * 3 + (day ~/ 7)) % 5);
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
        brand: 'Vosgen',
        modelName: 'Golf GTI Klasiği',
        modelYear: 2018,
        bodyType: 'Hatchback',
        colorHex: '#D90429',
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
  // MILESTONE CARDS • Dönüm Noktası Günleri
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

      case 21:
        return const DramaticCardModel(
          id: 'milestone_day_21',
          dayNumber: 21,
          category: DramaticCategory.betrayal,
          severity: DramaticSeverity.high,
          title: 'Protestolu Senet Yangını',
          characterName: 'Tefeci Deli Cavit',
          characterRole: 'Mahalle Çıkmazı',
          characterAvatar: 'sunglasses',
          icon: Icons.warning_amber_rounded,
          dialogue:
              '"Galerici kardeş, geçen hafta sattığın aracın arkasından gelen müşteri sana vadeli senet vermişti ya... İşte o senet karşılıksız çıktı, banka protesto çekti!"',
          foreshadowHint: 'Sütten ağzı yanan yoğurdu üfleyerek yer • Hukuk yolu mu yoksa esnaf uzlaşması mı?',
          choices: [
            DramaticChoiceModel(
              id: 'm21_lawyer',
              label: 'İcra Avukatını Devreye Sok • -₺3.000 Harç',
              shortDescription: 'Hukuk yoluyla tahsilat başlat • %80 ihtimalle ₺15.000 geri döner.',
              upfrontCost: 3000.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 0.8,
                  title: 'Yasal Zafer & Hızlı Haciz',
                  message: 'Avukat borçlunun diğer hesabına tedbir koydurdu, ana para kuruşu kuruşuna tahsil edildi!',
                  isSuccess: true,
                  moneyDelta: 15000.0,
                  reputationDelta: 5,
                  xpReward: 120,
                ),
                DramaticOutcomeModel(
                  probability: 0.2,
                  title: 'Uzatmalı Hukuk Mücadelesi',
                  message: 'Borçlu adres değiştirmiş, dava icra mahkemesinde uzadı gitti.',
                  isSuccess: false,
                  reputationDelta: 1,
                  xpReward: 40,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm21_settle',
              label: 'Bizzat Masaya Otur & Hurdayla Takas Et',
              shortDescription: 'Nakit yerine dükkanındaki yedek parçaları devral • Masrafsız çözüm.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Zararın Neresinden Dönülse Kârdır',
                  message: 'Nakit çıkmadı ama dükkandaki kaliteli jant ve motor parçalarını alıp zararı amorti ettin.',
                  isSuccess: true,
                  moneyDelta: 6000.0,
                  reputationDelta: 3,
                  xpReward: 80,
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

      case 45:
        return const DramaticCardModel(
          id: 'milestone_day_45',
          dayNumber: 45,
          category: DramaticCategory.opportunity,
          severity: DramaticSeverity.extreme,
          title: 'Samanlıkta Yatan Efsanevi Klasik',
          characterName: 'Köy Muhtarı Rüstem',
          characterRole: 'Taşra Temsilcisi',
          characterAvatar: 'mustache',
          icon: Icons.garage_rounded,
          dialogue:
              '"Galerici evlat! Rahmetli Hacı Emin Emmi\'nin samanlığında 38 yıldır branda altında yatan tek el hatasız bir Alman klasiği var. Varisler satmak istiyor, ilk sana haber verdim."',
          foreshadowHint: 'Körün istediği bir göz, Allah verdi iki göz • Saman altından su yürütmeyen temiz bir hazine!',
          choices: [
            DramaticChoiceModel(
              id: 'm45_buy_barn',
              label: 'Nakit Çantayla Köye Git & Kapat • -₺40.000',
              shortDescription: 'Koleksiyonluk antika aracı kap • Değeri ₺120.000 üzeri!',
              upfrontCost: 40000.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Samanlıktan Çıkan Sultan!',
                  message: 'Branda kalktı, nikelajlar ayna gibi parladı! Sanayide herkes hayranlıkla aracı izlemeye geldi.',
                  isSuccess: true,
                  spawnBargainCar: true,
                  reputationDelta: 20,
                  xpReward: 300,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm45_pass',
              label: 'Riske Girme & Teşekkür Et',
              shortDescription: 'Uzak köye yol masrafı yapma, nakiti galeride tut.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Temkinli Esnaflık',
                  message: 'Uzak yola gitmedin. Kasandaki sermaye hazır bekliyor.',
                  isSuccess: true,
                  reputationDelta: 0,
                  xpReward: 50,
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

      case 60:
        return const DramaticCardModel(
          id: 'milestone_day_60',
          dayNumber: 60,
          category: DramaticCategory.comedy,
          severity: DramaticSeverity.extreme,
          title: 'Gece Yarısı Çevre Yolu Kapışması',
          characterName: 'Deli Tayfun',
          characterRole: 'Şehrin Namlı Driftçisi',
          characterAvatar: 'sunglasses',
          icon: Icons.speed_rounded,
          dialogue:
              '"Usta vitrindeki turbolu makineyi ver, gece çevre yolunda rakip çetenin arabasıyla kalkış yapalım. Bahis büyük, kazanırsak parayı kırışırız!"',
          foreshadowHint: 'Dimyat\'a pirince giderken evdeki bulgurdan olma riski • Yüksek bahis mi yoksa dükkan huzuru mu?',
          choices: [
            DramaticChoiceModel(
              id: 'm60_race',
              label: 'Gizlice Anahtarı Ver • Büyük Kumar',
              shortDescription: '%60 ihtimalle ₺45.000 nakit ve şöhret, %40 araba çizilir ve ceza gelir.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 0.6,
                  title: 'Asfalt Ağladı & Kasa Doldu!',
                  message: 'Tayfun yarışı açık ara aldı! Gece yarısı dükkana çantayla ₺45.000 pay getirdi.',
                  isSuccess: true,
                  moneyDelta: 45000.0,
                  reputationDelta: 12,
                  xpReward: 200,
                ),
                DramaticOutcomeModel(
                  probability: 0.4,
                  title: 'Polis Radarı & Çizik Tampon',
                  message: 'Gece devriyesi kovalamış! Tayfun kıl payı kaçtı ama tampon çizik ve ₺8.000 ceza makbuzu kaldı.',
                  isSuccess: false,
                  moneyDelta: -8000.0,
                  reputationDelta: -6,
                  xpReward: 60,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm60_kick',
              label: 'Kapı Dışarı Et • Burası Düzgün Galeri',
              shortDescription: 'Dükkanın namusu ve araçlar güvende • +5 İtibar.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Ağırbaşlı Esnaf Duruşu',
                  message: 'Tayfun\'u dükkandan kovdun. Sanayi esnafı senin dürüstlüğünü takdir etti.',
                  isSuccess: true,
                  reputationDelta: 5,
                  xpReward: 70,
                ),
              ],
            ),
          ],
        );

      case 75:
        return const DramaticCardModel(
          id: 'milestone_day_75',
          dayNumber: 75,
          category: DramaticCategory.betrayal,
          severity: DramaticSeverity.high,
          title: 'Şüpheli Ekspertiz & Ekleme Şasi',
          characterName: 'Eksper Necmi',
          characterRole: 'Kıdemli Ekspertiz Ustası',
          characterAvatar: 'wrench',
          icon: Icons.car_crash_rounded,
          dialogue:
              '"Patron acil gel! Takasa gelen o lüks arabanın şasisini lifte kaldırdık; meğer iki ayrı pert aracın önüyle arkasını kaynakla birleştirip macunlamışlar! Takke düştü kel göründü!"',
          foreshadowHint: 'Ucuz etin yahnisi yavan olur • Ağır kusuru örtbas etmek mi yoksa ifşa etmek mi?',
          choices: [
            DramaticChoiceModel(
              id: 'm75_report',
              label: 'Satıcıya İade Et & Savcılığa Şikayet Et',
              shortDescription: 'Dolandırıcılığı ifşa et • Sanayide kahraman ilan edilirsin • +15 İtibar.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Dolandırıcılık Çökertildi!',
                  message: 'Sahtekar satıcı panikle parayı iade etti, polis şebekeyi yakaladı. Adın sanayide altın harflerle yazıldı!',
                  isSuccess: true,
                  reputationDelta: 15,
                  xpReward: 180,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm75_settle_quiet',
              label: 'Gizlice Parça Fiyatına Geri İade Al',
              shortDescription: 'Sessiz sedasız aracı geri ver, nakitini kurtar • +40 Deneyim.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Sessiz Çıkış',
                  message: 'Zarar etmeden aracı geri verdin ve konuyu kapattın.',
                  isSuccess: true,
                  reputationDelta: 2,
                  xpReward: 40,
                ),
              ],
            ),
          ],
        );

      case 90:
        return const DramaticCardModel(
          id: 'milestone_day_90',
          dayNumber: 90,
          category: DramaticCategory.legacy,
          severity: DramaticSeverity.medium,
          title: 'Çeyrek Yıl Maliye Barışı & Matrah Artırımı',
          characterName: 'Yeminli Mali Müşavir Fuat',
          characterRole: 'Mali Danışman',
          characterAvatar: 'briefcase',
          icon: Icons.account_balance_wallet_rounded,
          dialogue:
              '"Üç ayı geride bıraktık. Hükümet yeni bir vergi barışı ve matrah artırımı paketi açıkladı. Şimdi ₺15.000 yatırırsan önümüzdeki iki yıl boyunca maliye incelemesine karşı tam kalkan kazanırsın."',
          foreshadowHint: 'Ayağını yorganına göre uzat • Geleceğe yatırım mı yoksa parayı işletmek mi?',
          choices: [
            DramaticChoiceModel(
              id: 'm90_shield',
              label: 'Matrah Artırımına Katıl • -₺15.000',
              shortDescription: 'Mali güvence kalkanı ve temiz sicil • +12 İtibar, +150 Deneyim.',
              upfrontCost: 15000.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Mali Kalkan Sağlandı',
                  message: 'Resmi onay belgesi çerçevelenip duvara asıldı. Artık müfettiş korkusu olmadan ticaret yapabilirsin.',
                  isSuccess: true,
                  reputationDelta: 12,
                  xpReward: 150,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm90_cash_in_hand',
              label: 'Sermayeyi Kasada Bırak • Defterime Güveniyorum',
              shortDescription: 'Paranı bağlama, dürüst muhasebene güven.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Nakit Gücü',
                  message: 'Paran kasada kaldı. Fırsat araçları için hazır bekliyorsun.',
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

      case 120:
        return const DramaticCardModel(
          id: 'milestone_day_120',
          dayNumber: 120,
          category: DramaticCategory.betrayal,
          severity: DramaticSeverity.high,
          title: 'Rakip Galericinin Sahte Yorum Saldırısı',
          characterName: 'Bilişim Uzmanı Kerem',
          characterRole: 'İtibar Danışmanı',
          characterAvatar: 'sunglasses',
          icon: Icons.rate_review_rounded,
          dialogue:
              '"Patron, rakip oto galeri tuttuğu bot hesaplarla harita sayfamıza bir gecede yüzlerce 1 yıldızlı sahte yorum ve iftira yağdırdı! Telefonlar kesildi."',
          foreshadowHint: 'Meyve veren ağaç taşlanır • Hukuk ve siber danışmanlık ile karşı atağa geçmek şart.',
          choices: [
            DramaticChoiceModel(
              id: 'm120_counter',
              label: 'Bilişim Avukatı & Siber Temizlik • -₺6.000',
              shortDescription: 'Sahte yorumları sildir ve rakibi savcılığa ver • +18 İtibar.',
              upfrontCost: 6000.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'İtibar Zaferle Temizlendi!',
                  message: 'Platform tüm sahte hesapları sildi ve rakip galericiye yüklü tazminat davası açıldı!',
                  isSuccess: true,
                  reputationDelta: 18,
                  xpReward: 200,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm120_video',
              label: 'Vitrinden Şeffaflık Videosu Yayınla • Masrafsız',
              shortDescription: 'Sosyal medyada samimi bir video çekip gerçeği anlat • +10 İtibar.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Halkın Desteği Yanında!',
                  message: 'Videon viral oldu! Eski müşterilerin sayfana akın edip seni öven yorumlar yazdı.',
                  isSuccess: true,
                  reputationDelta: 10,
                  xpReward: 120,
                ),
              ],
            ),
          ],
        );

      case 150:
        return const DramaticCardModel(
          id: 'milestone_day_150',
          dayNumber: 150,
          category: DramaticCategory.comedy,
          severity: DramaticSeverity.medium,
          title: 'Aşiret Düğünü Gelin Arabası Krizi',
          characterName: 'Kirve Mahmut Ağa',
          characterRole: 'Aşiret Temsilcisi',
          characterAvatar: 'mustache',
          icon: Icons.celebration_rounded,
          dialogue:
              '"Galerici bey! Yeğenimin düğünü var, vitrindeki en fiyakalı siyah vitrin arabasını 3 günlüğüne gelin arabası yapacağız. Masrafı neyse iki katını veririz ama konvoyda korna çalmaktan şanzıman ısınırsa karışmam!"',
          foreshadowHint: 'Hamama giren terler • Yüksek kiralama geliri mi yoksa arabanın sağlığı mı?',
          choices: [
            DramaticChoiceModel(
              id: 'm150_rent',
              label: 'Özel Şoförünle Kirala • +₺25.000 Gelir',
              shortDescription: 'Kendi güvendiğin şoförü direksiyona oturt, aracı koru • +10 İtibar.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 0.85,
                  title: 'Görkemli Düğün & Bol Bahşiş',
                  message: 'Şoförün aracı tereyağından kıl çeker gibi idare etti. Aşiret cömertçe ₺25.000 ödedi!',
                  isSuccess: true,
                  moneyDelta: 25000.0,
                  reputationDelta: 10,
                  xpReward: 160,
                ),
                DramaticOutcomeModel(
                  probability: 0.15,
                  title: 'Ufak Çizik & Ekstra Cila',
                  message: 'Düğün coşkusunda tavana konfeti yapışmış, ₺3.000 temizlik masrafı çıktı ama kâr yine büyük.',
                  isSuccess: true,
                  moneyDelta: 18000.0,
                  reputationDelta: 5,
                  xpReward: 100,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm150_decline',
              label: 'Araçlar Sadece Satılıktır De • Kibarca Reddet',
              shortDescription: 'Araban vitrinde sıfır riskle kalsın.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Vitrin Korundu',
                  message: 'Ağa başka yere gitti, showroomun düzeni bozulmadı.',
                  isSuccess: true,
                  reputationDelta: 1,
                  xpReward: 30,
                ),
              ],
            ),
          ],
        );

      case 180:
        return const DramaticCardModel(
          id: 'milestone_day_180',
          dayNumber: 180,
          category: DramaticCategory.legacy,
          severity: DramaticSeverity.high,
          title: 'Yarı Yıl Ticaret Odası Özel Plaketi',
          characterName: 'Ticaret Odası Başkanı',
          characterRole: 'Protokol Başkanı',
          characterAvatar: 'suit',
          icon: Icons.military_tech_rounded,
          dialogue:
              '"Altı ayı geride bıraktınız. Şehrin en dürüst ve cirosu en yüksek bağımsız galerilerinden biri olarak Ticaret Odası Üstün Esnaflık Plaketi\'ne layık görüldünüz."',
          foreshadowHint: 'Yarım yıllık alın teri meyvesini veriyor.',
          choices: [
            DramaticChoiceModel(
              id: 'm180_accept',
              label: 'Protokol Törenine Katıl • -₺5.000 Bağış',
              shortDescription: 'Şehrin önde gelen iş insanlarıyla tanış • +22 İtibar, +200 Deneyim.',
              upfrontCost: 5000.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Plaket Vitrinde Parlıyor!',
                  message: 'Törende alkışlar eşliğinde plaketi aldın. Yerel gazeteler galerini örnek işletme yazdı.',
                  isSuccess: true,
                  reputationDelta: 22,
                  xpReward: 200,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm180_humble',
              label: 'Törensiz Plaketi Kabul Et • Mütevazı',
              shortDescription: 'Masrafsız kabul et • +10 İtibar.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Sade Başarı',
                  message: 'Plaket dükkana teslim edildi ve kasadaki parayı korudun.',
                  isSuccess: true,
                  reputationDelta: 10,
                  xpReward: 80,
                ),
              ],
            ),
          ],
        );

      case 200:
        return const DramaticCardModel(
          id: 'milestone_day_200',
          dayNumber: 200,
          category: DramaticCategory.opportunity,
          severity: DramaticSeverity.extreme,
          title: 'Gurbetçi Hasan Emmi\'nin Döviz Bavulu',
          characterName: 'Gurbetçi Hasan',
          characterRole: 'Köln Emeklisi',
          characterAvatar: 'mustache',
          icon: Icons.euro_rounded,
          dialogue:
              '"Selamünaleyküm hemşerim! Almanya\'dan kesin dönüş yaptım. Köyün yollarında tozu dumana katacak, akarı kokarı olmayan sağlam bir Alman arabası istiyorum. Nakit döviz bavulda hazır!"',
          foreshadowHint: 'Ağzı laf yapan esnaf kazanır • Doğru aracı sunarsan büyük kâr kasada.',
          choices: [
            DramaticChoiceModel(
              id: 'm200_deal',
              label: 'En Değerli Vitrin Aracını Sat & Döviz Kârı Al',
              shortDescription: 'Piyasa değerinin %25 üzerine peşin nakit satış • +₺60.000 Kâr!',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Tarihi Dövizli Satış!',
                  message: 'Hasan Emmi arabayı gördüğü gibi bayıldı ve parayı kuruşuna kadar masaya saydı!',
                  isSuccess: true,
                  moneyDelta: 60000.0,
                  reputationDelta: 15,
                  xpReward: 250,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm200_tea',
              label: 'Çay İkram Et & Pazarlıkta Esne',
              shortDescription: 'Dostluk kur, gelecekte akrabalarını da getirsin • +₺40.000 Kâr, +20 İtibar.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Gurbetçi Ağının Anahtarı',
                  message: 'Hasan Emmi Almanya\'daki tüm akrabalarına senin kartvizitini dağıtacağını söyledi!',
                  isSuccess: true,
                  moneyDelta: 40000.0,
                  reputationDelta: 20,
                  xpReward: 220,
                ),
              ],
            ),
          ],
        );

      case 240:
        return const DramaticCardModel(
          id: 'milestone_day_240',
          dayNumber: 240,
          category: DramaticCategory.betrayal,
          severity: DramaticSeverity.extreme,
          title: 'Sahte Noter & İkiz Plaka Operasyonu',
          characterName: 'Başkomiser Murat',
          characterRole: 'Asayiş Şube Amiri',
          characterAvatar: 'detective',
          icon: Icons.local_police_rounded,
          dialogue:
              '"Galerici Bey, şehre dadanan profesyonel bir ikiz plaka şebekesi var. Dükkanınızın önünden geçen şüpheli bir lüks aracın şasi numarasını kontrol etmemiz için desteğinize ihtiyacımız var."',
          foreshadowHint: 'Devletin yanında duran esnafın sırtı yere gelmez.',
          choices: [
            DramaticChoiceModel(
              id: 'm240_cooperate',
              label: 'Polise Tam Destek Ver & Tuzağı Kur',
              shortDescription: 'Emniyetle iş birliği yap • Çete yakalanırsa +25 İtibar ve Takdir Belgesi.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Kusursuz Asayiş Operasyonu!',
                  message: 'Şebeke suçüstü yakalandı! Emniyet Müdürü şahsen teşekkür edip galerinize teşekkür plaketi verdi.',
                  isSuccess: true,
                  reputationDelta: 25,
                  xpReward: 300,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm240_stay_out',
              label: 'Karışmak İstemiyorum De • Tarafsız Kal',
              shortDescription: 'İşine bak, sıfır risk.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Olaylardan Uzak',
                  message: 'Polis başka yerde operasyonu yaptı, dükkanın olağan seyrinde devam etti.',
                  isSuccess: true,
                  reputationDelta: 0,
                  xpReward: 40,
                ),
              ],
            ),
          ],
        );

      case 270:
        return const DramaticCardModel(
          id: 'milestone_day_270',
          dayNumber: 270,
          category: DramaticCategory.opportunity,
          severity: DramaticSeverity.high,
          title: 'Konsolosluk Zırhlı Filo Tasfiyesi',
          characterName: 'Ataşe Temsilcisi Stefan',
          characterRole: 'Diplomatik Misyon',
          characterAvatar: 'suit',
          icon: Icons.shield_rounded,
          dialogue:
              '"Konsolosluğumuzun görev süresi dolan 2 adet zırhlı diplomatik arazi aracını kapalı teklif usulüyle satıyoruz. Teminat bedeli ₺30.000."',
          foreshadowHint: 'Çantada keklik bir fırsat • Doğru teklifle servet kazandırabilir.',
          choices: [
            DramaticChoiceModel(
              id: 'm270_bid',
              label: 'Teminatı Yatır & Teklif Ver • -₺30.000',
              shortDescription: '%75 ihtimalle zırhlı efsane filoya eklenir • Değeri ₺100.000 üzeri!',
              upfrontCost: 30000.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 0.75,
                  title: 'Diplomatik Hazine Kasada!',
                  message: 'Kapalı zarf ihalesini kazandın! Kusursuz zırhlı araç galerinin vitrininde yerini aldı.',
                  isSuccess: true,
                  spawnBargainCar: true,
                  moneyDelta: 50000.0,
                  reputationDelta: 18,
                  xpReward: 250,
                ),
                DramaticOutcomeModel(
                  probability: 0.25,
                  title: 'Başka Bir Teklif Geçti',
                  message: 'Teminatın iade edildi ancak araçları alamadın. Sadece dosya harcı kesildi.',
                  isSuccess: false,
                  moneyDelta: 28000.0,
                  reputationDelta: 2,
                  xpReward: 50,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm270_pass',
              label: 'İhaleye Girme • Nakiti Koru',
              shortDescription: 'Sermayeni garantiye al.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Kasayı Korumak',
                  message: 'İhaleye girmedin, dükkanın nakit akışı bozulmadı.',
                  isSuccess: true,
                  reputationDelta: 0,
                  xpReward: 30,
                ),
              ],
            ),
          ],
        );

      case 300:
        return const DramaticCardModel(
          id: 'milestone_day_300',
          dayNumber: 300,
          category: DramaticCategory.comedy,
          severity: DramaticSeverity.high,
          title: 'Kripto Zengin Çocuğunun Ani Çıkışı',
          characterName: 'Kripto Fenomeni Batuhan',
          characterRole: 'Sosyal Medya Yıldızı',
          characterAvatar: 'sunglasses',
          icon: Icons.currency_bitcoin_rounded,
          dialogue:
              '"Patron sabah coin patladı, cüzdanda para kaynıyor! Şu köşedeki vitrin arabalarını nakit alıp hemen anahtarları teslim almak istiyorum. Üstüne ₺50.000 komisyon veririm ama hemen noter açtıracaksın!"',
          foreshadowHint: 'Sineğin yağını hesaplamayan bol kepçe müşteri • Hızlı noter mi yoksa temkinli devir mi?',
          choices: [
            DramaticChoiceModel(
              id: 'm300_notary',
              label: 'Özel Nöbetçi Noter Ayarla • Satışı Kapat',
              shortDescription: 'Büyük komisyonu cebe indir • +₺80.000 Kazanç!',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Yüzyılın Hızlı Satışı!',
                  message: 'Paralar anında banka hesabına geçti, Batuhan arabalarıyla kornaya basarak ayrıldı!',
                  isSuccess: true,
                  moneyDelta: 80000.0,
                  reputationDelta: 16,
                  xpReward: 250,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm300_wait',
              label: 'Pazartesi Günü Yasal Süreçte Gel De',
              shortDescription: 'Gece acelesine güvenme • Güvenli yol.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Temkinli Tüccar',
                  message: 'Müşteri aceleyle başka şehre gitti, sen ise sıfır riskle dükkanını korudun.',
                  isSuccess: true,
                  reputationDelta: 2,
                  xpReward: 50,
                ),
              ],
            ),
          ],
        );

      case 330:
        return const DramaticCardModel(
          id: 'milestone_day_330',
          dayNumber: 330,
          category: DramaticCategory.opportunity,
          severity: DramaticSeverity.high,
          title: 'Yıl Sonu ÖTV ve Enflasyon Söylentisi',
          characterName: 'Otomotiv Gazetecisi Sinan',
          characterRole: 'Sektör Analisti',
          characterAvatar: 'briefcase',
          icon: Icons.trending_up_rounded,
          dialogue:
              '"Yeni yılda sıfır ve ikinci el araçlara devasa ÖTV zammı ve kur güncellemesi geleceği Ankara kulislerinde konuşuluyor. Elindeki araçları tutarsan değerleri katlanacak!"',
          foreshadowHint: 'Alırken kazandıran ticaret kuralı • Stokta beklemek mi yoksa hızlı nakit çevirmek mi?',
          choices: [
            DramaticChoiceModel(
              id: 'm330_hold',
              label: 'Stokları Kapat & Yeni Yılı Bekle',
              shortDescription: 'Tüm araçların vitrin değerinde genel değer artışı beklentisi.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Vizyoner Stok Yönetimi',
                  message: 'Piyasa hareketlendi ve galerin şehirdeki en değerli filoya sahip oldu!',
                  isSuccess: true,
                  reputationDelta: 15,
                  xpReward: 200,
                ),
              ],
            ),
            DramaticChoiceModel(
              id: 'm330_liquidate',
              label: 'Fırsatı Kaçırma & Hızlıca Sat • Nakite Geç',
              shortDescription: 'Yüksek fiyattan hemen müşteri bul • +₺35.000 Hızlı Kazanç.',
              upfrontCost: 0.0,
              outcomes: [
                DramaticOutcomeModel(
                  probability: 1.0,
                  title: 'Sıcak Nakit Gücü',
                  message: 'Panik alıcılarına hızlıca satış yaptın, kasan parayla doldu.',
                  isSuccess: true,
                  moneyDelta: 35000.0,
                  reputationDelta: 8,
                  xpReward: 120,
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
  // PROCEDURAL CATEGORY GENERATORS • Zengin ve Çeşitli Olay Havuzu
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
        hint: 'Kaş yaparken göz çıkarmak • Müşteri görmek üzere, hızlı bir karar vermek gerek.',
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
      (
        title: 'Boyasız Göçükçünün Manyetik Şovu',
        characterName: 'Göçükçü İrfan Usta',
        characterRole: 'Sanayi Sanatkârı',
        characterAvatar: 'wrench',
        icon: Icons.hardware_rounded,
        dialogue:
            '"Patron, yeni aldığım vakumlu manyetik kitle arabanın kapısındaki göçüğü sıfır çekiçle çekeceğim diye iddiaya girdim, tüm çıraklar izlemeye toplandı!"',
        hint: 'Büyük lokma ye büyük söz söyleme • Gösteri başarılı olursa namın yürür.',
        c1Label: 'Ustayla Bahse Gir & İzin Ver',
        c1Desc: '%70 ihtimalle kapı kusursuz düzelir • +₺3.000 Değer, %30 vakum boyayı kaldırır.',
        c1Cost: 0.0,
        c1Title: 'Sanat Eseri Gibi Düzeltme!',
        c1Msg: 'İrfan Usta tek hamlede göçüğü jilet gibi yaptı! Çıraklar alkış tuttu.',
        c1Rep: 5,
        c1Money: 3000.0,
        c2Label: 'Macera Arama • Standart Çekiçle Yap',
        c2Desc: 'Sakin ve garanti usul • +1 İtibar.',
        c2Cost: 0.0,
        c2Title: 'Garantili Tamir',
        c2Msg: 'Klasik yöntemle yapıldı, risk alınmadı.',
        c2Rep: 1,
        c2Money: 0.0,
      ),
      (
        title: 'Stepne Havuzunda Unutulan Turşu Bidonu',
        characterName: 'Yıkamacı Memiş',
        characterRole: 'Oto Yıkama Sorumlusu',
        characterAvatar: 'cleaning_services_rounded',
        icon: Icons.water_drop_rounded,
        dialogue:
            '"Ustam takastan aldığımız arabanın bagaj stepne havuzuna köyden kalma 3 bidon kornişon turşusu koymuşlar, araba buram buram sirke kokuyor!"',
        hint: 'Akarı kokarı yok dedikleri araçtan turşu kokusu çıktı!',
        c1Label: 'Detaylı Ozon Temizliği Yaptır • -₺1.000',
        c1Desc: 'Koku tamamen çıkar, araç sıfır gibi kokar • +3 İtibar.',
        c1Cost: 1000.0,
        c1Title: 'Mis Kokulu Showroom',
        c1Msg: 'Ozon makinesi tüm kokuyu aldı, araca yeni araba kokusu sıkıldı.',
        c1Rep: 3,
        c1Money: 0.0,
        c2Label: 'Turşuları Esnafa Dağıt & Camları Aç',
        c2Desc: 'Doğal havalandırma ve komşu ikramı • Masrafsız.',
        c2Cost: 0.0,
        c2Title: 'Komşulara Ziyafet',
        c2Msg: 'Sanayi esnafı öğle yemeğinde turşuyu afiyetle yedi, arabayı da rüzgar temizledi.',
        c2Rep: 2,
        c2Money: 0.0,
      ),
      (
        title: 'Falcı Teyzenin Plaka Tılsımı',
        characterName: 'Fahriye Teyze',
        characterRole: 'Kıdemli Müşteri',
        characterAvatar: 'grandma',
        icon: Icons.auto_awesome_rounded,
        dialogue:
            '"Oğlum araba çok güzel ama plakasındaki rakamların ebced hesabına baktım, yıldızım uyuşmuyor. Bana plaka değiştirme sözü verirsen hemen alırım!"',
        hint: 'Müşteri velinimettir • Biraz sabır büyük satış getirebilir.',
        c1Label: 'Emniyetten Plaka Değişimini Üstlen • -₺1.500',
        c1Desc: 'Satış anında nakit kapanır • +₺12.000 Kâr.',
        c1Cost: 1500.0,
        c1Title: 'Yıldızlar Barıştı!',
        c1Msg: 'Yeni plaka basıldı, Fahriye Teyze mutluluktan dualar ederek aracı aldı!',
        c1Rep: 6,
        c1Money: 12000.0,
        c2Label: 'Plaka Değişmez De • Fiyatta Israr Et',
        c2Desc: 'Prensip sahibi tüccar duruşu.',
        c2Cost: 0.0,
        c2Title: 'Başka Müşteriye Kısmet',
        c2Msg: 'Teyze gitti ama araç bir sonraki gün normal müşteriye satıldı.',
        c2Rep: 0,
        c2Money: 0.0,
      ),
      (
        title: 'Sanayiye Kaçan Kurbanlık Tosun',
        characterName: 'Kasap Mahir',
        characterRole: 'Komşu Esnaf',
        characterAvatar: 'mustache',
        icon: Icons.pets_rounded,
        dialogue:
            '"Komşu kaçın! Kamyonetten atlayan tosun doğrudan galeri vitrinine doğru koşuyor, arabaların arasına girmeden yolu kapatalım!"',
        hint: 'Can havliyle koşan tosun showroom araçlarını ezebilir!',
        c1Label: 'Eski Çekiciyle Yolu Barikatla • Kahramanca',
        c1Desc: 'Showroom araçlarını koru • +10 İtibar, +80 Deneyim.',
        c1Cost: 0.0,
        c1Title: 'Sanayinin Kahramanı!',
        c1Msg: 'Çekiciyle tosunu ustalıkla çevrelediniz! Tek bir arabaya bile zarar gelmedi.',
        c1Rep: 10,
        c1Money: 0.0,
        c2Label: 'Dükkanın Kepenklerini İndir & İçeri Kaç',
        c2Desc: 'Kendini ve vitrini içeri kapat • Sıfır hasar.',
        c2Cost: 0.0,
        c2Title: 'Güvenli Kapanış',
        c2Msg: 'Tosun yoldan geçti gitti. Kimsenin burnu kanamadı.',
        c2Rep: 2,
        c2Money: 0.0,
      ),
      (
        title: 'Motor Kaputunda Uyuyan Kedi',
        characterName: 'Çırak Caner',
        characterRole: 'Hevesli Çırak',
        characterAvatar: 'wrench',
        icon: Icons.pets_rounded,
        dialogue:
            '"Usta, vitrindeki arabanın motor kaputuna sarman bir kedi kıvrılmış mışıl mışıl uyuyor. Müşteri aracı incelemeye geliyor, kediyi kovalayayım mı?"',
        hint: 'Esnafın merhameti müşterinin kalbine dokunur • Hızlı davranmak ise satışı garantiye alabilir.',
        c1Label: 'Kediyi Uyandırma • Esnaf Merhameti',
        c1Desc: 'Müşteriyi çay ocağında ağırla ve uyanmasını bekle • +6 İtibar, +40 Deneyim.',
        c1Cost: 0.0,
        c1Title: 'Merhametli Esnaf Takdiri',
        c1Msg: 'Müşteri bu samimi esnaf duruşuna hayran kaldı. Bir bardak çay eşliğinde aracı hiç pazarlıksız aldı!',
        c1Rep: 6,
        c1Money: 3500.0,
        c2Label: 'Kornaya Bas & Kediyi Ürküt',
        c2Desc: 'Müşteriye hemen aracı göster • Sıfır masraf.',
        c2Cost: 0.0,
        c2Title: 'Acele Satış',
        c2Msg: 'Kedi kaçtı, müşteri aracı inceledi ancak esnafın telaşından biraz rahatsız oldu.',
        c2Rep: -2,
        c2Money: 1000.0,
      ),
      (
        title: 'Habersiz Çaya Gelen Akrabalar',
        characterName: 'Hulusi Dayı',
        characterRole: 'Uzak Akraba',
        characterAvatar: 'mustache',
        icon: Icons.family_restroom_rounded,
        dialogue:
            '"Hayırlı işler yeğenim! Köyden geldik, oğlanı da getirdim galerini görsün dedik. Masaya 5 demli çay söyle de araba bakan müşteriye bizim köyün pazarını anlatalım!"',
        hint: 'Akraba ziyareti esnafın en zor sınavıdır • Müşteriyi kaçırmadan dengeyi kurmak gerek.',
        c1Label: 'Kuru Pasta ve Çay Ismarla • -₺600',
        c1Desc: 'Akrabaları arka ofise alıp ağırla, showroomu sakin tut • +4 İtibar.',
        c1Cost: 600.0,
        c1Title: 'Tatlı Dilli Ev Sahibi',
        c1Msg: 'Akrabalar arka odada pastalarını yerken sen ön tarafta müşteriye satışı başarıyla bağladın.',
        c1Rep: 4,
        c1Money: 2500.0,
        c2Label: 'Şimdi Ticaret Zamanı De • Kibarca Uyar',
        c2Desc: 'Masrafsız ancak aile içinde biraz dedikodu konusu olabilir.',
        c2Cost: 0.0,
        c2Title: 'Profesyonel Mesafe',
        c2Msg: 'Hulusi Dayı biraz bozulup çarşıya gitti ama showroom düzeni ve odak bozulmadı.',
        c2Rep: 1,
        c2Money: 0.0,
      ),
      (
        title: 'Sanayi Çaycısının Kabarık Çetelesi',
        characterName: 'Çaycı Necati',
        characterRole: 'Ocakçı Esnafı',
        characterAvatar: 'support_agent_rounded',
        icon: Icons.emoji_food_beverage_rounded,
        dialogue:
            '"Selamünaleyküm usta! Ay sonu hesabı geldi. Senin çıraklar ve gelen giden müşteriler tam 420 bardak çay içmiş. Pusulayı bırakıyorum, hesabı kapatalım."',
        hint: 'Esnaf hukuku çay ocağından geçer • İtiraz etmek dedikodu başlatabilir.',
        c1Label: 'Pusulayı İncelemeden Öde • -₺2.100',
        c1Desc: 'Sanayi esnafıyla dostluk pekişir, sıcak çaylar kesilmez • +5 İtibar.',
        c1Cost: 2100.0,
        c1Title: 'Cömert Galericinin Şanı',
        c1Msg: 'Necati Usta tüm sanayiye senin cömertliğini anlattı, komşular sana yönlendirme yapmaya başladı.',
        c1Rep: 5,
        c1Money: 1500.0,
        c2Label: 'Çeteleyi Masaya Yatır & Pazarlık Yap • -₺1.200',
        c2Desc: 'Gerçek bardağı hesapla, kasadaki parayı koru.',
        c2Cost: 1200.0,
        c2Title: 'Sıkı Hesap Uzmanı',
        c2Msg: 'Hesap düzeltildi, Necati Usta hafif homurdandı ama kuruşuna kadar doğru ödeme yapıldı.',
        c2Rep: 1,
        c2Money: 0.0,
      ),
      (
        title: 'Sanayide Düğün Konvoyu Baskını',
        characterName: 'Kirve Selim',
        characterRole: 'Düğün Sahibi',
        characterAvatar: 'mustache',
        icon: Icons.celebration_rounded,
        dialogue:
            '"Selamünaleyküm komşu! Gelin alayı sanayi caddesinde tıkandı, gelin arabasının tülleri rüzgarda uçtu. Vitrindeki arabayı 10 dakika süsletip yolu açalım mı?"',
        hint: 'Düğün telaşı esnafın neşesidir • Hızlı bir jest sanayide büyük dostluk kazandırır.',
        c1Label: 'Çırakları Seferber Et & Arabayı Süsle • -₺400',
        c1Desc: 'Kurdele ve çiçeklerle gelin arabasını hazırla • +6 İtibar, +45 Deneyim.',
        c1Cost: 400.0,
        c1Title: 'Konvoyun Gözbebeği!',
        c1Msg: 'Çıraklar 5 dakikada arabayı gelin gibi süsledi! Düğün alayı kornalar ve dualarla ayrıldı.',
        c1Rep: 6,
        c1Money: 2000.0,
        c2Label: 'Galerinin Önünü Açmalarını İste',
        c2Desc: 'Vitrini ve yolu sakin tut • Masrafsız.',
        c2Cost: 0.0,
        c2Title: 'Sakin Yol',
        c2Msg: 'Konvoy yavaşça ilerledi, showroom düzeni korundu.',
        c2Rep: 1,
        c2Money: 0.0,
      ),
      (
        title: 'Noterde Elektrik ve Sistem Çökmesi',
        characterName: 'Noter Katibi Veli',
        characterRole: 'Noter Görevlisi',
        characterAvatar: 'briefcase',
        icon: Icons.electrical_services_rounded,
        dialogue:
            '"Beyler tam imza aşamasında genel sistem kilitlendi, ekranlar gitti! İki saat bekleyeceğiz gibi duruyor, alıcı da gerilmeye başladı."',
        hint: 'Sabır acıdır ama meyvesi tatlıdır • Müşteriyi çay ocağında sakinleştirmek gerek.',
        c1Label: 'Alıcıyı Çay Ocağına Götür & Sohbet Et • -₺300',
        c1Desc: 'Sıcak çay ve esnaf hikayeleriyle havayı yumuşat • +5 İtibar.',
        c1Cost: 300.0,
        c1Title: 'Dost Meclisinde İmza',
        c1Msg: 'Sistem açılınca müşteri kahkahalarla imza attı! Satış tatlıya bağlandı.',
        c1Rep: 5,
        c1Money: 3000.0,
        c2Label: 'Noter Önünde Sessizce Bekle',
        c2Desc: 'Masrafsız bekleme • Alıcı hafif gergin kalır.',
        c2Cost: 0.0,
        c2Title: 'Gecikmeli Devir',
        c2Msg: 'Sistem açıldı ve işlem sessizce tamamlandı.',
        c2Rep: 1,
        c2Money: 0.0,
      ),
      (
        title: 'Çırağın Ehliyet Sevinci',
        characterName: 'Çırak Caner',
        characterRole: 'Taze Sürücü',
        characterAvatar: 'wrench',
        icon: Icons.badge_rounded,
        dialogue:
            '"Ustam müjde! Direksiyon sınavını tek seferde geçtim, ehliyet cebimde! Kutuyla baklava getirdim, vitrindeki arabayı içeri ben çekebilir miyim?"',
        hint: 'Gençlerin hevesi esnafın geleceğidir • Ölçülü sorumluluk vermek güven aşılar.',
        c1Label: 'Baklavayı Bölüş & Yanına Oturup Park Ettir',
        c1Desc: 'Çırağı tebrik et ve kontrollü sürüş deneyimi yaşat • +7 İtibar, +80 Deneyim.',
        c1Cost: 0.0,
        c1Title: 'Gururlu Usta ve Sevinçli Çırak',
        c1Msg: 'Caner milimetrik park etti! Sanayi komşuları dükkana gelip tatlıyı paylaştı.',
        c1Rep: 7,
        c1Money: 0.0,
        c2Label: 'Tebrik Et Ama Anahtarı Verme',
        c2Desc: 'Garantici ve temkinli duruş • Sıfır risk.',
        c2Cost: 0.0,
        c2Title: 'Temkinli Disiplin',
        c2Msg: 'Caner biraz buruldu ama ustasına saygısından dükkandaki işine devam etti.',
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
      (
        title: 'Eski Kabadayı ve Emanet Çanta',
        characterName: 'Gültekin Ağa',
        characterRole: 'Mahallenin Eski Namlısı',
        characterAvatar: 'sunglasses',
        icon: Icons.lock_clock_rounded,
        dialogue:
            '"Evlat, bu kilitli evrak çantasını bir hafta galerinin kasasında saklayacaksın. Kimse sormayacak, kimse açmayacak. Karşılığında galeriye kefilim."',
        hint: 'Ateşle oynayan elini yakar • Tehlikeli bir emanet mi yoksa açık kapı mı?',
        c1Label: 'Emaneti Kabul Et • Güçlü Himaye',
        c1Desc: '%70 ihtimalle sorunsuz biter ve +₺20.000 koruma primi alırsın, %30 polis denetler.',
        c1Cost: 0.0,
        c1Title: 'Emanet Teslim Edildi!',
        c1Msg: 'Hafta bitince çantayı teslim aldılar ve sana yüklü bir teşekkür zarfı bıraktılar.',
        c1Rep: 5,
        c1Money: 20000.0,
        c2Label: 'Biz Sadece Araba Alıp Satarız De • Reddet',
        c2Desc: 'Temiz ve yasal esnaflık duruşu • +4 İtibar.',
        c2Cost: 0.0,
        c2Title: 'Temiz Defter',
        c2Msg: 'Ağa anlayışla başını sallayıp gitti. Başın ağrımadı.',
        c2Rep: 4,
        c2Money: 0.0,
      ),
      (
        title: 'Haciz Memuru ve Kaçırılan SUV',
        characterName: 'İcra Memuru Haldun',
        characterRole: 'Adliye Temsilcisi',
        characterAvatar: 'briefcase',
        icon: Icons.gavel_rounded,
        dialogue:
            '"Kolay gelsin! Dün takasla aldığınız siyah lüks SUV hakkında 2 saat önce ihtiyati haciz kararı çıkmış. Aracı yediemin otoparkına çekeceğiz."',
        hint: 'Alırken kazandıran dediğin araba dert oldu!',
        c1Label: 'Avukatı Çağır & Borçluya Rücu Et • -₺2.500',
        c1Desc: 'Zararı satıcıya ödet • Hukuk kalkanı devrede.',
        c1Cost: 2500.0,
        c1Title: 'Hızlı İcra Karşı Hamlesi',
        c1Msg: 'Avukat satıcının gayrimenkulüne haciz koydurdu ve galerinin parasını kurtardı!',
        c1Rep: 4,
        c1Money: 15000.0,
        c2Label: 'Aracı Yediemine Teslim Et & Sineye Çek',
        c2Desc: 'Devletin kararına uy, yasal süreci bekle.',
        c2Cost: 0.0,
        c2Title: 'Hukuka Saygı',
        c2Msg: 'Aracı teslim ettin, mahkeme süreci başladı.',
        c2Rep: 1,
        c2Money: 0.0,
      ),
      (
        title: 'Müteahhit Takasında Heyelanlı Arsa Tuzağı',
        characterName: 'Müteahhit Ekrem',
        characterRole: 'Zor Durumdaki İnşaatçı',
        characterAvatar: 'suit',
        icon: Icons.landscape_rounded,
        dialogue:
            '"Galerici kardeşim, nakit sıkıştı. Vitrindeki araçların karşılığında sana göl manzaralı 2 dönüm arsa vereyim, hemen takas yapalım!"',
        hint: 'Görünen köy kılavuz istemez • İmarı ve zemin etüdünü araştırmadan imza atma!',
        c1Label: 'Kadastro ve Belediyeden Zemin Raporu Al • -₺2.000',
        c1Desc: 'Heyelan riskini önceden öğrenip tuzağı boz • +10 İtibar.',
        c1Cost: 2000.0,
        c1Title: 'Büyük Tuzak Bozuldu!',
        c1Msg: 'Arsanın heyelan bölgesinde olduğu ortaya çıktı! Tuzağa düşmedin, esnaf seni tebrik etti.',
        c1Rep: 10,
        c1Money: 0.0,
        c2Label: 'Takası Peşin Peşin Reddet',
        c2Desc: 'Sadece araba takası kabul et • Masrafsız.',
        c2Cost: 0.0,
        c2Title: 'Garanti Ticaret',
        c2Msg: 'Bilinmeyen gayrimenkule girmedin, araçların vitrinde kaldı.',
        c2Rep: 1,
        c2Money: 0.0,
      ),
      (
        title: 'Ani Elektrik Kesintisi ve Sıkışan Kepenk',
        characterName: 'Usta Elektrikçi Nuri',
        characterRole: 'Sanayi Elektrikçisi',
        characterAvatar: 'wrench',
        icon: Icons.power_off_rounded,
        dialogue:
            '"Patron bölgede trafo patladı, elektrikler kesildi! Müşteri aracı teslim almaya gelmişken otomatik kepenk tam yarıda kilitlendi, araba içeride mahsur!"',
        hint: 'Zaman daralıyor • Müşteri uçağa yetişecek, hızlı çözüm şart.',
        c1Label: 'Manuel Kolla Çıraklarla Asıl • Esnaf Gücü',
        c1Desc: 'Ter dökerek kepengi kaldır • +5 İtibar, +70 Deneyim.',
        c1Cost: 0.0,
        c1Title: 'Sanayi Dayanışması Zaferi',
        c1Msg: 'Çıraklarla birlikte kepengi manuel açtınız! Müşteri alkışlayarak aracını teslim aldı.',
        c1Rep: 5,
        c1Money: 0.0,
        c2Label: 'Jeneratörlü Acil Servis Çağır • -₺1.800',
        c2Desc: 'Zahmetsiz profesyonel müdahale • Masraflı garanti.',
        c2Cost: 1800.0,
        c2Title: 'Jeneratörle Hızlı Kurtarma',
        c2Msg: 'Seyyar jeneratör bağlandı ve kepenk açıldı. Müşteri memnun ayrıldı.',
        c2Rep: 3,
        c2Money: 0.0,
      ),
      (
        title: 'Kapı Önünde Lastik Yakan Mahalle Gençleri',
        characterName: 'Mahalleli Serdar',
        characterRole: 'Genç Sürücü',
        characterAvatar: 'sunglasses',
        icon: Icons.tire_repair_rounded,
        dialogue:
            '"Usta kusura bakma, yeni taktığımız egzozun sesini deniyorduk! Caddede iki tur sıfır çizdik, duman galeri vitrinine doğru geldi ama niyetimiz kötü değil."',
        hint: 'Tatlı dil yılanı deliğinden çıkarır • Racon kesmek mi yoksa gençleri eğitmek mi?',
        c1Label: 'Çay Ismarla & Pisti Göster • Mahalle Ağabeyliği',
        c1Desc: 'Gençleri caddeden güvenli piste yönlendir ve mahalleyi koru • +6 İtibar, +50 Deneyim.',
        c1Cost: 0.0,
        c1Title: 'Esnaf Ağabeyliği Saygı Topladı',
        c1Msg: 'Gençler özür dileyip dükkanı temizledi! Mahalle sakinleri sana teşekkür etti.',
        c1Rep: 6,
        c1Money: 0.0,
        c2Label: 'Sert Çıkış & Zabıtayı Çağır',
        c2Desc: 'Sokağı hemen boşalt • Net esnaf disiplini.',
        c2Cost: 0.0,
        c2Title: 'Sert Disiplin',
        c2Msg: 'Gençler dağıldı, cadde sessizliğe büründü.',
        c2Rep: 1,
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
      (
        title: 'İcradan Düşen Lüks Coupe',
        characterName: 'Müzayede Müdürü Kenan',
        characterRole: 'İcra İhale Sorumlusu',
        characterAvatar: 'suit',
        icon: Icons.gavel_rounded,
        dialogue:
            '"Patron, ikinci oturumda kimsenin teklif vermediği az hasarlı bir spor coupe yarı fiyatına düştü. ₺18.000 teminat verirsen tek teklifle aracı alırsın!"',
        hint: 'Tereyağından kıl çeker gibi fırsat • Kâr marjı çok yüksek.',
        c1Label: 'Teminatı Ver & Aracı Al • -₺18.000',
        c1Desc: 'Spor aracı kelepire kapat • +₺40.000 Kâr.',
        c1Cost: 18000.0,
        c1Title: 'Müzayede Zaferi!',
        c1Msg: 'Çekiç indi ve araba senin oldu! Sanayide pasta cila sonrası anında alıcı buldu.',
        c1Rep: 7,
        c1Money: 40000.0,
        c1Bargain: true,
        c2Label: 'İhaleye Girme • Beklemede Kal',
        c2Desc: 'Masrafsız duruş.',
        c2Cost: 0.0,
        c2Title: 'Sakin Takip',
        c2Msg: 'Kasayı açmadın, standart işine odaklandın.',
        c2Rep: 0,
        c2Money: 0.0,
        c2Bargain: false,
      ),
      (
        title: 'Fabrika Çıkışlı Test Araçları Paketi',
        characterName: 'Distribütör Bölge Sorumlusu',
        characterRole: 'Otomotiv Satış Müdürü',
        characterAvatar: 'briefcase',
        icon: Icons.factory_rounded,
        dialogue:
            '"Bayimiz yeni modele geçiyor. Sadece 5.000 km\'de 2 adet test aracını toplu alımda piyasanın %30 altına bırakabiliriz. ₺30.000 peşinat istiyoruz."',
        hint: 'Sıfır kokusu üzerinde araçlar • Müşteri kuyruğa girer.',
        c1Label: 'Peşinatı Öde & Paketi Bağla • -₺30.000',
        c1Desc: 'Neredeyse sıfır araçlarla vitrini süsle • +₺65.000 Değer.',
        c1Cost: 30000.0,
        c1Title: 'Vitrine Sıfır Kokulu Araçlar!',
        c1Msg: 'Araçlar showrooma girdiği gibi iki gün içinde satıldı, muhteşem bir kâr bıraktı!',
        c1Rep: 12,
        c1Money: 65000.0,
        c1Bargain: true,
        c2Label: 'Bütçeyi Aşma • Pas Geç',
        c2Desc: 'Sermayeni koru.',
        c2Cost: 0.0,
        c2Title: 'Temkinli Tüccar',
        c2Msg: 'Büyük borçlanmaya girmedin.',
        c2Rep: 0,
        c2Money: 0.0,
        c2Bargain: false,
      ),
      (
        title: 'Cuma Namazı Çıkışı Kalabalığı',
        characterName: 'Hacı Seyfi Bey',
        characterRole: 'Mahalle Büyüğü',
        characterAvatar: 'heritage',
        icon: Icons.groups_rounded,
        dialogue:
            '"Hayırlı cumalar evlat! Cami cemaati dağılırken vitrindeki arabalar dikkatimizi çekti. Gençler fiyat soruyor, yaşlılar da hayır duası ediyor."',
        hint: 'Cemaatin duası ve ilgisi galeriyi mahallenin gözdesi yapabilir.',
        c1Label: 'Kaldırıma Sandalye Çıkar & Su İkram Et • -₺400',
        c1Desc: 'Mahalleliyle sıcak bağ kur ve potansiyel alıcı topla • +7 İtibar, +60 Deneyim.',
        c1Cost: 400.0,
        c1Title: 'Bereketli Cuma Pazarı',
        c1Msg: 'İkramları alan cemaatten bir amca oğluna araba almak için hemen kapora bıraktı!',
        c1Rep: 7,
        c1Money: 4500.0,
        c1Bargain: true,
        c2Label: 'Showroom Kapılarını Koru • Kalabalığı İçeri Alma',
        c2Desc: 'Arabaların tozlanmasını önle ve düzeni muhafaza et.',
        c2Cost: 0.0,
        c2Title: 'Sessiz Cuma',
        c2Msg: 'Kalabalık yavaşça dağıldı, dükkanda herhangi bir karmaşa yaşanmadı.',
        c2Rep: 1,
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
        title: 'Köy Okuluna Minibüs Parçası Desteği',
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
      (
        title: 'Depremzede Ailenin Son Emaneti',
        characterName: 'Hüseyin Amca',
        characterRole: 'Afetzede Esnaf',
        characterAvatar: 'mustache',
        icon: Icons.volunteer_activism_rounded,
        dialogue:
            '"Evlat, memleketten elimizde kalan bu eski arabayla geldik. Çocuklara kiralık ev tutacağız, aracı değerinde alır mısın?"',
        hint: 'Veren el alan elden üstündür • Vicdan en büyük sermayedir.',
        c1Label: 'Piyasa Değerinin Üzerine Al • -₺6.000 Destek',
        c1Desc: 'Aileye barınma can suyu ver • +18 İtibar, +150 Deneyim.',
        c1Cost: 6000.0,
        c1Title: 'Merhametli Esnaf',
        c1Msg: 'Hüseyin Amca gözyaşlarıyla elini sıktı. Tüm sanayi çarşısı senin bu asil hareketini konuştu.',
        c1Rep: 18,
        c1Money: 0.0,
        c2Label: 'Piyasa Fiyatından Normal Satın Al',
        c2Desc: 'Standart ticaretini yap • +3 İtibar.',
        c2Cost: 0.0,
        c2Title: 'Standart Alım',
        c2Msg: 'Aracı normal fiyattan satın aldın ve nakitlerini teslim ettin.',
        c2Rep: 3,
        c2Money: 0.0,
      ),
      (
        title: 'Donmak Üzere Olan Sokak Köpekleri',
        characterName: 'Veteriner Deniz Hanım',
        characterRole: 'Hayvansever Hekim',
        characterAvatar: 'support_agent_rounded',
        icon: Icons.pets_rounded,
        dialogue:
            '"Kışın en sert gecesi. Galerinin ısıtmalı arka sundurmasını sokak köpeklerine açar mısınız? Zengin müşteriler biraz çekinebilir ama can kurtarırız."',
        hint: 'Merhamet etmeyene merhamet olunmaz.',
        c1Label: 'Sundurmayı Aç & Mama Desteği Ver • -₺1.500',
        c1Desc: 'Can dostları koru • +12 İtibar, Sosyal medyada büyük övgü.',
        c1Cost: 1500.0,
        c1Title: 'Şefkatli Yuva',
        c1Msg: 'Fotoğraflar paylaşıldı ve hayvansever müşteriler dükkanına akın etti!',
        c1Rep: 12,
        c1Money: 0.0,
        c2Label: 'Müşteri Kaybetmemek İçin İzin Verme',
        c2Desc: 'Kurumsal showroom düzenini koru.',
        c2Cost: 0.0,
        c2Title: 'Ticari Titizlik',
        c2Msg: 'Showroom düzeni bozulmadı.',
        c2Rep: 0,
        c2Money: 0.0,
      ),
      (
        title: 'Emekli Sandığı İkramiyesiyle Gelen Eski Dost',
        characterName: 'Tahir Amca',
        characterRole: 'Eski Mahalle Büyüğü',
        characterAvatar: 'grandma',
        icon: Icons.sentiment_satisfied_alt_rounded,
        dialogue:
            '"Evlat, 35 yıllık memuriyet bitti, emekli ikramiyemle torunuma ilk arabasını almaya geldim. Sana güvenim sonsuz, bizi yolda bırakmayacak temiz bir araba bağlar mıyız?"',
        hint: 'Eski dostların güveni parayla satın alınamaz • Gönül kırmak mı yoksa dua almak mı?',
        c1Label: 'Özel İkramiye İndirimi Yap & Depoyu Doldur • -₺2.500',
        c1Desc: 'Tahir Amca\'yı mutlu et ve hayır duasını al • +14 İtibar, +100 Deneyim.',
        c1Cost: 2500.0,
        c1Title: 'Eski Dostun Duası',
        c1Msg: 'Tahir Amca gözleri dolarak sarıldı. Şehirde esnaflığının dürüstlüğü bir kez daha yankılandı!',
        c1Rep: 14,
        c1Money: 0.0,
        c2Label: 'Liste Fiyatından Satış Yap',
        c2Desc: 'Standart piyasa koşulları • Masrafsız.',
        c2Cost: 0.0,
        c2Title: 'Rutin Satış',
        c2Msg: 'Satış standart fiyattan tamamlandı, ticaret devam etti.',
        c2Rep: 2,
        c2Money: 0.0,
      ),
      (
        title: 'Yağmurlu Havada Galeriye Sığınan Seyyar Satıcı',
        characterName: 'Simitçi İbrahim',
        characterRole: 'Seyyar Emekçi',
        characterAvatar: 'mustache',
        icon: Icons.umbrella_rounded,
        dialogue:
            '"Hayırlı işler ustam! Bardaktan boşanırcasına yağmur başladı, simit tablası ıslanırsa günlük ekmek param heba olacak. Ofisin kenarında biraz soluklanabilir miyim?"',
        hint: 'Veren el alan elden üstündür • Esnaf sofrası herkese açıktır.',
        c1Label: 'İçeri Buyur Et & Sıcak Çay İkram Et • -₺400',
        c1Desc: 'Soba başında ağırla, kalan simitleri personele al • +10 İtibar, +60 Deneyim.',
        c1Cost: 400.0,
        c1Title: 'Sıcak Esnaf Ocağı',
        c1Msg: 'İbrahim dualar ederek teşekkür etti. Showroomda çay simit eşliğinde sıcacık bir esnaf havası esti!',
        c1Rep: 10,
        c1Money: 0.0,
        c2Label: 'Sundurmanın Altında Beklemesini Söyle',
        c2Desc: 'Müşteri alanını koru • Dışarıda bekleme.',
        c2Cost: 0.0,
        c2Title: 'Mesafe Tercihi',
        c2Msg: 'İbrahim yağmur dinene kadar dışarıda bekleyip yoluna devam etti.',
        c2Rep: 0,
        c2Money: 0.0,
      ),
      (
        title: 'İflas Eden Komşu Esnafın Vedası',
        characterName: 'Torna Ustası Cemil',
        characterRole: '30 Yıllık Komşu',
        characterAvatar: 'wrench',
        icon: Icons.handshake_rounded,
        dialogue:
            '"Kardeşim, 30 senedir yan yana dükkan çalıştırdık. Borçlar belimi büktü, kepengi indirip memlekete dönüyorum. Dükkanın hatırası şu antika masa saatini sana emanet bırakmak istedim."',
        hint: 'Dost kara günde belli olur • Veda hüznü esnafın en ağır yüküdür.',
        c1Label: 'Emaneti Kabul Et & Yol Harçlığı Ver • -₺5.000',
        c1Desc: 'Eski komşuna vefa göster, elini bırakma • +16 İtibar, +150 Deneyim.',
        c1Cost: 5000.0,
        c1Title: 'Unutulmaz Esnaf Vefası',
        c1Msg: 'Cemil Usta gözyaşlarıyla helalleşti. Bu vefan tüm sanayi çarşısında derin saygı uyandırdı.',
        c1Rep: 16,
        c1Money: 0.0,
        c2Label: 'Saati Kabul Et & Helallik Al',
        c2Desc: 'Manevi vedalaşma • Masrafsız.',
        c2Cost: 0.0,
        c2Title: 'Hüzünlü Helalleşme',
        c2Msg: 'Cemil Usta ile sarılıp vedalaştınız, antika saat dükkanının başköşesine kondu.',
        c2Rep: 6,
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
        c1Cost: 8000.0,
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
      (
        title: 'Üniversitede Girişimcilik Konferansı',
        characterName: 'Dekan Prof. Dr. Metin',
        characterRole: 'İktisadi Bilimler Dekanı',
        characterAvatar: 'school_rounded',
        icon: Icons.co_present_rounded,
        dialogue:
            '"Sayın Galerici, sıfırdan kurup büyüttüğünüz ticaret hikayenizi üniversitemizin genç girişimci adaylarına anlatmanız için sizi onur konuğu olarak davet ediyoruz."',
        hint: 'Söz gümüşse sükut altın ama tecrübe paylaşmak geleceği inşa eder.',
        c1Label: 'Konferansa Katıl & Gençlere İlham Ol',
        c1Desc: 'Akademik çevrelerde itibar kazan • +16 İtibar, +180 Deneyim.',
        c1Cost: 0.0,
        c1Title: 'Girişimcilik Kürsüsü!',
        c1Msg: 'Salonda yüzlerce genç seni ayakta alkışladı! Şehrin entelektüel çevrelerinde büyük saygı kazandın.',
        c1Rep: 16,
        c1Money: 0.0,
        c2Label: 'İşler Yoğun De • Kibarca Reddet',
        c2Desc: 'Dükkandaki müşterilerine odaklan.',
        c2Cost: 0.0,
        c2Title: 'Esnaf Pratiği',
        c2Msg: 'Dükkandaki işlerinin başında kaldın.',
        c2Rep: 1,
        c2Money: 0.0,
      ),
      (
        title: 'Şehir Festivali Kortaj Araçları Liderliği',
        characterName: 'Kültür Dairesi Müdürü',
        characterRole: 'Belediye Temsilcisi',
        characterAvatar: 'suit',
        icon: Icons.festival_rounded,
        dialogue:
            '"Şehir Kurtuluş Festivali kortejinin öncü protokol araçlarını galerinizden tahsis etmenizi istiyoruz. Sponsorluk flamalarınız kortejin en önünde yer alacak."',
        hint: 'Tüm şehir halkı korteji izleyecek • Prestijin zirvesi.',
        c1Label: 'Korteje Sponsor Ol • -₺5.000 Masraf',
        c1Desc: 'Şehrin göz bebeği haline gel • +22 İtibar, +200 Deneyim.',
        c1Cost: 5000.0,
        c1Title: 'Kortejin En Önünde!',
        c1Msg: 'Araçlar caddeden geçerken binlerce vatandaş galerinin adını alkışladı!',
        c1Rep: 22,
        c1Money: 0.0,
        c2Label: 'Masrafa Girme • Protokolü Geri Çevir',
        c2Desc: 'Kendi yağında kavrulmaya devam.',
        c2Cost: 0.0,
        c2Title: 'Sessiz Seyir',
        c2Msg: 'Masrafsız bir festival haftası geçirdin.',
        c2Rep: 0,
        c2Money: 0.0,
      ),
      (
        title: 'Sanayi Sitesi Futbol Turnuvası',
        characterName: 'Kaptan Demir Usta',
        characterRole: 'Oto Tamirciler Derneği Kaptanı',
        characterAvatar: 'wrench',
        icon: Icons.sports_soccer_rounded,
        dialogue:
            '"Usta, sanayi siteleri arası geleneksel futbol turnuvası başlıyor. Bizim tamirciler takımının forma sponsoru olup maça kaptan olarak çıkmanı istiyoruz!"',
        hint: 'Sanayi esnafıyla halı sahada ter dökmek ve dayanışmayı pekiştirmek paha biçilemez.',
        c1Label: 'Forma Sponsoru Ol & Kaptan Çık • -₺4.000 Masraf',
        c1Desc: 'Sanayi esnafının gönlünü fethet • +18 İtibar, +150 Deneyim.',
        c1Cost: 4000.0,
        c1Title: 'Şampiyonluk Kupası Geldi!',
        c1Msg: 'Final maçında attığın son dakika golüyle kupayı kaldırdınız! Sanayi kahvehanesinde günlerce senin golün konuşuldu.',
        c1Rep: 18,
        c1Money: 0.0,
        c2Label: 'Vaktim Yok De • Turnuvayı Reddet',
        c2Desc: 'Sakatlanma riskine girme, dükkanın başında dur.',
        c2Cost: 0.0,
        c2Title: 'Maçsız Hafta Sonu',
        c2Msg: 'Esnaf biraz bozuldu ama işlerinin başından ayrılmadın.',
        c2Rep: -1,
        c2Money: 0.0,
      ),
      (
        title: 'Nostaljik Radyo Programı Röportajı',
        characterName: 'Radyocu Nihat',
        characterRole: 'Yerel Radyo Programcısı',
        characterAvatar: 'heritage',
        icon: Icons.radio_rounded,
        dialogue:
            '"Hayırlı işler usta! Sanayiden Yankılar programımızda bu hafta dürüst esnaflığı ve eski sanayi hatıralarını seninle canlı yayında konuşmak istiyoruz."',
        hint: 'Canlı yayında samimi hatıraları anlatmak şehrin dört bir yanına sesini duyurur.',
        c1Label: 'Canlı Yayına Katıl & Hikayeni Anlat',
        c1Desc: 'Tüm şehre esnaflığını dinlet • +20 İtibar, +160 Deneyim.',
        c1Cost: 0.0,
        c1Title: 'Yayın Rekor Kırdı!',
        c1Msg: 'Eski sanayi ustalarının hatıralarını anlattığın yayın dinleyicileri mest etti. Telefonlar kilitlendi, dükkana tebrik çelenkleri geldi!',
        c1Rep: 20,
        c1Money: 0.0,
        c2Label: 'Mikrofon Bana Göre Değil De • Reddet',
        c2Desc: 'Göz önünde olmayı sevmem de, işine bak.',
        c2Cost: 0.0,
        c2Title: 'Mütevazı Esnaf',
        c2Msg: 'Röportajı reddettin, dükkanın sakin huzurunda çalışmaya devam ettin.',
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
