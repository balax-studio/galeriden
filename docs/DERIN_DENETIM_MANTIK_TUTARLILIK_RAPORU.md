# Galerisinden — Derin Denetim: Mantık Hataları, Tutarsızlıklar ve Yüzeysel Sistemler

**Tarih:** 6 Eylül 2026 · **Commit:** `b1441bf` · **Kapsam:** Sadece rapor, hiçbir dosya değiştirilmedi.
**Doğrulama durumu:** `flutter analyze` → temiz. `flutter test` → **845 test, hepsi geçiyor.**

> Bu raporun ana bulgusu şudur: **oyunun kodu çalışıyor, testleri geçiyor, ama oyuncuya gösterdiği sayılar ile arka planda işlettiği sayılar birbirini tutmuyor.** Test paketi kodun "ne yaptığını" doğruluyor; "ekranda yazanla aynı şeyi yapıp yapmadığını" doğrulamıyor. Aşağıdaki bulguların büyük kısmı bu boşluktan çıkıyor.

Bulgular üç grupta: **(A) Sömürülebilir mantık hataları**, **(B) Ekranda yazan ≠ gerçekte olan**, **(C) Yüzeysel kalmış sistemler.** Her bulguda `dosya:satır`, neden yanlış olduğu ve **devralan ajan için somut düzeltme talimatı** var.

---

# A · SÖMÜRÜLEBİLİR MANTIK HATALARI

## A1 · TÜFE Kira Zammı butonu sınırsız — sonsuz kira sömürüsü ⭐ EN KRİTİK

**Dosyalar:** [game_real_estate_mixin.dart:663](lib/presentation/providers/game/game_real_estate_mixin.dart:663), [real_estate_rental_screen.dart:902](lib/presentation/screens/real_estate/real_estate_rental_screen.dart:902)

```dart
onPressed: () => _applyTufeIncrease(prop),          // hiçbir koşul yok
bool applyRentIndexIncrease(String id, {double rate = 0.25}) { ... }  // gün/cooldown kontrolü yok
```

Butonun etiketi `'rental_btn_apply_tufe': 'YILLIK TÜFE KİRA ZAMMI UYGULA'` — yani **yıllık**. Ama fonksiyonda ne `leaseStartDay` kontrolü, ne `currentDay` kaydı, ne cooldown, ne de kiracı tepkisi var. Buton hiçbir koşulda devre dışı bırakılmıyor.

**Sonuç:** Oyuncu butona 30 kez basarsa kira `1.25^30 ≈ 807 kat` artar. Üstelik her basışta 50 XP veriliyor. Tek bir dairenin geliri dakikalar içinde tüm oyun ekonomisini anlamsızlaştırır. Bu, `AGENTS.md` Invariant #4'ün ("spam butonları anında devre dışı bırak") doğrudan ihlali.

**Düzeltme:**
1. `TenantModel`'e `lastRentIncreaseDay` alanı ekle (varsayılan `0`), `toJson`/`fromJson`/`copyWith` senkron.
2. `applyRentIndexIncrease` içinde: `if (state.currentDay - tenant.lastRentIncreaseDay < 365) return false;` — sözleşme yıllık olduğu için 365 in-game gün. Başarılıysa `lastRentIncreaseDay: state.currentDay` yaz.
3. Kiracı tepkisi ekle: zam sonrası `evictionRiskScore` `+15` artsın ve `%20` ihtimalle kiracı sözleşmeyi feshetsin — aksi halde zam bedelsiz kalır, karar olmaktan çıkar.
4. UI'da `onPressed: canApplyTufe ? ... : null` yap, kalan gün sayısını göster; `rental_btn_tufe_locked` anahtarını **7 dilde** ekle.
5. XP'yi `50` → `10`'a düşür (yılda bir yapılan işlem için 50 XP dengesizdir).

## A2 · Uygulamayı 2 dakika arka plana atmak, ~10 in-game günlük personel işini bedava yapıyor ⭐

**Dosyalar:** [offline_progression.dart:142-168](lib/domain/usecases/offline_progression.dart:142), [daily_staff_processor.dart:187-226](lib/domain/services/daily_staff_processor.dart:187)

İki yol tamamen farklı davranıyor:

| | **Aktif oyun** `processStaffAutomation` | **Offline** `processOfflineTime` |
|---|---|---|
| Yıkamacı kontrolü | `s.isAvailableForWork && role == washer` | sadece `s.role == washer` — **enerji/izin/eğitim yok sayılıyor** |
| Yıkanan araç | **günde max 2** (oto yıkama varsa 5) | **tüm garaj, sınırsız** |
| Usta tamiri | **günde 1 araç, +20 puan** | **tüm araçlar, doğrudan 85'e** |
| Tetiklenme eşiği | 1 in-game gün = 120 sn | **elapsedMinutes ≥ 2** |

`offline_progression.dart:38`'deki `if (elapsedMinutes < 2) return ...` erken çıkışından sonra personel blokları `simulatedDays`'ten (30 dk = 1 gün) **bağımsız** çalışıyor. Yani **2 gerçek dakika** arka planda kalmak yeterli.

**Sonuç:** Bir usta tut → uygulamayı 2 dk arka plana at → geri dön → tüm garaj 85 kondisyona çıkmış. Tamirhane ekonomisi (parça, işçilik, süre) tamamen atlanıyor. Oyunun optimal stratejisi "oynamamak" haline geliyor — retention tasarımının tam tersi.

**Düzeltme:**
1. `offline_progression.dart:142-143` → `isAvailableForWork` kontrolünü ekle (aktif yolla aynı).
2. Personel bloklarını `simulatedDays` döngüsünün **içine** taşı ve aktif yolla aynı limitleri uygula: gün başına max 2 yıkama, gün başına 1 araç `+20` tamir.
3. `simulatedDays == 0` iken hiçbir personel aksiyonu çalışmasın.
4. Aktif yol `isDetailedCleaned: true` de set ediyor, offline yol etmiyor → aynı yıkama iki farklı değer bonusu üretiyor (`+%8` vs `+%4`). İkisini eşitle.

## A3 · Offline'da geçen günlerde kredi taksiti, vergi, kira ve senet hiç işlemiyor ⭐

**Dosyalar:** [offline_progression.dart:100-114](lib/domain/usecases/offline_progression.dart:100), [loan_settlement_engine.dart:17](lib/domain/usecases/loan_settlement_engine.dart:17), [game_time_mixin.dart:85-230](lib/presentation/providers/game/game_time_mixin.dart:85)

