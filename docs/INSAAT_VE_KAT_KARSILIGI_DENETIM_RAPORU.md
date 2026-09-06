# Galerisinden — Kat Karşılığı Sözleşme & Öz-İnşaat Modülü Derin Denetimi

**Tarih:** 6 Eylül 2026 · **Kapsam:** Sadece rapor, hiçbir dosya değiştirilmedi.
**İncelenen alan:** Arsa → İmar/KAKS tasarımı → Müteahhit kat karşılığı sözleşmesi → Öz-inşaat şantiyesi → Taşeron pazarlığı → Etap yönetimi → Ön satış → Anahtar teslim.

**İncelenen dosyalar:**
`real_estate_construction_screen.dart` (2001), `contractor_negotiation_chat_screen.dart`, `subcontractor_negotiation_chat_screen.dart`, `real_estate_chat_negotiation_engine.dart`, `contractor_negotiation_expansion.dart`, `construction_timeline_engine.dart`, `construction_negative_events_engine.dart`, `zoning_engine.dart`, `game_real_estate_mixin.dart`, `game_time_mixin.dart`, `real_estate_model.dart`.

---

> **Tek cümlelik özet:** Kat karşılığı pazarlığında **pay yüzdesi ters bağlanmış** — oyuncu payını %33'ten %55'e çıkardıkça aldığı daire sayısı %67'den %45'e **düşüyor**. Ve pazarlık ekranından sözleşme imzalamak, oyuncunun az önce Tab 1'de tasarladığı tüm KAKS/tipoloji planını **sessizce çöpe atıyor**.

Bulgular dört grupta: **(A) Kat karşılığı sözleşme**, **(B) Öz-inşaat & taşeron**, **(C) Teslim/finalize**, **(D) İmar & KAKS masası**.

---

# A · KAT KARŞILIĞI MÜTEAHHİT SÖZLEŞMESİ

## A1 · Pay yüzdesi TERS bağlı — iyi pazarlık yapan daha az daire alıyor ⭐⭐ EN KRİTİK

**Dosyalar:** [real_estate_chat_negotiation_engine.dart:370](lib/domain/usecases/real_estate_chat_negotiation_engine.dart:370), [game_real_estate_mixin.dart:798-803](lib/presentation/providers/game/game_real_estate_mixin.dart:798), [real_estate_model.dart:222](lib/data/models/real_estate_model.dart:222)

**Sohbet motorunda sayı = OYUNCUNUN payı.** Açılış repliği net:
```dart
'Biz %$initialShare arsa sahibine, %${100 - initialShare} müteahhide kat karşılığı teklif ediyoruz.'
```
`demandHigherShare` taktiği bunu doğruluyor:
```dart
nextShare += 3;
'Payınızı %$nextShare seviyesine çıkarıyoruz...'
'...arsa payınızı %$nextShare olarak güncelliyoruz.'
```

**Ama sözleşme kurulurken aynı sayı MÜTEAHHİDİN payı olarak yazılıyor:**
```dart
// game_real_estate_mixin.dart:798
final clampedShare = sharePercent.clamp(40, 60);
contractorSharePercent: clampedShare,
```
```dart
// real_estate_model.dart:222
int get playerShareUnits {
  final totalShare = (totalProjectUnits * (100 - contractorSharePercent) ~/ 100);
  ...
}
```

**Somut sonuç** — `initialOfferPercent` değerleri 33, 36, 38, 40, 42 ([contractor_negotiation_expansion.dart:51-107](lib/domain/usecases/contractor_negotiation_expansion.dart:51)), pazarlık tavanı `maxSharePercent = 55`:

| Oyuncunun yaptığı | Ekranda gördüğü | Gerçekte aldığı daire payı |
|---|---:|---:|
| Hiç pazarlık etmeden en kötü teklifi kabul (%33) | "%33 PAY" | **%60** (clamp 40 → 100−40) |
| Orta pazarlık (%45) | "%45 PAY" | **%55** |
| Tavana kadar zorlar (%55) | "%55 PAY" | **%45** |

