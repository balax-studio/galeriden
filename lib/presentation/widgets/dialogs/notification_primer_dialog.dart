import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/local_notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/game_provider.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';

/// Halil Usta baglamsal bildirim on izin diyalogu (Pre-Permission Primer)
/// Ilk arac vitrine ciktiginda veya vitrinde arac varken tek seferlik gosterilir.
class NotificationPrimerDialog extends ConsumerWidget {
  const NotificationPrimerDialog({super.key});

  static const String _prefKey = 'has_prompted_notification_primer';

  /// Uygun kosullari denetler ve gerekirse diyalogu baslatir
  static Future<bool> checkAndShow(BuildContext context, WidgetRef ref) async {
    final game = ref.read(gameProvider);
    final hasListedCar = game.ownedCars.any((c) => c.isListed && !c.isRented);
    if (!hasListedCar) return false;

    final prefs = await SharedPreferences.getInstance();
    final hasPrompted = prefs.getBool(_prefKey) ?? false;
    if (hasPrompted) return false;

    await prefs.setBool(_prefKey, true);

    if (!context.mounted) return false;
    final result = await show(context);
    return result ?? false;
  }

  /// Diyalogu acikca ekrana basar
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const NotificationPrimerDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(20),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: AppColors.brutalYellow,
          borderWidth: 2.5,
          borderRadius: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Rozet
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeoBrutalBadge(
                    text: context.tr('notification_primer_badge'),
                    icon: Icons.notifications_active_rounded,
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 10.5,
                  ),
                  NeoBrutalBadge(
                    text: 'Usta • Onaylı',
                    icon: Icons.verified_rounded,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 10.0,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Baslik
              Text(
                context.tr('notification_primer_title'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),

              // Aciklama / Lore
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  context.tr('notification_primer_desc'),
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Aksiyon Butonlari
              NeoBrutalButton(
                label: context.tr('notification_primer_accept'),
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                icon: Icons.check_circle_rounded,
                minHeight: 46,
                onPressed: () async {
                  Navigator.of(context).pop(true);
                  await LocalNotificationService.instance.requestPermissions();
                },
              ),
              const SizedBox(height: 8),
              NeoBrutalButton(
                label: context.tr('notification_primer_decline'),
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                textColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                borderColor: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                minHeight: 42,
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