`advanceGameDay()` yaklaşık **30 alt sistem** işletiyor. Offline gün ilerlemesi ise `currentDay`'i artırıyor ama yalnızca üç şey uyguluyor: yan iş geliri, mülk gideri, personel maaşı.

Atlanan sistemler: **kredi taksitleri, günlük vergi, araç kiralama geliri, vadeli satış taksitleri, çekler, gayrimenkul kirası, konsinye otopark ücreti, görev/sözleşme süreleri, hisse temettüleri, karaborsa baskını, vandalizm.**

Kredi tarafı doğrudan sömürülebilir çünkü ödeme **güne bağlı**:
```dart
// loan_settlement_engine.dart:17
if (nextDay % 7 != 0 || loans.isEmpty) return (balance, loans);
```

**Sonuç:** Oyuncu 6. günde uygulamayı kapatır, 90 dk sonra döner → `currentDay` 9 olur, **7. gün hiç yaşanmadığı için taksit hiç kesilmez.** Tekrarlanabilir: büyük kredi çek, 7'nin katlarına yaklaşınca uygulamayı arka plana at. Kredi bedava para haline gelir.

**Düzeltme (tercih sırasına göre):**
- **A (önerilen):** Offline ilerlemeyi kendi simülasyonuyla değil, `advanceGameDay()`'i `simulatedDays` kez çağırarak yap. Bunun için `advanceGameDay`'e `{bool isOfflineCatchUp = false}` parametresi ekle; offline modda UI tetikleyen kısımları (dramatic card, random event, story ad, `triggerOrganicOffers`) atla, ekonomik işlemleri aynen çalıştır. Tek doğruluk kaynağı olur, gelecekteki sapmalar biter.
- **B (asgari):** `processOfflineTime` içindeki gün döngüsüne en az `LoanSettlementEngine.processWeeklyLoans`, `calculateDailyTax`, `processInstallments`, `processCheques` çağrılarını ekle.

Hangisi seçilirse seçilsin şu regresyon testi yazılmalı: *"6. günde offline'a git, 3 gün ilerlet, kredi taksitinin kesildiğini doğrula."*

## A4 · Ödüllü reklam ödülü `expressDetailing` tüm garajın değerini kalıcı %15 şişiriyor

**Dosya:** [game_time_mixin.dart:1637-1651](lib/presentation/providers/game/game_time_mixin.dart:1637)

```dart
case StoryAdRewardType.expressDetailing:
  for (int i = 0; i < updatedCars.length; i++) {
    updatedCars[i] = c.copyWith(
      ...,
      baseMarketValue: (c.baseMarketValue * 1.15).roundToDouble(),  // KALICI
    );
  }
```

`baseMarketValue` aracın **içsel/kalıcı** değeri — yıkama/cila gibi geçici bonuslar zaten `estimatedRealValue` içinde ayrıca hesaplanıyor. Burada temel değerin kendisi kalıcı olarak artırılıyor.

`selectNextStoryCard()` tüm kartlar görüldüğünde `seenStoryCardIds`'i sıfırlayıp döngüyü yeniden başlatıyor ([game_time_mixin.dart:1554](lib/presentation/providers/game/game_time_mixin.dart:1554)). Yani bu ödül **tekrar tekrar alınabilir ve bileşik çalışır**: 10 kez → `1.15^10 = 4.05×` garaj değeri.

**Düzeltme:** `baseMarketValue` satırını kaldır. Geçici temizlik bayraklarını (`isWashed`, `isPolished`, `isDetailedCleaned`) set etmekle yetin — `estimatedRealValue` bunlara zaten `+%8` veriyor. Kalıcı artış isteniyorsa araç başına **bir kez** uygulanacak bir `hasExpressDetailBonus` bayrağı ekle.

## A5 · Şube merdivenini adım adım çıkmak %50 daha pahalı — "doğru oynayan" cezalandırılıyor

**Dosya:** [game_inventory_mixin.dart:567-644](lib/presentation/providers/game/game_inventory_mixin.dart:567)

`upgradeBranch` kümülatif: `targetLevel >= 2`, `>= 3`, `>= 4` … hepsi ayrı `if`. Yani **doğrudan branch_4 alan, 2 ve 3'ün tüm tier bayraklarını ve rotalarını da alıyor.**

| Yol | Toplam maliyet | Elde edilen |
|---|---:|---|
| branch_2 → branch_3 → branch_4 sırayla | **₺1.350.000** | tier_2,3,4 + 8 slot |
| doğrudan branch_4 | **₺900.000** | tier_2,3,4 + 8 slot |

Sıradan oynayan oyuncu **₺450.000 fazladan ödüyor, karşılığında hiçbir şey almıyor.** Level 8'e kadar toplam fark ₺23.850.000.

**Ek olarak:** `maxGarageSlots: branch.maxGarageSlots` **mutlak atama**. Oyuncu başka bir yoldan slot genişletmişse (ör. 12 slot), sonra branch_4 (8 slot) alırsa **kapasitesi 12'den 8'e düşer.** Araçlar silinmez ama `buyCar` kilitlenir ve oyuncu sebebini anlamaz.

**Düzeltme:**
1. Ya merdiveni zorunlu kıl: `if (state.currentBranchTier != branch.targetLevel - 1) return false;` ve UI'da sadece bir sonraki şubeyi satın alınabilir göster.
2. Ya da fiyatı farksal yap: `cost = branch.requiredBalance - (bir önceki tier'ın requiredBalance'ı)`.
3. Slot atamasını koruyucu yap: `maxGarageSlots: max(state.maxGarageSlots, branch.maxGarageSlots)`.

## A6 · Rastgele olay seçiminde bakiye kontrolü yok

**Dosya:** [game_time_mixin.dart:1526-1539](lib/presentation/providers/game/game_time_mixin.dart:1526)

```dart
void resolveRandomEvent(GameEventChoice choice) {
  final newBalance = state.balance + choice.balanceChange;   // negatife düşebilir
```

`event_black_market_raid` seçenekleri `-25.000`, `-60.000`, `-150.000`. Bakiyesi ₺0 olan oyuncu da bunları seçebilir ve eksiye düşer. Diğer tüm satın alma fonksiyonları (`buyCar`, `upgradeBranch`, `purchaseRealEstate`) bakiye kontrolü yapıyor — burada tutarsızlık var.

