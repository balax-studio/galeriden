import 'dart:math';

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
  counterPrice, // Karşı Fiyat Teklif Et (+%5 veya -%5)
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

class ChatNegotiationState {
  final String targetId;
  final String counterpartyName;
  final ChatSenderRole counterpartyRole;
  final int patience; // 0 to 100
  final int satisfaction; // 0 to 100
  final double currentPrice;
  final int currentSharePercent; // 40 to 60 for contractor
  final List<ChatMessageModel> messages;
  final bool isAgreed;
  final bool isWalkedAway;
  final String? lastToastMessage;

  const ChatNegotiationState({
    required this.targetId,
    required this.counterpartyName,
    required this.counterpartyRole,
    this.patience = 100,
    this.satisfaction = 50,
    required this.currentPrice,
    this.currentSharePercent = 50,
    this.messages = const [],
    this.isAgreed = false,
    this.isWalkedAway = false,
    this.lastToastMessage,
  });

  ChatNegotiationState copyWith({
    int? patience,
    int? satisfaction,
    double? currentPrice,
    int? currentSharePercent,
    List<ChatMessageModel>? messages,
    bool? isAgreed,
    bool? isWalkedAway,
    String? lastToastMessage,
  }) {
    return ChatNegotiationState(
      targetId: targetId,
      counterpartyName: counterpartyName,
      counterpartyRole: counterpartyRole,
      patience: patience ?? this.patience,
      satisfaction: satisfaction ?? this.satisfaction,
      currentPrice: currentPrice ?? this.currentPrice,
      currentSharePercent: currentSharePercent ?? this.currentSharePercent,
      messages: messages ?? this.messages,
      isAgreed: isAgreed ?? this.isAgreed,
      isWalkedAway: isWalkedAway ?? this.isWalkedAway,
      lastToastMessage: lastToastMessage ?? this.lastToastMessage,
    );
  }
}

class RealEstateChatNegotiationEngine {
  /// Müteahhit açılış diyalogunu oluşturur
  static ChatNegotiationState createContractorSession({
    required String landId,
    required String contractorName,
    required int totalUnits,
    required double baseMarketValue,
  }) {
    final openingMessage = ChatMessageModel(
      id: 'msg_0',
      senderName: contractorName,
      role: ChatSenderRole.contractor,
      message:
          'Selamlar, parselinizin imar durumunu inceledik. Bu arsaya KAKS gereği toplam $totalUnits adet daire sığıyor. %50 - %50 kat karşılığı anlaşma öneriyoruz. Arsa sizden, inşaat bizden.',
      timestamp: DateTime.now(),
      isFromPlayer: false,
      badgeText: '%50 - %50 KAT KARŞILIĞI',
    );

    return ChatNegotiationState(
      targetId: landId,
      counterpartyName: contractorName,
      counterpartyRole: ChatSenderRole.contractor,
      patience: 100,
      satisfaction: 50,
      currentPrice: baseMarketValue,
      currentSharePercent: 50,
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
      satisfaction: 55,
      currentPrice: offeredPrice,
      messages: [openingMessage],
    );
  }

  /// Taktik çalıştırma durum makinesi
  static ChatNegotiationState executeTactic({
    required ChatNegotiationState state,
    required ChatTacticType tactic,
    required String playerMessageText,
    required Random random,
  }) {
    if (state.isAgreed || state.isWalkedAway) return state;

    final updatedMessages = List<ChatMessageModel>.from(state.messages);

    // 1. Oyuncu mesajını ekle
    updatedMessages.add(
      ChatMessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_player',
        senderName: 'Siz',
        role: ChatSenderRole.player,
        message: playerMessageText,
        timestamp: DateTime.now(),
        isFromPlayer: true,
      ),
    );

    // 2. Taktik değerlendirmesi
    int nextPatience = state.patience;
    int nextSatisfaction = state.satisfaction;
    double nextPrice = state.currentPrice;
    int nextShare = state.currentSharePercent;
    bool nextAgreed = false;
    bool nextWalkedAway = false;
    String replyText = '';
    String? replyBadge;

