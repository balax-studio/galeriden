import 'package:galeriden/core/utils/notification_service.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/listing_model.dart';
import '../../../domain/usecases/negotiation_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/market_provider.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class InteractiveNegotiationSheet extends ConsumerStatefulWidget {
  final ListingModel listing;

  const InteractiveNegotiationSheet({
    super.key,
    required this.listing,
  });

  @override
  ConsumerState<InteractiveNegotiationSheet> createState() => _InteractiveNegotiationSheetState();
}

class _InteractiveNegotiationSheetState extends ConsumerState<InteractiveNegotiationSheet> {
  late double _offeredPrice;
  String? _sellerResponse;
  bool _isAccepted = false;
  late CustomerModel _customer;

  @override
  void initState() {
    super.initState();
    _offeredPrice = (widget.listing.askingPrice * 0.90).roundToDouble();
    _customer = CustomerModel.generateRandomCustomer();
  }

  /// Calculates success probability based on player negotiation skill and discount percentage requested
  int _calculateSuccessChance(int negotiationSkillLevel) {
    final asking = widget.listing.askingPrice;
    if (_offeredPrice >= asking) return 100;

    final discountPercent = ((asking - _offeredPrice) / asking) * 100;

    // Base success curve: 5% discount = 80%, 10% discount = 50%, 15% discount = 20%
    double baseChance = 100.0 - (discountPercent * 5.2);

    // Add bonus from player Negotiation skill (each level gives +4% success chance)
    double skillBonus = negotiationSkillLevel * 4.0;

    return (baseChance + skillBonus).clamp(5.0, 98.0).round();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final asking = widget.listing.askingPrice;

    final chancePercent = _calculateSuccessChance(game.skills.negotiationLevel);
    final discountAmount = asking - _offeredPrice;
    final discountRatio = ((discountAmount / asking) * 100).toStringAsFixed(1);

    Color chanceColor;
    if (chancePercent >= 70) {
      chanceColor = p.successColor;
    } else if (chancePercent >= 40) {
      chanceColor = p.warningColor;
    } else {
      chanceColor = p.errorColor;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: p.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PAZARLIK MASASI', style: AppTypography.titleLarge(p.isDark)),
              IconButton(
                icon: Icon(Icons.close, color: p.textPrimaryColor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(
            '${widget.listing.sellerName} ile teklifleşiyorsun.',
            style: AppTypography.bodyMedium(p.isDark),
          ),
          const SizedBox(height: 8),

          // Customer Archetype Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: p.primaryColor.withValues(alpha: 0.2),
                  child: VectorIconWidget(type: _customer.avatarType, color: p.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_customer.name, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: p.secondaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(_customer.archetypeTitle, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(_customer.personalityDescription, style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Vehicle Card Summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.surfaceBorderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.listing.title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                    Text(widget.listing.sellerCity, style: AppTypography.labelSmall(p.isDark)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Satıcı İlan Fiyatı', style: AppTypography.labelSmall(p.isDark)),
                    Text(CurrencyFormatter.format(asking), style: AppTypography.moneyMedium(p.isDark).copyWith(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Offer Slider & Live Probability Gauge
          Text('SENİN TEKLİFİN', style: AppTypography.labelSmall(p.isDark)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.format(_offeredPrice),
                style: AppTypography.moneyLarge(p.isDark).copyWith(fontSize: 26, color: p.primaryColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chanceColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: chanceColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.psychology_rounded, size: 16, color: chanceColor),
                    const SizedBox(width: 4),
                    Text(
                      'İkna Şansı: %$chancePercent',
                      style: TextStyle(color: chanceColor, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            discountAmount > 0 ? 'İstenen İndirim: ${CurrencyFormatter.formatShort(discountAmount)} (-%$discountRatio)' : 'Tam Fiyat Teklifi',
            style: AppTypography.labelSmall(p.isDark),
          ),
          const SizedBox(height: 10),

          Slider(
            value: _offeredPrice,
            min: (asking * 0.75).roundToDouble(),
            max: asking,
            divisions: 50,
            activeColor: p.primaryColor,
            inactiveColor: p.surfaceBorderColor,
            onChanged: _sellerResponse != null
                ? null
                : (val) {
                    setState(() {
                      _offeredPrice = val.roundToDouble();
                    });
                  },
          ),
          const SizedBox(height: 12),

          // Dialogue Outcome Display
          if (_sellerResponse != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isAccepted ? p.successColor.withValues(alpha: 0.15) : p.errorColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _isAccepted ? p.successColor : p.errorColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isAccepted ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: _isAccepted ? p.successColor : p.errorColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isAccepted ? 'TEKLİF KABUL EDİLDİ!' : 'TEKLİF REDDEDİLDİ',
                        style: TextStyle(color: _isAccepted ? p.successColor : p.errorColor, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('"${_sellerResponse!}"', style: AppTypography.bodyMedium(p.isDark).copyWith(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Discrepancy Bargaining Leverage Card
          if (_sellerResponse == null) ...[
            Builder(
              builder: (context) {
                final disc = NegotiationEngine.detectExpertiseDiscrepancy(widget.listing.car);
                if (!disc.hasDiscrepancy) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: const Color(0xFFFEF3C7),
                    borderColor: Colors.black,
                    borderWidth: 2,
                    borderRadius: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.report_problem_rounded, color: Color(0xFFD97706), size: 20),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'KOZ FIRSATI: ${disc.title}',
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          disc.description,
                          style: const TextStyle(color: Color(0xFF451A03), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        NeoBrutalButton(
                          label: 'Gizli Kusuru Koz Kullan (-%${(disc.extraDiscountPercent * 100).toInt()} İndirim)',
                          icon: Icons.gavel_rounded,
                          backgroundColor: const Color(0xFFD97706),
                          textColor: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          fullWidth: true,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onPressed: () {
                            final targetDiscPrice = (asking * (1.0 - disc.extraDiscountPercent)).roundToDouble();
                            setState(() {
                              _offeredPrice = targetDiscPrice;
                              _isAccepted = true;
                              _sellerResponse = 'Usta yakaladın beni, haklısın... Gizli kusuru kabul ediyorum. Teklifin olan ${CurrencyFormatter.formatShort(targetDiscPrice)} fiyata hemen veriyorum!';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],

          // Action Buttons
          Row(
            children: [
              if (_sellerResponse == null)
                Expanded(
                  child: NeoBrutalButton(
                    label: 'TEKLİFİ GÖNDER',
                    icon: Icons.send_rounded,
                    backgroundColor: p.primaryColor,
                    textColor: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onPressed: () {
                      final roll = Random().nextInt(100) + 1;
                      if (roll <= chancePercent) {
                        setState(() {
                          _isAccepted = true;
                          _sellerResponse = 'Tamam arkadaşım, dediğin fiyata veriyorum. Hayırlı olsun!';
                        });
                      } else {
                        setState(() {
                          _isAccepted = false;
                          _sellerResponse = 'Kusura bakma bu fiyata imkanı yok kurtarmaz. Biraz daha yukarı çıkman lazım.';
                        });
                      }
                    },
                  ),
                )
              else if (_isAccepted)
                Expanded(
                  child: NeoBrutalButton(
                    label: '${CurrencyFormatter.formatShort(_offeredPrice)} ÖDE VE SATIN AL',
                    icon: Icons.shopping_bag_rounded,
                    backgroundColor: const Color(0xFF22C55E),
                    textColor: Colors.black,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onPressed: game.balance < _offeredPrice
                        ? null
                        : () {
                            final outcome = ref.read(gameProvider.notifier).buyCar(
                                  widget.listing.car,
                                  _offeredPrice,
                                  isExpertiseCompleted: widget.listing.isExpertiseCompleted,
                                );
                            if (outcome != null) {
                              ref.read(marketProvider.notifier).removeListing(widget.listing.id);
                              final nav = Navigator.of(context);
                              nav.pop(); // Close sheet
                              if (nav.canPop()) {
                                nav.pop(); // Return to market if on detail screen
                              }

                              if (outcome.isTrapped) {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: p.surfaceColor,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: p.errorColor, size: 28),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            outcome.title,
                                            style: TextStyle(color: p.errorColor, fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Text(
                                      outcome.description,
                                      style: TextStyle(color: p.textPrimaryColor, fontSize: 14),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: Text('Anladım', style: TextStyle(color: p.primaryColor, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                NotificationService.showSuccess(context, 'Tebrikler! ${widget.listing.car.brand} ${widget.listing.car.modelName} ₺${CurrencyFormatter.formatShort(_offeredPrice)} fiyata satın alındı!');
                              }
                            }
                          },
                  ),
                )
              else
                Expanded(
                  child: NeoBrutalButton(
                    label: 'TEKLİFİ REVİZE ET',
                    icon: Icons.refresh_rounded,
                    backgroundColor: p.surfaceColor,
                    textColor: p.textPrimaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onPressed: () {
                      setState(() {
                        _sellerResponse = null;
                      });
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
