# Galerisinden — Sistemde Var Ama Kullanılamayan Özellikler Raporu

**Konu:** Kodda tam olarak yazılmış ama oyuncunun erişemediği özellikler, fonksiyonlar ve alt sistemler.
**Tetikleyici:** Kullanıcının tespiti — *"kredi çek var ama çekilemiyor"*. Bu doğru çıktı ve sistematik tarama aynı desende **12 alt sistem daha** ortaya çıkardı.
**Kapsam:** Yalnızca rapor. Kod okundu, hiçbir dosya değiştirilmedi.

---

## Özet

Sizin bulduğunuz kredi sorunu izole bir hata değil — **tekrar eden bir desenin** örneği:

> Alt sistem baştan sona yazılıyor (model + JSON + iş mantığı + arayüz bölümü + ödül entegrasyonu), ama **oyuncunun sistemi başlatacağı tek buton** hiç eklenmiyor.

En çarpıcı örnek kredi değil, **parça sipariş sistemi**: model, sipariş tipleri, kargo süresi, montaj mantığı, atölye ekranındaki liste bölümü, dashboard rozeti, ödüllü reklam hızlandırma noktası ve tutorial'ın 3 adımı — hepsi yazılmış. Sipariş verme butonu yok. Dolayısıyla `pendingOrders` listesi **hiçbir zaman dolmuyor** ve bu sistemin tamamı ölü.

Toplam bulgu: **4 tamamen erişilemez alt sistem**, **6 yarım bağlanmış özellik**, **7 ölü dosya (~4.000 satır)**, **8 ölü fonksiyon**, **5 ölü veri alanı**.

---

# A. TAMAMEN ERİŞİLEMEZ ALT SİSTEMLER

## A1 · Banka Kredisi — Sizin Tespitiniz ✅

**Dosya:** [game_finance_mixin.dart](lib/presentation/providers/game/game_finance_mixin.dart)

`takeBankLoan()` fonksiyonuna **hiçbir ekrandan çağrı yok.** Doğrulandı.

Ama kredi sisteminin geri kalanı eksiksiz kurulmuş:

| Parça | Durum |
|---|---|
| `LoanModel` (model + JSON serileştirme) | ✅ Yazılmış |
| Faiz oranları (3 ay %10 / 6 ay %18 / 12 ay %28) | ✅ Yazılmış |
| Maks. 3 aktif kredi kuralı | ✅ Yazılmış |
| Haftalık otomatik taksit kesintisi | ✅ [game_time_mixin.dart:133](lib/presentation/providers/game/game_time_mixin.dart:133) çalışıyor |
| `financeSense` yeteneği faiz indirimi | ✅ [game_finance_mixin.dart:20](lib/presentation/providers/game/game_finance_mixin.dart:20) uygulanıyor |
| Haftalık etkinlik (Pazartesi %20 faiz indirimi) | ✅ Yazılmış |
| İflas kurtarmada borç silme | ✅ Yazılmış |
| **Kredi çekme butonu** | ❌ **YOK** |

Sonuç: `activeLoans` listesi hiçbir zaman dolmuyor. Haftalık taksit döngüsü, faiz indirimi yeteneği, Pazartesi etkinliği ve borç silme mekanizması — hepsi hiç tetiklenmeyen kod.

**Ek çelişki:** `payLoanInstallment()` (erken/manuel taksit ödeme) da 0 çağrı. Ve `bankCreditLimit` alanı [bank_investments_screen.dart:390](lib/presentation/screens/finance/bank_investments_screen.dart:390) üzerinden **ücret ödenerek yükseltilebiliyor** — oyuncu asla kullanamayacağı bir kredi limitini para vererek büyütüyor.

## A2 · Parça Sipariş Sistemi ⭐ *en büyük ölü sistem*

**Dosya:** [game_market_mixin.dart:511](lib/presentation/providers/game/game_market_mixin.dart:511)

`orderPart()` → **0 çağrı.** Ve bu fonksiyon, `pendingOrders` listesine yazan **tek kaynak.** Dolayısıyla liste kalıcı olarak boş.

