/// Centralized Game Constants & Config for Galerisinden Tycoon
class AppConstants {
  AppConstants._();

  static const String appName = 'Galerisinden Tycoon';
  static const String currencySymbol = '₺';

  // Game Balance & Limits
  static const double initialBalance = 450000.0;
  static const int initialGarageSlots = 3;
  static const int maxActiveLoans = 3;
  static const double fraudFineAmount = 10000.0;
  static const int fraudReputationPenalty = 15;

  // Doping & Organic Timing
  static const int organicOfferIntervalSeconds = 25;
  static const int minDopingDelaySeconds = 3;
  static const int maxDopingDelaySeconds = 8;

  // Auction Times
  static const int auctionWindowDurationMinutes = 2;
  static const int auctionIntervalMinutes = 5;

  // Reputation Titles
  static const String titleKing = 'Galerici Kralı';
  static const String titleMaster = 'Usta Galericisi';
  static const String titleTrident = 'Tüccar Galerici';
  static const String titleRookie = 'Çırak Galerici';
}
