import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/utils/notification_service.dart';
import '../../../domain/usecases/contextual_emergency_ad_engine.dart';
import '../../providers/game_provider.dart';
import '../app_vector_icons.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';

class NeoBrutalContextualLifelineDialog extends ConsumerWidget {
  final ContextualLifelineEncounter encounter;
  final VoidCallback? onAccepted;
  final VoidCallback? onDismissed;

  const NeoBrutalContextualLifelineDialog({
    super.key,
    required this.encounter,
    this.onAccepted,
    this.onDismissed,
  });

  static Future<bool?> show(
    BuildContext context, {
    required ContextualLifelineEncounter encounter,
    VoidCallback? onAccepted,
    VoidCallback? onDismissed,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => NeoBrutalContextualLifelineDialog(
        encounter: encounter,
        onAccepted: onAccepted,
        onDismissed: onDismissed,
      ),
    );
  }

  void _claimBenefit(BuildContext context, WidgetRef ref) {
    ref.read(gameProvider.notifier).claimContextualLifeline(encounter);
    onAccepted?.call();
    if (context.mounted) {
      Navigator.of(context).pop(true);
      NotificationService.showSuccess(
        context,
        context.tr('lifeline_toast_claimed_success'),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final game = ref.watch(gameProvider);
    final hasNoAds = game.hasNoAdsLicense;
    final accentColor = Color(encounter.accentColorHex);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(20),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: accentColor,
          borderWidth: 3.0,
          borderRadius: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Badges Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: NeoBrutalBadge(
                      text: context.tr('lifeline_header_badge'),
                      icon: Icons.shield_rounded,
                      backgroundColor: accentColor,
                      textColor: Colors.black,
                      fontSize: 10.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: NeoBrutalBadge(
                      text: context.tr('lifeline_header_time_badge'),
                      icon: Icons.bolt_rounded,
                      backgroundColor: isDark
                          ? const Color(0xFF222938)
                          : const Color(0xFFE2E8F0),
                      textColor: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Character Avatar & Caller Identity
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white24 : const Color(0xFF0F172A),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black54 : const Color(0xFF0F172A),
                          offset: const Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: AvatarIconWidget(
                      avatar: encounter.avatarKey,
                      size: 28,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(encounter.callerNameKey),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: accentColor, width: 1.0),
                          ),
                          child: Text(
                            context.tr(encounter.callerRoleKey),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isDark ? accentColor : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3. Title & Subtitle
              Text(
                context.tr(encounter.titleKey, encounter.translationArgs),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr(encounter.subtitleKey),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 12),

              // 4. In-Universe Story Narrative Dialogue Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B0D13) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF222938) : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          size: 16,
                          color: accentColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            context.tr(encounter.storyDialogueKey, encounter.translationArgs),
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.45,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 5. Highlighted Benefit Pill Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentColor, width: 2.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: accentColor,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('lifeline_benefit_title'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isDark ? accentColor : const Color(0xFF0F172A),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr(encounter.perkSummaryKey, encounter.translationArgs),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 6. Action Buttons
              NeoBrutalButton(
                label: hasNoAds
                    ? context.tr('lifeline_btn_accept_instant')
                    : context.tr(encounter.ctaKey),
                icon: hasNoAds
                    ? Icons.flash_on_rounded
                    : Icons.play_circle_fill_rounded,
                backgroundColor: accentColor,
                textColor: Colors.black,
                fontSize: 13.5,
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  if (hasNoAds) {
                    _claimBenefit(context, ref);
                  } else {
                    AdService.instance.showRewardedAd(
                      onRewardEarned: () {
                        _claimBenefit(context, ref);
                      },
                      onAdUnavailable: () {
                        // In-universe fallback: reward is granted if ad unavailable
                        _claimBenefit(context, ref);
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 8),

              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onDismissed?.call();
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  context.tr(encounter.dismissKey),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
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
