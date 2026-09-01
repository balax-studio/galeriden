import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../providers/game_provider.dart';
import '../../providers/tutorial_provider.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_page_background.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      final game = ref.read(gameProvider);
      if ((hasSeenOnboarding || game.tutorialCompleted) && mounted) {
        context.go('/dashboard');
      }
    });
  }

  void _startGuidedJourney() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    ref.read(tutorialProvider.notifier).setStep(TutorialStep.inspectHeritageCar);
    if (mounted) {
      context.go('/dealership-identity');
    }
  }

  void _skipAllTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    ref.read(gameProvider.notifier).skipTutorial();
    ref.read(tutorialProvider.notifier).skipTutorial();
    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      body: NeoBrutalPageBackground(
        watermark: ThematicWatermarkType.dealership,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Top Brand Header & Skip Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFF0F172A),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? const Color(0xFF000000)
                                    : const Color(0xFF0F172A),
                                offset: const Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GALERİSİNDEN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              context.tr('onboarding_tycoon_subtitle'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    NeoBrutalButton(
                      label: context.tr('onboarding_skip_btn'),
                      backgroundColor: isDark
                          ? const Color(0xFF1E2330)
                          : const Color(0xFFE2E8F0),
                      textColor:
                          isDark ? Colors.white70 : const Color(0xFF0F172A),
                      borderColor: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFF0F172A),
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      onPressed: _skipAllTutorial,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Single Focused High-Impact Welcome Card
                Expanded(
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(22),
                    backgroundColor:
                        isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: isDark
                        ? const Color(0xFF333B4F)
                        : const Color(0xFF0F172A),
                    borderRadius: 14,
                    borderWidth: 2.5,
                    shadowOffset: const Offset(4.5, 4.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tag Badge
                        NeoBrutalBadge(
                          text: context.tr('onboarding_single_tag'),
                          backgroundColor: AppColors.brutalYellow,
                          textColor: Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                        ),
                        const SizedBox(height: 18),

                        // Visual Frame
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.brutalYellow
                                .withValues(alpha: isDark ? 0.20 : 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFF0F172A),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? const Color(0xFF000000)
                                    : const Color(0xFF0F172A),
                                offset: const Offset(3, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              color: AppColors.brutalYellow,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF0F172A),
                                width: 2.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF0F172A),
                                  offset: Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.directions_car_filled_rounded,
                              size: 38,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          context.tr('onboarding_single_title'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 3 Actionable Bullet Points (Kinesthetic Highlights)
                        _buildBulletTile(
                          icon: Icons.garage_rounded,
                          text: context.tr('onboarding_single_bullet_1'),
                          accentColor: AppColors.brutalYellow,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _buildBulletTile(
                          icon: Icons.build_circle_rounded,
                          text: context.tr('onboarding_single_bullet_2'),
                          accentColor: AppColors.brutalOrange,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _buildBulletTile(
                          icon: Icons.monetization_on_rounded,
                          text: context.tr('onboarding_single_bullet_3'),
                          accentColor: AppColors.brutalGreen,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // High-Visibility Neo-Brutalist Tutorial Action Button
                NeoBrutalButton(
                  label: context.tr('onboarding_single_start_btn'),
                  icon: Icons.key_rounded,
                  fullWidth: true,
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  borderColor: const Color(0xFF0F172A),
                  borderWidth: 2.5,
                  shadowOffset: const Offset(4.0, 4.0),
                  fontSize: 14,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onPressed: _startGuidedJourney,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBulletTile({
    required IconData icon,
    required String text,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2C) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF0F172A),
                width: 1.5,
              ),
            ),
            child: Icon(icon, size: 16, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
