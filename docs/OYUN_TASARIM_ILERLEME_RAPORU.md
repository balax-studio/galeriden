# Galerisinden — Oyun Tasarım & İlerleme Raporu

**Tarih:** 15 Ağustos 2026 · **Sürüm:** `GameConstants.appVersion = 1.2.0` · **Branch:** `main`
**Kapsam:** Oynanış döngüsü, ilerleme temposu, ekonomi dengesi, retention.
**Yöntem:** Statik kod analizi — `lib/` altındaki 131 Dart dosyası (29.845 satır). Tüm bulgular `dosya:satır` referanslıdır ve kod okumasıyla doğrulanmıştır; runtime profiling yapılmamıştır.
**Kapsam Dışı (talep gereği):** yeni harici paket, yeni grafik motoru, backend.

---

## 0. Yönetici Özeti

Oyunun içerik hacmi ve görsel kimliği güçlü; sorun içerik eksikliği değil, **çekirdek döngünün ekonomik olarak ödüllendirilmemesi.**

Üç cümlede teşhis:

1. **Restorasyon hiçbir şey kazandırmıyor.** `CarModel.estimatedRealValue` içindeki bir `clamp` hatası, kaporta hasarının araç değerine etkisini matematiksel olarak sıfırlıyor. Tutorial oyuncuya 8 adım boyunca kaporta onarımı öğretiyor ve 9. adımda "değer artışını gör" diyor — artış gerçekleşmiyor.
2. **İlerleme birinci görevde kilitleniyor.** `claimMissionReward` mantık hatası nedeniyle her zaman `false` dönüyor; "Dede Mirası" görevinin ₺35.000 + 250 XP ödülü alınamıyor. Ayrıca oyunda tanımlı **tek bir görev** var — havuz boş.
3. **Seviye atlamak bir cezalandırma.** Sabit gider XP seviyesine bağlı: Lv1'de ₺650/gün, Lv4'te ₺240.150/gün (**369×**). Oyuncu bu artışı seçmiyor — XP kazandığı için başına geliyor. Buna karşılık yan işletmeler ~1 saatte kendini amorti edip saatte ~28M pasif üretiyor; ana galeri döngüsü ~10× gölgeleniyor.

**Sonuç:** Oyuncu "araba al → onar → sat" döngüsünü oynamamayı öğreniyor. Optimal strateji Gün 1'den itibaren *kaporta onarımını atlamak, sadece motor tamir etmek, seviye atlamamaya çalışmak ve parayı yan işletmeye/mevduata yatırmak.* Bu, tasarlanan oyunun tam tersi.

İyi haber: **üç P0'ın üçü de birer lokal düzeltme.** Toplam ~120 satır kod değişikliğiyle çekirdek döngü çalışır hale geliyor.

---

## 1. Erken Oyun Pacing Analizi (Gün 1 — Dede Mirası & İlk 3 Araç)

### 1.1 Başlangıç Sermayesi

| Değer | Kaynak | Not |
|---|---|---|
| ₺75.000 | `dealership_model.dart:219` | Fiilen kullanılan |
| ₺50.000 | `game_constants.dart:22` (`startingBalance`) | **Ölü sabit** — hiçbir yerde okunmuyor |
| ₺50.000 | `dealership_model.dart:554` (`fromJson` fallback) | Bozuk kayıt yüklenirse oyuncu ₺25.000 kaybeder |
| 3 slot | `dealership_model.dart:221` | `fromJson` fallback'i **4** (`:556`) — tutarsız |

**Bulgu:** Üç ayrı yerde üç farklı başlangıç değeri var. Tek doğruluk kaynağı yok.

### 1.2 ₺75.000 Yeterli mi? — Hayır, ama görünenden farklı bir nedenle

Pazar üretimi (`market_engine.dart:228`): `askingPrice = estimatedRealValue × (0.70–1.30)`, taban ₺50.000. Segment taban değerleri: ekonomi ₺350k, halk ₺480k, premium ₺1.1M.

**Gerçek fiyat aralığı ≈ ₺83.000 – ₺400.000+.** Oyuncu ₺75.000 ile pazardan **hemen hiçbir şey alamaz.** Bu aslında *doğru bir tasarım kararı* — oyuncuyu miras aracı satmaya zorlar. Ancak oyun bunu hiçbir yerde söylemiyor; oyuncu Pazar'a girip 15 ilanın tamamının kırmızı/pasif olduğunu görüyor. Bu bir **öğretim boşluğu**, denge sorunu değil.

### 1.3 Miras Aracı Ekonomisi (Doğrulanmış Hesap)

`Tofaşk Hacı Murat 124`, `baseMarketValue = 240.000`, `isRare = true` (`dealership_model.dart:185-216`).

`estimatedRealValue` formülü (`car_model.dart:75-99`):

```
factor = (motor/100)×0.4 + (şanzıman/100)×0.3
       + clamp(1.0 − hasarlıParçaSayısı×0.08, 0.1, 0.3)   ← BOZUK TERİM
       + temizlik bonusu + detay opsiyonları + (rare ? 0.15 : 0)
```

| Aşama | Maliyet | Motor/Şanz. | factor | Araç Değeri | Marjinal Kazanç |
|---|---|---|---|---|---|
| Başlangıç | — | 40 / 50 | 0,76 | **₺182.400** | — |
| Motor rektifiye (Kalfa) | ₺18.000 | 100 / 100 | 1,15 | **₺276.000** | **+₺93.600** ✅ |
| Yıkama + Cila | ₺1.100 | 100 / 100 | 1,23 | **₺295.200** | **+₺19.200** ✅ |
| **5 kaporta parçası onarımı** | **₺29.500** | 100 / 100 | **1,23** | **₺295.200** | **₺0** ❌ |

**Optimal Gün 1 oyunu:** ₺19.100 harca → ₺295.200'e sat → net **+₺276.100**.
**Tutorial'ın öğrettiği oyun:** ₺48.600 harca → ₺295.200'e sat → net **+₺246.600**.

Oyun, kendi öğreticisini takip eden oyuncuyu **₺29.500 cezalandırıyor.** Detaylı analiz → **P0-1**.

### 1.4 Level 1 → 2 Darboğazı

Gereken: **1.000 XP** (`player_skills.dart:23-40`, `requiredXpForLevel(1) = 1000`).

