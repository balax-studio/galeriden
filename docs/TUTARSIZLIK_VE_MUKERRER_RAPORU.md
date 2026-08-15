# Galerisinden — Tutarsızlık, Çelişki ve Mükerrer İşlem Raporu

**Konu:** Oyuncunun gözüne batacak çelişkili metin/fiyat, mükerrer işlem, yazım hatası ve tutarsızlıklar.
**Kapsam:** Yalnızca rapor. Kod okundu, hiçbir dosya değiştirilmedi.
**Yöntem:** `lib/` altındaki kaynak kodun hedefli taraması. Her bulgu `dosya:satır` referanslı ve doğrulanmış.

---

## Özet

En ciddi bulgu tek cümleyle: **Şube satın alma ekranı, oyuncuya ödeyeceği günlük giderin 4 katına kadar yanlış bir rakam gösteriyor** — ve satın alınan iki şube aslında gideri hiç artırmıyor.

Bulguları oyuncunun fark etme sırasına göre gruplandırdım: önce ekranda gördüğü çelişkiler, sonra hissettiği ama adlandıramayacağı tutarsızlıklar, en sonda yalnızca geliştiricinin göreceği mükerrer kod.

---

# A. ÇELİŞKİLİ FİYAT & SAYI *(oyuncu doğrudan görüyor)*

## A1 · Şube Ekranındaki Sabit Gider Rakamları Gerçekle Uyuşmuyor ⭐ *en kritik*

**Dosyalar:** [branch_screen.dart:201](lib/presentation/screens/branch/branch_screen.dart:201), [branch_model.dart:35-75](lib/data/models/branch_model.dart:35), [game_inventory_mixin.dart:213-215](lib/presentation/providers/game/game_inventory_mixin.dart:213), [game_time_mixin.dart:56-63](lib/presentation/providers/game/game_time_mixin.dart:56)

Şube satın alma ekranı, `BranchModel.dailyBurnRate` değerini oyuncuya gösteriyor:
```dart
'• Sabit Gider: ${CurrencyFormatter.formatShort(b.dailyBurnRate)}/gün'
```

Ama gerçek gider `game_time_mixin.dart` içinde `property_tier_N` bayraklarından hesaplanıyor ve `upgradeBranch` bu bayrakları **bir kademe kaymış** şekilde set ediyor (`if (branch.targetLevel >= 3) → property_tier_2`).

| Şube | Ekranda yazan | Gerçekte kesilen | Durum |
|---|---:|---:|---|
| Kaldırım Başı Sokak Garajı (Lv1) | ₺300/gün | **₺500/gün** | %67 daha pahalı |
| İkitelli Sanayi Dükkânı (Lv2) | ₺1.800/gün | **₺500/gün** | Hiç bayrak set edilmiyor — gider hiç artmıyor |
| Maslak Otomotiv Plazası (Lv3) | ₺12.000/gün | **₺3.000/gün** | 4× daha ucuz |
| Levent Mega Holding (Lv4) | ₺50.000/gün | **₺12.000/gün** | 4× daha ucuz |
| — | — | ₺45.000/gün | **Ulaşılamaz kademe** (`targetLevel >= 5` gerekiyor, böyle şube yok) |

Üç ayrı sorun iç içe:
1. Hiçbir satır tutmuyor — dört şubenin dördünde de gösterilen ≠ kesilen.
2. **İkitelli Sanayi Dükkânı (₺350.000)** satın alındığında hiçbir `property_tier` bayrağı set edilmiyor; oyuncu ₺1.800/gün gidere hazırlanıp ₺500'de kalıyor.
3. `property_tier_4` (₺45.000/gün) kademesine ulaşan hiçbir yol yok — ölü kademe.

Oyuncu bunu mutlaka fark eder: ₺12.000.000 ödeyip "günlük ₺50.000 gider" beklerken bakiyesinden ₺12.000 düşmesi, ya da tersi, güven kırıcı bir tutarsızlık.

## A2 · İki Paralel Mülk Sistemi, Aynı Kademeler İçin Çelişkili Fiyatlar

**Dosyalar:** [game_inventory_mixin.dart:117-146](lib/presentation/providers/game/game_inventory_mixin.dart:117), [branch_model.dart:28-83](lib/data/models/branch_model.dart:28)

