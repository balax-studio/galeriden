import 'dart:math';

import '../../../data/models/real_estate_category.dart';
import 'contractor_negotiation_expansion.dart';
import 'real_estate_buyer_negotiation_expansion.dart';

enum ChatSenderRole {
  player,
  contractor,
  subcontractor,
  buyer,
  tenant,
  seller,
}

class ChatMessageModel {
  final String id;
  final String senderName;
  final ChatSenderRole role;
  final String message;
  final DateTime timestamp;
  final bool isFromPlayer;
  final String? badgeText;

  const ChatMessageModel({
    required this.id,
    required this.senderName,
    required this.role,
    required this.message,
    required this.timestamp,
    required this.isFromPlayer,
    this.badgeText,
  });
}

enum ChatTacticType {
  demandHigherShare, // Daire Payını Artır
  demandPrimeFloors, // Üst Kat / Şerefiye Önceliği
  demandQualityUpgrade, // C35 Beton / Kalite Artırımı
  demandAdvanceDeposit, // Nakit Teminat / Kira Avansı İste
  demandBankGuarantee, // Banka Teminat Mektubu İste
  askJokeOrChat, // Çay Ismarla & Şantiye Sohbeti (Espri / Sabır Yenileme)
  counterPrice, // Karşı Fiyat Teklif Et
  demandCashDiscount, // Peşin İndirimiyle Kabul Et
  demandDoubleShift, // Çift Vardiya & Gece Betonu
  demandCashMaterials, // Malzemeyi Peşin Alıyorum, İşçilikten Kır
  demandPenaltyClause, // Gününde Bitmezse Cezai Şartı İşletirim
  transferDeedCosts, // Tapu Masrafını Alıcıya Devret
  acceptAgreement, // Sözleşmeyi İmzala / Onayla
  walkAway, // Masadan Kalk / Reddet
}

class ChatTacticOption {
  final ChatTacticType type;
  final String labelKey;
  final int patienceCost;
  final double successChance; // 0.0 - 1.0

  const ChatTacticOption({
    required this.type,
    required this.labelKey,
    required this.patienceCost,
    required this.successChance,
  });
}

class ChatTacticExecutionPlan {
  final ChatNegotiationState stateWithPlayerMessageOnly;
  final ChatNegotiationState finalState;
  final ChatMessageModel playerMessage;
  final ChatMessageModel counterpartyReply;

  const ChatTacticExecutionPlan({
    required this.stateWithPlayerMessageOnly,
    required this.finalState,
    required this.playerMessage,
    required this.counterpartyReply,
  });
}

class ChatNegotiationState {
  final String targetId;
  final String counterpartyName;
  final ChatSenderRole counterpartyRole;
  final int patience; // 0 to 120
  final int maxPatience;
  final int satisfaction; // 0 to 100
  final double currentPrice;
  final int currentSharePercent; // 33 to 60 for contractor
  final int maxSharePercent;
  final String? contractorId;
  final List<ChatMessageModel> messages;
  final bool isAgreed;
  final bool isWalkedAway;
  final int jokeUseCount;
  final double minPrice;
  final bool hasPrimeFloorClause;
  final bool hasQualityUpgrade;
  final double contractorAdvancePaid;
  final bool hasBankGuarantee;
  final int contractorStageDays;
  final String? lastToastMessage;

  const ChatNegotiationState({
    required this.targetId,
    required this.counterpartyName,
    required this.counterpartyRole,
    this.patience = 100,
    this.maxPatience = 100,
    this.satisfaction = 50,
    required this.currentPrice,
    this.currentSharePercent = 50,
    this.maxSharePercent = 55,
    this.contractorId,
    this.messages = const [],
    this.isAgreed = false,
    this.isWalkedAway = false,
    this.jokeUseCount = 0,
    this.minPrice = 0.0,
    this.hasPrimeFloorClause = false,
    this.hasQualityUpgrade = false,
    this.contractorAdvancePaid = 0.0,
    this.hasBankGuarantee = false,
    this.contractorStageDays = 15,
    this.lastToastMessage,
  });

