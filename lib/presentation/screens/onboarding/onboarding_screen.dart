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
