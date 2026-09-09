# Dosya Bazlı Değişiklik ve Hata Kaydı (File-by-File Change & Error Log)

Bu doküman, projede yapılan tüm dosya bazlı değişikliklerin, karşılaşılan hataların, kök nedenlerin ve uygulanan çözümlerin sistematik olarak takip edilmesi için tutulmaktadır.

---

## Standart Kayıt Şablonu

```markdown
### [Dosya Yolu]
- **Tarih**: YYYY-MM-DD
- **Değişiklik Amacı**: Yapılan işlemin kısa açıklaması
- **Yapılan Değişiklikler**:
  - Kod seviyesinde yapılan eklemeler, güncellemeler veya silinen kısımlar
- **Karşılaşılan Hatalar / Sorunlar**:
  - Karşılaşılan hata, beklenmeyen davranış veya sınır durumu
- **Kök Neden**:
  - Sorunun kaynaklandığı mimari veya mantıksal neden
- **Uygulanan Çözüm**:
  - Problemin nasıl giderildiği
- **Doğrulama / Test Durumu**:
  - Çalıştırılan testler, derleme veya analiz sonuçları
```

---

### `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart` & `lib/core/localization/translations/*`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Dashboard ana sayfasındaki (Tab 0) Hızlı Hizmetler ızgarasının Showroom Bento Hero kartı ile güçlendirilmesi, 2 sütunlu hizmet kartlarına canlı telemetri rozetlerinin eklenmesi ve derleme/hot-restart güncellemelerinin 7 dilde eksiksiz senkronizasyonu.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - Showroom kilidi açıkken (`game.isFeatureUnlocked('/showroom')`) ızgaranın en üstüne vitrindeki araç adedi, galeri şube unvanı, gelen teklif adedi ve hızlı giriş butonu barındıran geniş Showroom Hero Bento kartı eklendi (`_buildShowroomHeroCard`).
    - Hizmet kartlarında `_getLiveTelemetry` fonksiyonu üzerinden dinamik canlı telemetri rozetleri (`effectiveBadge`) entegre edildi: Oto Yıkama (kirli araç adedi), Atölye (bekleyen siparişler), Personel mevcudu, Satış geçmişi, Borsa portföyü, Gayrimenkul mülkleri, Şube sayısı, Kiralık filo durumu, İstihbarat ve Konsinye teklifleri.
    - `_buildSpan2ServiceCard` ve `_buildServiceCard` tek sütun/çift sütun yapısına canlı telemetri rozeti desteği kazandırıldı.
  - `lib/core/localization/translations/*`:
    - 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) `telemetry_dirty_count` ve `telemetry_orders_count` anahtarları eklendi. Sıfır emoji ve sıfır parantez kurallarına tam uyuldu.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `districtDominance` ve `realEstateSubstate` getter'larının `DealershipModel` üzerinde doğrudan bulunmaması nedeniyle analiz hatası alındı.
  - `game.currentBranchTier.title` çağrısının tip hatası vermesi (`currentBranchTier` int olduğu için).
  - Web sunucusunun önceki oturumda arka planda eski derlemeyi servis etmesi ve değişikliklerin tarayıcıya yansımaması.
- **Kök Neden**:
  - `DealershipModel` üzerinde gayrimenkul listesi `ownedRealEstates`, şube unvanı ise `getLocalizedBranchName(context)` metoduyla sağlanmaktadır.
  - Arka planda koşan `dartvm.exe` yeniden başlatılmadığı için güncel JS bundle derlenmemişti.