Bu tek eksik butonun arkasında duran ölü içerik:

| Parça | Konum | Sonuç |
|---|---|---|
| `PartOrderModel` + `OrderType` (Geçici Yama / Usta Onarımı / Sıfır OEM) | data/models | Hiç örneklenmiyor |
| Dinamik parça maliyet hesabı (araç değerine göre, 6 parça kategorisi) | `RepairEngine.calculatePartRepairCost` | Hiç çağrılmıyor |
| Kargo bekleme süresi & teslimat sayacı | `PartOrderModel.isDelivered` | Hiç işlemiyor |
| **Atölye "BEKLEYEN PARÇA SİPARİŞLERİ" bölümü** | [workshop_screen.dart:384](lib/presentation/screens/workshop/workshop_screen.dart:384) | Hiç görünmüyor |
| `AnimatedOrderCard` widget'ı | presentation/widgets | Hiç render edilmiyor |
| **Dashboard "$X Sipariş" rozeti** | [dashboard_services_grid.dart:86](lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart:86) | Hiç görünmüyor |
| **Ödüllü reklam: "Kargoyu hızlandır"** | `instantDeliverPartOrder` | **Para kazandıran reklam noktası hiç tetiklenmiyor** |
| Çıkış kancası metni: *"X parça siparişi yolda"* | [psychology_engine.dart:101](lib/domain/usecases/psychology_engine.dart:101) | Hiç yazılmıyor |
| **Tutorial adımları 4-5-6** (`orderPart`, `waitDelivery`, `installPart`) | [tutorial_provider.dart:9-11](lib/presentation/providers/tutorial_provider.dart:9) | Tamamlanamaz |

`installDeliveredPart()` ve `instantDeliverPartOrder()` fonksiyonları arayüze **bağlı** — yani oyuncu parça monte edebiliyor ve kargo hızlandırabiliyor, ama **hiç sipariş veremiyor.** Zincirin ortası ve sonu var, başı yok.

## A3 · Kademeli Usta Onarımı (RepairTier) — Risk/Ödül Mekaniği

**Dosya:** [repair_engine.dart](lib/domain/usecases/repair_engine.dart), [game_inventory_mixin.dart](lib/presentation/providers/game/game_inventory_mixin.dart)

`repairBodyPartWithTier()` ve `repairEngineWithTier()` → **0 çağrı.**

Bu fonksiyonlar `RepairEngine`'in en zengin mekaniğini kullanıyor:

| Usta kademesi | Maliyet çarpanı | Başarı oranı |
|---|---:|---:|
| Çırak | ×0.55 | **%68** |
| Kalfa | ×1.00 | **%88** |
| Usta | ×1.75 | **%100** |

Başarısızlık durumunda özel mesajlar bile yazılmış: *"Çırak usta boyayı tutturamadı, renk dalgalanması oldu!"*, *"Motor rektefiye sırasında ayar tutturulamadı."*

Bunun yerine arayüz `performWorkshopStationRepair()` kullanıyor — **sabit fiyat, %100 başarı, risk yok.** Yani oyunun tek gerçek "kumar" onarım mekaniği (ucuz çırağa mı verirsin, pahalı ustaya mı) tamamen devre dışı.

## A4 · Tutorial Sistemi — Onboarding Tarafından Anında Atlanıyor

**Dosyalar:** [tutorial_provider.dart](lib/presentation/providers/tutorial_provider.dart), [tutorial_overlay.dart](lib/presentation/widgets/tutorial_overlay.dart), [onboarding_screen.dart:72](lib/presentation/screens/onboarding/onboarding_screen.dart:72)

12 adımlı bir tutorial sistemi yazılmış (`TutorialStep` enum'u, her adım için Türkçe yönerge metni, `TutorialOverlay` widget'ı). Ama:

```dart
// onboarding_screen.dart:72
ref.read(tutorialProvider.notifier).skipTutorial();
```

Onboarding, tutorial'ı **doğrudan atlıyor.** Sonuç:
- `TutorialOverlay` widget'ı **hiçbir dosyadan import edilmiyor** — hiç render edilmiyor
- `advanceTutorialStep()` → 0 çağrı
- `tutorialStepIndex` alanı kaydediliyor ama hiç okunmuyor
- 12 adımlık yönerge metinlerinin hiçbiri gösterilmiyor