    switch (tactic) {
      case ChatTacticType.demandHigherShare:
        nextPatience -= 20;
        if (random.nextDouble() < 0.60 && nextShare < 58) {
          nextShare += 3;
          nextSatisfaction += 10;
          replyText =
              'Pekala, arsanızın konumu değerli. Payınızı %$nextShare seviyesine çıkarıyoruz ancak teslim süresine 30 gün ekleriz.';
          replyBadge = '%$nextShare PAY GÜNCELLENDİ';
        } else {
          replyText =
              'Maalesef maliyetler çok yüksek, %$nextShare üzerinde pay vermemiz ticari olarak mümkün değil.';
        }
        break;

      case ChatTacticType.demandPrimeFloors:
        nextPatience -= 15;
        if (random.nextDouble() < 0.70) {
          nextSatisfaction += 15;
          replyText =
              'Anlaştık, projedeki en üst 2 katın ve köşe dairelerin tapusunu sizin adınıza tescil edeceğiz.';
          replyBadge = 'ÜST KATLAR TAHSİS EDİLDİ';
        } else {
          replyText =
              'Şerefiye paylaşımında eşit kura çekmek zorundayız, tek taraflı üst kat veremeyiz.';
        }
        break;

      case ChatTacticType.demandQualityUpgrade:
        nextPatience -= 15;
        if (random.nextDouble() < 0.65) {
          replyText =
              'C35 hazır beton, yerden ısıtma ve ses yalıtımı şartnamesini sözleşmeye ekliyoruz.';
          replyBadge = 'LÜKS C35 ŞARTNAMESİ';
        } else {
          replyText =
              'Standart C30 beton kalitemiz yönetmeliğe tam uygundur, lüks donanım için bütçemiz kısıtlı.';
        }
        break;

      case ChatTacticType.demandAdvanceDeposit:
        nextPatience -= 25;
        if (random.nextDouble() < 0.50) {
          nextSatisfaction += 20;
          replyText =
              'İnşaat süresince kiranızı karşılamak adına peşin ₺350.000 nakit avansı hesabınıza yatırıyoruz.';
          replyBadge = '₺350.000 NAKİT AVANS';
        } else {
          replyText =
              'Nakit akışımızı şantiye demirine bağladık, nakit avans ödemesi yapamayız.';
        }
        break;

      case ChatTacticType.counterPrice:
        nextPatience -= 20;
        final delta = state.counterpartyRole == ChatSenderRole.buyer
            ? state.currentPrice * 0.05
            : state.currentPrice * -0.05;
        if (random.nextDouble() < 0.65) {
          nextPrice += delta;
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
          replyText =
              'Anlaştık patron • Sahaya seyyar aydınlatma ve ekstra jeneratör kuruyoruz • Gece çift vardiyaya girip süreden gün kazanacağız.';
          replyBadge = 'ÇİFT VARDİYA ONAYLANDI';
        } else {
          replyText =
              'Aman patron, gece beton dökersek mahalleli zabıtayı yığar şantiyeye • Sabah 06:00 dedi mi mikserleri sıraya dizeceğiz.';
        }
        break;

      case ChatTacticType.demandCashMaterials:
        nextPatience -= 10;
        if (random.nextDouble() < 0.70) {
          final discount = (state.currentPrice * 0.08).roundToDouble();
          nextPrice = state.currentPrice - discount;
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
      case ChatTacticType.acceptAgreement:
        nextAgreed = true;
        replyText =
            'Harika! Şartlarda mutabık kaldık. Sözleşmeyi hazırlatıyorum, hayırlı uğurlu olsun!';
        replyBadge = 'MUTABAKAT SAĞLANDI';
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
          'Israrlarınız ve şartlarınız sınırımızı aştı. Masadan kalkıyoruz, teklif geçerliliğini yitirdi.';
      replyBadge = 'MASADAN KALKTI';
    }

    // 3. Karşı taraf yanıt mesajını ekle
    updatedMessages.add(
      ChatMessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}_reply',
        senderName: state.counterpartyName,
        role: state.counterpartyRole,
        message: replyText,
        timestamp: DateTime.now(),
        isFromPlayer: false,
        badgeText: replyBadge,
      ),
    );

    return state.copyWith(
      patience: max(0, nextPatience),
      satisfaction: min(100, max(0, nextSatisfaction)),
      currentPrice: nextPrice,
      currentSharePercent: nextShare,
      messages: updatedMessages,
      isAgreed: nextAgreed,
      isWalkedAway: nextWalkedAway,
    );
  }
}