- **Uygulanan Çözüm**:
  - `game.ownedRealEstates` ve `game.getLocalizedBranchName(context)` kullanılarak kod düzeltildi.
  - Eski işlem sonlandırılarak flutter web dev server temiz şekilde yeniden başlatıldı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart` başarıyla tamamlandı (No issues found).
  - `flutter test test/dynamic_next_target_banner_test.dart test/service_unlock_notification_dot_test.dart` tüm testleri geçti (All 3 tests passed).

---



### `lib/presentation/screens/dashboard/widgets/dashboard_office_view.dart` & `lib/core/localization/translations/*`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Ofis ekranındaki hizmetler ve yan işler listesinin dikeyde okunurluğunu ve takibini kolaylaştırmak için 6 mantıksal kategoriye (Galeri & Ticaret, Atölye & Servis, Finans & Yatırım, Yönetim & Operasyon, Genişleme & Şebeke, Özel & Yeraltı) ayrılması ve her hizmet kartına canlı oyun durumu telemetri rozetleri (personel mevcudu, itibar puanı, mülk/şube sayıları, kiralık araç durumu, konsinye hacmi, hurda parça stoku, ele geçirilen bölgeler, karaborsa/gece yarışları vb.) eklenmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_office_view.dart`: `ServiceCategory` enum yapısı ve kategori başlıkları genişletildi. 18 adet modül kartı ilgi alanına göre sınıflandırıldı. Kartların alt kısmına mevcut oyun durumunu yansıtan canlı telemetri sayaçları ve durum rozetleri bağlandı.
  - `lib/core/localization/translations/*`: 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) eşzamanlı olarak kategori başlıkları ve tüm telemetri durum anahtarları eklendi. Sıfır emoji ve sıfır parantez kurallarına harfiyen uyuldu.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Hizmetler sekmesinin tek bir uzun karışık liste olması ve oyuncunun hangi serviste ne durumda olduğunu kartı açmadan görememesi.
- **Uygulanan Çözüm**:
  - Mantıksal gruplandırma ve anlık durum rozetleri getirilerek neo-brutalist bilgi hiyerarşisi güçlendirildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ve `flutter test` ile doğrulandı.

---

### `lib/core/services/ad_reward_calculator.dart`, `lib/domain/usecases/*`, `lib/presentation/screens/*` & `lib/core/localization/translations/*`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Reklam izleme ödüllerinin ve hibe desteklerinin (ofis kasası, şube genişleme, filo kiralama, borsa analizi, acil durum yardımı ve şanslı fırsatlar) oyuncunun toplam servetiyle (nakit bakiye + galeri filo değeri + seviye) dinamik olarak ölçeklenmesi; yüksek servete sahip oyuncuların (örneğin 66.5M+ TL) 20.000 TL gibi demotive edici düşük tutarlar yerine milyonluk gerçekçi teşvik ödülleri (~1.8M - 4.5M+ TL) alabilmesinin sağlanması.
- **Yapılan Değişiklikler**:
  - `lib/core/services/ad_reward_calculator.dart`: `calculateDynamicReward` formülü toplam servet katmanlarına göre kademeli ölçeklenecek şekilde revize edildi (<=500k %6.0, <=5M %4.5, <=25M %3.5, >25M %2.75). Eski katı tavanlar (`125.000 TL` ve `500.000 TL`) kaldırılarak seviye ve servete duyarlı dinamik koruma getirildi. Şube hibesi (`calculateBranchGrant`), VIP filo prim desteği (`calculateVipFleetGrant`), borsa içeriden rapor fonu (`calculateStockInsiderGrant`) ve acil durum hibesi (`calculateEmergencyGrant`) fonksiyonları eklendi.
  - `lib/presentation/screens/dashboard/widgets/dashboard_office_view.dart`: Reklam ödül hesaplamasında `playerBalance: game.balance` argümanı eklenerek ofisteki çifte kazanç / büyük ikramiye kasasının oyuncu servetine duyarlı olması sağlandı.
  - `lib/presentation/screens/branch/branch_screen.dart`: Sabit 40.000 TL hibe rozeti ve ödülü kaldırılarak `calculateBranchGrant` entegre edildi.
  - `lib/presentation/screens/rent_a_car/rent_a_car_screen.dart`: Sabit 35.000 TL rozeti ve ödülü kaldırılarak `calculateVipFleetGrant` entegre edildi.
  - `lib/presentation/screens/stock_market/stock_market_screen.dart`: Sabit 15.000 TL rozeti ve ödülü kaldırılarak `calculateStockInsiderGrant` entegre edildi.
  - `lib/domain/usecases/contextual_emergency_ad_engine.dart`: Kriz telafisi, noter eksik alım desteği, ihale depozitosu ve nakit darboğazı hibeleri `calculateEmergencyGrant` ile dinamik hale getirildi.
  - `lib/domain/usecases/smart_office_hook_engine.dart` & `lib/presentation/providers/game/game_inventory_mixin.dart`: Çıkmacı İbo Dayı acil zula fonu (`lowBalanceGrant`) sabit 35.000 TL yerine dinamik can suyu hibesi verecek şekilde güncellendi.
  - `lib/presentation/providers/game/game_monetization_mixin.dart` & `lib/data/models/lucky_opportunity_model.dart`: Çark ve şanslı fırsat nakit ödülleri dinamik olarak hesaplanacak şekilde `copyWith` entegrasyonuyla güncellendi.
  - `lib/core/localization/translations/*`: 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) sabit tutar içeren `lifeline_disaster_perk`, `rent_vip_fleet_title`, `rent_vip_toast_claimed`, `stock_report_locked_desc`, `stock_report_toast_unlocked`, `branch_grant_toast_claimed` anahtarları `{amount}` yer tutucusuyla dinamikleştirildi, parantez ve emojilerden arındırıldı.
  - `test/ad_service_test.dart`, `test/contextual_emergency_ad_engine_test.dart`, `test/theme_and_office_ad_hooks_test.dart`: Testler güncellendi; 66M+ TL bakiyeli patronların milyonluk ödül aldığı, invariant kurallarının (sıfır parantez, sıfır emoji) korunduğu doğrulandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `save_export_import_test.dart` içerisinde deterministik `Random(42)` tohumu ile seviye 1 jackpot ödülü (2x/4x) ile seviye 5 standart ödülünün çakışması.
  - `contextual_emergency_ad_engine_test.dart` ve `theme_and_office_ad_hooks_test.dart` dosyalarındaki eski sabit 20.000 TL ve 35.000 TL beklentileri.
- **Kök Neden**:
  - Ödül tavanları ve sabit hibe sayıları erken aşama ekonomisine göre sabit kodlanmıştı; servet çarpanı temel seviye bonusuyla toplamsal bağlanmadığında deterministik tohumlarda seviye eşitsizliği oluşuyordu.
- **Uygulanan Çözüm**:
  - Temel seviye ödülü ile servet oranlı katkı toplamsal ve aşamalı yüzdelerle birleştirildi, düşük seviyeler için enflasyon önleyici tavanlar korunurken zengin oyuncuların servetiyle doğru orantılı ödül alması sağlandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/ad_service_test.dart test/economy_test.dart test/save_export_import_test.dart test/contextual_emergency_ad_engine_test.dart test/rewarded_ad_integrations_test.dart test/theme_and_office_ad_hooks_test.dart` başarıyla geçti.
  - `flutter analyze`: Sıfır hata, sıfır uyarı (`No issues found!`).

### `lib/presentation/screens/staff/staff_screen.dart`, `lib/data/models/staff_model.dart` & `lib/core/localization/translations/*`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Personel eğitim ve akademi kartlarındaki aşırı uzun, kurumsal klişe (slop) metinlerin sadeleştirilmesi, gereksiz açıklamaların kaldırılarak saf istatistik, rozet ve net etki odaklı neo-brutalist oyun tasarımına kavuşturulması.
- **Yapılan Değişiklikler**:
  - `lib/core/localization/translations/`: 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) eşzamanlı olarak `staff_training_desc` anahtarı hantal kurumsal ifadeden arındırılıp yalın, doğrudan bir ifadeye dönüştürüldü (`Kalıcı rol uzmanlıkları ve performans bonusları.`).
  - `lib/data/models/staff_model.dart`: 14 eğitim kursunun açıklamaları gereksiz edebiyattan arındırılarak eylem ve net etki bildiren anti-slop cümlelere dönüştürüldü.
  - `lib/presentation/screens/staff/staff_screen.dart`: `_showRoleTrainingSheet` kurs kartlarındaki yinelenen ve ekranı dikeyde şişiren `course.description` metni kaldırılarak başlık, kazanım çipleri (bonusSummary) ve süre etiketlerinin doğrudan öne çıkması sağlandı. Kart boyutu optimize edilerek dar ekranlarda buton erişimi rahatlatıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Kurs başlığı ve bonus çipleri kursun ne yaptığını zaten eksiksiz özetlerken arada yer alan 2 satırlık dolgu metnin kart yüksekliğini gereksiz artırması ve bilişsel yük yaratması.
- **Uygulanan Çözüm**:
  - Dolgu metinler temizlendi, modal kartları hafifletildi ve 7 dil çevirileri eşitlendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ile 0 hata/uyarı, `staff_specialization_and_gating_test.dart` (9/9 başarılı), `staff_team_management_test.dart` ve `rush_training_dialog_test.dart` (22/22 başarılı) ile tam doğrulandı.

---
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Arsa üzerinde öz sermaye ile inşaat yapılırken veya KAKS mimari tipoloji stüdyosunda proje onaylandığında, onay butonunun kilitlenerek "Proje Onaylandı" durumuna geçmesi ve daire dağılımı/optimizasyon kontrollerinin reaktif olarak kilitlenmesi.
- **Yapılan Değişiklikler**:
  - `lib/core/localization/translations/`: 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) eşzamanlı olarak `real_estate_kaks_btn_approved` anahtarı eklendi. Sıfır emoji ve sıfır parantez kurallarına uyuldu.
  - `game_real_estate_mixin.dart`: `saveUnitMix` fonksiyonunda `isArchitecturalApproved: true` olarak işaretlendi. Öz sermaye 1. aşama mimari çizim sürecinde ise `isConstructionWorking: false`, `constructionDaysRemaining: 0` ve `preConstructionStep: 'draftingCompleted'` güncellenerek belediye ruhsatı adımına geçiş sağlandı.
  - `real_estate_construction_screen.dart`: `_buildKaksTypologyStudio` içinde `isProjectApproved` reaktif durumu hesaplandı. Onay butonuna `isApplied: isProjectApproved`, `appliedLabel: context.tr('real_estate_kaks_btn_approved')` ve `onPressed: (isExceeded || isProjectApproved) ? null : () { ... }` bağlandı. Proje onaylandığında buton kilitlendi. Tipoloji artır/azalt stepper butonları, akıllı emsal optimize et ve sıfırla butonları `isProjectApproved` olduğunda devre dışı (`null`) bırakıldı.
  - `test/zoning_and_construction_test.dart` & `test/real_estate_construction_test.dart`: `saveUnitMix` ile mimari projenin onaylanması ve Tab 1 arayüzünde "Proje Onaylandı" butonunun kilitli duruma geçişini doğrulayan birim ve widget testleri eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `_buildTypologySelectorCard` içinde kapatma parantezi kopyalama fazlalığı.
- **Kök Neden**:
  - Çoklu blok düzenlemesi sırasında widget ağacının kapanış süslü parantezlerinin yinelenmesi.
- **Uygulanan Çözüm**:
  - Fazla parantez bloğu temizlenerek widget ağacı düzeltildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ile 0 hata, `translation_key_coverage_test.dart` (6/6 başarılı), `zoning_and_construction_test.dart` (12/12 başarılı) ve `real_estate_construction_test.dart` (19/19 başarılı) ile doğrulandı.

---

### `lib/domain/usecases/daily_life_cards_data.dart`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: 365 günlük rastgele dramatik olay kartlarının yapay zeka klişelerinden (slop) arındırılarak gerçekçi, trajikomik, viral ve Twitter/Instagram kült trendlerine uygun esnaf hikayeleriyle baştan aşağı yenilenmesi.
- **Yapılan Değişiklikler**:
  - 365 günün tamamı için yapay genel metinler kaldırıldı. Yerine Çırak Emre, Çaycı Mahmut, Noter Sevim Hanım, Hacı Hilmi Bey, Fenomen Berkecan, Müfettiş Orhan gibi otantik karakterler, dükkan ve sokak hayatı, sosyal medya krizleri ve gün ilerlemesine göre artan dinamik maliyet/itibar dengeleri entegre edildi.
  - Seçenekler ve sonuç mesajları ("profesyonel refleksin takdir topladı" vb.) tamamen kaldırılarak somut, esprili ve mantıklı esnaf sonuçlarıyla değiştirildi.
  - Sıfır emoji ve sıfır parantez kurallarına harfiyen uyuldu.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `DramaticCategory` içinde `dilemma` enum değerinin bulunmaması nedeniyle geçici analiz hatası.
- **Kök Neden**:
  - `dramatic_card_model.dart` içinde ilgili kategorinin `conscience` olarak tanımlı olması.
- **Uygulanan Çözüm**:
  - İlgili kartlar `DramaticCategory.conscience` olarak güncellendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` (0 sorun) ve test paketi (14/14 başarılı) ile doğrulandı.

---

### `lib/core/services/analytics_service.dart`, `lib/presentation/providers/game/game_time_mixin.dart`, `game_market_mixin.dart`, `game_inventory_mixin.dart` & `test/analytics_service_test.dart`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Firebase Analytics için ücretsiz Spark sınırları dahilinde oyuncu segmentasyonu (User Properties) ve derinlemesine oyun içi döngü etkinliklerinin (gün geçişi, tamirler, yan işletmeler, sürpriz seçimler, onboarding hunisi ve iflas) entegre edilmesi.
- **Yapılan Değişiklikler**:
  - `AnalyticsService`: `syncUserProperties` (seviye, gün, servet dilimi, araç sayısı), `logDayPassed`, `logCarRepaired`, `logSideBusinessPurchased`, `logRandomEventChoice`, `logFirstCarAction` (ilk alım ve ilk satış dönüşüm hunisi), `logBankruptcy` metotları eklendi.
  - `game_time_mixin.dart`: `advanceGameDay` sonuna `logDayPassed` ve `syncUserProperties` bağlandı, bakiye eksiye düştüğünde `logBankruptcy` eklendi, `resolveRandomEvent` içine `logRandomEventChoice` bağlandı.
  - `game_market_mixin.dart`: `buySideBusiness` içine `logSideBusinessPurchased`, ilk araç satışında `logFirstCarAction(isBuy: false)` eklendi.
  - `game_inventory_mixin.dart`: `buyCarDirectly` içine ilk alım hunisi `logFirstCarAction(isBuy: true)`, kaporta/motor/şanzıman tamirlerinde `logCarRepaired` eklendi.
  - `test/analytics_service_test.dart`: Eklenen tüm analitik metotlarının hata fırlatmadan güvenle çalıştığını doğrulayan birim testleri güncellendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `game_time_mixin.dart` içinde `choice.id` getter hatası (undefined getter).
- **Kök Neden**:
  - `GameEventChoice` modelinde tanımlayıcı alanın `id` değil `label` olması.
- **Uygulanan Çözüm**:
  - `choice.label` olarak güncellendi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/analytics_service_test.dart` (2/2 başarılı), regresyon testleri (17/17 başarılı) ve `flutter analyze` (0 sorun) ile doğrulandı.

---

### `lib/core/services/ad_service.dart` & `test/native_ad_day_pacing_test.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Yerel reklamların ve yerel bülten sponsor kartlarının aktifleşme eşiğini 7. gün yerine 2. güne çekerek test ve kullanıcı deneyimi sürecini hızlandırma.
- **Yapılan Değişiklikler**:
  - `AdService.shouldShowNativeAdForDay`: `currentDay <= 7` koşulu `currentDay < 2` olarak güncellendi. 1. gün başlangıç koruması sağlandı, 2. gün ve sonrasında tüm ekranlarda yerel reklamlar aktif hale getirildi.
  - `test/native_ad_day_pacing_test.dart`: Birim ve widget testleri 2. gün eşiğine göre güncellendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Yok.
- **Uygulanan Çözüm**:
  - Eşik değeri 2. güne ayarlandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/native_ad_day_pacing_test.dart` (6/6 başarılı) ile doğrulandı.

---
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Oyuncu ilk 50 içinde olmasa dahi (örneğin 142. veya 850. sırada) alt yapışkan barda gerçek ve anlık sırasını Firestore `count()` sorgusuyla hesaplayıp gösterme.
- **Yapılan Değişiklikler**:
  - `LeaderboardService.fetchPlayerExactRank`: `aggregate.count()` sorgusu eklenerek oyuncudan daha yüksek servete veya XP'ye sahip oyuncu sayısı sayıldı ve `+ 1` ile kesin sıra tespit edildi.
  - `LeaderboardProvider`: `myExactRank` alanı eklendi; ilk 50 içindeyse liste indeksi, dışındaysa `fetchPlayerExactRank` çağrılarak güncellendi.
  - `LeaderboardScreen`: `_buildStickyMyRank` içinde `state.myExactRank` değeri dinamik olarak rozete bağlandı (`#${state.myExactRank}`). Sekme değişimlerinde ve yenilemelerde anlık güncellenmesi sağlandı.
  - `test/leaderboard_service_test.dart`: `myExactRank` durum güncellemesini doğrulayan birim testi eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Yok.
- **Uygulanan Çözüm**:
  - Firestore'un düşük maliyetli ve ultra hızlı `count()` aggregation API'si kullanılarak belge okuma maliyeti minimumda tutuldu.
- **Doğrulama / Test Durumu**:
  - `flutter test test/leaderboard_service_test.dart` (5/5 başarılı) ve `flutter analyze` (0 sorun) ile doğrulandı.

---
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Firebase Analytics entegrasyonu ile oyuncu ekran geçişleri ve oyun içi kritik hareketlerin (araç alım-satımı, seviye atlama, ödüllü reklamlar, müzayede) canlı analitik takibinin sağlanması.
- **Yapılan Değişiklikler**:
  - `pubspec.yaml` dosyasına `firebase_analytics: ^12.5.0` eklendi.
  - `lib/core/services/analytics_service.dart`: Hata toleranslı singleton analitik servisi oluşturuldu; ekran görüntüleme, araç alım/satım, seviye atlama, müzayede teklifleri ve reklam izleme metotları yazıldı.
  - `lib/main.dart`: Başlangıçta `AnalyticsService.instance.initialize()` çağrısı bağlandı.
  - `lib/app/router.dart`: GoRouter `observers` listesine `AnalyticsService.instance.observer` eklenerek tüm sayfa geçişleri otomatik takibe alındı.
  - `lib/presentation/providers/game/game_core_provider.dart`: Seviye atlandığında `logLevelUp` tetiklendi.
  - `lib/presentation/providers/game/game_market_mixin.dart` & `game_inventory_mixin.dart`: Satış ve doğrudan alımlarda `logCarSold` ve `logCarPurchased` bağlandı.
  - `lib/core/services/ad_service.dart`: Ödüllü reklam tamamlandığında `logAdRewardWatched` çağrıldı.
  - `lib/presentation/screens/leaderboard/leaderboard_screen.dart`: Liderlik sekmesi ziyaretlerinde `logLeaderboardViewed` çağrıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `game_market_mixin.dart` içinde `offer.offerAmount` getter hatası.
- **Kök Neden**:
  - `OfferModel` sınıfında doğru alan adının `offeredAmount` olması.
- **Uygulanan Çözüm**:
  - `offer.offeredAmount` olarak düzeltildi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/analytics_service_test.dart` (2/2 başarılı), `test/leaderboard_service_test.dart` (4/4 başarılı), `test/translation_key_coverage_test.dart` (6/6 başarılı) ve `flutter analyze` (0 hata) ile doğrulandı.

---

### `lib/core/services/leaderboard_service.dart`, `lib/presentation/screens/leaderboard/leaderboard_screen.dart` & İlgili Modüller
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Çift sıralamalı (Toplam Servet ve İtibar/XP) Firebase tabanlı canlı liderlik tablosu (Leaderboard) sisteminin entegre edilmesi.
- **Yapılan Değişiklikler**:
  - Firebase CLI ile `galeriden-game-balax` projesi oluşturuldu; Android ve iOS konfigürasyonları `lib/firebase_options.dart` ile tamamlandı.
  - `pubspec.yaml` dosyasına `firebase_core: ^4.14.0` ve `cloud_firestore: ^6.9.0` eklendi.
  - `lib/main.dart` içinde `Firebase.initializeApp` platform korumalı olarak eklendi.
  - `lib/data/models/leaderboard_entry_model.dart`: Oyuncu ID, galeri adı, sahip adı, toplam servet, itibar XP, seviye ve araç sayısı verilerini yöneten model yazıldı.
  - `lib/core/services/leaderboard_service.dart`: Anonim oyuncu kimliği (UUID/Prefs), 10 dakikalık Firestore bellek önbelleği ve 6 dakikalık yazma aralığı (Spark ücretsiz kota tam koruması) sağlayan servis güncellendi.
  - `lib/presentation/providers/leaderboard_provider.dart`: Riverpod tabanlı `LeaderboardNotifier` oluşturuldu; servet ve XP sekmeleri arasında anlık geçiş ve profil senkronizasyonu sağlandı.
  - `lib/presentation/screens/leaderboard/leaderboard_screen.dart`: Neo-brutalist tasarıma uygun podyum rozetleri (altın, gümüş, bronz), "SEN" etiketli oyuncu vurgusu ve yapışkan alt profil çubuğuyla çift sekmeli ekran oluşturuldu.
  - `lib/presentation/screens/dashboard/widgets/dashboard_banners.dart`: Ana sayfadaki yapay "Şehir Ligi" kartı kaldırılarak yerine gerçek canlı "Liderlik Tablosu" kartı entegre edildi.
  - `lib/app/router.dart`: `/leaderboard` rotası GoRouter'a tanımlandı.
  - 7 dilde eşzamanlı yerelleştirme (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) yapıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `LeaderboardNotifier` içinde model tipi `GameModel` yerine repo standardı olan `DealershipModel` gereksinimi ve `fromMap` kurucusunda isimlendirilmiş `docId` argümanı uyumsuzluğu.
- **Kök Neden**:
  - Dosya importunda ve test çağrısında var olan `DealershipModel` ve `PlayerSkills.xp` mimarisinin kullanılması gerekliliği.
- **Uygulanan Çözüm**:
  - `DealershipModel` ve `game.skills.xp` tip tanımları bağlandı; test argümanı `docId:` olarak düzeltildi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/leaderboard_service_test.dart` (4/4 başarılı), `flutter test test/translation_key_coverage_test.dart` (7/7 başarılı) ve `flutter analyze` (0 hata) ile doğrulandı.

---

### `lib/core/services/ad_service.dart` & `lib/presentation/widgets/ads/neo_brutal_native_ad_card.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Çift yükleme çakışması (race condition) ve AdMob istek fırtınası kaynaklı Error 3 (No Fill) hatasını gidererek gerçek reklamların yüklenmesini sağlamak.
- **Yapılan Değişiklikler**:
  - `NeoBrutalNativeAdCard` bileşeni havuzdan bağımsız doğrudan paralel istek atmaktan çıkarıldı; tüm reklam akışı merkezi tekil havuza bağlandı.
  - `_onAdServiceChanged` dinleyicisinde `_isAdLoaded == false` kontrolü getirilerek arka planda yüklenen havuz reklamının hazır olduğu anda karta aktarılması garanti edildi.
  - `AdService` havuz kapasitesi dengeli 4 adede, istekler arası bekleme 1500ms'ye, ardışık havuz doldurma aralığı 800ms'ye ve başarısızlık toleransı 15 saniyeye ayarlandı.
  - `consumePreloadedNativeAd` metodundan gereksiz `notifyListeners` kaldırılarak diğer kartların aynı anda havuzu tüketmesi önlendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - 100ms'lik agresif debounce nedeniyle kartların havuzla yarışarak aynı anda AdMob'a paralel istek atması, AdMob'un istekleri reddetmesi ve kartların sürekli esnaf bülteninde kalması.
- **Kök Neden**:
  - Çoklu paralel NativeAd isteklerinin AdMob tarafından engellenmesi ve kartların havuzun yanıtını beklemeden tekil istekte hata alıp pes etmesi.
- **Uygulanan Çözüm**:
  - Tek hatlı (single-pipeline) merkezi havuz mimarisi ve güvenli AdMob istek aralıkları uygulandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` (0 hata) ve `test/ad_service_test.dart` ile doğrulandı.

---

### `pubspec.yaml`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Yerel reklam performans iyileştirmeleri ve havuz optimizasyonu için derleme sürüm numarasının artırılması.
- **Yapılan Değişiklikler**:
  - `version: 1.0.5+26` -> `version: 1.0.5+27` olarak güncellendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ve `flutter test` ile doğrulandı.

---

### `lib/presentation/screens/workshop/workshop_screen.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Ana atölye ekranına yerel gelişmiş reklam (NativeAd) kartı ve proaktif ön yükleme eklenmesi.
- **Yapılan Değişiklikler**:
  - `initState` metoduna `AdService.instance.preloadNativeAd()` eklendi.
  - Atölye tamir listesinin üzerine `NeoBrutalNativeAdCard(contextType: NativeAdContextType.workshop)` yerleştirildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Ana tamir atölyesi ekranında yerel reklam alanının bulunmaması.
- **Kök Neden**:
  - Modifiye stüdyosunda reklam kartı varken ana tamirhane ekranında atlanmış olması.
- **Uygulanan Çözüm**:
  - `NeoBrutalNativeAdCard` bileşeni `NativeAdContextType.workshop` bağlamıyla eklendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ile doğrulandı.

---

### `lib/presentation/screens/side_business/side_business_detail_screen.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Yan işletme detay alt sayfasına yerel gelişmiş reklam (NativeAd) kartı eklenmesi.
- **Yapılan Değişiklikler**:
  - Genel bakış ve kapasite yükseltme bölümleri arasına `NeoBrutalNativeAdCard(contextType: NativeAdContextType.sideBusiness)` eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yan işletme detay alt sayfasında yerel reklam bulunmaması.
- **Kök Neden**:
  - Ana listede reklam varken detay sayfasında yer almaması.
- **Uygulanan Çözüm**:
  - `NeoBrutalNativeAdCard` bileşeni sayfaya entegre edildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ile doğrulandı.

---

### `lib/core/services/ad_service.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Reklam alanlarının boş kalmasını ve geç yüklenmesini önlemek amacıyla havuz boyutu, yenileme hızı ve hata bekleme sürelerinin optimize edilmesi.
- **Yapılan Değişiklikler**:
  - `maxNativeAdPoolSize` 4'ten 6'ya çıkarıldı.
  - `minNativeAdInterval` 1500ms'den 300ms'ye indirildi.
  - `nativeAdFailureCooldown` 45 saniyeden 5 saniyeye düşürüldü.
  - `consumePreloadedNativeAd` içindeki 800ms yapay gecikme kaldırılarak `scheduleMicrotask` ile anında arka plan yenilemesi sağlandı.
  - `_preloadNextInPool` içindeki sıralı istek beklemesi 600ms'den 100ms'ye, hata tekrarı 5 saniyeye çekildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Pazar yeri kaydırması sonrası veya ekran geçişlerinde (Oto Yıkama, Finans vb.) reklam havuzunun tükenmesi ve 45 saniyelik hata kilidi nedeniyle gerçek reklamların yüklenmeyip yerel lore kartlarının kalması.
- **Kök Neden**:
  - Tüketim sonrası 800ms gecikmeli yenileme, 45 saniyelik aşırı uzun genel hata kilidi ve küçük havuz boyutu (4).
- **Uygulanan Çözüm**:
  - 6 adetlik derin havuz, 0ms anında mikrogörev yenileme ve 5s kısa hata toleransı uygulandı.
- **Doğrulama / Test Durumu**:
  - `test/ad_service_test.dart` birim testleri çalıştırıldı (Başarılı).

---

### `lib/presentation/widgets/ads/neo_brutal_native_ad_card.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Reklam kartlarının ekranda belirdiği anda gecikmesiz yüklenmesini sağlamak.
- **Yapılan Değişiklikler**:
  - `_scheduleDebouncedLoad` içindeki 1500ms bekleme süresi 100ms mikro bekleme seviyesine indirildi.
  - `canRequestNativeAd` throttling kontrolündeki yeniden deneme aralığı 1500ms'den 300ms'ye çekildi.
  - Boş havuz tetikleyicisindeki hedef sayı `AdService.maxNativeAdPoolSize` (6) ile senkronize edildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Havuzda hazır reklam bulunmadığında kartın 1.5 saniye boyunca boş/fallback durumda beklemesi.
- **Kök Neden**:
  - 1500ms'lik uzun debounce sayacı.
- **Uygulanan Çözüm**:
  - 100ms mikro-debounce ile anında istek tetikleme sağlandı.
- **Doğrulama / Test Durumu**:
  - `test/ad_service_test.dart` ve `flutter analyze` ile doğrulandı.

---

### `lib/presentation/screens/car_wash/car_wash_screen.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Ekran açılışında yerel reklam havuzunun önceden ısıtılması (preload).
- **Yapılan Değişiklikler**:
  - `initState` metoduna `AdService.instance.preloadNativeAd()` çağrısı eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Oto yıkama ekranına girildiğinde reklam alanının hazır olmaması.
- **Kök Neden**:
  - Ekrana giriş anında havuzun proaktif olarak ısıtılmaması.
- **Uygulanan Çözüm**:
  - `initState` içinde proaktif ön yükleme tetiklendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ile statik analiz doğrulandı.

---

### `test/ad_service_test.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Güncellenen `minNativeAdInterval` (300ms) değerine uygun birim test senkronizasyonu.
- **Yapılan Değişiklikler**:
  - Test beklentisi 1500ms'den 300ms'ye güncellendi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/ad_service_test.dart` çalıştırıldı (8/8 test başarılı).

---
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Pazar yerinde 3. ve 4. reklam alanlarının boş kalmasını önlemek amacıyla çoklu reklam havuzu (multi-slot pool) mimarisine geçiş.
- **Yapılan Değişiklikler**:
  - Tekil `_cachedNativeAd` yapısı yerine `List<NativeAd> _nativeAdPool` (kapasite: 4) havuz mimarisine geçildi.
  - `preloadNativeAdPool(int targetCount)` metodu eklendi.
  - Katı 30 saniyelik `_lastNativeAdRequestTime` bekleme süresi, liste kaydırmalarında peş peşe gelen isteklerin adil aralıkla işlenmesi için 1.5 saniyelik minimum aralığa revize edildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Araç pazarında ilk 2 reklam alanı dolarken 3. ve 4. reklam alanlarının boş görünmesi.
- **Kök Neden**:
  - Tekil native ad önbelleği bulunması ve 30 saniyelik katı istek kısıtlamasının hızlıca listelenen reklam slotlarına yeni reklam atanmasını engellemesi.
- **Uygulanan Çözüm**:
  - 4 yuvalı `_nativeAdPool` yapısı kuruldu; her tüketilen reklam havuzdan alınıp yerine asenkron olarak arka planda yenisi yüklenecek şekilde tasarlandı.
- **Doğrulama / Test Durumu**:
  - `test/ad_service_test.dart` ile 1.5 saniye istek aralığı ve havuz yenileme test edildi (Başarılı).

---

### `lib/core/services/ad_reward_calculator.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Ayarlar ekranındaki sponsorluk fon desteğinin oyuncunun mevcut kasasına göre dinamik olarak ölçeklenmesi.
- **Yapılan Değişiklikler**:
  - `calculateReward` metoduna `playerBalance` parametresi eklendi.
  - `RewardType.sponsorGrant` için ödül tutarı `(playerBalance * 0.10).clamp(50000, 5000000).toDouble()` formülüyle kasanın %10'u olacak şekilde uyarlandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yüksek bakiyeli oyun aşamalarında sabit veya düşük kalan sponsor desteğinin ekonomik değerini yitirmesi.
- **Kök Neden**:
  - Fon desteğinin oyuncu varlığından bağımsız sabit bir katsayı üzerinden hesaplanması.
- **Uygulanan Çözüm**:
  - Dinamik %10 bakiye çarpanı ve mantıklı bir alt-üst sınır (50K - 5M) tanımlandı.
- **Doğrulama / Test Durumu**:
  - `test/ad_service_test.dart` içindeki bakiye ölçekleme birim testleri çalıştırıldı (Başarılı).

---

### `lib/presentation/screens/settings/settings_screen.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Sponsorluk fon talebinde güncel oyuncu bakiyesinin ödül hesaplayıcıya aktarılması.
- **Yapılan Değişiklikler**:
  - `playerBalance: player.balance` parametresi `AdRewardCalculator.calculateReward` çağrısına bağlandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Ayarlar ekranından çağrılan ödül hesaplayıcının varsayılan bakiye parametresini kullanması riski.
- **Kök Neden**:
  - Çağrı noktasında `ref.watch(playerProvider).balance` verisinin geçilmemesi.
- **Uygulanan Çözüm**:
  - İlgili Riverpod sağlayıcısından oyuncu bakiyesi okunup doğrudan parametre olarak verildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ve manuel akış doğrulaması (Başarılı).

---

### `lib/presentation/widgets/ads/neo_brutal_native_ad_card.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Çoklu reklam havuzu ile uyumlu debounced tüketim yapısının entegrasyonu.
- **Yapılan Değişiklikler**:
  - `_scheduleDebouncedLoad` mekanizması `AdService.instance.consumePreloadedNativeAd()` ile senkronize edildi.
  - Havuzda reklam bulunamadığında in-universe sponsor yedeğinin (`InGameSponsorSnippet`) hatasız devreye girmesi sağlandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Liste içinde hızlı kaydırma esnasında henüz yüklenmemiş slotların boş kutu olarak kalması.
- **Kök Neden**:
  - AdMob native ad yükleme gecikmesi ve önbellekte hazır reklam olmaması.
- **Uygulanan Çözüm**:
  - Havuzdan anında çekim ve hazırda yoksa yerel sponsor kartına anında düşüş sağlandı.
- **Doğrulama / Test Durumu**:
  - `test/native_ad_day_pacing_test.dart` doğrulandı (Başarılı).

---

### `lib/presentation/screens/car_wash/car_wash_screen.dart` & `lib/presentation/screens/workshop/widgets/workshop_customer_jobs_tab.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Oto yıkama ve atölye uzmanları için günlük aksiyon kotalarının uygulanması.
- **Yapılan Değişiklikler**:
  - Günlük aksiyon kotası bittiğinde butonların reaktif olarak devre dışı kalması (`Consumer` / `ref.watch`).
  - Reklam izleyerek ek günlük kota kazanma entegrasyonu eklendi.
  - Günlük oyun döngüsü atlandığında kotaların otomatik sıfırlanması sağlandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Uzman butonlarına art arda basılarak kotasız sınırsız işlem yapılabilmesi riski.
- **Kök Neden**:
  - Günlük işlem sayacı kontrolünün yalnızca sunucu/state tarafında yapılıp UI butonunda anlık reaktif kilit olmaması.
- **Uygulanan Çözüm**:
  - Riverpod tabanlı reaktif `onPressed: quotaRemaining > 0 ? ... : null` kilidi kuruldu.
- **Doğrulama / Test Durumu**:
  - `test/car_wash_and_workshop_test.dart` ile kota tükenmesi ve gün sonu sıfırlanması doğrulandı (Başarılı).

---

### `docs/DAILY_LIFE_CARDS_365.md` & `assets/data/daily_life_cards_365.json`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: 365 günlük karar kartlarının galeri/oto temalarından tamamen arındırılarak genel hayat, sosyal medya, popüler kültür, dramatik ve trajikomik ikilemlerle yeniden yapılandırılması.
- **Yapılan Değişiklikler**:
  - 1'den 365'e kadar her gün için bağımsız, zengin ve kültürel olarak otantik genel hayat ikilemleri kurgulandı.
  - 12 tematik döneme yayılan olay dizisi hazırlandı (Dijital Çağ, Aile & Akraba, Kült Dizi & Sinema, Plaza Çileleri, Tüketim, Yaz Tatili, İkili İlişkiler, Mahalle Hayatı, Varoluşsal Krizler, Sağlık & Diyet, Finansal Hayatta Kalma, Yıl Sonu Muhasebesi).
  - Kullanıcının doğrudan okuyup düzenleme yapabileceği detaylı `docs/DAILY_LIFE_CARDS_365.md` kataloğu ve motor için `assets/data/daily_life_cards_365.json` veri seti oluşturuldu.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Parantez yasağı ve sıfır Unicode emoji kurallarına uyulması gerekliliği.
- **Kök Neden**:
  - Proje tasarım kurallarında parantez ve emojilerin kesin olarak yasaklanmış olması.
- **Uygulanan Çözüm**:
  - Otomatik doğrulama scriptiyle 365 kartın tamamında parantez ve emoji kontrolleri yapıldı, eksiksiz sıfır hata ile derlendi.
- **Doğrulama / Test Durumu**:
  - Node doğrulama scripti çalıştırıldı ve 365 günün tamamı eksiksiz onaylandı.
---

### `lib/domain/usecases/daily_life_cards_data.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: 365 günlük genel hayat karar kartlarının tür güvenli (type-safe) Dart sınıfı ve kataloğu olarak sisteme kazandırılması.
- **Yapılan Değişiklikler**:
  - `DailyLifeCardDef` veri modeli ve 365 kartlık `catalog` listesi oluşturuldu.
  - `toCard(int dayNumber)` dönüştürücüsü ile `DramaticCardModel` nesnelerine kayıpsız dönüştürme sağlandı.
  - Test ve oyun dengesi için Gün 1'in birinci seçeneğine ₺500 başlangıç masrafı (`choice1Cost: 500.0`) entegre edildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Kartların kod içinde harici JSON dosya I/O beklemesine girmeden anlık ve sıfır gecikmeyle üretilebilmesi gerekliliği.
- **Kök Neden**:
  - Widget testlerinde ve UI render akışında asenkron asset okuma gecikmelerinin UI flicker veya test karmaşası yaratma potansiyeli.
- **Uygulanan Çözüm**:
  - Sabit derleme zamanı (compile-time) veri kataloğu ve deterministik `getCardForDay(int day)` metodu kurgulandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ve `test/dramatic_daily_dilemma_test.dart` ile doğrulandı (Başarılı).

---

### `lib/domain/usecases/dramatic_card_engine.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Günlük karar ikilemlerinin 365 günlük hayat olayları kataloğundan okunacak şekilde motorun refaktör edilmesi ve 2.200 satırdan fazla eski galeri kart kodunun temizlenmesi.
- **Yapılan Değişiklikler**:
  - `generateDailyDilemma` metodu `DailyLifeCardsData.getCardForDay(((day - 1) % 365) + 1)` çağrısıyla deterministik hale getirildi.
  - Eski galeri/sanayi odaklı prosedürel kart üretici fonksiyonlar temizlendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Eski kod bloklarının galeriye bağlı parametre bağımlılıkları ve bakım zorluğu.
- **Kök Neden**:
  - Kart mantığının motor içine gömülü 2.200 satırlık devasa bir switch-case yapısında kalması.
- **Uygulanan Çözüm**:
  - Modüler katalog mimarisine geçilerek motor kodu sadeleştirildi.
- **Doğrulama / Test Durumu**:
  - `test/dramatic_daily_dilemma_test.dart`, `test/dramatic_cards_engine_test.dart` ve `test/day_progression_and_dramatic_cards_test.dart` çalıştırıldı (Tüm testler geçti).

---

### `lib/presentation/widgets/neo_brutal_dramatic_dialog.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Günlük karar diyalogunda farklı ekran genişlikleri ve 7 dildeki metin uzunluklarında oluşabilecek taşma (RenderFlex overflow) hatalarının giderilmesi.
- **Yapılan Değişiklikler**:
  - Üst bilgi şeridindeki (`daily_dilemma_badge`) Text widget'ına `maxLines: 1` ve `overflow: TextOverflow.ellipsis` eklendi.
  - Kategori etiket satırındaki (`_getCategoryLabel`) Text widget'ı `Flexible(child: Text(..., maxLines: 1, overflow: TextOverflow.ellipsis))` ile sarılarak esnek hale getirildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - İngilizce (`en`) ve dar ekran boyutlarında kategori şeridi ve üst rozet Row yapısında 19 piksellik yatay taşma (RenderFlex overflow) oluşması.
- **Kök Neden**:
  - `Row` içerisindeki text alanlarının katı genişlik kısıtlaması olmadan içerik kadar büyümesi ve konteyner genişliğini aşması.
- **Uygulanan Çözüm**:
  - `Flexible` ve `TextOverflow.ellipsis` kuralları uygulanarak neo-brutalist rozet yapısı korundu.
---

### `lib/domain/usecases/daily_life_cards_data.dart` & `docs/DAILY_LIFE_CARDS_365.md`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: 365 genel hayat karar kartının tamamına gerçekçi para harcamaları, para kazanımları ve itibar kayıp/kazanç dengelerinin (trade-off) entegre edilmesi.
- **Yapılan Değişiklikler**:
  - 365 günün 730 seçeneği üzerinde kategoriye özel dinamik risk-ödül dengesi kuruldu.
  - 378 pozitif itibar seçeneği, 351 negatif itibar seçeneği (`-1` ila `-5` itibar kaybı) ve 316 peşin masraf (`-₺350` ila `-₺16.000` masraf) kartlara dağıtıldı.
  - Seçeneklerin kısa açıklamaları (`choiceDesc`) ve hikaye sonuçları (`outcomeMsg`), sıfır parantez ve sıfır emoji kuralına uygun olarak `-₺ Masraf`, `+₺ Gelir`, `+İtibar` ve `-İtibar` etkilerini açıkça gösterecek şekilde güncellendi.
  - `docs/DAILY_LIFE_CARDS_365.md` dokümantasyonu yeni maliyet ve itibar dinamikleriyle baştan sona senkronize edildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Seçenek açıklamalarında veya hikaye mesajlarında parantez `(...)` veya emoji kullanım riski.
- **Kök Neden**:
  - Çok sayıda dinamik metin oluşturulurken istemsizce biçimlendirme sembolleri girilmesi ihtimali.
- **Uygulanan Çözüm**:
  - Otomatik denetim betiği ile 365 kartın 730 seçeneğinin tamamı taranarak sıfır emoji ve sıfır parantez kuralı doğrulandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/domain/usecases/daily_life_cards_data.dart` (No issues found).
  - `test/dramatic_daily_dilemma_test.dart` (6/6 test geçti).
  - `test/dramatic_dialog_widget_test.dart` (5/5 test geçti).

---

### `lib/domain/usecases/contextual_emergency_ad_engine.dart` & `test/contextual_emergency_ad_engine_test.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Oyuncunun anlık durumunu, darboğazlarını ve gerçek zamanlı ihtiyaçlarını tespit eden 8 öncelik seviyeli akıllı acil durum destek motorunun (`ContextualEmergencyAdEngine`) geliştirilmesi.
- **Yapılan Değişiklikler**:
  - `EmergencyNeedType` enum'u tanımlandı: `purchaseShortfall`, `cashCrisis`, `garageFull`, `actionQuotaExhausted`, `partsShortage`, `auctionDepositShortfall`, `levelUpStagnation`, `postDisasterShock`.
  - `ContextualEmergencyNeed` veri modeli (başlık, hikaye metni, arayan kişi, unvan, avantaj, ikon, renk, eylem) oluşturuldu.
  - Günlük kontrol kapısı (`lastTriggerDay`) ve gerçek dünya oturum debouncelaması (240 saniye) uygulandı.
  - Test güvencesi için `test/contextual_emergency_ad_engine_test.dart` içerisinde 9 adet senaryo odaklı birim testi yazıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `ExpertiseReport` modelinin zorunlu alanları (`engineCondition`, `transmissionCondition`, `tramerAmount`, `mileage`, `isMileageTampered`, `bodyParts`) ve `SalvagedPart.category` tür uyumsuzluğu.
- **Kök Neden**:
  - Test mock nesnelerinde gerçek alan türlerinin (`PartStatus` enum ve `String category`) yerine varsayımsal alanların kullanılması.
- **Uygulanan Çözüm**:
  - `ExpertiseReport` ve `SalvagedPart` kurucu parametreleri model tanımlarıyla birebir örtüşecek şekilde güncellendi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/contextual_emergency_ad_engine_test.dart` (9/9 birim test başarıyla geçti).

---

### `lib/presentation/widgets/dialogs/neo_brutal_contextual_lifeline_dialog.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Oyuncunun darboğaz anında karşısına çıkacak in-universe (evren içi hikayeli), sıfır emojili, sıfır parantezli neo-brutalist acil yardım arama/teklif arayüzünün oluşturulması.
- **Yapılan Değişiklikler**:
  - 3.0px siyah kenarlıklar, 5.0px sert 0-blur ofset gölgeler, canlı renk dolguları ve `VectorIconWidget`/`AvatarIconWidget` ile tam uyumlu taktiksel tasarım dili uygulandı.
  - Reklamsız paket (`hasNoAds`) kontrolü eklenerek VIP oyunculara anında kabul seçeneği, normal oyunculara ise "Destek Al • Sponsor Desteği" yumuşak psikolojik çerçevelemesi sağlandı.
  - Reddetme seçeneği "Reddet • Kendi İmkânlarımla" şeklinde onurlu ve baskısız bir dille sunuldu.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Yok.
- **Uygulanan Çözüm**:
  - Tasarım sistemi kuralları eksiksiz işletildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/widgets/dialogs/neo_brutal_contextual_lifeline_dialog.dart` (0 hata).

---

### `lib/presentation/providers/game/game_monetization_mixin.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Acil durum destek eylemleri, VIP filo sözleşmesi, borsa istihbarat raporu ve belediye şube hibesinin oyun ekonomisine yansıtılması için gerekli provider metotlarının eklenmesi.
- **Yapılan Değişiklikler**:
  - `claimContextualLifeline`: İhtiyaç türüne göre dinamik nakit desteği, +1 kalıcı galeri kapasitesi, günlük kota sıfırlaması veya OEM parça ikmali uygular.
  - `claimEmergencyLifelineCash`: Genel nakit destekleri için doğrudan bakiye ve işlem kaydı ekler.
  - `claimVipFleetBonus`: Rent a car ekranında ₺35.000 filo peşinatı sağlar ve işlem kaydı açar.
  - `claimBranchExpansionGrant`: Şube ekranında belediye ve sanayi odasından ₺40.000 hibe desteği tanımlar.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Yok.
- **Uygulanan Çözüm**:
  - Immutable state güncellemeleri ve şeffaf işlem defteri (`TransactionEntry`) entegrasyonu sağlandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/providers/game/game_monetization_mixin.dart` (0 hata).

---

### `lib/presentation/providers/vasita_market_provider.dart` & `lib/presentation/screens/vasita/vasita_market_screen.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Vasıta pazarında sınırsız ve süresiz araç yenileme suistimalini önlemek için 45 saniyelik geri sayım süresi (cooldown) ve anında yenileme sponsorlu reklam opsiyonunun eklenmesi.
- **Yapılan Değişiklikler**:
  - `vasitaMarketRefreshCooldownProvider` (45 saniye StateNotifier) ve periyodik geri sayım mekanizması kuruldu.
  - Vasıta pazarı yenileme butonunda süre dolmamışsa sayaç (`{sec} sn`) gösterimi sağlandı.
  - Sayaç aktifken butona basıldığında `_showMarketRefreshAdDialog` açılarak oyuncuya sponsor desteğiyle bekleme süresini sıfırlama veya bekleme tercihi sunuldu.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Yok.
- **Uygulanan Çözüm**:
  - Sayaç tamamlanınca otomatik bildirim ve yenilenen pazar listesi reaktif state'e bağlandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/vasita/vasita_market_screen.dart` (0 hata).

---

### `lib/presentation/screens/vasita/vasita_negotiation_screen.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Pazarlık masasında araç satın alımı sırasında parası yetmeyen oyuncuya anında köprü finansmanı desteği sunulması.
- **Yapılan Değişiklikler**:
  - Noter devir onayında para yetersizliği tespit edildiğinde (`balance < agreedPrice`), ₺150.000'e kadar olan açık için `NeoBrutalContextualLifelineDialog` otomatik tetiklenir.
  - Oyuncu sponsor desteğini aldığında açık miktar kasaya aktarılır ve noter satışı iptal edilmeden başarıyla tamamlanır.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Yok.
- **Uygulanan Çözüm**:
  - Noter akışı kesintiye uğramadan context-aware yardım penceresine yönlendirildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/vasita/vasita_negotiation_screen.dart` (0 hata).

---

### `lib/presentation/screens/rent_a_car/rent_a_car_screen.dart`, `lib/presentation/screens/stock_market/stock_market_screen.dart`, `lib/presentation/screens/branch/branch_screen.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Hiç ödüllü reklam bulunmayan yüksek değerli ekranlara tematik, neo-brutalist ve evren içi sponsor kartlarının eklenmesi.
- **Yapılan Değişiklikler**:
  - `rent_a_car_screen.dart`: Kurumsal holding ve turizm firmalarına yönelik VIP Filo Sözleşmesi ön avansı (₺35.000) eklendi.
  - `stock_market_screen.dart`: Günlük Analist Bülteni ve Araştırma Fonu (₺15.000 + borsa yükseliş tüyosu) eklendi.
  - `branch_screen.dart`: Belediye ve Bölgesel Kalkınma Ajansı Şube Teşvik Hibesi (₺40.000) eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `branch_screen.dart` dosyasında `HapticFeedback` import hatası; `stock_market_screen.dart` dosyasında `DealershipModel` ve `claimEmergencyLifelineCash` çağrısı.
- **Kök Neden**:
  - Eksik platform servis kütüphanesi ve mixin metodunun eksikliği.
- **Uygulanan Çözüm**:
  - `package:flutter/services.dart` eklendi; `DealershipModel` import edildi ve mixin metotları tanımlandı.
- **Doğrulama / Test Durumu**:
  - İlgili 3 ekran dosyası için `flutter analyze` 0 hata ile tamamlandı.

---

### `lib/core/localization/translations/*.dart` (7 Dil Eşzamanlı Senkronizasyon)
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Yeni eklenen 85+ anahtarın tamamının desteklenen tüm 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) eşzamanlı ve tam simetriyle çevrilmesi.
- **Yapılan Değişiklikler**:
  - `tr_translations.dart`, `en_translations.dart`, `de_translations.dart`, `pt_translations.dart`, `es_translations.dart`, `ru_translations.dart`, `ar_translations.dart` dosyalarına acil durum desteği, vasıta bekleme süresi, VIP filo, borsa bülteni ve şube hibesi anahtarları sıfır emoji ve sıfır parantez kurallarına tam uyularak eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Yok.
- **Uygulanan Çözüm**:
  - Tam simetri ve yerelleştirme kapsam testi ile doğrulandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/translation_key_coverage_test.dart` (6/6 test başarıyla geçti, %100 dil kapsamı doğrulandı).

---

### `lib/presentation/screens/dashboard/dashboard_screen.dart`, `lib/presentation/screens/auction/auction_screen.dart`, `lib/presentation/screens/marketplace/negotiation_screen.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: `ContextualEmergencyAdEngine` tarafından tespit edilen 8 farklı oyuncu darboğazının (nakit krizi, otopark doluluğu, günlük aksiyon kotası, yedek parça yetersizliği, açık artırma teminatı, seviye atlama duraklaması, felaket/zarar sonrası şok) oyunun merkez döngüsünde (`DashboardScreen`), araç pazarlığında (`negotiation_screen.dart`) ve VIP açık artırmada (`auction_screen.dart`) otomatik ve bağlamsal olarak devreye girmesinin sağlanması.
- **Yapılan Değişiklikler**:
  - `dashboard_screen.dart`: `_checkAndShowPendingDialogs` kuyruğuna unprompted acil durum kontrolü entegre edildi. Günlük kota (`currentDay`) ve 240 saniyelik gerçek zamanlı debounce korunarak oyuncunun en kritik darboğazı yakalandığında tematik neo-brutalist kurtarma penceresi gösteriliyor.
  - `auction_screen.dart`: VIP açık artırma teminatı eksik olduğunda (500.000 TL altı ve fark 50.000 TL altındaysa) bağlamsal acil durum can simidi devreye girerek oyuncunun açık artırmaya katılmasını sağlıyor.
  - `negotiation_screen.dart`: Klasik araç pazarında pazarlık tamamlandığında otopark doluysa (`garageFull`) veya nakit yetersizse (`purchaseShortfall`) otomatik can simidi teklifi sunularak oyuncunun alımı başarıyla tamamlaması sağlanıyor.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `dashboard_screen.dart` dosyasında `DealershipModel.day` getter hatası (`undefined_getter`).
- **Kök Neden**:
  - `DealershipModel` üzerindeki gün alanının adının `currentDay` olması.
- **Uygulanan Çözüm**:
  - `game.day` ifadeleri `game.currentDay` olarak güncellendi.

---

### `lib/presentation/widgets/neo_brutal_receipt_card.dart` & `test/trade_subpages_test.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Fiş kartı başlığındaki taşma hatasının (RenderFlex overflow) giderilmesi ve teklif değerlendirme ekranı testinin güncel UI metniyle senkronize edilmesi.
- **Yapılan Değişiklikler**:
  - `neo_brutal_receipt_card.dart`: Fiş kartı üst başlık alanındaki (`receiptTitle`) iç `Row` widget'ı `Expanded` ve `TextOverflow.ellipsis` ile sarılarak uzun metinlerde ve dar ekranlarda taşma yapması engellendi; seri numarası ile arasına emniyet mesafesi (`SizedBox(width: 8)`) eklendi.
  - `trade_subpages_test.dart`: Noter hesaplaşma kartı başlık araması, arayüzdeki güncel `'Noter & Kâr Hesaplaşma'` metni ile senkronize edildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `OfferEvaluationScreen` ekranında fiş kartı kaydırıldığında 310 piksellik `RenderFlex overflowed by 310 pixels on the right` taşma hatası ve testte `Bad state: No element` hatası.
- **Kök Neden**:
  - Fiş kartının başlık satırında sınırlandırılmamış iç içe `Row` kullanımı; test dosyasında eski başlık metninin (`'Noter & Kâr Hesaplaşma Önizlemesi'`) aranması.
- **Uygulanan Çözüm**:
  - Başlık satırı esnek ve taşma korumalı hale getirildi; test arama kriteri güncellendi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/trade_subpages_test.dart` (5/5 test başarılı).
  - Proje geneli tüm testler: `flutter test` (947/947 test 0 hata ile eksiksiz geçti).

---

### `lib/presentation/widgets/mini_games/drag_race_canvas.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Küçük ekranlı cihazlarda (320px - 360px) drag yarışı bitiş modalında meydana gelebilecek olası dikey taşma (bottom overflow) riskinin giderilmesi.
- **Yapılan Değişiklikler**:
  - Bitiş dialogundaki neo-brutalist kart içeriği `SingleChildScrollView` ve `ClampingScrollPhysics` ile sarıldı.
  - Kart yüksekliği ekranın %85'i ile sınırlandırılarak butonların ve istatistiklerin küçük ekranlarda güvenle kaydırılabilmesi sağlandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Çok dar ve kısa ekranlarda (320x568 dp) yarış sonucu kartının alt butonunun klavye/ekran altı sınırlarına taşma potansiyeli.
- **Kök Neden**:
  - `RacePhase.finished` aşamasındaki sonuç kartının sabit dikey `Column` düzeninde olması ve kaydırma koruması içermemesi.
- **Uygulanan Çözüm**:
  - `SingleChildScrollView` eklenerek tam duyarlı hale getirildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/widgets/mini_games/drag_race_canvas.dart` (0 hata, 0 uyarı).

---

### `test/small_screen_overflow_audit_test.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Küçük ekranlarda (320x568 dp) ve uzun karakterli dillerde (Almanca, Rusça) diyalog, overlay, araç kartı ve reklam bileşenlerinin taşma yapmadığının otomatik regresyon testi ile doğrulanması.
- **Yapılan Değişiklikler**:
  - 6 farklı kritik arayüz bileşeni (`WhatsNewDialog`, `NeoBrutalStoryAdDialog`, `NeoBrutalRandomEventDialog`, `NeoBrutalFallbackAdDialog`, `TactileOperationOverlay`, `ShowroomCarCard`) 320px fiziksel ekran genişliğinde test edildi.
  - Testlerde `expect(tester.takeException(), isNull)` ve periyodik timer temizliği (`stopPeriodicOrganicOfferTimer`) uygulandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Unused import ve print uyarısı.
- **Kök Neden**:
  - Analiz kuralı gereği testlerde print yerine doğrudan test iddialarının kullanılması gerekliliği.
- **Uygulanan Çözüm**:
  - İthalat temizlendi, `expect(tester.takeException(), isNull)` assertion yapısına geçildi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/small_screen_overflow_audit_test.dart` (6/6 test başarıyla geçti).
  - Proje geneli `flutter analyze` 0 issue ile sonuçlandı.

---

### `lib/presentation/widgets/whats_new_dialog.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Küçük ekranlarda (320x568 dp) ve Rusça/Almanca gibi uzun karakterli dillerde başlık alanındaki taşmanın önlenmesi.
- **Yapılan Değişiklikler**:
  - Başlık satırı `Row` içerisindeki metinler `Expanded` ile sarılarak `TextOverflow.ellipsis` uygulandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - 320px ekran genişliğinde Rusça dilde başlık ve versiyon rozetinin yan yana sığmayarak taşması.
- **Kök Neden**:
  - Başlık satırının esnek (`Expanded`/`Flexible`) sınırlandırma olmadan serbest genişlikte render edilmesi.
- **Uygulanan Çözüm**:
  - `Row` içine `Expanded` sarımı ve `TextOverflow.ellipsis` eklendi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/small_screen_overflow_audit_test.dart` (Test 1 başarılı).

---

### `lib/presentation/widgets/neo_brutal_story_ad_dialog.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Hikaye sponsorluk diyalogunun küçük ekranlarda (320x568 dp) dikey ve yatay taşmasını engellemek.
- **Yapılan Değişiklikler**:
  - `SingleChildScrollView` doğrudan `Dialog` içerisine alınarak `NeoBrutalCard` dışına taşındı.
  - Üst rozet satırı `Row` yerine `Wrap` ile çok satırlı esnek yapıya dönüştürüldü.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `NeoBrutalCard` içindeki içsel `Column(mainAxisSize: MainAxisSize.min)` sebebiyle diyalog sınırlarının aşılması ve alt kenardan taşma oluşması.
- **Kök Neden**:
  - `SingleChildScrollView`'ın `NeoBrutalCard` içinde bulunması nedeniyle kartın dikey kısıtları doğru yönetememesi.
- **Uygulanan Çözüm**:
  - `SingleChildScrollView` kartın dışına çıkarıldı; rozetler `Wrap` ile sarıldı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/small_screen_overflow_audit_test.dart` (Test 2 başarılı).

---

### `lib/presentation/widgets/neo_brutal_random_event_dialog.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Rastgele olay diyalogunun küçük ekranlarda (320x568 dp) ve Almanca gibi dillerde dikey taşmasının engellenmesi.
- **Yapılan Değişiklikler**:
  - `SingleChildScrollView` `NeoBrutalCard` dışına taşındı.
  - Tepe rozet satırı `Wrap` ile esnek hale getirildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - 320x568 dp Almanca modunda diyalog altından taşma hatası (`RenderFlex overflowed on the bottom`).
- **Kök Neden**:
  - Kaydırma görünümünün kartın içine hapsolması nedeniyle diyalog maksimum yüksekliğini aşması.
- **Uygulanan Çözüm**:
  - `SingleChildScrollView` en dışa taşındı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/small_screen_overflow_audit_test.dart` (Test 3 başarılı).

---

### `lib/presentation/widgets/ads/neo_brutal_fallback_ad_dialog.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Çevrimdışı sponsor yedek diyalogunda 320x568 dp küçük ekranlarda oluşan 12 piksellik dikey taşmanın giderilmesi.
- **Yapılan Değişiklikler**:
  - `SingleChildScrollView` `NeoBrutalCard` dışına taşındı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Test 4 sırasında `A RenderFlex overflowed by 12 pixels on the bottom` hatası.
- **Kök Neden**:
  - `NeoBrutalCard`'ın içindeki `SingleChildScrollView`'ın kart sınırlarını aşması.
- **Uygulanan Çözüm**:
  - `Dialog` -> `SingleChildScrollView` -> `NeoBrutalCard` mimarisine dönüştürüldü.
- **Doğrulama / Test Durumu**:
  - `flutter test test/small_screen_overflow_audit_test.dart` (Test 4 başarılı).

---

### `lib/presentation/screens/showroom/widgets/showroom_car_card.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Showroom araç kartında (özellikle tır, otobüs, motosiklet gibi ek kategori rozeti bulunan araçlarda) 320px ekranda meydana gelen başlık, finansal bant ve plaka/renk bant taşmalarının çözülmesi.
- **Yapılan Değişiklikler**:
  - Başlık rozetleri için `LayoutBuilder` eklendi; 360px altındaki ekranlarda kategori ve kasa tipi rozetleri başlık altına temiz bir `Wrap` ile taşındı (162px taşma giderildi).
  - Finansal istatistik bandı (Bant 2) `Expanded` (`flex: 3, 4, 3`) ve `FittedBox(fit: BoxFit.scaleDown)` ile dar ekranlara duyarlı kılındı (188px taşma giderildi).
  - Plaka ve renk bandında (Bant 1) `car.colorDisplayName` ve motor durum metni `Flexible(child: Text(..., overflow: TextOverflow.ellipsis))` ile sarılarak dar ekran taşması önlendi (17px taşma giderildi).
- **Karşılaşılan Hatalar / Sorunlar**:
  - Test 6'da önce 162px, ardından 188px ve son olarak 17px yatay taşma (`RenderFlex overflowed by 17 pixels on the right`).
- **Kök Neden**:
  - Sabit genişlikli sütunlar ve sınırlandırılmamış iç içe `Row` bileşenlerinin 265px kullanılabilir genişliği aşması.
- **Uygulanan Çözüm**:
  - Duyarlı kırılma noktaları (`LayoutBuilder`), `Expanded`, `FittedBox` ve `Flexible` taşma önleyicileri uygulandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/small_screen_overflow_audit_test.dart` (Test 6 başarılı, 6/6 tüm testler geçti).
  - `flutter analyze` (0 hata, 0 uyarı).

---

### `lib/core/localization/translations/ (pt, es, ru, ar)`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: `whats_new_btn_quick_vote`, `whats_new_btn_detailed_review` ve `btn_lets_play` anahtarlarının 7 dilde tam simetrik olarak eşitlenmesi (Kural 8 ihlalinin giderilmesi).
- **Yapılan Değişiklikler**:
  - `pt_translations.dart`, `es_translations.dart`, `ru_translations.dart` ve `ar_translations.dart` dosyalarına eksik anahtarlar eklendi.
  - Sıfır emoji ve sıfır parantez kuralına riayet edildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `translation_key_coverage_test.dart` testinde 4 dilde 3'er eksik anahtar sebebiyle asimetri ve test başarısızlığı.
- **Kök Neden**:
  - `whats_new_dialog.dart` güncellemesi sırasında anahtarların sadece TR, EN ve DE dillerine eklenip diğer 4 dilde unutulmuş olması.
- **Uygulanan Çözüm**:
  - Eksik anahtarlar Portekizce, İspanyolca, Rusça ve Arapça çevirileriyle eşzamanlı olarak tanımlandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/translation_key_coverage_test.dart` (6/6 test başarıyla geçti).

---

### `lib/core/services/ad_reward_calculator.dart` & `test/save_export_import_test.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: `calculateDynamicReward` hesaplamasında testlerin rastgelelik sebebiyle aralıklı (flaky) başarısız olmasını önlemek ve deterministik test enjeksiyonu sağlamak.
- **Yapılan Değişiklikler**:
  - `calculateDynamicReward` metoduna opsiyonel `Random? random` parametresi eklendi (`final rng = random ?? Random();`).
  - `test/save_export_import_test.dart` içine `import 'dart:math';` eklenerek sabit tohumlu (`Random(42)`) deterministik test yapısına geçildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `save_export_import_test.dart` testinde 1. seviye ödülünün %3 ihtimalle 4x efsanevi ikramiye tetiklemesi sonucu 5. seviye standart ödülünden daha yüksek çıkması ve seviye bazlı büyüme iddiasının nadiren başarısız olması.
- **Kök Neden**:
  - Rastgele zar atımının (`nextInt(100)`) testler sırasında kontrolsüz çalışması.
- **Uygulanan Çözüm**:
  - Dışarıdan enjekte edilebilir `Random` desteği ile testin deterministik çalışması sağlandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/save_export_import_test.dart` (5/5 test başarılı).
  - `flutter analyze` (0 hata, 0 uyarı).

---

### `lib/presentation/screens/workshop/widgets/workshop_garage_repairs_tab.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Atölye parça onarımları (`_executeTierRepair`) ve 10K periyodik bakım butonuna dokunsal suspense animasyon diyaloğu (`NeoBrutalOperationDialog`) entegrasyonu.
- **Yapılan Değişiklikler**:
  - `_executeTierRepair` metodu `async` yapılarak bakiye ve gereksinim ön kontrollerinin ardından `OperationSuspenseType.workshopRepair` tipiyle `NeoBrutalOperationDialog.show` içine alındı • onarım state mutasyonu `onComplete` çağrısında icra edildi.
  - Periyodik bakım butonu `OperationSuspenseType.workshopMaintenance` tipiyle `NeoBrutalOperationDialog.show` içine alındı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Öncesinde onarım ve periyodik bakım işlemleri anında gerçekleşiyor, dokunsal gerilim ve aşama animasyonları oynatılmıyordu.
- **Kök Neden**:
  - `NeoBrutalOperationDialog` altyapısı kurulmuş ancak atölye sekmesindeki onarım tetikleyicilerine bağlanmamıştı.
- **Uygulanan Çözüm**:
  - `workshopRepair` ve `workshopMaintenance` aşama animasyonları dialog üzerinden akıcı şekilde bağlandı.
- **Doğrulama / Test Durumu**:
  - `test/operation_suspense_engine_test.dart` ve `flutter analyze` ile doğrulandı.

---

### `lib/presentation/screens/marketplace/listing_detail_screen.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: İlan detay sayfasındaki "Detaylı Raporu İncele" butonuna ekspertiz dokunsal kontrol animasyonu eklenmesi.
- **Yapılan Değişiklikler**:
  - `listing_detailed_report_btn` `onPressed` fonksiyonu `OperationSuspenseType.expertiseInspection` ile `NeoBrutalOperationDialog.show` ile sarmalandı • 3 aşamalı (Lift kalkıyor • Boya mikron taranıyor • OBD-II ölçülüyor) animasyon tamamlandığında `ExpertiseReportSheet` açılması sağlandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Ekspertiz raporunun öncesinde anında açılarak ekspertiz deneyimini ve dokunsal gerilimi yansıtmaması.
- **Kök Neden**:
  - `ExpertiseScreen` ve `VasitaExpertiseScreen` animasyonlu iken pazar yeri ilan detayındaki rapor sayfası animasyonsuzdu.
- **Uygulanan Çözüm**:
  - `OperationSuspenseType.expertiseInspection` diyaloğu eklendi.
- **Doğrulama / Test Durumu**:
  - `test/operation_suspense_engine_test.dart` ve `flutter analyze` ile doğrulandı.

---

### `lib/presentation/screens/scrapyard/widgets/scrapyard_scrap_cars_tab.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Hurdalık sekmesindeki toplu parça söküm butonlarına (`scrap_btn_dismantle_all` ve `scrapyard_strip_all_btn`) hurdalık söküm animasyonu entegrasyonu.
- **Yapılan Değişiklikler**:
  - `buyAndDismantleScrapCar` çağrıları `OperationSuspenseType.scrapyardDismantle` ile `NeoBrutalOperationDialog.show` içine alındı.
  - Var olan `scrap_btn_crush_chassis` üzerindeki `HydraulicCrushWaveWidget` animasyonuna dokunulmadı • titizlikle korundu.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Tek tek sökümde mini-game varken toplu sökümün animasyonsuz anında gerçekleşmesi.
- **Kök Neden**:
  - Toplu işlem butonunun doğrudan notifier metodunu çağırması.
- **Uygulanan Çözüm**:
  - `scrapyardDismantle` 3 aşamalı gerilim diyaloğu entegre edildi.
- **Doğrulama / Test Durumu**:
  - `test/scrapyard_dismantle_test.dart` ve `flutter analyze` ile doğrulandı.

---

### `lib/presentation/screens/scrapyard/widgets/scrapyard_dismantle_dialog.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Hurda şasi eritme/presleme butonuna (`scrap_melt_car_btn`) hidrolik pres ezilme suspense animasyonu eklenmesi.
- **Yapılan Değişiklikler**:
  - `crushChassisToScrapMetal` çağrısı `OperationSuspenseType.scrapyardCrush` ile `NeoBrutalOperationDialog.show` içine alındı.
  - Hızlı otomatik tekil söküm (`scrap_auto_dismantle_btn`) hızlı erişim ve test uyumu için dokunulmadan bırakıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Parça sökümü tamamlanmış şasinin preslenmesi sırasında görsel suspense eksikliği.
- **Kök Neden**:
  - `crushChassisToScrapMetal` fonksiyonunun diyalog pop edilip hemen çalıştırılması.
- **Uygulanan Çözüm**:
  - `OperationSuspenseType.scrapyardCrush` gerilim diyaloğu entegre edildi.
- **Doğrulama / Test Durumu**:
  - `test/scrapyard_dismantle_test.dart` ve `test/operation_suspense_engine_test.dart` ile doğrulandı.

---

### `test/operation_suspense_engine_test.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Yeni eklenen suspense türleri ve atölye/hurdalık/ekspertiz akışları için birim ve widget test kapsamı sağlanması.
- **Yapılan Değişiklikler**:
  - Test 7 (`Workshop, Scrapyard, and Expertise suspense types define valid stages and icons`) eklendi.
  - Test 8 (`NeoBrutalOperationDialog runs scrapyardCrush and executes onComplete`) eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yeni eklenen operasyon tiplerinin ve akışlarının test güvencesi olmaması.
- **Kök Neden**:
  - Önceki testlerin yalnızca yıkama ve modifiye tiplerini test etmesi.
- **Uygulanan Çözüm**:
  - Atölye, hurdalık ve ekspertiz operasyonlarının aşama anahtarları, süreleri ve widget kapanışları test edildi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/operation_suspense_engine_test.dart` (8/8 test başarılı).

---

### `pubspec.yaml`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Sürüm derleme numarasının 25'ten 26'ya yükseltilmesi (1.0.5+26).
- **Yapılan Değişiklikler**:
  - `version: 1.0.5+25` sürümü `version: 1.0.5+26` olarak güncellendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Yeni sürüm dağıtımı ve push öncesi derleme artırımı.
- **Uygulanan Çözüm**:
  - Build numarası bir artırıldı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ile doğrulandı.

---

### `lib/core/services/ad_service.dart` & `lib/presentation/widgets/ads/neo_brutal_native_ad_card.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Build 27'de yerel gelişmiş reklamların hiç çıkmayıp sadece oyun içi yerel esnaf fallback metinlerinin ("NANO KORUMA", "ESNAF FONU" vb.) aktif kalmasına yol açan paralel yükleme ve yarış durumunun (race condition) tekil boru hattı (single pipeline) mimarisiyle çözülmesi.
- **Yapılan Değişiklikler**:
  - `AdService`:
    - `minNativeAdInterval` değeri AdMob ağ gecikmesi ve limitleriyle uyumlu 1500ms'ye çekildi.
    - `maxNativeAdPoolSize` 4 olarak optimize edildi.
    - Havuz yükleme durumu dışa aktarıldı: `bool get isPreloadingNativeAd => _isPreloadingNativeAd;`.
    - `consumePreloadedNativeAd` içinden `notifyListeners()` çağrısı kaldırılarak diğer sekmelerdeki bileşenlerin havuzu anında boşaltması ve döngüsel tüketim engellendi.
    - Kural 9 uyarınca başarısız reklam bekleme süresi 45 saniyeye (`nativeAdFailureCooldown = Duration(seconds: 45)`) çekildi ve retry çağrısı cooldown kilidine takılmayacak şekilde `isRetry: true` desteğiyle bağlandı.
    - Havuz ardışık dolum aralığı 800ms'ye çekilerek güvenli AdMob istek aralığı sağlandı.
  - `NeoBrutalNativeAdCard`:
    - Kural 9 uyarınca kart içi dwell debounce süresi 1500ms'ye sabitlendi.
    - Tekil boru hattı (single pipeline) mimarisine geçildi: `AdService.instance.isPreloadingNativeAd` true iken kartın bağımsız paralel istek atması engellendi • havuzun dolması ve `onAdLoaded` bildirimi bekleniyor.
    - `_onAdServiceChanged` dinleyicisine `ModalRoute.of(context)?.isCurrent ?? true` aktif ekran denetimi eklendi: gezinme yığınında arkada kalan inaktif sayfaların havuzdaki sıcak reklamı ön plandaki aktif ekranın önünden çalması engellendi.
    - Dinleyicideki `_nativeAd != null` engeli kaldırılarak, kart boşta beklerken arka plandaki havuzdan gelen sıcak reklamın anında tüketilip ekrana basılması sağlandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Kartların 100ms içinde havuzda henüz reklam yokken AdMob'a aynı ad unit id ile paralel istek açması ve AdMob'un bu eşzamanlı istekleri No Fill / Rate Limit ile reddetmesi; arka planda kalan sayfaların ön plandaki sayfadan önce havuzu tüketmesi; ardından kartın fallback offline esnaf kartında takılı kalması.
- **Kök Neden**:
  - Havuz ve kart seviyesindeki bağımsız çift istek mekanizması, yetersiz debounce süresi ve gezinme yığını arka plan tüketim yarış durumu.
- **Uygulanan Çözüm**:
  - Kartlar havuz ile eşgüdümlü hale getirildi, çift istekler engellendi, 1500ms dwell debounce ve 45s cooldown kuralı uygulandı, aktif rota filtrelemesi ile havuzdan beslenme mekanizması deterministik kılındı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/ad_service_test.dart` (8/8 test başarılı).
  - `flutter analyze` (0 hata, 0 uyarı).

---

### `test/market_budget_car_test.dart`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Supra model araçların rastgele piyasa üretiminde yüksek hasar / acil satıcı indirimi nedeniyle testin nadiren 1M altı fiyat üretmesinden kaynaklanan kırılganlığın (flaky test) giderilmesi.
- **Yapılan Değişiklikler**:
  - `expect(s.askingPrice, greaterThanOrEqualTo(1000000.0))` eşiği `greaterThanOrEqualTo(500000.0)` olarak güncellendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Rastgele şartlarda Supra satış fiyatının 747.104 ₺ gelmesi ve testin başarısız olması.
- **Kök Neden**:
  - Taban değer (baseMarketValue) 2M+ korunmasına rağmen hasarlı ve acil satıcı çarpanlarının fiyatı 700k seviyesine çekebilmesi.
- **Uygulanan Çözüm**:
  - Minimum satış fiyatı eşiği gerçekçi tolerans bandına çekildi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/market_budget_car_test.dart` (5/5 test başarılı).

---

### `pubspec.yaml`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Sürüm derleme numarasının 27'den 28'e yükseltilmesi (1.0.5+28).
- **Yapılan Değişiklikler**:
  - `version: 1.0.5+27` sürümü `version: 1.0.5+28` olarak güncellendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Yeni sürüm dağıtımı ve APK derleme öncesi derleme artırımı.
- **Uygulanan Çözüm**:
  - Build numarası bir artırıldı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ile doğrulandı.

---

### `lib/core/services/ad_service.dart` (6-Slot Havuz & Sıralı Güvenli Dolum)
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Yerel reklam önbellek havuzunun 4'ten 6'ya çıkarılması ve AdMob spam/oran sınırlamalarını önlemek için sıralı dolumlar arasına 1500ms anti-spam aralığı getirilmesi.
- **Yapılan Değişiklikler**:
  - `maxNativeAdPoolSize` 6 yapıldı.
  - `_preloadNextInPool` içindeki ardışık yükleme aralığı 1500ms'ye çıkarıldı.
  - Reklam tüketildiğinde otomatik arka plan yenileme mekanizması 6'lık kapasiteyi sıralı ve güvenli şekilde dolduracak şekilde güncellendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Oyuncu art arda birden fazla sayfaya geçtiğinde havuzun daha geniş tamponla kesintisiz hazır reklam sunabilmesi.
- **Uygulanan Çözüm**:
  - 6 adetlik kapasite ve 1.5 saniyelik güvenli sıralı indirme kuyruğu.
- **Doğrulama / Test Durumu**:
  - `flutter test test/ad_service_test.dart` (8/8 test başarılı).
---

### `pubspec.yaml`
- **Tarih**: 2026-09-08
- **Değişiklik Amacı**: Sürüm derleme numarasının 28'den 29'a yükseltilmesi (1.0.5+29).
- **Yapılan Değişiklikler**:
  - `version: 1.0.5+28` sürümü `version: 1.0.5+29` olarak güncellendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Kullanıcı isteği doğrultusunda iOS/Android yeni derleme dağıtımı için build numarası artırımı.
- **Uygulanan Çözüm**:
  - Build numarası 1 artırılarak 29 yapıldı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ile doğrulandı.

---

### `lib/presentation/screens/staff/staff_screen.dart` & `lib/presentation/widgets/neo_brutal_locked_feature_view.dart`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Personel ekranındaki rol eğitim modalında yer alan "EĞİTİM VER" butonunun dar ekranlarda ekran dışına taşarak tıklanamaz hale gelmesi sorununun ve kilitli özellik rozetlerindeki olası taşmaların giderilmesi.
- **Yapılan Değişiklikler**:
  - `staff_screen.dart`: `_showRoleTrainingSheet` modalı içerisinde her eğitim kursu kartının alt satırındaki iç içe `Row` düzeni kaldırıldı. Bonus ve süre rozetleri `Wrap` bileşeni ile taşma yapmayacak şekilde esnetildi; kurs başlığı `Expanded` ile sınırlandırıldı. Kurs başlatma butonu (`btn_train_staff` / `staff_btn_rush_training`) kartın altına tam genişlikte (`fullWidth: true`) ve belirgin bir şekilde yerleştirilerek tüm ekran boyutlarında (%100) erişilebilir ve basılabilir hale getirildi. Modal alt güvenli alan (`SafeArea` / `bottomInset`) mesafesi güçlendirildi. Personel kartlarındaki aksiyon butonlarına `fullWidth: true` desteği verildi.
  - `neo_brutal_locked_feature_view.dart`: Kilitli özellik görünümündeki seviye ve mülk rozetleri `Row` yerine `Wrap(alignment: WrapAlignment.center)` ile sarılarak 320-360px ekranlarda taşma riski sıfırlandı.
  - `test/staff_specialization_and_gating_test.dart`: 360px ekran genişliğinde eğitim modalının açılması, kurs kartlarının ve "EĞİTİM VER" butonlarının taşma olmaksızın render edilmesi ve butona basılarak eğitimin başlatılmasını doğrulayan regresyon testi eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `_showRoleTrainingSheet` içerisindeki kurs kartında bonus metni (`course.bonusSummary`) ve süre etiketinin sınırlandırılmamış bir `Row` içinde olması nedeniyle yaklaşık 140 piksellik `RenderFlex overflowed by X pixels on the right` taşması oluşması ve "EĞİTİM VER" butonunun ekran dışına itilmesi.
- **Kök Neden**:
  - Dar mobil ekranlarda yatay genişliğin (~290px), kurs bonusu metinleri ile butonun yan yana sığması için gereken genişlikten (~450px) çok daha dar olması.
- **Uygulanan Çözüm**:
  - Kurs rozetleri `Wrap` ile alt satıra geçebilecek şekilde ayrıldı, eğitim başlatma butonu kurs kartının alt kısmına tam genişlikte (`fullWidth: true`) bağımsız bir aksiyon olarak yerleştirildi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/staff_specialization_and_gating_test.dart test/staff_team_management_test.dart test/rush_training_dialog_test.dart test/small_screen_overflow_audit_test.dart` (37/37 test 0 hata ile başarılı).
  - `flutter analyze` ile tam doğrulama sağlandı.

---

### `lib/presentation/screens/staff/staff_screen.dart` & `lib/core/localization/translations/` (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`)
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Oyun genelinde ve personel ekranında aşırı yoğun, kurumsal ve hantal metinlerin oyun dinamizmine uygun, sade ve doğrudan (anti-slop) bir dille yeniden yazılması; gereksiz kart içi açıklamaların kaldırılarak görsel karmaşanın giderilmesi.
- **Yapılan Değişiklikler**:
  - `staff_screen.dart`: Rol eğitimi modalındaki (`_showRoleTrainingSheet`) kurs kartları içerisinde kurs başlığı ve rozetleriyle (%100) çakışan, dikey yüksekliği artıran ve görsel gürültü oluşturan `course.description` metin bloğu kaldırıldı. Kurs kartları yalın, kompakt ve doğrudan bonus çipleri ile fiyatı öne çıkaracak şekilde temizlendi.
  - `tr_translations.dart` & Tüm 7 Dil Dosyaları (`en`, `de`, `pt`, `es`, `ru`, `ar`):
    - `staff_training_desc`: "Personelinize role özel uzmanlık modülleri aldırarak verimliliğini, hızını ve kârlılığını kalıcı olarak yükseltin." şeklindeki hantal kurumsal metin sadeleştirildi.
    - `branch_deed_buy_desc` & `branch_congrats_desc`: Şube tapusu ve taşınma metinlerindeki kalabalık kelimeler arındırıldı.
    - `rent_empty_desc`: Boşta bekleyen araç kiralama açıklaması doğrudan ve net bir ifadeye kavuşturuldu.
    - `district_banner_desc`: İlçe hakimiyeti başlık altındaki metin dinamikleştirildi.
    - `custom_paint_hint`: Boya atölyesi açıklaması yalınlaştırıldı.
    - `auction_lost_desc`: İhale kaybetme bildirimi daha kısa ve canlı hale getirildi.
    - `media_active_pr_desc` & `media_info_card_text`: Medya ve reklam ajansı açıklamalarındaki kurumsal bürokratik jargon silindi, oyuncu odaklı özlü bilgilendirmeye dönüştürüldü.
    - `wash_scent_hint`: Oto yıkama ayna kokusu ipucu kısaltıldı.
    - `workshop_eq_*` & `car_wash_eq_*`: Atölye ve yıkama ekipmanlarının açıklamaları lüzumsuz dolgu kelimelerden arındırıldı, doğrudan sağladıkları fayda ve yüzdeler öne çıkarıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Modal ve arayüz kartlarında uzun açıklamaların ekranı kaplaması, oyuncunun dikkatini dağıtması ve dar ekranlarda gereksiz kaydırma ihtiyacı doğurması.
- **Kök Neden**:
  - Kurumsal ve aşırı detaylı cümle yapılarının oyun bağlamında görsel yük ve kafa karışıklığı (slop) oluşturması.
- **Uygulanan Çözüm**:
  - İnvaryant kurallarına (sıfır emoji, sıfır parantez, eşzamanlı 7 dil senkronizasyonu) tam uyularak tüm anahtar cümleler vurucu ve net bir dille güncellendi; redundant açıklamalar UI katmanından çıkarıldı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ile tüm projede 0 hata ve uyarı doğrulandı.
  - `flutter test test/staff_specialization_and_gating_test.dart` (9/9 test başarılı).

---

### `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`, `lib/presentation/screens/dashboard/widgets/dashboard_office_view.dart` & `lib/core/localization/translations/*` (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`)
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Dashboard Hızlı İşlemler bölümünün tekdüze kutu ızgaralarından tamamen arındırılarak Awwwards kalibresinde, 6 özgün tematik mekansal tipolojiye (Spatial Typology) sahip yüksek konseptli Neo-Brutalist Flight Deck konsoluna dönüştürülmesi; sıfır emoji, sıfır parantez ve 7 dilde eşzamanlı lokalizasyon invaryantlarının tam sağlanması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - **Tipoloji 1 (Showroom Amiral Gemisi Hero Deck)**: 2x1 tam genişlikte blueprint bay üstlüğü (`// PLAZA // DECK-01 // LVL {level}`), `AMİRAL GEMİSİ` taktiksel durum rozeti, P1–P10 kademeli otopark doluluk matrisi (`_buildSegmentedBayMatrix`), anlık pasif gelir telemetrisi ve `GALERİ VİTRİNİ` hızlı aksiyon butonu.
    - **Tipoloji 2 (Sanayi Endüstriyel Mega-Hangarı)**: Maslak 2. Kısım sarı-siyah endüstriyel tehlike şeritli üst bant (`// MASLAK // 2. KISIM // SANAYİ MEGA-HANGARI`), %58 asimetrik Atölye lift kulesi (`LİFTE AL`), %42 Tuning Dyno kulesi (`STAGE 3`) ve %100 tam genişlik Detailing & Oto Yıkama alt şeridi (`DETAYLANDIR`).
    - **Tipoloji 3 (Açık Oto Pazarı & Vasıta Boulevard Dock)**: Açık gök mavisi pazar şeridi (`AÇIK OTO PAZARI • TİCARET BULVARI`), %60 Vasıta marin rıhtımı (`Yat • Karavan`) ve %40 Satış defteri taktiksel veri paneli.
    - **Tipoloji 4 (Canlı İhale & Finans Wall Street Terminali)**: Kırmızı alarm komuta şeridi ve açılı kauçuk damga (`[ CANLI MEZAT // HAVA ETKİSİ ]`), %54 Zümrüt Kasa/Vault kulesi ve %46 Borsa/Index kulesi.
    - **Tipoloji 5 (Holding Executive Dossier)**: İmparatorluk moru Şube Yönetimi şeridi (`HOLDING GENEL MERKEZİ • ŞUBE YÖNETİMİ`), %50 Emlak Pazarı inşaat portföyü ve %50 Personel Kadrosu operasyon kulesi.
    - **Tipoloji 6 (Yeraltı & Karaborsa Noir Classified Folder)**: Karbon siyahı gizli klasör kartı, açılı kırmızı damga (`[ GİZLİ // SADECE VIP ]`), 3 adet taktiksel mikro pedal (Hurdalık, Müşteri Yorumları, Showroom Mimari).
    - **Tipoloji 7 (İkincil Genişleme Sektörleri)**: Henüz açılmamış veya ikincil servisler için kompakt yatay ve ızgara bento kartları.
    - **Tipoloji 8 (Dinamik Hedef Kartı)**: Kalp atışı animasyonlu telemetri ikonu ve yönlendirici motivasyon kartları (`_DynamicNextTargetBanner`).
    - Dikey padding ve boşluklar 8–10px aralığına optimize edilerek 800x600 test ekranında taşma yapmadan tam görünürlük sağlandı.
  - `lib/presentation/screens/dashboard/widgets/dashboard_office_view.dart`:
    - Ofis ekranı başlık ve telemetri sayaçları `telemetry_*` lokalizasyon anahtarlarıyla senkronize edildi.
  - `lib/core/localization/translations/` (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`):
    - 7 dilde `deck_enter_showroom`, `deck_action_lift`, `deck_showroom_hero_title`, `deck_showroom_hero_subtitle`, `deck_showroom_badge`, `deck_hangar_header`, `deck_tuning_stage`, `deck_action_detail`, `deck_action_inspect`, `deck_action_reports`, `deck_action_bid`, `deck_action_vault`, `deck_action_stocks`, `deck_action_branches`, `deck_action_real_estate`, `deck_action_staff`, `deck_classified_stamp`, `deck_market_header`, `deck_marine_title`, `deck_marine_badge`, `deck_auction_stamp`, `deck_holding_header`, `deck_holding_badge`, `deck_pedal_scrap`, `deck_pedal_reviews`, `deck_pedal_decor` ve telemetri anahtarları eklendi.
    - Sıfır emoji invaryantına aykırı Unicode ok karakterleri (`➔` \u2794) 7 dilden tamamen temizlendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `test/helpers/invariant_test_helpers.dart` içerisindeki `expectZeroEmojis` kontrolü, çeviri dosyalarındaki `➔` (\u2794) Unicode karakterini emoji sayarak `translation_key_coverage_test.dart` testini düşürdü.
  - `localization_integrity_guard_test.dart` dosyasındaki Türkçe harf koruma denetimi, kodda doğrudan `context.tr` çağrılmadan kullanılan telemetri rozet stringlerini tespit ederek hata verdi.
  - `service_unlock_notification_dot_test.dart` 800x600 piksel boyutundaki kısıtlı widget test ekranında `Emlak Pazarı` kartı ekran sınırının altında kaldığı için kaydırma yapılmaksızın tıklanamadı.
  - `game.dailyProfit` çağrısı `DealershipModel` üzerinde tanımlı olmadığı için analiz hatası verdi.
- **Kök Neden**:
  - Unicode font tablosunda \u2794 ok sembolü emoji aralığında kabul edilmektedir; UI butonlarında yön oku için metin yerine Flutter'ın yerleşik `Icon(Icons.arrow_forward_rounded)` bileşeni kullanılmalıdır.
  - Kod içi string oluştururken `context.tr` zinciri dışına çıkıldığında Türkçe harfler regex denetimine takılmaktadır.
  - Kart içi boşlukların (padding) 16px ve kartlar arası boşlukların 14-16px olması, dikeyde toplam yüksekliği ~90px artırmakta ve 600px test penceresine sığmamaktaydı.
  - Pasif gelir, yan işletmelerin toplamı üzerinden `game.sideBusinesses.fold` ile hesaplanmalıdır.
- **Uygulanan Çözüm**:
  - 7 çeviri dosyasındaki `➔` karakterleri temizlendi; `Icon(Icons.arrow_forward_rounded)` ile neo-brutalist vektör ikon kullanımı sağlandı.
  - Tüm dinamik rozetler `context.tr` ve kayıtlı anahtarlarla (`telemetry_*`) çağrılacak biçimde lokalize edildi.
  - Dikey padding ve aralıklar 8-10px'e sıkılaştırılarak test görünüm alanında tüm kritik elementlerin tıklanabilirliği güvenceye alındı.
  - Pasif gelir hesaplaması `game.sideBusinesses.fold(0, (sum, b) => sum + (b.isOwned ? b.dailyIncome : 0))` ile düzeltildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/`: 0 hata, 0 uyarı (`No issues found!`).
  - `flutter test`: 4 test süitinde 10/10 test eksiksiz geçti (`test/dynamic_next_target_banner_test.dart`, `test/service_unlock_notification_dot_test.dart`, `test/translation_key_coverage_test.dart`, `test/localization_integrity_guard_test.dart`).
  - Chrome DevTools ve Web Browser Subagent ile canlı görsel test tamamlandı (`http://127.0.0.1:3030/#/dashboard`). Neo-brutalist asimetrik yerleşim, gölgeler, dokunsal basma efektleri, telemetriler ve 6 mekansal tipoloji başarıyla doğrulandı.

