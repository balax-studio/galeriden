# Spec: Telemetri, İlk Oyun Döngüsü (FTUE) ve Seviye 1 Gelir Onarım Sistemi (§SPEC-2026-09-12-TELEMETRY-FTUE-REMEDIATION)

## 1. Giriş ve Problem Analizi
Son 28 günlük Google Analytics 4 (GA4) verileri ve kaynak kod denetimleri sonucunda tespit edilen kritik eksiklikler:
1. **MainActivity Yığılması ve Ayrışmayan Ekranlar**: `GoRouter` ve alt sekmelerdeki `IndexedStack` yapısı sebebiyle ekran görüntülemelerinin %90'ı `MainActivity` ve `FlutterViewController` altında toplanmakta, ekran bazlı terk analizi yapılamamaktadır.
2. **Dönüşüm Hunisindeki Kritik Mantık Hatası**: `game_inventory_mixin.dart` ve `game_market_mixin.dart` dosyalarında `first_car_purchased` ve `first_car_sold` olayları eleman eklendikten sonra `isEmpty` ile kontrol edildiği için hiçbir zaman tetiklenmemektedir.
3. **Pazar Alımlarında Eksik Telemetri**: `buyCar` ve `buyCarWithNoter` metotlarında `AnalyticsService.instance.logCarPurchased` çağrısı bulunmamaktadır.
4. **Rehber Durumu Asılı Kalması**: `tutorial_provider.dart` içindeki `nextStep()` çağrısı kodun hiçbir yerinde tetiklenmemekte; Dashboard'daki yönlendirme kartı sürekli "Dede Mirası Arabayı İncele" adımında kilitli kalmaktadır.
5. **Görev ve Kilit Çelişkisi**: Başlangıç görevinin "onarıp sat" ifadesi içermesine rağmen tamirhanenin Seviye 2 kilidine tabi olması oyuncuları yanıltmaktadır.
6. **Seviye 1 Reklam İzolasyonu**: Reklam noktalarının Seviye 2 arkasına kilitli olması sebebiyle oyuncuların %60'ından fazlası reklam seçeneklerine hiç ulaşamamaktadır.

---

## 2. Modül Haritası (Capability Map)

| Modül ID | Sorumluluk | Bağımlılıklar | Öncelik |
| :--- | :--- | :--- | :--- |
| `telemetry-funnel-repair` | Huni mantık hatasının düzeltilmesi, pazar alımlarına analitik eklenmesi ve sekme bazlı ekran takibi. | `analytics_service.dart`, `router.dart`, `game_inventory_mixin.dart`, `game_market_mixin.dart` | **P0** |
| `ftue-reactive-guidance` | Başlangıç görevi metninin kilitlerle uyumlanması, rehberin araç durumuna reaktif bağlanması ve anlık teklif bildirimi. | `dealership_model.dart`, `tutorial_provider.dart`, `dashboard_screen.dart`, `create_listing_screen.dart` | **P0** |
| `level1-monetization-access` | Seviye 1 oyuncular için vitrin ve pazar ekranlarında yumuşak dilli, hijyen kurallarına uygun sponsor desteği butonları. | `showroom_car_card.dart`, `marketplace_screen.dart`, `ad_service.dart` | **P1** |
| `localization-sync-7lang` | Eklenen veya güncellenen tüm başlık, toast ve buton metinlerinin 7 dilde eş zamanlı senkronizasyonu. | `app_localizations.dart`, `lib/core/localization/translations/*` | **P0** |

Yapım Sırası: `telemetry-funnel-repair` → `ftue-reactive-guidance` → `level1-monetization-access` → `localization-sync-7lang`

---

## 3. Detaylı Teknik Tasarım

### 3.1. Modül 1: Telemetry & Funnel Repair (`telemetry-funnel-repair`)
- **Huni Mantık Düzeltmesi**:
  - `game_inventory_mixin.dart`:
    ```dart
    final bool isFirstCarEver = state.ownedCars.isEmpty;
    state = state.copyWith(...);
    if (isFirstCarEver) {
      AnalyticsService.instance.logFirstCarAction(isBuy: true);
    }
    ```
  - `game_market_mixin.dart`:
    ```dart
    final bool isFirstSaleEver = state.salesHistory.isEmpty;
    state = state.copyWith(...);
    if (isFirstSaleEver) {
      AnalyticsService.instance.logFirstCarAction(isBuy: false);
    }
    ```
