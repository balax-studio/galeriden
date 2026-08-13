import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../core/theme/app_typography.dart';
import '../providers/game_provider.dart';
import '../providers/tutorial_provider.dart';
import 'app_glass_container.dart';
import 'app_vector_icons.dart';

class TutorialOverlayBanner extends ConsumerWidget {
  const TutorialOverlayBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final tutorial = ref.watch(tutorialProvider);

    if (game.tutorialCompleted || !tutorial.isActive) {
      return const SizedBox.shrink();
    }

    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: AppGlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderColor: p.primaryColor.withValues(alpha: 0.5),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: p.primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: VectorIconWidget(
                type: 'lightbulb',
                size: 20,
                color: p.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'REHBER GÖREVİ (${tutorial.step.index + 1}/11)',
                    style: AppTypography.labelSmall(p.isDark).copyWith(
                      color: p.primaryColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tutorial.stepInstruction,
                    style: AppTypography.bodyMedium(p.isDark).copyWith(
                      color: p.textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Rehberi Atla',
              icon: VectorIconWidget(
                type: 'close',
                size: 18,
                color: p.textSecondaryColor,
              ),
              onPressed: () {
                ref.read(tutorialProvider.notifier).skipTutorial();
                ref.read(gameProvider.notifier).completeTutorial();
              },
            ),
          ],
        ),
      ),
    );
  }
}