Kod tabanında `property_tier_N` bayraklarını set eden **iki ayrı fonksiyon** var ve ikisi aynı kademe için tamamen farklı fiyat istiyor:

| Kademe | `upgradePrestigeBranch()` | `upgradeBranch()` (BranchModel) |
|---|---:|---:|
| tier_2 | ₺350.000 (+2 slot) | ₺2.500.000 (Maslak, 10 slot) |
| tier_3 | ₺1.250.000 (+4 slot) | ₺12.000.000 (Levent, 16 slot) |
| tier_4 | ₺4.500.000 (+6 slot) | *(erişilemez)* |

`upgradePrestigeBranch` hiçbir ekrandan çağrılmıyor (ölü kod) — ama duruyor ve aynı oyun kavramı için 7 kata varan farklı bir fiyat tablosu tanımlıyor. İleride biri bunu bağlarsa iki sistem çakışır.

## A3 · Dramatik Kart C1 — "Dürüst" Seçim Matematiksel Olarak Zarar

**Dosyalar:** [dramatic_card_model.dart:673-723](lib/data/models/dramatic_card_model.dart:673), [dramatic_card_engine.dart:160-180](lib/domain/usecases/dramatic_card_engine.dart:160)

"Dul Kadının Arabası" kartında oyuncuya söylenenler:
- Önsezi notu: *"Aracın gerçek piyasa değeri **en az ₺180.000**."*
- Dürüst seçim: *"Gerçek Değerini Söyle (**₺150.000** Teklif Et)"*
- Sömürücü seçim: *"Kadının Dediği Fiyata Al (₺70.000)"* → açıklama: *"+₺110.000 değer"*

Ama her iki seçim de aynı `spawnBargainCar: true` sonucunu veriyor ve motor **sabit kodlanmış tek bir araç** üretiyor: `baseMarketValue: 120.000`.

Sonuç:
- **Dürüst seçim:** ₺150.000 öde → ₺120.000'lik araç al → **₺30.000 garantili zarar.**
- **Sömürücü seçim:** ₺70.000 öde → ₺120.000'lik araç al → ₺50.000 kâr (vaat edilen ₺110.000 değil).

Yani oyunun "ahlaklı ol" mesajını taşıyan kart, ahlaklı oyuncuyu somut olarak cezalandırıyor ve iki seçimin de rakamı yanlış.

## A4 · Dramatik Kart E1 — "₺250.000 Üzerinde" Denen Araç ₺120.000

**Dosya:** [dramatic_card_model.dart:993-1002](lib/data/models/dramatic_card_model.dart:993)

"Kapalı Zarf İhalesi" jackpot metni:
> *"Konteynerden gümrükte unutulmuş hatasız bir klasik canavar çıktı! **Değeri ₺250.000 üzerinde!**"*

