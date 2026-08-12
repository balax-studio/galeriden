import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/app_vector_icons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Galerisinden Tycoon\'a Hoş Geldin',
      'subtitle': 'Kendi araba galeri imparatorluğunu kur. İkinci el araç pazarını takip et, kelepir araçları bul ve kâr et.',
      'vectorType': 'car',
    },
    {
      'title': 'Detaylı Ekspertiz İncelemesi',
      'subtitle': 'Aracı satın almadan önce ekspertize sok. Kaporta hasarlarını, motor durumunu ve Tramer kaydını ortaya çıkar.',
      'vectorType': 'expertise',
    },
    {
      'title': 'Tamir Et, Temizle & İlana Koy',
      'subtitle': 'Atölyede aracı restore et, pasta-cila yap. İlana koyarak gelen pazarlık tekliflerini değerlendir ve galerin seviye atlasın.',
      'vectorType': 'workshop',
    },
  ];

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
                  onPressed: () => context.go('/dashboard'),
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
                      context.go('/dashboard');
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
