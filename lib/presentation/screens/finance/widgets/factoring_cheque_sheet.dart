import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/cheque_model.dart';
import '../../../../data/models/mega_systems_extensions_model.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class FactoringChequeSheet extends StatelessWidget {
  final List<Cheque> cheques;
  final Function(String chequeId) onChequeFactored;

  const FactoringChequeSheet({
    super.key,
    required this.cheques,
    required this.onChequeFactored,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: Color(0xFF333B4F), width: 2.5),
          left: BorderSide(color: Color(0xFF333B4F), width: 2.5),
          right: BorderSide(color: Color(0xFF333B4F), width: 2.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.brutalYellow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF333B4F), width: 2.0),
                ),
                child: const Icon(Icons.currency_exchange_rounded, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'FAKTORİNG & ÇEK KIRDIRMA',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Vadesi gelmemiş müşteri çeklerinizi %8.5 iskonto ile anında peşin nakde çevirin.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (cheques.isEmpty)
            const NeoBrutalCard(
              padding: EdgeInsets.all(18),
              backgroundColor: Color(0xFF141721),
              borderColor: Color(0xFF333B4F),
              borderRadius: 10,
              child: Center(
                child: Text(
                  'Portföyünüzde kırdırılabilecek aktif çek bulunmamaktadır.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...cheques.map((c) {
              final deal = FactoringDeal.calculate(c.id, c.amount);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: const Color(0xFF141721),
                  borderColor: const Color(0xFF333B4F),
                  borderRadius: 10,
                  borderWidth: 2.0,
                  shadowOffset: const Offset(3, 3),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2330),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF333B4F), width: 1.5),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: AppColors.brutalYellow, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Çek Tutarı: ₺${c.amount.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5),
                            ),
                            Text(
                              'Vade: ${c.dueDays} Gün Sonra',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                            ),
                            Text(
                              'Net Ödeme: ₺${deal.payoutCash.toStringAsFixed(0)} (-%8.5)',
                              style: const TextStyle(color: AppColors.brutalGreen, fontWeight: FontWeight.w800, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      NeoBrutalButton(
                        label: 'KIRDIR',
                        backgroundColor: AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 11,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        onPressed: () {
                          Navigator.of(context).pop();
                          onChequeFactored(c.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
