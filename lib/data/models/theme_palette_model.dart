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
        id: json['id'] as String,
        name: json['name'] as String,
        price: json['price'] as int,
        isUnlocked: json['isUnlocked'] as bool? ?? false,
        isDark: json['isDark'] as bool? ?? true,
        primaryColor: Color(json['primaryColor'] as int),
        secondaryColor: Color(json['secondaryColor'] as int),
        backgroundColor: Color(json['backgroundColor'] as int),
        surfaceColor: Color(json['surfaceColor'] as int),
        surfaceBorderColor: Color(json['surfaceBorderColor'] as int),
        textPrimaryColor: Color(json['textPrimaryColor'] as int),
        textSecondaryColor: Color(json['textSecondaryColor'] as int),
        successColor: Color(json['successColor'] as int),
        warningColor: Color(json['warningColor'] as int),
        errorColor: Color(json['errorColor'] as int),
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

  // Pre-defined Preset Palettes for In-Game Store
  static const List<ThemePaletteModel> defaultPalettes = [
    ThemePaletteModel(
      id: 'quiet_luxury_dark',
      name: '2026 Imperial Gold (Koyu)',
      price: 0,
      isUnlocked: true,
      isDark: true,
      primaryColor: Color(0xFFC9A96E),
      secondaryColor: Color(0xFF5B7B6F),
      backgroundColor: Color(0xFF0D0D0F),
      surfaceColor: Color(0xFF1A1A1E),
      surfaceBorderColor: Color(0xFF2C2C32),
      textPrimaryColor: Color(0xFFE8E6E1),
      textSecondaryColor: Color(0xFF9E9A92),
      successColor: Color(0xFF4A8B6E),
      warningColor: Color(0xFFD97724),
      errorColor: Color(0xFFC4484A),
    ),
    ThemePaletteModel(
      id: 'quiet_luxury_light',
      name: '2026 Classic Ivory (Aydınlık)',
      price: 0,
      isUnlocked: true,
      isDark: false,
      primaryColor: Color(0xFFB38B40),
      secondaryColor: Color(0xFF4A6B5F),
      backgroundColor: Color(0xFFF7F5F0),
      surfaceColor: Color(0xFFFFFFFF),
      surfaceBorderColor: Color(0xFFE5E0D5),
      textPrimaryColor: Color(0xFF1A1A1E),
      textSecondaryColor: Color(0xFF6B6760),
      successColor: Color(0xFF388E3C),
      warningColor: Color(0xFFF57C00),
      errorColor: Color(0xFFD32F2F),
    ),
    ThemePaletteModel(
      id: 'neon_cyber',
      name: 'Night Cyberpunk',
      price: 25000,
      isUnlocked: false,
      isDark: true,
      primaryColor: Color(0xFF00E5FF),
      secondaryColor: Color(0xFFD500F9),
      backgroundColor: Color(0xFF0A0E17),
      surfaceColor: Color(0xFF121824),
      surfaceBorderColor: Color(0xFF1F293D),
      textPrimaryColor: Color(0xFFE0F7FA),
      textSecondaryColor: Color(0xFF80DEEA),
      successColor: Color(0xFF00E676),
      warningColor: Color(0xFFFF9100),
      errorColor: Color(0xFFFF1744),
    ),
    ThemePaletteModel(
      id: 'vintage_racing',
      name: 'Vintage Racing Green',
      price: 50000,
      isUnlocked: false,
      isDark: true,
      primaryColor: Color(0xFF2E7D32),
      secondaryColor: Color(0xFFA1887F),
      backgroundColor: Color(0xFF111C14),
      surfaceColor: Color(0xFF1C2B1F),
      surfaceBorderColor: Color(0xFF2E4232),
      textPrimaryColor: Color(0xFFE8F5E9),
      textSecondaryColor: Color(0xFFA5D6A7),
      successColor: Color(0xFF66BB6A),
      warningColor: Color(0xFFFFA726),
      errorColor: Color(0xFFEF5350),
    ),
    ThemePaletteModel(
      id: 'imperial_ruby',
      name: 'Royal Ruby & Silver',
      price: 75000,
      isUnlocked: false,
      isDark: true,
      primaryColor: Color(0xFFD32F2F),
      secondaryColor: Color(0xFFB0BEC5),
      backgroundColor: Color(0xFF140809),
      surfaceColor: Color(0xFF211012),
      surfaceBorderColor: Color(0xFF381B1F),
      textPrimaryColor: Color(0xFFFFEBEE),
      textSecondaryColor: Color(0xFFFFCDD2),
      successColor: Color(0xFF43A047),
      warningColor: Color(0xFFFB8C00),
      errorColor: Color(0xFFE53935),
    ),
  ];
}
