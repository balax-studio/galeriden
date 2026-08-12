import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  static String format(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatShort(double amount) {
    if (amount >= 1000000) {
      return '₺${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₺${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '₺${amount.toInt()}';
  }
}
