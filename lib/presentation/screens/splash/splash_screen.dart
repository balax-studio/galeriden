import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/game_provider.dart';
import '../../widgets/dot_grid_background.dart';
import '../../widgets/hazard_stripe_widget.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_card.dart';

/// High-impact 1.5-second Neo-Brutalist Splash and Telemetry Loading Screen
/// Features industrial tactile aesthetics, animated RPM progress gauge,
/// Balax Studio production stamping, and smooth route gating.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _proceedToNextScreen();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _proceedToNextScreen() async {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      final game = ref.read(gameProvider);

      if (!mounted) return;
      if (!hasSeenOnboarding && !game.tutorialCompleted) {
        context.go('/onboarding');
      } else {
        context.go('/dashboard');
      }
    } catch (_) {
      // Safe fallback when GoRouter is not attached in test harnesses
    }
  }

  String _getTelemetryStatus(double progress) {
    if (progress < 0.40) {
      return context.tr('splash_loading_step1');
    } else if (progress < 0.85) {
      return context.tr('splash_loading_step2');
    } else {
      return context.tr('splash_loading_step3');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D14),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Fast-forward on touch for eager players
          if (!_hasNavigated) {
            _controller.stop();
            _proceedToNextScreen();
          }
        },
        child: Stack(
          children: [
            // Background tactical dot grid
            const Positioned.fill(
              child: Opacity(
                opacity: 0.35,
                child: DotGridBackground(
                  child: SizedBox.expand(),
                ),
              ),
            ),

            // Top Animated Hazard Stripe
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: HazardStripeWidget(
                  height: 12.0,
                  stripeWidth: 12.0,
                  isAnimated: true,
                  color1: AppColors.brutalYellow,
                  color2: Color(0xFF0F172A),
                ),
              ),
            ),

            // Bottom Animated Hazard Stripe
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: HazardStripeWidget(
                  height: 12.0,
                  stripeWidth: 12.0,
                  isAnimated: true,
                  color1: AppColors.brutalYellow,
                  color2: Color(0xFF0F172A),
                ),
              ),
            ),

            // Central Core Interface
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 2),

                    // 1. Balax Studio Presents Stamped Badge
                    Center(
                      child: Transform.rotate(
                        angle: -0.04,
                        child: NeoBrutalBadge(
                          text: context.tr('splash_studio_present'),
                          backgroundColor: AppColors.brutalYellow,
                          textColor: Colors.black,
                          borderColor: Colors.black,
                          borderWidth: 2.2,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          icon: Icons.verified_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 2. Main Title & Tactical Subtitle Badge
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Hard black outline offset shadow
                              Text(
                                'GALERİDEN',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3.5,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 6.0
                                    ..color = Colors.black,
                                ),
                              ),
                              const Text(
                                'GALERİDEN',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3.5,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          NeoBrutalBadge(
                            text: context.tr('splash_tagline'),
                            backgroundColor: const Color(0xFF1E2433),
                            textColor: const Color(0xFF94A3B8),
                            borderColor: const Color(0xFF334155),
                            borderWidth: 1.8,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 3. Center Tactical Emblem
                    Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B26),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.brutalYellow,
                              offset: Offset(4.0, 4.0),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.speed_rounded,
                            size: 46,
                            color: AppColors.brutalYellow,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // 4. Telemetry Loading Console
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final progress = _controller.value;
                        final percent = (progress * 100).toInt();
                        final statusText = _getTelemetryStatus(progress);

                        return NeoBrutalCard(
                          backgroundColor: const Color(0xFF141722),
                          borderColor: Colors.black,
                          borderWidth: 2.5,
                          borderRadius: 14,
                          shadowOffset: const Offset(3.5, 3.5),
                          shadowColor: Colors.black,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Telemetry Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.toxicLime,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'ENGINE TELEMETRY',
                                        style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$percent%',
                                    style: const TextStyle(
                                      color: AppColors.brutalYellow,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Chunky Neo-Brutalist Progress Bar
                              Container(
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0A0D14),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: Colors.black, width: 2.0),
                                ),
                                child: Stack(
                                  children: [
                                    FractionallySizedBox(
                                      widthFactor: progress.clamp(0.02, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: percent > 85
                                              ? AppColors.toxicLime
                                              : AppColors.brutalYellow,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    // Segment Tick Marks
                                    Row(
                                      children: List.generate(
                                        9,
                                        (index) => Expanded(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              width: 1.5,
                                              height: double.infinity,
                                              color: Colors.black38,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Realtime Status Readout
                              Text(
                                statusText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const Spacer(flex: 3),

                    // 5. Version & Production Tag
                    Center(
                      child: Text(
                        'V${GameConstants.appVersion} • BALAX STUDIO PRODUCTION',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
