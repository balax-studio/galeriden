# Spec: Yan İşletmeler İnşaat, Ruhsat ve Hızlandırma Sistemi (Side Business Construction & Rush Spec)

## 1. Objective
Galeriden Tycoon içerisindeki yan işletmelere (oto yıkama, ekspertiz, çekici filosu, kiralama vb.) satın alındıklarında anında aktifleşmek yerine işletme büyüklüğüne göre kademeli bir **İnşaat ve Ruhsat Süreci (Construction Period)** kazandırmak. Oyuncular gün atlayarak inşaatı doğal olarak tamamlayabileceği gibi, **Ekspres Müteahhit & Ruhsat Desteği** ile AdMob ödüllü reklam izleyerek inşaat süresini anında sıfırlayıp tesisi işletmeye alabilirler.

## 2. Tech Stack & Environment
- **Framework**: Flutter 3.x / Dart 3.x
- **State Management**: Riverpod (`gameProvider`, `game_market_mixin.dart`, `game_time_mixin.dart`)
- **Monetization**: Google Mobile Ads (`AdService.instance.showRewardedAdWithFallback`)
- **Localization**: 7 Simultaneous Languages (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`)
- **Design System**: Neo-Brutalism (Zero Unicode Emojis, Zero Parentheses, 3.5px black borders, tactile hazard stripes, hard drop shadows)

## 3. Invariant Rules & Boundaries
- **Always**:
  - Zero Unicode Emojis: Use `VectorIconWidget` or native Flutter icons.
  - Zero Parentheses: Use ` • ` or ` - ` for formatting.
  - 7-Language Synchronization: Localize every new string across all 7 languages.
  - Ownership & Construction Gating: Unfinished businesses must not generate income or unlock facilities (`isOwned && !isUnderConstruction`).
- **Never**:
  - Never allow income generation during construction.
  - Never force unskippable blocking ads; construction rush is strictly optional and rewarded.
  - Never run unprompted `git push`.

## 4. Construction Duration Matrix

| İşletme Türü (SideBusinessType) | İnşaat Süresi (Oyun Günü) | Hızlandırma Seçeneği | Gerekçe |
|---|---|---|---|
| `vendingMachine` (Otomat & Kahve) | 0 Gün (Anında) | Gerek Yok | Küçük cihaz kurulumu |
| `billboard` (Dijital Reklam) | 1 Gün | Reklam / Gün Atlama | Tabela montajı |
| `autoShop` (Hızlı Bakım) | 2 Gün | Reklam / Gün Atlama | Lift ve alet kurulumu |
| `carWash` (Oto Yıkama & Detailing) | 2 Gün | Reklam / Gün Atlama | Basınç hattı ve su deposu |
| `towTruck` (Çekici & Kurtarma) | 3 Gün | Reklam / Gün Atlama | Çekici tescil ve kasko |
| `evCharging` (Elektrikli Şarj) | 4 Gün | Reklam / Gün Atlama | Yüksek voltaj trafo onayı |
| `inspectionStation` (Muayene İst.) | 4 Gün | Reklam / Gün Atlama | Kalibrasyon ve resmi izin |
| `corporateExpertise` (Kurumsal Eksp.) | 5 Gün | Reklam / Gün Atlama | Dyno montajı ve kurumsal ruhsat |
| `carRental` (Rent a Car) | 5 Gün | Reklam / Gün Atlama | Filo kasko ve acente ruhsatı |
| `sparePartsStore` (Yedek Parça) | 3 Gün | Reklam / Gün Atlama | Raf ve stok lojistiği |
| `wrapStudio` (Kaplama Stüdyosu) | 3 Gün | Reklam / Gün Atlama | Tozsuz fırın ve aydınlatma |

## 5. Architecture & Data Contracts

### 5.1 Data Model (`SideBusinessModel`)
```dart
class SideBusinessModel {
  // Existing fields...
  final bool isUnderConstruction;
  final int constructionDaysRemaining;
  final int totalConstructionDays;

  // Helper getters
  bool get isOperational => isOwned && !isUnderConstruction;
  double get constructionProgress => totalConstructionDays > 0
      ? (1.0 - (constructionDaysRemaining / totalConstructionDays)).clamp(0.0, 1.0)
      : 1.0;
}
```

### 5.2 Domain Engine (`SideBusinessEngine`)
- `processDailyEarnings`: Sadece `b.isOperational` olan işletmeler gelir/gider üretir.
- Gün atlama (`_processSideBusinesses` in `game_time_mixin.dart`):
  - `isUnderConstruction && constructionDaysRemaining > 0`: `constructionDaysRemaining - 1`.
  - `constructionDaysRemaining <= 0`: `isUnderConstruction: false`.

### 5.3 Notifier Actions (`GameMarketMixin`)
- `buySideBusiness(businessId)`: Türüne göre `totalConstructionDays` hesaplar ve başlatır.
- `rushSideBusinessConstruction(businessId)`: AdMob rewarded ad çağırır; başarı durumunda `isUnderConstruction: false`, `constructionDaysRemaining: 0` yapar.

## 6. UI / UX Design Specifications
- **Şantiye Durum Rozeti**: Sarı-siyah endüstriyel tehlike şeritleri `[ İNŞAAT HALİNDE • RUHSAT SÜRECİ ]`.
- **İlerleme Sayacı**: `Kalan Süre: X Gün` ve dolum çubuğu.
- **Hızlandırma Butonu**: Taktil Neo-Brutalist sarı buton `[ MÜTEAHHİT DESTEĞİ • ANINDA AÇ ]` (Video ikonu ile).
- **Açılış Kutlaması**: İnşaat bittiğinde veya hızlandırıldığında haptik titreşim ve başarı bildirimi.

## 7. Testing Strategy
- Unit test: `test/side_business_construction_test.dart`
  - Satın alma sonrası inşaat gününün doğruluğu
  - Gün atlama sırasında geri sayımın çalışması
  - İnşaat devam ederken gelir üretilmemesi
  - Reklamlı hızlandırma ile anında açılışın gerçekleşmesi
- `flutter analyze` 0 hata doğrulaması.
