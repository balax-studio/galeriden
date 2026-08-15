import 'package:galeriden/core/utils/notification_service.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/listing_model.dart';
import '../../../domain/usecases/negotiation_engine.dart';
import '../../../domain/usecases/psychology_engine.dart';
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
  bool _isProcessing = false;
  bool _isThinking = false;
  String _thinkingText = '';
  int _counterOfferCount = 0;
  bool _isNearMiss = false;
  bool _isLockedOut = false;
  late CustomerModel _customer;
  late String _fomoText;

  @override
  void initState() {
    super.initState();
    _offeredPrice = (widget.listing.askingPrice * 0.90).roundToDouble();
    _customer = CustomerModel.generateSellerFromListing(widget.listing.sellerName);
    _fomoText = PsychologyEngine.getRandomFomoText();
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
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7A00).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFF7A00).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFFF7A00)),
                          const SizedBox(width: 4),
                          Text(
                            _fomoText,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF7A00),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text('Pazarlık:', style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 10.5)),
                        const SizedBox(width: 4),
                        ...List.generate(3, (index) {
                          final isLeft = index < (3 - _counterOfferCount);
                          return Container(
                            margin: const EdgeInsets.only(left: 3),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isLeft ? p.primaryColor : (p.isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1)),
                            ),
                          );
                        }),
                        const SizedBox(width: 4),
                        Text(
                          '${3 - _counterOfferCount}/3',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: _counterOfferCount >= 3 ? p.errorColor : p.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
            onChanged: (_sellerResponse != null || _isThinking || _isLockedOut)
                ? null
                : (val) {
                    setState(() {
                      _offeredPrice = val.roundToDouble();
                    });
                  },
          ),
          if (_isThinking) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: p.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.primaryColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: p.primaryColor),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _thinkingText,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: p.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_sellerResponse == null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                PsychologyEngine.getSuspenseNegotiationText(),
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: p.isDark ? Colors.white60 : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Dialogue Outcome Display
          if (_sellerResponse != null) ...[
            NeoBrutalCard(
              backgroundColor: _isAccepted ? p.successColor.withValues(alpha: 0.15) : p.errorColor.withValues(alpha: 0.15),
              borderColor: _isAccepted ? p.successColor : p.errorColor,
              borderWidth: 2,
              borderRadius: 14,
              padding: const EdgeInsets.all(16),
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
                  Text(
                    '${_customer.name}: "${_sellerResponse!}"',
                    style: AppTypography.bodyMedium(p.isDark).copyWith(fontStyle: FontStyle.italic),
                  ),
                  if (_isNearMiss && !_isAccepted && !_isLockedOut) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.near_me_rounded, size: 14, color: Color(0xFFD97706)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Çok yaklaştın! Satıcı kararsız kaldı ama fiyatı biraz daha yükseltmen gerek.',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_isLockedOut) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEF4444)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.block_rounded, size: 14, color: Color(0xFFEF4444)),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '3 pazarlık hakkın tükendi! Satıcı bu araç için tekliflere kapandı.',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Discrepancy Bargaining Leverage Card OR Bluff Mechanic
          if (_sellerResponse == null && widget.listing.isExpertiseCompleted) ...[
            Builder(
              builder: (context) {
                final disc = NegotiationEngine.detectExpertiseDiscrepancy(widget.listing.car);
                
                if (!disc.hasDiscrepancy) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: NeoBrutalCard(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: p.surfaceColor,
                      borderColor: Colors.black,
                      borderWidth: 2,
                      borderRadius: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.masks_rounded, color: Colors.purple, size: 20),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  'BLÖF FIRSATI: Satıcıyı Kandır',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Araçta sorun görünmüyor ama satıcıyı yalan söyleyerek manipüle edebilirsin. (Başarısız olursa teklifi reddedebilir!)',
                            style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 11),
                          ),
                          const SizedBox(height: 10),
                          NeoBrutalButton(
                            label: 'Blöf Yap (-%15 İndirim İste)',
                            icon: Icons.psychology_alt_rounded,
                            backgroundColor: Colors.purple,
                            textColor: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            fullWidth: true,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            onPressed: () {
                              final roll = Random().nextInt(100);
                              final bluffChance = game.skills.negotiationLevel * 5; // 5% to 50% success
                              
                              if (roll < bluffChance) {
                                final targetDiscPrice = (asking * 0.85).roundToDouble();
                                setState(() {
                                  _offeredPrice = targetDiscPrice;
                                  _isAccepted = true;
                                  switch (_customer.archetype) {
                                    case CustomerArchetype.skepticalOfficial:
                                      _sellerResponse = 'Gerçekten mi? Raporu o kadar dikkatli okumamıştım. Peki o zaman, ${CurrencyFormatter.formatShort(targetDiscPrice)} olsun.';
                                      break;
                                    case CustomerArchetype.impatientYouth:
                                      _sellerResponse = 'Öyle mi diyorsun? Uğraşamayacağım şimdi, al senin dediğin fiyat ${CurrencyFormatter.formatShort(targetDiscPrice)} olsun geç.';
                                      break;
                                    case CustomerArchetype.greedyFlipper:
                                      _sellerResponse = 'Vay be, gözümden kaçmış demek. Nakit vereceksen ${CurrencyFormatter.formatShort(targetDiscPrice)}\'a bırakıyorum, yoksa iptal.';
                                      break;
                                    case CustomerArchetype.familyMan:
                                      _sellerResponse = 'Yaa, öyle miymiş... Ben hiç fark etmedim. Neyse tamam, ${CurrencyFormatter.formatShort(targetDiscPrice)} olsun o zaman.';
                                      break;
                                  }
                                });
                              } else {
                                setState(() {
                                  _isAccepted = false;
                                  switch (_customer.archetype) {
                                    case CustomerArchetype.skepticalOfficial:
                                      _sellerResponse = 'Ben aracımın her şeyini bilirim, evraklarım tam! Kimi kandırıyorsun, seninle işim olmaz!';
                                      break;
                                    case CustomerArchetype.impatientYouth:
                                      _sellerResponse = 'Kardeşim sen beni kopardın mı sanıyorsun? Raporda her şey yazıyor, hadi işine!';
                                      break;
                                    case CustomerArchetype.greedyFlipper:
                                      _sellerResponse = 'Hoppala! Kimi yiyorsun sen? O raporu ben kendi ustama da gösterdim, uza buradan.';
                                      break;
                                    case CustomerArchetype.familyMan:
                                      _sellerResponse = 'Ayıptır, biz burada dürüstçe iş yapıyoruz. Ekspertiz raporu ortada, sana araç falan satmıyorum.';
                                      break;
                                  }
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

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
                              switch (_customer.archetype) {
                                case CustomerArchetype.skepticalOfficial:
                                  _sellerResponse = 'Haklısınız, bu detay gözümden kaçmış. Titiz biriyimdir ama hata benim, ${CurrencyFormatter.formatShort(targetDiscPrice)} fiyatı kabul ediyorum.';
                                  break;
                                case CustomerArchetype.impatientYouth:
                                  _sellerResponse = 'Tamam tamam, uzatma. Zaten acil satmam lazım, ${CurrencyFormatter.formatShort(targetDiscPrice)}\'a al git.';
                                  break;
                                case CustomerArchetype.greedyFlipper:
                                  _sellerResponse = 'Usta yakaladın beni, helal olsun... Neyse zararın neresinden dönsek kârdır, ${CurrencyFormatter.formatShort(targetDiscPrice)}\'a veriyorum!';
                                  break;
                                case CustomerArchetype.familyMan:
                                  _sellerResponse = 'Haklısınız, mahcup oldum şimdi... Size karşı dürüst olmak isterim, teklifiniz olan ${CurrencyFormatter.formatShort(targetDiscPrice)}\'a bırakıyorum.';
                                  break;
                              }
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
                    label: '${CurrencyFormatter.formatShort(_offeredPrice)} TEKLİF ET',
                    icon: Icons.handshake_rounded,
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onPressed: (_isProcessing || _isThinking || _isLockedOut)
                        ? null
                        : () async {
                            setState(() {
                              _isProcessing = true;
                              _isThinking = true;
                              _thinkingText = PsychologyEngine.getSuspenseNegotiationText();
                              _counterOfferCount++;
                            });

                            await Future.delayed(const Duration(milliseconds: 850));
                            if (!mounted) return;

                            final roll = Random().nextInt(100) + 1;
                            if (roll <= chancePercent) {
                              setState(() {
                                _isThinking = false;
                                _isProcessing = false;
                                _isAccepted = true;
                                _isNearMiss = false;
                                switch (_customer.archetype) {
                                  case CustomerArchetype.skepticalOfficial:
                                    _sellerResponse = 'Teklifiniz makul. Beyefendi/Hanımefendi gibi anlaştık. Hayırlı olsun.';
                                    break;
                                  case CustomerArchetype.impatientYouth:
                                    _sellerResponse = 'Süper, hızını sevdim! Ver elini, hayırlı olsun.';
                                    break;
                                  case CustomerArchetype.greedyFlipper:
                                    _sellerResponse = 'Tamam arkadaşım, nakit hazırsa hemen notere geçiyoruz. Dediğin fiyata veriyorum.';
                                    break;
                                  case CustomerArchetype.familyMan:
                                    _sellerResponse = 'Ortada buluştuk diyelim, aileye gidecek araba sonuçta. Hayırlı uğurlu olsun.';
                                    break;
                                }
                              });
                            } else {
                              final isNear = roll <= chancePercent + 15;
                              final isLocked = _counterOfferCount >= 3;
                              setState(() {
                                _isThinking = false;
                                _isProcessing = false;
                                _isAccepted = false;
                                _isNearMiss = isNear;
                                _isLockedOut = isLocked;
                                if (isLocked) {
                                  _sellerResponse = '3 kere pazarlık yaptık, anlaşamıyoruz. Daha fazla vaktimi harcama!';
                                } else {
                                  switch (_customer.archetype) {
                                    case CustomerArchetype.skepticalOfficial:
                                      _sellerResponse = 'Maalesef bu fiyat aracımın değerini yansıtmıyor. İyi günler dilerim.';
                                      break;
                                    case CustomerArchetype.impatientYouth:
                                      _sellerResponse = 'O fiyata bedava vereyim istersen? Yok kardeşim, kurtarmaz.';
                                      break;
                                    case CustomerArchetype.greedyFlipper:
                                      _sellerResponse = 'Bizi mi koparıyorsun ustam? O fiyata ölüsü bile verilmez, biraz daha yukarı çık.';
                                      break;
                                    case CustomerArchetype.familyMan:
                                      _sellerResponse = 'Kusura bakmayın, o fiyata verirsem aile bütçemiz çok sarsılır. Biraz daha yükseltmeniz lazım.';
                                      break;
                                  }
                                }
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
                    onPressed: (game.balance < _offeredPrice || _isProcessing)
                        ? null
                        : () {
                            setState(() => _isProcessing = true);
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
                                  builder: (ctx) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: NeoBrutalCard(
                                      backgroundColor: p.surfaceColor,
                                      borderColor: Colors.black,
                                      borderWidth: 3,
                                      borderRadius: 16,
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.warning_amber_rounded, color: p.errorColor, size: 32),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  outcome.title,
                                                  style: TextStyle(color: p.errorColor, fontWeight: FontWeight.w900, fontSize: 18),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            outcome.description,
                                            style: TextStyle(color: p.textPrimaryColor, fontSize: 14, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 24),
                                          NeoBrutalButton(
                                            label: 'Anladım',
                                            icon: Icons.check_circle_outline,
                                            backgroundColor: AppColors.brutalYellow,
                                            textColor: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            fullWidth: true,
                                            onPressed: () => Navigator.pop(ctx),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                NotificationService.showSuccess(context, 'Tebrikler! ${widget.listing.car.brand} ${widget.listing.car.modelName} ${CurrencyFormatter.formatShort(_offeredPrice)} fiyata satın alındı!');
                              }
                            }
                            if (mounted) {
                              setState(() => _isProcessing = false);
                            }
                          },
                  ),
                )
              else if (!_isLockedOut)
                Expanded(
                  child: NeoBrutalButton(
                    label: 'TEKLİFİ REVİZE ET (${3 - _counterOfferCount} Hak Kaldı)',
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
                        _isProcessing = false;
                        _isThinking = false;
                        _isNearMiss = false;
                      });
                    },
                  ),
                )
              else
                Expanded(
                  child: NeoBrutalButton(
                    label: 'MASADAN AYRIL',
                    icon: Icons.close_rounded,
                    backgroundColor: const Color(0xFFEF4444),
                    textColor: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