**Düzeltme:** Karşılanamayan seçenekleri `NeoBrutalRandomEventDialog` içinde devre dışı bırak ve `resolveRandomEvent` başına guard koy: `if (choice.balanceChange < 0 && state.balance < choice.balanceChange.abs()) return;`. Hiçbir seçenek karşılanamıyorsa bir "borçlan" varyantı sun.

---

# B · EKRANDA YAZAN ≠ GERÇEKTE OLAN

## B1 · `profitMultiplier` tamamen sahte — ₺30M'lik şube 2.5× kâr vaat ediyor, hiçbir şey yapmıyor ⭐

**Dosyalar:** [branch_model.dart:12](lib/data/models/branch_model.dart:12), [branch_screen.dart:302](lib/presentation/screens/branch/branch_screen.dart:302), `tr_translations.dart:405`

```dart
'branch_item_profit_mult': 'Kâr Çarpanı: x{mult}',   // ekranda: "Kâr Çarpanı: x2.5"
```

Tüm kod tabanında `profitMultiplier` **yalnızca 2 yerde** geçiyor: model tanımı ve şube ekranındaki metin. **Hiçbir satış, teklif, fiyat veya gelir hesabı bu değeri okumuyor.**

Oyuncu ₺30.000.000 ödeyip "kârım 2,5 katına çıkacak" diye bekliyor; kârı hiç değişmiyor. Oyundaki en pahalı satın alma kararı tamamen yalan bir gerekçeye dayanıyor.

**Düzeltme (biri seçilmeli):**
- **Uygula:** `game_market_mixin`'deki satış kâr hesabına ve `NegotiationEngine.generateBuyerOffer` teklif üretimine `currentBranchTier`'dan türetilen çarpanı ekle. `DealershipModel`'e getter yaz ve tek noktadan kullan:
  ```dart
  double get branchProfitMultiplier => BranchModel.getAllBranches()
      .firstWhere((b) => b.targetLevel == currentBranchTier).profitMultiplier;
  ```
- **Ya da kaldır:** Alanı ve `branch_item_profit_mult` anahtarını 7 dilden sil, yerine gerçekten çalışan bir faydayı göster (slot sayısı, açılan rotalar).

Karar verilmeden yayına çıkmamalı — oyuncu ikinci şubeden sonra fark ediyor.

## B2 · Tapu satın almak gideri sıfırlamıyor, tam tersine **artırıyor** ⭐

**Dosyalar:** [game_time_mixin.dart:394-398](lib/presentation/providers/game/game_time_mixin.dart:394), [branch_model.dart:53](lib/data/models/branch_model.dart:53), `tr_translations.dart:409-410`

Ekrandaki vaat:
```
'branch_deed_buy_desc':   'Tapuyu satın alarak günlük kira giderini sıfırlayın.'
'branch_deed_owned_desc': 'Bu şubenin mülkiyeti size ait. Günlük kira gideri ödemezsiniz.'
```

Model tarafı da bunu destekliyor: `dailyBurnRate: ownedDeeds.contains('branch_1') ? 0.0 : 300.0` → şube kartında **₺0/gün** yazıyor.

Gerçek gider ise tamamen ayrı hesaplanıyor:
```dart
double burn = 300.0;
if (unlockedBuildings.contains('property_tier_8')) burn = 75000.0; ...   // tapudan bağımsız
final deedCount = state.ownedBranchDeeds.length;
if (deedCount > 0) burn += deedCount * 1250.0;                          // tapu başına +1250 EKLİYOR
```

**Sonuç:** Oyuncu ₺150.000.000'a tapu alıyor, ekranda "₺0/gün" görüyor, gerçekte günlük gideri **₺1.250 artıyor.** Vaadin tam tersi yön.

**Düzeltme:** `_processDailyPropertyBurn` tapuyu dikkate alsın:
```dart
final ownedDeedTiers = state.ownedBranchDeeds
    .map((id) => int.tryParse(id.replaceAll('branch_', '')) ?? 0);
if (ownedDeedTiers.contains(state.currentBranchTier)) {
  burn = 0.0;                                        // aktif şubenin tapusu varsa kira yok
}
burn += state.ownedBranchDeeds.length * 1250.0;      // aidat kalabilir ama EKRANDA gösterilmeli
```
Ve `branch_deed_owned_desc` metnini "Kira ödemezsiniz, yalnızca ₺1.250/gün aidat ödersiniz." olarak 7 dilde güncelle. Aidat gösterilmezse ikinci bir yalan oluşur.

## B3 · Günlük Nakit Akışı ekranı neredeyse her satırda yanlış ⭐

**Dosya:** [cashflow_engine.dart](lib/domain/usecases/cashflow_engine.dart) — tüm dosya · Ekran: [daily_cashflow_screen.dart:118](lib/presentation/screens/finance/daily_cashflow_screen.dart:118)

Bu ekranın tek amacı oyuncuya günlük kâr/zararını doğru söylemek. Gerçek `advanceGameDay()` ile karşılaştırma:

| Kalem | Ekranda | Gerçekte | Sapma |
|---|---|---|---|
| **Vergi** | `game.dailyTaxRate` = **sabit ₺150** | `calculateDailyTax(level, likit)` = 250–5.000 **+ likit varlığın %0,1'i** | ₺50M likit oyuncuda **₺150 vs ₺51.500 → 343×** |
| **Kredi** | `sum(monthlyPayment)` her gün | `nextDay % 7 == 0` → **7 günde bir** | **7× fazla gösteriliyor** |
| **Yan iş geliri** | `effectiveDailyIncome` (ham) | `effectiveIncomeWithUtilization` (çarpan **0,05–1,60**) | Atıl galeride **20× fazla** |
| **Mülk gideri** | sadece tier tablosu | tier + `tapu × ₺1.250` | eksik |
| **Personel** | `sum(dailySalary)` | `salaryMultiplier`, moral, istifa dahil | eksik |
| **Gayrimenkul kirası** | **yok** | `pendingRentIncome` günlük birikiyor | tamamen eksik |
| **Konsinye otopark, taksit, çek, araç bakımı, ilan amortismanı** | **yok** | hepsi işliyor | tamamen eksik |

