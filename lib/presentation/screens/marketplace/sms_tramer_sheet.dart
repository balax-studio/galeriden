import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/listing_model.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class SmsTramerSheet extends StatelessWidget {
  final ListingModel listing;

  const SmsTramerSheet({super.key, required this.listing});

  static void show(BuildContext context, ListingModel listing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SmsTramerSheet(listing: listing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final car = listing.car;
    final exp = car.expertise;
    final plate = car.plateNumber.isNotEmpty ? car.plateNumber : '34 GLR ${100 + (car.id.hashCode % 899)}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          width: 2.5,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                child: const Icon(Icons.sms_rounded, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '5664 HASAR & SİGORTA GEÇMİŞİ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$plate • SBM Tramer Veritabanı',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // SMS Bubble Card
          NeoBrutalCard(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
            borderRadius: 12,
            borderWidth: 2.0,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'GÖNDEREN: 5664 • SBM',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF38BDF8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Bugün, ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Text(
                  'Sayin Ilgili, Kayitlarimiza gore $plate sasi no ile eslesen ${car.brand} ${car.modelName} ${car.modelYear} model aracta:',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                if (exp.tramerAmount == 0) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E575).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00E575), width: 1.5),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_rounded, color: Color(0xFF00E575), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'HASAR KAYDI YOKTUR • ₺0 Tramer. Aracın sigorta havuzunda kayıtlı herhangi bir kazası bulunmamaktadır.',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF00E575),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'TOPLAM HASAR: ${CurrencyFormatter.formatShort(exp.tramerAmount.toDouble())}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• KZ1: ${(exp.tramerAmount * 0.6).round()} TL • Çarpma / Kaporta Onarımı\n'
                          '• KZ2: ${(exp.tramerAmount * 0.4).round()} TL • Dolu / Boya & Düzeltme',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                if (exp.isMileageTampered) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.report_problem_rounded, color: Color(0xFFEF4444), size: 16),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'DİKKAT: Son muayene KM kaydı mevcut kadrandan yüksektir! • KM Oynanmış',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text(
                    'Son TÜVTÜRK Muayenesi: ${(exp.mileage * 0.95).round()} KM • KM Orijinal',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Close button
          NeoBrutalButton(
            label: 'ANLADIM, RAPORU KAPAT',
            icon: Icons.check_circle_outline_rounded,
            backgroundColor: const Color(0xFFFFDE59),
            textColor: Colors.black,
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
