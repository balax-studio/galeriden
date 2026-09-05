import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/game_sound_haptic_service.dart';
import '../../data/models/auction_model.dart';
import '../../domain/usecases/auction_engine.dart';
import 'game_provider.dart';

class AuctionSessionState {
  final AuctionModel auction;
  final List<UpcomingLotModel> upcomingLots;
  final bool isWindowOpen;
  final int closedCountdown;
  final bool hasPlayerEnteredBid;
  final bool isHandlingAuctionEnd;
  final bool hasExtendedAuction;
  final bool hasBluffedInCurrentAuction;
  final List<String> bidLogs;
  final bool isOfficerConsulted;
  final String? officerSpeech;
  final bool isVipSession;

  const AuctionSessionState({
    required this.auction,
    required this.upcomingLots,
    required this.isWindowOpen,
    required this.closedCountdown,
    this.hasPlayerEnteredBid = false,
    this.isHandlingAuctionEnd = false,
    this.hasExtendedAuction = false,
    this.hasBluffedInCurrentAuction = false,
    required this.bidLogs,
    this.isOfficerConsulted = false,
    this.officerSpeech,
    this.isVipSession = false,
  });

  AuctionSessionState copyWith({
    AuctionModel? auction,
    List<UpcomingLotModel>? upcomingLots,
    bool? isWindowOpen,
    int? closedCountdown,
    bool? hasPlayerEnteredBid,
    bool? isHandlingAuctionEnd,
    bool? hasExtendedAuction,
    bool? hasBluffedInCurrentAuction,
    List<String>? bidLogs,
    bool? isOfficerConsulted,
    String? officerSpeech,
    bool? isVipSession,
  }) {
    return AuctionSessionState(
      auction: auction ?? this.auction,
      upcomingLots: upcomingLots ?? this.upcomingLots,
      isWindowOpen: isWindowOpen ?? this.isWindowOpen,
      closedCountdown: closedCountdown ?? this.closedCountdown,
      hasPlayerEnteredBid: hasPlayerEnteredBid ?? this.hasPlayerEnteredBid,
      isHandlingAuctionEnd: isHandlingAuctionEnd ?? this.isHandlingAuctionEnd,
      hasExtendedAuction: hasExtendedAuction ?? this.hasExtendedAuction,
      hasBluffedInCurrentAuction: hasBluffedInCurrentAuction ?? this.hasBluffedInCurrentAuction,
      bidLogs: bidLogs ?? this.bidLogs,
      isOfficerConsulted: isOfficerConsulted ?? this.isOfficerConsulted,
      officerSpeech: officerSpeech,
      isVipSession: isVipSession ?? this.isVipSession,
    );
  }
}

class AuctionSessionNotifier extends StateNotifier<AuctionSessionState> {
  final Ref ref;
  Timer? _timer;

  AuctionSessionNotifier(this.ref)
      : super(AuctionSessionState(
          auction: AuctionEngine.createLiveAuction(
              playerLevel: ref.read(gameProvider).level),
          upcomingLots: AuctionEngine.generateUpcomingLots(
              count: 3, playerLevel: ref.read(gameProvider).level),
          isWindowOpen: AuctionEngine.isAuctionActiveNow(),
          closedCountdown: AuctionEngine.getSecondsUntilNextAuction(),
          bidLogs: const [],
        )) {
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    final windowNow = AuctionEngine.isAuctionActiveNow();

    if (windowNow != state.isWindowOpen) {
      if (windowNow ||
          (!state.isHandlingAuctionEnd &&
              !state.hasPlayerEnteredBid &&
              state.auction.secondsRemaining <= 0)) {
        final game = ref.read(gameProvider);
        state = state.copyWith(
          isWindowOpen: windowNow,
          auction: windowNow ? AuctionEngine.createLiveAuction(playerLevel: game.level) : state.auction,
          upcomingLots: windowNow ? AuctionEngine.generateUpcomingLots(count: 3, playerLevel: game.level) : state.upcomingLots,
          isOfficerConsulted: false,
          officerSpeech: null,
        );
      }
    }

    if (!state.isWindowOpen) {
      final remaining = AuctionEngine.getSecondsUntilNextAuction();
      if (remaining <= 0) {
        AuctionEngine.openSessionImmediately();
        final game = ref.read(gameProvider);
        state = state.copyWith(
          isWindowOpen: true,
          closedCountdown: 0,
          auction: AuctionEngine.createLiveAuction(playerLevel: game.level),
          upcomingLots: AuctionEngine.generateUpcomingLots(count: 3, playerLevel: game.level),
          isOfficerConsulted: false,
          officerSpeech: null,
        );
      } else {
        state = state.copyWith(closedCountdown: remaining);
      }
      return;
    }

    if (state.auction.secondsRemaining <= 1) {
      if (!state.isHandlingAuctionEnd) {
        stopTimer();
        state = state.copyWith(
          isHandlingAuctionEnd: true,
          auction: state.auction.copyWith(secondsRemaining: 0, status: AuctionStatus.ended),
        );
      }
      return;
    }

    state = state.copyWith(
      auction: state.auction.copyWith(secondsRemaining: state.auction.secondsRemaining - 1),
    );

    // Process rival bot bid
    final updated = AuctionEngine.processRivalBid(state.auction);
    if (updated != null) {
      GameSoundHapticService.playAuctionBid();
      final updatedLogs = List<String>.from(state.bidLogs);
      if (updated.isAntiSnipingTriggered) {
        updatedLogs.insert(0, 'Anti-Sniping Devrede • Süre +15s Uzatıldı!');
      }
      updatedLogs.insert(0, '${updated.highestBidderName} teklif artırdı: ₺${updated.currentBid.toInt()}');
      state = state.copyWith(
        auction: updated,
        bidLogs: updatedLogs,
      );
    }
  }

