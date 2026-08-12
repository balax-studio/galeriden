import 'package:flutter/material.dart';
import 'app_colors.dart';

class StatColors {
  StatColors._();

  /// KM Status Color
  static Color getMileageColor(int mileage) {
    if (mileage < 60000) return AppColors.successGreen;
    if (mileage < 130000) return AppColors.primaryAmber;
    if (mileage < 200000) return AppColors.warningOrange;
    return AppColors.errorRed;
  }

  static String getMileageLabel(int mileage) {
    if (mileage < 60000) return 'Çok Düşük KM';
    if (mileage < 130000) return 'Makul KM';
    if (mileage < 200000) return 'Yüksek KM';
    return 'Aşırı Yüksek KM';
  }

  /// Engine Condition Color
  static Color getEngineColor(double condition) {
    if (condition >= 85) return AppColors.successGreen;
    if (condition >= 65) return AppColors.primaryAmber;
    if (condition >= 45) return AppColors.warningOrange;
    return AppColors.errorRed;
  }

  static String getEngineLabel(double condition) {
    if (condition >= 85) return 'Saat Gibi (%${condition.round()})';
    if (condition >= 65) return 'Düzgün (%${condition.round()})';
    if (condition >= 45) return 'Bakım İster (%${condition.round()})';
    return 'Bitik Motor (%${condition.round()})';
  }

  /// Tramer Amount Color
  static Color getTramerColor(int amount) {
    if (amount == 0) return AppColors.successGreen;
    if (amount < 12000) return AppColors.primaryAmber;
    if (amount < 35000) return AppColors.warningOrange;
    return AppColors.errorRed;
  }

  static String getTramerLabel(int amount) {
    if (amount == 0) return 'Hasarsız (0 ₺)';
    if (amount < 12000) return 'Hafif Hasar Kaydı';
    if (amount < 35000) return 'Orta Hasar Kaydı';
    return 'Ağır Hasar Kaydı';
  }

  /// Body Part Condition Color
  static Color getPartColor(String status) {
    switch (status.toLowerCase()) {
      case 'original':
      case 'orijinal':
        return AppColors.partOriginal;
      case 'painted':
      case 'boyalı':
        return AppColors.partPainted;
      case 'changed':
      case 'değişen':
        return AppColors.partChanged;
      case 'damaged':
      case 'hasarlı':
      default:
        return AppColors.partDamaged;
    }
  }

  static String getPartLabel(String status) {
    switch (status.toLowerCase()) {
      case 'original':
      case 'orijinal':
        return 'Orijinal';
      case 'painted':
      case 'boyalı':
        return 'Boyalı';
      case 'changed':
      case 'değişen':
        return 'Değişen';
      case 'damaged':
      case 'hasarlı':
      default:
        return 'Hasarlı';
    }
  }
}