**Buna rağmen** `completeTutorial()` çalışıyor ve ilk satışta oyuncuya **+₺50.000 "tutorial tamamlama bonusu"** veriyor — hiç görmediği bir tutorial için.

---

# B. YARIM BAĞLANMIŞ ÖZELLİKLER

| # | Özellik | Yazılmış olan | Bağlı olan | Sonuç |
|---|---|---|---|---|
| B1 | **Kredi taksiti ödeme** | `payLoanInstallment()` | — | Manuel/erken ödeme yok (yalnızca otomatik haftalık) |
| B2 | **Kredi limiti** | Ücretle yükseltiliyor | Hiçbir şeyi sınırlamıyor | Oyuncu işe yaramaz bir limite para ödüyor |
| B3 | **Yıkama & Cila** | `washAndPolishCar()` (₺300 + ₺800, ayrı ayrı) | `performWashService()` (paket) | Ayrı yıkama/cila seçeneği yok |
| B4 | **Detaylı temizlik** | `detailCleanCar()` (₺2.500) | `performWashService()` | Ölü |
| B5 | **Detay opsiyonları** | `applyDetailingOption()` + `DetailingOption` modeli | — | `appliedDetailingOptionIds` araç değerini +%6/adet artırıyor ama hiç uygulanamıyor |
| B6 | **İlan beyan tipi (kısayol)** | `updateCarListingDeclaration()` | `updateCarListingDetails()` | Mükerrer, ölü sarmalayıcı |

---

# C. ÖLÜ DOSYALAR

Hiçbir dosyadan `import` edilmeyen kaynaklar:

| Dosya | Satır | İçerik |
|---|---:|---|
| [isometric_world_map.dart](lib/presentation/widgets/isometric_world_map.dart) | ~2.000 | 15 tıklanabilir binalı izometrik şehir haritası |
| [isometric_showroom_canvas.dart](lib/presentation/widgets/isometric_showroom_canvas.dart) | ~797 | İzometrik showroom görselleştirmesi |
| [threejs_city_view.dart](lib/presentation/widgets/threejs_city_view.dart) | — | Platform switch dosyası |
| [threejs_city_view_web.dart](lib/presentation/widgets/threejs_city_view_web.dart) | ~338 | Web 3D şehir görünümü |
| [threejs_city_view_mobile.dart](lib/presentation/widgets/threejs_city_view_mobile.dart) | ~328 | Mobil 3D şehir görünümü |
| [threejs_city_view_stub.dart](lib/presentation/widgets/threejs_city_view_stub.dart) | — | Fallback |
| [tutorial_overlay.dart](lib/presentation/widgets/tutorial_overlay.dart) | — | Tutorial arayüz katmanı |

**Toplam ~4.000 satır** derlenen ama hiç çalışmayan kod. `isometric_showroom_canvas` özellikle dikkat çekici — Showroom'un izometrik görselleştirmesi yazılmış ama Showroom ekranı onu kullanmıyor.

---

# D. ÖLÜ FONKSİYONLAR

Tanımlı, hiçbir arayüzden çağrılmayan:

| Fonksiyon | Konum | Not |
|---|---|---|
| `takeBankLoan` | game_finance_mixin | A1 |
| `payLoanInstallment` | game_finance_mixin | B1 |
| `orderPart` | game_market_mixin:511 | A2 |
| `repairBodyPartWithTier` | game_inventory_mixin | A3 |
| `repairEngineWithTier` | game_inventory_mixin | A3 |
| `washAndPolishCar` | game_inventory_mixin | B3 |
| `detailCleanCar` | game_inventory_mixin | B4 |
| `applyDetailingOption` | game_inventory_mixin | B5 |
| `updateCarListingDeclaration` | game_inventory_mixin | B6 |
| `advanceTutorialStep` | game_core_provider | A4 |
| `instantRepair` | game_market_mixin | Anında onarım seçeneği hiç sunulmuyor |
| `addOffer` | game_market_mixin | — |
| `sellCar` | game_inventory_mixin | Doğrudan satış (teklifsiz) yolu yok |
| `expandGarageSlot` | game_inventory_mixin:195 | Garaj genişletmenin ikinci yolu |
| `upgradePrestigeBranch` | game_inventory_mixin:117 | Şube sistemiyle çelişkili paralel fiyatlar |
| `buyScrapyardCar` | game_market_mixin:709 | `buyAndDismantleScrapCar` ile mükerrer |
| `dismissPendingStoryCard` | game_time_mixin | Kart kapatma yolu yok |
| `dismissPendingRandomEvent` | game_time_mixin | Kart kapatma yolu yok |