- **Pazar Alım Telemetrisi**:
  - `buyCar` ve `buyCarWithNoter` metotlarının sonuna `AnalyticsService.instance.logCarPurchased` eklenmesi.
- **Ekran Takibi**:
  - `dashboard_screen.dart` içinde `ref.listen<int>(dashboardTabProvider)` dinleyicisine indeks bazlı `logScreenView` bağlanması:
    - 0: `Dashboard - Ana Sayfa`
    - 1: `Showroom - Galerim`
    - 2: `Marketplace - Pazar Yeri`
    - 3: `Office - Galeri Yonetimi`
- **Rehber Telemetrisi**:
  - `AnalyticsService` içine `logTutorialStep` ve `logTutorialCompleted` eklenmesi.

### 3.2. Modül 2: FTUE & Reactive Guidance (`ftue-reactive-guidance`)
- **Başlangıç Görevi Sadeleştirmesi**:
  - `dealership_model.dart` içindeki `m_heritage_1` görev açıklaması "Dede mirası arabanı vitrine koy ve ilk satışını yap" olarak güncellenir.
- **Dinamik Rehber Durumu**:
  - `tutorial_provider.dart` bağımsız sayaç yerine aracın gerçek durumunu izler:
    - Eğer araç ilanda değilse: `listCarForSale` ("Dede Mirasını İlana Ver" • aksiyon: ilan ekranı).
    - Eğer araç ilandaysa ve teklif varsa: `acceptFirstOffer` ("İlk Müşterin Geldi - Satışı Yap" • aksiyon: teklifler sekmesi veya diyalogu).
    - Eğer satış yapıldıysa: `completed`.
- **Anlık Teklif Karşılama**:
  - `create_listing_screen.dart` üzerinden ilan verildiğinde, oyuncu henüz ilk satışını yapmamışsa kullanıcı Vitrin'e döndüğünde doğrudan teklifler sekmesine animasyonla geçilir ve dikkat çekici görsel vurgu sunulur.

### 3.3. Modül 3: Seviye 1 Monetizasyon Erişimi (`level1-monetization-access`)
- **Vitrin Hızlı Teklif Sponsorluğu**:
  - `showroom_car_card.dart`: İlanda olan ve henüz 3 teklife ulaşmamış araçlar için yumuşak dilli "Sponsor Desteği Al" butonu.
  - Tıklandığında `AdService.instance.showRewardedAdWithFallback` çağrılır ve ödül kazanıldığında `triggerOrganicOffers()` anında çalıştırılır.
- **AdMob Hijyen Güvencesi**:
  - Spam tıklamalara karşı reaktif buton kilidi (`_isProcessing`).
  - 45 saniyelik başarısız yükleme geri çekilme süresi.

### 3.4. Modül 4: 7 Dilde Senkronizasyon (`localization-sync-7lang`)
- Tüm yeni veya güncellenen dizgeler (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) dil dosyalarında eş zamanlı ve parantezsiz (` • ` veya ` - ` kullanılarak) tanımlanır.

---

## 4. Sınırlar ve Kurallar (Boundaries)
- **Daima Yap**: Tüm yeni dizgeleri 7 dilde senkronize et; birim testlerini çalıştır; testlerde `stopPeriodicOrganicOfferTimer` çağrısını koru; değişiklikleri `docs/FILE_CHANGELOG.md` dosyasına kaydet.
- **Önce Sor**: Bakiye veya ekonomik formüllerin katsayılarını radikal şekilde değiştirmeden önce onay al.
- **Asla Yapma**: Unicode emoji kullanma; UI dizgelerinde parantez kullanma; `initState` içinde reklam yükleme; unprompted `git push` yapma.

---

## 5. Başarı Kriterleri (Success Criteria)
1. `test/analytics_service_test.dart` ve `test/first_core_loop_tutorial_test.dart` dahil tüm testlerin sıfır hata ile geçmesi.
2. `state.ownedCars.isEmpty` ve `state.salesHistory.isEmpty` mantık hatalarının giderildiğinin birim testiyle kanıtlanması.
3. Dashboard sekmeleri değiştikçe `logScreenView` çağrısının çalıştığının doğrulanması.
4. Yeni dizgelerin 7 dilde de mevcut olduğunun doğrulanması.
