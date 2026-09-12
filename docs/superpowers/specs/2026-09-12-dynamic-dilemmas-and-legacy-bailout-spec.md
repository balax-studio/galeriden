# Specification: Dynamic Dilemma Scaling & Contextual Story Expansion

- **Spec Identifier**: `SPEC-2026-09-12-DYNAMIC-DILEMMAS-AND-LEGACY-BAILOUT`
- **Status**: Draft (Awaiting User Review)
- **Author**: Antigravity & Senior Dev

---

## 1. Objective

Elevate the newly introduced contextual dilemma system by:
1. Transforming dilemma loans and grants from fixed, static numbers into **context-aware dynamic financial lifelines** (scaling with player level, cash deficit, and garage valuation).
2. Implementing the **Family Legacy & Heritage Vehicle** choice: Players in liquidity need can either accept dynamic cash or claim a vintage barn-find classic car into their garage.
3. Introducing **four new situational dilemma pools** to capture dynamic operational moments:
   - High Capital & Wealth (Balance > ₺500,000)
   - Damaged & Muddy Fleet (2+ damaged/unwashed cars in garage)
   - High Reputation & VIP Clients (Reputation >= 70)
   - Post-Sale Customer Dispute & Defect Claims (Players with sales history)

---

## 2. Tech Stack & Invariant Rules
- **Framework**: Flutter 3.x / Dart 3.x, Riverpod state management.
- **Rule 1: Zero Unicode Emojis**: Always use `VectorIconWidget` or native Flutter icons (`Icons.*`).
- **Rule 2: Zero Parentheses in UI Strings**: Use ` • ` or ` - ` for separators.
- **Rule 3: Simultaneous 7-Language Synchronization**: All keys in `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`.
- **Rule 4: File Changelog**: Log all modifications in `docs/FILE_CHANGELOG.md`.

---

## 3. Project Structure
```
lib/
├── data/models/
│   ├── dramatic_card_model.dart       # Dynamic outcome helpers & reward scaling
├── domain/usecases/
│   ├── contextual_dilemma_pool.dart   # Expanded situational pools & condition matching
│   └── dramatic_card_engine.dart      # Dynamic reward evaluation & vehicle rewards
├── core/localization/translations/    # 7-Language translation matrices
test/
└── dynamic_dilemma_expansion_test.dart # Unit tests validating dynamic scaling & pool selection
```

---

## 4. Architectural Design & Formulas

### 4.1 Dynamic Financial Lifeline Formula
Instead of static `₺25,000`, the grant or solidarity outcome scales dynamically:
```dart
double calculateDynamicGrant(DealershipModel state) {
  final levelMultiplier = state.level * 40000.0;
  final deficitCover = state.balance < 0 ? state.balance.abs() + 25000.0 : 0.0;
  return max(50000.0, levelMultiplier + deficitCover);
}
```

### 4.2 Heritage Classic Vehicle Injection
When the player picks "Köydeki Garajdan Yadigâr Klasik Aracı Getir":
```dart
CarModel generateHeirloomCar(int currentDay) {
  return CarModel(
    id: 'heirloom_classic_${DateTime.now().millisecondsSinceEpoch}',
    brand: 'Mercedes-Benz',
    modelName: '200D W123',
    modelYear: 1982,
    bodyType: 'Sedan',
    colorHex: '0xFF2E4053',
    baseMarketValue: 240000.0,
    currentPurchasePrice: 0.0, // Heritage inheritance: zero acquisition cost
    expertise: ExpertiseReport(
      engineCondition: 65.0,
      transmissionCondition: 70.0,
      tramerAmount: 0,
      mileage: 285000,
      isMileageTampered: false,
      bodyParts: const {},
    ),
    isHeroShowcase: true,
  );
}
```

### 4.3 New Situational Pools

#### A. High Capital & Wealth Pool (`state.balance >= 500000`)
- **Maliye ve Vergi Denetmeni**:
  - Choice 1: "Şeffaf Beyan Ver • Vergi Levhasını Parlat" (Pay ₺35,000 tax, gain +8 reputation and XP).
  - Choice 2: "Muhasebeciye Pasla • Masrafı Düş" (Risk audit penalty, save cash).
- **Gizli Koleksiyon Müzayedesi**:
  - Opportunity to acquire a mint luxury classic at a 30% discount.

#### B. Damaged & Muddy Fleet Pool (Damaged/unwashed cars >= 2)
- **Taksici Kooperatifi Toptan Alım**:
  - Cooperative manager offers to buy all damaged stock in one lump sum at 85% market value.
- **Çıkmacı İrfan Usta**:
  - Offers bulk salvaged parts repair for all damaged cars at half price.

#### C. High Reputation & VIP Clients Pool (`state.reputation >= 70`)
- **Ünlü Dizi Oyuncusu / Futbolcu Ziyareti**:
  - Choice 1: "VIP İndirimi Yap • Sosyal Medya Paylaşımı Al" (₺25,000 discount, gain +12 reputation and viral customer traffic).
  - Choice 2: "Fiyattan Taviz Verme • Net Kârı Al" (Sell at full price, 0 reputation).

#### D. Post-Sale Customer Dispute Pool (`salesHistory.isNotEmpty`)
- **Kapıya Dayanan Huysuz Alıcı**:
  - Choice 1: "Usta Masrafını Karşıla • Esnaf Şanını Koru" (Cover ₺4,500 repair, boost reputation).
  - Choice 2: "Noter Sözleşmesini Göster • Sorumluluk Kabul Etme" (Save money, lose 3 reputation).

---

## 5. Success Criteria
1. When balance is negative, dilemma grant choices provide sufficient funds (`>= ₺50,000` up to `₺300,000+`) to recover from debt.
2. The legacy vehicle choice successfully injects an authentic classic car with ₺0 purchase price directly into the player's garage.
3. Situational pools trigger accurately when conditions (High Capital, Damaged Fleet, High Reputation, Sales Dispute) are met.
4. All text is 100% localized in all 7 languages without emojis or parentheses.
5. All automated unit tests pass and `flutter analyze` reports 0 warnings.