---

# E. ÖLÜ VERİ ALANLARI

Modelde tanımlı, kaydediliyor, ama hiç okunmayan alanlar:

| Alan | Model | Ne için yazılmış |
|---|---|---|
| `isChassisRepaired` | `CarModel` | Şasi onarım durumu — hiç set edilmiyor, hiç okunmuyor |
| `prestigeMultiplier` | `DealershipModel` | Prestij/sezon çarpanı — hiç uygulanmıyor |
| `dailyTaxRate` | `DealershipModel` | Günlük vergi — `advanceGameDay`'de kesiliyor ama **oyuncuya hiçbir yerde gösterilmiyor** |
| `hasStreakFreeze` | `DealershipModel` | Seri dondurma hakkı — motor destekliyor ama **oyuncu bu hakkı hiç kazanamıyor/kullanamıyor** |
| `recentEvents` | `DealershipModel` | Olay geçmişi — listede tutuluyor, hiçbir ekranda gösterilmiyor |
| `tutorialStepIndex` | `DealershipModel` | A4 |

---

# Öncelik Sırası

| Sıra | Bulgu | Neden | Tahmini iş |
|---|---|---|---|
| 1 | **A2 — Parça siparişi** | Tek buton, arkasında 9 ölü parça + reklam geliri noktası + 3 tutorial adımı | Atölye ekranına "Sipariş Ver" akışı |
| 2 | **A1 — Banka kredisi** | Tek buton, arkasında 7 ölü parça; ayrıca oyuncu kullanamayacağı limite para ödüyor | Finans ekranına kredi çekme akışı |
| 3 | **A3 — Kademeli onarım** | Oyunun tek risk/ödül onarım mekaniği; içerik hazır | Atölyede tier seçimi |
| 4 | **A4 — Tutorial** | Görülmeyen tutorial için ₺50.000 bonus veriliyor | Ya overlay'i bağla ya bonusu kaldır |
| 5 | **B2 — Kredi limiti** | Aktif yanıltma: işe yaramaz bir şey satılıyor | A1 ile birlikte çözülür |
| 6 | **E — `hasStreakFreeze`** | D7 retention mekaniği, motor hazır, kazanma yolu yok | Ödül olarak ver |
| 7 | **B3-B5 — Yıkama/detay** | Mükerrer; ya sil ya bağla | Temizlik |
| 8 | **C — Ölü dosyalar** | ~4.000 satır bakım borcu | Sil veya bağla |

---

## Kapanış

Bu raporun tespit ettiği desen, önceki raporlarda da tekrar tekrar çıkmıştı: `RandomEventEngine` (16 olay — bu arada **artık bağlanmış**, iyi haber), `PsychologyEngine` metinleri, ses efektleri, izometrik harita.

Ortak kök neden şu görünüyor: **özellik "bittiğinde" iş mantığı ve arayüz gösterimi yazılıyor, ama kullanıcının sistemi başlatacağı giriş noktası ayrı bir adım olarak unutuluyor.**

Pratik bir kontrol önerisi: yeni bir özellik tamamlandığında sorulacak tek soru — *"Oyuncu bunu hangi ekranda, hangi butona basarak başlatıyor?"* Bu sorunun somut bir cevabı yoksa özellik bitmemiştir.

---

*Bu rapor `lib/` kaynak kodunun sistematik taramasına dayanır. Hiçbir dosya değiştirilmedi.*