| XP Kaynağı | Miktar | Durum |
|---|---|---|
| Miras aracı satışı (`100 + kâr/1000`) | ~395 | ✅ |
| Motor onarımı / yıkama / detay | ~65 | ✅ |
| İlk araç alımı | 50 | ✅ |
| **"Dede Mirası" görev ödülü** | **250** | ❌ **Alınamıyor (P0-2)** |
| **Gün 1 gerçekleşen toplam** | **~510** | **Hedefin %51'i** |

Oyuncu Level 2'ye ulaşmak için **iki tam araç döngüsü** çevirmek zorunda. Teklif bekleme süresi ortalama ~6,7 dakika (bkz. §2.1) olduğundan bu **25–40 dakikalık** bir tırmanış.

Ve ödülü şu: **günlük sabit gider ₺500 → ₺4.500 (9×).** İlerleme, oyuncuya kendini bir ceza olarak sunuyor → **P0-3**.

### 1.5 Kilit Şeması — Sağlıklı

`dealership_model.dart:89-122`. Lv1: pazar/showroom/ekspertiz/yıkama. Lv2: atölye/tuning/personel/geçmiş. Lv3: açık artırma/finans/borsa. Lv4: hurdalık/kiralama/karaborsa/yan işletmeler/şubeler.

Atölye Lv2 gerektiriyor ama `unlockedBuildings` başlangıçta `{'/marketplace', '/workshop'}` içerdiği için (`:477`) tutorial akışı kırılmıyor. **Bu doğru yapılmış.** Kilit sırası mantıklı, değişiklik gerektirmiyor.

---

## 2. Çekirdek Oynanış Döngüsü & Sürtünme Noktaları

### 2.1 Downtime: Oyunun En Büyük Etkileşimsizlik Kaynağı

`game_time_mixin.dart:24-39`:

```dart
Timer.periodic(const Duration(seconds: 60), (timer) {
  if (timer.tick % 2 == 0) advanceGameDay();          // 1 oyun günü = 120 sn
  double dayFactor = 0.8 + (random.nextDouble() * 0.4);
  if (state.ownedCars.isNotEmpty && random.nextDouble() < (0.15 * dayFactor)) {
    triggerOrganicOffers();                            // dakikada tek teklif, tek araca
  }
});
```

| Metrik | Değer | Değerlendirme |
|---|---|---|
| Teklif olasılığı | %15 / dakika | İlk teklif için ortalama bekleme **6,7 dakika** |
| Tetikleme başına teklif | **1 adet, tek araç** | 3 araç ilandaysa araç başına **~20 dakika** |
| Teklif ömrü | 12 **gerçek saat** (`offer_model.dart:33`) | Aciliyet hissi sıfır — FOMO mekaniği ölü |
| Oyuncunun bekleme sırasında yapabileceği | Doping (₺2.500, araç başına 1 kez) | Tek etkileşimli seçenek |

Bekleme ekranında yapacak *hiçbir şey yok.* Tycoon türünde bu, oturum uzunluğunu en çok kısaltan tek faktördür → **P1-2**.

### 2.2 Offline İlerleme Fiilen Yok

`offline_progression.dart:25`:

```dart
int potentialOffers = (elapsedMinutes / minutesPerOffer).floor().clamp(1, 5);
```

- 30 dakika sonra dönen oyuncu: **5 teklif.** 8 saat sonra dönen oyuncu: **5 teklif.** Geri dönmenin ödülü yok.
- `simulatedEarnings: 0.0` (`:47`) — offline hiçbir gelir yok.
- `advanceGameDay` sadece uygulama açıkken çalışıyor → **yan işletme "pasif geliri" fiilen aktif gelir.** Ekonominin tamamı uygulama kapanınca donuyor.

Bu, tür beklentisini tersine çeviriyor ve D1/D7 retention'ın temel kancasını yok ediyor → **P1-2**.

### 2.3 Yan Döngüler Ana Galeriyi Gölgeliyor mu? — Evet, ~10× ile

`side_business_model.dart:112-136` formülü ve `dealership_model.dart:273-471` verileriyle hesaplanan tam kurulu pasif gelir:

| İşletme | Lv1 Baz | + Yükseltmeler | Günlük Toplam |
|---|---:|---:|---:|
| sb_1 Otomat | 450 | 2.650 | 3.100 |
| sb_2 Oto Yıkama | 1.400 | 12.750 | 14.150 |
| sb_3 Reklam Panosu | 2.800 | 27.150 | 29.950 |
| sb_4 Çekici Filosu | 5.200 | 51.000 | 56.200 |
| sb_5 Aksesuar Store | 2.500 | 21.150 | 23.650 |
| sb_6 Ekspertiz İst. | 4.200 | 34.650 | 38.850 |
| sb_7 Kiralama | 7.800 | 74.100 | 81.900 |
| sb_8 EV Şarj | 10.500 | 98.400 | 108.900 |
| sb_9 Kurumsal Eksp. | 22.500 | 66.000 | 88.500 |
| sb_10 Yedek Parça | 42.000 | 114.600 | 156.600 |
| sb_11 Wrap Stüdyo | 95.000 | 231.000 | 326.000 |
| **TOPLAM (Lv1)** | | | **~₺928.000/gün** |
| **TOPLAM (Lv5 + müdür)** | | | **~₺1.300.000/gün** |

1 oyun günü = 120 saniye → **30 gün/saat**.

- **Pasif gelir: ~₺39.000.000 / gerçek saat**
- **Ana döngü geliri:** araç başına ~₺275.000 kâr, döngü ~10 dk → **~₺1.650.000 / saat**
- **Oran: 23×**

Toplam yatırım (işletme + yükseltme) ≈ ₺25M → **amortisman süresi ~40 dakika.** Ayrıca `effectiveDailyIncome` `clamp(0.0, ∞)` ile korunuyor (`:135`) — yan işletme **hiçbir koşulda zarar edemez.** Risk yok, tavan yok, karar yok.

**Ters ölçekleme:** pahalı işletmeler daha *hızlı* amorti oluyor (sb_1: 55 gün; sb_11: 19 gün). Ekonomik olarak doğru hamle, ucuzları tamamen atlayıp doğrudan en pahalıya gitmek.

### 2.4 Risk-Free Banka Arbitrajı

| Parametre | Değer | Kaynak |
|---|---|---|
| Mevduat faizi | %0,67 / oyun günü, **bileşik** | `game_time_mixin.dart:304` |
| Varsayılan kredi limiti | **₺15.000.000** | `dealership_model.dart:176` |
| 3 aylık kredi maliyeti | %10 **toplam** (bileşik değil) | `game_finance_mixin.dart:16` |
| Taksit periyodu | 7 oyun günü = **14 gerçek dakika** | `game_time_mixin.dart:126` |