`dailyTaxRate` alanı kod tabanında **hiçbir yerde atanmıyor** — sadece `dealership_model.dart` `1139`, `1526`, `1822` satırlarında `150.0` varsayılanıyla doğuyor. `game_finance_mixin.dart:211`'deki `shortTermTax = dailyTaxRate * 30` ile 30 günlük projeksiyon aynı yanlışı 30 katına çıkarıyor.

Ayrıca `finance_substate.dart:37`'de **aynı isimli üçüncü bir alan** var: `dailyTaxRate = 0.02` — bu sefer *oran* anlamında. İsim çakışması ileride sessiz hata üretir.

**Düzeltme:**
1. `DealershipModel.dailyTaxRate` alanını **sil.** Yerine hesaplanan getter koy:
   ```dart
   double get effectiveDailyTax => LoanSettlementEngine.calculateDailyTax(
       level, totalLiquidWealth: balance + bankDepositBalance);
   ```
   `cashflow_engine:114`, `finance_screen:708`, `game_finance_mixin:211` bunu kullansın.
2. `loanDailyPayment`'ı `sum(monthlyPayment) / 7.0` yap; etiketi `'Kredi • haftalık taksitin günlük karşılığı'` olarak 7 dilde güncelle.
3. Yan iş gelirini `effectiveIncomeWithUtilization(...)` ile hesapla — `game_time_mixin:565-575`'teki aynı parametreleri geçir.
4. `propertyDailyBurn`'e `game.ownedBranchDeeds.length * 1250.0` ekle.
5. `CashflowSummary`'ye `realEstateRentIncome`, `consignmentParkingFee`, `vehicleMaintenanceCost` alanları ekle ve ekranda göster.
6. `finance_substate.dart:37`'deki alanı `taxRatePercent` olarak yeniden adlandır.
7. **Regresyon testi:** `CashflowEngine.calculate(state).netDailyCashflow` ile `advanceGameDay()` sonrası gerçek bakiye değişiminin ±%5 içinde olduğunu doğrulayan test yaz. Bu test yoksa sapma zamanla tekrar oluşur.

## B4 · Pazarlık becerisi Vasıta pazarında hiç çalışmıyor, İkinci El pazarında ise gizli çalışıyor

**Dosyalar:** [game_inventory_mixin.dart:99-127](lib/presentation/providers/game/game_inventory_mixin.dart:99) vs [game_inventory_mixin.dart:166-175](lib/presentation/providers/game/game_inventory_mixin.dart:166)

`buyCar` üç indirimi uyguluyor:
```dart
finalPurchasePrice *= (1.0 - state.skills.negotiationMultiplier);   // %20'ye kadar
if (characterOrigin == tuccarTorunu) finalPurchasePrice *= 0.92;    // -%8
if (specializationPath == trader)   finalPurchasePrice *= 0.90;     // -%10
```
`buyCarWithNoter` **hiçbirini uygulamıyor** — `agreedPrice` aynen ödeniyor.

| Ekran | Çağrı | Perkler |
|---|---|---|
| `/marketplace` pazarlık ([negotiation_screen.dart:267](lib/presentation/screens/marketplace/negotiation_screen.dart:267)) | `buyCar` | **uygulanıyor** |
| `/vasita` pazarlık ([vasita_market_provider.dart:92](lib/presentation/providers/vasita_market_provider.dart:92)) | `buyCarWithNoter` | **uygulanmıyor** |

İki ayrı sorun:

1. **Vasıta'da:** Oyuncu "Pazarlık Gücü"ne 10 seviye yatırım yapar, karakter kökenini "Tüccar Torunu", uzmanlığını "Pazar Kurdu" seçer — Vasıta pazarında **hiçbiri işe yaramaz.** `character_growth_screen.dart:234` ekranda "%20 indirim" yazmaya devam eder.
2. **Marketplace'te:** Oyuncu ekranda "₺240.000'e anlaştım" görür, butona basar, bakiyesinden **₺163.000** düşer. Gösterilen fiyat ≠ ödenen fiyat.

**Düzeltme:** İndirim mantığını tek yere taşı (ör. `PricingEngine.applyBuyerPerks(price, state)`); `buyCarWithNoter` de bunu çağırsın. **Önemli:** pazarlık ekranları anlaşılan fiyatı gösterirken indirimi **görünür** kılmalı — ör. `Anlaşılan ₺240.000 · Pazarlık Gücü −₺48.000 · Ödenecek ₺192.000`. Aksi halde perk düzeltmesi ikinci sorunu çözmez.

## B5 · Efsane araç ödülü hâlâ çökme riski taşıyor ve marka evrenine aykırı

**Dosya:** [dramatic_card_engine.dart:148-170](lib/domain/usecases/dramatic_card_engine.dart:148)

Önceki raporda bildirilen bulgu **düzeltilmemiş:**
```dart
brand: 'Volk',            // GameConstants.carBrands içinde yok — oyunun karşılığı 'Vosgen'
colorHex: 'D90429',       // ne '#' ne '0x' öneki var
```

`marketplace_screen.dart:419` çözümlemesi try/catch'siz:
```dart
final carColor = Color(int.parse(car.colorHex.replaceFirst('#', '0xFF')));
```
`'D90429'` için `replaceFirst` hiçbir şey değiştirmez → `int.parse('D90429')` → **FormatException.**

Ayrıca kod tabanında **üç farklı hex çözümleyici** var, üçü farklı formatı tolere ediyor:

| Konum | Kabul ettiği | Reddettiği |
|---|---|---|
| `listing_detail_screen.dart:39` (try/catch var) | `#RRGGBB`, `0xFFRRGGBB` | `RRGGBB` → fallback |
| `marketplace_screen.dart:419` (**korumasız**) | `#RRGGBB`, `0xFFRRGGBB` | `RRGGBB` → **çökme** |
| `car_wash_canvas.dart:303` (try/catch var) | `#RRGGBB`, `RRGGBB` | `0xFFRRGGBB` → **sarıya düşüyor** |

Yani `0xFF...` formatlı araçlar oto yıkama ekranında **yanlış renkte** görünüyor — bu ayrı bir görsel hata.

