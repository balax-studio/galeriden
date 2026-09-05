import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class WorkshopAcousticDiagnosticDialog {
  static void show(BuildContext context, CarModel car) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final diagnoses = [
      (
        context.tr('workshop_steth_tap_title'),
        'subap',
        context.tr('workshop_steth_tap_desc'),
      ),
      (
        context.tr('workshop_steth_turbo_title'),
        'turbo',
        context.tr('workshop_steth_turbo_desc'),
      ),
      (
        context.tr('workshop_steth_bearing_title'),
        'sanziman',
        context.tr('workshop_steth_bearing_desc'),
      ),
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(20),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
            borderRadius: 12,
            borderWidth: 2.5,
            shadowOffset: const Offset(4, 4),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hearing_rounded,
                          color: AppColors.brutalOrange, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.tr('workshop_engine_diagnose_title'),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('workshop_steth_banner_desc', {
                      'brand': car.brand,
                      'modelName': car.modelName,
                    }),
                    style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...diagnoses.map((d) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          NotificationService.showSuccess(
                            context,
                            context.tr('workshop_steth_success',
                                {'diagnosis': d.$1}),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: NeoBrutalCard(
                          padding: const EdgeInsets.all(10),
                          backgroundColor: isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFF1F5F9),
                          borderColor: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A),
                          borderRadius: 8,
                          borderWidth: 1.5,
                          shadowOffset: const Offset(2, 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d.$1,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 2),
                              Text(d.$3,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      NeoBrutalButton(
                        label: context.tr('btn_close'),
                        backgroundColor: isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFE2E8F0),
                        textColor: isDark ? Colors.white : Colors.black,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
