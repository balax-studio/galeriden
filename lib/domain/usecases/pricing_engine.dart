import '../../data/models/dealership_model.dart';

class PricingEngine {
  /// Unifies buyer acquisition perks (pazarlık becerisi, tüccar torunu, pazar kurdu)
  /// for both regular market purchases and notary registered purchases (C2).
  static double applyBuyerPerks({
    required double basePrice,
    required double negotiationMultiplier,
    required CharacterOrigin characterOrigin,
    required SpecializationPath specializationPath,
  }) {
    double price = basePrice;

    // Skill Perk: Pazarlık Gücü - negotiationMultiplier (up to 18% discount)
    if (negotiationMultiplier > 0) {
      price *= (1.0 - negotiationMultiplier);
    }

    // Origin Perk: Tüccar Torunu -%8 alım indirimi
    if (characterOrigin == CharacterOrigin.tuccarTorunu) {
      price *= 0.92;
    }

    // Specialization Perk: Pazar Kurdu (Trader) -%10 alım indirimi
    if (specializationPath == SpecializationPath.trader) {
      price *= 0.90;
    }

    return price.roundToDouble();
  }
}
