import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/scrapyard_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_card.dart';

class ScrapyardInstallDialog {
  static void show(BuildContext context, WidgetRef ref, SalvagedPart part) {
    final game = ref.read(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final eligibleCars =
        game.ownedCars.where((c) => !c.isRented && !c.isConsignment).toList();

    if (eligibleCars.isEmpty) {
      NotificationService.showError(
          context, context.tr('scrap_no_installable_cars'));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(18),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('scrap_dialog_install_title'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('scrap_dialog_install_desc',
                      {'part': part.name, 'cond': '${part.conditionPercent}'}),
                  style: const TextStyle(
                       fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: eligibleCars.length,
                    itemBuilder: (cCtx, i) {
                      final car = eligibleCars[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            final success = ref
                                .read(gameProvider.notifier)
                                .installPartToCar(part.id, car.id);
                            if (success) {
                              NotificationService.showSuccess(
                                context,
                                context.tr('scrap_install_success_toast', {
                                  'part': part.name,
                                  'car': '${car.brand} ${car.modelName}',
                                }),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0F1118)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF333B4F)
                                    : const Color(0xFF0F172A),
                                width: 2.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${car.modelYear} ${car.brand} ${car.modelName}',
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                      'Motor: %${car.expertise.engineCondition.round()} • Şanzıman: %${car.expertise.transmissionCondition.round()}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded,
                                    size: 14),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