**Düzeltme:**
1. `lib/core/utils/color_parser.dart` oluştur: tek `Color parseCarColor(String hex)`, `#`/`0x`/çıplak üç formatı da normalize etsin, hatada tema rengine düşsün.
2. Üç çağrı yerini de buna çevir; `marketplace_screen.dart:419` korumasız olduğu için öncelikli.
3. `dramatic_card_engine.dart:154` → `colorHex: '#D90429'`; `brand: 'Volk'` → `'Vosgen'`, model adını `GameConstants.carBrands` içindeki gerçek bir modelle eşleştir.
4. `CarModel` constructor'ına debug assert ekle: `assert(colorHex.startsWith('#') || colorHex.startsWith('0x'))`.

## B6 · Teklifler gerçek dakikayla, oyun ise in-game günle çalışıyor

**Dosyalar:** [negotiation_engine.dart:644](lib/domain/usecases/negotiation_engine.dart:644), [offer_model.dart:45](lib/data/models/offer_model.dart:45), [game_time_mixin.dart:54](lib/presentation/providers/game/game_time_mixin.dart:54)

Oyunda **beş ayrı zaman birimi** aynı anda kullanılıyor:

| Sistem | Birim | Dosya |
|---|---|---|
| Oyun günü | **120 gerçek saniye** | `game_time_mixin.dart:54` |
| Teklif ömrü | **3–8 gerçek dakika** | `negotiation_engine.dart:644` |
| Hurdalık "günlük" işi | **20 gerçek saat** | `game_scrapyard_mixin.dart:440` |
| Giriş serisi | **gerçek takvim günü** | `game_core_provider.dart:97` |
| Offline ilerleme | **30 gerçek dakika = 1 gün** | `offline_progression.dart:63` |

Sonuçlar:
- Bir teklif ortalama **2,75 in-game gün** yaşıyor ama oyuncuya gün cinsinden süre gösterilmiyor.
- Oyuncu 10 dakika telefonu bırakırsa tüm teklifler kaybolur; ekranda hiçbir gün geçmemiş gibi görünür, sebep anlaşılmaz.
- "Günlük" hurdalık işi pratikte **600 in-game günde bir** yapılabiliyor.
- Aktif oyunda 1 saat = 30 in-game gün; offline 1 saat = 2 gün. Aynı gerçek süre **15× farklı** ilerleme üretiyor.

**Düzeltme:**
1. `OfferModel`'de `expiresAt` (DateTime) yerine `expiresOnDay` (int); `isExpired` → `currentDay > expiresOnDay`. Teklif ömrü 2–4 **in-game gün** olsun.
2. `doDailyScrapyardSideGig`'i `lastScrapyardGigDate` (DateTime) yerine `lastScrapyardGigDay` (int) ile gate'le — 1 in-game gün.
3. Giriş serisi gerçek takvim günü kalabilir (retention mekaniği), ama UI'da açıkça "gerçek gün" olarak etiketlensin.
4. Bu değişiklik save şemasını etkiler → `DealershipModel.fromJson` içinde eski `expiresAt` alanını okuyup `currentDay + 2`'ye çeviren migration ekle.

## B7 · Yazım hatası hâlâ ekranda

**Dosya:** [mission_factory.dart:460](lib/domain/usecases/mission_factory.dart:460)
```dart
{'name': 'Doktor Selim Bey', 'archetype': 'Pretij & Konfor', ...}   // → 'Prestij & Konfor'
```
VIP sözleşme kartında görünüyor. (Önceki rapordaki "Vitlindeki" hataları düzeltilmiş.)

---

# C · YÜZEYSEL KALMIŞ SİSTEMLER

## C1 · Hava durumu sistemi tamamen dekoratif — "CANLI ETKİ" rozeti yalan söylüyor ⭐

**Dosyalar:** [weather_engine.dart:21](lib/domain/usecases/weather_engine.dart:21), [game_hud_widget.dart:685-830](lib/presentation/widgets/game_hud_widget.dart:685)

`WeatherEngine.getVehicleDemandMultiplier()` **hiçbir yerden çağrılmıyor.** `suvDemandMultiplier` ve `sportDemandMultiplier` değerleri sadece HUD'daki bilgi diyalogunda **gösteriliyor**:
```dart
multiplierPercent: (w.suvDemandMultiplier * 100).round(),   // "SUV talebi %160"
```
Ve bu diyalogun başlığında `weather_live_impact` → **"CANLI ETKİ"** rozeti duruyor.

Hiçbir teklif, fiyat, talep veya satış hızı hesabı hava durumunu okumuyor. Oyuncu "karlı günde SUV satayım" diye strateji kurar, hiçbir fark görmez.

Ayrıca hava tamamen deterministik: `_weatherCycle[(inGameDay - 1) % 7]` → 7. gün **her zaman** kar. Rastgelelik yok, mevsim yok.

**Düzeltme:**
1. `NegotiationEngine.generateBuyerOffer` ve organik teklif üretiminde çarpanı uygula:
   ```dart
   final weatherMult = WeatherEngine.getVehicleDemandMultiplier(state.currentWeather, car.bodyType);
   // teklif tutarını veya teklif gelme olasılığını çarp
   ```
2. `market_engine` ilan üretiminde SUV/Spor arz-talep dengesini o günün havasına göre kaydır.
3. Havayı `Random(currentDay)` seed'iyle deterministik-ama-tahmin-edilemez yap; mevsim bandı ekle.
4. Çarpan bağlanana kadar `weather_live_impact` rozetini kaldır — şu anda oyuncuya yalan söylüyor.

## C2 · Kilometre ve model yılı fiyata hiç etki etmiyor ⭐

**Dosyalar:** [car_model.dart:308-424](lib/data/models/car_model.dart:308), [market_engine.dart:158-219](lib/domain/usecases/market_engine.dart:158)

`estimatedRealValue` formülünde **`expertise.mileage` ve `modelYear` geçmiyor.** Sadece motor/şanzıman kondisyonu, boyalı/değişen oranı, temizlik, detailing, tuning, plaka ve renk var.

`market_engine`'de araç üretilirken de bağımsızlar:
```dart
final year = 1990 + _random.nextInt(15);
final baseValue = 35000.0 + _random.nextInt(...);   // year ile ilgisi yok
final mileage = 120000 + _random.nextInt(160000);   // baseValue ile ilgisi yok
```

**Sonuç:** 1990 model 280.000 km'lik araç ile 2005 model 120.000 km'lik araç **aynı fiyat** olabiliyor — hem üretimde hem değerlemede. Oyunun temel önermesi ("ekspertiz yap, doğru fiyatla") bu iki kritik veriyi yok sayıyor. Ekspertiz ekranı KM'yi büyük puntoyla gösteriyor ama sayı mekanik olarak ölü — sadece `isMileageTampered` boolean'ı pazarlıkta koz olarak kullanılıyor.

