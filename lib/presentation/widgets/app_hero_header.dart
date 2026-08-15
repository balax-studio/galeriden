import 'package:flutter/material.dart';
import '../../data/models/dealership_model.dart';
import 'game_hud_widget.dart';

/// Beneloil Style Game Top Bar Wrapper
class AppHeroHeader extends StatelessWidget {
  final DealershipModel game;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onProfileTap;

  const AppHeroHeader({
    super.key,
    required this.game,
    this.onSettingsTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.5),
            Colors.black.withValues(alpha: 0.0),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: const SafeArea(
        bottom: false,
        child: GameHudHeaderWidget(),
      ),
    );
  }
}
