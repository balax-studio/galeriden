import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/listing_model.dart';
import '../../domain/usecases/vasita_negotiation_engine.dart';
import 'game_provider.dart';
import 'vasita_market_provider.dart';

class VasitaNegotiationState {
  final double offeredPrice;
  final int sellerPatience;
  final int bonusChancePercent;
  final Set<String> usedTacticIds;
  final String sellerDialogue;
  final bool isProcessing;
  final bool isAccepted;
  final bool isWalkaway;
  final double? lastNearMissAmount;
  final bool isHandoverCompleted;
  final int offerAttemptCount;

  const VasitaNegotiationState({
    required this.offeredPrice,
    this.sellerPatience = 100,
    this.bonusChancePercent = 0,
    this.usedTacticIds = const {},
    this.sellerDialogue = '',
    this.isProcessing = false,
    this.isAccepted = false,
    this.isWalkaway = false,
    this.lastNearMissAmount,
    this.isHandoverCompleted = false,
    this.offerAttemptCount = 0,
  });

  VasitaNegotiationState copyWith({
    double? offeredPrice,
    int? sellerPatience,
    int? bonusChancePercent,
    Set<String>? usedTacticIds,
    String? sellerDialogue,
    bool? isProcessing,
    bool? isAccepted,
    bool? isWalkaway,
    double? lastNearMissAmount,
    bool? isHandoverCompleted,
    int? offerAttemptCount,
  }) {
    return VasitaNegotiationState(
      offeredPrice: offeredPrice ?? this.offeredPrice,
      sellerPatience: sellerPatience ?? this.sellerPatience,
      bonusChancePercent: bonusChancePercent ?? this.bonusChancePercent,
      usedTacticIds: usedTacticIds ?? this.usedTacticIds,
      sellerDialogue: sellerDialogue ?? this.sellerDialogue,
      isProcessing: isProcessing ?? this.isProcessing,
      isAccepted: isAccepted ?? this.isAccepted,
      isWalkaway: isWalkaway ?? this.isWalkaway,
      lastNearMissAmount: lastNearMissAmount,
      isHandoverCompleted: isHandoverCompleted ?? this.isHandoverCompleted,
      offerAttemptCount: offerAttemptCount ?? this.offerAttemptCount,
    );
  }
}

class VasitaNegotiationNotifier extends StateNotifier<VasitaNegotiationState> {
  final Ref ref;
  final ListingModel listing;

  VasitaNegotiationNotifier(this.ref, this.listing)
      : super(VasitaNegotiationState(
          offeredPrice: (listing.askingPrice * 0.90).roundToDouble(),
          sellerDialogue: VasitaNegotiationEngine.generateDynamicSellerDialogue(
            sellerName: listing.sellerName,
            sellerTrait: listing.sellerTrait,
            offeredPrice: (listing.askingPrice * 0.90).roundToDouble(),
            askingPrice: listing.askingPrice,
            patience: 100,
          ),
        ));

  void updateOfferPrice(double price) {
    if (state.isAccepted || state.isWalkaway || state.isProcessing) return;
    state = state.copyWith(offeredPrice: price);
  }

  void resetToAskingPrice() {
    if (state.isAccepted || state.isWalkaway || state.isProcessing) return;
    state = state.copyWith(offeredPrice: listing.askingPrice);
  }

  VasitaTacticRollOutcome? executeTactic(VasitaTactic tactic) {
    if (state.usedTacticIds.contains(tactic.id) || state.isAccepted || state.isProcessing) return null;
    if (state.isWalkaway && !tactic.isRescue) return null;

    final game = ref.read(gameProvider);
    final outcome = VasitaNegotiationEngine.rollTactic(
      tactic: tactic,
      listing: listing,
      currentPatience: state.sellerPatience,
      playerLevel: game.level,
    );

    final updatedTactics = {...state.usedTacticIds, tactic.id};
    final newPatience = (state.sellerPatience + outcome.patienceChange).clamp(0, 100).toInt();

    int newBonus = state.bonusChancePercent;
    bool newWalkaway = state.isWalkaway;
    int newAttempts = state.offerAttemptCount;

    if (outcome.isSuccess) {
      newBonus = (newBonus + tactic.baseBonusPercent).clamp(0, 35);
      if (tactic.isRescue && state.isWalkaway) {
        newWalkaway = false;
        newAttempts = 2; // Gives 1 more critical offer opportunity
        ref.read(vasitaLockedListingsProvider.notifier).update(
          (s) => s.where((id) => id != listing.id).toSet(),
        );
      }
    } else if (outcome.isWalkaway) {
      newWalkaway = true;
      ref.read(vasitaLockedListingsProvider.notifier).update((s) => {...s, listing.id});
    }

    state = state.copyWith(
      usedTacticIds: updatedTactics,
      sellerPatience: newPatience,
      sellerDialogue: outcome.message,
      bonusChancePercent: newBonus,
      isWalkaway: newWalkaway,
      offerAttemptCount: newAttempts,
    );

    return outcome;
  }

  void setProcessing(bool val) {
    state = state.copyWith(isProcessing: val, lastNearMissAmount: null);
  }

  void setDialogue(String text) {
    state = state.copyWith(sellerDialogue: text);
  }

  VasitaNegotiationOutcome evaluateOffer() {
    final game = ref.read(gameProvider);
    final outcome = VasitaNegotiationEngine.evaluateOffer(
      listing: listing,
      offeredPrice: state.offeredPrice,
      currentPatience: state.sellerPatience,
      playerLevel: game.level,
      extraBonusPercent: state.bonusChancePercent / 100.0,
    );

    final newAttemptCount = state.offerAttemptCount + 1;
    bool newWalkaway = state.isWalkaway || outcome.isWalkaway;
    bool newAccepted = state.isAccepted || outcome.isAccepted;

    if (!newAccepted && newAttemptCount >= 3) {
      newWalkaway = true;
      ref.read(vasitaLockedListingsProvider.notifier).update((s) => {...s, listing.id});
    } else if (newWalkaway) {
      ref.read(vasitaLockedListingsProvider.notifier).update((s) => {...s, listing.id});
    }

    final finalDialogue = (!newAccepted && newAttemptCount >= 3)
        ? '${listing.sellerName} • 3 teklif hakkınız da tükendi! Daha fazla vaktimi almayın, masadan kalkıyorum.'
        : outcome.responseMessage;

    state = state.copyWith(
      isProcessing: false,
      offerAttemptCount: newAttemptCount,
      isAccepted: newAccepted,
      isWalkaway: newWalkaway,
      sellerPatience: outcome.updatedPatience,
      sellerDialogue: finalDialogue,
      lastNearMissAmount: outcome.nearMissAmount,
    );

    return outcome;
  }

  void completeHandover() {
    state = state.copyWith(
      isHandoverCompleted: true,
      isAccepted: true,
      sellerDialogue: '${listing.sellerName} • Ruhsatı ve anahtarları teslim ettim. Hayırlı uğurlu olsun! Pazar ilanı sistemden kaldırıldı.',
    );
  }
}

final vasitaNegotiationProvider = StateNotifierProvider.autoDispose
    .family<VasitaNegotiationNotifier, VasitaNegotiationState, ListingModel>((ref, listing) {
  return VasitaNegotiationNotifier(ref, listing);
});
