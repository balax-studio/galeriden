import 'package:flutter/material.dart';
import '../../data/models/theme_palette_model.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final ThemePaletteModel palette;

  const AppThemeExtension({required this.palette});

  @override
  AppThemeExtension copyWith({ThemePaletteModel? palette}) {
    return AppThemeExtension(palette: palette ?? this.palette);
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      palette: ThemePaletteModel(
        id: palette.id,
        name: palette.name,
        price: palette.price,
        isUnlocked: palette.isUnlocked,
        isDark: palette.isDark,
        primaryColor: Color.lerp(palette.primaryColor, other.palette.primaryColor, t)!,
        secondaryColor: Color.lerp(palette.secondaryColor, other.palette.secondaryColor, t)!,
        backgroundColor: Color.lerp(palette.backgroundColor, other.palette.backgroundColor, t)!,
        surfaceColor: Color.lerp(palette.surfaceColor, other.palette.surfaceColor, t)!,
        surfaceBorderColor: Color.lerp(palette.surfaceBorderColor, other.palette.surfaceBorderColor, t)!,
        textPrimaryColor: Color.lerp(palette.textPrimaryColor, other.palette.textPrimaryColor, t)!,
        textSecondaryColor: Color.lerp(palette.textSecondaryColor, other.palette.textSecondaryColor, t)!,
        successColor: Color.lerp(palette.successColor, other.palette.successColor, t)!,
        warningColor: Color.lerp(palette.warningColor, other.palette.warningColor, t)!,
        errorColor: Color.lerp(palette.errorColor, other.palette.errorColor, t)!,
      ),
    );
  }
}
