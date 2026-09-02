import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/stock_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_button.dart';

class IpoRequestModal {
  static void show(BuildContext context, WidgetRef ref, IpoOfferModel ipo) {
    final game = ref.read(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lotCtrl = TextEditingController(text: ipo.maxLotPerUser.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final int requestedLots = int.tryParse(lotCtrl.text) ?? 0;
            final double totalCost = requestedLots * ipo.lotPrice;

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(dialogCtx).viewInsets.bottom),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141721) : Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border.all(
                        color: isDark
                            ? const Color(0xFF333B4F)
                            : const Color(0xFF0F172A),
                        width: 2.5),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                        context.tr(
                            'stock_ipo_demand_title', {'symbol': ipo.symbol}),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                        context.tr('stock_ipo_max_limit',
                            {'amount': ipo.maxLotPerUser}),
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 12),
                    TextField(
                      controller: lotCtrl,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      decoration: InputDecoration(
                        hintText: context.tr('stock_lot_hint'),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF0F1118)
                            : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        suffixText: 'LOT',
                      ),
                      onChanged: (val) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr(
                          'ipo_total_demand_cost', {'cost': totalCost.round()}),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brutalGreen),
                    ),
                    const SizedBox(height: 16),
                    NeoBrutalButton(
                      label: context.tr('ipo_btn_confirm_demand'),
                      icon: Icons.check_circle_outline_rounded,
                      backgroundColor: AppColors.brutalGreen,
                      textColor: Colors.black,
                      fullWidth: true,
                      onPressed: () {
                        if (requestedLots <= 0 ||
                            requestedLots > ipo.maxLotPerUser) {
                          NotificationService.showError(
                            context,
                            context.tr('ipo_max_lot_error',
                                {'max': ipo.maxLotPerUser}),
                          );
                          return;
                        }
                        if (game.balance < totalCost) {
                          NotificationService.showError(context,
                              context.tr('stock_insufficient_funds_toast'));
                          return;
                        }
                        final success = ref
                            .read(gameProvider.notifier)
                            .requestIpo(ipo.id, requestedLots);
                        if (success) {
                          Navigator.pop(dialogCtx);
                          NotificationService.showSuccess(
                            context,
                            context.tr('ipo_demand_success_toast',
                                {'symbol': ipo.symbol}),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  },
).then((_) => lotCtrl.dispose());
}
}
