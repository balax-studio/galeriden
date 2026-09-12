import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../domain/usecases/smart_mentor_engine.dart';
import '../providers/dashboard_provider.dart';
import '../providers/game_provider.dart';
import 'neo_brutal_badge.dart';
import 'neo_brutal_button.dart';
import 'neo_brutal_card.dart';
import 'pixel_mentor_avatar.dart';

/// Halil Usta Akıllı Esnaf Rehberi Neo-Brutalist Pop-up
/// Oyun sıkıştığında veya yeni bir mekanik / şube fırsatı doğduğunda
/// oyuncuya derinlemesine taktiksel yol gösterir.
class SmartMentorDialog extends ConsumerWidget {
  final SmartMentorAdvice advice;
  final bool animatedAvatar;

  const SmartMentorDialog({
    super.key,
    required this.advice,
    this.animatedAvatar = true,
  });

  static Future<void> show(BuildContext context, SmartMentorAdvice advice) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SmartMentorDialog(advice: advice),
    );
  }

  String _formatText(String template, Map<String, String> params) {
    var result = template;
    params.forEach((key, val) {
      result = result.replaceAll('{$key}', val);
    });
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final quoteRaw = context.tr(advice.quoteKey);
    final quoteText = _formatText(quoteRaw, advice.params);

    final tacticalRaw = context.tr(advice.tacticalKey);
    final tacticalText = _formatText(tacticalRaw, advice.params);

    final titleRaw = context.tr(advice.titleKey);
    final titleText = _formatText(titleRaw, advice.params);

    final actionLabel = context.tr(advice.actionBtnKey);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(18),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
            borderRadius: 16,
            borderWidth: 2.8,
            shadowOffset: const Offset(4.5, 4.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Üst Başlık Satırı: HALİL USTA Rozeti + Sağ Üstte 8-Bit Piksel Avatar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Kullanıcı Kriteri: Başlıkta sadece "HALİL USTA" yazsın
                          Row(
                            children: [
                              NeoBrutalBadge(
                                text: context.tr('mentor_badge_halil_usta'),
                                backgroundColor: AppColors.brutalYellow,
                                textColor: Colors.black,
                                fontSize: 13,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Tavsiye Durumu Başlığı
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: advice.accentColor.withAlpha(isDark ? 50 : 35),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: advice.accentColor,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  advice.iconData,
                                  size: 14,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    titleText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sağ Üst Köşe 8-Bit Neo-Brutalist Avatar
                    PixelMentorAvatar(
                      size: 64,
                      backgroundColor: advice.accentColor,
                      borderColor: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFF0F172A),
                      animated: animatedAvatar,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Halil Usta'nın Sözü Konuşma Baloncuğu
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1B202E)
                        : const Color(0xFFFFFBEB),
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
                            ? const Color(0xFF333B4F)
                            : const Color(0xFF0F172A),
                        offset: const Offset(2.5, 2.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            size: 18,
                            color: isDark
                                ? AppColors.brutalYellow
                                : const Color(0xFFD97706),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.tr('mentor_quote_badge_label'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: isDark
                                  ? AppColors.brutalYellow
                                  : const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        quoteText,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white.withAlpha(235)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Derin Taktiksel Hamle Kutusu
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F131D)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: advice.accentColor,
                      width: 1.8,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: advice.accentColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.black,
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('mentor_tactical_step_label'),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              tacticalText,
                              style: TextStyle(
                                fontSize: 11.5,
                                height: 1.4,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Aksiyon Butonları
                NeoBrutalButton.trade(
                  label: actionLabel,
                  icon: Icons.bolt_rounded,
                  fullWidth: true,
                  shadowOffset: const Offset(3.5, 3.5),
                  fontSize: 13.5,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ref
                        .read(gameProvider.notifier)
                        .markFeatureSeen(advice.targetRoute);
                    Navigator.of(context).pop();
                    if (advice.targetRoute == '/showroom') {
                      ref.read(dashboardTabProvider.notifier).state = 1;
                    } else if (advice.targetRoute == '/marketplace') {
                      ref.read(dashboardTabProvider.notifier).state = 2;
                    } else {
                      context.push(advice.targetRoute);
                    }
                  },
                ),
                const SizedBox(height: 8),
                NeoBrutalButton.neutral(
                  label: context.tr('mentor_btn_dismiss'),
                  fullWidth: true,
                  shadowOffset: const Offset(2.5, 2.5),
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (advice.type == SmartMentorAdviceType.featureUnlocked) {
                      ref
                          .read(gameProvider.notifier)
                          .markFeatureSeen(advice.targetRoute);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