  ChatNegotiationState copyWith({
    int? patience,
    int? maxPatience,
    int? satisfaction,
    double? currentPrice,
    int? currentSharePercent,
    int? maxSharePercent,
    String? contractorId,
    List<ChatMessageModel>? messages,
    bool? isAgreed,
    bool? isWalkedAway,
    int? jokeUseCount,
    double? minPrice,
    bool? hasPrimeFloorClause,
    bool? hasQualityUpgrade,
    double? contractorAdvancePaid,
    bool? hasBankGuarantee,
    int? contractorStageDays,
    String? lastToastMessage,
  }) {
    return ChatNegotiationState(
      targetId: targetId,
      counterpartyName: counterpartyName,
      counterpartyRole: counterpartyRole,
      patience: patience ?? this.patience,
      maxPatience: maxPatience ?? this.maxPatience,
      satisfaction: satisfaction ?? this.satisfaction,
      currentPrice: currentPrice ?? this.currentPrice,
      currentSharePercent: currentSharePercent ?? this.currentSharePercent,
      maxSharePercent: maxSharePercent ?? this.maxSharePercent,
      contractorId: contractorId ?? this.contractorId,
      messages: messages ?? this.messages,
      isAgreed: isAgreed ?? this.isAgreed,
      isWalkedAway: isWalkedAway ?? this.isWalkedAway,
      jokeUseCount: jokeUseCount ?? this.jokeUseCount,
      minPrice: minPrice ?? this.minPrice,
      hasPrimeFloorClause: hasPrimeFloorClause ?? this.hasPrimeFloorClause,
      hasQualityUpgrade: hasQualityUpgrade ?? this.hasQualityUpgrade,
      contractorAdvancePaid: contractorAdvancePaid ?? this.contractorAdvancePaid,
      hasBankGuarantee: hasBankGuarantee ?? this.hasBankGuarantee,
      contractorStageDays: contractorStageDays ?? this.contractorStageDays,
      lastToastMessage: lastToastMessage ?? this.lastToastMessage,
    );
  }
}

class RealEstateChatNegotiationEngine {
  /// Müteahhit açılış diyalogunu oluşturur (F1·12)
  static ChatNegotiationState createContractorSession({
    required String landId,
    String? contractorName,
    required int totalUnits,
    required double baseMarketValue,
    ContractorNegotiationProfile? profile,
    int playerReputationScore = 0,
  }) {
    final effectiveProfile = profile;
    final name = effectiveProfile?.defaultName ??
        contractorName ??
        'Metropol Yapı Mimarlık';
    final initialShare = effectiveProfile?.initialOfferPercent ?? 50;
    int maxCap = effectiveProfile?.maxCapPercent ?? 55;
    if (playerReputationScore >= 700) {
      maxCap = max(maxCap, 60); // F1·12: Yüksek itibar pay tavanını %60'a çıkarır
    }
    final patience = effectiveProfile?.basePatience ?? 100;

    String openingText;
    String openingBadge;

    if (effectiveProfile != null) {
      switch (effectiveProfile.personality) {
        case ContractorPersonality.traditional:
          openingText =
              'Selamünaleyküm arsa sahibi kardeşim. Parselinizi inceledik, KAKS gereği toplam $totalUnits adet daire sığıyor. Piyasa yangın yeri, demirin tonu dolara bağlı. Biz %$initialShare arsa sahibine, %${100 - initialShare} müteahhide kat karşılığı teklif ediyoruz. Dededen kalma dürüstlükle temeli atalım.';
          openingBadge = '%$initialShare - %${100 - initialShare} KAT KARŞILIĞI';
          break;
        case ContractorPersonality.aggressive:
          openingText =
              'Hayırlı işler. Parselinize KAKS gereği toplam $totalUnits daire planladık. %$initialShare kat karşılığı gireriz. Çift vardiya çalışır, 14 ayda anahtar teslim ederiz. Hızlı olan kazanır!';
          openingBadge = '%$initialShare - %${100 - initialShare} HIZLI DÖNÜŞÜM';
          break;
        case ContractorPersonality.cooperative:
          openingText =
              'Hoş geldiniz komşum. Biz mahallenin çocuğuyuz. Bu arsaya $totalUnits daire için %$initialShare payla teklif veriyoruz. Malzemeden çalmayız, komşuluk hukukunu gözetiriz.';
          openingBadge = '%$initialShare - %${100 - initialShare} MAHALLE ORTAKLIĞI';
          break;
        case ContractorPersonality.luxury:
          openingText =
              'İyi günler. Parselinizin lokasyonuna yakışır $totalUnits bağımsız bölümlük rezidans projesi tasarladık. %$initialShare kat karşılığıyla C40 statik beton ve kapalı otopark vaat ediyoruz.';
          openingBadge = '%$initialShare - %${100 - initialShare} LÜKS REZİDANS';
          break;
        case ContractorPersonality.corporate:
          openingText =
              'Merhaba, parseliniz için KAKS ve çekme mesafesi simülasyonları yapıldı. Toplam $totalUnits adet daire sığıyor. %$initialShare arsa payı ve kurumsal taahhüt güvencesiyle başlamayı teklif ediyoruz.';
          openingBadge = '%$initialShare - %${100 - initialShare} KURUMSAL TEKLİF';
          break;
      }
    } else {
      openingText =
          'Selamlar, parselinizin imar durumunu inceledik. Bu arsaya KAKS gereği toplam $totalUnits adet daire sığıyor. %$initialShare - %${100 - initialShare} kat karşılığı anlaşma öneriyoruz. Arsa sizden, inşaat bizden.';
      openingBadge = '%$initialShare - %${100 - initialShare} KAT KARŞILIĞI';
    }

    final openingMessage = ChatMessageModel(
      id: 'msg_0',
      senderName: name,
      role: ChatSenderRole.contractor,
      message: openingText,
      timestamp: DateTime.now(),
      isFromPlayer: false,
      badgeText: openingBadge,
    );

    return ChatNegotiationState(
      targetId: landId,
      counterpartyName: name,
      counterpartyRole: ChatSenderRole.contractor,
      patience: patience,
      maxPatience: patience,
      satisfaction: 50,
      currentPrice: baseMarketValue,
      currentSharePercent: initialShare,
      maxSharePercent: maxCap,
      contractorId: effectiveProfile?.id,
      messages: [openingMessage],
    );
  }

