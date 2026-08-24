import '../../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../providers/game_provider.dart';
import '../../providers/tutorial_provider.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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

  final List<Map<String, dynamic>> _pages = [
    {
      'tagKey': 'onboarding_tag_story',
      'tagColor': AppColors.brutalYellow,
      'titleKey': 'onboarding_title_story',
      'subtitleKey': 'onboarding_desc_story',
      'vectorType': 'car',
      'icon': Icons.directions_car_filled_rounded,
      'accent': AppColors.brutalYellow,
    },
    {
      'tagKey': 'onboarding_tag_workshop',
      'tagColor': AppColors.brutalOrange,
      'titleKey': 'onboarding_title_workshop',
      'subtitleKey': 'onboarding_desc_workshop',
      'vectorType': 'workshop',
      'icon': Icons.build_circle_rounded,
      'accent': AppColors.brutalOrange,
    },
    {
      'tagKey': 'onboarding_tag_market',
      'tagColor': AppColors.brutalGreen,
      'titleKey': 'onboarding_title_market',
      'subtitleKey': 'onboarding_desc_market',
      'vectorType': 'expertise',
      'icon': Icons.monetization_on_rounded,
      'accent': AppColors.brutalGreen,
    },
  ];

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    ref.read(gameProvider.notifier).completeTutorial();
    ref.read(tutorialProvider.notifier).skipTutorial();
    if (mounted) {
      context.go('/dealership-identity');
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Top Brand Header & Skip Button
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    onPressed: _finishOnboarding,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Monolithic Card Carousel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: NeoBrutalCard(
                        padding: const EdgeInsets.all(24),
                        backgroundColor:
                            isDark ? const Color(0xFF141721) : Colors.white,
                        borderColor: isDark
                            ? const Color(0xFF333B4F)
                            : const Color(0xFF0F172A),
                        borderRadius: 12,
                        borderWidth: 2.5,
                        shadowOffset: const Offset(4, 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Tag Badge
                            NeoBrutalBadge(
                              text: context.tr(item['tagKey'] as String),
                              backgroundColor: item['tagColor'] as Color,
                              textColor: Colors.black,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                            ),
                            const SizedBox(height: 24),

                            // Monolithic Icon Frame
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: (item['accent'] as Color)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
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
                              child: VectorIconWidget(
                                type: item['vectorType'] as String,
                                color: item['accent'] as Color,
                                size: 54,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Title
                            Text(
                              context.tr(item['titleKey'] as String),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Subtitle
                            Text(
                              context.tr(item['subtitleKey'] as String),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF475569),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Page Indicators (Monolithic Blocks)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 28 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.brutalYellow
                          : (isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF333B4F)
                            : const Color(0xFF0F172A),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Bottom Action Button
              NeoBrutalButton(
                label: _currentPage == _pages.length - 1
                    ? context.tr('onboarding_start_btn')
                    : context.tr('onboarding_next_btn'),
                icon: _currentPage == _pages.length - 1
                    ? Icons.store_rounded
                    : Icons.arrow_forward_rounded,
                fullWidth: true,
                backgroundColor: _currentPage == _pages.length - 1
                    ? AppColors.brutalGreen
                    : AppColors.brutalYellow,
                textColor: Colors.black,
                borderColor:
                    isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                fontSize: 14,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _finishOnboarding();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