Verilen araç yine aynı sabit kodlanmış `baseMarketValue: 120.000` 2018 Hatchback. Aynı çelişki C2 kartında da var (*"normal piyasası ₺140.000"* → yine ₺120.000'lik araç).

---

# B. ÇELİŞKİLİ METİN & VAAT *(oyuncu fark eder ama adlandıramaz)*

## B1 · Beş Farklı Hikâye, Tek Bir Araç ⭐

**Dosya:** [dramatic_card_engine.dart:160-180](lib/domain/usecases/dramatic_card_engine.dart:160)

`spawnBargainCar` her tetiklendiğinde **birebir aynı aracı** üretiyor:

```dart
brand: 'Volk',
modelName: 'Golf GTI Klasiği',
modelYear: 2018,
bodyType: 'Hatchback',
baseMarketValue: 120000.0,
```

Bu tek araç şu beş farklı anlatının **hepsinin** karşılığı olarak veriliyor:

| Kart | Anlatının vaat ettiği araç | Verilen |
|---|---|---|
| C1 — Dul Kadının Arabası | *"Rahmetli beyimin arabası"* (₺180.000+) | 2018 Golf GTI |
| C1 (sömürücü seçim) | Aynı araç | 2018 Golf GTI |
| C2 — Rakibin Zor Günü | *"Kelepir araba"* (₺140.000) | 2018 Golf GTI |
| E1 — Jackpot | *"Efsane klasik canavar"* (₺250.000+) | 2018 Golf GTI |
| E1 — Orta sonuç | *"Temiz bir aile aracı"* | 2018 Golf GTI |

Bir oyuncu bu kartlardan ikisini gördüğünde çelişkiyi anında fark eder: yaşlı kadının rahmetli eşinden kalan araba ile gümrük konteynerinden çıkan efsane klasik **aynı 2018 model Golf.**

## B2 · "Aile Yadigârı" Kilidi Tek Dokunuşla Geri Alınabiliyor

**Dosyalar:** [dramatic_card_model.dart:842-857](lib/data/models/dramatic_card_model.dart:842), [game_inventory_mixin.dart:102-113](lib/presentation/providers/game/game_inventory_mixin.dart:102), [showroom_car_card.dart:477](lib/presentation/screens/showroom/widgets/showroom_car_card.dart:477)

D1 kartı ("Dede'nin Eski Çırağı") oyuncuya ağır, geri dönülmez bir karar sunuyor: *"Araç **satılamaz** koleksiyon statüsü kazanır"*, sonuç ekranında **"AİLE YADİGARI TESCİLLENDİ"** rozeti gösteriliyor.

Ama Showroom kartındaki `toggleShowcaseLock()` fonksiyonu bu kilidi **tek dokunuşla açıp kapatıyor** — hiçbir onay, hiçbir bedel, hiçbir uyarı yok. Dramatik kartın tüm duygusal ağırlığı (dedenin mirasına sahip çıkma kararı) mekanik olarak sahte: oyuncu kilidi 2 saniye sonra kaldırıp aracı satabilir.

*Not: Motor tarafı doğru çalışıyor — kilitli araçlar hırsızlık kartından korunuyor ([dramatic_card_engine.dart:114](lib/domain/usecases/dramatic_card_engine.dart:114)). Sorun yalnızca kilidin bedelsiz geri alınabilmesi.*

## B3 · Üç Farklı Seviye Kapısı Tablosu

**Dosyalar:** [dealership_model.dart](lib/data/models/dealership_model.dart) `getRequiredLevel()`, [isometric_world_map.dart:87-300](lib/presentation/widgets/isometric_world_map.dart:87)

Aynı özelliklerin hangi seviyede açılacağı iki yerde tanımlı ve **hiç uyuşmuyor**:

| Özellik | `getRequiredLevel()` | Harita `requiredLevel` | Fark |
|---|---:|---:|---|
| `/workshop` | 2 | 1 | 1 kademe |
| `/tuning-studio` | 2 | 5 | **3 kademe** |
| `/scrapyard` | 4 | 3 | 1 kademe |
| `/auction` | 3 | 4 | 1 kademe |
| `/finance` | 3 | 3 | ✓ |
| `/bank-investments` | 3 | 6 | **3 kademe** |
| `/stock-market` | 3 | 7 | **4 kademe** |
| `/black-market` | 4 | 8 | **4 kademe** |
| `/side-businesses` | 4 | 6 | 2 kademe |
| `/branches` | 4 | 5 | 1 kademe |

Harita şu an hiçbir ekrandan çağrılmadığı için oyuncu bu çelişkiyi **henüz** görmüyor. Ama harita bağlanır bağlanmaz (önceki raporda önerdiğim gibi) oyuncu, servis listesinde "Seviye 3" yazan bir özelliğin haritada "Seviye 7" göründüğünü fark eder. Ayrıca haritanın `unlockCost` alanı (₺15.000–₺350.000) hiçbir yerde karşılığı olmayan üçüncü bir ekonomi tanımlıyor.

---

# C. YAZIM HATALARI *(ekranda görünüyor)*

| # | Hata | Doğrusu | Konum | Görünürlük |
|---|---|---|---|---|
| 1 | **"Vitlindeki"** | Vitrindeki | [psychology_engine.dart:133](lib/domain/usecases/psychology_engine.dart:133) | "Yokluğunda Neler Oldu?" modalı |
| 2 | **"Vitlindeki"** | Vitrindeki | [weekly_event_engine.dart:61](lib/domain/usecases/weekly_event_engine.dart:61) | Cumartesi haftalık etkinlik banner'ı |
| 3 | **"Pretij & Konfor"** | Prestij | [mission_factory.dart:86](lib/domain/usecases/mission_factory.dart:86) | VIP sözleşme kartı |

İlk ikisi aynı kelimenin aynı hatası — muhtemelen kopyala-yapıştır kaynaklı. Üçü de kullanıcıya gösterilen metinlerde.

---

# D. KİMLİK TUTARSIZLIĞI

## D1 · Oyunun Adı Üç Yerde Üç Farklı

| Değer | Konum | Nerede görünüyor |
|---|---|---|
| `'Galeriden'` | [app.dart:64](lib/app/app.dart:64) | Uygulama başlığı (görev çubuğu, uygulama değiştirici) |
| `'Galeriden'` | [game_constants.dart:18](lib/core/constants/game_constants.dart:18) | **Ayarlar ekranı** — `"Galeriden v1.2.0"` |
| `'Galeriden Tycoon'` | [app_constants.dart:5](lib/core/config/app_constants.dart:5) | *(kullanılmıyor)* |
| `Galerisinden` | Kod yorumlarında (`app_colors.dart:3`, `app_spacing.dart:1`, `game_sound_haptic_service.dart:3`) | — |

Projenin, klasörün ve yorumların adı **Galerisinden**, ama oyuncuya gösterilen her yerde **Galeriden** yazıyor — "sin" hecesi eksik. Ayarlar ekranındaki sürüm satırı bunu doğrudan gösteriyor.

---

# E. ÇÖKME RİSKİ

## E1 · Sabit Kodlanmış Araç Rengi Hatalı Formatta

**Dosya:** [dramatic_card_engine.dart:167](lib/domain/usecases/dramatic_card_engine.dart:167)

```dart
colorHex: 'D90429',
```

Oyundaki diğer tüm araçlar iki formattan birini kullanıyor: `'0xFF1E3A8A'` ([game_time_mixin.dart:432](lib/presentation/providers/game/game_time_mixin.dart:432)) veya `'#000000'` ([showroom_offers_tab.dart:89](lib/presentation/screens/showroom/widgets/showroom_offers_tab.dart:89)).

Renk ayrıştırma kodu şu şekilde:
```dart
Color(int.parse(car.colorHex.replaceFirst('#', '0xff')))
```

`'D90429'` değerinde ne `#` ne de `0x` öneki var → `replaceFirst` hiçbir şey değiştirmiyor → `int.parse('D90429')` **`FormatException` fırlatıyor.**

Bu araç Showroom'a eklendiği anda, aracı çizen her ekran ([isometric_showroom_canvas.dart:643](lib/presentation/widgets/isometric_showroom_canvas.dart:643), [isometric_hydraulic_lift.dart:37](lib/presentation/screens/workshop/widgets/isometric_hydraulic_lift.dart:37)) bu satırda patlar. Kartlardan (C1, C2, E1) biri "kelepir araç" ödülü verdiğinde tetiklenir — yani **oyuncunun ödül aldığı anda ekran çöker.**

## E2 · Marka Oyunun Marka Listesinde Yok

Aynı araçtaki `brand: 'Volk'` değeri, `GameConstants.carBrands` listesinde bulunmuyor. Oyunun Volkswagen karşılığı **"Vosgen"** (`'Vosgen Golf Sekiz R-Line'`). Dolayısıyla bu araç:
- Marka bazlı filtrelerde/eşleştirmelerde hiçbir gruba düşmez,
- VIP sözleşmelerinde (`targetBrand`) asla eşleşmez,
- Oyunun tutarlı "esprili marka" evreninden görsel olarak sırıtır ("Volk Golf GTI Klasiği" — hem gerçek marka adına yakın hem de oyunun kendi kurgusuna aykırı).

---

# F. MÜKERRER İŞLEM & KOD *(oyuncu görmüyor ama davranış farkı yaratıyor)*

## F1 · `sellSalvagedPart` İki Kez Tanımlı — Farklı XP Veriyor

**Dosyalar:** [game_inventory_mixin.dart:528](lib/presentation/providers/game/game_inventory_mixin.dart:528), [game_market_mixin.dart:732](lib/presentation/providers/game/game_market_mixin.dart:732)

Aynı isimli fonksiyon iki ayrı mixin'de, iki farklı davranışla tanımlı:

| | `GameInventoryMixin` | `GameMarketMixin` |
|---|---|---|
| XP ödülü | **15** | **45** |
| `part.isSold` kontrolü | ❌ yok | ✅ var |

`GameCoreNotifier` mixin sırası `with GameFinanceMixin, GameInventoryMixin, GameMarketMixin, ...` şeklinde ([game_core_provider.dart:19-25](lib/presentation/providers/game/game_core_provider.dart:19)). Dart'ta çakışan üyelerde **son mixin kazanır** → `GameMarketMixin` (45 XP) çalışıyor, `GameInventoryMixin` versiyonu tamamen ölü.

Tehlike şu: mixin sırası ileride herhangi bir sebeple değişirse, parça satışının XP ödülü sessizce 45'ten 15'e düşer ve `isSold` koruması kaybolur. Hiçbir derleyici uyarısı çıkmaz.

## F2 · Hurdalık Alımı İçin İki Ayrı Fonksiyon

| Fonksiyon | Konum | XP | Davranış | UI'dan çağrılıyor mu |
|---|---|---:|---|---|
| `buyAndDismantleScrapCar` | inventory_mixin:502 | 60 | Aracı listeden siler | ✅ Evet |
| `buyScrapyardCar` | market_mixin:709 | 120 | `isPurchased: true` işaretler | ❌ **Hayır (ölü)** |

Aynı oyun eylemi için iki farklı XP ödülü (60 vs 120) ve iki farklı envanter davranışı tanımlı. Kullanılan versiyon daha az XP veren.

## F3 · Çağrılmayan Ölü Fonksiyonlar

Tanımlı ama hiçbir ekrandan kullanılmayan işlemler:

| Fonksiyon | Konum | Not |
|---|---|---|
| `buyScrapyardCar` | game_market_mixin.dart:709 | F2'deki mükerrer |
| `instantRepair` | game_market_mixin.dart | Anında onarım — hiç sunulmuyor |
| `addOffer` | game_market_mixin.dart | — |
| `expandGarageSlot` | game_inventory_mixin.dart:195 | Garaj genişletmenin ikinci yolu |
| `upgradePrestigeBranch` | game_inventory_mixin.dart:117 | A2'deki çelişkili fiyat sistemi |
| `RandomEventEngine` *(tüm sınıf)* | random_event_engine.dart | 16 yazılmış olay |
| `getRandomFomoText`, `getSunkCostRepairText` | psychology_engine.dart | — |
| `IsometricWorldMap` *(2.000 satır)* | isometric_world_map.dart | B3'teki çelişkili seviye tablosunun kaynağı |

## F4 · Alias Fonksiyon

**Dosya:** [game_inventory_mixin.dart:786](lib/presentation/providers/game/game_inventory_mixin.dart:786)

```dart
/// Alias for doDailyScrapyardSideGig
bool workScrapyardSideGig() => doDailyScrapyardSideGig();
```

UI `workScrapyardSideGig()` çağırıyor, asıl mantık `doDailyScrapyardSideGig()` içinde. İki isim aynı iş için — küçük ama gereksiz bir dolaylılık.

---

# Öncelik Sırası

| Sıra | Bulgu | Neden | Görünürlük |
|---|---|---|---|
| 1 | **E1** — colorHex çökme riski | Ödül anında ekran çökebilir | 🔴 Çökme |
| 2 | **A1** — Şube gider rakamları | 4 şubede de gösterilen ≠ kesilen, iki şube gideri hiç artırmıyor | 🔴 Yüksek |
| 3 | **B1** — Beş hikâye, tek araç | İkinci kartta anında fark edilir | 🟠 Yüksek |
| 4 | **A3/A4** — Kart fiyat çelişkileri | Dürüst seçim zarar ettiriyor | 🟠 Yüksek |
| 5 | **C** — Yazım hataları (3 adet) | Ekranda görünüyor, düzeltmesi dakikalar | 🟡 Orta |
| 6 | **B2** — Yadigâr kilidi geri alınabilir | Dramatik kartın ağırlığını sahte kılıyor | 🟡 Orta |
| 7 | **D1** — "Galeriden" vs "Galerisinden" | Ayarlar ekranında görünüyor | 🟡 Orta |
| 8 | **F1** — Mükerrer `sellSalvagedPart` | Sessiz davranış değişikliği riski | 🟢 Düşük |
| 9 | **B3** — Üç seviye tablosu | Harita bağlanana kadar gizli | 🟢 Düşük |
| 10 | **A2, F2, F3, F4** — Ölü/mükerrer kod | Bakım borcu | 🟢 Düşük |

---

*Bu rapor `lib/` kaynak kodunun hedefli taramasına dayanır. Hiçbir dosya değiştirilmedi.*
