import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/customer_crm_event_model.dart';
import '../../providers/game_provider.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';

class CustomerFollowUpDialog extends ConsumerWidget {
  final CustomerCrmEventModel event;

  const CustomerFollowUpDialog({super.key, required this.event});

  static Future<void> show(BuildContext context, CustomerCrmEventModel event) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomerFollowUpDialog(event: event),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDispute = event.type == CustomerCrmEventType.hiddenDefectDispute;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(18),
        backgroundColor: isDark ? const Color(0xFF10141D) : Colors.white,
        borderColor: event.accentColor,
        borderWidth: 3.0,
        borderRadius: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: event.accentColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 2.0),
                  ),
                  child: Icon(event.icon, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${event.customerName} • ${event.carModelName}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBrutalBadge(
                  text: 'CRM',
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF19202E) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 1.5,
                ),
              ),
              child: Text(
                event.description,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            if (isDispute) ...[
              const Text(
                'ESNAF DURUŞUNU SEÇ',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
              const SizedBox(height: 10),
              NeoBrutalButton(
                label: 'ÜCRETSİZ ONAR - ESNAFLIK GÖSTER',
                icon: Icons.handyman_rounded,
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fullWidth: true,
                onPressed: () {
                  ref.read(gameProvider.notifier).resolveCustomerDispute(
                        event: event,
                        choice: CrmResolutionChoice.generousRepair,
                      );
                  Navigator.of(context).pop();
                  NotificationService.showSuccess(
                    context,
                    'Müşteri memnun edildi! Galeriye +25 itibar eklendi.',
                  );
                },
              ),
              const SizedBox(height: 8),
              NeoBrutalButton(
                label: 'İSKONTOLU TAKAS TEKLİF ET',
                icon: Icons.sync_rounded,
                backgroundColor: AppColors.brutalYellow,
                textColor: Colors.black,
                fullWidth: true,
                onPressed: () {
                  ref.read(gameProvider.notifier).resolveCustomerDispute(
                        event: event,
                        choice: CrmResolutionChoice.discountedTradeIn,
                      );
                  Navigator.of(context).pop();
                  NotificationService.showInfo(
                    context,
                    'Takas teklifi yapıldı. Galeriye +10 itibar eklendi.',
                  );
                },
              ),
              const SizedBox(height: 8),
              NeoBrutalButton(
                label: 'SÖZLEŞMEYİ GÖSTER - İTİRAZI REDDET',
                icon: Icons.close_rounded,
                backgroundColor: isDark ? const Color(0xFF222838) : const Color(0xFFF1F5F9),
                textColor: isDark ? Colors.white70 : Colors.black87,
                fullWidth: true,
                onPressed: () {
                  ref.read(gameProvider.notifier).resolveCustomerDispute(
                        event: event,
                        choice: CrmResolutionChoice.firmContract,
                      );
                  Navigator.of(context).pop();
                  NotificationService.showWarning(
                    context,
                    'İtiraz reddedildi. Müşteri sosyal medyada şikayet yazdı.',
                  );
                },
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.brutalGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.brutalGreen, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kazanım:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Text(
                      '+${CurrencyFormatter.formatShort(event.financialImpact)} • +${event.reputationImpact} İtibar',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              NeoBrutalButton(
                label: 'ÖDÜLÜ VE İTİBARI AL',
                icon: Icons.check_circle_rounded,
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fullWidth: true,
                onPressed: () {
                  ref.read(gameProvider.notifier).acceptCustomerCrmAppreciation(event);
                  Navigator.of(context).pop();
                  NotificationService.showSuccess(
                    context,
                    'Kazanımlar kasanıza ve itibarınıza eklendi!',
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