Sömürü: ₺15M kredi çek → tamamını mevduata yatır → 21 oyun gününde (42 dk) mevduat `1,0067²¹ = 1,1506` → **₺17.259.000**. Kredi geri ödemesi ₺16.500.000. **Net kâr ₺759.000, oynanış gerektirmiyor, risk sıfır.** Döngü sınırsız tekrarlanabilir. Mevduat tek başına bile saatte **+%22,2 bileşik** kazandırıyor.

---

## 3. Seviye Eğrisi & XP / Ödül Enflasyonu

### 3.1 XP Kaynak Envanteri ve Sömürü

| Eylem | XP | Maliyet | XP/₺ |
|---|---:|---:|---|
| **Hisse alımı** (`game_market_mixin.dart:162`) | **10** | ~₺24,55 (HURD, 1 lot) | **0,41** |
| **Hisse satışı** (`:199`) | **10** | ~₺0,05 komisyon | **~200** |
| Karaborsa aracı (`:722`) | 200 | ₺1,2M+ | 0,00017 |
| Araç satışı (`:379`) | 100 + kâr/1000 | — | — |
| Hurdalık pert alımı (`:654`) | 120 | ₺140.000 | 0,00086 |

**Kritik sömürü:** `buyStock` / `sellStock` her çağrıda 10 XP veriyor, **hiçbir limit yok.** En ucuz hisse ₺24,50. 100 al + 100 sat = **2.000 XP** karşılığında yaklaşık **₺100 komisyon.** Bu, Level 3'ün (2.250 XP) tamamını ~5 dakikalık dokunuşla, cebe zarar vermeden açar.

Bu sömürü tek başına zararsız olsa iyi olurdu — ama seviye, sabit gideri tetiklediği için oyuncuyu farkında olmadan iflasa sürüklüyor (§3.2).

### 3.2 Seviye = Ceza (P0-3'ün Çekirdeği)

`game_time_mixin.dart:51-58`:

```dart
double propertyDailyBurn = 500.0;
if (state.level == 2)      propertyDailyBurn = 4500.0;
else if (state.level == 3) propertyDailyBurn = 32000.0;
else if (state.level >= 4) propertyDailyBurn = 240000.0;
```

| Seviye | Gider/gün (+₺150 vergi) | **Gider / gerçek saat** | Lv1'e göre |
|---|---:|---:|---:|
| 1 | ₺650 | ₺19.500 | 1× |
| 2 | ₺4.650 | **₺139.500** | **7,2×** |
| 3 | ₺32.150 | **₺964.500** | **49×** |
| 4 | ₺240.150 | **₺7.204.500** | **369×** |

Seviye `addXP` içinden otomatik yükseliyor (`game_core_provider.dart:162-173`) — oyuncunun onayı, uyarısı, geri dönüşü yok. Bir oyuncu birkaç hisse alarak Level 3'e sıçrayabilir ve saatte ₺964.500 gidere mahkûm olur; oysa Lv4 gelir kaynakları (yan işletmeler) hâlâ kilitlidir.

### 3.3 İflas Soft-Lock

`game_time_mixin.dart:222-226` — tek otomatik kurtarma:

```dart
if (newBalance < 0 && currentCars.isEmpty && state.pendingOrders.isEmpty) {
  newBalance = 25000.0;
  updatedLoans.clear();
}
```

Koşul **garajın tamamen boş olmasını** şart koşuyor. En yaygın iflas senaryosu ise şudur: oyuncunun elinde satılmayan 1 araç var, bakiye eksiye düştü. Garaj boş değil → kurtarma tetiklenmiyor → bakiye her 2 dakikada daha da düşüyor → **kalıcı soft-lock.**

Daha kötüsü: kurtarma fonksiyonları **yazılmış ama hiçbir ekrana bağlanmamış:**

- `claimEmergencyBailout()` — `game_inventory_mixin.dart:569` — ₺50.000 can suyu. **UI referansı: 0**
- `doDailyScrapyardSideGig()` — `:580` — günlük ₺5.000 çıraklık. **UI referansı: 0**

(Doğrulama: `grep -rn "claimEmergencyBailout\|doDailyScrapyardSideGig" lib` → yalnızca tanım satırları.)

Ayrıca `claimEmergencyBailout`'un koşulu da hatalı: `if (balance > 15000 && ownedCars.isNotEmpty) return false;` — garaj boşken ikinci koşul `false` olduğu için **AND** hiç sağlanmaz ve fonksiyon **sınırsız ₺50.000 + 100 XP** dağıtır. UI'a bağlanmadan önce mutlaka düzeltilmeli.

### 3.4 PlayerSkills: 5 Yetenekten 2'si Tamamen Ölü

| Yetenek | Etkisi | Fiilen Bağlı mı? |
|---|---|---|
| `negotiationLevel` | Pazarlık kabul olasılığı +%3/sv | ✅ `negotiation_engine.dart:256` |
| `reputation` | Offline teklif hızı/limiti | ✅ `offline_progression.dart:22-33` |
| `financeSense` | `financeInterestDiscount`, `chequeRiskReduction` | ❌ **Hiçbir yerde okunmuyor** |
| `marketSense` | `marketingDopingBonus` | ❌ **Hiçbir yerde okunmuyor** |
| `eyeForDetail` | `expertiseCostDiscount` | ❌ **Ekspertiz zaten ücretsiz** (§3.5) |

`ExpertiseEngine.detectHiddenTampering()` (`expertise_engine.dart:9`) hiçbir yerden çağrılmıyor. Karakter Gelişimi ekranı bu bonusları yüzde olarak gösteriyor (`character_growth_screen.dart:181`) — oyuncu var olmayan bir güç için yetenek puanı harcıyor.

### 3.5 Ekspertiz Ücretsiz → Risk Sistemi Ölü

`expertise_screen.dart:114-127`: buton "EKSPERTİZ YAPTIR (₺1.500)" yazıyor, `game.balance < 1500` ile kilitleniyor — ama **para hiç düşülmüyor.** `markExpertiseCompleted` yalnızca `marketProvider` üzerindeki liste flag'ini değiştiriyor (`market_provider.dart:53-60`).