  /// Alıcı/Kiracı açılış diyalogunu oluşturur
  static ChatNegotiationState createBuyerSession({
    required String propertyId,
    required String buyerName,
    required double offeredPrice,
    required String buyerNote,
    bool isRental = false,
  }) {
    final openingMessage = ChatMessageModel(
      id: 'msg_0',
      senderName: buyerName,
      role: isRental ? ChatSenderRole.tenant : ChatSenderRole.buyer,
      message: buyerNote.isNotEmpty
          ? buyerNote
          : (isRental
              ? 'İlanınızı gördüm, ailemizle uzun vadeli kiralamak istiyoruz. Şartlarda anlaşırsak hemen kontrat yapalım.'
              : 'Portföyünüzdeki gayrimenkulü inceledim, bütçem hazır ve nakit devir yapabiliriz.'),
      timestamp: DateTime.now(),
      isFromPlayer: false,
      badgeText: isRental ? 'KİRA TEKLİFİ' : 'SATIN ALMA TEKLİFİ',
    );

    return ChatNegotiationState(
      targetId: propertyId,
      counterpartyName: buyerName,
      counterpartyRole:
          isRental ? ChatSenderRole.tenant : ChatSenderRole.buyer,
      patience: 100,
      maxPatience: 100,
      satisfaction: 55,
      currentPrice: offeredPrice,
      messages: [openingMessage],
    );
  }

  /// Taktik çalıştırma durum makinesi (geriye dönük tam uyumlu)
  static ChatNegotiationState executeTactic({
    required ChatNegotiationState state,
    required ChatTacticType tactic,
    required String playerMessageText,
    required Random random,
    RealEstateCategory? propertyCategory,
  }) {
    final plan = evaluateTacticPlan(
      state: state,
      tactic: tactic,
      playerMessageText: playerMessageText,
      random: random,
      propertyCategory: propertyCategory,
    );
    return plan?.finalState ?? state;
  }

