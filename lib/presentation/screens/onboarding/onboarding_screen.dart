import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/game_provider.dart';
import '../../providers/tutorial_provider.dart';
import '../../widgets/app_vector_icons.dart';

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

  final List<Map<String, String>> _pages = [
    {
      'title': 'Deden Hasan Usta\'dan Kalan Miras',
      'subtitle': 'Eski usta dedenden sana 1978 model bir Tofaş Murat 124 ve 75.000 ₺ sermaye miras kaldı. Ama araç yürür vaziyette değil...',
      'vectorType': 'car',
    },
    {
      'title': 'Stratejik Tamir & Parça Siparişi',
      'subtitle': 'Atölyede arızaları incele. Parçayı geçici tamir mi edeceksin, ustaya mı göndereceksin yoksa yeni parça mı sipariş edeceksin? Bütçeni iyi yönet!',
      'vectorType': 'workshop',
    },
    {
      'title': 'İlk Satışını Yap & Galerini Büyüt',
      'subtitle': 'Onardığın aracı ilana koy, gelen pazarlıkları değerlendir. İlk kârınla otomotiv imparatorluğunun temelini at!',
      'vectorType': 'expertise',
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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text('Atla', style: AppTypography.bodyMedium(p.isDark)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: p.primaryColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: p.primaryColor, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: VectorIconWidget(
                            type: item['vectorType']!,
                            color: p.primaryColor,
                            size: 54,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          item['title']!,
                          textAlign: TextAlign.center,
                          style: AppTypography.headlineMedium(p.isDark),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item['subtitle']!,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium(p.isDark),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? p.primaryColor : p.surfaceBorderColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.primaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
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
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Galeriyi Aç' : 'Devam Et',
                    style: AppTypography.titleLarge(false).copyWith(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