Sonuç zinciri:
- `RiskEngine.evaluateUninspectedPurchaseRisk` (%30 tuzak şansı) **hiç tetiklenmez** — ekspertiz bedava olduğu için rasyonel oyuncu her zaman yaptırır.
- `GameConstants.expertiseBaseCost` ölü sabit.
- `eyeForDetail` yeteneği anlamsız.
- "Ekspertiz yaptırayım mı?" — oyunun en iyi tasarlanmış risk/ödül kararı — **karar olmaktan çıkıyor.**

### 3.6 Money Sink Envanteri

| Kaynaklar (giren) | Sinkler (çıkan) |
|---|---|
| Araç satışı ✅ | Onarım ✅ |
| Yan işletmeler (23× baskın) ⚠️ | Ekspertiz ❌ (ücretsiz) |
| Mevduat +%22/saat bileşik ⚠️ | Doping ₺2.500 (araç başına 1 kez) |
| Borsa (asimetrik, oyuncu lehine) ⚠️ | Garaj/şube genişletme ✅ |
| Kiralama / çek / senet ✅ | Personel maaşı ✅ |
| Streak ödülü (30k'ya kadar) ✅ | Sabit gider ⚠️ (seçilmeyen, cezalandırıcı) |
| Hikâye kartları ✅ | Tema/dekor mağazası ✅ (kozmetik) |

**Yapısal sorun:** Tek büyük sink (sabit gider) oyuncunun *seçmediği* bir sink. Oyuncunun *istediği için* para harcadığı, kalıcı ve gurur verici bir hedef yok. Bu, geç oyunda heyecan kaybının doğrudan nedeni → **P1-3**.

---

## 4. Retention & Günlük Döngü

| Kanca | Kod | Durum |
|---|---|---|
| Login streak | `psychology_engine.dart:40` (₺1.000→₺30.000) | ✅ Çalışıyor, iyi ölçekleniyor |
| Günlük görev | — | ❌ **Yok.** Oyunda toplam 1 görev tanımlı |
| Hikâyeli karşılaşma | `story_card_model.dart`, 7-21 gün döngüsü | ⚠️ Çalışıyor ama frekans çok düşük |
| Piyasa haberi | `game_time_mixin.dart:272` (5 günde bir) | ⚠️ Rotasyon var, **oynanışa etkisi yok** |
| Başarımlar | `player_achievements.dart` | ⚠️ 11'in 3'ü ulaşılamaz |
| Push / hatırlatma | — | ❌ Yok |

### 4.1 Görev Sistemi Fiilen Yok

Oyunda tanımlı görev sayısı: **1** (`m_heritage_1`, `dealership_model.dart:232-241`). Görev üretimi yapan hiçbir kod yok (`grep "MissionModel("` → yalnızca bu tek örnek). `MissionType.doExpertise` hiçbir yerden ilerletilmiyor.

`dashboard_screen.dart:1374`'teki "Tüm görevler tamamlandı! Yeni görevler yarın gelecek." mesajı **yerine getirilmeyen bir vaat** — yeni görev asla gelmiyor.

### 4.2 Hikâye Kartlarının Ödülleri Homojen

`resolveStoryCard` (`game_time_mixin.dart:349-455`): 8 ödül tipinin **5'i düz nakit** (₺25.000–₺40.000). `viralBuyerOffers` "viral alıcı akını" vaat ediyor ama sadece ₺40.000 veriyor; `partsDiscountCredit` "parça indirimi" diyor ama ₺35.000 nakit veriyor. Anlatı ile mekanik örtüşmüyor — kartların anlatısal değeri boşa gidiyor.

### 4.3 Ulaşılamayan Başarımlar

`_checkAchievementsInternal` (`game_core_provider.dart:106-147`) yalnızca 8 ID'yi kontrol ediyor. Hiçbir yerden tetiklenmeyenler:

| ID | Ödül | Durum |
|---|---|---|
| `expert_master` | ₺3.000 + 75 XP + 1 SP | ❌ Ulaşılamaz |
| `restoration_5` | ₺25.000 + 500 XP + 2 SP | ❌ Ulaşılamaz |
| `restoration_king` | ₺7.500 + 150 XP + 1 SP | ⚠️ Koşul `engineCondition == 100.0 && isDetailedCleaned` — float eşitliği kırılgan |

Ters yönde: `checkAchievement('garage_expand')` ve `checkAchievement('first_scrap')` çağrılıyor ama bu ID'ler `initialList`'te yok → sessiz no-op.

**Kilitli kalan toplam:** ₺28.000 + 575 XP + 3 yetenek puanı.

---

# P0 — Kritik (Hemen Yapılmalı)

## P0-1 · Kaporta Restorasyonu Araç Değerini Hiç Artırmıyor

**Dosya:** `lib/data/models/car_model.dart:83`
**Etki:** Çekirdek döngünün "Atölye" ayağı ekonomik olarak tamamen ölü. Tutorial'ın 1–9. adımları oyuncuya zararlı bir davranış öğretiyor.

**Kök neden:**

```dart
factor += (1.0 - (changedOrDamagedCount * 0.08)).clamp(0.1, 0.3);
```

`clamp`'in **üst sınırı 0,3.** İfade `1.0 - 0.08n ≤ 0.3` olması için `n ≥ 8,75`, yani **9 veya daha fazla** hasarlı parça gerekiyor.

- Miras aracının **5** kaporta parçası var → terim her zaman `0,3`.
- Pazar araçlarının 12 parçası var (`market_engine.dart:126-139`), hasar olasılığı parça başına ~%25 → ortalama **3** hasarlı parça → terim yine her zaman `0,3`.

Yani `changedOrDamagedCount` değişkeni **pratikte hiçbir zaman sonuca etki etmiyor.** `partConditions` haritası ise `estimatedRealValue` tarafından hiç okunmuyor.

**Doğrulanmış maliyet:** Miras aracında 5 parça onarımı ₺29.500 → değer artışı ₺0.

**Çözüm:**

```dart
// car_model.dart — hasarlı parça oranına göre ölçeklenen, parça sayısından bağımsız ceza
final totalParts = expertise.bodyParts.length;
final damageRatio = totalParts == 0
    ? 0.0
    : expertise.bodyParts.values.where((s) =>
        s == PartStatus.changed || s == PartStatus.damaged).length / totalParts;
final paintedRatio = totalParts == 0
    ? 0.0
    : expertise.bodyParts.values.where((s) => s == PartStatus.painted).length / totalParts;

// Tavan / Şasi Türk pazarında ağır değer kaybı yaratır
double structuralPenalty = 0.0;
for (final key in const ['Tavan', 'Şasi/Podye']) {
  final st = expertise.bodyParts[key];
  if (st == PartStatus.changed || st == PartStatus.damaged) structuralPenalty += 0.06;
  else if (st == PartStatus.painted) structuralPenalty += 0.03;
}

// 0.30 = kusursuz kaporta tavanı; hasar oranı arttıkça 0.05'e kadar düşer
factor += (0.30 - damageRatio * 0.25 - paintedRatio * 0.10 - structuralPenalty)
            .clamp(0.05, 0.30);
```

**Doğrulama:** Miras aracının 5 parçası onarıldığında `damageRatio` 0,60→0, `paintedRatio` 0,40→0 → terim 0,11 → 0,30 = **+0,19 factor = +₺45.600.** ₺29.500 maliyete karşı **+₺16.100 net kâr.** Kaporta onarımı artık kârlı ama motordan (%93.600) daha zayıf — doğru öncelik hiyerarşisi kurulmuş olur.

**Ek not:** `ExpertiseEngine.evaluateVehicle` (`expertise_engine.dart:28-39`) hasarı zaten doğru hesaplıyor. Ekspertiz raporu "D (Ağır Hasarlı)" derken satış değeri değişmiyordu — iki motor arasındaki bu tutarsızlık da bu düzeltmeyle kapanıyor.

---

## P0-2 · Görev Ödülü Alınamıyor + Görev Havuzu Boş

**Dosyalar:** `lib/presentation/providers/game/game_core_provider.dart:200-213`, `lib/presentation/providers/game/game_market_mixin.dart:542-561`
**Etki:** İlk görevin ₺35.000 + 250 XP ödülü kalıcı olarak erişilemez. Level 1→2 XP bütçesinin %25'i kayıp. "AL" butonu sessizce hiçbir şey yapmıyor.

**Kök neden — iki fonksiyon `isCompleted` alanını çelişkili kullanıyor:**

```dart
// game_core_provider.dart:205-207 — "hedefe ulaşıldı" anlamında set ediyor
return m.copyWith(
  currentProgress: newProgress,
  isCompleted: newProgress >= m.targetGoal,   // → true
);

// game_market_mixin.dart:547 — "ödül alındı" anlamında okuyor
if (mission.currentProgress < mission.targetGoal || mission.isCompleted) return false;
//                                                  ^^^^^^^^^^^^^^^^^^ her zaman true → her zaman false döner
```

UI (`dashboard_screen.dart:1445-1456`) `progressRatio >= 1.0` olunca butonu gösteriyor ama dönüş değerini kontrol etmiyor → **sessiz başarısızlık.**

**Çözüm — 3 parça:**

**(a)** `MissionModel`'e ayrı bir `isClaimed` alanı ekle (`mission_model.dart`), `toJson`/`fromJson`/`copyWith`'e dahil et. `isCompleted` = hedefe ulaşıldı, `isClaimed` = ödül alındı.

```dart
// game_market_mixin.dart:547
if (mission.currentProgress < mission.targetGoal || mission.isClaimed) return false;
final updatedMission = mission.copyWith(isClaimed: true);
```

**(b)** UI'da dönüş değerini kullan ve buton durumunu `isClaimed`'e bağla:

```dart
// dashboard_screen.dart:1454
final ok = ref.read(gameProvider.notifier).claimMissionReward(mission.id);
if (ok) {
  NotificationService.showSuccess(context,
    'Görev ödülü alındı: +₺${mission.rewardMoney} • +${mission.rewardXP} XP');
} else {
  NotificationService.showError(context, 'Bu ödül zaten alınmış.');
}
```

**(c)** `MissionFactory` ekle — `lib/domain/usecases/mission_factory.dart` (yeni dosya, harici paket yok). Alınmış görevler `advanceGameDay` içinde havuzdan çıkarılıp yerine seviyeye uygun yenisi üretilir. `MissionType.doExpertise` için `ExpertiseScreen`'e `updateMissionProgress(MissionType.doExpertise, 1)` çağrısı eklenir (aynı zamanda `expert_master` başarımını da çözer).

---

## P0-3 · Ekonomik Ölüm Sarmalı: Cezalandırıcı Seviye Gideri + İflas Soft-Lock

**Dosyalar:** `lib/presentation/providers/game/game_time_mixin.dart:51-58, 222-226`, `lib/presentation/providers/game/game_inventory_mixin.dart:569-577`
**Etki:** İlerleme oyuncuyu cezalandırıyor; iflas edilen durumda geri dönüş yok.

**Üç ayrı kusur:**

**(a) Sabit gider XP seviyesine bağlı.** Lv1→Lv4 arasında 369× artış, oyuncunun onayı olmadan (§3.2). Üstelik `buyStock` XP sömürüsüyle (§3.1) bir oyuncu bunu kazara tetikleyebilir.

**(b) Otomatik kurtarma yanlış koşula bağlı.** `newBalance < 0 && currentCars.isEmpty` — en yaygın iflas senaryosunda (satılmayan 1 araç + eksi bakiye) tetiklenmiyor.

**(c) İki kurtarma fonksiyonu hiçbir UI'a bağlı değil** ve biri sınırsız para veren bir hataya sahip (§3.3).

**Çözüm:**

**(a) Gideri seviyeden ayır, satın alınan mülke bağla.** `unlockedBuildings` içinde kademe anahtarları (`property_tier_2` vb.) tut; gider bunlardan hesaplansın:

```dart
// game_time_mixin.dart — seviye yerine SATIN ALINMIŞ mülk kademesine bağla
double propertyDailyBurn = 500.0;
if (state.unlockedBuildings.contains('property_tier_4'))      propertyDailyBurn = 240000.0;
else if (state.unlockedBuildings.contains('property_tier_3')) propertyDailyBurn = 32000.0;
else if (state.unlockedBuildings.contains('property_tier_2')) propertyDailyBurn = 4500.0;
```

Böylece gider artışı oyuncunun **bilinçli kararı** olur, otomatik ceza olmaktan çıkar. (Bu, P1-3'ün prestij sistemiyle doğrudan birleşir.) Ayrıca kademeler arası boşluğu yumuşat: 500 → 3.000 → 12.000 → 45.000 (369× yerine **90×**).

**(b) Kurtarma koşulunu likidite bazlı yap:**

```dart
final liquidatableValue = currentCars.fold<double>(
    0.0, (sum, c) => sum + c.estimatedRealValue);
if (newBalance < 0 && (liquidatableValue + newBalance) < 25000) {
  newBalance = 25000.0;
  updatedLoans.clear();
  // recentEvents'e "Devlet Esnaf Destek Kredisi" olayı ekle — oyuncu ne olduğunu görsün
}
```

**(c) `claimEmergencyBailout` koşulunu düzelt ve UI'a bağla:**

```dart
// game_inventory_mixin.dart:570 — OR olmalı, AND değil
final totalAssets = state.balance +
    state.ownedCars.fold<double>(0.0, (s, c) => s + c.estimatedRealValue);
if (totalAssets > 15000) return false;
```

`doDailyScrapyardSideGig`'i Dashboard'a "Hurdalıkta Çıraklık — Günde 1 kez ₺5.000" kartı olarak ekle; bakiye ₺20.000'in altına düştüğünde öne çıkar.

---

## P0.5 — Doğrulanmış Diğer Kritik Bulgular

P0 üçlüsünün dışında kalan, tek satırlık düzeltmelerle kapanan doğrulanmış defektler:

| # | Bulgu | Konum | Etki | Düzeltme |
|---|---|---|---|---|
| 1 | Ekspertiz ücreti hiç düşülmüyor; RiskEngine ölü | `expertise_screen.dart:120-127` | Oyunun en iyi risk kararı yok oluyor | `deductBalance(1500 × (1 − skills.expertiseCostDiscount))` çağır |
| 2 | `buyStock`/`sellStock` sınırsız XP farmı | `game_market_mixin.dart:162, 199` | ~₺100 ile 2.000 XP | XP'yi işlem hacmine bağla: `addXP((grossCost / 50000).clamp(0, 25).round())` |
| 3 | Pazar listesi sınırsız büyüyor | `market_provider.dart:49` + `market_engine.dart:71` | `count` parametresi yok sayılıp her seferinde 8–15 ilan ekleniyor; 1 saatte ~150 ilan | `generateRandomListings` içinde `actualCount` yerine `count` kullan |
| 4 | Seviye atlayınca pazar sıfırlanıyor | `market_provider.dart:9` | `ref.watch(...level)` provider'ı yeniden kurar → tüm ilanlar + ödenen ekspertizler silinir | `ref.read` + manuel `refreshMarket()` |
| 5 | Araç ilandan geri çekilemiyor | `car_model.dart:186` | `customListingPrice ?? this.customListingPrice` → `null` set edilemez | `copyWith`'e `bool clearListingPrice = false` ekle |
| 6 | 3 başarım ulaşılamaz (₺28.000 + 575 XP + 3 SP) | `game_core_provider.dart:106-147` | Ödül kilitli | `expert_master`, `restoration_5` koşullarını ekle; sayaç alanları gerekir |
| 7 | Banka arbitrajı (§2.4) | `game_time_mixin.dart:304` | Risk-free sonsuz para | Mevduat faizini %0,67 → **%0,12**/gün; `bankCreditLimit` varsayılanını ₺15M → **₺250.000** |
| 8 | Hile butonları production ayarlarında | `settings_screen.dart:279, 294` | +₺100M ve Lv4 tek dokunuşla | `if (kDebugMode)` ile sarmala |
| 9 | Timer state yüklenmeden başlıyor | `game_core_provider.dart:29-32` | `_loadState()` async; `startPeriodicOrganicOfferTimer()` initial state üzerinde çalışabiliyor | Timer'ı `_loadState()`'in `await` sonrasına taşı |

---

# P1 — Önemli (İlk Güncelleme): Tutundurmayı 2× Artıracak 3 Mekanik

## P1-1 · Günlük Görev Rotasyonu + "Aranan Araç" Sözleşmeleri

**Sorun:** Oyunda 1 görev var, günlük döngü kancası yok (§4.1).

**Mekanik:**

**(a) Günlük Görev Kuşağı** — Her oyun gününün başında 3 görev üretilir; oyuncu seviyesine göre ölçeklenir. Mevcut `MissionModel` + `MissionType` altyapısı zaten yeterli, yeni model gerekmiyor.

```
"Bugün 2 araç ekspertizden geçir"        → doExpertise  · ₺8.000 + 120 XP
"Kaportacıda 3 parça onart"              → repairParts  · ₺12.000 + 150 XP
"Toplam ₺150.000 kâr et"                 → earnProfit   · ₺20.000 + 250 XP
```

Kritik tasarım kararı: **görevler çekirdek döngüyü hedeflemeli** (ekspertiz + onarım + satış), yan döngüleri değil. Bu, P0-1 ile birlikte oyuncuyu ana galeriye geri çeker.

**(b) "Aranan Araç" Sözleşmeleri** — Bir NPC müşteri belirli bir profil ister: *"2015+ bir SUV arıyorum, tramersiz olsun, ₺1.200.000'e kadar çıkarım. 5 gün süre."* Oyuncu Pazar'da o profili avlar, alır, onarır, teslim eder → **piyasa değerinin %125'i + 300 XP.**

Bu, Pazar taramasına *amaç* katar. Şu an oyuncu pazara "ucuz bir şey var mı" diye bakıyor; sözleşmeyle "şu spesifik aracı arıyorum" diye bakar. Aynı ekran, çok daha yüksek etkileşim.

**Uygulama:** `lib/domain/usecases/mission_factory.dart` (yeni) + `DealershipModel`'e `activeContracts` alanı. `advanceGameDay` içinden tetiklenir. Harici paket yok.

---

## P1-2 · Randevu Kuyruğu: Downtime'ı Karara Dönüştür

**Sorun:** Ortalama 6,7 dakika ölü bekleme; offline dönüş ödülsüz (§2.1, §2.2).

**Mekanik — üç katman:**

**(a) Görünür randevu kuyruğu.** Rastgele %15/dakika yerine, ilandaki her araç için deterministik ve **görünen** bir sayaç: *"Sonraki Ziyaretçi: 01:47"*. Bekleme aynı uzunlukta kalsa bile, görünür sayaç belirsizliği ortadan kaldırır — oyuncu ne zaman döneceğini bilir. Süre şu faktörlerle kısalır:

| Faktör | Etki |
|---|---|
| `skills.reputation` | −%8 / seviye |
| `isDoped` | −%40 |
| Satış Danışmanı personeli | −%25 |
| İlan fiyatı < piyasa değeri | −%30 |

**(b) Bekleme sırasında aktif eylem.** Oyuncu bekleme yerine seçim yapabilsin: *İlanı Öne Çıkar* (₺1.500, sıradaki ziyaretçiyi hemen çağırır), *Sosyal Medya Paylaşımı* (ücretsiz, 4 saatte 1, −%50 bekleme), *Fiyat Kır* (bekleme yarıya iner, teklif tavanı düşer). Böylece ölü zaman bir **kaynak yönetimi kararına** dönüşür.

**(c) Gerçek offline ilerleme.** `OfflineProgression`'daki `clamp(1, 5)` limitini kaldır; geçen gerçek süreyi oyun gününe çevirip yan işletme gelirini, sabit gideri ve maaşları **offline da işlet** (maksimum 12 saat birikim). Dönen oyuncu bir **"Yokluğunda Neler Oldu"** özet ekranıyla karşılaşır: kaç ziyaretçi geldi, kaç teklif birikti, ne kadar pasif gelir düştü, hangi masraflar çıktı.

Bu üçlü, tycoon türünün temel geri-dönüş kancasını kurar ve şu anda tamamen eksik.

---

## P1-3 · Prestij & Koleksiyon: Oyuncunun *İstediği* Money Sink

**Sorun:** Tek büyük sink oyuncunun seçmediği sabit gider; kalıcı, gurur verici bir hedef yok (§3.6).

**Mekanik:**

**(a) Galeri Prestij Kademeleri** — P0-3(a) ile doğrudan birleşir. Sabit gider artık seviyeden değil, **satın alınan mülkten** gelir:

| Kademe | Maliyet | Slot | Günlük Gider | Kalıcı Bonus |
|---|---:|---:|---:|---|
| Sanayi Dükkânı | başlangıç | 3 | ₺500 | — |
| Cadde Üstü Galeri | ₺450.000 | 6 | ₺3.000 | Ziyaretçi hızı +%15 |
| Plaza Showroom | ₺2.800.000 | 10 | ₺12.000 | Teklif tavanı +%8 |
| Otomotiv Kalesi | ₺18.000.000 | 15 | ₺45.000 | Nadir araç oranı +%20 |

Oyuncu "hazır mıyım?" diye düşünür ve gideri **bilinçli olarak üstlenir.** Ceza, hedefe dönüşür.

**(b) Koleksiyon Vitrini** — Nadir araçlar (`isRare`) vitrine kilitlenebilir: **kalıcı olarak satılamaz hale gelir** ve karşılığında kalıcı bir pasif bonus verir (itibar +5, ziyaretçi hızı +%3 vb.). Bu, ekonomiden **gerçek para çeken** tek mekanik olur — çünkü araç geri dönmez. Ayrıca `Tofaşk Hacı Murat 124`'e duygusal bir final verir: oyuncu dedesinin arabasını satmak yerine vitrine koyabilir.

**(c) Yan işletme dengelemesi** (kritik):

```dart
// side_business_model.dart — mevcut clamp(0.0, ∞) her koşulda kâr garantiliyor
// Talep dalgalanması ekle: piyasa haberleri ve itibar geliri etkilesin
final demandFactor = 0.65 + (marketDemandIndex * 0.55);   // 0.65 – 1.20
final net = grossDailyIncome * demandFactor - dailyMaintenanceExpense;
return net;   // clamp KALDIRILDI — kötü günlerde zarar mümkün olmalı
```

Ayrıca ters ölçeklemeyi düzelt: yükseltme maliyeti `cost × 1.20 × level` yerine `cost × 1.20 × level²` — üst kademeler amortismanı hızlandırmasın (§2.3). Hedef: pasif gelir, ana döngünün **%35–45'i** olsun, %2.300'ü değil.

---

# P2 — Cilalama (QoL)

**Geri bildirim & şeffaflık**
1. `claimMissionReward`, `buySideBusiness`, `boostListingDoping`, `upgradeSkill` gibi `bool` dönen ~20 fonksiyonun çağrı yerlerinde dönüş değeri kontrol edilmiyor — başarısız işlemler sessizce yutuluyor. Tümüne `NotificationService` geri bildirimi ekle. (Şu an oyuncu butona basıp hiçbir şey olmadığını görüyor ve bunu bug sanıyor — haklı.)
2. Değer değişimlerinde **öncesi/sonrası** göster: her onarım butonunda `₺182.400 → ₺276.000 (+₺93.600)`. Oyuncunun onarım kararını bilinçli vermesi için tek gereken bu.
3. Sabit gider, vergi ve maaşları Dashboard'da **"Günlük Nakit Akışı"** kartında topla: `Gelir ₺X · Gider ₺Y · Net ₺Z`. Şu an para nereye gidiyor görünmüyor.
4. Seviye atlarken kutlama ekranı: hangi özellikler açıldı, gider ne kadar arttı, ne yapmalı.

**Pazar & Envanter**
5. Pazar'da filtre/sıralama: bütçeye göre, segmente göre, "alabileceklerim" toggle'ı. 15 ilanın 14'ünün pasif olduğu ekran demoralize edici.
6. İlan kartında **tahmini kâr marjı** rozeti (istek fiyatı vs. `estimatedRealValue`).
7. Showroom'da araçları duruma göre sırala: *Onarım Bekliyor → İlana Hazır → İlanda → Teklif Var.*
8. Toplu işlem: "Tüm araçları yıka" tek dokunuş.

**Pazarlık & Satış**
9. Pazarlık sayfasında `maxCounters` (3) sayacını görünür yap — oyuncu kaç hakkı kaldığını bilmiyor.
10. Teklif tipi karşılaştırması: nakit ₺X *şimdi* vs. senet ₺Y (`paymentProbability` ile beklenen değer). Şu an oyuncu %15 batma riskini göremiyor.
11. Kabul edilen teklifte kâr/zarar animasyonu ve satış geçmişine yumuşak geçiş.

**Ekonomi okunabilirliği**
12. Yan işletme kartında **amortisman süresi** göster: "Yatırımını 19 günde çıkarır."
13. Borsa ekranında portföy toplam kâr/zararı — şu an tek tek hesaplanıyor.
14. Kredi çekmeden önce toplam geri ödemeyi ve taksit takvimini onay ekranında göster.

**Hijyen**
15. `GameConstants.startingBalance`, `expertiseBaseCost`, `repairCostMultiplier`, `detailingCost` sabitleri hiçbir yerde okunmuyor — ya bağla ya sil. Şu an sahte bir tek-doğruluk-kaynağı izlenimi veriyorlar.
16. Başlangıç değerlerini tek yerde topla (`initial()` ve `fromJson` fallback'leri şu an çelişiyor: ₺75.000/₺50.000, 3 slot/4 slot).
17. `salesHistory`'deki iki sahte açılış kaydı (`sale_init_1/2`) `totalProfit` ve `carsSold` ile tutarsız — oyuncu "0 satış" görürken geçmişte 2 satış duruyor.

---

# Aksiyon Planı — `/plan` ile Uygulanabilir Yol Haritası

> Sıralama bilinçli: her adım bir öncekinin doğrulanabilirliğine dayanıyor. P0'lar bittiğinde oyun oynanabilir; P1'ler bittiğinde tutundurucu olur.

### Sprint 0 — Ekonomi Onarımı (tahmini ~120 satır, en yüksek ROI)

```
1. car_model.dart:83 — estimatedRealValue hasar terimini yeniden yaz (P0-1)
   → Doğrulama: miras aracı 5 parça onarımı sonrası değer ₺295.200 → ₺340.800 olmalı

2. mission_model.dart — isClaimed alanı ekle (+ toJson/fromJson/copyWith)
   game_market_mixin.dart:547 — kontrolü isClaimed'e çevir
   dashboard_screen.dart:1454 — dönüş değerini kontrol et, bildirim göster        (P0-2 a-b)
   → Doğrulama: ilk satış sonrası "AL" → ₺35.000 + 250 XP hesaba geçmeli

3. game_time_mixin.dart:51-58 — gideri unlockedBuildings kademesine bağla
   game_time_mixin.dart:222 — kurtarma koşulunu likidite bazlı yap
   game_inventory_mixin.dart:570 — claimEmergencyBailout koşulunu düzelt (AND→toplam varlık)
                                                                                  (P0-3)
   → Doğrulama: Lv3'e çıkan oyuncunun günlük gideri ₺650'de kalmalı

4. expertise_screen.dart:120 — ekspertiz ücretini gerçekten düş                   (P0.5 #1)
5. market_engine.dart:71 — count parametresini kullan                             (P0.5 #3)
6. settings_screen.dart:279 — hile butonlarını kDebugMode ile sarmala             (P0.5 #8)
```

### Sprint 1 — Sömürü Kapatma & Denge

```
7.  game_market_mixin.dart:162,199 — hisse XP'sini işlem hacmine bağla            (P0.5 #2)
8.  game_time_mixin.dart:304 — mevduat faizi %0,67 → %0,12
    dealership_model.dart:176 — bankCreditLimit ₺15M → ₺250.000                   (P0.5 #7)
9.  side_business_model.dart:132 — clamp'i kaldır, demandFactor ekle
    nextLevelUpgradeCost: cost×1.20×level → cost×1.20×level²                      (P1-3c)
    → Hedef metrik: pasif gelir / ana döngü geliri oranı ≤ 0,45
10. market_provider.dart:9 — ref.watch → ref.read (pazar sıfırlanmasın)           (P0.5 #4)
11. car_model.dart:186 — copyWith'e clearListingPrice ekle                        (P0.5 #5)
12. game_core_provider.dart:106 — expert_master + restoration_5 koşulları         (P0.5 #6)
13. game_core_provider.dart:29 — timer'ı _loadState sonrasına taşı                (P0.5 #9)
```

### Sprint 2 — Görev & Sözleşme Sistemi (P1-1)

```
14. lib/domain/usecases/mission_factory.dart (YENİ)
    - generateDailyMissions(int playerLevel) → List<MissionModel>
    - MissionType.doExpertise dahil 5 tipin tamamı kullanılsın
15. game_time_mixin.dart — advanceGameDay içinde günlük görev rotasyonu
16. expertise_screen.dart — updateMissionProgress(doExpertise, 1) çağrısı
17. DealershipModel — activeContracts alanı + "Aranan Araç" sözleşme akışı
18. Dashboard'da görev kartlarını yenile (kalan süre + ilerleme + AL butonu)
```

### Sprint 3 — Randevu Kuyruğu & Offline (P1-2)

```
19. lib/domain/usecases/visitor_queue_engine.dart (YENİ)
    - Araç başına deterministik nextVisitorAt hesabı
    - Modifikatörler: reputation, isDoped, salesman, fiyat/değer oranı
20. game_time_mixin.dart — %15 rastgele tetiklemeyi kuyruk sistemiyle değiştir
21. Showroom kartlarında geri sayım + "Öne Çıkar / Paylaş / Fiyat Kır" eylemleri
22. offline_progression.dart — clamp(1,5) kaldır; gün ilerlemesi, pasif gelir,
    gider ve maaşları offline işlet (maks. 12 saat)
23. "Yokluğunda Neler Oldu" özet ekranı
```

### Sprint 4 — Prestij & Koleksiyon (P1-3)

```
24. Prestij kademesi satın alma akışı (branch_screen.dart üzerine kur)
25. Koleksiyon Vitrini: isRare araçları kalıcı kilitle + pasif bonus
26. Sabit gideri prestij kademesine tam bağla; kademe aralıklarını yumuşat
```

### Sprint 5 — P2 QoL

```
27. bool dönen tüm fonksiyon çağrılarına bildirim ekle (~20 nokta)
28. Onarım butonlarına öncesi/sonrası değer göstergesi
29. Günlük Nakit Akışı kartı
30. Pazar filtreleri + kâr marjı rozeti
31. Sabit/başlangıç değeri hijyeni (tek doğruluk kaynağı)
```

---

## Doğrulama Metrikleri

Sprint 0 ve 1 sonrasında bu dört sayı ölçülmeli — hepsi ilk oturumun ilk 30 dakikasında gözlemlenebilir:

| Metrik | Şu an | Hedef |
|---|---:|---:|
| Kaporta onarımının değer getirisi | **₺0** | ≥ maliyetin 1,5× |
| Level 1→2 için gereken süre | ~25–40 dk | 12–18 dk |
| Pasif gelir / ana döngü geliri | **23×** | ≤ 0,45× |
| Teklif bekleme süresi (görünür) | 6,7 dk (belirsiz) | 2–4 dk (sayaçlı) |

---

*Bu rapor `lib/` altındaki kaynak kodun statik analizine dayanır. Ekonomi hesapları koddaki formüllerden türetilmiştir; oyun içi telemetri ile doğrulanması önerilir.*