  /// Taktik çalıştırma planı: Oyuncunun mesajı ile karşı tarafın cevabını ayrı aşamalarda teslim eder
  static ChatTacticExecutionPlan? evaluateTacticPlan({
    required ChatNegotiationState state,
    required ChatTacticType tactic,
    required String playerMessageText,
    required Random random,
    RealEstateCategory? propertyCategory,
  }) {
    if (state.isAgreed || state.isWalkedAway) return null;

    // 1. Oyuncu mesajını oluştur
    final playerMessage = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_player',
      senderName: 'Siz',
      role: ChatSenderRole.player,
      message: playerMessageText,
      timestamp: DateTime.now(),
      isFromPlayer: true,
    );

    final stateWithPlayer = state.copyWith(
      messages: [...state.messages, playerMessage],
    );

    // 2. Alıcı veya Kiracı rolü ise genişletilmiş alıcı motorunu işlet
    if (state.counterpartyRole == ChatSenderRole.buyer ||
        state.counterpartyRole == ChatSenderRole.tenant) {
      final archetype = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
        state.counterpartyName,
        propertyCategory ?? RealEstateCategory.housing,
      );
      final outcome = RealEstateBuyerNegotiationExpansion.evaluateBuyerTactic(
        state: state,
        tactic: tactic,
        archetype: archetype,
        random: random,
      );

      int nextPatience = max(0, state.patience + outcome.patienceDelta);
      int nextSatisfaction =
          min(100, max(0, state.satisfaction + outcome.satisfactionDelta));
      double nextPrice = outcome.nextPrice;
      bool nextAgreed = outcome.isAgreed;
      bool nextWalkedAway = outcome.isWalkedAway;
      String replyText = outcome.replyText;
      String? replyBadge = outcome.replyBadge;

      if (nextPatience <= 0 && !nextAgreed) {
        nextWalkedAway = true;
        replyText =
            'Israrlarınız ve şartlarınız sınırımızı aştı • Masadan kalkıyoruz, teklif geçerliliğini yitirdi.';
        replyBadge = 'MASADAN KALKTI';
      }

