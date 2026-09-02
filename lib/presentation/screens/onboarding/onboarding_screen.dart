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
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      final game = ref.read(gameProvider);
      if ((hasSeenOnboarding || game.tutorialCompleted) && mounted) {
        context.go('/dashboard');
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  void _goToNextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _startGuidedJourney();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final List<Map<String, dynamic>> pages = [
      {
        'tagKey': 'onboarding_single_tag',
        'tagColor': AppColors.brutalYellow,
        'titleKey': 'onboarding_single_title',
        'storyKey': 'onboarding_single_story_desc',
        'icon': Icons.directions_car_filled_rounded,
        'accent': AppColors.brutalYellow,
        'bullets': [
          {
            'icon': Icons.badge_rounded,
            'textKey': 'onboarding_heritage_who_are_we',
            'color': AppColors.brutalYellow,
          },
          {
            'icon': Icons.time_to_leave_rounded,
            'textKey': 'onboarding_heritage_car_origin',
            'color': AppColors.brutalOrange,
          },
          {
            'icon': Icons.trending_up_rounded,
            'textKey': 'onboarding_heritage_mission',
            'color': AppColors.brutalGreen,
          },
        ],
      },
      {
        'tagKey': 'onboarding_tag_workshop',
        'tagColor': AppColors.brutalOrange,
        'titleKey': 'onboarding_title_workshop',
        'storyKey': 'onboarding_desc_workshop',
        'icon': Icons.build_circle_rounded,
        'accent': AppColors.brutalOrange,
        'bullets': [
          {
            'icon': Icons.search_rounded,
            'textKey': 'onboarding_workshop_bullet_1',
            'color': AppColors.brutalOrange,
          },
          {
            'icon': Icons.inventory_2_rounded,
            'textKey': 'onboarding_workshop_bullet_2',
            'color': AppColors.brutalYellow,
          },
          {
            'icon': Icons.price_check_rounded,
            'textKey': 'onboarding_workshop_bullet_3',
            'color': AppColors.brutalGreen,
          },
        ],
      },
      {
        'tagKey': 'onboarding_tag_market',
        'tagColor': AppColors.brutalGreen,
        'titleKey': 'onboarding_title_market',
        'storyKey': 'onboarding_desc_market',
        'icon': Icons.storefront_rounded,
        'accent': AppColors.brutalGreen,
        'bullets': [
          {
            'icon': Icons.store_rounded,
            'textKey': 'onboarding_market_bullet_1',
            'color': AppColors.brutalGreen,
          },
          {
            'icon': Icons.account_balance_wallet_rounded,
            'textKey': 'onboarding_market_bullet_2',
            'color': AppColors.brutalYellow,
          },
          {
            'icon': Icons.domain_rounded,
            'textKey': 'onboarding_market_bullet_3',
            'color': AppColors.brutalOrange,
          },
        ],
      },
    ];

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      body: NeoBrutalPageBackground(
        watermark: ThematicWatermarkType.dealership,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                // Top Brand Header & Skip Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
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
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GALERİSİNDEN',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              context.tr('onboarding_tycoon_subtitle'),
                              style: TextStyle(
                                fontSize: 9.5,
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
                      fontSize: 10.5,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      onPressed: _skipAllTutorial,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Interactive Story Cards PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (idx) {
                      setState(() {
                        _currentPage = idx;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = pages[index];
                      final tagColor = item['tagColor'] as Color;
                      final accent = item['accent'] as Color;
                      final icon = item['icon'] as IconData;
                      final bullets =
                          item['bullets'] as List<Map<String, dynamic>>;

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return NeoBrutalCard(
                            padding: EdgeInsets.zero,
                            backgroundColor:
                                isDark ? const Color(0xFF141721) : Colors.white,
                            borderColor: isDark
                                ? const Color(0xFF333B4F)
                                : const Color(0xFF0F172A),
                            borderRadius: 14,
                            borderWidth: 2.5,
                            shadowOffset: const Offset(3.5, 3.5),
                            child: SizedBox(
                              height: constraints.maxHeight - 6,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Tag Badge
                                    NeoBrutalBadge(
                                      text:
                                          context.tr(item['tagKey'] as String),
                                      backgroundColor: tagColor,
                                      textColor: Colors.black,
                                      fontSize: 10,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                    ),
                                    const SizedBox(height: 10),

                                    // Visual Frame
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: accent.withValues(
                                            alpha: isDark ? 0.20 : 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isDark
                                              ? const Color(0xFF333B4F)
                                              : const Color(0xFF0F172A),
                                          width: 2.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark
                                                ? const Color(0xFF000000)
                                                : const Color(0xFF0F172A),
                                            offset: const Offset(2.0, 2.0),
                                            blurRadius: 0,
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: accent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF0F172A),
                                            width: 1.8,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          icon,
                                          size: 24,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Title
                                    Text(
                                      context.tr(item['titleKey'] as String),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Narrative Story Callout Box
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1B2232)
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isDark
                                              ? const Color(0xFF2A344A)
                                              : const Color(0xFFCBD5E1),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.format_quote_rounded,
                                            size: 18,
                                            color: accent,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              context.tr(
                                                  item['storyKey'] as String),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? const Color(0xFFE2E8F0)
                                                    : const Color(0xFF334155),
                                                height: 1.35,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // 3 Structured Kinesthetic Bullets
                                    for (int i = 0; i < bullets.length; i++) ...[
                                      if (i > 0) const SizedBox(height: 6),
                                      _buildBulletTile(
                                        icon: bullets[i]['icon'] as IconData,
                                        text: context.tr(
                                            bullets[i]['textKey'] as String),
                                        accentColor:
                                            bullets[i]['color'] as Color,
                                        isDark: isDark,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Page Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pages.length, (index) {
                    final isSelected = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isSelected ? 20 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brutalYellow
                            : (isDark
                                ? const Color(0xFF2A344A)
                                : const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A),
                          width: 1.2,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),

                // Action Navigation Buttons
                if (_currentPage < 2)
                  Row(
                    children: [
                      Expanded(
                        child: NeoBrutalButton(
                          label: context.tr('onboarding_single_start_btn'),
                          icon: Icons.key_rounded,
                          backgroundColor: isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0),
                          textColor: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          borderColor: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A),
                          borderWidth: 2.0,
                          shadowOffset: const Offset(2.5, 2.5),
                          fontSize: 11.5,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          onPressed: _startGuidedJourney,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NeoBrutalButton(
                          label: context.tr('onboarding_next_btn'),
                          icon: Icons.arrow_forward_rounded,
                          backgroundColor: AppColors.brutalYellow,
                          textColor: Colors.black,
                          borderColor: const Color(0xFF0F172A),
                          borderWidth: 2.0,
                          shadowOffset: const Offset(2.5, 2.5),
                          fontSize: 11.5,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          onPressed: _goToNextPage,
                        ),
                      ),
                    ],
                  )
                else
                  NeoBrutalButton(
                    label: context.tr('onboarding_single_start_btn'),
                    icon: Icons.key_rounded,
                    fullWidth: true,
                    backgroundColor: AppColors.brutalGreen,
                    textColor: Colors.black,
                    borderColor: const Color(0xFF0F172A),
                    borderWidth: 2.5,
                    shadowOffset: const Offset(3.5, 3.5),
                    fontSize: 13.5,
                    padding: const EdgeInsets.symmetric(vertical: 13),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2C) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: const Color(0xFF0F172A),
                width: 1.2,
              ),
            ),
            child: Icon(icon, size: 13, color: Colors.black),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10.5,
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
