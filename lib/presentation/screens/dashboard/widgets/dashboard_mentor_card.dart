import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../domain/usecases/mentor_quest_engine.dart';
import '../../../../domain/usecases/smart_mentor_engine.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/market_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import '../../../widgets/pixel_mentor_avatar.dart';
import '../../../widgets/steam_cup_widget.dart';

/// Halil Usta Masası • Kontrol Paneli Ortam Rehber Kartı
/// Oyuncuyu tam ekran modal ile bölmeden, kontrol panelinde canlı
/// ve etkileşimli olarak derin esnaf tavsiyeleri sunar.
/// Yüksek kontrastlı Neo-Brutalist taktil geometri ve prosedürel atölye dokusuyla donatılmıştır.
class DashboardMentorCard extends ConsumerWidget {
  const DashboardMentorCard({super.key});

  String _formatText(String template, Map<String, String> params) {
    var result = template;
    params.forEach((key, val) {
      result = result.replaceAll('{$key}', val);
    });
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    if (!game.tutorialCompleted) return const SizedBox.shrink();

    final marketListings = ref.watch(marketProvider);
    final advice = SmartMentorEngine.evaluateAdvice(
      game,
      marketListings: marketListings,
    );

    if (advice == null) return const SizedBox.shrink();

    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final activeQuest = MentorQuestEngine.getActiveQuest(game);
    final canServeTea = MentorQuestEngine.canServeTea(game);

    var quoteRaw = context.tr(advice.quoteKey);
    if (quoteRaw == advice.quoteKey) {
      final baseKey = advice.quoteKey.replaceAll(RegExp(r'_v\d$'), '');
      quoteRaw = context.tr(baseKey);
    }
    final quoteText = _formatText(quoteRaw, advice.params);

    final tacticalRaw = context.tr(advice.tacticalKey);
    final tacticalText = _formatText(tacticalRaw, advice.params);

    final titleRaw = context.tr(advice.titleKey);
    final titleText = _formatText(titleRaw, advice.params);

    final actionLabel = context.tr(advice.actionBtnKey);

    final brutalBorderColor = isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A);
    final brutalShadowColor = isDark ? Colors.black54 : const Color(0xFF0F172A);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(13),
        backgroundColor: isDark ? const Color(0xFF131722) : Colors.white,
        borderColor: brutalBorderColor,
        borderRadius: 14,
        borderWidth: 2.5,
        shadowOffset: const Offset(4.0, 4.0),
        child: CustomPaint(
          painter: _MentorWorkbenchPainter(
            isDark: isDark,
            accentColor: advice.accentColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst İstasyon Bilgi Satırı • Yüksek Kontrastlı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('mentor_desk_station_id'),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: advice.accentColor,
                          border: Border.all(
                            color: brutalBorderColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        advice.mood == MentorMood.teaSip
                            ? context.tr('mentor_station_badge_tea')
                            : context.tr('mentor_station_badge_radar'),
                        style: TextStyle(
                          fontSize: 9.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Üst Bölüm: Avatar + Konuşma Kartı
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      final greetingKey = switch (advice.mood) {
                        MentorMood.neutral => 'mentor_tap_greeting_neutral',
                        MentorMood.teaSip => 'mentor_tap_greeting_teasip',
                        MentorMood.worried => 'mentor_tap_greeting_worried',
                        MentorMood.proud => 'mentor_tap_greeting_proud',
                        MentorMood.clever => 'mentor_tap_greeting_clever',
                      };
                      final greeting = context.tr(greetingKey);
                      final message = greeting.isNotEmpty ? greeting : context.tr('mentor_tap_greeting');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            message,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: PixelMentorAvatar(
                      size: 48,
                      backgroundColor: advice.accentColor,
                      borderColor: brutalBorderColor,
                      borderWidth: 2.2,
                      shadowOffset: const Offset(2.5, 2.5),
                      animated: true,
                      mood: advice.mood,
                      isGlitching: advice.isCriticalModal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1B2130) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: brutalBorderColor,
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: brutalShadowColor,
                            offset: const Offset(2.5, 2.5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              NeoBrutalBadge(
                                text: context.tr('mentor_card_banner_title'),
                                backgroundColor: AppColors.brutalYellow,
                                textColor: Colors.black,
                                fontSize: 10.0,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: brutalBorderColor,
                                    width: 1.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: brutalShadowColor,
                                      offset: const Offset(1.5, 1.5),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      advice.iconData,
                                      size: 12,
                                      color: isDark ? advice.accentColor : const Color(0xFF0F172A),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      titleText,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            quoteText,
                            style: TextStyle(
                              fontSize: 12.0,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Taktiksel Hamle Kutusu • Yüksek Kontrastlı Usta Servis Notu
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0E131D) : const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: brutalBorderColor,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: brutalShadowColor,
                      offset: const Offset(2.5, 2.5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4.0,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isDark ? advice.accentColor : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.lightbulb_rounded,
                      size: 16,
                      color: isDark ? AppColors.brutalYellow : const Color(0xFF92400E),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('mentor_tactical_note_header'),
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: isDark ? AppColors.brutalYellow : const Color(0xFF78350F),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tacticalText,
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Halil Usta Hikaye Görevi (Narrative Side Quest)
              if (activeQuest != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161B26) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: brutalBorderColor,
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: brutalShadowColor,
                        offset: const Offset(2.5, 2.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            activeQuest.isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.assignment_outlined,
                            size: 14,
                            color: activeQuest.isCompleted ? const Color(0xFF16A34A) : const Color(0xFFCA8A04),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            context.tr('mentor_quest_badge_title'),
                            style: TextStyle(
                              fontSize: 9.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                            ),
                          ),
                          const Spacer(),
                          if (activeQuest.isCompleted)
                            Transform.rotate(
                              angle: -0.08,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.toxicLime,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFF0F172A), width: 1.8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF0F172A),
                                      offset: Offset(1.5, 1.5),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  context.tr('mentor_quest_approved_stamp').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            )
                          else
                            Text(
                              '${activeQuest.currentProgress} / ${activeQuest.targetGoal}',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr(activeQuest.titleKey),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr(activeQuest.descriptionKey),
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (activeQuest.isCompleted) ...[
                        const SizedBox(height: 6),
                        NeoBrutalButton.primary(
                          label: context.tr('quest_halil_claim_reward'),
                          icon: Icons.card_giftcard_rounded,
                          fontSize: 10.5,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            ref.read(gameProvider.notifier).claimMentorQuest(activeQuest.id);
                          },
                        ),
                      ] else ...[
                        const SizedBox(height: 6),
                        _buildQuestQuickAction(context, ref, activeQuest.id, isDark),
                      ],
                    ],
                  ),
                ),
              ],

              // Halil Usta Çay Ocağı Etkileşimi • Çay ısmarlanınca tamamen kapanır
              if (canServeTea) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    final served = ref.read(gameProvider.notifier).serveTeaToHalil();
                    if (served) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.tr('quest_halil_tea_served_today'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          backgroundColor: AppColors.toxicLime,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF271C14) : const Color(0xFFFED7AA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: brutalBorderColor,
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: brutalShadowColor,
                          offset: const Offset(2.5, 2.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SteamCupWidget(
                          size: 20,
                          teaColor: const Color(0xFFB45309),
                          borderColor: isDark ? Colors.white70 : const Color(0xFF0F172A),
                          steamColor: isDark ? Colors.white38 : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.tr('quest_halil_serve_tea_btn'),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.brutalOrange,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: brutalBorderColor,
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Aksiyon Butonu
              NeoBrutalButton.trade(
                label: actionLabel,
                icon: Icons.bolt_rounded,
                fullWidth: true,
                fontSize: 11.5,
                padding: const EdgeInsets.symmetric(vertical: 8),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref.read(gameProvider.notifier).recordMentorAdvice(advice);
                  ref.read(gameProvider.notifier).markFeatureSeen(advice.targetRoute);
                  if (advice.targetRoute == '/showroom') {
                    ref.read(dashboardTabProvider.notifier).state = 1;
                  } else if (advice.targetRoute == '/marketplace') {
                    ref.read(dashboardTabProvider.notifier).state = 2;
                  } else {
                    context.push(advice.targetRoute);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestQuickAction(
    BuildContext context,
    WidgetRef ref,
    String questId,
    bool isDark,
  ) {
    String label;
    IconData icon;
    VoidCallback onTap;

    switch (questId) {
      case MentorQuestEngine.questFirstPurchase:
        label = context.tr('quest_action_goto_market');
        icon = Icons.storefront_rounded;
        onTap = () {
          HapticFeedback.selectionClick();
          ref.read(dashboardTabProvider.notifier).state = 2;
        };
        break;
      case MentorQuestEngine.questFirstProfitSale:
        label = context.tr('quest_action_goto_showroom');
        icon = Icons.directions_car_filled_rounded;
        onTap = () {
          HapticFeedback.selectionClick();
          ref.read(dashboardTabProvider.notifier).state = 1;
        };
        break;
      case MentorQuestEngine.questReachLevelTwo:
      default:
        label = context.tr('quest_action_view_status');
        icon = Icons.trending_up_rounded;
        onTap = () {
          HapticFeedback.selectionClick();
          ref.read(dashboardTabProvider.notifier).state = 0;
        };
        break;
    }

    return NeoBrutalButton(
      label: label,
      icon: icon,
      fontSize: 10.0,
      fontWeight: FontWeight.w900,
      padding: const EdgeInsets.symmetric(vertical: 5),
      backgroundColor: isDark ? const Color(0xFF262C3D) : const Color(0xFFF1F5F9),
      textColor: isDark ? Colors.white : const Color(0xFF0F172A),
      borderColor: isDark ? const Color(0xFF475569) : Colors.black,
      borderWidth: 2.0,
      shadowOffset: const Offset(2.0, 2.0),
      onPressed: onTap,
    );
  }
}

/// Halil Usta Atölye Masası Arka Plan Prosedürel Dokusu
/// Sıfır bellek harcamasıyla milimetrik cetvel çentikleri, köşe artı imleri
/// ve taktil tram stippling noktaları çizer.
class _MentorWorkbenchPainter extends CustomPainter {
  final bool isDark;
  final Color accentColor;

  _MentorWorkbenchPainter({
    required this.isDark,
    required this.accentColor,
  });

  final Paint _tickPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;

  final Paint _dotPaint = Paint()
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    _tickPaint.color = isDark
        ? const Color(0xFF475569).withValues(alpha: 0.45)
        : const Color(0xFF475569).withValues(alpha: 0.35);
    _dotPaint.color = isDark
        ? const Color(0xFF475569).withValues(alpha: 0.22)
        : const Color(0xFF0F172A).withValues(alpha: 0.08);

    // 1. Üst kenar boyunca milimetrik cetvel çentikleri
    for (double x = 16.0; x < size.width - 16.0; x += 12.0) {
      final isMajor = (x / 12.0).round() % 4 == 0;
      final tickHeight = isMajor ? 4.5 : 2.5;
      canvas.drawLine(Offset(x, 2.0), Offset(x, 2.0 + tickHeight), _tickPaint);
    }

    // 2. Köşe hizalama artı (+) imleri
    const crossSize = 3.5;
    final corners = [
      const Offset(8, 8),
      Offset(size.width - 8, 8),
      const Offset(8, 8),
      Offset(size.width - 8, size.height - 8),
    ];
    for (final c in corners) {
      canvas.drawLine(Offset(c.dx - crossSize, c.dy), Offset(c.dx + crossSize, c.dy), _tickPaint);
      canvas.drawLine(Offset(c.dx, c.dy - crossSize), Offset(c.dx, c.dy + crossSize), _tickPaint);
    }

    // 3. Sağ alt köşede taktil Bayer tram stippling dokusu
    const step = 8.0;
    final startY = size.height * 0.75;
    for (double y = startY; y < size.height - 8.0; y += step) {
      for (double x = size.width * 0.72; x < size.width - 8.0; x += step) {
        if (((x / step).toInt() + (y / step).toInt()) % 2 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, 1.2, 1.2), _dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MentorWorkbenchPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.accentColor != accentColor;
  }
}