      final replyMessage = ChatMessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_reply',
        senderName: state.counterpartyName,
        role: state.counterpartyRole,
        message: replyText,
        timestamp: DateTime.now(),
        isFromPlayer: false,
        badgeText: replyBadge,
      );

      final finalState = stateWithPlayer.copyWith(
        patience: nextPatience,
        satisfaction: nextSatisfaction,
        currentPrice: nextPrice,
        messages: [...stateWithPlayer.messages, replyMessage],
        isAgreed: nextAgreed,
        isWalkedAway: nextWalkedAway,
      );

      return ChatTacticExecutionPlan(
        stateWithPlayerMessageOnly: stateWithPlayer,
        finalState: finalState,
        playerMessage: playerMessage,
        counterpartyReply: replyMessage,
      );
    }

    // 3. Müteahhit ve diğer roller için taktik değerlendirmesi
    int nextPatience = state.patience;
    int nextSatisfaction = state.satisfaction;
    double nextPrice = state.currentPrice;
    int nextShare = state.currentSharePercent;
    int nextJokeCount = state.jokeUseCount;
    bool nextPrimeFloors = state.hasPrimeFloorClause;
    bool nextQualityUpgrade = state.hasQualityUpgrade;
    double nextAdvance = state.contractorAdvancePaid;
    bool nextBankGuarantee = state.hasBankGuarantee;
    int nextStageDays = state.contractorStageDays;
    bool nextAgreed = false;
    bool nextWalkedAway = false;
    String replyText = '';
    String? replyBadge;

    switch (tactic) {
      case ChatTacticType.demandHigherShare:
        nextPatience -= 20;
        final cap = state.maxSharePercent > 0 ? state.maxSharePercent : 58;
        if (random.nextDouble() < 0.60 && nextShare < cap) {
          nextShare += 3;
          nextSatisfaction += 10;
          final successPool = [
            'Pekala, arsanızın konumu ve potansiyeli değerli. Payınızı %$nextShare seviyesine çıkarıyoruz ancak teslim süresine 30 gün ekleriz.',
            'Arsanızın bereketi hürmetine %3 daha ekleyelim, payınız %$nextShare oldu. Yalnız ruhsat harçlarını ortak hesaptan öderiz.',
            'Pazarlığınız çetin çıktı! Sizi kırmayalım, arsa payınızı %$nextShare olarak güncelliyoruz. Hayırlı olsun.',
            'Maliyetleri son damlasına kadar sıktık. Projeye başlama hatrına daire payınızı %$nextShare yapıyoruz.',
          ];
          replyText = successPool[random.nextInt(successPool.length)];
          replyBadge = '%$nextShare PAY GÜNCELLENDİ';
        } else {
          final rejectPool = [
            'Demirin tonu ve C35 beton birim fiyatı ortada! %$nextShare payın üzerine çıkarsak cepten yeriz, kurtarmaz.',
            'İmar çekme mesafeleri ve otopark yönetmeliği yüzünden zaten metrekare kaybettik, daha fazla pay veremeyiz.',
            'Banka faizleri ve malzeme enflasyonu belimizi büküyor, %$nextShare pay bu projenin kırmızı çizgisidir.',
            'Fizibilite tablomuz kırmızı alarm veriyor patron, bu arsa için maksimum sınırımız budur.',
          ];
          replyText = rejectPool[random.nextInt(rejectPool.length)];
        }
        break;

      case ChatTacticType.demandPrimeFloors:
        nextPatience -= 15;
        if (random.nextDouble() < 0.70) {
          nextSatisfaction += 15;
          nextPrimeFloors = true;
          final primeSuccessPool = [
            'Anlaştık, projedeki en üst 2 katın ve köşe dairelerin tapusunu sizin adınıza tescil edeceğiz.',
            'Sözleşmeye şerefiye maddesi eklendi: Güney cepheli ve ferah üst kat daireleri doğrudan sizin listenize yazıldı.',
            'Kabul, en güzel manzaralı dubleks ve üst katları size ayırıyoruz, alt katları biz satarız.',
          ];
          replyText = primeSuccessPool[random.nextInt(primeSuccessPool.length)];
          replyBadge = 'ÜST KATLAR TAHSİS EDİLDİ';
        } else {
          final primeRejectPool = [
            'Şerefiye paylaşımında eşit kura çekmek zorundayız, tek taraflı üst kat veremeyiz.',
            'Üst katları satıp şantiyenin demir ve beton nakdini karşılayacağız patron, oraları verirsek inşaat tıkanır.',
            'Hak geçmesin patron, noter huzurunda kura çekimi şartımızdır.',
          ];
          replyText = primeRejectPool[random.nextInt(primeRejectPool.length)];
        }
        break;

      case ChatTacticType.demandQualityUpgrade:
        nextPatience -= 15;
        if (random.nextDouble() < 0.65) {
          nextSatisfaction += 15;
          nextQualityUpgrade = true;
          final qualitySuccessPool = [
            'C35 hazır beton, yerden ısıtma, taşyünü mantolama ve akustik ses yalıtımı şartnamesini sözleşmeye ekliyoruz.',
            'Kabul, temelden çatıya 1. sınıf C35 beton ve sessiz boru tesisatı şartnamesini imzalıyoruz.',
            'Lüks şartname onaylandı: 3 camlı ısıcam doğramalar ve C35 statik beton projeye işlendi.',
          ];
          replyText =
              qualitySuccessPool[random.nextInt(qualitySuccessPool.length)];
          replyBadge = 'LÜKS C35 ŞARTNAMESİ';
        } else {
          final qualityRejectPool = [
            'Standart C30 beton kalitemiz yönetmeliğe tam uygundur, lüks ithal donanım için bütçemiz kısıtlı.',
            'Statik mühendisimiz C30 sınıfını yeterli gördü, C35 farkı metrekare maliyetini aşırı şişirir.',
            'Şartnameyi çok ağırlaştırırsak şantiye takvimi uzar, standart kaliteli yerli malzemeyle ilerleyelim.',
          ];
          replyText =
              qualityRejectPool[random.nextInt(qualityRejectPool.length)];
        }
        break;

      case ChatTacticType.demandAdvanceDeposit:
        nextPatience -= 25;
        if (random.nextDouble() < 0.50) {
          nextSatisfaction += 20;
          nextAdvance = 350000.0;
          final advanceSuccessPool = [
            'İnşaat süresince kiranızı karşılamak adına peşin ₺350.000 nakit kira avansını hesabınıza yatırıyoruz.',
            'Kabul, taşınma ve kira masraflarınız için ₺350.000 teminat avansını noter devrinde peşin ödeyeceğiz.',
          ];
          replyText =
              advanceSuccessPool[random.nextInt(advanceSuccessPool.length)];
          replyBadge = '₺350.000 NAKİT AVANS';
        } else {
          final advanceRejectPool = [
            'Nakit akışımızı şantiye demirine bağladık, nakit avans ödemesi yapamayız.',
            'Bütün likiditeyi beton santraline peşin bağladık, kasada kira avansı verecek nakit yok.',
          ];
          replyText =
              advanceRejectPool[random.nextInt(advanceRejectPool.length)];
        }
        break;

      case ChatTacticType.demandBankGuarantee:
        nextPatience -= 20;
        final isCorporateOrLuxury =
            state.contractorId == 'contractor_metropol_mimarlik' ||
                state.contractorId == 'contractor_bogazici_elit';
        final successChance = isCorporateOrLuxury ? 0.70 : 0.45;
        if (random.nextDouble() < successChance) {
          nextSatisfaction += 20;
          nextBankGuarantee = true;
          final guaranteePool = [
            'Haklısınız, yarım kalan şantiyeler piyasayı tedirgin etti • Kamu bankasından kesin teminat mektubunu çıkarıp noter sözleşmesine ekliyoruz.',
            'Kurumsal mali gücümüz tamdır • ₺2.500.000 tutarındaki banka teminat mektubunu adınıza bloke edip şantiyeye öyle başlıyoruz.',
            'Güven esastır • Banka teminat mektubunu tapu dairesine teslim etmeyi kabul ediyoruz.',
          ];
          replyText = guaranteePool[random.nextInt(guaranteePool.length)];
          replyBadge = 'BANKA TEMİNATI ONAYLANDI';
        } else {
          final rejectPool = [
            'Biz 40 yıllık esnafız, bugüne kadar tek bir çivimiz havada kalmadı • Bankaya boşuna komisyon yedirmeyelim patron.',
            'Banka kredi limitlerimizi şantiye malzeme alımına bağladık • Teminat mektubu yerine şirket kefaleti öneriyoruz.',
            'Teminat mektubu masrafı fizibilitemizi bozar • Bizim referanslarımız şantiyelerimizdir, bankayla aramıza girmeyin.',
          ];
          replyText = rejectPool[random.nextInt(rejectPool.length)];
        }
        break;

      case ChatTacticType.askJokeOrChat:
        nextJokeCount++;
        if (nextJokeCount <= 3) {
          final gain = max(0, 22 - (nextJokeCount - 1) * 8);
          nextPatience = min(state.maxPatience, nextPatience + gain);
          nextSatisfaction = min(100, nextSatisfaction + max(5, 15 - (nextJokeCount - 1) * 5));
          final jokeKey = ContractorNegotiationExpansion.getRandomJokeKey(random);
          replyText = _getJokeText(jokeKey);
          replyBadge = 'ÇAY VE SOHBET • SABIR +$gain';
        } else {
          nextPatience -= 10;
          replyText = 'Patron laf lafı açıyor da işimize dönelim, şantiye bizi bekler.';
          replyBadge = 'İŞE ODAKLANMA • SABIR -10';
        }
        break;

      case ChatTacticType.counterPrice:
        nextPatience -= 20;
        final effectiveFloor = state.minPrice > 0 ? state.minPrice : (state.currentPrice * 0.75);
        final delta = state.counterpartyRole == ChatSenderRole.buyer
            ? state.currentPrice * 0.05
            : state.currentPrice * -0.05;
        if (random.nextDouble() < 0.65 && (state.counterpartyRole == ChatSenderRole.buyer || nextPrice + delta >= effectiveFloor)) {
          nextPrice = max(effectiveFloor, nextPrice + delta);
          nextSatisfaction += 10;
          replyText =
              'Önerdiğiniz rakamı değerlendirdik. Yeni fiyat ₺${nextPrice.round()} olarak el sıkışabiliriz.';
          replyBadge = 'YENİ TEKLİF: ₺${nextPrice.round()}';
        } else {
          replyText =
              'Bu rakam bizim fizibilitenin çok üzerinde kalıyor, fiyatı esnetemeyiz.';
        }
        break;

      case ChatTacticType.demandDoubleShift:
        nextPatience -= 15;
        if (random.nextDouble() < 0.65) {
          nextSatisfaction += 15;
          nextStageDays = 11;
          replyText =
              'Anlaştık patron • Sahaya seyyar aydınlatma ve ekstra jeneratör kuruyoruz • Gece çift vardiyaya girip süreden gün kazanacağız.';
          replyBadge = 'ÇİFT VARDİYA ONAYLANDI';
        } else {
          replyText =
              'Aman patron, gece beton dökersek mahalleli zabıtayı yığar şantiyeye • Sabah 06:00 dedi mi mikserleri sıraya dizeceğiz.';
        }
        break;

      case ChatTacticType.demandCashMaterials:
        nextPatience -= 20;
        final effectiveFloor = state.minPrice > 0 ? state.minPrice : (state.currentPrice * 0.75);
        if (random.nextDouble() < 0.70 && nextPrice > effectiveFloor) {
          final discount = (state.currentPrice * 0.08).roundToDouble();
          nextPrice = max(effectiveFloor, state.currentPrice - discount);
          nextSatisfaction += 20;
          replyText =
              'Madem demiri hazır betonu peşin bağlıyorsun patron, biz de işçilik birim fiyatından ₺${discount.round()} düşüyoruz • Helali hoş olsun.';
          replyBadge = 'PEŞİN MALZEME İNDİRİMİ';
        } else {
          replyText =
              'Patron malzeme desteğin makbule geçer ama usta yevmiyesi, kalıp çivisi ve bağ teli maliyetimiz belli • Fiyattan daha fazla kıramayız.';
        }
        break;

      case ChatTacticType.demandPenaltyClause:
        nextPatience -= 20;
        if (random.nextDouble() < 0.60) {
          nextSatisfaction += 10;
          replyText =
              'Sözümüz senettir patron • Sözleşmeye cezai şart maddesini ekle • Dededen kalma tecrübeyle gününden önce teslim etmezsek namerdiz!';
          replyBadge = 'CEZAİ ŞART TAAHHÜDÜ';
        } else {
          nextPatience -= 10;
          replyText =
              'Aman patron, şantiyede hava muhalefeti var, beton santralinin elektrik arızası var • Mahkemeyle şantiyeyi germeyelim, tatlıya bağlayalım.';
        }
        break;

      case ChatTacticType.demandCashDiscount:
        nextPatience -= 20;
        final effectiveFloor = state.minPrice > 0 ? state.minPrice : (state.currentPrice * 0.75);
        if (random.nextDouble() < 0.65 && nextPrice > effectiveFloor) {
          final discount = (nextPrice * 0.07).roundToDouble();
          nextPrice = max(effectiveFloor, nextPrice - discount);
          nextSatisfaction += 15;
          replyText =
              'Peşin ödeme yapacağınızı göz önünde bulundurarak ₺${discount.round()} nakit indirimi uyguladık.';
          replyBadge = 'NAKİT İNDİRİM: -₺${discount.round()}';
        } else {
          replyText =
              'Bu fiyatın altına inmemiz mümkün değil, nakit akışımız kurtarmıyor.';
        }
        break;

      case ChatTacticType.acceptAgreement:
        if (state.satisfaction >= 40) {
          nextAgreed = true;
          replyText =
              'Harika! Şartlarda mutabık kaldık. Sözleşmeyi hazırlatıyorum, hayırlı uğurlu olsun!';
          replyBadge = 'MUTABAKAT SAĞLANDI';
        } else {
          nextPatience -= 25;
          replyText =
              'Bu şartlarda henüz el sıkışamayız patron • Talepleriniz dengeleri çok zorladı, ortak bir noktada buluşmamız gerek.';
        }
        break;

      case ChatTacticType.transferDeedCosts:
        nextPatience -= 15;
        if (random.nextDouble() < 0.60) {
          replyText =
              'Tamamdır, tapu harcı ve döner sermaye masraflarının tamamını biz üstleniyoruz.';
          replyBadge = 'TAPU HARCI KARŞI TARAFTA';
        } else {
          replyText =
              'Teamül gereği tapu masrafı yarı yarıya ödenmelidir, tamamını alamayız.';
        }
        break;

      case ChatTacticType.walkAway:
        nextWalkedAway = true;
        replyText =
            'Görüşmelerde ortak bir noktada buluşamadık. Teklifimiz iptal edilmiştir.';
        replyBadge = 'PAZARLIK BİTTİ';
        break;
    }

    if (nextPatience <= 0 && !nextAgreed) {
      nextWalkedAway = true;
      replyText =
          'Israrlarınız ve şartlarınız sınırımızı aştı • Masadan kalkıyoruz, teklif geçerliliğini yitirdi.';
      replyBadge = 'MASADAN KALKTI';
    }

    final replyMessage = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_reply',
      senderName: state.counterpartyName,
      role: state.counterpartyRole,
      message: replyText,
      timestamp: DateTime.now(),
      isFromPlayer: false,
      badgeText: replyBadge,
    );

    final finalState = stateWithPlayer.copyWith(
      patience: max(0, nextPatience),
      satisfaction: min(100, max(0, nextSatisfaction)),
      currentPrice: nextPrice,
      currentSharePercent: nextShare,
      jokeUseCount: nextJokeCount,
      hasPrimeFloorClause: nextPrimeFloors,
      hasQualityUpgrade: nextQualityUpgrade,
      contractorAdvancePaid: nextAdvance,
      hasBankGuarantee: nextBankGuarantee,
      contractorStageDays: nextStageDays,
      messages: [...stateWithPlayer.messages, replyMessage],
      isAgreed: nextAgreed,
      isWalkedAway: nextWalkedAway,
    );

    return ChatTacticExecutionPlan(
      stateWithPlayerMessageOnly: stateWithPlayer,
      finalState: finalState,
      playerMessage: playerMessage,
      counterpartyReply: replyMessage,
    );
  }

  static String _getJokeText(String jokeKey) {
    switch (jokeKey) {
      case 'contractor_joke_inspector_tea':
        return 'Usta anlatayım: Yapı denetimci geldi, demir aralığına cetvel tuttu. 14.8 cm çıktı diye tutanak tutacaktı. İki bardak tavşan kanı çay söyledik, 16 cm ye kadar müsaade çıktı!';
      case 'contractor_joke_inverted_blueprint':
        return 'Geçen şantiyede kalıpçı projeyi ters tutmuş, sığınağı 4. kata yapmışız! Belediye heyeti gelene kadar panoramik manzaralı sığınak diye daireyi sattık!';
      case 'contractor_joke_positive_energy':
        return 'Beton santrali aradı, çimento bitti dedi. Dedim usta pozitif düşün, harca duaları ve sevgimizi kattık, vallahi C40 tan sağlam oldu!';
      case 'contractor_joke_mixer_wedding':
        return 'Dün gece mikser mahalleye girdi, düğün konvoyuna denk geldi. Mikserin tamburunu davul zurna eşliğinde halayla çevirdik!';
      case 'contractor_joke_monet_painter':
        return 'Bizim boyacı Monet gibi mübarek! Tavanı öyle bir boyadı ki nem mi var, soyut sanat mı var eksper bile ayırt edemedi!';
      case 'contractor_joke_iron_price_moon':
        return 'Demirin tonu SpaceX roketi gibi uzaya fırladı patron. Sabah aldığımız inşaat demiri öğlen borsa hissesi gibi kıymete biniyor!';
      case 'contractor_joke_c40_bunker':
        return 'Statikçi öyle bir temel çizmiş ki 9 şiddetinde deprem olsa bina sapasağlam kalır, mahalle binanın etrafına pikniğe toplanır!';
      case 'contractor_joke_plumber_waterfall':
        return 'Tesisatçı boruyu öyle bir döşemiş ki sıcak suyu açınca mutfaktan şelale sesi geliyor! Müşteriye doğayla baş başa terapi konsepti diye anlattık!';
      case 'contractor_joke_cat_crane':
        return 'Kule vincin tepesinde uyuyan sarman kedi var. Kedi uyanmadan bomu çevirmiyoruz, şantiyemizin baş mühendisi ve uğuru o!';
      default:
        return 'Demli çay her kapıyı açar patron • Şantiyede harç biter, çay bitmez!';
    }
  }
}
