import 'package:flutter/material.dart';

class ThemePaletteModel {
  final String id;
  final String name;
  final int price; // ₺ TL store price (0 = unlocked by default)
  final bool isUnlocked;
  final bool isDark;

  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color surfaceBorderColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color successColor;
  final Color warningColor;
  final Color errorColor;

  const ThemePaletteModel({
    required this.id,
    required this.name,
    required this.price,
    required this.isUnlocked,
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.surfaceBorderColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
  });

  Color get infoColor => secondaryColor;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'isUnlocked': isUnlocked,
        'isDark': isDark,
        'primaryColor': primaryColor.toARGB32(),
        'secondaryColor': secondaryColor.toARGB32(),
        'backgroundColor': backgroundColor.toARGB32(),
        'surfaceColor': surfaceColor.toARGB32(),
        'surfaceBorderColor': surfaceBorderColor.toARGB32(),
        'textPrimaryColor': textPrimaryColor.toARGB32(),
        'textSecondaryColor': textSecondaryColor.toARGB32(),
        'successColor': successColor.toARGB32(),
        'warningColor': warningColor.toARGB32(),
        'errorColor': errorColor.toARGB32(),
      };

  factory ThemePaletteModel.fromJson(Map<String, dynamic> json) => ThemePaletteModel(
        id: json['id'] as String? ?? 'quiet_luxury_dark',
        name: json['name'] as String? ?? 'Quiet Luxury Dark',
        price: (json['price'] as num?)?.toInt() ?? 0,
        isUnlocked: json['isUnlocked'] as bool? ?? false,
        isDark: json['isDark'] as bool? ?? true,
        primaryColor: Color((json['primaryColor'] as num?)?.toInt() ?? 0xFFC9A96E),
        secondaryColor: Color((json['secondaryColor'] as num?)?.toInt() ?? 0xFF4F46E5),
        backgroundColor: Color((json['backgroundColor'] as num?)?.toInt() ?? 0xFF0D0D0F),
        surfaceColor: Color((json['surfaceColor'] as num?)?.toInt() ?? 0xFF18181C),
        surfaceBorderColor: Color((json['surfaceBorderColor'] as num?)?.toInt() ?? 0xFF2A2A32),
        textPrimaryColor: Color((json['textPrimaryColor'] as num?)?.toInt() ?? 0xFFF3F4F6),
        textSecondaryColor: Color((json['textSecondaryColor'] as num?)?.toInt() ?? 0xFF9CA3AF),
        successColor: Color((json['successColor'] as num?)?.toInt() ?? 0xFF10B981),
        warningColor: Color((json['warningColor'] as num?)?.toInt() ?? 0xFFF59E0B),
        errorColor: Color((json['errorColor'] as num?)?.toInt() ?? 0xFFEF4444),
      );

  ThemePaletteModel copyWith({bool? isUnlocked}) => ThemePaletteModel(
        id: id,
        name: name,
        price: price,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        isDark: isDark,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        backgroundColor: backgroundColor,
        surfaceColor: surfaceColor,
        surfaceBorderColor: surfaceBorderColor,
        textPrimaryColor: textPrimaryColor,
        textSecondaryColor: textSecondaryColor,
        successColor: successColor,
        warningColor: warningColor,
        errorColor: errorColor,
      );

  // Pre-defined Preset Palettes for In-Game Store (1 Light + 1 Dark Curated)
  static const List<ThemePaletteModel> defaultPalettes = [
    // 1. Light - Sanayi Çırağı (Default Free)
    ThemePaletteModel(
      id: 'sanayi_ciragi_light',
      name: 'Sanayi Çırağı (Aydınlık)',
      price: 0,
      isUnlocked: true,
      isDark: false,
      primaryColor: Color(0xFFEAB308),
      secondaryColor: Color(0xFF2563EB),
      backgroundColor: Color(0xFFF4F4F0),
      surfaceColor: Color(0xFFFFFFFF),
      surfaceBorderColor: Color(0xFF0F172A),
      textPrimaryColor: Color(0xFF0F172A),
      textSecondaryColor: Color(0xFF475569),
      successColor: Color(0xFF16A34A),
      warningColor: Color(0xFFD97706),
      errorColor: Color(0xFFDC2626),
    ),

    // 2. Dark - Gece Vardiyası (₺50.000)
    ThemePaletteModel(
      id: 'gece_vardiyasi_dark',
      name: 'Gece Vardiyası (Karanlık)',
      price: 50000,
      isUnlocked: false,
      isDark: true,
      primaryColor: Color(0xFFFACC15),
      secondaryColor: Color(0xFF38BDF8),
      backgroundColor: Color(0xFF0F172A),
      surfaceColor: Color(0xFF1E293B),
      surfaceBorderColor: Color(0xFF334155),
      textPrimaryColor: Color(0xFFF8FAFC),
      textSecondaryColor: Color(0xFF94A3B8),
      successColor: Color(0xFF22C55E),
      warningColor: Color(0xFFF59E0B),
      errorColor: Color(0xFFEF4444),
    ),
  ];
}
