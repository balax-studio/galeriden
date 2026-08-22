import 'package:flutter/material.dart';

enum AppLanguage {
  turkish('tr', 'Türkçe', 'Türkçe', 'TR', '₺', false),
  english('en', 'İngilizce', 'English', 'EN', '\$', false),
  german('de', 'Almanca', 'Deutsch', 'DE', '€', false),
  portuguese('pt', 'Portekizce', 'Português', 'BR', 'R\$', false),
  spanish('es', 'İspanyolca', 'Español', 'ES', '€', false),
  russian('ru', 'Rusça', 'Русский', 'RU', '₽', false),
  arabic('ar', 'Arapça', 'العربية', 'AR', 'د.إ', true);

  final String code;
  final String turkishName;
  final String nativeName;
  final String countryBadge;
  final String currencySymbol;
  final bool isRtl;

  const AppLanguage(
    this.code,
    this.turkishName,
    this.nativeName,
    this.countryBadge,
    this.currencySymbol,
    this.isRtl,
  );

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.turkish,
    );
  }

  Locale get locale => Locale(code);
}
