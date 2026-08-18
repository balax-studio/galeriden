import 'dart:math';
import '../../../core/utils/iterable_extensions.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/models/market_news_model.dart';
import '../../../data/models/game_event_model.dart';

/// Pure domain usecase engine for stock market fluctuations, forex rates,
/// portfolio dividend distributions, and IPO listing payouts.
class StockMarketEngine {
  /// Processes daily stock price movements, macro news impacts, and dividend distribution.
  static (List<StockModel>, double, List<GameEventModel>) processStockFluctuationsAndDividends({
    required int nextDay,
    required double balance,
    required List<StockModel> stocks,
    required List<PlayerStockModel> ownedStocks,
    required List<GameEventModel> events,
    MarketNewsModel? activeNews,
    Random? random,
  }) {
    final rng = random ?? Random();
    final updatedStocks = List<StockModel>.from(stocks);
    final updatedEvents = List<GameEventModel>.from(events);
    double currentBalance = balance;

    for (int i = 0; i < updatedStocks.length; i++) {
      final stock = updatedStocks[i];
      double baseChange = (rng.nextDouble() * 0.20) - 0.10;

      // Macro news impact (direct impact on automotive/industrial giants FROTO & TOASO)
      if (activeNews != null && (stock.symbol == 'FROTO' || stock.symbol == 'TOASO')) {
        if (activeNews.priceMultiplier > 1.0) {
          baseChange += 0.06;
        } else {
          baseChange -= 0.06;
        }
      }

      double newPrice = (stock.currentPrice * (1.0 + baseChange)).roundToDouble();
      if (newPrice < 1.0) newPrice = 1.0;
      List<double> history = List<double>.from(stock.priceHistory);
      history.add(newPrice);
      if (history.length > 30) history = history.sublist(history.length - 30);
      updatedStocks[i] = stock.copyWith(
        previousPrice: stock.currentPrice,
        currentPrice: newPrice,
        priceHistory: history,
      );
    }

    // Process daily dividends from player portfolio
    double totalDividends = 0.0;
    for (var owned in ownedStocks) {
      final stock = findFirstWhere(updatedStocks, (s) => s.symbol == owned.symbol);
      if (stock != null) {
        final double stockVal = owned.quantity * stock.currentPrice;
        totalDividends += (stockVal * stock.dividendYield) / 365.0;
      }
    }

    if (totalDividends >= 1.0) {
      final roundDiv = (totalDividends * 100).roundToDouble() / 100.0;
      currentBalance += roundDiv;
      updatedEvents.insert(0, GameEventModel(
        id: 'dividend_$nextDay',
        title: 'BIST Portföy Temettü Geliri',
        description: 'Hisselerinden günlük +₺${roundDiv.round()} net temettü nakit akışı hesabına yatırıldı.',
        type: GameEventType.income,
        amount: roundDiv,
        date: DateTime.now(),
      ));
    }

    return (updatedStocks, currentBalance, updatedEvents);
  }

  /// Processes daily forex and gold rate movements with 30-day historical window.
  static List<ForexGoldModel> processForexFluctuations({
    required List<ForexGoldModel> forexList,
    Random? random,
  }) {
    if (forexList.isEmpty) return ForexGoldModel.defaultForex;
    final rng = random ?? Random();
    final List<ForexGoldModel> updated = [];

    for (var item in forexList) {
      final double changeRatio = 1.0 + ((rng.nextDouble() * 0.03) - 0.015);
      final double newBuy = (item.buyRate * changeRatio * 100).roundToDouble() / 100.0;
      final double newSell = (newBuy * 0.991 * 100).roundToDouble() / 100.0;

      List<double> history = List<double>.from(item.rateHistory);
      history.add(newBuy);
      if (history.length > 30) history = history.sublist(history.length - 30);

      updated.add(item.copyWith(
        buyRate: newBuy,
        sellRate: newSell,
        previousRate: item.buyRate,
        rateHistory: history,
      ));
    }
    return updated;
  }

  /// Processes IPO countdown, listing date settlement, and profit realization.
  static (List<IpoOfferModel>, List<PlayerIpoRequestModel>, double, List<GameEventModel>) processIpoSettlement({
    required int nextDay,
    required double balance,
    required List<IpoOfferModel> ipos,
    required List<PlayerIpoRequestModel> requests,
    required List<GameEventModel> events,
  }) {
    if (ipos.isEmpty) {
      return (IpoOfferModel.defaultIpos(nextDay), requests, balance, events);
    }

    final List<IpoOfferModel> updatedIpos = [];
    final List<PlayerIpoRequestModel> updatedRequests = List<PlayerIpoRequestModel>.from(requests);
    final List<GameEventModel> updatedEvents = List<GameEventModel>.from(events);
    double currentBalance = balance;

    for (var ipo in ipos) {
      if (ipo.isListed) {
        updatedIpos.add(ipo);
        continue;
      }

      int remainingDays = ipo.daysUntilListing - 1;
      if (remainingDays <= 0) {
        updatedIpos.add(ipo.copyWith(daysUntilListing: 0, isListed: true));

        final playerReq = findFirstWhere(updatedRequests, (r) => r.ipoId == ipo.id);
        if (playerReq != null) {
          final double payout = playerReq.totalSpent * ipo.listingMultiplier;
          final double profit = payout - playerReq.totalSpent;
          currentBalance += payout;

          updatedEvents.insert(0, GameEventModel(
            id: 'ipo_listed_${ipo.id}_$nextDay',
            title: '${ipo.companyName} • ${ipo.symbol} Borsada Tavan Açtı!',
            description: '${ipo.symbol} halka arzında tavan serisi gerçekleşti! ₺${playerReq.totalSpent.round()} yatırımın ₺${payout.round()} oldu • +₺${profit.round()} kâr.',
            type: GameEventType.income,
            amount: payout,
            date: DateTime.now(),
          ));
        }
      } else {
        updatedIpos.add(ipo.copyWith(daysUntilListing: remainingDays));
      }
    }

    if (updatedIpos.every((i) => i.isListed)) {
      if (nextDay % 7 == 0) {
        return (IpoOfferModel.defaultIpos(nextDay), updatedRequests, currentBalance, updatedEvents);
      }
    }

    return (updatedIpos, updatedRequests, currentBalance, updatedEvents);
  }
}
