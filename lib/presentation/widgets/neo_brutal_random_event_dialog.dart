import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/game_sound_haptic_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/notification_service.dart';
import '../../data/models/game_event_model.dart';
import '../providers/game_provider.dart';
import 'app_vector_icons.dart';
import 'neo_brutal_badge.dart';
import 'neo_brutal_card.dart';

class NeoBrutalRandomEventDialog extends ConsumerWidget {
  final GameEventModel event;

  const NeoBrutalRandomEventDialog({
    super.key,
    required this.event,
  });

  static Future<void> show(BuildContext context, GameEventModel event) {
    GameSoundHapticService.playWarningVibration();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NeoBrutalRandomEventDialog(event: event),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color headerBadgeColor;
    String headerBadgeText;
    switch (event.type) {
      case GameEventType.goodEvent:
      case GameEventType.income:
        headerBadgeColor = const Color(0xFF00E575);
        headerBadgeText = context.tr('event_type_good');
        break;
      case GameEventType.badEvent:
      case GameEventType.expense:
        headerBadgeColor = const Color(0xFFEF4444);
        headerBadgeText = context.tr('event_type_bad');
        break;
      case GameEventType.meme:
        headerBadgeColor = const Color(0xFFFFDE59);
        headerBadgeText = context.tr('event_type_meme');
        break;
      case GameEventType.neutral:
        headerBadgeColor = const Color(0xFF38BDF8);
        headerBadgeText = context.tr('event_type_neutral');
        break;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: NeoBrutalCard(
        backgroundColor: isDark ? const Color(0xFF131620) : Colors.white,
        borderColor: isDark ? const Color(0xFF2E3748) : const Color(0xFF0F172A),
        borderWidth: 2.8,
        borderRadius: 18,
        shadowOffset: const Offset(5, 5),
        shadowColor: isDark ? Colors.black87 : const Color(0xFF0F172A),
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeoBrutalBadge(
                    text: headerBadgeText,
                    backgroundColor: headerBadgeColor,
                    textColor: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  ),
                  NeoBrutalBadge(
                    text: context.tr('event_type_daily'),
                    backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white70 : const Color(0xFF475569),
                    fontSize: 9.5,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title and Icon
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: headerBadgeColor.withValues(alpha: isDark ? 0.25 : 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF384252) : const Color(0xFF0F172A),
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black54 : const Color(0xFF0F172A),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: AvatarIconWidget(
                      avatar: event.iconEmoji,
                      size: 26,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Description Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B202D) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1),
                    width: 2.0,
                  ),
                ),
                child: Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Choices list
              Text(
                context.tr('event_what_will_you_do'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              ...event.choices.map((choice) {
                final hasCost = choice.balanceChange < 0;
                final hasReward = choice.balanceChange > 0;
                Color choiceBg = isDark ? const Color(0xFF1A1F2C) : Colors.white;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(gameProvider.notifier).resolveRandomEvent(choice);

                      if (choice.balanceChange > 0) {
                        GameSoundHapticService.playCashSuccess();
                      } else {
                        GameSoundHapticService.playWarningVibration();
                      }

                      NotificationService.showSuccess(
                        context,
                        '${choice.resultText}\n'
                        '${choice.balanceChange != 0 ? (choice.balanceChange > 0 ? "+${CurrencyFormatter.formatShort(choice.balanceChange)}" : CurrencyFormatter.formatShort(choice.balanceChange)) : ""} '
                        '${choice.reputationChange != 0 ? "• ${choice.reputationChange > 0 ? "+" : ""}${context.tr('label_reputation_delta', {'val': choice.reputationChange})}" : ""}',
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: choiceBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            hasCost
                                ? Icons.money_off_rounded
                                : (hasReward ? Icons.monetization_on_rounded : Icons.touch_app_rounded),
                            size: 20,
                            color: hasCost
                                ? const Color(0xFFEF4444)
                                : (hasReward ? const Color(0xFF00E575) : const Color(0xFFFFDE59)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  choice.label,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                if (choice.resultText.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    choice.resultText,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