`tramerAmount` da değere etki etmiyor (yalnızca `isPristineOriginal` ve pazarlık kozu için okunuyor).

**Düzeltme:** `estimatedRealValue`'ye üç çarpan ekle (mevcut `0,2–1,6` clamp bandına dikkat ederek):
```dart
// Yaş amortismanı: yılda -%1,5, max -%35
final age = (DateTime.now().year - modelYear).clamp(0, 40);
factor *= (1.0 - (age * 0.015)).clamp(0.65, 1.0);

// KM amortismanı: 150.000 km referans, her +50.000 km için -%4, max -%20
final kmPenalty = ((expertise.mileage - 150000) / 50000.0 * 0.04).clamp(-0.05, 0.20);
factor *= (1.0 - kmPenalty);

// Tramer: değerin %30'una kadar doğrudan düşüm
final tramerPenalty = (expertise.tramerAmount / baseMarketValue).clamp(0.0, 0.30);
factor *= (1.0 - tramerPenalty);
```
Ve `market_engine`'de `baseValue`'yu `year` ile ilişkilendir (yeni model = yüksek taban). **Klasik/nadir araçlarda yaş cezasını ters çevir** (`isRare` ise yaş bonus versin) — aksi halde barn find / klasik koleksiyon ekonomisi bozulur.

**Uyarı devralan ajana:** Bu değişiklik tüm ekonomi dengesini kaydırır. `test/economy_test.dart`, `test/mathematical_audit_test.dart`, `test/market_realism_and_hp_specs_test.dart` mutlaka güncellenmeli ve yeniden kalibre edilmeli.

## C3 · 113 rastgele olay seçeneği yalnızca 3 şey yapabiliyor

**Dosyalar:** [random_event_engine.dart](lib/domain/usecases/random_event_engine.dart) (1.968 satır), [game_event_model.dart:3-16](lib/data/models/game_event_model.dart:3)

`GameEventChoice` modelinin **tüm alanları**: `label`, `resultText`, `balanceChange`, `reputationChange`, `xpGain`. Başka hiçbir şey yok. Yani 1.968 satırlık, özenle yazılmış 113 seçeneğin **hepsi** sadece bakiye/itibar/XP değiştiriyor.

Anlatı ile mekanik arasındaki kopukluk:

| Olay | Metin ne diyor | Kod ne yapıyor |
|---|---|---|
| `event_black_market_raid` | *"araç yediemin otoparkına çekildi"* | Hiçbir araç envanterden çıkmıyor |
| `event_sel` | *"Araçların alt takımları çamur oldu"* | `isWashed` değişmiyor; "kendi imkanlarınla yıka" hiçbir aracı yıkamıyor |
| Kaput boyama olayı | *"Kaput fırın boyaya alındı"* | Hiçbir aracın `bodyParts` durumu değişmiyor |
| Kahve otomatı / yıkama pompası olayları | Oto yıkama yan işini anlatıyor | `sideBusinesses` state'i hiç okunmuyor/yazılmıyor |

Ayrıca seçenekler çoğu zaman **gerçek ikilem sunmuyor**: `event_belediye`'de "İtiraz Et & Çay Ismarla" hem **daha ucuz** (−2.500 vs −5.000) hem **daha çok XP** (50 vs 30) veriyor; tek bedeli 5 itibar. Doğru seçim tartışmasız.

Küçük mantık tuhaflığı: "Cezayı Öde" seçeneği itibarı **+5 artırıyor** — ceza ödemek neden itibar kazandırsın?

**Düzeltme:**
1. `GameEventChoice`'a etki alanları ekle: `String? targetCarEffect` (`'impound' | 'dirty' | 'repaint' | 'damage'`), `String? sideBusinessId` + `int downtimeDays`, `int? staffMoraleChange`, `String? unlockFlag`.
2. `resolveRandomEvent`'i bu alanları işleyecek şekilde genişlet — `DramaticCardEngine.resolve`'daki `loseTargetCar` / `makeFamilyHeirloom` mantığı hazır bir örnek, aynı yapıyı kullan.
3. **En az** şu 6 olayı gerçek etkiye bağla: karaborsa baskını (araç el koyma), sel (tüm araçlar kirlenir), kaput hasarı (`bodyParts` bozulur), yıkama pompası (yan iş 2 gün durur), zabıta (1 gün ilan yasağı), kedi olayı (itibar zaten çalışıyor, dokunma).
4. Seçenekleri **denk** hale getir. Basit kural: `(|balanceChange| / 1000) + (reputationChange * 2) + (xpGain / 10)` her seçenek için yaklaşık eşit olsun.

## C4 · Kiracı seçim ekranı 4 kriter gösteriyor, sadece 1,5'i çalışıyor

**Dosyalar:** [tenant_model.dart:14-23](lib/data/models/tenant_model.dart:14), [game_time_mixin.dart:586-600](lib/presentation/providers/game/game_time_mixin.dart:586)

`TenantModel` alanlarının kullanım durumu:

| Alan | Ekranda | Kodda kullanımı |
|---|---|---|
| `monthlyRent` | ✅ | ✅ gerçek gelir |
| `evictionRiskScore` | ✅ "Tahliye Riski %30" | ⚠️ aşağıya bak |
| `reliabilityScore` | ✅ **A+/A/B/C notu** | ❌ **hiçbir yerde okunmuyor** |
| `desiredLeaseYears` | ✅ | ❌ **hiçbir yerde okunmuyor** |
| `leaseStartDay` | — | ❌ kullanılmıyor |
| `unpaidRentDays` | — | ⚠️ sadece artırılıyor, hiç okunmuyor |

`evictionRiskScore` ise "risk" değil, **gizli kira kesintisi**:
```dart
final isDelinquent = tenant != null && random.nextInt(100) < tenant.evictionRiskScore;
```
Her gün bağımsız zar atılıyor, sonuç sadece "o gün kira yok". Birikimli sonuç yok, tahliye yok, depozito irat edilmiyor, icra yok. Yani **riski 30 olan kiracı, kirasının %70'ini ödeyen kiracıdır** — belirsizlik değil, deterministik indirim.