  void addBidLog(String log) {
    state = state.copyWith(
      bidLogs: [log, ...state.bidLogs],
    );
  }

  void recordPlayerBid({
    required double nextBid,
    required String highestBidderName,
    required int nextSeconds,
    required int antiSnipingCount,
    required bool wasLateBid,
    String? speech,
    String? speakerName,
    required String bidLogText,
  }) {
    final updatedLogs = List<String>.from(state.bidLogs);
    if (wasLateBid) {
      updatedLogs.insert(0, 'Anti-Sniping Devrede • Süre +15s Uzatıldı!');
    }
    updatedLogs.insert(0, bidLogText);

    state = state.copyWith(
      hasPlayerEnteredBid: true,
      bidLogs: updatedLogs,
      auction: state.auction.copyWith(
        currentBid: nextBid,
        highestBidderName: highestBidderName,
        isPlayerHighestBidder: true,
        secondsRemaining: nextSeconds,
        antiSnipingCount: antiSnipingCount,
        isAntiSnipingTriggered: wasLateBid,
        activeSpeech: speech,
        activeSpeakerName: speakerName,
      ),
    );
  }

  void setHandlingAuctionEnd(bool val) {
    state = state.copyWith(isHandlingAuctionEnd: val);
  }

  void resetRound({required int playerLevel}) {
    state = state.copyWith(
      auction: AuctionEngine.createLiveAuction(playerLevel: playerLevel),
      upcomingLots: AuctionEngine.generateUpcomingLots(count: 3, playerLevel: playerLevel),
      hasPlayerEnteredBid: false,
      isHandlingAuctionEnd: false,
      hasExtendedAuction: false,
      hasBluffedInCurrentAuction: false,
      isOfficerConsulted: false,
      officerSpeech: null,
    );
    startTimer();
  }

  void consultOfficer(String advice) {
    state = state.copyWith(
      isOfficerConsulted: true,
      officerSpeech: advice,
    );
  }

  void recordBluff({
    required double counterBid,
    required String rivalName,
    required String dialogue,
    required String logText,
  }) {
    final updatedLogs = List<String>.from(state.bidLogs);
    updatedLogs.insert(0, logText);
    state = state.copyWith(
      hasPlayerEnteredBid: false,
      hasBluffedInCurrentAuction: true,
      bidLogs: updatedLogs,
      auction: state.auction.copyWith(
        currentBid: counterBid,
        highestBidderName: rivalName,
        isPlayerHighestBidder: false,
        activeSpeech: dialogue,
        activeSpeakerName: rivalName,
        secondsRemaining: 3,
      ),
    );
  }

  void extendAuction() {
    state = state.copyWith(
      isHandlingAuctionEnd: false,
      hasExtendedAuction: true,
      auction: state.auction.copyWith(
        secondsRemaining: 15,
        status: AuctionStatus.active,
      ),
    );
    startTimer();
  }

  void startVipAuction({
    required int playerLevel,
    required String startedLog,
    required String startingPriceLog,
  }) {
    final vipAuction = AuctionEngine.createVipAuction(playerLevel: playerLevel);
    state = state.copyWith(
      isVipSession: true,
      auction: vipAuction,
      bidLogs: [
        startingPriceLog,
        startedLog,
      ],
      hasPlayerEnteredBid: false,
      hasExtendedAuction: false,
      isHandlingAuctionEnd: false,
    );
    startTimer();
  }

  void startStandardAuction({required int playerLevel}) {
    state = state.copyWith(
      isVipSession: false,
      auction: AuctionEngine.createLiveAuction(playerLevel: playerLevel),
      bidLogs: const [],
      hasPlayerEnteredBid: false,
      hasExtendedAuction: false,
      isHandlingAuctionEnd: false,
    );
    startTimer();
  }

  void refreshWindow() {
    final remaining = AuctionEngine.getSecondsUntilNextAuction();
    final isOpen = AuctionEngine.isAuctionActiveNow();
    state = state.copyWith(
      closedCountdown: remaining,
      isWindowOpen: isOpen,
    );
  }

  void markBluffed() {
    state = state.copyWith(hasBluffedInCurrentAuction: true);
  }

  void markExtended() {
    state = state.copyWith(hasExtendedAuction: true);
  }

  void setVipSession(bool isVip) {
    state = state.copyWith(isVipSession: isVip);
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}

final auctionSessionProvider =
    StateNotifierProvider.autoDispose<AuctionSessionNotifier, AuctionSessionState>((ref) {
  return AuctionSessionNotifier(ref);
});
