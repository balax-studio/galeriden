import 'package:flutter/material.dart';
import 'game_hud_widget.dart';

/// Beneloil Style Game Top Bar Wrapper
class AppHeroHeader extends StatelessWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onProfileTap;

  const AppHeroHeader({
    super.key,
    this.onSettingsTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            width: 2.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: const SafeArea(
        bottom: false,
        child: GameHudHeaderWidget(),
      ),
    );
  }
}