`unpaidRentDays` 7'nin katlarında sadece bir log satırı üretiyor; 100 güne çıksa bile hiçbir şey olmuyor.

**Sonuç:** Kiracı seçimi 4 kriterli bir karar gibi sunuluyor ama optimal strateji tek satır: `max(monthlyRent × (1 − evictionRiskScore/100))`. Anlatı katmanının tamamı boşta.

**Düzeltme:**
1. `reliabilityScore`'u fiilen bağla: `isDelinquent` olasılığını `evictionRiskScore` yerine `(100 - reliabilityScore)` ile harmanla, veya mülk yıpranma hızına (`isUnderRenovation` tetiklenme sıklığına) bağla.
2. `unpaidRentDays` eşiklerine gerçek sonuç koy:
   - `>= 15` → uyarı `GameEventModel` + depozitodan mahsup
   - `>= 30` → otomatik tahliye, depozito irat, mülk boşa düşer, itibar −5
3. `desiredLeaseYears`'ı sözleşme süresine bağla: süre dolunca kiracı ya yeniler ya çıkar; erken tahliyede oyuncu tazminat öder.
4. Zar atışını **birikimli** yap: art arda ödenmeyen gün arttıkça `isDelinquent` olasılığı yükselsin — böylece "riski 30" gerçekten riskli hissettirsin.

## C5 · İçerik katmanı 7 dilde değil — lokalizasyon bir cephe

**Kanıt:** UI anahtarları kusursuz — 7 dilde **4.535 anahtar**, sıfır eksik, sıfır çevrilmemiş değer (doğrulandı). Ama `lib/` altında lokalizasyon klasörü **dışında** ~**5.011 sabit kodlanmış Türkçe metin**, **145 dosyada** var.

En yoğun dosyalar:

| Dosya | Türkçe sabit metin |
|---|---:|
| `random_event_engine.dart` | 632 |
| `negotiation_engine.dart` | 262 |
| `dramatic_card_engine.dart` | 221 |
| `dramatic_card_model.dart` | 205 |
| `negotiation_suspense_engine.dart` | 182 |
| `market_engine.dart` | 151 |
| `real_estate_negotiation_engine.dart` | 129 |
| `auction_engine.dart` | 119 |
| `game_time_mixin.dart` | 99 |

Bunlar oyuncunun **en çok okuduğu** metinler: tüm olaylar, tüm pazarlık replikleri, tüm dramatik kartlar, tüm satıcı/müşteri kişilikleri, tüm ekspertiz parça isimleri, tüm günlük özet olayları.

Presentation katmanında bile 590 tane var — örneğin `create_listing_screen.dart` (çekirdek ekran):
```dart
'Vitrin & Tanıtım Paketleri'
'Standart İlan'
'Acil İlan • Doping'
'Doping başarıyla uygulandı!'
'Yüksek Talep • Hızlı Alıcı Çekimi'
```

`AGENTS.md` Invariant #8 açıkça yasaklıyor: *"Hardcoded text or single-language additions without full 7-language synchronization are strictly forbidden."* Kural anahtar dosyaları için tutuluyor; içerik motorları için hiç uygulanmamış.

**Sonuç:** Almanca oynayan bir oyuncu, çevrilmiş bir menü kabuğu içinde **tamamen Türkçe bir oyun** görüyor.

**Düzeltme (aşamalı, tek seferde yapılamaz):**
- **Faz 1 — kanamayı durdur:** `test/` altına lint testi ekle: `lib/presentation/screens/**` içinde Türkçe karakter içeren ve `context.tr` ile sarmalanmamış string literal varsa test kırılsın. Mevcutlar için bir allowlist dosyası tut. Böylece **yeni** ihlal eklenemez.
- **Faz 2 — presentation:** 590 literal'i anahtara çevir; en yoğun 6 dosyayla başla.
- **Faz 3 — içerik motorları:** Bu motorlar rastgele metin üretiyor, doğrudan `context.tr` kullanamazlar. Yaklaşım: motorlar **anahtar + parametre** döndürsün (`(key: 'evt_flood_choice_pro', params: {'cost': 8000})`), UI çözümlesin. `market_engine`'de `descriptionKey` ile bu desen **zaten var** — o deseni tüm motorlara yay.
- **Öncelik:** `dramatic_card_model` + `random_event_engine` (en çok okunan), sonra `negotiation_engine`.
- **Not:** Ekspertiz parça adları (`'Kaput'`, `'Sol Ön Çamurluk'`) hem `Map` anahtarı hem ekran metni olarak kullanılıyor. Bunları çevirmek için anahtarları `enum BodyPart`'a taşımak ve gösterimi ayırmak gerekir — ayrı bir refactor.

## C6 · Ölü kod ve çakışan paralel sistemler

| Ne | Konum | Sorun |
|---|---|---|
| `upgradePrestigeBranch` | [game_inventory_mixin.dart:381](lib/presentation/providers/game/game_inventory_mixin.dart:381) | `property_tier_N` bayraklarını set eden **ikinci** sistem. Hiçbir ekrandan çağrılmıyor. Fiyatları `upgradeBranch` ile eşleşiyor ama slot mantığı farklı (**toplamalı** vs **mutlak**). Biri bunu bağlarsa A5'teki slot düşme hatası ikiye katlanır. |
| `expandGarageSlot` | [game_inventory_mixin.dart:553](lib/presentation/providers/game/game_inventory_mixin.dart:553) | Ölü. Garaj genişletmenin üçüncü yolu. |
| `buyVasita` | [vasita_market_provider.dart:68](lib/presentation/providers/vasita_market_provider.dart:68) | Ölü. Bağlansaydı B4 nedeniyle **pazarlıktan daha ucuz** olurdu — pazarlık mini oyununu tamamen anlamsızlaştırırdı. Bağlanmadan önce B4 düzeltilmeli. |
| `EventDispatcher` | `lib/domain/usecases/event_dispatcher.dart` | Sınıf hiçbir yerden referans edilmiyor. |
| `calculateDailyTax` `>= 9` dalı | [loan_settlement_engine.dart:191](lib/domain/usecases/loan_settlement_engine.dart:191) | Max seviye 8 → `₺5.000` kademesine ulaşılamaz. |
| `getRequiredLevel()` → `getRequiredBranchName()` | [dealership_model.dart:900-903](lib/data/models/dealership_model.dart:900) | **Seviye** değerini **şube tier** adına çeviriyor. Bunlar farklı eksenler: seviye XP'den, tier satın almadan geliyor. Seviye 8 ama tier 1 olan oyuncuya "Sanayi Sitesi Esnaf Galerisi gerekli" deniyor — oysa seviyesi zaten yeterli. |