**Pazarlıkta ne kadar başarılı olursanız o kadar az daire alıyorsunuz.** Üstelik `clamp(40, 60)` yüzünden en kötü teklif (%33 → 40'a yükseltiliyor) en iyi sonucu veriyor. Bu, gayrimenkul modülünün merkezî mekaniğinin tamamen tersine çalışması demek.

**Kökeni:** [zoning_engine.dart:164-215](lib/domain/usecases/zoning_engine.dart:164) içinde **hiç kullanılmayan** bir `ContractorProfile` sınıfı var ve alanı açıkça `defaultPlayerSharePercent` (**oyuncu** payı, 40–60, `minShare 40 / maxShare 60`). `startContractorConstruction`'ın `clamp(40, 60)`'ı bu ölü sınıftan geliyor. Yani fonksiyon **oyuncu payı** almak üzere tasarlanmış, ama **müteahhit payı** alanına yazıyor.

**Düzeltme:**
1. `RealEstateModel.contractorSharePercent` alanını **`playerSharePercent`** olarak yeniden adlandır. `toJson`/`fromJson`'a migration ekle: eski `contractorSharePercent` okunursa `100 - değer` olarak dönüştür (aksi halde mevcut kayıtlardaki devam eden projeler tersine döner).
2. `playerShareUnits` → `(totalProjectUnits * playerSharePercent ~/ 100) - soldPreSaleUnits`.
3. `startContractorConstruction` içinde `clampedShare` doğrudan `playerSharePercent`'e yazılsın; `clamp(33, 60)` yap (sohbetin gerçek alt sınırı 33).
4. `startSelfBuildConstruction` içindeki `contractorSharePercent: 0` → `playerSharePercent: 100`.
5. **Regresyon testi:** *"%55 pazarlıkla imzalanan 10 daireli projede `playerShareUnits == 5`, %33 ile imzalananda `playerShareUnits == 3` olmalı."*

## A2 · Aynı alan iki ekranda zıt etiketle gösteriliyor — çelişkinin kaynağı

**Dosyalar:** `tr_translations.dart:3654`, `tr_translations.dart:4022`, [game_real_estate_mixin.dart:811](lib/presentation/providers/game/game_real_estate_mixin.dart:811)

Tek bir sayı, üç farklı okuma:

| Yer | Metin | Anlamı |
|---|---|---|
| İnşaat ekranı kartı | `'real_estate_contractor_share': 'Müteahhit Payı: %{share}'` (sabit `'50'`) | **müteahhidin** payı |
| Sohbet ekranı rozeti | `'contractor_chat_share_badge': '%{percent} PAY'` + tüm diyalog | **oyuncunun** payı |
| Tapu geçmişi kaydı | `'... %$clampedShare Oyuncu Payı'` | **oyuncunun** payı |

Üstelik inşaat ekranındaki kart yüzdeyi **sabit `'50'`** olarak basıyor ([real_estate_construction_screen.dart:1245](lib/presentation/screens/real_estate/real_estate_construction_screen.dart:1245)) — pazarlık sonucundan bağımsız.

**Düzeltme:** A1'deki yeniden adlandırmadan sonra üç metni de tek anlamda birleştir: `'Sizin Payınız: %{share} • Müteahhit: %{other}'`. Sabit `'50'` yerine gerçek değeri geçir. 7 dilde güncelle.

## A3 · Pazarlıkla imzalamak, tasarlanan KAKS/tipoloji planını çöpe atıyor ⭐

**Dosyalar:** [contractor_negotiation_chat_screen.dart:190](lib/presentation/screens/real_estate/contractor_negotiation_chat_screen.dart:190) vs [real_estate_construction_screen.dart:1269](lib/presentation/screens/real_estate/real_estate_construction_screen.dart:1269)

İki giriş noktası, iki farklı çağrı:

```dart
// İnşaat ekranı • "Anlaşmayı Başlat" butonu
startContractorConstruction(land.id, customUnitMix: _workingMix);      // plan korunuyor

// Sohbet ekranı • pazarlık sonrası
startContractorConstruction(land.id, sharePercent: _chatState.currentSharePercent);  // customUnitMix YOK
```

Pazarlık yoluyla imzalandığında `customUnitMix` **null** kalır. Sonuçlar zincirleme:
1. `totalProjectUnits` özel plandan değil, m²'ye bakan kaba fallback'ten hesaplanır: `>=800 → 8, >=500 → 6, aksi 4` ([real_estate_model.dart:212-217](lib/data/models/real_estate_model.dart:212)).
2. `finalizeConstruction` içinde `typologyQueue` **boş** kalır → üretilen **her daire** varsayılan `2+1 / 105 m²` olur ([game_real_estate_mixin.dart:1115](lib/presentation/providers/game/game_real_estate_mixin.dart:1115)).

Yani oyuncu Tab 1'de dakikalarca 1+1/3+1/4+1 karması tasarlıyor, "Mimari Planı Onayla"ya basıyor, sonra pazarlığa giriyor — ve **plan sessizce siliniyor.**

**Düzeltme:** `contractor_negotiation_chat_screen`'e `customUnitMix` parametresini taşı. En temizi: rota parametresi yerine sohbet ekranı da `land.customUnitMix`'i okusun — bunun için "Mimari Planı Onayla" butonunun planı gerçekten **kaydetmesi** gerekiyor (bkz. **D1**). İki düzeltme birlikte yapılmalı.

## A4 · Doğrudan imzalamak, pazarlık etmekten her koşulda daha iyi

**Dosya:** [real_estate_construction_screen.dart:1263-1295](lib/presentation/screens/real_estate/real_estate_construction_screen.dart:1263)

Yan yana iki buton var:

| Buton | Pay sonucu (A1 sonrası gerçek) | Tipoloji planı | Süre |
|---|---:|---|---|
| **"Anlaşmayı Başlat"** (doğrudan) | varsayılan 50 → **%50 daire** | **korunuyor** | anında |
| **"Müteahhitle Pazarlık"** | 40–55 → **%45–60 daire** | **siliniyor** | 5–10 tur sohbet |

Pazarlık tavana çıkarsa %45 alıyor; hiç pazarlık etmezse %50 alıyor **ve** planını koruyor. Yani **pazarlık özelliğinin tamamı bir tuzak** — oynamamak daha kârlı.

**Düzeltme:** A1 + A3 düzeltildikten sonra doğrudan butonu ya kaldır ya da açık bir bedelle sun: doğrudan imza = sabit %40 pay, pazarlık = 40–60 aralığı. Pazarlığın bir üstünlüğü olmalı, aksi halde ekran ölü içerik.

## A5 · "Anlaş" butonu koşulsuz kabul ediyor — pazarlık tamamen tiyatro ⭐

**Dosya:** [real_estate_chat_negotiation_engine.dart:551-557](lib/domain/usecases/real_estate_chat_negotiation_engine.dart:551)

```dart
case ChatTacticType.demandCashDiscount:
case ChatTacticType.acceptAgreement:
  nextAgreed = true;
  replyText = 'Harika! Şartlarda mutabık kaldık...';
```

Karşı taraf **her zaman, koşulsuz** kabul ediyor. `satisfaction` (memnuniyet) hesaplanıyor, her taktikte güncelleniyor, ekranda gösteriliyor — ama **hiçbir kararı etkilemiyor**. Tek gerçek kısıt `patience <= 0` → masadan kalkma.

Ayrıca **`demandCashDiscount` ile `acceptAgreement` aynı `case` gövdesini paylaşıyor** (fallthrough). Oyuncu "Nakit İndirim İste" butonuna basıyor, indirim beklerken **sözleşme imzalanıyor**. Bu iki taktik semantik olarak zıt.

**Düzeltme:**
1. `demandCashDiscount` için ayrı bir `case` yaz — fiyatı %5–10 indiren, patience düşüren, başarısız olabilen kendi gövdesi olsun.
2. `acceptAgreement`'ı koşula bağla: `if (state.satisfaction >= 40) nextAgreed = true; else { patience -= 25; replyText = 'Bu şartlarda imza atmayız...'; }`. Memnuniyet metresi ancak o zaman anlam kazanır.

## A6 · "Çay & Sohbet" sonsuz sabır üretiyor — müteahhit ekranında pazarlık limitsiz

**Dosya:** [real_estate_chat_negotiation_engine.dart:484-490](lib/domain/usecases/real_estate_chat_negotiation_engine.dart:484)

```dart
case ChatTacticType.askJokeOrChat:
  nextPatience = min(state.maxPatience, nextPatience + 22);
  nextSatisfaction = min(100, nextSatisfaction + 15);
```

Bedelsiz, sınırsız, her seferinde **+22 sabır ve +15 memnuniyet**. Müteahhit ekranında `askJokeOrChat` mevcut ([contractor_negotiation_chat_screen.dart:713](lib/presentation/screens/real_estate/contractor_negotiation_chat_screen.dart:713)).

Döngü: `demandHigherShare` (−20 sabır) → `askJokeOrChat` (+22 sabır) → net **+2**. Sabır asla bitmez, oyuncu her zaman tavana çıkar. (A1 yüzünden tavana çıkmak zaten kötü — iki hata birbirini gizliyor.)

**Düzeltme:** Sohbet taktiğine azalan verim ekle: `ChatNegotiationState`'e `jokeUseCount` alanı koy, kazancı `max(0, 22 - jokeUseCount * 8)` yap ve 3. kullanımdan sonra `nextPatience -= 10` ile ters çevir ("Patron, işimize dönelim").

## A7 · Altı taktikten beşi hiçbir şey kaydetmiyor — verilen sözlerin karşılığı yok ⭐

**Dosya:** [real_estate_chat_negotiation_engine.dart:394-520](lib/domain/usecases/real_estate_chat_negotiation_engine.dart:394)

| Taktik | Rozet & vaat | Kalıcı etki |
|---|---|---|
| `demandPrimeFloors` | "ÜST KATLAR TAHSİS EDİLDİ" — *"en üst 2 katın tapusunu sizin adınıza tescil edeceğiz"* | **yok** — üstelik `finalizeConstruction` oyuncuya **en küçük** daireleri veriyor (bkz. **C3**), yani vaadin tam tersi |
| `demandQualityUpgrade` | "LÜKS C35 ŞARTNAMESİ" | **yok** — başarı dalında `satisfaction` bile artmıyor, sadece metin |
| `demandAdvanceDeposit` | "₺350.000 NAKİT AVANS" — *"hesabınıza yatırıyoruz"* | **yok** — bakiye değişmiyor |
| `demandBankGuarantee` | "BANKA TEMİNATI ONAYLANDI" — *"₺2.500.000 teminat mektubu"* | **yok** — zaten müteahhidin projeyi yarıda bırakma mekaniği de yok |
| `demandDoubleShift` | "ÇİFT VARDİYA ONAYLANDI" — *"süreden gün kazanacağız"* | **yok** — müteahhit etabı sabit 15 gün |
| `demandHigherShare` | "%X PAY GÜNCELLENDİ" | **var — ama ters** (A1) |

`_finalizeContract` yalnızca `sharePercent` gönderiyor; diğer beş taktiğin hiçbir çıktısı `RealEstateModel`'e yazılmıyor.

**Düzeltme:** `RealEstateModel`'e sözleşme şartları alanları ekle ve `finalize`'da kullan:
- `bool hasPrimeFloorClause` → `finalizeConstruction`'da tipoloji kuyruğunu **büyükten küçüğe** sırala (C3 ile birlikte).
- `bool hasQualityUpgrade` → üretilen dairelerin `baseMarketValue`'sunu ×1.08.
- `double contractorAdvancePaid` → `startContractorConstruction` içinde `balance += 350000`.
- `bool hasBankGuarantee` → müteahhidin gecikme/terk olayına karşı sigorta (önce o olayı ekle, yoksa alanı kaldır).
- `int contractorStageDays` → çift vardiyada 15 → 11.

Bunlar eklenene kadar ilgili taktikleri ekrandan **kaldırmak**, oyuncuya sahte vaat vermekten iyidir.

## A8 · Başarı bildirimi işlemden ÖNCE gösteriliyor, dönüş değeri kontrol edilmiyor — sıralama hatası ⭐

**Dosya:** [contractor_negotiation_chat_screen.dart:168-196](lib/presentation/screens/real_estate/contractor_negotiation_chat_screen.dart:168)

```dart
if (_chatState.isAgreed) {
  GameSoundHapticService.playCashSuccess();                              // 1. para sesi
  NotificationService.showSuccess(context, tr('contractor_chat_agreed_toast'));  // 2. "sözleşme imzalandı"
  _finalizeContract();                                                   // 3. asıl işlem — SONRA
}

void _finalizeContract() {
  final land = ref.read(gameProvider).ownedRealEstates.firstWhere((r) => r.id == widget.landId);  // orElse YOK
  ref.read(gameProvider.notifier).startContractorConstruction(...);       // dönüş değeri YOK SAYILIYOR
  Future.delayed(const Duration(milliseconds: 600), () { if (mounted) context.pop(); });  // koşulsuz kapanış
}
```

Üç ayrı sorun:
1. **Sıralama:** Başarı sesi + toast, işlemden önce. `startContractorConstruction` `false` dönerse (`isConstructionActive` zaten true, arsa değil, kayıt bulunamadı) oyuncu "sözleşme imzalandı" görür, ekran kapanır, **hiçbir şey olmamıştır.**
2. **Dönüş değeri yok sayılıyor** — `bool` döndüren fonksiyonun sonucu hiç okunmuyor.
3. **`firstWhere` `orElse`'siz** — arsa portföyden çıkmışsa (paralel bir akışta finalize edildiyse) `StateError` fırlatır ve ekran çöker.

**Düzeltme:**
```dart
void _finalizeContract() {
  final idx = ref.read(gameProvider).ownedRealEstates.indexWhere((r) => r.id == widget.landId);
  if (idx == -1) { NotificationService.showError(context, tr('real_estate_not_found')); context.pop(); return; }
  final ok = ref.read(gameProvider.notifier).startContractorConstruction(
    ref.read(gameProvider).ownedRealEstates[idx].id,
    sharePercent: _chatState.currentSharePercent,
    customUnitMix: widget.customUnitMix,   // A3
  );
  if (!ok) { NotificationService.showError(context, tr('contractor_contract_failed')); return; }
  GameSoundHapticService.playCashSuccess();
  NotificationService.showSuccess(context, tr('contractor_chat_agreed_toast'));
  Future.delayed(const Duration(milliseconds: 600), () { if (mounted) context.pop(); });
}
```
Ses ve toast **her zaman** işlemin başarılı dönüşünden sonra. Yeni hata anahtarlarını 7 dilde ekle.

## A9 · Müteahhit modu: sıfır maliyet, sıfır risk, sıfır etkileşim

**Dosya:** [game_time_mixin.dart:759-782](lib/presentation/providers/game/game_time_mixin.dart:759)

Müteahhit modunda günlük döngü sadece sayaç düşürüyor: her etap sabit **15 gün**, 7 etap = **105 gün** saf bekleme. Ne maliyet, ne şantiye olayı, ne taşeron seçimi, ne gecikme, ne müteahhidin projeyi bırakması. Oyuncunun sözleşmeden sonra yapabileceği tek şey beklemek.

Karşılaştırma:

| | Müteahhit | Öz-inşaat |
|---|---|---|
| Nakit çıkışı | **₺0** | `baseMarketValue`'nun **%110'u** (bkz. B1) |
| Şantiye olayı riski | **yok** | etap başına %17,6–28,6 |
| Etkileşim | **yok** | 8 etap × taşeron pazarlığı |
| Süre | 105 gün sabit | 86 gün × parsel ölçeği × taşeron |
| Daire payı | %45–60 | %100 |

Öz-inşaat daha kârlı ama tüm riski taşıyor; müteahhit ise risksiz. Sorun şu ki müteahhit tarafında **hiçbir karar noktası yok** — 105 gün boyunca ekran sadece bir ilerleme çubuğu.

**Düzeltme:** Müteahhit moduna en az iki karar noktası ekle:
1. Etap 3 ve 5'te müteahhit ek talep etsin ("demir zammı, %5 pay ya da ₺X nakit katkı") — reddedilirse +10 gün gecikme.
2. `hasBankGuarantee` yoksa %8 ihtimalle "müteahhit şantiyeyi bıraktı" olayı: proje etap 3'e döner, oyuncu yeni müteahhitle pazarlık yapar. Bu, A7'deki teminat mektubu taktiğine de anlam kazandırır.

## A10 · Kullanılmayan ikinci müteahhit kadrosu — kavram karmaşasının kaynağı

**Dosya:** [zoning_engine.dart:164-215](lib/domain/usecases/zoning_engine.dart:164)

`ContractorProfile` sınıfı ve `ZoningEngine.standardContractors` listesi (Metropol Yapı, Öz-Gözde İnşaat, Taşeron Kardeşler) tam donanımlı: `defaultPlayerSharePercent` 50/55/45, `durationMultiplier`, `reliabilityScore`, açıklamalar. **Dosya dışında sıfır referans.**

Aktif sistem ise `ContractorNegotiationExpansion`'daki 5 farklı müteahhit ve `initialOfferPercent` 33–42. İki kadro, iki farklı isim seti, iki farklı pay semantiği.

**Düzeltme:** `ContractorProfile` ve `standardContractors`'ı **sil**. `minShare/maxShare` gerekiyorsa `ContractorNegotiationExpansion`'a taşı. A1 düzeltmesinde `clamp` değerlerini oradan al.

---

# B · ÖZ-İNŞAAT & TAŞERON

## B1 · 1. etap iki kez ücretlendiriliyor — toplam maliyet %100 yerine %110 ⭐

**Dosyalar:** [game_real_estate_mixin.dart:846](lib/presentation/providers/game/game_real_estate_mixin.dart:846), [construction_timeline_engine.dart:91-95](lib/domain/usecases/construction_timeline_engine.dart:91)

`startSelfBuildConstruction`:
```dart
final stageCost = (land.baseMarketValue * 0.10).roundToDouble(); // Etap 1: Proje & Ruhsat (%10)
...
constructionStage: 1,
```

Sonra oyuncu 1. etap için taşeron seçer ve `startSelfBuildStage` çalışır:
```dart
if (land.constructionStage < 1 || land.constructionStage > 8) return false;   // stage 1 GEÇERLİ
final stageDetails = ConstructionTimelineEngine.getStageDetails(1);           // costPercentage: 0.10
```

**Ruhsat etabı iki kez faturalanıyor.** Etap yüzdeleri toplamı `0.10+0.12+0.22+0.16+0.14+0.12+0.08+0.06 = 1.00`, artı baştaki 0.10 → **toplam 1.10**.

**Düzeltme:** İkisinden biri seçilmeli:
- **A:** `startSelfBuildConstruction` ücretsiz olsun (`constructionStage: 1`, para alma), ilk gerçek ödeme taşeron seçiminde yapılsın. Metni "Şantiye kuruldu, 1. etap için taşeron seçin" yap.
- **B:** `startSelfBuildConstruction` %10'u alsın ve `constructionStage: 2` ile başlatsın (ruhsat tamam). O zaman `startSelfBuildStage` guard'ı `< 2` olmalı.

**B önerilir** — "Öz-İnşaat Başlat • ₺X" butonu zaten bir ödeme vaadi veriyor.

## B2 · Taşeron anlaşmasında başarı bildirimi işlemden önce, state koşulsuz siliniyor ⭐ sıralama hatası

**Dosya:** [subcontractor_negotiation_chat_screen.dart:186-221](lib/presentation/screens/real_estate/subcontractor_negotiation_chat_screen.dart:186)

```dart
if (_chatState!.isAgreed) {
  GameSoundHapticService.playCashSuccess();                       // 1. para sesi
  NotificationService.showSuccess(context, tr('subcontractor_toast_agreed'));  // 2. "anlaşıldı"
  _confirmStageStart();                                           // 3. asıl işlem
}

void _confirmStageStart() {
  final land = ref.read(gameProvider).ownedRealEstates.firstWhere((r) => r.id == widget.landId);  // orElse YOK
  final success = ref.read(gameProvider.notifier).startSelfBuildStage(...);
  setState(() { _activeSubcontractor = null; _chatState = null; });   // KOŞULSUZ sıfırlama
  if (success && mounted) context.pop();
}
```

`startSelfBuildStage` şu durumlarda `false` döner: bakiye yetmiyor (çarpan + şantiye olayı eklendikten sonra), `isConstructionWorking` zaten true, `constructionMode != 'selfBuild'`, etap aralık dışı.

Başarısızlıkta oyuncunun yaşadığı: **para sesi çalar, "Taşeronla anlaşıldı" yazısı çıkar, sohbet sıfırlanıp taşeron listesine döner, hiçbir hata gösterilmez, hiçbir şey olmamıştır.** Pazarlıkta harcanan 5–10 tur da kaybolur.

**Düzeltme:** A8'deki kalıbın aynısı — `success` kontrolünden **sonra** ses/toast; başarısızlıkta `showError` + `_chatState` korunsun ki oyuncu tekrar deneyebilsin. `firstWhere`'e `indexWhere` + guard.

## B3 · Şantiye kurulmadan "Taşeron Seç" butonu açık — garantili sessiz başarısızlık

**Dosya:** [real_estate_construction_screen.dart:1395-1400](lib/presentation/screens/real_estate/real_estate_construction_screen.dart:1395)

Öz-inşaat **başlatılmadan önceki** kartta, "Öz-İnşaat Başlat" butonunun yanında ikinci bir buton var ve doğrudan taşeron ekranına gidiyor:
```dart
onPressed: () { context.push('/emlak-insaat/${land.id}/taseron'); }
```

O anda `constructionMode == null`. Oyuncu taşeron seçip pazarlık yapar, "Anlaş"a basar → B2'deki akış → `startSelfBuildStage` ilk satırda `if (land.constructionMode != 'selfBuild') return false;` ile çıkar. Başarı sesi + toast gösterilmiştir; hiçbir şey olmamıştır.

**Düzeltme:** Butonu `land.constructionMode == 'selfBuild'` koşuluna bağla; öncesinde ya gizle ya da `onPressed: null` + açıklayıcı etiket ("Önce şantiyeyi kur").

## B4 · Etap maliyeti için ekranda dört farklı rakam dolaşıyor ⭐

| Nerede | Formül | Örnek (base ₺8M, etap 3, hızlı taşeron) |
|---|---|---:|
| İnşaat ekranı butonu ([:1644](lib/presentation/screens/real_estate/real_estate_construction_screen.dart:1644)) | `base × costPercentage` | **₺1.760.000** |
| `canAfford` kontrolü ([:1645](lib/presentation/screens/real_estate/real_estate_construction_screen.dart:1645)) | aynı — çarpansız | **₺1.760.000** |
| Taşeron sohbeti açılış ([:96](lib/presentation/screens/real_estate/subcontractor_negotiation_chat_screen.dart:96)) | `× sub.costMultiplier` | **₺2.200.000** |
| Taşeron ekranı bütçe göstergesi ([:141](lib/presentation/screens/real_estate/subcontractor_negotiation_chat_screen.dart:141)) | `base × 0.75` | **₺6.000.000** |
| Gerçekte kesilen ([game_real_estate_mixin.dart:936](lib/presentation/providers/game/game_real_estate_mixin.dart:936)) | pazarlık fiyatı **+ şantiye olayı** | değişken |

İki somut sonuç:
1. **`canAfford` yanlış kapıyı bekliyor.** Bakiyesi tam ₺1.760.000 olan oyuncu butonu aktif görür, taşeron ekranına girer, pazarlığı bitirir — ve `startSelfBuildStage` bakiye yetmediği için `false` döner (B2 yüzünden sessizce).
2. **Sohbette anlaşılan rakam ile kesilen rakam farklı** — şantiye olayı maliyeti (`incidentCost`, etap bedelinin %8–15'i) üzerine ekleniyor ve oyuncuya hiçbir yerde gösterilmiyor.

**Düzeltme:**
1. Tek bir `ConstructionPricing.stageCost(land, tier)` yardımcı fonksiyonu yaz; kart etiketi, `canAfford` ve sohbet açılışı aynı fonksiyonu çağırsın.
2. `canAfford` kontrolünü en pahalı taşeron çarpanına göre yap (`× 1.25`) veya kartta aralık göster: "₺1,76M – ₺2,20M".
3. `totalBudget = base * 0.75` göstergesini ya kaldır ya da gerçek toplam (`base × 1.00` veya B1 sonrası ne olacaksa) ile değiştir.

## B5 · Taşeron fiyatının alt sınırı yok — her etapta ~%40 gizli indirim

**Dosyalar:** [real_estate_chat_negotiation_engine.dart:522-535](lib/domain/usecases/real_estate_chat_negotiation_engine.dart:522), [:492-506](lib/domain/usecases/real_estate_chat_negotiation_engine.dart:492)

```dart
case ChatTacticType.demandCashMaterials:
  nextPatience -= 10;                                  // en ucuz taktik
  if (random.nextDouble() < 0.70) {                    // en yüksek başarı oranı
    final discount = (state.currentPrice * 0.08).roundToDouble();
    nextPrice = state.currentPrice - discount;         // ALT SINIR YOK
```
`counterPrice` de taşeron rolünde `−%5` uyguluyor, yine sınırsız.

Sabır 100, `demandCashMaterials` başına −10 → sıfıra düşmeden **9 kullanım**. %70 başarıyla ≈ 6,3 başarı → `0.92^6.3 ≈ 0.60`. Yani **her etapta ortalama %40 indirim**, üstelik bu indirim hiçbir yerde "pazarlık kazancı" olarak gösterilmiyor. Ayrıca `customStageCost` devreye girdiği için `sub.costMultiplier` tamamen devre dışı kalıyor — taşeron kademesinin maliyet ekseni çöküyor.

**Düzeltme:**
1. `ChatNegotiationState`'e `minPrice` alanı ekle (`stageCost × 0.75` gibi) ve her indirimde `nextPrice = max(minPrice, ...)` uygula. Tabana ulaşıldığında ret repliği dön.
2. `demandCashMaterials`'ın sabır bedelini −10'dan −20'ye çıkar (diğer taktiklerle denk olsun).
3. Pazarlık kazancını görünür kıl: sözleşme onayında "Liste: ₺2,20M • Pazarlık: −₺440K • **Ödenecek: ₺1,76M**".

## B6 · Şantiye olayları görünmez — imza anında ekstra para kesiliyor

**Dosyalar:** [game_real_estate_mixin.dart:901-935](lib/presentation/providers/game/game_real_estate_mixin.dart:901), [construction_negative_events_engine.dart:25-36](lib/domain/usecases/construction_negative_events_engine.dart:25)

Olay, etap **başlarken** zar atılıyor ve maliyeti aynı anda tahsil ediliyor:
```dart
final incident = ConstructionNegativeEventsEngine.rollStageIncident(...);   // %17,6–28,6
...
final totalDeduction = stageCost + incidentCost;
```

Ama olay hiçbir yerde gösterilmiyor: dialog yok, `GameEventModel` yok, bildirim yok. Tek iz `provenanceLog`'a eklenen bir satır ve "Şantiye Telsizi" kartında görünme ihtimali.

İki mantık sorunu:
1. **Zamanlama ters.** "Demire zam geldi", "taşeron ekibi iş bıraktı", "yağmur betonu bozdu" gibi olaylar **inşaat sırasında** olmalı. Şu an sözleşme imzalanır imzalanmaz, henüz tek çivi çakılmadan gerçekleşiyor.
2. **Bakiye yetmezse ceza tuhaf:** `if (state.balance >= stageCost + incident.costImpact) { incidentCost = ... } else { extraDays += 1; }` — sadece **1 gün** ek. Zengin oyuncu parayla, fakir oyuncu 1 günle kurtuluyor; ikisi denk değil.

**Düzeltme:**
1. Olay zarını `game_time_mixin`'in günlük döngüsüne taşı: aktif şantiyede her gün `%3` ihtimalle olay tetiklensin, `constructionDaysRemaining += dayDelayImpact` ve `balance -= costImpact` uygulansın.
2. Olayı `GameEventModel` olarak `recentEvents`'e ekle ve `NeoBrutalRandomEventDialog` ile göster — hatta oyuncuya seçim sun ("zammı öde" / "ucuz demirle devam et → kalite düşer").
3. Bakiye yetmezse ek gün cezasını olayın `dayDelayImpact`'i kadar yap, sabit 1 değil.

## B7 · Taşeron kademesinde iki alan ölü, prim kademesi hiçbir ek fayda vermiyor

**Dosya:** [construction_timeline_engine.dart:191-238](lib/domain/usecases/construction_timeline_engine.dart:191)

| Alan | Değerler | Kullanımı |
|---|---|---|
| `costMultiplier` | 1.25 / 1.00 / 0.80 | sadece sohbet **açılış** fiyatı — B5 yüzünden final fiyata etkisiz |
| `durationMultiplier` | 0.75 / 1.00 / 1.25 | **hiç okunmuyor** — `calculateStageDays` kendi içinde ayrı bir `switch` ile aynı sayıları tekrar tanımlıyor |
| `reliabilityScore` | 0.95 / 0.88 / 0.76 | **hiç okunmuyor** — muhtemelen seçim ekranında yıldız olarak gösteriliyor ama hiçbir hesaba girmiyor |

Ayrıca risk eşleşmesi tuhaf:
```dart
riskMultiplier: sub.tier == budget ? 1.3 : (sub.tier == speed ? 0.8 : 1.0)
```
**Hızlı** ekip en düşük riski (0.8), **standart** ise 1.0 alıyor. Yani 1.25× ödediğiniz "hızlı" kademe hem daha hızlı hem daha güvenli; "standart" kademenin hiçbir üstünlüğü yok. Gerçekçi olan tersi olurdu: hız → daha yüksek hata riski.

**Düzeltme:**
1. `calculateStageDays` içindeki `switch`'i sil, `sub.durationMultiplier`'ı parametre olarak al — tek doğruluk kaynağı.
2. `riskMultiplier`'ı `reliabilityScore`'dan türet: `riskMultiplier = 2.0 - (reliabilityScore * 1.5)` → speed 0.575, standard 0.68, budget 0.86. Ya da basitçe `1.0 - reliabilityScore` oranını kullan.
3. Risk sıralamasını yeniden dengele: hız kademesi hızlı **ama riskli**, prim kademesi pahalı **ama güvenli** olsun. Şu anki 3 kademe tek boyutlu.

## B8 · Etap sayacının üst sınırı yok — 9, 10, 11… diye artıyor

**Dosya:** [game_real_estate_mixin.dart:986](lib/presentation/providers/game/game_real_estate_mixin.dart:986)

```dart
final nextStage = land.constructionStage + 1;   // clamp yok
```
`startSelfBuildStage` guard'ı `constructionStage > 8` olduğu için **etap 8 de "çalıştırılabilir"**. Tamamlandığında etap **9** olur. `constructionProgress = (9/8).clamp(0,1)` = 1.0 olduğu için görsel olarak fark edilmez ama sayı kayda yazılır.

**Düzeltme:** `constructionStage: nextStage.clamp(1, 9)` ve `startSelfBuildStage` guard'ını `> 8` yerine `>= 8`'e çekip etap 8'i (İskan) ayrı bir "teslim" akışı yap — ya da 9'u resmî "tamamlandı" değeri olarak modelde belgele.

## B9 · `advanceSelfBuildStage` — ters sıralı, ölü üçüncü uygulama

**Dosya:** [game_real_estate_mixin.dart:1010-1039](lib/presentation/providers/game/game_real_estate_mixin.dart:1010)

Hiçbir ekrandan çağrılmıyor ama duruyor ve **aktif akışın tam tersi sırayla** çalışıyor:

| | Aktif akış | `advanceSelfBuildStage` |
|---|---|---|
| Sıra | etabı fonla → gün say → **sonra** etabı ilerlet | **önce** etabı ilerlet → gün say |
| Süre | `calculateStageDays(...)` | sabit **4 gün** |
| Taşeron | seçiliyor | yok |
| Şantiye olayı | var | **`triggerIncidents` parametresi alıyor ama hiç kullanmıyor** |
| Etap 8 | izinli (`> 8` reddi) | reddediliyor (`>= 8`) |

Biri bunu bir butona bağlarsa etaplar atlanır ve maliyet tablosu bozulur.

**Düzeltme:** Fonksiyonu **sil**. "Legacy compatibility" yorumu geçerli değil — çağıran yok.

## B10 · "Tamamlandı" eşiği UI'da 9, motorda 8 — %100 gösterip bitirtmiyor

**Dosyalar:** [real_estate_construction_screen.dart:86-88](lib/presentation/screens/real_estate/real_estate_construction_screen.dart:86), [game_real_estate_mixin.dart:1080](lib/presentation/providers/game/game_real_estate_mixin.dart:1080)

```dart
// UI
final isFinished = land.constructionMode == 'selfBuild'
    ? land.constructionStage >= 9
    : (land.constructionStage >= 8 && land.constructionDaysRemaining == 0);

// Motor
if (land.constructionStage < 8) return [];   // 8 yeterli
```

Öz-inşaatta etap 8'e gelen oyuncu: ilerleme çubuğu **%100**, 8 etabın hepsi yeşil — ama "Daireleri Teslim Al" butonu **yok**. Bir etap daha çalıştırması gerekiyor, bunu anlatan hiçbir şey yok.

**Düzeltme:** Model tarafında tek bir `bool get isConstructionComplete` getter'ı tanımla, hem UI hem `finalizeConstruction` onu kullansın. Modeldeki `constructionStage` yorumunu (`8: İskan`) gerçek davranışla eşleştir.

---

# C · TESLİM (finalizeConstruction) & GÜNLÜK DÖNGÜ

## C1 · "Şantiye Tamamlandı" bildirimi her gün tekrar ediyor — sonsuz spam ⭐

**Dosya:** [game_time_mixin.dart:757-815](lib/presentation/providers/game/game_time_mixin.dart:757)

**Müteahhit modu:** Etap 8'e gelindiğinde `constructionDaysRemaining: 0` olur. Ertesi gün:
```dart
final daysLeft = currentProp.constructionDaysRemaining - 1;   // 0 - 1 = -1
if (daysLeft <= 0) {                                          // TRUE
  final nextStage = currentProp.constructionStage + 1;        // 9, 10, 11...
  ...
  if (nextStage >= 8) { updatedEvents.insert(0, GameEventModel(id: '..._${millisecondsSinceEpoch}', title: 'Şantiye Tamamlandı • Anahtar Teslim Hazır', ...)); }
}
```
Olay id'si her seferinde benzersiz olduğu için tekilleştirme çalışmaz. Oyuncu daireleri teslim alana kadar **her in-game günde bir** (yani her 2 gerçek dakikada bir) aynı bildirimi alır ve `constructionStage` sınırsız büyür.

**Öz-inşaat modu:** Aynı hata. Etap süresi bittiğinde `constructionDaysRemaining: 0` yazılır ama `isConstructionWorking` **true** kalır. Ertesi gün `daysLeft = -1 <= 0` → "Şantiye Etabı Tamamlandı" olayı **yeniden** eklenir. Oyuncu etabı teslim alana kadar her gün tekrar.

**Düzeltme:**
1. Müteahhit dalına üst sınır: `if (currentProp.constructionStage >= 8) { /* hiçbir şey yapma */ }` — döngünün başında atla.
2. Öz-inşaat dalında olay üretimini `isConstructionWorking && daysLeft == 0` (yani tam **o gün** biten) koşuluna bağla; `daysLeft < 0` durumunda hiçbir şey yapma.
3. `GameEventModel` id'sinden `millisecondsSinceEpoch`'u çıkar, `'construction_ready_${prop.id}_${stage}'` gibi deterministik yap ki tekrar eklenirse tekilleştirilebilsin.

## C2 · Teslim, portföy slot limitini tamamen delip geçiyor

**Dosya:** [game_real_estate_mixin.dart:1141-1145](lib/presentation/providers/game/game_real_estate_mixin.dart:1141)

`purchaseRealEstate` slot kontrolü yapıyor:
```dart
if (state.ownedRealEstates.length >= state.maxRealEstateSlots) return false;
```
`finalizeConstruction` **hiç yapmıyor**:
```dart
updatedList.removeAt(index);          // 1 arsa çıkar
updatedList.addAll(createdApartments); // N daire girer  — kontrol yok
```

8–20 daire tek seferde portföye giriyor. `expandRealEstateSlots` maliyeti `500000 × 1.8^level` — yani oyuncu slot genişletme ekonomisini tamamen atlayabiliyor.

**Düzeltme:** Ya slot kontrolü ekle (yetmezse teslimi engelle ve "önce portföy genişlet" uyarısı ver), ya da inşaat başlarken `totalProjectUnits` kadar slot rezerve et. İkincisi daha adil: sözleşme imzalanırken oyuncu gereksinimi görür.

## C3 · Oyuncu her zaman EN KÜÇÜK daireleri alıyor — sessiz değer kaybı ⭐

**Dosya:** [game_real_estate_mixin.dart:1087-1119](lib/presentation/providers/game/game_real_estate_mixin.dart:1087)

`typologyQueue` sabit sırayla dolduruluyor: **1+0 → 1+1 → 2+0 → 2+1 → 3+1 → 4+1** (küçükten büyüğe). Sonra:
```dart
for (int i = 0; i < unitsToCreate; i++) {
  final typology = (i < typologyQueue.length) ? typologyQueue[i] : {...'2+1'...};
```
`unitsToCreate = playerShareUnits` — yani kuyruğun **ilk N elemanı** alınıyor.

**Örnek:** 8 daireli proje, mix = 2×(1+0), 2×(1+1), 2×(3+1), 2×(4+1). %50 kat karşılığı → oyuncu 4 daire alır: **1+0, 1+0, 1+1, 1+1**. Müteahhide 3+1 ve 4+1'ler kalır.

Daire **sayısı** olarak %50, **metrekare/değer** olarak yaklaşık **%30**. Sözleşmede bu hiçbir yerde yazmıyor. Üstelik A7'deki `demandPrimeFloors` taktiği tam bunun tersini vaat ediyor: *"en üst katları size ayırıyoruz."*

**Aynı hata ön satışta daha ağır:** `playerShareUnits` içinde `- soldPreSaleUnits` var, yani ön satış kuyruğun **sonundan** siler → oyuncu **en büyük** dairelerini kaybeder. Ve `preSaleUnitPrice` tüm tipolojiler için **tek düz fiyat** (`baseMarketValue × 2.2 / totalUnits × 0.75`). Yani oyuncu 4+1 dairesini 1+0 fiyatının aynısına satıyor.

**Düzeltme:**
1. Payı **metrekare üzerinden** dağıt, adet üzerinden değil: kuyruğu büyükten küçüğe sırala ve oyuncu ile müteahhit arasında **dönüşümlü** (1-2-2-1 serpentine) dağıt. Böylece %50 gerçekten %50 değer eder.
2. `hasPrimeFloorClause` varsa (A7) dağıtımda oyuncuya öncelik ver.
3. `preSaleUnitPrice`'ı tipolojiye göre hesapla: `unitGrossM2 × avgValuePerM2 × 0.75`. Ön satışta **hangi** dairenin satıldığını oyuncuya göster.
4. Ön satışın kuyruğun sonundan değil, **başından** (küçük daireler) silmesi daha mantıklı — oyuncu likidite için küçükleri feda etsin.

## C4 · İnşaat maliyeti kâr muhasebesinden tamamen siliniyor

**Dosya:** [game_real_estate_mixin.dart:1134](lib/presentation/providers/game/game_real_estate_mixin.dart:1134)

```dart
currentPurchasePrice: 0.0,
```
Daha sonra `sellRealEstate`:
```dart
final totalCost = property.currentPurchasePrice + property.deedFeePaid + property.commissionPaid;  // = 0
final netProfit = salePrice - totalCost;   // = salePrice
```

Sonuç: Oyuncu arsaya ₺8M, etaplara ₺8,8M harcar; daireyi ₺4M'ye satar; `totalProfit` **+₺4M** artar. Gerçekte projeden zarar etmiş olabilir. Kariyer boyu kâr istatistiği ve buna bağlı her rozet/görev anlamsızlaşıyor.

**Düzeltme:** `finalizeConstruction` toplam yatırımı hesaplayıp dairelere paylaştırsın:
```dart
final totalInvested = land.currentPurchasePrice + land.deedFeePaid + land.commissionPaid + land.totalConstructionSpent;
final costPerUnit = totalInvested / max(1, unitsToCreate);
// her daire için:
currentPurchasePrice: costPerUnit,
```
Bunun için `RealEstateModel`'e `double totalConstructionSpent` alanı ekle ve `startSelfBuildStage` / `startSelfBuildConstruction` her ödemede `+= stageCost` yazsın. Müteahhit modunda `totalConstructionSpent = 0` kalır — doğru.

## C5 · Daire değeri sabit `1.8` katsayısına bağlı — imar kalitesi değeri hiç etkilemiyor

**Dosyalar:** [game_real_estate_mixin.dart:1110](lib/presentation/providers/game/game_real_estate_mixin.dart:1110), [zoning_engine.dart:232](lib/domain/usecases/zoning_engine.dart:232)

```dart
final double avgValuePerM2 = (land.baseMarketValue * 2.8) / (land.squareMeters * 1.8);
```
Ama gerçek KAKS parsele göre değişiyor:
```dart
final kaks = customKaks ?? (safeArea >= 1500 ? 2.10 : (safeArea >= 800 ? 1.80 : 1.50));
```

Sabit `1.8` yalnızca **800–1499 m²** parseller için doğru. Ve daha önemlisi: formül `avgValuePerM2`'yi parselin imar kalitesinden **bağımsız** kılıyor — 2.10 KAKS'lı prestijli bir parselde üretilen dairenin m² değeri, 1.50 KAKS'lı parseldekiyle **aynı**. KAKS sadece daire **sayısını** etkiliyor, **değerini** hiç etkilemiyor.

Bu, son commit'lerde öne çıkarılan "dinamik KAKS/TAKS hesaplaması" özelliğinin yarısının boşa gitmesi demek.

**Düzeltme:**
```dart
final zoning = ZoningEngine.calculateZoning(
    parcelSquareMeters: land.squareMeters.toDouble(), baseMarketValue: land.baseMarketValue);
final totalBuildable = max(1.0, zoning.netResidentialArea);
final avgValuePerM2 = (land.baseMarketValue * 2.8) / totalBuildable;
```
Ve imar kalitesine prim ekle: `avgValuePerM2 *= (1.0 + (zoning.kaks - 1.5) * 0.10)` — yüksek emsalli parsel daha değerli daire üretsin.

## C6 · Özel plan yoksa tüm daireler tek tip 2+1 oluyor

**Dosya:** [game_real_estate_mixin.dart:1115](lib/presentation/providers/game/game_real_estate_mixin.dart:1115)

`customUnitMix == null` ise `typologyQueue` boş kalır ve her daire fallback `{'type': '2+1', 'gross': 105.0, 'net': 88.0}` olur. A3 yüzünden bu durum **pazarlıkla imzalanan her sözleşmede** oluşuyor.

**Düzeltme:** Fallback yerine `ZoningEngine.optimizeUnitMix(zoning.netResidentialArea)` çağır — özel plan yoksa bile makul bir karma üretilsin. Ayrıca A3 düzeltilirse bu yol çok daha az tetiklenir.

## C7 · `constructionMode` hiç temizlenmiyor — projeden vazgeçme yolu yok

**Dosyalar:** [real_estate_model.dart:199](lib/data/models/real_estate_model.dart:199), `copyWith` (satır 483-486)

```dart
bool get isConstructionActive => constructionMode != null || (constructionStage > 0 && constructionStage < 8);
```
`constructionMode` yalnızca `'contractor'` ve `'selfBuild'` değerlerini alıyor; **hiçbir yerde `null`'a döndürülmüyor** ve `copyWith`'te `clearConstructionMode` bayrağı **yok** (`clearCurrentTenant`, `clearActiveSubcontractor`, `clearCustomUnitMix` var — bu unutulmuş).

Sonuç: İnşaat başlatan oyuncu arsayı **asla satamaz** (`canBeSold` → `!isConstructionActive`), kiraya veremez, iptal edemez. Öz-inşaatta parası biterse (etap maliyetleri `baseMarketValue`'nun %110'u) arsa kalıcı olarak kilitlenir — ne bitirebilir ne satabilir. **Oyunu tıkayan bir çıkmaz.**

**Düzeltme:**
1. `copyWith`'e `bool clearConstructionMode = false` ekle.
2. `cancelConstruction(landId)` fonksiyonu yaz: harcanan tutarın %40'ını geri ver, `constructionMode`'u temizle, `constructionStage: 0`, `soldPreSaleUnits` varsa ön satış bedelini geri öde ve itibardan −10 düş.
3. İnşaat ekranına "Projeden Vazgeç" butonu ekle (onay diyaloğuyla). Anahtarları 7 dilde ekle.

## C8 · Başarısızlıkta "başarı" bildirimi gösteriliyor

**Dosya:** [real_estate_construction_screen.dart:1943-1958](lib/presentation/screens/real_estate/real_estate_construction_screen.dart:1943)

```dart
final created = ref.read(gameProvider.notifier).finalizeConstruction(land.id);
if (created.isNotEmpty) {
  NotificationService.showSuccess(context, tr('real_estate_finalize_success_toast', {'count': created.length.toString()}));
} else {
  NotificationService.showSuccess(context, tr('real_estate_finalize_success_toast', {'count': '0'}));  // yine SUCCESS
}
context.pop();
```

`finalizeConstruction` boş liste döndüğünde (etap < 8, gün > 0, ya da `playerShareUnits == 0` — hepsi ön satışa gitmişse) oyuncu **"0 daire teslim alındı"** yazan bir **yeşil başarı** bildirimi görüp ekrandan atılıyor.

**Düzeltme:** `else` dalını `NotificationService.showError` yap, `context.pop()`'u `if (created.isNotEmpty)` içine al ve nedeni açıklayan ayrı bir anahtar ekle (`real_estate_finalize_failed`) — 7 dilde.

---

# D · İMAR & KAKS MASASI

## D1 · "Mimari Planı Onayla" butonu hiçbir şey kaydetmiyor — sahte onay

**Dosya:** [real_estate_construction_screen.dart:662-682](lib/presentation/screens/real_estate/real_estate_construction_screen.dart:662)

```dart
onPressed: isExceeded ? null : () {
  NotificationService.showSuccess(context, tr('real_estate_kaks_confirmed_toast'));  // "Plan onaylandı"
  setState(() { _selectedTabIndex = 0; });   // sadece sekme değiştiriyor
},
```

Buton hiçbir şey kaydetmiyor — `_workingMix` zaten `_updateMix` ile canlı güncelleniyor, `land.customUnitMix`'e yazılmıyor. "Plan onaylandı" bildirimi tamamen sahte. Ve A3'te görüldüğü gibi, plan hiçbir yere kaydedilmediği için pazarlık ekranı onu bulamıyor.

**Düzeltme:** Butona gerçek bir eylem bağla: `ref.read(gameProvider.notifier).saveUnitMix(land.id, _workingMix!)` — `RealEstateModel.customUnitMix`'e yazsın. Böylece hem onay gerçek olur hem A3 kendiliğinden çözülür.

## D2 · Emsal (KAKS) sınırı aşılabilir — imar kuralı yalnızca tavsiye

**Dosya:** [real_estate_construction_screen.dart:1272](lib/presentation/screens/real_estate/real_estate_construction_screen.dart:1272), [:1378](lib/presentation/screens/real_estate/real_estate_construction_screen.dart:1378)

`isExceeded` yalnızca Tab 1'deki onay butonunu devre dışı bırakıyor. Ama Tab "Mod"daki iki başlatma butonu `isExceeded`'i **hiç kontrol etmiyor** ve `_workingMix`'i olduğu gibi geçiriyor:
```dart
startContractorConstruction(land.id, customUnitMix: _workingMix);
startSelfBuildConstruction(land.id, customUnitMix: _workingMix);
```

Oyuncu emsali aşan bir plan çizip sekmeyi değiştirerek doğrudan inşaata başlayabiliyor. Kırmızı uyarı, gösterge çubuğu ve "EMSAL AŞILDI" rozeti tamamen dekoratif kalıyor — modülün ana kuralı uygulanmıyor.

**Düzeltme:** Kuralı **domain katmanına** taşı. `startContractorConstruction` ve `startSelfBuildConstruction` başına:
```dart
if (customUnitMix != null) {
  final zoning = ZoningEngine.calculateZoning(
      parcelSquareMeters: land.squareMeters.toDouble(), baseMarketValue: land.baseMarketValue,
      customUnitMix: customUnitMix);
  if (zoning.isEmsalExceeded) return false;
}
```
UI'da da butonları `isExceeded` ile devre dışı bırak ve nedenini yaz. Kuralın hem UI'da hem domain'de olması gerekiyor — sadece UI'da olursa D2 tekrar oluşur.

## D3 · Ekranda sabit kodlanmış Türkçe metinler

**Dosya:** [real_estate_construction_screen.dart:977](lib/presentation/screens/real_estate/real_estate_construction_screen.dart:977)

```dart
'Topraktan ön satış hakkı sadece öz-inşaat şantiyesi aktifken ve en az 2 daire payınız varken açılır.'
```
Ayrıca `'Taşeron Ekibi'` (varsayılan taşeron adı, [:1690](lib/presentation/screens/real_estate/real_estate_construction_screen.dart:1690) ve [:1747](lib/presentation/screens/real_estate/real_estate_construction_screen.dart:1747)) ve `'Arsa Parseli'` / `'İmarlı Arsa'` ([subcontractor_negotiation_chat_screen.dart:232-244](lib/presentation/screens/real_estate/subcontractor_negotiation_chat_screen.dart:232)).

Sohbet motorlarındaki yüzlerce replik de aynı durumda — bu, genel denetim raporundaki **C5** bulgusunun bu modüldeki somut örneği.

**Düzeltme:** Bu ekrandaki literal'leri anahtara çevir ve 7 dile ekle. Sohbet motorları için: motorlar **anahtar + parametre** döndürsün, UI çözümlesin (`market_engine`'deki `descriptionKey` deseni).

---

# Öncelik Sırası

| # | Bulgu | Neden önce | İş |
|---|---|---|---|
| 1 | **A1** Pay yüzdesi ters | Modülün merkezî mekaniği tersine çalışıyor • kayıt migration'ı gerektirdiği için **erken** yapılmalı | M |
| 2 | **C7** Vazgeçme yolu yok | Parası biten oyuncunun arsası kalıcı kilitleniyor — çıkmaz | S |
| 3 | **C1** Günlük bildirim spam'i | Her 2 dakikada bir aynı bildirim | S |
| 4 | **A3 + D1** Plan çöpe gidiyor | Pazarlıkla imzalayan tüm oyuncular tek tip daire alıyor • ikisi birlikte çözülür | S |
| 5 | **A8 + B2 + B3** Başarı bildirimi işlemden önce | Üç ekranda aynı kalıp • sessiz başarısızlık | S |
| 6 | **C3** En küçük daireler oyuncuya | "%50" gerçekte ~%30 değer | M |
| 7 | **B1** 1. etap iki kez ücretli | %10 fazla maliyet | XS |
| 8 | **A5** "Anlaş" koşulsuz kabul | Pazarlığın tamamı tiyatro | S |
| 9 | **B4** Dört farklı maliyet rakamı | `canAfford` yanlış kapıda | S |
| 10 | **C2** Slot limiti deliniyor | Portföy ekonomisi atlanıyor | XS |
| 11 | **B5** Fiyat tabanı yok | Etap başına ~%40 gizli indirim | S |
| 12 | **C4** Maliyet kâr muhasebesinde yok | `totalProfit` anlamsız | S |
| 13 | **A7** Beş taktik boşta | Verilen sözlerin karşılığı yok | M |
| 14 | **D2** Emsal aşılabilir | Modülün ana kuralı uygulanmıyor | S |
| 15 | **C8** Başarısızlıkta başarı bildirimi | — | XS |
| 16 | **A6** Sonsuz sabır | Pazarlık limitsiz | XS |
| 17 | **B6** Görünmez şantiye olayları | Ödenen ≠ anlaşılan | M |
| 18 | **B10 / B8** Eşik uyuşmazlığı & sınırsız etap | %100'de bitirme butonu yok | S |
| 19 | **C5** Sabit 1.8 katsayısı | KAKS değeri etkilemiyor | S |
| 20 | **A9** Müteahhit modu etkileşimsiz | 105 gün saf bekleme | M |
| 21 | **B7** Ölü alanlar & ters risk | 3 kademe tek boyutlu | S |
| 22 | **A4** Pazarlık dominated | A1+A3 sonrası yeniden dengelenmeli | S |
| 23 | **A10 / B9** Ölü paralel sistemler | Bakım borcu • A1'in kaynağı | XS |
| 24 | **C6 / D3** Fallback tipoloji & sabit metinler | — | S |

## Devralan ajan için notlar

1. **A1 önce, migration ile.** `contractorSharePercent` yeniden adlandırılırken `fromJson`'a dönüşüm eklenmezse devam eden projeler tersine döner. İlk iş bu, çünkü diğer düzeltmeler (`C3` dağıtım, `A7` şart alanları) bu alanın anlamına dayanıyor.

2. **Üç ekranda aynı sıralama hatası var** (`A8`, `B2`, `C8`): *başarı bildirimi → işlem* sırası. Tek bir kalıpla düzeltilmeli: **işlem → dönüş değeri kontrolü → ses/toast → navigasyon**. Bu kalıbı diğer sohbet ekranlarında da (`real_estate_buyer_negotiation_chat_screen`, `real_estate_tenant_negotiation_chat_screen`) kontrol et — büyük ihtimalle aynı kopya var.

3. **Kural hem UI'da hem domain'de olmalı.** `D2` (emsal) ve `B3` (şantiye kurulmadan taşeron) aynı kökten: kural sadece butonun `onPressed`'inde. UI kuralı kullanıcıya *açıklamak*, domain kuralı *uygulamak* için var.

4. **Bu modülde de tek doğruluk kaynağı sorunu var:** etap maliyeti 4 yerde, süre çarpanı 2 yerde (`durationMultiplier` + `calculateStageDays` switch), tamamlanma eşiği 2 yerde (9 vs 8), müteahhit kadrosu 2 yerde, pay semantiği 3 yerde. Düzeltirken kopya ekleme — mevcutları birleştir.

5. **Test önerisi.** Şu üç senaryo `test/` altına eklenmeli:
   - *"%55 pazarlıkla imzalanan 10 daireli projede oyuncu 5 daire alır"* (A1)
   - *"Pazarlık ekranından imzalanan sözleşmede `customUnitMix` korunur"* (A3)
   - *"Etap 8 tamamlandıktan sonra 10 gün ilerlet → yalnızca 1 adet 'Şantiye Tamamlandı' olayı üretilir"* (C1)

---

# E · ÖNERİLEN AKIŞ SIRALAMASI & DERİNLİK TASARIMI

Bu bölüm bir bulgu listesi değil, **uygulama şartnamesi**. Amaç iki şey: oyuncu ekrana girdiğinde **her an tek bir "şimdi ne yapmalıyım" cevabı görsün**, ve o cevabı verirken **bir şey kazandığını / riske attığını hissetsin**.

Şu anki sorun: ekranda 3 sekme, 2 mod kartı, 4 buton aynı anda açık; hangisinin önce geldiği belli değil; bir kısmı hiçbir şey yapmıyor (D1), bir kısmı sessizce başarısız oluyor (B3). Oyuncu "ne oldu şimdi?" diye çıkıyor.

## E0 · Ortak giriş: tek durum makinesi

Arsa ekranı **her zaman tek bir duruma** karşılık gelmeli ve o durum **tek bir birincil butonu** açmalı. `RealEstateModel`'e tek bir getter ekle ve tüm UI onu okusun:

```dart
enum LandPhase { imar, modSecimi, muteahhitBekleme, etapHazir, etapCalisiyor, etapTeslimAlinir, teslimeHazir, tamamlandi }
LandPhase get landPhase { ... }
```

| Faz | Ekranda tek birincil buton | Kilitli olan |
|---|---|---|
| `imar` | **"Mimari Planı Onayla"** | mod kartları, taşeron |
| `modSecimi` | **"Müteahhitle Görüş"** / **"Kendi Şantiyeni Kur"** (2 eşit kart) | taşeron **(B3)** |
| `muteahhitBekleme` | *buton yok* — geri sayım + olay kartı | — |
| `etapHazir` | **"N. Etap için Taşeron Seç"** | ön satış devam eder |
| `etapCalisiyor` | *buton yok* — geri sayım + şantiye telsizi | taşeron ekranı |
| `etapTeslimAlinir` | **"Etabı Teslim Al"** | yeni taşeron |
| `teslimeHazir` | **"Anahtar Teslim • N Daire"** | — |
| `tamamlandi` | ekran kapanır, portföye yönlendirir | — |

**Kural:** Aynı anda birden fazla birincil buton görünmesin. İkincil eylemler (ön satış, projeden vazgeç) ayrı ve gri olsun. Bu tek değişiklik, A4/B3/B10'daki kafa karışıklığının çoğunu bitirir.

## E1 · Kat karşılığı yolu — 6 adım

Bugün: *sözleşme imzala → 105 gün bekle → teslim al.* Ortada karar yok.

Önerilen sıra:

**1. İmar Etüdü** *(zorunlu, ilk adım)*
Parselin KAKS/TAKS'ı hesaplanır, oyuncu tipoloji karmasını kurar ve **gerçekten kaydeder** (D1). Emsal aşılırsa ilerlenemez (D2).
→ *Kanca:* "Bu parsele 12 daire sığıyor" cümlesi ilk heyecan noktası. Rakam büyüdükçe oyuncu daha iyi bir plan kurmak ister.

**2. İhale Masası** *(yeni)*
Tek müteahhit yerine **3 müteahhit aynı anda teklif versin** — farklı pay, farklı süre, farklı güvenilirlik. `ContractorNegotiationExpansion`'daki 5 profil zaten var, sadece üçünü rastgele seçip yan yana koymak yeterli.
→ *Kanca:* Karşılaştırma = karar. Tek teklif varsa "kabul et"ten başka seçenek yok; üç teklif varsa oyuncu düşünmek zorunda.

**3. Pazarlık** *(A1, A5, A6, A7 düzeltilmiş haliyle)*
Pay yüzdesi doğru yönde çalışsın; "Anlaş" memnuniyet eşiğine bağlansın; sohbet taktiği azalan verimli olsun; **beş vaadin karşılığı sözleşmeye yazılsın**.
→ *Kanca:* Sözleşme imzalanmadan önce bir **özet kartı**: "Payınız: 6/12 daire • Üst katlar sizde • Peşin avans ₺350.000 • Teslim 98 gün". Oyuncu ne kazandığını tek bakışta görsün.

**4. Şantiye Dönemi** *(A9 — bugün tamamen boş)*
105 gün bekleme yerine **3 karar noktası**:
- **Etap 3'te** müteahhit ek talep eder: *"demire zam geldi, ya %3 pay ya ₺X nakit."* Reddedersen +10 gün.
- **Etap 5'te** komşu itirazı / belediye denetimi: rüşvet, bekleme veya avukat.
- **Teminat mektubu yoksa** %8 ihtimalle müteahhit şantiyeyi bırakır → proje etap 3'e döner, yeni ihale açılır.
→ *Kanca:* Bekleme süresi "boş zaman" olmaktan çıkıp **gerilim** olur. A7'deki teminat mektubu taktiği de böylece anlam kazanır.

**5. Anahtar Teslim** *(C1, C2, C3, C8)*
Bildirim spam'i biter, slot kontrolü yapılır, daireler **değer olarak adil** dağıtılır.
→ *Kanca:* Teslim ekranında dairelerin tek tek listelendiği kısa bir animasyon: "Daire 3 • 3+1 • ₺4.2M". Bu, oyunun en büyük tek ödül anı — şu an sadece bir toast.

**6. Portföy**
Daireler tek tek kiralanabilir/satılabilir hale gelir.
→ *Kanca:* "12 dairenin 6'sı sizin" ifadesi portföy ekranında bir rozet olsun.

## E2 · Öz-inşaat yolu — 7 adım

Bugün adımlar var ama fiyat 4 farklı yerde farklı (B4), ödeme iki kez alınıyor (B1), olaylar görünmüyor (B6).

Önerilen sıra:

**1. İmar Etüdü** — kat karşılığıyla aynı, ortak adım.

**2. Fizibilite Tablosu** *(yeni, zorunlu okuma adımı)*
Şantiyeyi kurmadan önce oyuncu **tam maliyeti** görsün:
```
Toplam inşaat bütçesi:  ₺8.000.000   (8 etap)
Bugünkü bakiyeniz:      ₺3.200.000
Ön satışla toplayabileceğiniz: ₺2.400.000  (3 daire)
DURUM: Bütçe yetersiz • 3. etapta duraksama riski
```
→ *Kanca:* Bu tablo hem **B4**'ü (dört farklı rakam) hem **C7**'yi (parası bitince kilitlenme) baştan çözer. Ve oyuncuya "yetecek mi?" gerilimini en başta verir — girmeden önce hesap yapar.

**3. Şantiye Kurulumu** — ruhsat bedeli **bir kez** alınır (B1), faz `etapHazir` olur, taşeron butonu **ancak burada** açılır (B3).

**4. Taşeron Seçimi & Pazarlık** *(B5, B7)*
3 kademe gerçekten farklı hissettirsin:

| Kademe | Maliyet | Süre | Risk | Ek |
|---|---|---|---|---|
| **Hızlı** | 1.25× | 0.75× | **yüksek** | işçilik hatası ihtimali |
| **Standart** | 1.00× | 1.00× | orta | — |
| **Ekonomik** | 0.80× | 1.25× | **düşük ama yavaş** | teslimde eksik iş çıkabilir |

Bugün "hızlı" hem hızlı hem en güvenli — tek boyutlu. Yukarıdaki gibi her kademenin bir bedeli olmalı. Pazarlıkta fiyat tabanı `%75` olsun (B5).
→ *Kanca:* Aynı etabı iki farklı taşeronla iki farklı sonuçla yaşamak, tekrar oynanabilirlik demek.

**5. Etap Çalışması** *(B6)*
Şantiye olayı **imza anında değil, çalışma sırasında** çıksın ve **dialog olarak gösterilsin** — seçimli:
> *"Demire zam geldi. Sözleşme fiyatının üzerine ₺240.000 istiyorlar."*
> **[Zammı Öde]** · **[Ucuz Demirle Devam — kalite düşer]** · **[İşi Durdur — +5 gün]**

→ *Kanca:* Şu an oyuncunun parası sessizce eksiliyor. Seçim haline gelince aynı olay hem anlaşılır hem gerilimli olur.

**6. Ön Satış** *(C3)*
Nakit sıkışınca "topraktan daire sat" gerçek bir kurtarma hamlesi olsun: **hangi daireyi** sattığını göstersin, fiyat tipolojiye göre hesaplansın, ve **büyük daireyi değil küçüğü** feda etsin.
→ *Kanca:* "Şimdi ucuza sat ve şantiyeyi kurtar mı, dişini sık ve tam fiyatına sat mı?" — modülün en iyi kararı, şu an gizli.

**7. Anahtar Teslim** — kat karşılığıyla aynı, ama **12/12 daire** oyuncunun.
→ *Kanca:* İki yolun farkı burada patlasın: *"Kat karşılığında 6 daire alırdın. Kendi göbeğini kestin: 12."*

## E3 · İki yol birbirinden gerçekten ayrışmalı

Şu an ikisi de aynı ekranda, aynı ilerleme çubuğuyla ilerliyor; fark sadece para. Fark **his** olarak da kurulmalı:

| | **Kat Karşılığı** | **Öz-İnşaat** |
|---|---|---|
| Rol | Ortak — *pazarlıkçı* | Patron — *yönetici* |
| Nakit | ₺0 çıkış, avans **girişi** | Ağır çıkış, ön satışla nefes |
| Karar sayısı | 1 ihale + 3 olay | 8 taşeron + 8 olay + ön satış |
| Risk | Müteahhit bırakabilir | Para bitebilir |
| Kazanç | %40–60 daire | %100 daire |
| Süre | ~105 gün sabit | 86 gün, taşerona göre ±%25 |
| Kime | Erken oyun, sermayesiz | Geç oyun, sermayeli |
| Tek cümle | *"Arsa senden, inşaat benden."* | *"Kendi göbeğini kendin kes."* |

Ekranda mod seçimi bu iki cümleyle sunulsun, teknik tabloyla değil. Oyuncu hangisini seçtiğini **hissederek** seçsin.

## E4 · Kafa karışıklığını bitiren 5 küçük kural

1. **Her ekranda tek birincil buton** (E0). İkincil eylemler gri ve küçük.
2. **Her buton bir sonraki adımı adıyla söylesin:** "İleri" değil, **"3. Etap için Taşeron Seç • ₺1,76M"**.
3. **Kilitli her buton nedenini yazsın.** `onPressed: null` + boz gri yeterli değil — altına "Önce şantiyeyi kur" satırı gelsin. (B3, D2)
4. **Hiçbir işlem sessiz başarısız olmasın.** İşlem → dönüş kontrolü → ses/toast → navigasyon. (A8, B2, C8)
5. **İlerleme çubuğu yalan söylemesin.** %100 gösterip bitirme butonu vermeyen durum kalmasın. (B10)

## E5 · Devralan ajan için uygulama sırası

Bu bölümü **A/B/C/D düzeltmelerinden sonra** uygula — bozuk mekaniğin üzerine akış tasarımı kurulmaz.

| Sıra | İş | Bağımlılık |
|---|---|---|
| 1 | `LandPhase` durum makinesi + tek birincil buton kuralı (E0) | A1, B3, B10 düzeltilmiş olmalı |
| 2 | Fizibilite tablosu (E2·2) | B1, B4 |
| 3 | Şantiye olayı dialogu (E2·5) | B6 |
| 4 | Ön satış tipoloji gösterimi (E2·6) | C3 |
| 5 | Sözleşme özet kartı (E1·3) | A1, A7 |
| 6 | Müteahhit ihale masası — 3 teklif (E1·2) | A1, A4 |
| 7 | Şantiye dönemi karar noktaları (E1·4) | A7, A9 |
| 8 | Teslim animasyonu + iki yol karşılaştırma cümlesi (E1·5, E2·7) | C1, C2, C3 |

Adım 1–4 "kafa karışmasın", adım 5–8 "heyecanlansın" tarafı. **Sırayı bozma:** oyuncu önce ne yapacağını anlamalı, sonra heyecanlanmalı. Her yeni metin `AGENTS.md` #8 gereği aynı commit'te 7 dile eklenmeli.

---

# F · GERÇEKÇİLİK & DERİNLİK: NEYİ DİNAMİKLEŞTİRELİM

Modülün en büyük yapısal zayıflığı şu: **inşaat sistemi oyunun geri kalanından tamamen kopuk.** İçinde hava durumu yok, piyasa yok, itibar yok, personel yok, rakip yok, kredi yok, NPC yok. Oysa bunların **hepsi oyunda zaten var ve çalışıyor** — sadece inşaata bağlanmamış.

Bu bölüm iki soruya cevap veriyor: **(F1–F2)** hangi sabit sayıyı neye bağlayacağız, **(F3–F5)** hangi yeni katmanı ekleyeceğiz.

## F1 · Şu an sabit olan 14 sayı ve dinamik karşılığı

| # | Sabit | Nerede | Dinamik olmalı |
|---|---|---|---|
| 1 | Müteahhit etap süresi **15 gün** | [game_time_mixin.dart:763](lib/presentation/providers/game/game_time_mixin.dart:763) | Müteahhit profilinin `durationMultiplier`'ı × parsel ölçeği × hava × malzeme endeksi |
| 2 | KAKS **2.10/1.80/1.50** yalnız m²'ye bakıyor | [zoning_engine.dart:232](lib/domain/usecases/zoning_engine.dart:232) | **İlçeye göre** imar planı — Maslak yüksek emsal, Kadıköy düşük. `district` zaten modelde var |
| 3 | TAKS **0.35/0.30** | [zoning_engine.dart:231](lib/domain/usecases/zoning_engine.dart:231) | Aynı — ilçe imar tablosundan |
| 4 | Daire değeri çarpanı **2.8** | [game_real_estate_mixin.dart:1110](lib/presentation/providers/game/game_real_estate_mixin.dart:1110) | İlçe talebi + `districtMarketShare` + inşaat kalitesi |
| 5 | Alan bölen **1.8** | aynı satır | Gerçek `zoning.netResidentialArea` (bkz. **C5**) |
| 6 | Ön satış iskontosu **0.75** | [real_estate_model.dart:234](lib/data/models/real_estate_model.dart:234) | Etaba göre: etap 2'de 0.65 *(riskli, ucuz)* → etap 7'de 0.92 *(neredeyse bitmiş)* |
| 7 | Anahtar teslim çarpanı **2.5** | [real_estate_model.dart:238](lib/data/models/real_estate_model.dart:238) | Piyasa haberi + ilçe + kalite şartnamesi |
| 8 | Şantiye olayı olasılığı **%22** | [construction_negative_events_engine.dart:32](lib/domain/usecases/construction_negative_events_engine.dart:32) | Etaba göre değişsin: hafriyat/kaba yapı riskli, ince işler sakin. + hava + taşeron güvenilirliği |
| 9 | Etap maliyet yüzdeleri **sabit tablo** | [construction_timeline_engine.dart:91-144](lib/domain/usecases/construction_timeline_engine.dart:91) | Yüzdeler kalsın, ama **malzeme endeksi** ile çarpılsın (F3·2) |
| 10 | Taşeron kadrosu **3 sabit profil** | [construction_timeline_engine.dart:207-236](lib/domain/usecases/construction_timeline_engine.dart:207) | Her etapta 3–5 arasında **rastgele havuzdan** çekilsin; isim, fiyat ve güvenilirlik dalgalansın |
| 11 | Müteahhit teklifi **tek** | `contractor_negotiation_chat_screen` | 3 eşzamanlı teklif (E1·2) |
| 12 | Pay tavanı **55** | [real_estate_chat_negotiation_engine.dart:106](lib/domain/usecases/real_estate_chat_negotiation_engine.dart:106) | Oyuncu itibarı + parselin çekiciliği + ilçe rekabeti |
| 13 | Ruhsat bedeli **%10** | [game_real_estate_mixin.dart:846](lib/presentation/providers/game/game_real_estate_mixin.dart:846) | Belediye/ilçe harcı + hukuk müşaviri personeli varsa indirim |
| 14 | Slot kapasitesi kontrolsüz | [game_real_estate_mixin.dart:1141](lib/presentation/providers/game/game_real_estate_mixin.dart:1141) | Sözleşme anında rezervasyon (**C2**) |

**Genel kural:** Hiçbir ekonomik sayı doğrudan `baseMarketValue`'nun sabit bir yüzdesi olarak kalmasın. Her biri en az **bir** oyun durumundan beslensin.

## F2 · Oyunda zaten var, inşaata bağlanmamış 8 sistem ⭐ en yüksek getiri

Bunlar **yeni sistem değil** — mevcut state alanlarını okumak yeterli. En ucuz derinlik buradan gelir.

| Mevcut sistem | Şu an inşaatta | Nasıl bağlanmalı |
|---|---|---|
| **`state.currentWeather`** *(WeatherEngine)* | hiç okunmuyor | Yağmur/kar → beton dökümü durur. Etap 2–3'te `constructionDaysRemaining` **artmasın, azalmasın** o gün. Şantiye telsizinde: *"Bugün beton santrali kapalı, mikserler bekliyor."* **Bu aynı zamanda genel rapordaki C1'i (hava durumu tamamen dekoratif) çözer.** |
| **`state.districtMarketShare`** | hiç okunmuyor | İlçedeki pazar payın yüksekse müteahhitler **daha iyi pay** teklif etsin, daireler daha hızlı satılsın. Zaten `game_market_mixin`'de araç tarafında bu desen var |
| **`state.npcRelationships`** | hiç okunmuyor | Müteahhitler kalıcı NPC olsun. İkinci projede: *"Geçen sefer sözümüzde durduk, bu sefer %3 fazla veriyoruz."* İlişki düşükse teklif vermesin. `DramaticCardEngine`'deki NPC güncelleme deseni hazır |
| **`state.reputationScore`** | hiç okunmuyor | İtibar yüksekse pay tavanı 55 → 60'a çıksın, teminat mektubu kabul oranı artsın |
| **`state.hiredStaff`** *(legalAdvisor rolü var!)* | hiç okunmuyor | Hukuk müşaviri varsa ruhsat etabı **%30 kısalsın**; usta varsa şantiye olayı riski düşsün. Personel sistemine yeni bir amaç kazandırır |
| **`state.activeLoans` / `bankCreditLimit`** | hiç okunmuyor | **İnşaat kredisi:** etap etap çekilen, teminatı arsa olan özel kredi türü. Öz-inşaatın "para bitti" çıkmazının (C7) doğru çözümü bu |
| **`state.activeNews`** *(MarketNewsModel)* | hiç okunmuyor | *"Demir ithalatına ek vergi"* haberi → o hafta tüm etap maliyetleri **×1.15**. Haber sistemi zaten günlük çalışıyor |
| **`skills.financeSense` / `negotiationLevel`** | hiç okunmuyor | Pazarlık becerisi taşeron/müteahhit pazarlığında etkili olsun *(araç tarafındaki gibi)*. Şu an emlak pazarlığı beceriden tamamen bağımsız |

**Öncelik:** Hava durumu ve inşaat kredisi ilk ikisi. Hava, bekleme süresine dokunulabilir bir doku katar; kredi, öz-inşaatın en büyük tasarım açığını kapatır.

## F3 · Eklenecek 4 yeni katman

**1. Bürokrasi & Ruhsat *(gerçekçilik omurgası)***
Ruhsat şu an tek tıkla alınan bir ödeme. Gerçekte: proje onayı → itiraz süresi → harç → ruhsat. Öneri: ruhsat etabında **%25 ihtimalle** bir engel çıksın — komşu itirazı, çekme mesafesi düzeltmesi, otopark yönetmeliği. Her biri para **veya** gün maliyeti, hukuk müşaviri varsa atlanabilir.
→ *Getiri:* Türkiye'de inşaatın en tanıdık dramı bu; oyunun kültürel tonuna birebir oturur.

**2. Malzeme Fiyat Endeksi *(tek sayı, her yere dokunuyor)***
`double constructionCostIndex` — 0.85 ile 1.35 arasında gezinen, günlük küçük adımlarla değişen ve `activeNews`'ten sıçrayan tek bir global çarpan. Tüm etap maliyetleri bununla çarpılsın; ekranda son 7 günlük mini grafik gösterilsin.
→ *Getiri:* **Zamanlama kararı doğar.** "Endeks 1.28, bekleyeyim mi?" Bugün inşaatta hiçbir zamanlama kararı yok. Tek alan, en büyük derinlik.

**3. Kalite & Gizli Kusur *(uzun vadeli sonuç)***
Her etabın bir `qualityScore`'u olsun (taşeron kademesi + olay seçimleri + malzeme kısıntısı). Ortalama kalite:
- **Daire değerini** ±%15 etkilesin,
- Düşük kaliteli binada teslimden sonra **gizli kusur** çıksın *(su kaçağı, cephe çatlağı)* — `hasWaterLeakRisk` mekanizması tadilatta zaten var, aynısı kullanılsın.
→ *Getiri:* "Ucuza kaç" kararının bedeli 50 gün sonra geri gelir. Oyunun en güçlü hafıza mekaniği.

**4. Rakip Müteahhit / Rakip Proje**
`RivalLeaderboardEngine` zaten var. İnşaat sürerken: *"Karşı parselde Öz-Gözde İnşaat 14 daire çıkarıyor, 20 gün önce bitiriyor."* Rakip önce biterse ilçedeki daire fiyatları **%8 düşer**.
→ *Getiri:* Süre baskısı. Şu an hızlı bitirmenin hiçbir ödülü yok — hız kademesine ödemek anlamsız.

## F4 · Kat karşılığına özel derinlik

Bu yolun teması **güven ve pazarlık** olmalı; sayı yönetimi değil.

- **Sözleşme şartları kalıcı olsun** (A7). Beş taktiğin çıktısı `RealEstateModel`'de saklansın: üst kat tahsisi, C35 şartnamesi, nakit avans, teminat mektubu, çift vardiya. Her biri teslimde somut fark yaratsın.
- **Müteahhidin sicili görünsün.** Profilde "tamamladığı proje: 3, geciken: 1" gibi bir geçmiş; `npcRelationships` üzerinden oyuncunun kendi geçmişiyle birleşsin.
- **Sözleşme feshi riski.** Teminat mektubu yoksa terk ihtimali (E1·4). Terk edilirse arsa **etap 3'e döner** ve yeni ihale açılır — teminat mektubu taktiği o anda hayat kurtarır.
- **Pay yerine "daire seçimi" pazarlığı.** Asıl gerilim yüzde değil, **hangi daireler**. Sözleşme sonunda kısa bir "daire seçim turu": müteahhit ve oyuncu sırayla seçsin. C3'teki adaletsizliği hem çözer hem oyunlaştırır.
- **İkinci parselde referans etkisi.** İyi geçmişse aynı müteahhit daha iyi teklifle gelsin; kötü ayrıldıysanız ilçedeki tüm müteahhitler %2 kötü teklif versin.

## F5 · Öz-sermayeye özel derinlik

Bu yolun teması **nakit akışı ve risk yönetimi** olmalı.

- **İnşaat kredisi** (F2). Etap etap çekilen, teminatı arsa olan kredi. Ödenmezse **arsaya el konur** — öz-inşaatın gerçek kaybetme koşulu bu olsun, sessiz kilitlenme (C7) değil.
- **Nakit akışı paneli.** Ekranda sürekli görünen üç sayı: kalan bütçe, kalan etap maliyeti, ön satışla toplanabilecek. Fizibilite tablosunun (E2·2) canlı hali.
- **Ön satış piyasası.** Sabit fiyat yerine **alıcı gelsin**: etaba, kaliteye ve ilçeye göre teklif versin, pazarlık edilebilsin. `real_estate_buyer_negotiation_expansion` motoru hazır — yeniden kullanılabilir.
- **Etap atlatma / hızlandırma.** Ekstra para ile etabı kısaltma (`rushRenovation` deseni tadilatta zaten var) — ama kalite düşsün. Zaman/para/kalite üçgeni tamamlanır.
- **Kendi personelini kullanma.** Usta çalışan varsa bir etabı taşeronsuz yap: **%40 ucuz, %50 yavaş.** Personel sistemi ile inşaat arasında ilk gerçek bağ.
- **Etap teslim denetimi.** "Teslim Al" tek tık olmasın: kısa bir kontrol *(3 kalem: demir, şakül, yalıtım)*. Eksik bulursan taşeron ücretsiz düzeltir **+3 gün**; atlarsan `qualityScore` düşer. Zeigarnik etkisi ve oyuncu failliği.

## F6 · Uygulama sırası

| Sıra | İş | Neden bu sırada | Maliyet |
|---|---|---|---|
| 1 | **Hava durumu → şantiye gecikmesi** (F2) | Tek `if`; hem derinlik hem genel rapordaki C1'i kapatır | XS |
| 2 | **Malzeme fiyat endeksi** (F3·2) | Tek alan, tüm maliyetlere dokunur, zamanlama kararı doğurur | S |
| 3 | **İnşaat kredisi** (F2, F5) | C7'nin doğru çözümü; öz-inşaatı oynanabilir kılar | M |
| 4 | **İlçe bazlı KAKS/TAKS ve daire değeri** (F1·2-4) | KAKS ekranını gerçekten anlamlı yapar | S |
| 5 | **Kalite & gizli kusur** (F3·3) | Taşeron kademesi kararına ilk kez sonuç verir | M |
| 6 | **Sözleşme şartlarının kalıcılığı** (F4, A7) | Beş ölü taktiği canlandırır | M |
| 7 | **Bürokrasi & ruhsat engelleri** (F3·1) | Kültürel ton; ruhsat etabını doldurur | M |
| 8 | **Ön satış piyasası & daire seçim turu** (F4, F5) | Modülün en iyi iki kararı | M |
| 9 | **Personel entegrasyonu** (F2, F5) | İki sistemi birbirine bağlar | S |
| 10 | **Rakip proje** (F3·4) | Süre baskısı; hız kademesine anlam katar | M |

**İlk üç madde tek başına modülün karakterini değiştirir:** hava dokusu verir, endeks zamanlama kararı verir, kredi ise "para bitti" çıkmazını gerilime çevirir. Gerisi bunların üstüne kurulur.

**Uyarı:** F, **A/B/C/D düzeltmelerinden ve E akış sıralamasından sonra** gelir. Ters bağlı bir pay yüzdesinin (A1) üstüne malzeme endeksi eklenirse iki hata birbirini gizler ve ayıklanamaz hale gelir. Her yeni sayı ekranda gösterildiği anda `AGENTS.md` #8 gereği 7 dile de eklenmeli.

---

*Bu rapor yalnızca kaynak kod okumasına dayanır. Hiçbir dosya değiştirilmedi.*
