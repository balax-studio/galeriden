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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: Colors.transparent,
      child: const SafeArea(
        bottom: false,
        child: GameHudHeaderWidget(),
      ),
    );
  }
}