**Düzeltme:** İlk dördünü sil. `>= 9` dalını `>= 8` yap veya kaldır. `getRequiredBranchName`'i ya kaldır ya da gerçek tier gereksinimini ayrı bir tablodan oku.

## C7 · `CurrencyFormatter` 7 dile hazır değil

**Dosya:** [currency_formatter.dart](lib/core/utils/currency_formatter.dart)

```dart
NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0)   // dil ne olursa olsun
if (amount >= 1000000) return '₺${(amount/1000000).toStringAsFixed(1)}M';
```

Dört sorun:
1. `locale: 'tr_TR'` **sabit** — İngilizce oynayan oyuncu `₺1.234.567` (nokta ayraçlı) görüyor.
2. `M` / `K` kısaltmaları İngilizce ve **hiçbir dile çevrilmiyor** — Türkçe'de `Mn`/`B`, Rusça'da `млн`/`тыс`, Arapça'da RTL akış içinde Latin harfler.
3. **Milyar dalı yok:** `₺1.500.000.000` → `"1500.0M"`. `branch_8` tapusu ₺150M; gayrimenkul + inşaat ekonomisiyle milyar seviyesi ulaşılabilir.
4. **Negatif bozuk:** `-5000` → `amount >= 1000` yanlış → `'₺-5000'` (kısaltılmıyor), ama `+5000` → `'₺5K'`. Aynı ekranda iki farklı format.

**Düzeltme:** `formatShort`'u `langCode` alacak şekilde imzala; kısaltma soneklerini 7 dilde localization anahtarı yap (`fmt_thousand`, `fmt_million`, `fmt_billion`); `NumberFormat` locale'ini aktif dilden al; negatifte `amount.abs()` üzerinden çalışıp işareti başa ekle; milyar dalı ekle.

---

# Öncelik Sırası — Devralan Ajan İçin Yol Haritası

| # | Bulgu | Etki | İş büyüklüğü |
|---|---|---|---|
| 1 | **A1** TÜFE sınırsız zam | Ekonomiyi tek başına yıkıyor | S |
| 2 | **A3** Offline'da kredi/vergi atlanıyor | Kredi bedava | M |
| 3 | **A2** Offline personel sömürüsü | "Oynamamak" optimal strateji | S |
| 4 | **B1** `profitMultiplier` sahte | En pahalı satın alma yalan | M |
| 5 | **B3** Nakit akışı ekranı yanlış | Tüm finansal kararlar hatalı veriye dayanıyor | M |
| 6 | **B2** Tapu gideri artırıyor | Vaadin tam tersi | S |
| 7 | **A4** Reklam ödülü değer şişirme | Bileşik sömürü | S |
| 8 | **B5** colorHex çökme + Volk markası | Ödül anında çökme | S |
| 9 | **B4** Pazarlık perkleri iki pazarda farklı | Gösterilen ≠ ödenen | M |
| 10 | **A5** Şube merdiveni + slot düşmesi | ₺23,8M gizli ceza | S |
| 11 | **C1** Hava durumu dekoratif | "CANLI ETKİ" yalan | M |
| 12 | **C2** KM & model yılı ölü | Oyunun temel önermesi eksik | **L** — ekonomi rekalibrasyonu |
| 13 | **C4** Kiracı sistemi yüzeysel | 4 kriterin 2,5'i sahte | M |
| 14 | **C3** 113 olay seçeneği yüzeysel | Anlatı ≠ mekanik | **L** |
| 15 | **B6** Beş farklı zaman birimi | Teklifler sebepsiz kayboluyor | M — save migration gerekli |
| 16 | **A6** Olay seçiminde bakiye kontrolü yok | Negatif bakiye | S |
| 17 | **C7** CurrencyFormatter | 7 dil desteği eksik | S |
| 18 | **B7** "Pretij" yazım hatası | Ekranda görünüyor | XS |
| 19 | **C6** Ölü kod & çakışan sistemler | Bakım borcu | S |
| 20 | **C5** 5.011 sabit Türkçe metin | Lokalizasyon bir cephe | **XL** — fazlı |

## Devralan ajan için genel notlar

1. **Önce test altyapısını kur, sonra düzelt.** Şu an 845 test geçiyor ama hiçbiri "ekranda yazan = gerçekte olan" iddiasını doğrulamıyor. Diğer düzeltmelere başlamadan şu üç test eklenmeli:
   - `CashflowEngine.calculate()` ile `advanceGameDay()` bakiye değişimi karşılaştırması (±%5).
   - Şube ekranında gösterilen `dailyBurnRate` ile `_processDailyPropertyBurn` sonucu karşılaştırması.
   - Offline `simulatedDays` kez `advanceGameDay()` ile offline simülasyonun aynı sonucu üretmesi.

2. **Tek doğruluk kaynağı ilkesi.** Bu raporun neredeyse tüm bulguları aynı kökten geliyor: aynı sayının iki-üç yerde ayrı ayrı hesaplanması — mülk gideri 3 yerde, vergi 2 yerde, alım indirimi 2 yerde, tier bayrakları 2 fonksiyonda, hex çözümleme 3 yerde, personel otomasyonu 2 yerde. Düzeltmeleri yaparken **yeni bir kopya oluşturma** — mevcut kopyaları tek fonksiyona indir.

3. **A ve B gruplarını C'den önce bitir.** A/B küçük ve riski düşük; C2/C3/C5 ekonomi rekalibrasyonu ve büyük refactor gerektiriyor.

4. **Her düzeltmede 7 dil kuralı geçerli.** Yeni gösterilen her sayı/etiket (aidat satırı, TÜFE kilidi, indirim satırı, kredi etiketi) `AGENTS.md` #8 gereği 7 dile aynı commit'te eklenmeli.

---

*Bu rapor `lib/` kaynak kodunun hedefli okunmasına dayanır. Hiçbir dosya değiştirilmedi. `flutter analyze` temiz, `flutter test` 845/845 geçiyor — bulguların hiçbiri derleyici veya mevcut testlerle yakalanamıyor.*
