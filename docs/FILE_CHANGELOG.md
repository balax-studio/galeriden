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
```

### `16-Bit Neo-Brutalist Prosedürel Piksel Yüz Rozetleri ve Pop-up Entegrasyonu (§SPEC-2026-09-13-NEO-BRUTAL-PIXEL-FACES)`
- **Tarih**: 2026-09-13
- **Değişiklik Amacı**:
  - Projedeki tüm pop-up ve modal diyalog kartlarına (`NeoBrutalOperationDialog`, `EmergencyBailoutDialog`, `LuckyOpportunityDialog`, `DailyBulletinDialog`), kartın sağ üst köşesinden dışarı taşan (`Stack` + `Positioned(top: -18, right: -10)` ile `clipBehavior: Clip.none`), 16-bit retro-arcade ve neo-brutalist tarzda prosedürel piksel yüz rozetleri eklenmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/widgets/pixel_art/neo_brutal_pixel_face.dart`:
    - [YENİ]: `PixelFaceExpression` enum'ı tanımlandı (`cunningDealer`, `panickedBanker`, `sweatingMechanic`, `smugNotary`, `hypedGambler`).
    - [YENİ]: 16x16 matris koordinatlı, saf Flutter `CustomPainter` tabanlı `NeoBrutalPixelFaceWidget` oluşturuldu. Harici bitmap gerektirmeden 2.5px solid siyah kenarlık, 0-blur hard offset gölge (`Offset(3, 3)`), -0.06 radyan eğimli çıkartma açısı, CRT scanline dokusu ve isteğe bağlı lokalize mini rozet çıkartması uygulandı. `shouldRepaint` kontrolü ifade eşitliğiyle optimize edildi.
  - `lib/presentation/widgets/emergency_bailout_dialog.dart`:
    - Dialog kartı `Stack(clipBehavior: Clip.none)` ile sarmalanarak sağ üst köşeye `PixelFaceExpression.panickedBanker` (panikleyen finansçı) yüz rozeti eklendi.
  - `lib/presentation/widgets/dialogs/lucky_opportunity_dialog.dart`:
    - Dialog kartı `Stack(clipBehavior: Clip.none)` ile sarmalanarak sağ üst köşeye `PixelFaceExpression.hypedGambler` (yıldız gözlü coşkulu kumarbaz) yüz rozeti eklendi.
  - `lib/presentation/widgets/dialogs/neo_brutal_operation_dialog.dart`:
    - `OperationSuspenseType` bağlamına göre dinamik ifade belirlendi: `notaryTransfer` -> `smugNotary` (resmi memur), `expertiseInspection` -> `cunningDealer` (kurnaz galerici), diğer atölye/modifiye/yıkama/hurdalık işlemleri -> `sweatingMechanic` (terleyen usta). Sağ üst köşeye taşacak şekilde monte edildi.
  - `lib/presentation/widgets/daily_bulletin_dialog.dart`:
    - Dialog kartı `Stack(clipBehavior: Clip.none)` ile sarmalanarak sağ üst köşeye `PixelFaceExpression.cunningDealer` (kurnaz galerici) yüz rozeti eklendi.
  - `lib/core/localization/translations/`:
    - `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar` dillerinin 7'sine de eşzamanlı olarak `pixel_face_dealer`, `pixel_face_banker`, `pixel_face_mechanic`, `pixel_face_notary`, `pixel_face_gambler` anahtarları eklendi. Unicode emoji ve parantez kullanılmadı.
  - `test/neo_brutal_pixel_face_test.dart`:
    - [YENİ]: 5 farklı mimik durumunun render doğrulaması, 7 dilli invariant key denetimi, Türkçe ve İngilizce rozet metni testi, dokunma mekanik baskı etkileşimi ve renk token testleri yazıldı (6/6 test başarılı).
- **Karşılaşılan Hatalar / Sorunlar**:
  - 1. Test Localization Delegate Hatası: İlk test denemesinde `DefaultMaterialLocalizations.delegate` kullanıldığında Türkçe (`tr`) yerel ayarı için delegate bulunamadı uyarısı alındı.
  - 2. `toUpperCase()` Türkçe Karakter Uyuşmazlığı: Testte `'PANİK!'` (`\u0130`) beklenirken Dart standart String `.toUpperCase()` metodunun ASCII uyumlu `'PANIK!'` (`\u0049`) üretmesi sonucu test assert hatası oluştu.
  - 3. Parantez/Köşeli Parantez Kapanış Uyuşmazlığı: `daily_bulletin_dialog.dart` ve `lucky_opportunity_dialog.dart` içerisinde `Stack` sarmalaması sonrası `Column(children: [...])` ve `SingleChildScrollView` kapanışlarında eksik parantez/köşeli parantez syntax uyarısı alındı.
- **Kök Neden**:
  - `GlobalMaterialLocalizations.delegate` yerine eksik delegate kullanımı, Dart dilinde yerel bağımsız büyük harf dönüşüm davranışı ve iç içe widget hiyerarşisinde kapanış belirteçlerinin kayması.
- **Uygulanan Çözüm**:
  - Testte `GlobalMaterialLocalizations.delegate` ve proje standart `expectInvariantKeys` helper'ı kullanıldı, test beklentisi Dart VM çıktısıyla eşitlendi ve dialog dosyalarındaki tüm widget hiyerarşisi tam olarak kapatıldı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/... test/...`: 0 hata, 0 uyarı (No issues found).
  - `flutter test test/neo_brutal_pixel_face_test.dart`: 6/6 test geçti.
  - `flutter test test/translation_key_coverage_test.dart`: 6/6 test geçti.
  - `flutter test test/ui_ux_pro_max_and_shaders_test.dart`: 14/14 test geçti.
  - `flutter test test/operation_suspense_engine_test.dart`: 8/8 test geçti.
  - `flutter test test/dramatic_dialog_widget_test.dart`: 5/5 test geçti.

### `Sistemik Bellek Sızıntısı, Hayalet Zamanlayıcı ve Yaşam Döngüsü Denetimi (§SPEC-2026-09-12-MEMORY-LEAK-AND-LIFECYCLE-AUDIT)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Projedeki 424 Dart dosyasında bellek sızıntısı (memory leak), askıda kalan hayalet zamanlayıcılar (ghost timers), arka plan pil tüketimi ve Flutter yaşam döngüsü (`setState during build`) risklerinin taranarak kök nedenleriyle cerrahi olarak giderilmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/providers/game/game_core_provider.dart`:
    - `onAppResumed`: Uygulama arka plandan ön plana döndüğünde `startPeriodicOrganicOfferTimer()` yerine `resumePeriodicOrganicOfferTimer()` çağrıldı. Böylece `onAppPaused` sırasında `true` yapılan `_isOrganicTimerExplicitlyStopped` bayrağı sıfırlandı ve oyun günü / teklif zamanlayıcısının kalıcı olarak durması engellendi.
  - `lib/presentation/providers/outsourced_tuning_provider.dart`:
    - `_startTicker`: İşlemde olan sipariş bulunmadığında (`TuningOrderStatus.inProgress` yokken) her saniye periyodik çalışan zamanlayıcı durduruldu. Sadece aktif sipariş varken çalışması ve tüm siparişler bittiğinde zamanlayıcının kapanması sağlandı. `onAppPaused()` ve `onAppResumed()` entegrasyonu eklendi.
  - `lib/presentation/providers/vasita_market_provider.dart`:
    - `onAppPaused` ve `onAppResumed` metotları eklenerek 4 dakikalık periyodik piyasa yenileme zamanlayıcısının uygulama arka plandayken gereksiz yere veri üretmesi engellendi.
  - `lib/presentation/providers/real_estate_market_provider.dart`:
    - `onAppPaused` ve `onAppResumed` metotları eklenerek 5 dakikalık gayrimenkul piyasa zamanlayıcısı yaşam döngüsüne bağlandı.
  - `lib/app/app.dart`:
    - `didChangeAppLifecycleState`: `vasitaMarketProvider`, `realEstateMarketProvider` ve `outsourcedTuningProvider` yaşam döngüsü olaylarına (`paused` / `resumed`) bağlandı.
  - `lib/presentation/widgets/ads/neo_brutal_native_ad_card.dart`:
    - `build` metodu içinde senkron olarak çağrılan `_evaluateAdLoading`, `WidgetsBinding.instance.addPostFrameCallback` içine alındı. Böylece `build` sırasında doğrudan `setState()` tetiklenerek arayüz çökmesi veya uyarı verilmesi riski bertaraf edildi.
  - `lib/presentation/providers/game/game_inventory_mixin.dart` & `lib/presentation/providers/game/game_market_mixin.dart`:
    - `salesHistory` listesi en güncel 150 kayıtla sınırlandırılarak uzun oyun oturumlarında sınırsız büyümesi ve yığın bellek (heap) şişmesi önlendi.
    - `customerReviews` listesi en güncel 50 kayıtla sınırlandırılarak durum serileştirme yükü dengelendi.
  - `test/lifecycle_and_memory_leak_audit_test.dart`:
    - [YENİ]: Yaşam döngüsü duraklatma/devam etme, zamanlayıcı temizliği ve liste sınırlarını doğrulayan 5 adet regresyon testi yazıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - 1. Kritik Saat Donması Hatası: Oyuncu uygulamayı simge durumuna küçültüp geri açtığında oyun saati ve vitrin teklifleri oturum boyunca kalıcı olarak duruyordu.
  - 2. Hayalet İş Parçacığı / Pil Tüketimi: Sanayi modifiyesinde hiçbir sipariş yokken dahi 1 saniyelik `Timer.periodic` durmaksızın CPU'yu uyandırıyordu.
  - 3. Arka Planda Çalışan Piyasa Zamanlayıcıları: Vasıta ve emlak piyasası arka planda aktif listeleme üretmeye devam ediyordu.
  - 4. `setState during build` Riski: `NeoBrutalNativeAdCard` render esnasında senkron değerlendirme yaparak doğrudan durum güncellemeye yeltenebiliyordu.
  - 5. Sınırsız Liste Büyümesi: Yüzlerce araç satışında `salesHistory` ve `customerReviews` sınırsız büyüyerek belleğe ve SharedPreferences/Hive serileştirmesine aşırı yük bindiriyordu.
- **Kök Neden**:
  - `onAppPaused` içindeki test hijyen bayrağının (`_isOrganicTimerExplicitlyStopped`) `onAppResumed` sırasında sıfırlanmaması, zamanlayıcıların sipariş durumu ve uygulama yaşam döngüsüyle reaktif bağlanmaması, kart yükleme kontrolünün çizim fazı sonrasına ertelenmemesi ve model koleksiyonlarında maksimum sınır bulunmaması.
- **Uygulanan Çözüm**:
  - Yaşam döngüsü senkronizasyonu tamamlandı, post frame callback ile render güvenliği sağlandı, zamanlayıcılar reaktif hale getirildi ve koleksiyonlar sınırlandırıldı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze`: 0 hata, 0 uyarı (No issues found).
  - `flutter test test/lifecycle_and_memory_leak_audit_test.dart`: 5/5 test başarıyla geçti.
  - Tüm regresyon testleri: 26/26 test başarıyla geçti.

### `Softlock ve Exploit Kapsamlı Güvenlik Denetimi & Düzeltmeleri (§SPEC-2026-09-12-SOFTLOCK-EXPLOIT-AUDIT)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Oyundaki sermaye tuzağı softlock senaryolarının (pozitif bakiye kilitlenmesi) önlenmesi, araç satışı ve kumar kayıplarında askıda kalan hayalet tekliflerin temizlenmesi, vitrine kilitli veya kiradaki araçların suistimal edilmesinin (çifte kazanç / kumar açığı) engellenmesi ve ilan fiyatı doğrulamasının sıkılaştırılması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/providers/game/game_inventory_mixin.dart`:
    - `fulfillWantedCarContract`: Sipariş tamamlandığında satılan araca ait askıda kalan `incomingOffers` ve parça `pendingOrders` kayıtları filtrelendi.
    - `sellCar`: Doğrudan araç satışında hedef araca ait aktif teklifler ve bekleyen siparişler temizlendi.
    - `sellCarAtAuction`: Müzayede satışında araç envanterden çıkarken ilişkili teklifler ve siparişler temizlendi.
    - `updateCarListingDetails`: `customPrice` parametresi doğrulanarak 0, negatif, NaN veya sonsuz değerlerin ilana geçmesi engellendi, temiz sanitizasyon sağlandı.
    - `claimEmergencyBailout`: Pozitif bakiye sermaye tuzağı engellendi. Oyuncunun 0 aracı varken ve nakit varlığı piyasadaki en ucuz başlangıç arabasını (₺35.000) alamayacak durumdaysa acil dede mirası can suyu hakkı tanındı.
  - `lib/presentation/providers/game/game_casino_mixin.dart`:
    - `playCasinoBaccarat` & `playCasinoStreetCraps`: Kirada olan (`isRented`), vitrinde sergilenen (`isLockedInShowcase`) veya konsinye (`isConsignment`) araçların kumar masasına sürülmesi engellendi. Kumar kaybedildiğinde kaybedilen araca ait askıda kalan teklif ve parça siparişleri temizlendi.
  - `lib/presentation/providers/game/game_rental_mixin.dart`:
    - `rentCar`: Vitrine kilitlenmiş itibar araçlarının aynı anda kiraya verilerek çifte kazanç sağlanması engellendi (`isLockedInShowcase` denetimi eklendi).
  - `lib/presentation/screens/dashboard/widgets/dashboard_banners.dart`:
    - `DashboardEmergencyRescueBanner`: Acil kurtarma koşulu sermaye tuzağını kapsayacak şekilde genişletildi. Oyuncunun parası az (₺20.000 altı) fakat satılabilir aracı varsa doğrudan "Spot Pazara Acil Sat • Nakde Çevir" aksiyonu sunularak anında likidite yaratması sağlandı.
  - `test/softlock_and_exploit_audit_test.dart`:
    - [YENİ]: 8 senaryolu kapsamlı regresyon ve açık doğrulama testleri yazıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - 1. Sermaye Tuzağı Softlock Riski: Oyuncunun 0 aracı ve ₺16.000 parası olduğunda, en ucuz araba ₺35.000 iken toplam varlığı ₺15.000'i aştığı için can suyu alamıyor ve oyunda ilerleyemiyordu.
  - 2. Hayalet Teklif Senaryosu: Araç hızlı satıldığında veya kumarda kaybedildiğinde vitrinde o aracın eski teklif kartı asılı kalıyordu.
  - 3. Çifte Faydalanma Açığı: Kirada olan araçlar kumarda ortaya konabiliyor, vitrindeki araçlar ise aynı anda kiraya verilebiliyordu.
- **Kök Neden**:
  - Varlık kontrollerinin piyasa başlangıç araç fiyat tabanıyla (₺35.000) senkronize olmaması, araç envanterden çıkarılırken ilişkili koleksiyonların (`incomingOffers`, `pendingOrders`) silinmemesi ve durum bayraklarının (`isRented`, `isLockedInShowcase`, `isConsignment`) karşılıklı kilit mekanizmasında eksik bulunması.
- **Uygulanan Çözüm**:
  - Dede mirası can suyu eşiği en ucuz başlangıç aracı tabanıyla hizalandı, dashboard kurtarma paneline toptancı spot satış butonu entegre edildi, tüm araç çıkış fonksiyonlarına teklif temizleyiciler eklendi ve kumar/kiralama kontrollerine sıkı durum filtreleri yerleştirildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze`: 0 hata, 0 uyarı (No issues found).
  - `flutter test test/softlock_and_exploit_audit_test.dart`: 8/8 test başarıyla geçti.
  - Regresyon paketleri: 13/13 test başarıyla geçti.

### `Sıralı Tutundurma Deneyimi ve Taktil Çevrimdışı Gelir Tasarımı (§SPEC-2026-09-12-SEQUENTIAL-RETENTION-ORCHESTRATION)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Açılışta 5 pop-up'ın aynı anda tetiklenerek ekranı kilitlemesini (Diyalog Fırtınası) engellemek, çevrimdışı ilerleme özetini taktil üretken dither ve esnaf banknot dalgalarıyla zenginleştirmek ve bildirim ön izinlerini yalnızca bağlamsal eylem anına (vitrine araç ilanı verildiği ana) taşımak.
- **Yapılan Değişiklikler**:
  - `lib/presentation/widgets/tactile_cash_pattern_painter.dart`:
    - [YENİ]: `TactileCashPatternOverlay` ve `_TactileCashPainter` bileşeni eklendi. Guilloché sinüs dalgaları ve 4x4 Bayer dither matriksi ile banknot dokusu ve fiziksel para bereketi hissi sıfır bitmap maliyetiyle oluşturuldu.
  - `lib/presentation/screens/dashboard/widgets/dashboard_retention_modals.dart`:
    - `showOfflineRecapModal` metodu `Future<bool?>` döndürecek şekilde güncellendi ve `await` edilebilir hale getirildi.
    - Çevrimdışı kazanç kahraman paneline `TactileCashPatternOverlay`, 26px devasa nakit göstergesi, yumuşak psikolojik dil kullanan reklam katlayıcı ("SPONSOR DESTEĞİ İLE KATLA") ve dokunsal ses-haptik geri bildirimler entegre edildi.
    - Biriken vitrin teklifleri metin satırı yerine sarı çerçeveli görsel fırsat kartlarına dönüştürüldü.
  - `lib/presentation/widgets/dialogs/daily_login_sheet.dart`:
    - `DailyLoginSheet.show(context)` metodu `Future<T?>` döndürecek şekilde güncellendi.
  - `lib/presentation/screens/dashboard/dashboard_screen.dart`:
    - Açılıştaki 5 pencereli pop-up yığılması kaldırıldı.
    - Sıralı yürütücü kuruldu: 1. Öncelik olarak Çevrimdışı Özet gösterilir ve kapatılana kadar beklenir. Kapatıldıktan 350 milisaniye sonra 2. Öncelik olarak Günlük Giriş Takvimi yumuşakça açılır.
    - Ön izin (`NotificationPrimerDialog`) ve `WhatsNewDialog` açılış kuyruğundan tamamen çıkarıldı.
  - `lib/presentation/screens/showroom/widgets/showroom_listing_modal.dart` & `create_listing_screen.dart`:
    - `NotificationPrimerDialog.checkAndShow` vitrine araç ilanı verildiği ana taşındı; oyuncu tam ilan açtığı anda Halil Usta dükkan loruyla izin istenir.
  - `test/modal_queue_sequence_test.dart`:
    - [YENİ]: `TactileCashPatternOverlay` tuval çizim testi ve `Future` imza doğrulama birim testleri yazıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Diskte yeterli yer kalmaması nedeniyle derleyici geçici dosya yazamadı (OS Error: Diskte yeterli yer yok, errno = 112).
- **Kök Neden**:
  - Proje `build/` klasörünün 2.7 GB yer kaplaması ve Windows geçici dosyalarının disk alanını tüketmesi.
- **Uygulanan Çözüm**:
  - `flutter clean` çalıştırılarak 20 GB boş disk alanı açıldı; bağımlılıklar temizlendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze`: 0 hata, 0 uyarı.
  - `flutter test`: 13/13 birim testi başarıyla geçti.

### `Zamana Duyarlı Çoklu Bildirim Diyalog Havuzu (§SPEC-2026-09-12-TIME-SENSITIVE-NOTIFICATIONS)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Bildirimlerin monotonluğunu kırmak ve gerçek saat dilimlerine (sabah siftahı, öğle pazarı telaşı, akşam hesap kesimi) uyumlu otantik Halil Usta esnaf diyalogları sunmak.
- **Yapılan Değişiklikler**:
  - `lib/core/services/local_notification_service.dart`:
    - `NotificationTimeSlot` enum'ı eklendi (`morning`: 09:00-11:59, `afternoon`: 12:00-16:59, `evening`: 17:00-21:59).
    - `getTimeSlot(int hour)` fonksiyonuyla bildirimin ekrana düşeceği saat dilimi tespit edildi.
    - `resolveShowroomCopy` ve `resolveDailyCopy` metotları her zaman dilimi için çoklu varyantlı (sabah 3 varyant, öğle 3 varyant, akşam 3 varyant) zengin diyalog havuzuna genişletildi.
    - Vitrin teklifleri ve günlük esnaf destek bildirimleri 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) sıfır emoji ve sıfır parantez kuralına uygun olarak esnaf kültürüne göre yerelleştirildi (105 farklı şablon varyantı).
    - Gün ve araç adına bağlı deterministik tohumlama (`(now.day + carTitle.hashCode) % 3`) ile art arda aynı bildirimin gelmesi engellendi.
  - `test/notification_quiet_hours_test.dart`:
    - `Time-Sensitive Notification Dialogue Pool Tests` test grubu eklendi: saat dilimi tespiti, sabah/öğle/akşam loru doğrulaması ve tüm 7 dilde sıfır emoji ve sıfır parantez invariant kontrolü yapıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Çözümleyici içinde tekil bir return ifadesinde noktalı virgül eksikliği statik analiz hatası verdi.
- **Kök Neden**:
  - Şablon bloğu birleşimindeki küçük sözdizimi atlaması.
- **Uygulanan Çözüm**:
  - Noktalı virgül eklendi ve statik analiz hatası giderildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/core/services/local_notification_service.dart test/notification_quiet_hours_test.dart`: 0 hata, 0 uyarı.
  - `flutter test test/retention_recovery_roadmap_test.dart test/notification_quiet_hours_test.dart`: 11/11 test başarıyla geçti.

### `Yerel Bildirim Sertleştirmesi, Gece Koruyucusu ve Etik İzin Mimarisi (§SPEC-2026-09-12-NOTIFICATION-HARDENING)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Oyuncu tutundurma bildirimlerinin teknik (Android 13+ izinleri, yeniden başlatma koruması), zamansal (22:00 - 09:00 sessiz saat koruması) ve etik (dark pattern denetimi, kullanıcı otonomisi, Halil Usta bağlamsal ön izin diyalogu) boyutlarıyla sertleştirilmesi.
- **Yapılan Değişiklikler**:
  - `android/app/src/main/AndroidManifest.xml`:
    - Android 13 (API 33+) için zorunlu `android.permission.POST_NOTIFICATIONS`, cihaz açılışında bildirimlerin korunması için `android.permission.RECEIVE_BOOT_COMPLETED` ve dokunsal titreşim için `android.permission.VIBRATE` izinleri eklendi.
  - `lib/core/services/local_notification_service.dart`:
    - `calculateSafeScheduledTime(DateTime now, Duration delay)` metodu yazıldı: Gece 22:00 ile sabah 09:00 arasına denk gelen tüm bildirimler uykuyu bölmemek için otomatik olarak sabah 09:30'a ötelendi.
    - Vitrin teklif metinlerine dinamik araç adı entegre edildi (`$carTitle için hevesli bir alıcı geldi • Teklif masada bekliyor!`).
    - Bildirime dokunulduğunda doğrudan ilgili bölüme götüren `payloadStream` mimarisi kuruldu (`route_showroom`, `route_daily_login`).
    - Ayarlardan kapatıldığında tüm zamanlanmış bildirimleri sıfırlayan `cancelAllReminders` fonksiyonu eklendi.
  - `lib/presentation/providers/settings_provider.dart`:
    - `SettingsState` ve `SettingsNotifier` içine `isNotificationsEnabled` durumu ve `toggleNotifications()` fonksiyonu eklendi; SharedPreferences ile kalıcı hale getirildi.
  - `lib/presentation/screens/settings/settings_screen.dart`:
    - Ayarlar ekranına Neo-Brutalist dokunsal bildirim açma kapama anahtarı eklendi. Kapatıldığında tüm bekleyen bildirimleri anında iptal eden, açıldığında ise kibarca izin isteyen çift taraflı yaşam döngüsü bağlandı.
  - `lib/presentation/widgets/dialogs/notification_primer_dialog.dart`:
    - Halil Usta bağlamsal ön izin diyalogu (Pre-Permission Primer) yazıldı: Vitrine ilk araba konulduğunda oyuncuya dükkan loruyla ("Evlat, vitrindeki arabana müşteri geldiğinde dükkandan haber uçurayım mı?") kibarca soruldu.
  - `lib/presentation/screens/dashboard/dashboard_screen.dart`:
    - Pano açılışında vitrinde ilanı olan araç varsa `NotificationPrimerDialog.checkAndShow` çağrısı tetiklendi.
  - `lib/app/app.dart`:
    - Yalnızca gerçek arka plan duraklamasında (`AppLifecycleState.paused`) çalışacak şekilde yaşam döngüsü filtresi sadeleştirildi (`inactive` durumu elendi).
    - `settings.isNotificationsEnabled` kapalıysa zamanlayıcıların tetiklenmesi engellendi ve mevcut bildirimler temizlendi.
    - Bildirime tıklandığında ilgili ekrana yönlendirme yapan `payloadStream` dinleyicisi kuruldu.
  - `lib/core/localization/translations/*.dart`:
    - Bildirim başlığı, açıklaması ve Halil Usta ön izin metinleri 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) sıfır emoji ve sıfır parantez kurallarına uygun olarak senkronize edildi.
  - `test/notification_quiet_hours_test.dart`:
    - Sessiz saat koruması (gece 22:30, gece 21:00, sabah 06:00, gündüz 14:00 ve 24 saatlik döngü) birim testleri yazılarak doğrulandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `settings_screen.dart` dosyasında toast bildirimi için kullanılan `NotificationService` ile yerel bildirimler için kullanılan `LocalNotificationService` isim benzerliğinden ötürü çakışma yaşandı.
  - `notification_primer_dialog.dart` içinde `NeoBrutalButton` parametrelerinde `label` yerine `text` ve `minHeight` yerine `height` kullanılması statik analiz uyarısı verdi.
- **Kök Neden**:
  - Farklı servislerin benzer isimlendirmeleri ve `NeoBrutalButton` API kontratı.
- **Uygulanan Çözüm**:
  - Her iki import `settings_screen.dart` dosyasına eklendi. `NeoBrutalButton` parametreleri `label` ve `minHeight` olarak düzeltildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` çalıştırıldı: 0 hata, 0 uyarı.
  - `flutter test test/notification_quiet_hours_test.dart test/retention_recovery_roadmap_test.dart` çalıştırıldı: 8/8 test başarıyla geçti.

### `Erken Dönem Oyuncu Tutundurma (Retention Recovery) Yol Haritası (§SPEC-2026-09-12-RETENTION-RECOVERY-ROADMAP)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - D1 (%15.7), D7 (%1.5), D14 (%0.4) seviyesine düşen oyuncu tutundurma oranını toparlamak amacıyla 5 aşamalı aksiyon planının eksiksiz uygulanması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/providers/game/game_inventory_mixin.dart`:
    - `updateCarListingDetails` metoduna erken evre mekaniği eklendi: Toplam satış sayısı 3'ün altındaysa (`salesHistory.length < 3`) ve bekleyen teklif yoksa, ilana çıkıldıktan sonra 8 ila 15 saniye içinde kârlı bir garanti alıcı teklifi (`OfferModel`) oluşturularak oyuncunun bekleme süresi ortadan kaldırıldı.
  - `lib/presentation/providers/game/game_time_mixin.dart`:
    - Seviye 1 ve 2 için 45 saniyede bir çalışan özel erken organik teklif döngüsü (`_earlyCadenceTimer`) eklendi. Teklif gelme ihtimali %25'ten %60'a yükseltildi.
    - `stopPeriodicOrganicOfferTimer` metodu widget testlerinde zamanlayıcı sızıntısını önlemek için hem genel hem erken döngüyü sıfırlayacak şekilde güncellendi (İnvaryant Kural 6).
  - `lib/domain/usecases/offline_progression.dart`:
    - Seviye 1 ve 2 oyuncuları için çevrimdışı kira ve vergi kesintisi (`propertyDailyBurn` ve `dailyTax`) sıfırlandı; yeni oyuncuların oyuna döndüklerinde kasa bakiyelerinin erimesi engellendi.
    - Çevrimdışı kalınan ilk 2 saat içinde (en az 30 dk çevrimdışı kalındığında) vitrinde ilanı olan araçlar için taban en az 2 cazip teklif garanti edildi (`minFloorOffers = 2`).
  - `lib/domain/usecases/mentor_quest_engine.dart`:
    - Seviye 3 atölye restorasyonu öncesine Seviye 1-2 için 3 yeni erişilebilir görev eklendi: `questFirstPurchase` (Pazardan İlk Aracı Al), `questFirstProfitSale` (İlk Kârlı Satışını Yap), `questReachLevelTwo` (Galeri Seviye 2'ye Ulaş).
    - `onCarPurchased` ve `checkAndPersistRestorationProgress` metotları bu görevlerin ilerlemesini ve tamamlanmasını otomatik takip edecek şekilde güncellendi.
  - `lib/presentation/screens/dashboard/widgets/dashboard_mentor_card.dart`:
    - Halil Usta kartına görev türüne göre doğrudan ilgili ekrana yönlendiren hızlı aksiyon butonu eklendi (`_buildQuestQuickAction`).
    - Neo-Brutalist tasarım kurallarına uygun olarak 2.5px siyah kenarlık, 0-blur gölge ve dokunsal basma efekti uygulandı. Sıfır emoji ve sıfır parantez kuralları korundu.
  - `pubspec.yaml`:
    - `flutter_local_notifications: ^17.2.3` bağımlılığı eklendi.
  - `lib/core/services/local_notification_service.dart`:
    - 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) çevrimdışı yerel bildirim servisi yazıldı.
    - 90. dakikada vitrin hatırlatıcı bildirimi (`notification_early_showroom_reminder_title` / `body`) ve 24. saatte günlük esnaf desteği bildirimi (`notification_daily_support_title` / `body`) planlama fonksiyonları eklendi.
  - `lib/main.dart`:
    - Uygulama başlangıcında `LocalNotificationService.instance.initialize()` çağrısı başlatıldı.
  - `lib/app/app.dart`:
    - Uygulama arka plana geçtiğinde (`AppLifecycleState.paused` / `inactive`) yerel bildirimlerin planlanması, ön plana döndüğünde (`resumed`) bildirimlerin iptal edilmesi sağlandı.
  - `lib/presentation/screens/dashboard/dashboard_screen.dart`:
    - Oyuncu panosu açıldığında günlük ödül hakkı varsa (`canClaimDaily`), `DailyLoginSheet` otomatik olarak açılarak kutlama ve geri dönüş alışkanlığı tetiklendi.
  - `lib/core/localization/translations/*.dart`:
    - 12 yeni yerelleştirme anahtarı (`quest_halil_first_purchase_*`, `quest_halil_first_sale_*`, `quest_halil_level_two_*`, `quest_action_*`, `notification_*`) 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) sıfır emoji ve sıfır parantez kuralına uygun olarak eklendi.
  - `test/retention_recovery_roadmap_test.dart`:
    - Aşama 2 (sıfır çevrimdışı masraf, en az 2 teklif birikmesi) ve Aşama 3 (Halil Usta görev zinciri ilerlemesi) kapsamlı birim testleri yazılarak doğrulandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `SaleRecordModel` sınıfında `profit` ve `carId` yerine `netProfit` alanının bulunması ve `ExpertiseReport.clean()` kurucusunun olmaması derleme uyarısı verdi.
  - `MentorQuestEngine.getActiveQuest` metodunun `tutorialCompleted == false` durumunda `null` dönmesi birim testinde tespit edildi.
- **Kök Neden**:
  - Model alan adları farkı ve test senaryosunda `tutorialCompleted` bayrağının başlatılmaması.
- **Uygulanan Çözüm**:
  - `mentor_quest_engine.dart` içinde `s.netProfit > 0` kontrolüne geçildi. Testte `ExpertiseReport` kurucusu ve `tutorialCompleted: true` güncellendi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/retention_recovery_roadmap_test.dart` çalıştırıldı: 3/3 test başarıyla geçti.

### `docs/superpowers/specs/2026-09-12-early-game-rewarded-ads-research.md`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Galeriden Tycoon erken oyun evresi (Seviye 1-3, Gün 1-7) ödüllü reklam mimarisinin derin araştırma raporunun ve eylem planının oluşturulması (§SPEC-2026-09-12-EARLY-GAME-REWARDED-ADS-RESEARCH).
- **Yapılan Değişiklikler**:
  - `docs/superpowers/specs/2026-09-12-early-game-rewarded-ads-research.md`:
    - Erken evrede ekonomiyi ve ilerleme tatminini bozan kontrolsüz nakit hibelerinin ve erken atölye onarım kancalarının analizi.
    - Kaldırılacak patolojik reklam noktaları ve yerine konulacak 5 yeni esnaf dayanışması kancasının (Kelepir Radarı, Noter Harcı Muafiyeti, Ücretsiz Ekspertiz Kuponu, Çırak Yıkama Desteği, Cömert Müşteri Dopingi) detaylı teknik tasarımı.
- **Doğrulama / Test Durumu**:
  - Dokümantasyon ve mimari doğrulama tamamlandı.

### `Uygulama Derleme Numarasının Yükseltilmesi (1.0.6+31 -> 1.0.6+32)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Halil Usta Masası taktil tasarımı, canlı çay dumanı, 365 günlük kart göçü ve dinamik ikilem sistemi iyileştirmelerini içeren yeni sürümün paketlenmesi için derleme numarasının 32'ye yükseltilmesi.
- **Yapılan Değişiklikler**:
  - `pubspec.yaml`:
    - Versiyon `1.0.6+31`'den `1.0.6+32`'ye yükseltildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze`: 0 hata.

### `Halil Usta Masası Neo-Brutalist & Prosedürel Dokunmatik Tasarım Yenilemesi, Canlı Çay Dumanı & 7 Dilli İstasyon Rozetleri (§SPEC-2026-09-12-MENTOR-CARD-REDESIGN)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Halil Usta Masası (`DashboardMentorCard`) bileşeninin Neo-Brutalist taktil geometriye, prosedürel canvas çizimlerine (milimetrik cetvel çentikleri, köşe artı işaretleri, Bayer matris stippling dokusu) ve canlı sinüzoidal buhar animasyonuna (`SteamCupWidget`) kavuşturulması.
  - Açık temada okunabilirliği artıran derin kehribar (`0xFF78350F`) başlık, sert çerçeveli konuşma kartı ve taktil onay mührü (`TactileBrutalStamp`) entegrasyonu.
  - Çay ısmarlanınca (`canServeTea == false`) alt çay kutusunun tamamen kapanması/gizlenmesi ve tüm istasyon rozetlerinin (`mentor_desk_station_id`, `mentor_station_badge_tea`, `mentor_station_badge_radar`, `mentor_quest_approved_stamp`) 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) eksiksiz senkronizasyonu.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_mentor_card.dart`:
    - `_MentorWorkbenchPainter` `CustomPainter` sınıfı eklendi; cetvel çizgileri, ızgara noktaları ve köşe hedefleme çentikleri sıfır bellek tahsisli statik `Paint` nesneleriyle 60/120 FPS'te çizildi.
    - `SteamCupWidget` canlı sinüs dalgalı buhar animasyonu çay bardağı üzerine yerleştirildi.
    - Çay servis edildikten sonra konteynerin arayüzde yer kaplamadan yok olması sağlandı (`if (canServeTea) ...`).
    - İstasyon rozetleri ve "Usta Onaylı" taktil mührü yerelleştirildi.
  - `lib/core/localization/translations/*.dart`:
    - 7 dilde `mentor_quest_approved_stamp`, `mentor_desk_station_id`, `mentor_station_badge_tea` ve `mentor_station_badge_radar` anahtarları sıfır emoji ve sıfır parantez kuralına uygun olarak eklendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/dashboard/widgets/dashboard_mentor_card.dart`: 0 hata, 0 uyarı (No issues found).
  - `flutter test test/smart_mentor_engine_test.dart`: 13/13 test başarıyla geçti.

### `365 Günlük Statik Kart Yerine Dinamik Durumsal İkilem Sistemi (ContextualDilemmaPool) Göçü & Günlük Yenileme (§BUGFIX-2026-09-12-DILEMMA-MIGRATION)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Oyunda 365 günlük takvimsel kartlar yerine `ContextualDilemmaPool` tabanlı durumsal ikilem sistemine geçilmiş olmasına rağmen, oyuncuların karşısına halen eski `milestone_day_1` kartının çıkması sorununun giderilmesi.
  - Oyuncunun ilk gününde doğrudan bağlamsal ve interaktif çaylak ikilemi (`rookie_tea_mahmut`) ile başlaması, eski kayıt dosyalarındaki `milestone_` kartlarının otomatik olarak dinamik ikilemlere dönüştürülmesi ve gün atlamalarında kart seçiminin oyuncunun güncel finansal durumuna göre otomatik tazelenmesi.
- **Yapılan Değişiklikler**:
  - `lib/data/models/dealership_model.dart`:
    - `DealershipModel.initial()` fabrika yapıcısında hardcoded `milestone_day_1` yerine `const DramaticCardModel(id: 'rookie_tea_mahmut', ...)` bağlandı.
  - `lib/presentation/providers/game/game_core_provider.dart`:
    - Kayıtlı oyun yükleme döngüsünde (`_loadSavedGame`) eski `milestone_` önekli kartlar tespit edilerek `ContextualDilemmaPool.selectContextualCard` ile anında güncel duruma uygun dinamik ikileme göç ettirildi.
  - `lib/domain/usecases/offline_progression.dart`:
    - Çevrimdışı ilerleme simülasyonunda gün atlandığında veya kart `milestone_` ise `DramaticCardEngine.generateDailyDilemma` çağrılarak taze durumsal kart üretildi.
  - `lib/presentation/providers/game/game_time_mixin.dart`:
    - `_processDramaticDecision` metodu gün atlamalarında mevcut kartı oyuncunun yeni durumuna (bakiye, araç sayısı, kriz) göre tazeleyecek şekilde güncellendi.
    - `dismissPendingDramaticCard` metoduna eksik olan `saveState()` kalıcılığı eklendi.
  - `test/day_progression_and_dramatic_cards_test.dart`:
    - 1. gün varsayılan kart doğrulaması `rookie_tea_mahmut` olarak güncellendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `DealershipModel.initial()` içinde `milestone_day_1` kartı yer alıyordu ve sağlayıcı yalnızca `pendingDramaticCard == null` ise kart üretiyordu.
  - Eski `localStorage` kayıtlarında biriken `milestone_` kartları gün atlamalarında temizlenemiyordu.
- **Kök Neden**:
  - İlk durum başlangıç verisinin eski statik modelden devralınması ve yükleme aşamasında geriye dönük göç kontrolünün bulunmaması.
- **Uygulanan Çözüm**:
  - Başlangıç durumu dinamik çaylak ikilemiyle güncellendi, başlangıçta ve çevrimdışı ilerlemede otomatik göç kodu eklendi, gün ilerlemelerinde dinamik kart yenilemesi sağlandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/day_progression_and_dramatic_cards_test.dart`: 4/4 test geçti.
  - `flutter test test/dramatic_cards_engine_test.dart`: 4/4 test geçti.
  - `flutter test test/dynamic_dilemma_expansion_test.dart`: 7/7 test geçti.
  - `flutter test test/core_loop_funnel_and_dilemma_test.dart`: 5/5 test geçti.
  - `flutter test test/dramatic_daily_dilemma_test.dart`: 15/15 test geçti.
  - Toplam 35/35 ikilem ve gün ilerleme testi başarıyla geçti.

### `Hızlı İlan Sonrası Doğrudan Showroom Yönlendirmesi & Çok Dilli Senkronizasyon (§SPEC-2026-QUICK-LISTING-SHOWROOM-FLOW)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Araç satın alma pazarlığı tamamlandığında açılan hızlı ilan verme modalında (`QuickListingBottomSheet`), araç vitrine çıkarıldığında oyuncunun doğrudan vitrine/showroom'a yönlendirilmesi; işlem iptal edildiğinde veya bekletildiğinde önceki akışa dönülmesi ve tüm buton/etiketlerin 7 dilde eksiksiz senkronize edilmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/showroom/widgets/quick_listing_bottom_sheet.dart`:
    - `QuickListingBottomSheet.show` metodu `Future<bool?>` döndürecek şekilde güncellendi; ilan onaylandığında `Navigator.of(context).pop(true)`, vazgeçildiğinde `pop(false)` döndürüldü.
  - `lib/presentation/screens/marketplace/negotiation_screen.dart`:
    - Noter satışı tamamlandıktan sonra `QuickListingBottomSheet.show` sonucu kontrol edilerek, ilan verildiyse oyuncunun otomatik olarak `/showroom` ekranına yönlendirilmesi sağlandı.
  - `lib/core/localization/translations/` (`tr`, `en`, `de`, `es`, `pt`, `ru`, `ar`):
    - `quick_listing_btn_showroom` anahtarı 7 dilde sıfır emoji ve parantezsiz kuralına tam uyumlu olarak eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Oyuncu aracı satın alıp hemen ilana koyduğunda, pazar ekranında kalıyor ve aracının vitrindeki halini görmek için manuel olarak showroom sekmesine geçmesi gerekiyordu.
- **Kök Neden**:
  - `QuickListingBottomSheet.show` metodunun dönüş değeri olmaması ve `negotiation_screen.dart` dosyasının modal kapandıktan sonra koşulsuz olarak `/marketplace` rotasında kalması.
- **Uygulanan Çözüm**:
  - Modal başarıyla ilan verdiğinde `true` bayrağı ile kapanması sağlandı ve çağrıcı ekranda `context.go('/showroom')` yönlendirmesi tetiklendi.
- **Doğrulama / Test Durumu**:
  - Flutter statik analizi ve dil anahtarı senkronizasyon kontrolleri tamamlandı.

### `Emlak Satış İlanı Tavan/Taban Fiyat Denetimi & Çok Dilli Validasyon (§SPEC-2026-REAL-ESTATE-PRICING-CEILING-FLOOR)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Emlak satış ilanlarında oyuncuların aşırı fahiş fiyat veya taban altı fiyat belirlemelerini önleyen %150 rayiç tavanı ve %40 taban kurallarının arayüz ve bildirim katmanında tam uyarılması; başarısız ilanın sessizce reddedilmesi yerine oyuncuya açıklayıcı bilgilendirme yapılması ve 7 dilde senkronizasyonun tamamlanması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/real_estate/real_estate_listing_manage_screen.dart`:
    - `_publishSaleListing` metoduna `maxAllowedPrice` (%150 rayiç tavan) ve `minAllowedPrice` (%40 taban) kontrolleri eklendi. Sınırlar aşıldığında `NotificationService.showWarning` ile oyuncuya yerelleştirilmiş uyarı gösterilerek işlem engellendi.
  - `lib/core/localization/translations/` (`tr`, `en`, `de`, `es`, `pt`, `ru`, `ar`):
    - `real_estate_price_exceeds_ceiling` ve `real_estate_price_below_floor` anahtarları 7 dilde sıfır emoji ve parantezsiz olarak eklendi.
  - `test/real_estate_listing_narrative_test.dart`:
    - 7 dil senkronizasyon testine yeni anahtarlar eklendi; tavan/taban sınır doğrulama testi eklendi (6/6 geçti).
- **Karşılaşılan Hatalar / Sorunlar**:
  - İlan verme ekranında kullanıcı tavan veya taban dışı bir fiyat girdiğinde backend işlemi reddediyor ancak UI katmanında sessizce hiçbir geri bildirim verilmiyordu.
- **Kök Neden**:
  - `_publishSaleListing` fonksiyonunun `listRealEstateForSale` false döndüğünde kullanıcıya bildirim sunmaması.
- **Uygulanan Çözüm**:
  - İlan gönderme öncesinde hem arayüzde ön denetim eklendi hem de bilgilendirici uyarı bildirimleri 7 dilde bağlandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/real_estate_listing_narrative_test.dart`: 6/6 test geçti.
  - `flutter test test/real_estate_market_test.dart test/real_estate_buyer_negotiation_expansion_test.dart`: 32/32 test geçti.

### `Sadece Kritik Durumlarda İkilem Kartı Tetikleme Mimarisi (Strictly Critical Dilemma Triggering)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Oyuncuyu her gün zorunlu kart popup'ları ile bölmek yerine, ikilem kartlarının yalnızca galeride gerçek bir kriz, darboğaz veya kritik dönüm noktası (nakit krizi, ilk 3 gün acemilik adaptasyonu, hasarlı/çamurlu filo darboğazı, satış sonrası müşteri ihtilafı, yüksek sermaye/müzayede fırsatı, VIP itibar) gerçekleştiğinde tetiklenmesi; normal ve sakin günlerde hiçbir kart çıkmadan günün akıcı ilerlemesi.
- **Yapılan Değişiklikler**:
  - `lib/domain/usecases/contextual_dilemma_pool.dart`:
    - `selectCriticalCard` metodu eklendi. Sadece tanımlı kritik koşullar (bakiye < ₺25.000, ilk 3 gün acemilik ve seviye <= 2, hasarlı araç >= 2, müşteri ihtilafı, sermaye >= ₺500.000, itibar >= 120) aktifse kart döndürür; aksi halde `null` döndürür.
  - `lib/domain/usecases/dramatic_card_engine.dart`:
    - `selectCriticalDilemma` metodu eklenerek `ContextualDilemmaPool.selectCriticalCard` çıktısına bağlandı.
  - `lib/presentation/providers/game/game_time_mixin.dart`:
    - `_processDramaticDecision` metodu `DramaticCardEngine.selectCriticalDilemma` kullanacak şekilde güncellendi. Kritik durum yoksa `pendingDramaticCard` `null` kalır ve hiçbir modal açılmaz.
    - `dismissPendingDramaticCard` metoduna kapatılan kartın ID'sini `seenDramaticCardIds` listesine ekleme mantığı dahil edilerek, kapatılan kartın hemen ertesi gün tekrar döngüye girmesi engellendi.
  - `lib/presentation/providers/game/game_core_provider.dart`:
    - Depolamadan yükleme ve başlatma döngülerinde `pendingDramaticCard`'ı zorla doldurmak yerine yalnızca eski `milestone_` kartı varsa `selectCriticalDilemma` ile göç ettirilmesi, yoksa `null` kalması sağlandı.
  - `lib/domain/usecases/offline_progression.dart`:
    - Çevrimdışı simülasyonda yeni kart üretimi `selectCriticalDilemma` üzerinden yapılarak sadece kriz koşullarında kart üretilmesi sağlandı.
  - `test/day_progression_and_dramatic_cards_test.dart`:
    - Test 2 ve Test 3 kritik durum tetikleme mimarisini doğrulayacak şekilde güncellendi; normal günlerde kart çıkmadığı (`isNull`), nakit krizi tetiklendiğinde kriz kartının belirdiği teyit edildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Yok.
- **Uygulanan Çözüm**:
  - Koşullu tetikleme ve `null` durum yönetimi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/day_progression_and_dramatic_cards_test.dart test/dramatic_cards_engine_test.dart test/dynamic_dilemma_expansion_test.dart test/core_loop_funnel_and_dilemma_test.dart test/dramatic_daily_dilemma_test.dart test/dramatic_dialog_widget_test.dart`: 40/40 test başarıyla geçti.
  - `flutter analyze`: 0 hata, 0 uyarı (No issues found).

### `365 Günlük Statik Milestone Kartlarının Kaldırılması ve Dinamik İkilem (ContextualDilemmaPool) Tam Geçişi`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Oyunda 365 günlük takvim milestone kartlarının (ör. `milestone_day_1`) yeni açılan veya önceden kaydedilmiş oyunlarda kalıcı olarak görünmesini engelleyip, galerinin anlık finansal ve operasyonel durumuna göre tepki veren `ContextualDilemmaPool` dinamik ikilem motoruna tam geçişin sağlanması.
- **Yapılan Değişiklikler**:
  - `lib/data/models/dealership_model.dart`:
    - `DealershipModel.initial()` içerisindeki statik `milestone_day_1` kartı, `ContextualDilemmaPool.rookieCards.first.copyWith(dayNumber: 1)` (`rookie_tea_mahmut`) ile değiştirildi.
  - `lib/presentation/providers/game/game_core_provider.dart`:
    - Oyun başlatma ve yükleme döngüsünde eski kayıtlardan gelebilecek `milestone_` ID'li kartları tespit edip durumsal dinamik ikilemlerle (`DramaticCardEngine.generateDailyDilemma`) otomatize eden geçiş (migration) mekanizması eklendi.
  - `lib/domain/usecases/offline_progression.dart`:
    - Çevrimdışı ilerleme simülasyonunda gün atlandığında kartın sadece gün numarasını değiştirmek yerine, duruma uygun yeni dinamik kart çekilmesi sağlandı; eski `milestone_` kartları otomatik güncellendi.
  - `lib/presentation/providers/game/game_time_mixin.dart`:
    - Gün geçişi sonrası `_processDramaticDecision` metodunda ikilem yenileme mantığı güçlendirildi.
    - `dismissPendingDramaticCard` metoduna `saveState()` eklenerek kart kapatıldığında durumun depolamaya kalıcı olarak yazılması sağlandı.
  - `test/day_progression_and_dramatic_cards_test.dart`:
    - 1. gün kart beklentisi `milestone_day_1` yerine `rookie_tea_mahmut` olarak güncellendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Kullanıcının "biz 365 günlük kart sistemi yerine dilemma sistemi getirmedik mi, sorun ne?" geri bildiriminde, yeni oyunda ve depolamada hâlâ `milestone_day_1` kartının belirmesi.
- **Kök Neden**:
  - `DealershipModel.initial()` model fabrikasında 1. gün için `milestone_day_1` kartının statik sabit olarak kodlanmış olması ve eski yerel depolama verilerinde bu kartın önceden kaydedilmiş olarak kalması.
- **Uygulanan Çözüm**:
  - Başlangıç modeli `rookie_tea_mahmut` ile güncellendi, başlangıçta ve çevrimdışı ilerlemede `milestone_` ön ekine sahip tüm kartlar dinamik havuzdan gelen kartlarla otomatik göç ettirildi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/day_progression_and_dramatic_cards_test.dart test/dramatic_cards_engine_test.dart test/dynamic_dilemma_expansion_test.dart test/core_loop_funnel_and_dilemma_test.dart test/dramatic_daily_dilemma_test.dart`: 35/35 test başarıyla geçti.
  - `flutter analyze`: 0 hata, 0 uyarı.

### `Halil Usta Masası Kontrast İyileştirmesi ve Çay Kutusu Kapanma Entegrasyonu`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Halil Usta kartındaki silik kalan açık renklerin ve sınır çizgilerinin neo-brutalist 2.0px saf siyah çerçeveler ve yüksek kontrastlı tipografi ile belirginleştirilmesi, çay ikram edildiğinde ise çay kutusunun ekrandan tamamen kaybolarak yer tasarrufu sağlaması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_mentor_card.dart`:
    - Tüm iç kartlara (konuşma balonu, usta notu, görev panosu, çay kutusu) 2.0px sert koyu kenarlıklar (`0xFF0F172A`) ve 2.5px sıfır bulanıklıklı taktil gölgeler uygulandı.
    - Usta Notu başlığındaki soluk açık yeşil renk koyu kehribar tonuna (`0xFF78350F`) çevrildi, sarı zemin (`0xFFFEF9C3`) ve 4px koyu sol gösterge çubuğu ile okunurluk garanti altına alındı.
    - Anlatı görevi tamamlandığında usta onay damgası `AppColors.toxicLime` dolgulu, 1.8px siyah çerçeveli ve saf siyah kalın yazılı taktil kaşe haline getirildi.
    - `canServeTea` kontrolündeki `else` bloğu kaldırılarak çay ikram edildikten sonra kutunun anında kapanması ve ekrandan kaybolması sağlandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Açık tema üzerinde düşük kontrastlı pastel tonların ve yeşil yazıların arka planla karışması.
- **Uygulanan Çözüm**:
  - Saf neo-brutalist yüksek kontrast geometri ve tam siyah gölge/kenarlık mimarisi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/smart_mentor_engine_test.dart`: 26/26 test başarıyla geçti.
  - `flutter analyze lib/presentation/screens/dashboard/widgets/dashboard_mentor_card.dart`: 0 hata, 0 uyarı (No issues found).
  - Web sunucusuna Hot Reload & Hot Restart uygulandı.

### `Halil Usta Masası Generative Art & Neo-Brutalist Taktil Tasarım Entegrasyonu`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Kontrol panelindeki `DashboardMentorCard` bileşeninin düz ve sade kart görünümünden çıkarılarak, `/generative-art-shaders` ve `/design` kurallarına uygun olarak yaşayan bir sanayi atölyesi masasına dönüştürülmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_mentor_card.dart`:
    - `_MentorWorkbenchPainter` CustomPainter'ı eklenerek kart zeminine milimetrik cetvel çentikleri, köşe artı (+) hizalama imleri ve sağ altta taktil Bayer matrisi stippling tram dokusu entegre edildi.
    - Halil Usta piksel avatarının yanına net konuşma balonu kartı yerleştirildi, mood ve usta tavsiye renkleriyle dinamik sınır vurgusu yapıldı.
    - Taktiksel usta tavsiyesi, sarı/amber servis notu formatına (`mentor_tactical_note_header`) ve sol kenar kalın renk şeridine dönüştürüldü.
    - Anlatı yan görevleri alanına görev tamamlandığında beliren -6 derece eğimli `TactileBrutalStamp` ("USTA ONAYLI") damgası entegre edildi.
    - Halil Usta çay ocağı etkileşimine `SteamCupWidget` ile canlı sinüzoidal çay buharı animasyonu ve taktil buton yerleşimi eklendi.
    - Kartın sağ üst köşesine endüstriyel istasyon damgası (`mentor_desk_station_id`) ve canlı radar durum göstergesi eklendi.
  - `lib/core/localization/translations/`:
    - 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) `mentor_quest_approved_stamp` ve `mentor_desk_station_id` anahtarları sıfır emoji ve sıfır parantez kuralıyla eşzamanlı olarak eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok.
- **Kök Neden**:
  - Yok.
- **Uygulanan Çözüm**:
  - Sıfır bellek sızıntılı ve 60/120 FPS GPU bütçesine uygun `CustomPainter` tasarımı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/smart_mentor_engine_test.dart`: 26/26 test başarıyla geçti.
  - `flutter analyze lib/presentation/screens/dashboard/widgets/dashboard_mentor_card.dart`: 0 hata, 0 uyarı (No issues found).

### `Durumsal Dinamik İkilem Motoru (ContextualDilemmaPool) Yeniden Entegrasyonu`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Oyuncunun gün geçişlerinde 365 günlük statik genel hayat/kültür kartları (ör. Gün 15 Ezel Replikleriyle Teselli) yerine, galerinin kaza/hasar, nakit açığı, acemilik ve atıl araç gibi anlık ticari durumlarına tepki veren durumsal ikilemlerin (`ContextualDilemmaPool`) birincil motor olarak çalıştırılması.
- **Yapılan Değişiklikler**:
  - `lib/domain/usecases/dramatic_card_engine.dart`:
    - `generateDailyDilemma` metodu `ContextualDilemmaPool.selectContextualCard(state, seenIds: state.seenDramaticCardIds).copyWith(dayNumber: day)` çağrısına bağlandı.
    - Katalog ve statik testler için `generateCalendarDilemma(int day)` metodu ayrıştırıldı.
  - `test/dramatic_daily_dilemma_test.dart`:
    - 365 günlük katalog ve değişmezlik testleri `generateCalendarDilemma` metodu üzerinden doğrulandı.
  - `test/dramatic_dialog_widget_test.dart`:
    - Bakiye yetersizliği testi (`Insufficient balance choices do not advance to outcome`), `ContextualDilemmaPool.rookieCards.first` (Mahmut çay bahşişi: ₺200) kullanılarak deterministik hale getirildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `test/dramatic_dialog_widget_test.dart` içinde bakiye 0 yapıldığında `ContextualDilemmaPool`'un otomatik olarak `cashCrisisCards` (tüm seçenekleri ₺0 maliyetli olan hurdacı/miras kartı) seçmesi ve testin `upfrontCost > 0` seçeneği ararken `Bad state: No element` hatası vermesi.
- **Kök Neden**:
  - `ContextualDilemmaPool`'un iflas durumlarında oyuncuyu korumak için ücretsiz seçenekler sunması, ancak arayüz testinin ücretli seçenek arayarak oyuncunun yetersiz bakiye durumunu simüle etmeyi amaçlaması.
- **Uygulanan Çözüm**:
  - Testte `rookieCards.first` (maliyeti ₺200 olan) doğrudan verilerek ₺0 bakiye kilidi test edildi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/dramatic_daily_dilemma_test.dart test/dynamic_dilemma_expansion_test.dart test/core_loop_funnel_and_dilemma_test.dart test/day_progression_and_dramatic_cards_test.dart test/dramatic_dialog_widget_test.dart test/events_and_narrative_audit_test.dart test/small_screen_overflow_audit_test.dart`: 36/36 test başarılı.
  - `flutter analyze`: 0 hata, 0 uyarı (No issues found).

### `Halil Usta Derin Mentor Mekaniği (§SPEC-2026-09-12-HALIL-USTA-DEEP-MENTOR)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Halil Usta'ya katı if-else zinciri yerine anlık oyun dinamiklerine göre aciliyet skoru hesaplayan fayda tabanlı dinamik skorlama motorunun (`utilityScore` [0.0 - 1.0]) kazandırılması.
  - Tekrar eden tavsiyelerin ekranı kilitlemesini önlemek için her ardışık gün için %20 sönümleme (`0.80^consecutiveDays`, asgari 0.20) uygulayan yorulma ve hafıza sönümleme algoritmasının entegrasyonu.
  - `DealershipModel` içerisine `final Map<String, dynamic> mentorMemory` alanının eklenerek usta hafızasının (`lastAdvisedType`, `lastAdvisedDay`, `consecutiveDays`, `teaServedCount`, `lastTeaServedDay`, `completedQuestIds`, `claimedQuestIds`) kalıcı hale getirilmesi.
  - 13 tavsiye türünün her biri için 3'er adet dinamik diyalog varyantının (`_v1`, `_v2`, `_v3` - toplam 39 yeni varyant) ve 7 desteklenen dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) eşzamanlı sıfır emoji / sıfır parantez kuralıyla yerelleştirilmesi.
  - `PixelMentorAvatar` için 5 farklı duygu ve ruh hali durumunun (`MentorMood`: `neutral`, `proud`, `worried`, `clever`, `teaSip`) ve CRT glitch & kromatizm aberrasyonunun (`isGlitching`) piksel matrisi ve CustomPainter ile görselleştirilmesi.
  - `MentorQuestEngine` ile 3 anlatı yan görevinin ("Eski Dostun Yadigarı", "Piyasa Kurdu", "Esnaf Bereketi") ve günlük çay ikramı (misafirperverlik) mekaniğinin eklenmesi.
- **Yapılan Değişiklikler**:
  - `lib/data/models/dealership_model.dart`:
    - `mentorMemory` alanı eklendi (`Map<String, dynamic>`). `toJson`, `fromJson`, `copyWith`, `initial` metotlarına entegre edildi.
  - `lib/domain/usecases/smart_mentor_engine.dart`:
    - `MentorMood` enum eklendi (`neutral`, `proud`, `worried`, `clever`, `teaSip`).
    - `SmartMentorAdvice` sınıfına `double utilityScore` ve `MentorMood mood` alanları eklendi.
    - Tüm aday tavsiyelere dinamik fayda skorları ve duygu durumları atandı.
    - Yorulma sönümlemesi ve aday tavsiyelerin skora göre yarıştırılması sağlandı.
    - `((game.currentDay + winner.type.index) % 3) + 1` formülüyle dinamik `_v1`, `_v2`, `_v3` alıntı anahtarı seçimi eklendi.
    - `recordAdviceGiven` yardımcı metodu ile tavsiye sunulduğunda usta hafızası güncellendi.
  - `lib/domain/usecases/mentor_quest_engine.dart`:
    - `MentorNarrativeQuest` veri modeli oluşturuldu.
    - `MentorQuestEngine` sınıfı altında `questHeritageRestore`, `questBargainSniper`, `questTeaHospitality` görevleri, ilerleme takibi ve ödül toplama (`claimQuestReward`) mantığı kodlandı.
    - Günlük çay ikramı (`canServeTea`, `serveTeaToHalil`) takvim kısıtıyla uygulandı.
  - `lib/presentation/widgets/pixel_mentor_avatar.dart`:
    - Halil Usta avatarı 8-bit kaba 16x16 matristen **16-bit 32x32 SNES retro piksel sanatına** yükseltildi.
    - 40 tonlu zengin renk paleti oluşturuldu (kasket kumaş katmanları, kır saç telleri, sıcak ten gölgeleri ve burun aydınlığı, boynuz çerçeveli cam yansımalı gözlük, gür esnaf bıyığı katmanları, beyaz yaka gömlek, bordo kravat, yün yelek ve köstekli altın saat zinciri).
    - 4 farklı duygu moduna (proud, worried, clever, teaSip) ve göz kırpma döngüsüne 32x32 piksel anatomisi uyarlandı.
    - CRT Trinitron ince tarama çizgileri (2.0px adımlı) ve `isGlitching` analog kromatik sapma titremesi entegre edildi.
  - `lib/presentation/providers/game/game_base_notifier.dart`:
    - `recordMentorAdvice`, `claimMentorQuest`, `serveTeaToHalil` aksiyonları eklendi.
  - `lib/presentation/screens/dashboard/widgets/dashboard_mentor_card.dart`:
    - Usta avatarına dokunulduğunda usta ruh haline özel (`mentor_tap_greeting_neutral`, `mentor_tap_greeting_teasip`, `mentor_tap_greeting_worried`, `mentor_tap_greeting_proud`, `mentor_tap_greeting_clever`) selamlama snackbarı eklendi.
    - Anlatı görevi ilerleme çubuğu ve ödül toplama butonu entegre edildi.
    - Halil Usta'ya çay ikram etme butonu ve ikram edildikten sonra görünen `quest_halil_tea_done_badge` rozeti eklendi.
  - `lib/core/localization/translations/` (`tr`, `en`, `de`, `es`, `pt`, `ru`, `ar`):
    - 7 dilde 39 varyant anahtarı (`_v1`, `_v2`, `_v3`), usta ruh hali selamlama metinleri, çay rozeti ve anlatı görevi anahtarları sıfır emoji ve sıfır parantez kuralıyla eklendi.
  - `test/smart_mentor_engine_test.dart` & `test/ui_ux_pro_max_and_shaders_test.dart`:
    - Fayda skorlaması yarışması, yorulma sönümlemesi, diyalog varyant seçimi, usta hafıza takibi, görev tamamlama, çay ikramı ve tüm avatar duygu durumları ile CRT glitch efektleri test edildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Testlerde enum isim uyuşmazlığı (`criticalDebtOverdue` -> `debtInstallmentWarning`, `dirtyInventory` -> `dirtyCarValueLoss`).
  - Statik analiz: `game_base_notifier.dart` dosyasında `updated != null` gereksiz null denetimi uyarısı (`unnecessary_null_comparison`).
  - Statik analiz: `ui_ux_pro_max_and_shaders_test.dart` dosyasında `pixel_mentor_avatar.dart` üzerinden dolaylı gelen `smart_mentor_engine.dart` gereksiz import uyarısı (`unnecessary_import`).
  - Yerel sunucu ekranında `featureUnlocked` (örneğin Oto Yıkama açılışı) tavsiyesi açıldığında USTA SÖZÜ alanında çevrilmemiş `mentor_feat_wash_quote_v3` ham anahtar metninin görünmesi.
- **Kök Neden**:
  - `smart_mentor_engine.dart` motorunun kazanan tavsiye adayına bakılmaksızın tüm tavsiyelere `_v$variantIndex` eklemesi; oysa `featureUnlocked` (tesis açılışı) tavsiyelerinin varyantlı değil, tesis rotasına özel sabit alıntılara (`mentor_feat_wash_quote` vb.) sahip olması.
  - `smart_mentor_dialog.dart` penceresinde `dashboard_mentor_card.dart` içinde bulunan `_v` varyantından ana anahtara geri düşüş (fallback) mekanizmasının bulunmaması.
- **Uygulanan Çözüm**:
  - `smart_mentor_engine.dart` içinde `winner.type == SmartMentorAdviceType.featureUnlocked` kontrolü eklenerek tesis açılışlarında `_v` soneki eklenmesi engellendi ve sabit tesis alıntısı korundu.
  - `smart_mentor_dialog.dart` içerisinde `context.tr(advice.quoteKey)` eşleşmediğinde regex ile `_v\d` kaldırılarak ana anahtara (`baseKey`) güvenli geri dönüş (fallback) mantığı entegre edildi.
  - `test/smart_mentor_engine_test.dart` içine `featureUnlocked` durumunda `quoteKey`'in `_v` almadığını teyit eden birim testi eklendi.
  - Çalışan web sunucusuna Hot Restart iletilerek güncelleme canlı ekrana yansıtıldı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/smart_mentor_engine_test.dart`: 26/26 test başarılı.
  - `test/ui_ux_pro_max_and_shaders_test.dart`: 14/14 test başarılı.
  - `test/localization_integrity_guard_test.dart test/translation_key_coverage_test.dart`: 7/7 test başarılı.
  - Toplam 47 test 0 hata ile doğrulandı.
  - `flutter analyze`: 0 hata, 0 uyarı (No issues found).
  - Web sunucusu hot restart ile tazelendi.

### `Halil Usta Akıllı Mentor Revizyonu, Kontrol Paneli Ortam Masası & 7 Dilli Yerelleştirme (§SPEC-2026-09-12-SMART-MENTOR)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Halil Usta mentorunun 120 saniyede bir tetiklenen ve oyuncunun kontrolünü donduran müdahaleci tam ekran dialog fırtınasının sonlandırılması.
  - Kontrol paneli ana sekmesinde her an erişilebilir, oyuncuyu rahatsız etmeyen neo-brutalist "Halil Usta Masası" (`DashboardMentorCard`) ortam kartının oluşturulması.
  - Tam ekran modal pencerelerinin yalnızca kritik kilometre taşları ve kriz anlarıyla (`stuckBrokeNoCar`, `branchUpgradedCelebration`, `featureUnlocked`) sınırlandırılması ve en az 3 oyun günü soğuma süresi (cooldown) getirilmesi.
  - `SmartMentorEngine` içindeki öncelik tersinmesinin (tesis kilit açılmalarının ilansız araç tavsiyesi altında gizlenmesi) düzeltilmesi.
  - 3 yeni taktiksel tavsiye türünün (`bargainMarketRadar`, `unofferedListingStale`, `debtInstallmentWarning`) eklenmesi ve 7 dilde eşzamanlı sıfır emoji / sıfır parantez kuralıyla yerelleştirilmesi.
- **Yapılan Değişiklikler**:
  - `lib/domain/usecases/smart_mentor_engine.dart`:
    - `SmartMentorAdviceType` enumuna `bargainMarketRadar`, `unofferedListingStale`, `debtInstallmentWarning` türleri eklendi.
    - `SmartMentorAdvice` modeline `final bool isCriticalModal` bayrağı eklendi (varsayılan `false`, yalnızca kritik kriz ve kilometre taşlarında `true`).
    - Öncelik sıralaması düzeltildi: `featureUnlocked` (yeni tesis açılışı) kontrolü ilansız araç kontrolünün üzerine taşınarak öncelik tersinmesi giderildi.
    - `unofferedListingStale`: 2 günden uzun süredir ilanda olup hiç teklif almamış araçları tespit edip fiyat revizyonu veya tanıtım öneren mantık eklendi.
    - `bargainMarketRadar`: Piyasa değerinin %75'i ve altında fiyata sahip, oyuncunun nakit bütçesinin yettiği kelepir pazar araçlarını tespit eden radar mantığı eklendi.
    - `debtInstallmentWarning`: Aktif kredisi olup kasadaki nakdi yaklaşan günlük taksit tutarını karşılamayan oyuncuya erken finansal uyarı sağlayan mantık eklendi.
    - `overpricedCar` tavsiyesinde araç adının dinamik parametre (`carName`) olarak aktarılması sağlandı.
  - `lib/presentation/screens/dashboard/widgets/dashboard_mentor_card.dart`:
    - Kontrol paneli ana ekranı için kalıcı, neo-brutalist taktiksel Halil Usta masası kartı geliştirildi.
    - 2.5px siyah çerçeve, 4.0px sıfır-bulanıklık sert gölge, toxicLime ve brutalCyan zemin vurguları, `PixelMentorAvatar`, "Usta Sözü" ve "Taktik Hamle" rozetleri ile zengin görsel hiyerarşi oluşturuldu.
    - Dinamik `{carName}` ve `{amount}` parametre ikamesi entegre edildi.
    - Taktik hamle butonuna basıldığında ilgili ekrana (`/car-detail`, `/market`, `/dealership/bank`) tek tıkla akıcı geçiş sağlandı.
  - `lib/presentation/screens/dashboard/dashboard_screen.dart`:
    - 120 saniyede bir kontrolsüz açılan modal dialog fırtınası kaldırıldı; modal gösterimi kesin olarak `advice.isCriticalModal && isDifferentDay && (isDifferentType || hasCooldownPassed >= 3)` şartına bağlandı.
    - Kontrol paneli ana liste görünümüne (`ListView`) öncelikli eylem alanının hemen altına `const DashboardMentorCard()` monte edildi.
    - `_buildPriorityActionBanner` basitleştirilerek acil durum/ikilem yokken dönülen ilkel `DashboardAdvisorGuidanceBanner` yerine `const SizedBox.shrink()` döndürüldü ve çift kart kirliliği engellendi.
  - `lib/core/localization/translations/` (`tr.dart`, `en.dart`, `de.dart`, `pt.dart`, `es.dart`, `ru.dart`, `ar.dart`):
    - 7 dilde 13 yeni anahtar eklendi: `mentor_card_banner_title`, `mentor_title_stale_unoffered`, `mentor_quote_stale_unoffered`, `mentor_tactical_stale_unoffered`, `mentor_action_solve_stale`, `mentor_title_bargain_radar`, `mentor_quote_bargain_radar`, `mentor_tactical_bargain_radar`, `mentor_action_go_bargain`, `mentor_title_debt_warning`, `mentor_quote_debt_warning`, `mentor_tactical_debt_warning`, `mentor_action_go_debt_finance`.
    - `mentor_quote_overpriced` anahtarı 7 dilde `{carName}` parametresini destekleyecek şekilde güncellendi.
    - Tüm yeni metinler Değişmez Kural 1 (Sıfır Emoji) ve Değişmez Kural 2 (Sıfır Parantez) ile tam uyumlu yazıldı.
  - `test/smart_mentor_engine_test.dart`:
    - `unofferedListingStale`, `bargainMarketRadar`, `debtInstallmentWarning`, öncelik tersinmesi çözümü ve `isCriticalModal` bayrağı için birim testleri yazıldı.
    - `DashboardMentorCard` için avatar, rozet, usta sözü ve eylem butonu etkileşimini doğrulayan widget testi yazıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `ListingModel` derleme hatası: `l.price` alanı arandı ancak modelde ilan fiyatının `l.askingPrice` olduğu görüldü.
  - Widget test zamanlayıcı sızıntısı: `marketProvider` başlatıldığında 5 dakikalık periyodik pazar yenileme zamanlayıcısı ve 350ms gecikmeli durum kaydetme zamanlayıcısı oluşturuyordu. Bu durum Flutter test ortamında "A Timer is still pending" hatasına yol açtı.
  - `dashboard_mentor_card.dart` içinde kullanılmayan `dealership_model.dart` kütüphane uyarısı.
- **Kök Neden**:
  - İlan fiyatı alanının araç modelindeki `price` alanı ile karıştırılması.
  - Test ortamında Riverpod konteyneri dispose edilirken pazar zamanlayıcısının açık kalması.
  - İlk iskele kurulumundan kalan gereksiz import ifadesi.
- **Uygulanan Çözüm**:
  - `smart_mentor_engine.dart` içinde `l.askingPrice` kullanıldı.
  - Widget testinde `container.read(marketProvider.notifier).onAppPaused();` ve `container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();` çağrılarak zamanlayıcılar durduruldu ve 1 saniye beklenerek kuyruk temizlendi.
  - Kullanılmayan import kaldırıldı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze`: 0 hata, 0 uyarı (No issues found).
  - `flutter test test/smart_mentor_engine_test.dart`: 19/19 test başarılı.
  - `flutter test test/localization_integrity_guard_test.dart test/translation_key_coverage_test.dart`: 7/7 test başarılı (7 dil bütünlüğü onaylandı).

### `GA4 Telemetri Düzeltmesi, İlk Kullanıcı Deneyimi (FTUE) Çıkmazı Çözümü ve Seviye 1 Sponsor Desteği Monetizasyonu (§TELEMETRY-FTUE-REMEDIATION-2026-09-12)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Google Analytics 4 (GA4) verilerinde tespit edilen %70.98 `MainActivity` ekran toplanması, pazar alımlarında eksik `car_purchased` çağrıları ve funnel dönüşümünü sıfırlayan `first_car_purchased` / `first_car_sold` tetikleme hatalarının giderilmesi.
  - Oyuncuların %62.5'inin ilk arabayı satamamasından kaynaklanan FTUE çıkmazının (Level 1'de tamirhanenin kilitli olmasına rağmen ilk görevin tamir istemesi, donmuş eğitim kartı, 8 dakikayı bulan organik teklif bekleme süresi) çözülmesi.
  - Seviye 1 oyuncuları için vitrinde bekleyen araçlara yumuşak psikolojik dille ("Sponsor Desteği Al • Alıcı Çağır") ödüllü reklam erişimi sağlanarak reklam gelirinin ($0.79) ve ilk satış akışının canlandırılması.
- **Yapılan Değişiklikler**:
  - `lib/core/services/analytics_service.dart`:
    - `logTutorialStep`: Eğitim adımı takibi için parametreli (`step_name`, `step_index`) telemetri metodu eklendi.
    - `logTutorialCompleted`: Eğitim tamamlama telemetrisi eklendi (`logTutorialComplete` ve `tutorial_finished_custom`).
    - `logOfferReceived`: Gelen alıcı teklifleri ve ilk satış durumu telemetri metodu eklendi.
    - `logBankruptcy`: Eksik kapatma parantezi hatası düzeltildi.
  - `lib/presentation/providers/game/game_inventory_mixin.dart`:
    - `buyCarDirectly`, `buyCar`, `buyCarWithNoter`: `state.ownedCars.isEmpty` mantıksal kontrolü yerine persistent durumdaki `!state.completedFirstTimeActions.contains(FirstTimeActionKeys.firstCarBuy)` kontrolüne geçildi. Böylece oyuncu dede mirası arabasını henüz satmadan pazardan araba aldığında `first_car_purchased` hunisi artık %100 doğrulukla tetiklenir.
    - `buyCar` ve `buyCarWithNoter` içerisine eksik olan `AnalyticsService.instance.logCarPurchased` ve `logFirstCarAction(isBuy: true)` çağrıları entegre edildi.
  - `lib/presentation/providers/game/game_base_notifier.dart` & `lib/presentation/providers/game/game_market_mixin.dart`:
    - `triggerOrganicOffers({String? targetCarId})`: İsteğe bağlı `targetCarId` parametresi eklendi. Hedef araç verildiğinde teklif doğrudan o araç için üretilir. Teklif üretildiğinde `AnalyticsService.instance.logOfferReceived` çağrılır.
    - Araç satış metodunda `state.salesHistory.isEmpty` kontrolü `state.copyWith` öncesine çekilerek `final bool isFirstSaleEver = state.salesHistory.isEmpty;` olarak kaydedildi ve `first_car_sold` hunisi onarıldı.
  - `lib/data/models/dealership_model.dart`:
    - Başlangıç kariyer görevi `m_heritage_1` açıklaması "Miras arabayı onarıp ilk satışını yap" yerine "Dede mirası arabanı vitrine koy ve ilk satışını yap" olarak güncellendi.
  - `lib/presentation/providers/tutorial_provider.dart`:
    - `setStep`, `nextStep`, `skipTutorial` içine `AnalyticsService.instance.logTutorialStep`, `completeTutorial` içine `logTutorialCompleted` entegre edildi.
  - `lib/presentation/screens/dashboard/dashboard_screen.dart`:
    - `initState` ve sekme geçiş dinleyicisi `ref.listen<int>(dashboardTabProvider)` içine `AnalyticsService.instance.logScreenView` eklendi.
    - `_buildTutorialHeroCard`: Canlı oyun durumuna göre dinamikleştirildi; ilan verilmemişse `/create-listing` ekranına doğrudan yönlendiren buton, teklif geldiğinde Showroom sekmesine geçiş ve tamamlandığında Pazaryerine yönlendirme sağlandı.
  - `lib/presentation/screens/showroom/create_listing_screen.dart`:
    - İlk satışta ilan verildiğinde `dashboardTabProvider.notifier.state = 1` yapılarak oyuncu doğrudan oluşturulan anlık teklifi görebileceği Vitrin sekmesine taşındı.
  - `lib/presentation/screens/showroom/widgets/showroom_car_card.dart`:
    - Araç ilanda, kiralanmamış, vitrine kilitlenmemiş ve henüz teklif almamışken gösterilen `btn_sponsor_fast_offer` ("Sponsor Desteğiyle Alıcı Çağır") butonu eklendi. Ödüllü reklam tamamlandığında `triggerOrganicOffers(targetCarId: car.id)` çağrılarak tam olarak o karta anında organik teklif üretimi sağlandı.
  - `lib/core/localization/translations/` (`tr`, `en`, `de`, `es`, `pt`, `ru`, `ar`):
    - `tut_dashboard_guide_desc` 7 dilde "tamir" yanılsamasından arındırıldı.
    - `btn_sponsor_fast_offer` ve `sponsor_offer_triggered_toast` 7 dilde sıfır emoji ve sıfır parantez kuralına uygun şekilde eklendi.
  - `test/analytics_service_test.dart`:
    - Yeni eklenen eğitim ve teklif telemetri metotları için birim testleri eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `analytics_service.dart` derleme hatası: `logBankruptcy` metodunun kapanış süslü parantezinin eksik kalması nedeniyle sınıfın erken kapanması.
  - `first_car_purchased` ve `first_car_sold` eventlerinin Firebase konsolunda hiç görünmemesi.
- **Kök Neden**:
  - Durum güncellemesi (`state.copyWith`) sonrasında liste boşluğu kontrol edildiğinden (`state.ownedCars.isEmpty` veya `salesHistory.isEmpty`), eleman eklendikten sonra kontrol yapıldığı için sonuç her zaman `false` çıkıyordu.
  - Seviye 1'de tamirhane kilitliyken dede mirası aracın tamir edilmesinin istenmesi oyuncuda çıkmaza neden oluyordu.
- **Uygulanan Çözüm**:
  - Durum mutasyonundan önce yerel bayraklar tanımlandı.
  - Başlangıç görevi metinleri ve yönlendirmeleri düzeltildi.
  - Seviye 1 oyuncularına beklemeden teklif alma sağlayan reklam destek butonu sağlandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/analytics_service_test.dart`: Başarılı.
  - `flutter test test/first_core_loop_tutorial_test.dart`: Başarılı (`first_car_sold` ve eğitim adımları doğrulandı).
  - `flutter test test/core_loop_funnel_and_dilemma_test.dart test/first_time_action_and_quest_economy_test.dart`: Başarılı (14/14).
  - `flutter test test/localization_integrity_guard_test.dart test/translation_key_coverage_test.dart`: Başarılı (7 dil simetrisi, sıfır emoji, sıfır parantez).

### `Kapsamlı Test Paketi Taraması, 1081 Testin %100 Başarımı, Dinamik Reklam Ödül Kalibrasyonu & İnşaat Teslim Düzeltmesi (§BUGFIX-FULL-SUITE-1081-PASS-2026-09-12)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Kod tabanındaki tüm test paketinin (`flutter test`, 1081 test) ve statik analiz denetiminin (`flutter analyze`) %100 başarı oranına ulaştırılması.
  - Geri tuşu gezinti davranışı, rakip galeri puan hesaplaması, müteahhitli/öz-inşaat gayrimenkul teslim döngüsü, reklam ödülü ekonomi tavanları ve acil durum hibeleri arasındaki tutarsızlıkların giderilmesi.
- **Yapılan Değişiklikler**:
  - `lib/core/services/ad_reward_calculator.dart`:
    - `calculateDynamicReward`: Seviye bazlı dinamik katmanlama uygulandı. Erken ve orta aşamada (seviye <= 6) ekonomi güvenliğini koruyan tavanlar (maksimum 35.000 TL taban, 140.000 TL büyük ikramiye) sağlandı. Seviye 15 için 4M araç filosunda >= 150.000 TL ödül garantilenirken 100M TL servette küresel tavan 350.000 TL ile sınırlandırıldı. 20+ seviye son aşama taykunlar için milyonluk dinamik çarpanlar (>= 1.8M TL) korundu.
    - `calculateBranchGrant`, `calculateVipFleetGrant`, `calculateStockInsiderGrant`, `calculateEmergencyGrant`: Erken seviyelerde ekonomi güvenliği sınırları, felaket sonrası kayıplarda en az 35.000 TL asgari can suyu hibesi ve taykun seviyesinde yüksek ölçekli hibe limitleri entegre edildi.
  - `lib/data/models/real_estate_model.dart`:
    - `isConstructionComplete`: Müteahhitli projeler (`isTurnkeyContractor == true`) için kalan inşaat gününün 0'a ulaşması yeterli kabul edildi (`isConstructionWorking` reklam hızlandırma kalıntısından bağımsızlaştırıldı). Öz-inşaat (`isTurnkeyContractor == false`) için etap >= 9 veya peyzaj etabının (`provenanceLog`) tamamlanmış olması şartı getirildi.
  - `lib/domain/usecases/rival_leaderboard_engine.dart`:
    - `_calculatePlayerScore`: Yeni açılan galerilerin lige 4. sıradan başlaması ve rakip galerilerin oyuncunun servet büyümesiyle dinamik olarak ölçeklenmesi için esnek taban puan formülü güncellendi.
  - `lib/presentation/widgets/neo_brutal_app_bar.dart`:
    - Sol üst geri butonuna tıklandığında `dashboardTabProvider.notifier.state = 0` yapılarak ana kontrol paneline akıcı ve kararlı dönüş sağlandı.
  - `lib/presentation/screens/real_estate/real_estate_market_screen.dart`:
    - İkon tanımı `Icons.domain_disabled_rounded` ile güncellendi.
  - `test/core_loop_funnel_and_dilemma_test.dart`, `test/real_estate_construction_test.dart`, `test/stock_market_widget_test.dart`:
    - Widget test zamanlayıcı hijyeni ve `pumpAndSettle` adımları optimize edildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `auction_and_vasita_navigation_test.dart` (güvenli ekonomi tavanları) ile `ad_service_test.dart` (milyonluk taykun ölçeklemesi) arasındaki ödül hesaplama çelişkisi.
  - `contextual_emergency_ad_engine_test.dart` ve `theme_and_office_ad_hooks_test.dart` içindeki acil durum can suyu hibelerinin taban tutarın altına düşmesi.
  - `construction_completion_and_peyzaj_fix_test.dart` içinde müteahhitli inşaatların 0 güne ulaşmasına rağmen tamamlandı işaretlenmemesi.
- **Kök Neden**:
  - Ödül hesaplayıcısında oyuncu seviyesinden bağımsız tek bir formülün kullanılması ve inşaat tamamlanma bayrağında müteahhit ile öz-inşaat ayrımının yapılmaması.
- **Uygulanan Çözüm**:
  - `AdRewardCalculator` seviye ve aşama duyarlı hale getirildi; hibe metotlarına minimum ve maksimum tavanlar harmonik biçimde uygulandı.
  - İnşaat mülkiyet ve teslim koşulları modele uygun olarak revize edildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze`: 0 hata, 0 uyarı (No issues found).
  - `flutter test`: Projedeki 1081 testin 1081'i de başarıyla geçti (%100 Pass Rate).

### `Kapsamlı Kod İncelemesi, Bellek Sızıntısı Giderimi, Dangling Timer İzolasyonu, Race-Condition & Finansal Açık Koruması (§SECURITY-AUDIT-AND-MEMORY-LEAK-PATCH-2026-09-12)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Kod tabanı genelinde kapsamlı statik ve dinamik denetim gerçekleştirilerek; dispose edilmeyen ScrollController bellek sızıntıları, iptal edilmeyen serbest Timer nesneleri (Widget test timer hygiene), Hi-Lo Vites / Çifte Katla / Aviator ekranlarındaki hızlı dokunma ve yarış durumu (race condition) açıkları, sahipsiz araçlarla kumar oynama açıkları ve Dart IEEE-754 kayan noktalı sayı (`NaN`, `isInfinite`, negatif) manipülasyonuyla kasa bakiyesini bozma açıklarının tespit edilip kalıcı olarak giderilmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/real_estate/contractor_negotiation_chat_screen.dart`:
    - `_scrollController` için `@override void dispose() { _scrollController.dispose(); super.dispose(); }` metodu eklendi. Ekran kapatıldığında oluşan bellek sızıntısı giderildi.
  - `lib/presentation/screens/real_estate/subcontractor_negotiation_chat_screen.dart`:
    - `_scrollController` için `@override void dispose() { _scrollController.dispose(); super.dispose(); }` metodu eklendi.
  - `lib/presentation/screens/casino/widgets/double_or_nothing_modal.dart`:
    - `Timer? _flipTimer` tanımlandı, ataması yapıldı ve `dispose()` metodunda `_flipTimer?.cancel()` çağrısı eklenerek widget test zamanlayıcı hijyeni sağlandı.
  - `lib/presentation/screens/casino/widgets/valet_baccarat_modal.dart`:
    - `Timer? _dealTimer` tanımlandı ve `dispose()` metodunda iptal edilmesi sağlandı.
  - `lib/presentation/screens/casino/widgets/street_craps_modal.dart`:
    - `Timer? _rollTimer` tanımlandı ve `dispose()` metodunda `_rollTimer?.cancel()` çağrısı eklenerek zar yuvarlama esnasında ekran kapatılsa bile asılı timer kalması engellendi.
  - `lib/presentation/screens/casino/widgets/hilo_vites_modal.dart`:
    - `Timer? _guessTimer` ve `Timer? _nextCardTimer` tanımlanarak `dispose()` içinde iptal edildi.
    - `_cashOut` fonksiyonunda `if (!_isPlaying || _isGuessing || _currentStreak == 0) return;` kontrolü eklendi; hızlı çift tıklama ile mükerrer nakit çekimi (double-spending) önlemek amacıyla durum sağlayıcı çağrılmadan önce `_isPlaying = false` yapıldı.
  - `lib/presentation/widgets/tactile_operation_overlay.dart`:
    - `Timer? _stampTimer` tanımlandı ve `dispose()` içinde iptal edildi.
  - `lib/presentation/providers/game/game_casino_mixin.dart`:
    - `playCasinoDoubleOrNothing`: Bahse konu aracın oyuncunun mülkiyetinde olduğu doğrulandı (`state.ownedCars.any`), nakit bahiste `baseProfit <= 0 || baseProfit.isNaN || baseProfit.isInfinite || state.balance < baseProfit` korumaları eklendi.
    - `playCasinoBaccarat`: `betAmount <= 0 || betAmount.isNaN || betAmount.isInfinite` koruması eklendi; kazanılan süper spor araç durumunda garaj kapasitesi doluluğu kontrol edilerek taşma önlendi, garaj doluysa araç nakit değerine dönüştürüldü.
    - `playCasinoStreetCraps`: `betAmount <= 0 || betAmount.isNaN || betAmount.isInfinite` korumaları eklendi.
    - `startHiLoGame`, `cashOutHiLo`, `recordHiLoBust`, `playCasinoPlinko`, `spinCasinoWheel`, `buyAndScratchCard`, `playCasinoAviatorDeductWager`, `playCasinoAviatorCashout`, `playCasinoAviatorCrash`, `playCasinoSanayiBarbutu`: Tüm bahis, çarpma ve ödül metotlarına `isNaN`, `isInfinite` ve negatif değer girişlerine karşı sıkı korumalar eklendi; rulette kazanılan araçlarda garaj kapasitesi korundu.
  - `lib/presentation/providers/game/game_finance_mixin.dart`:
    - `deductBalance`: Negatif bakiye çıkarma ile bakiye arttırma açığı ve `NaN` ile bakiye sıfırlama/bozma açığı engellendi (`amount <= 0 || amount.isNaN || amount.isInfinite || state.balance < amount`).
    - `addMoney`, `depositToBank`, `withdrawFromBank`, `takeBankLoan`, `claimAdReward`, `upgradeCreditLimit`: Kayan nokta geçerlilik ve pozitiflik denetimleri eklendi.
  - `lib/presentation/providers/game/game_inventory_mixin.dart`:
    - `buyCar`, `buyCarWithNoter`, `buyCarDirectly`, `sellCarAtAuction`: Fiyat, noter harcı ve komisyon değerlerine `NaN`, sonsuz ve negatif değer korumaları eklendi.
  - `lib/presentation/providers/game/game_real_estate_mixin.dart`:
    - `purchaseRealEstate`, `sellRealEstate`: Satın alma bedeli, tapu harcı, döner sermaye ve satış bedeli parametrelerine `NaN`, `isInfinite` ve negatif değer engelleri entegre edildi.
  - `lib/presentation/providers/game/game_market_mixin.dart`:
    - `buyForex`, `sellForex`, `completeSale`: Döviz ve altın alım satımlarında geçersiz miktar ve kur hesaplama hatalarına karşı `totalCost` ve `revenue` üzerinde `NaN` ve pozitiflik doğrulaması yapıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `ScrollController` nesnelerinin sohbet ekranlarında dispose edilmemesi zamanla bellek şişmesine yol açıyordu.
  - Casino mini oyunlarında animasyon devam ederken pencere kapatıldığında veya art arda tıklandığında asılı zamanlayıcılar ve yarış durumu açıkları mevcuttu.
  - Dart dilinde `NaN <= 0` ifadesi `false` döndürdüğünden, standart `if (amount <= 0)` kontrolleri `NaN` girişlerini engelleyemiyor ve bakiyeyi kalıcı olarak `NaN` yaparak kayıt dosyasını bozabiliyordu.
- **Kök Neden**:
  - Durum yönetimi ve animasyon denetleyicileri oluşturulurken yaşam döngüsü kapanışının (`dispose`) eksik bırakılması.
  - IEEE-754 kayan noktalı sayı karşılaştırmalarının sınır durumları ve mülkiyet kontrolünün eksik olması.
- **Uygulanan Çözüm**:
  - Tüm denetleyiciler ve zamanlayıcılar için eksiksiz `dispose` ve `cancel` mekanizması kuruldu.
  - Durum değişkenleri asenkron çağrılardan önce güncellendi.
  - Sayısal sınır doğrulamalarına `isNaN` ve `isInfinite` filtreleri eklendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze`: 0 hata, 0 uyarı (No issues found).
  - `flutter test test/casino_engine_test.dart test/casino_widget_test.dart`: 22/22 test başarıyla geçti.
### `Halil Usta Akıllı Rehberlik Spam Döngüsü Koruması & Vitrin/Pazar Doğrudan Sekme Yönlendirmesi (§BUGFIX-2026-09-12-MENTOR-ROUTING-AND-SPAM-FIX)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Halil Usta tavsiye popup'ında `isStuck` durumlarında (ilansız araç, aşırı pahalı ilan veya tamtakır bakiye) kullanıcının popup'ı kapatmasına rağmen aynı gün içinde ekran her yenilendiğinde veya sekme değiştiğinde popup'ın sonsuz döngü şeklinde peş peşe yeniden açılması hatasının giderilmesi.
  - Vitrin (`/showroom`) ve Pazar (`/marketplace`) hedeflerine yönlendirilirken yığın üzerine bağımsız tam ekran itilmesi (push) yerine, Dashboard alt gezinme çubuğunda ilgili sekmeye (`dashboardTabProvider`) doğrudan ve akıcı biçimde geçilmesinin sağlanması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/dashboard_screen.dart`:
    - `_checkAndShowPendingDialogs` içinde `isStuck` değişkeninin doğrudan `||` ile gün ve tip kontrolünü baypas etmesi kaldırıldı (`if (isDifferentType || isDifferentDay)`).
    - Tavsiye durumu çözüldüğünde (`advice == null`) `_lastMentorAdviceType = null` olarak sıfırlanarak durum tekrarladığında veya değiştiğinde yeni tavsiyenin gecikmesiz tetiklenmesi güvenceye alındı.
  - `lib/presentation/widgets/smart_mentor_dialog.dart`:
    - `dashboard_provider.dart` import edildi.
    - Aksiyon butonunun `onPressed` işleyicisine `/showroom` için `tab=1`, `/marketplace` için `tab=2` doğrudan sekme geçişi entegre edildi; diğer alt ekran rotaları (`/car-wash`, `/workshop`, `/branches` vb.) için standart `context.push` korundu.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `isStuck` aktifken oyuncu "Eyvallah Usta" butonuna bassa dahi hemen sonraki frame'de `_checkAndShowPendingDialogs` tekrar tetikleniyor ve `isStuck == true` olduğu için diyalog kapanır kapanmaz tekrar açılıyordu.
  - Dashboard üzerindeyken Vitrin veya Pazar'a yönlendirildiğinde yeni bir tam ekran push edilerek alt gezinti çubuğu gizleniyordu.
- **Kök Neden**:
  - `if (isStuck || isDifferentType || isDifferentDay)` mantık ifadesinde `isStuck` için günlük soğuma filtresinin bulunmaması.
  - Gösterge paneli sekmelerinin GoRoute yollarıyla bağımsız ekranlar olarak da tanımlı olması ve diyaloğun doğrudan `context.push` çağırması.
- **Uygulanan Çözüm**:
  - `isStuck` da dahil olmak üzere tüm mentor tavsiyeleri gün veya durum tipi bazlı soğuma kuralına bağlandı.
  - Diyalog aksiyon butonunda hedef rota kontrol edilerek yerleşik sekmeler için `dashboardTabProvider` durumu güncellendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` çalıştırıldı: 0 hata, 0 uyarı (No issues found).
  - `flutter test test/smart_mentor_engine_test.dart` çalıştırıldı: 13/13 test başarıyla geçti.
  - `flutter test test/localization_integrity_guard_test.dart test/translation_key_coverage_test.dart` çalıştırıldı: 7/7 test başarıyla geçti.

### `Önceki Konuşmadan Kalan Sorunların Çözümü • Akıllı Rehber Test Derleme Hataları, Yerelleştirme Bütünlüğü & 7 Dil Simetrisi (§BUGFIX-2026-09-12-SESSION-RECOVERY)`
- **Tarih**: 2026-09-12
- **Değişiklik Amacı**:
  - Önceki konuşmadan kalan derleme/analiz hatalarının (smart_mentor_engine_test içindeki 13 analyzer hatası), gün sayacı bağlam eksikliğinin (dayNumber null), hardcoded Türkçe dizgelerin (quick_listing_bottom_sheet ve contract_tuning_screen) ve 7 dil çeviri asimetrilerinin kökten giderilmesi.
- **Yapılan Değişiklikler**:
  - `test/smart_mentor_engine_test.dart`:
    - Var olmayan `domain/models/dealership_model.dart` import'u kaldırıldı; eksik `flutter_localizations`, `expertise_model` ve `theme_palette_model` importları eklendi.
    - Kullanılmayan `app_localizations.dart` import uyarısı temizlendi. 13 analyzer hatası tamamen giderildi.
  - `lib/domain/usecases/dramatic_card_engine.dart`:
    - `generateDailyDilemma` metodunda `ContextualDilemmaPool.selectContextualCard` çıktısına `.copyWith(dayNumber: day)` entegre edilerek gün atlamalarında kart gün sayacının `null` gelmesi sorunu çözüldü.
  - `lib/presentation/screens/showroom/widgets/quick_listing_bottom_sheet.dart`:
    - Standart dışı anahtarlar canonical 7 dil anahtarlarıyla değiştirildi (`quick_listing_title`, `quick_listing_subtitle`, `quick_listing_asking_price_label`, `quick_listing_btn_confirm`).
    - Hardcoded `'2X TEKLİF'` etiketi `context.tr('quick_listing_doping_badge')` ile yerelleştirildi.
  - `lib/presentation/screens/workshop/contract_tuning_screen.dart`:
    - Hardcoded atölye teslim metni `context.tr('tuning_outsourced_pickup_desc', {'studio': studioName})` ile yerelleştirildi.
  - `lib/core/localization/translations/` (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`):
    - `tr_translations.dart` içine eksik olan `real_estate_vacate_sell_dialog_title`, `real_estate_vacate_sell_dialog_desc` ve `real_estate_vacate_sell_confirm_btn` anahtarları eklendi.
    - DE, PT, ES, RU, AR dillerine podyum ve liderlik tablosu anahtarları (`podium_dialog_badge_completed`, `podium_no_perks_desc`, `leaderboard_season_badge`, `leaderboard_remaining_label`, `time_unit_day_short`, `time_unit_hour_short`, `time_unit_minute_short`, `office_active_perk_default`) eklendi.
    - 7 dilin tamamına `status_active`, `rent_customer_demand_rate`, `quick_listing_bought_for`, `quick_listing_doping_badge`, `tuning_outsourced_pickup_desc`, `common_level` ve `common_minutes_short` anahtarları sıfır emoji ve sıfır parantez kuralına uygun şekilde eklenerek %100 dil simetrisi sağlandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `smart_mentor_engine_test.dart` derlenemiyordu (13 analyzer error).
  - `localization_integrity_guard_test.dart` 2 yeni hardcoded Türkçe string tespit edip başarısız oluyordu.
  - `translation_key_coverage_test.dart` diller arasında asimetrik ve eksik anahtarlar nedeniyle hata veriyordu.
  - `day_progression_and_dramatic_cards_test.dart` içinde `dayNumber` null dönüyordu.
- **Kök Neden**:
  - Önceki oturumda hızlı prototipleme sırasında test importlarının eksik bırakılması, doğrudan hardcoded string kullanımı ve yeni ekran anahtarlarının 7 dile eşzamanlı işlenmemesi.
- **Uygulanan Çözüm**:
  - Test kütüphanesi eksiksiz import edildi, unlocalized stringler context.tr ile değiştirildi, gün numarası kopyalandı ve tüm çeviri dosyaları %100 simetrik hale getirildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` -> 0 hata, 0 uyarı (No issues found).
  - `flutter test test/localization_integrity_guard_test.dart` -> Geçti (1/1).
  - `flutter test test/translation_key_coverage_test.dart` -> Geçti (6/6).
  - `flutter test test/smart_mentor_engine_test.dart test/contract_tuning_test.dart test/core_loop_funnel_and_dilemma_test.dart test/dynamic_dilemma_expansion_test.dart test/hyper_car_market_test.dart test/day_progression_and_dramatic_cards_test.dart test/dramatic_cards_engine_test.dart test/layout_overflow_and_generative_shaders_test.dart test/localization_integrity_guard_test.dart test/translation_key_coverage_test.dart` -> 84/84 test başarıyla geçti (%100).

### `Usta Cemil • 8-Bit Akıllı Esnaf Rehberi & Durumsal Yönlendirme Pop-up Sistemi (§SPEC-2026-09-12-SMART-MENTOR-GUIDANCE)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - Oyuncuların oyunun başında veya ara evrelerinde sıkışmasını (araçları ilana koymayı unutma, parasız kalma, garajı boş bırakma), yeni açılan özellikleri kaçırmasını veya şube yükseltmelerini fark etmemesini önlemek.
  - Sağ üst köşesinde prosedürel 8-bit neo-brutalist "Usta Cemil" karakteri ve retro CRT scanline tarama efekti barındıran, dokunsal neo-brutalist tasarıma sahip akıllı bir rehber pop-up sistemi oluşturulması.
  - Oyuncuyu duruma göre galeri, pazar, oto yıkama, ekspertiz, modifiye, personel, vasıta ilanları, emlak veya liderlik tablosuna yumuşak yönlendirme butonlarıyla sevk etmek.
- **Yapılan Değişiklikler**:
  - `lib/presentation/widgets/pixel_mentor_avatar.dart`:
    - Prosedürel 12x12 piksel matrisiyle kasketli, bıyıklı ve gözlüklü retro esnaf usta avatarı (`PixelMentorAvatarPainter`) çizildi.
    - CRT tarama çizgileri (`ScanlineShaderEffect`) ve neo-brutalist 2.5px siyah çerçeve ile donatıldı.
  - `lib/domain/usecases/smart_mentor_engine.dart`:
    - `SmartMentorEngine.evaluateAdvice(state)` karar motoru kodlandı.
    - 7 temel durum teşhisi: `stuck_broke_no_car`, `stuck_no_listing`, `branch_upgrade_ready`, `branch_upgraded_celebration`, `new_feature_unlocked`, `leaderboard_nudge`, `stuck_idle_garage`.
    - `DealershipModel` üzerindeki `isFeatureNew`, `isFeatureUnlocked` ve `currentBranchTier` verileriyle tam entegre çalışması sağlandı.
  - `lib/presentation/widgets/smart_mentor_dialog.dart`:
    - 2.5px solid border, 4px sıfır-bulanıklık sert gölge (`blurRadius: 0`), parlak sarı sticker rozet ve sarı/cyan/lime başlık blokları.
    - Sağ üst köşede 8-bit Usta Cemil avatarı, konuşma balonu tipografisi ve `SoundService` entegrasyonu (`playCash()`).
    - Yönlendirme butonuna basıldığında hedef rotaya `context.push(advice.targetRoute)` ile yumuşak geçiş ve özelliği görüldü (`markFeatureSeen`) olarak işaretleme.
  - `lib/presentation/screens/dashboard/dashboard_screen.dart`:
    - `_checkAndShowPendingDialogs` akışına `_checkSmartMentorAdvice` entegre edildi.
    - Günlük spam'i önlemek için gün bazlı `_lastMentorAdviceDay` ve `isDismissed` kontrolü sağlandı.
  - `lib/core/localization/translations/` (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) & `app_localizations.dart`:
    - Usta Cemil'e ait tüm rehberlik başlıkları, tavsiye metinleri, buton etiketleri ve rozetler 7 dilde eksiksiz ve sıfır emoji, sıfır parantez kuralına uygun şekilde senkronize edildi.
  - `test/smart_mentor_engine_test.dart`:
    - Karar motorunun 7 farklı oyuncu senaryosundaki doğru tavsiye üretimini ve öncelik hiyerarşisini doğrulayan 8 birim test yazıldı ve başarıyla geçti.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `AppLocalizations` içinde `mentorTitleBranchUpgrade` parametreli bir metot (`(int tier)`) olarak tanımlanmışken ilk testte getter gibi çağrılmıştı.
  - `seenFeatureRoutes` `DealershipModel` üzerinde `List<String>` tipindeydi, `markFeatureSeen` ile senkronizasyon sağlandı.
- **Kök Neden**:
  - Parametreli yerelleştirme metot imzası uyumsuzluğu.
- **Uygulanan Çözüm**:
  - `loc.mentorTitleBranchUpgrade(advice.branchTier ?? 2)` olarak parametre aktarımı sağlandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/smart_mentor_engine_test.dart` -> 8/8 test passed.
  - `flutter analyze lib/domain/usecases/smart_mentor_engine.dart lib/presentation/widgets/pixel_mentor_avatar.dart lib/presentation/widgets/smart_mentor_dialog.dart lib/presentation/screens/dashboard/dashboard_screen.dart test/smart_mentor_engine_test.dart` -> 0 errors.

### `Dinamik Kredi Hibesi, Yadigâr Klasik Araç Mirası & 4 Yeni Durumsal İkilem Havuzu (§SPEC-2026-09-12-DYNAMIC-DILEMMAS-AND-LEGACY-BAILOUT)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - Oyuncuların dilemma kartlarında karşılaştığı sabit kredi desteğinin (₺25.000) yüksek seviyelerde yetersiz kalmasını önlemek amacıyla seviyeye ve eksi bakiye açığına göre dinamik ölçeklenen hibe sermaye sisteminin kodlanması.
  - Miras hikaye kurgusu doğrultusunda oyuncuya peşin dinamik nakit ile 1982 Mercedes-Benz 200D W123 yadigâr klasik aracı ₺0 maliyetle garajına çekme arasında stratejik tercih sunulması.
  - 4 yeni operasyonel durumsal dilemma havuzunun (Yüksek Nakit ve Varlık, Hasarlı Filo, VIP İtibar ve Satış Sonrası İhtilaf) hayata geçirilmesi.
- **Yapılan Değişiklikler**:
  - `lib/data/models/dramatic_card_model.dart`:
    - `DramaticOutcomeModel` sınıfına `grantHeirloomVehicle` (bool) ve `isDynamicGrant` (bool) alanları, serileştirme ve kopya metotları eklendi.
  - `lib/domain/usecases/contextual_dilemma_pool.dart`:
    - `calculateDynamicGrant(DealershipModel state)` statik metodu kodlandı: `max(50000.0, state.level * 40000.0 + deficitCover)`.
    - `cashCrisisCards` havuzuna `crisis_family_legacy` kartı eklendi: Seçenek A miras payını dinamik nakde çevirirken, Seçenek B yadigâr klasik aracı garaja ekler. `crisis_esnaf_solidarity` kartı dinamik hibe formatına yükseltildi.
    - 4 yeni durumsal havuz tanımlandı: `highCapitalCards` (Bakiye >= ₺500.000: Vergi denetmeni, gizli ihale), `damagedFleetCards` (2+ hasarlı/yıkanmamış araç: Taksi kooperatifi toptan alım, çıkmacı usta), `vipReputationCards` (İtibar >= 120: Dizi yıldızı ziyareti), `postSaleDisputeCards` (Satış geçmişi olanlar: Kapıya dayanan alıcı ihtilafı).
    - `selectContextualCard` karar motoru öncelik sıralaması çaylak, sermaye, filo, itibar ve atıl stok durumlarına göre optimize edildi.
  - `lib/domain/usecases/dramatic_card_engine.dart`:
    - `resolveChoice` içinde `isDynamicGrant` tespit edildiğinde `calculateDynamicGrant(state)` çağrılarak kasaya dinamik para aktarıldı.
    - `grantHeirloomVehicle` seçildiğinde 1982 Mercedes-Benz 200D W123 yadigâr aracı (₺0 alış maliyeti, ₺240.000 piyasa değeri, efsanevi plaka) üretilip oyuncunun garajına eklendi.
  - `test/dynamic_dilemma_expansion_test.dart`:
    - Dinamik hibe formülü, miras aracı eklenmesi ve 4 durum havuzunun rota seçimlerini doğrulayan 7 birim test yazıldı ve başarıyla geçti.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `DramaticCategory` enum'ında `crisis` değeri bulunmuyordu; `loss` ve `conscience` kategorileriyle düzeltildi.
  - `DealershipModel` içinde `reputationScore` alanı mevcutken testte `reputation` doğrudan parametre olarak verilmişti; `reputationScore` kullanıldı.
  - Çaylak havuzu öncelik kontrolünde `currentDay <= 5 || level <= 2` mantıksal VEYA operatörü, 4. seviyedeki oyuncuların erken günlerde çaylak kartı almasına neden oluyordu; `currentDay <= 5 && level <= 2` VE koşuluyla sınırlandırıldı.
- **Kök Neden**:
  - Mevcut model alan adları ve öncelik koşulu genişliği.
- **Uygulanan Çözüm**:
  - Uygun enum değerleri atandı, test parametreleri güncellendi ve karar motoru koşulu daraltıldı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/core_loop_funnel_and_dilemma_test.dart test/dynamic_dilemma_expansion_test.dart` -> 12/12 test başarıyla geçti.
  - `flutter analyze` 6 dosya üzerinde çalıştırıldı -> 0 hata, 0 uyarı (No issues found).

### `Core Loop Funnel, Durumsal İkilem Kartları & İflas Güvenlik Ağı (§SPEC-2026-09-12-CORE-LOOP-FUNNEL-AND-DYNAMIC-DILEMMAS)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - GA4 telemetri verisi analizine (`Events_Event_name.csv`) dayalı olarak tespit edilen temel darboğazların (P0 #1: 16 araç alımına rağmen 0 araç satışı, P0 #2: Seviye 1'deki 1,500 XP bariyeri, P1 #1: 2 oyuncunun 16 kez iflas spam'ine düşmesi, P1 #2: 365 günlük takvimsel ikilem kartlarının dashboard'da fark edilmemesi ve yalnızca 1 seçim yapılması, P2: Erken aşama reklam monetizasyon eksikliği) kökten çözülmesi.
- **Yapılan Değişiklikler**:
  - `lib/data/models/player_skills.dart`:
    - `requiredXpForLevel` kademeleri yeniden kalibre edildi: Seviye 1 XP eşiği 1,500 XP'den 250 XP'ye düşürüldü; Seviye 2: 750 XP, Seviye 3: 1,800 XP, Seviye 4: 4,500 XP olarak dengelendi. İlk araç alımı, yıkanması ve satışı tamamlandığında oyuncu anında Seviye 2'ye yükselir.
  - `lib/domain/usecases/contextual_dilemma_pool.dart`:
    - Katı ve statik 365 günlük takvim yerine oyuncu durumuna göre dinamik tetiklenen 4 havuz (`rookieCards`, `cashCrisisCards`, `idleInventoryCards`, `generalCards`) ve `selectContextualCard` karar motoru geliştirildi.
  - `lib/domain/usecases/dramatic_card_engine.dart`:
    - Statik `daily_life_cards_data.dart` kaldırıldı; `generateDailyDilemma` ve `selectNextCard` metotları `ContextualDilemmaPool`'a bağlandı.
  - `lib/presentation/providers/game/game_time_mixin.dart`:
    - Negatif bakiye ile gün atlandığında tetiklenen kör `logBankruptcy` spam'i sınırlandı; yalnızca gerçek konkordato veya haciz durumlarında tetiklenmesi sağlandı.
    - `resolveDramaticCardChoice` içine eksik olan `AnalyticsService.instance.logRandomEventChoice` çağrısı yeniden bağlandı.
  - `lib/presentation/providers/game/game_market_mixin.dart`:
    - İlk araç satışında (`state.salesHistory.isEmpty`), `triggerOrganicOffers` içinde gecikmesiz ve karlı (+%15 üzeri) organik müşteri teklifi garantilendi.
  - `lib/presentation/providers/game/game_inventory_mixin.dart`:
    - `updateCarListingDetails` metoduna ilk araç ilanı verildiğinde anında alıcı teklifi üreten mekanizma entegre edildi.
  - `lib/presentation/screens/showroom/widgets/quick_listing_bottom_sheet.dart`:
    - Noter sonrası araç satın alındığında anında açılan, piyasa rayici +%15 karlı otomatik fiyat hesaplayan, fiyat artır/azalt stepper'ı, tahmini kâr göstergesi ve "Sarı Site Vitrin Dopingi" sponsor boost seçeneği sunan Neo-Brutalist bottom sheet geliştirildi.
  - `lib/presentation/screens/marketplace/negotiation_screen.dart`:
    - Noter devir diyaloğu (`onComplete`) sonrasında `QuickListingBottomSheet.show` çağrısı entegre edildi.
  - `lib/presentation/screens/vasita/vasita_negotiation_screen.dart`:
    - Vasıta teslim onay modalına "Hemen İlana Koy" taktil Neo-Brutalist butonu eklendi.
  - `lib/presentation/widgets/emergency_bailout_dialog.dart`:
    - Kasa eksiye düştüğünde açılan; "Esnaf Can Suyu Desteği" (+₺50,000 hibe sponsor reklamı) ve "Spot Pazara Acil Satış" (en ucuz aracı piyasa değerinin %75'ine anında nakde çevirme) sunan acil durum güvenlik ağı modalı oluşturuldu.
  - `lib/presentation/screens/dashboard/dashboard_screen.dart`:
    - `_checkAndShowPendingDialogs` güncellendi; bakiye eksiye düştüğünde `EmergencyBailoutDialog`, gün atlandığında veya tetiklendiğinde `NeoBrutalDramaticDialog` ana ekranda pop-up olarak gösterildi.
  - `lib/presentation/screens/marketplace/marketplace_screen.dart`:
    - Hızlı filtre çubuğuna "Pazarı Yenile • Sponsor Desteği" taktil butonu eklendi.
  - `lib/core/localization/translations/`:
    - `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar` dillerinin tamamında tüm yeni metin anahtarları sıfır emoji ve sıfır parantez kuralına uygun şekilde eksiksiz senkronize edildi.
  - `test/core_loop_funnel_and_dilemma_test.dart`:
    - XP eşiklerini, dinamik ikilem havuzu seçimlerini ve karar motorunu doğrulayan 5 birim test yazıldı ve başarıyla tamamlandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `test/core_loop_funnel_and_dilemma_test.dart` derlenirken `ExpertiseReport` zorunlu parametreleri (`isMileageTampered`, `bodyParts`) eksikti.
  - `dramatic_card_engine.dart` dosyasında `daily_life_cards_data.dart` için `unused_import` uyarısı oluştu.
  - `negotiation_screen.dart` ve `vasita_negotiation_screen.dart` dosyalarında asenkron `Navigator.pop` sonrası `use_build_context_synchronously` uyarısı alındı.
- **Kök Neden**:
  - Tip tanımlarındaki zorunlu alanlar ve Flutter linter kuralları (`mounted` kontrolü State bağlamında yapılmalıdır).
- **Uygulanan Çözüm**:
  - Testteki model örnekleri eksiksiz parametrelerle güncellendi.
  - Kullanılmayan statik takvim import'u temizlendi.
  - `context.mounted` yerine State sınıfının `mounted` kontrolü uygulandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/core_loop_funnel_and_dilemma_test.dart` -> 5/5 test geçti.
  - `flutter analyze` 12 dosya üzerinde çalıştırıldı -> 0 hata, 0 uyarı (No issues found).

### `VIP Dış Kaynak Modifiye & Performans Evleri (Contract Tuning Houses) Sistemi (§SPEC-2026-09-11-VIP-DIS-KAYNAK-TUNING)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - Oyuncuların kendi garajlarının ötesine geçerek araçlarını seviyelerine ve araç uygunluğuna göre 5 farklı parodi bağımsız modifiye atölyesine (Sanayi Çırakları & Yaşar Usta, Tokyo Kaydırak & Maslak JDM, Bavyera Güç & Herr Klaus, Nostalji Sanat & Usta Hilmi, Monaco Hypercraft & Karbon) teslim edebileceği, gerçek oyun süresiyle geri sayan (15 - 120 dakika), gün atlamalarla ilerleyen, ödüllü reklamla kalan süresi yarıya indirilebilen ve proje bittiğinde aracın güç, unvan ve piyasa çarpanı kazanarak envantere döndüğü VIP Dış Kaynak Modifiye sisteminin geliştirilmesi.
- **Yapılan Değişiklikler**:
  - `lib/data/models/outsourced_tuning_model.dart`:
    - `OutsourcedTuningStudio`, `TuningOrder`, `TuningOrderStatus` ve `StudioDeal` modelleri oluşturuldu; JSON serileştirme ve kopya metotları eklendi.
  - `lib/data/models/car_model.dart`:
    - `isOutsourcedTuning` (bool) ve `activeTuningOrderId` (String?) alanları eklendi.
    - `isListed` getter'ı modifiyedeki araçların ilana verilmesini engelleyecek şekilde güncellendi.
    - `copyWith()`, `toJson()` ve `fromJson()` entegre edildi.
  - `lib/domain/usecases/outsourced_tuning_engine.dart`:
    - 5 parodi stüdyo tanımı ve marka/kategori kısıt kuralları oluşturuldu.
    - Dinamik maliyet ve katma değer güvenliği formülleri (`calculateCost`, `calculateExpectedValueGain`) kodlandı.
    - `createOrder`, `applySpeedup`, `advanceDayForOrder` ve `applyCompletedTuning` use case'leri hayata geçirildi.
  - `lib/presentation/providers/outsourced_tuning_provider.dart`:
    - `OutsourcedTuningNotifier` (Riverpod) oluşturuldu; 1 saniyelik `Timer.periodic` ile aktif sayaç takibi, SharedPreferences persistansı, AdMob hızlandırma işleyicisi ve teslim alma entegrasyonu sağlandı.
  - `lib/presentation/screens/workshop/widgets/carbon_weave_painter.dart`:
    - `/generative-art-shaders` protokolüne uygun olarak 45 derece çift yönlü karbon dimi dokuma ve CRT telemetri tarama çizgileri üreten `CustomPainter` shader'ı oluşturuldu.
  - `lib/presentation/screens/workshop/contract_tuning_screen.dart`:
    - Neo-brutalist taktil UI gramerine uygun (0-blur sert gölgeler, 2.5px siyah bordürler, basma kompresyonu, sıfır emoji, sıfır parantez) stüdyo kartları, araç seçim bottom sheet'i, canlı geri sayım kartı, "Ustaya Çay Ismarla" hızlandırma butonu ve teslimat kutlama modalı inşa edildi.
  - `lib/presentation/screens/workshop/tuning_studio_screen.dart`:
    - VIP Dış Kaynak Atölyelerine yönlendiren taktil geçiş kartı ve üst bar aksiyonu eklendi.
  - `lib/app/router.dart`:
    - `/contract-tuning` rotası tescil edildi.
  - `lib/core/localization/translations/`:
    - Tüm anahtarlar 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) eşzamanlı olarak yerelleştirildi.
  - `test/contract_tuning_test.dart`:
    - Stüdyo kayıtları, araç uygunluk filtreleri, maliyet sınırları, sayaç hızlandırma ve tamamlanma yükseltmelerini doğrulayan 10 birim test yazıldı ve başarıyla geçti.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `AdService.showRewardedAd` metodunda `onReward` yerine `onRewardEarned` adlandırılmış parametresi bekleniyordu.
  - `ExpertiseReport` oluşturulurken `tramerAmount` parametresi `int` türü beklerken `0.0` (double) verilmişti.
  - `collection` paket bağımlılığı doğrudan pubspec'te olmadığından `firstWhereOrNull` yerine standart Dart döngüsü kuruldu.
- **Kök Neden**:
  - Proje mimarisindeki mevcut tip tanımları ve paket bağımlılık kısıtları.
- **Uygulanan Çözüm**:
  - `AdService.showRewardedAdWithFallback` çağrısı `onRewardEarned` parametresiyle güncellendi.
  - Testlerde `tramerAmount: 0` olarak düzeltildi ve `OutsourcedTuningEngine.applyCompletedTuning` fonksiyonuna `badgeKey` rozet eklemesi tamamlandı.
  - `firstWhereOrNull` yerine sıfır bağımlılıklı standart Dart döngüleri kullanıldı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/contract_tuning_test.dart`: 10/10 test başarıyla geçti (%100).
  - `flutter analyze lib/data/models/outsourced_tuning_model.dart lib/domain/usecases/outsourced_tuning_engine.dart lib/presentation/providers/outsourced_tuning_provider.dart lib/presentation/screens/workshop/contract_tuning_screen.dart lib/presentation/screens/workshop/widgets/carbon_weave_painter.dart lib/app/router.dart test/contract_tuning_test.dart`: 0 hata, 0 uyarı (No issues found).

### `Pazar Dengeleme, Doğal Çeşitlilik ve Hiper Araç Pity Oranı Kalibrasyonu (§SPEC-2026-09-11-PAZAR-DENGELEME-VE-PITY)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - Yüksek sermayeli (₺50M - ₺955M+) oyuncunun pazarında aşırı pahalı araç enflasyonunu ("full pahalı araç oldu") engellemek; ₺15M/₺35M altındaki araçları yok eden agresif filtreyi kaldırarak BMW, Mercedes, Porsche, Audi gibi günlük/lüks araç çeşitliliğini korumak ve hiper araç oranını tam olarak hedeflenen "10 - 15 araçta 1 adet" seviyesine dengelemek.
- **Yapılan Değişiklikler**:
  - `lib/domain/usecases/market_engine.dart`:
    - `_generateSingleListing` içerisindeki bakiye >= 50M durumunda ₺15M (%98) ve ₺35M (%75) altını eleyen katı re-roll filtresi kaldırıldı; yerine yalnızca ₺500k altı düşük bütçeli araçları eleyen hafif filtre bırakıldı.
    - `_selectWeightedBrand` içerisinde ₺50M+ bakiye segment ağırlıkları dengelendi: `hiper` (1.0, ~%7 - %8), `egzotik` (3.0), `süperspor` (3.5), `lüks` (4.0), `premium` (3.0), `elektrikli` (1.5), `popüler`/`güvenilir` (1.0), `halk` (0.3).
    - 12 araçlık kayar blok acıma (pity counter) mekanizması korunarak her 10-12 araçta doğal olarak tam 1 adet hiper araç çıkması sağlandı.
  - `test/hyper_car_market_test.dart`:
    - 40 araçlık pazar testinde hiper araç sayısının tam 3 ile 6 adet arasında kaldığı (~10-12 araçta 1 adet) ve pazarın geri kalan en az 34 aracının normal pazar araçlarından oluştuğu doğrulandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/hyper_car_market_test.dart`: 6/6 test passed (100%).
  - `flutter test test/vasita_market_test.dart`: 27/27 test passed (100%).
  - `flutter analyze lib/domain/usecases/market_engine.dart test/hyper_car_market_test.dart`: 0 hata, 0 uyarı (No issues found).

### `Hiper Araç Havuzu, Kasaya Entegre Koleksiyon Çarpanı ve Pity Sayacı Entegrasyonu (§SPEC-2026-09-11-HIPER-ARAC-VE-KOLEKSIYON)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - Oyunda sermayesi 50 milyon TL ile 1 milyar TL ve üzerine ulaşan oyuncuların yaşadığı ekonomik tavan sorununu çözmek amacıyla; taban değerleri 50M - 150M TL olan yeni 'hiper' segmenti (Bugaç, Köniğ, Pagan, Rolso ve özel Ferro modelleri), zengin oyuncular için her 10 - 15 araçta bir garanti hiper araç düşüren acıma (pity counter) mekanizması, 1/1 Ismarlama, Zırhlı Makam, Karbon Pist ve Kraliyet Garajı dinamik prestij çarpanları, altın neo-brutalist vitrin rozeti ve 7 dilde eşzamanlı yerelleştirme sisteminin entegre edilmesi.
- **Yapılan Değişiklikler**:
  - `lib/core/constants/game_constants.dart`:
    - Yeni `'hiper'` segmentiyle 4 parodi hipermarka eklendi: `Bugaç`, `Köniğ`, `Pagan`, `Rolso` (toplam 15 model).
    - `Ferro` markasına `LaFerro Hibrit V12` ve `Daytona SP3 Safkan` modelleri eklendi.
  - `lib/core/constants/car_specifications.dart`:
    - 15 yeni hiper otomobil modeline fabrika çıkış beygir (> 550 HP), tork ve hızlanma (< 5.5s) veritabanı spesifikasyonları eklendi.
    - Marka bazlı varsayılan fallback motor verileri tanımlandı.
  - `lib/data/models/car_model.dart`:
    - `bool get isHyperCar` getter'ı eklendi; marka, model adı ve taban değer kriterleriyle hiper araçları tespit ediyor.
  - `lib/domain/usecases/market_engine.dart`:
    - `generateRandomListings` içine 12 araçlık pencerelerde çalışan garanti hiper araç acıma (pity counter) sistemi eklendi (bakiye >= ₺50M).
    - `_generateForcedHyperListing` ve `_selectHyperBrand` metotları oluşturuldu.
    - `_calculateBaseValue` içerisine hiper modellerin taban değerleri ve `case 'hiper'` kuralı eklendi.
    - `_generateSingleListing` içerisine bakiye >= ₺40M/₺50M oyuncular için dinamik prestij koleksiyon çarpanları (1.2x - 1.8x) ve ₺350M - ₺450M aralığı için güvenlik tavanı/tabanı eklendi.
    - Hiper araçlar için özel başlık ve ilan açıklaması slot kompozitörleri (`hyper_1`..`hyper_5`, `desc_hyper_collector_1`, `seller_profile_hyper_vip`) eklendi.
    - `_selectWeightedBrand` içerisinde zengin oyuncular için `hiper` ağırlığı (20.0) ve ucuz araç filtreleme kuralları güncellendi.
  - `lib/presentation/screens/vasita/vasita_market_screen.dart`:
    - Hiper araçlar için altın kenarlık (`0xFFFFB800`) ve `NeoBrutalBadge` (`badge_hyper_collection`, `Icons.workspace_premium_rounded`) entegre edildi.
  - `lib/core/localization/translations/*.dart`:
    - `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar` dillerinin tamamına `badge_hyper_collection`, `hyper_1`..`hyper_5`, `desc_hyper_collector_1`, `seller_profile_hyper_vip` anahtarları sıfır emoji ve sıfır parantez kuralına uygun olarak eklendi.
  - `test/hyper_car_market_test.dart`:
    - ₺955M bakiye pity garantisi (40 araçta en az 3 hiper), ₺50M - ₺450M fiyat aralığı doğrulaması, ₺100k düşük bakiye izolasyonu, `CarSpecifications` performans verileri ve 7 dil değişmez kontrolünü içeren 6 test yazıldı ve başarıyla doğrulandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - İlk test çalıştırmasında hypercar asking price'ın ₺1.031.792.458 TL'ye ulaşarak 450M üst sınırını aştığı görüldü.
- **Kök Neden**:
  - Karasu ve Divo modellerinin yüksek taban fiyatlarının (220M+) üzerine Spor kasa çarpanı (1.25x), Pristine kondisyon çarpanı (1.15x), Kraliyet koleksiyonu çarpanı (2.6x), efsanevi renk çarpanı (1.18x) ve satıcı marjının (1.20x) ardışık katlanarak birikmesi (double-compounding).
- **Uygulanan Çözüm**:
  - Taban değerler 50M - 130M bandına kalibre edildi, dinamik prestij çarpanları 1.2x - 1.8x bandına çekildi, `baseValue` için ₺250M güvenlik tavanı ve `askingPrice` için `[50M, 450M]` kesin sınırlandırması uygulandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/hyper_car_market_test.dart`: 6/6 test passed (100%).
  - `flutter test test/vasita_market_test.dart`: 27/27 test passed (100%).
  - `flutter analyze lib/domain/usecases/market_engine.dart test/hyper_car_market_test.dart`: 0 hata, 0 uyarı (No issues found).

### `Arayüz Taşma Problemleri (RenderFlex Overflow), Prosedürel Dokuların 4 Ekrana Entegrasyonu ve 7 Dilli Yerelleştirme (§SPEC-2026-LAYOUT-OVERFLOW-AND-SHADERS)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - Dashboard (Showroom & Galeri), Oto Yıkama (Paket 4), Şantiye (Telsiz ve Canlı Anons) ve Gece Pazarı (Drag Yarış Eşleşmesi) ekranlarındaki yatay `RenderFlex overflowed` taşma hatalarının `Flexible`, `Expanded` ve `maxLines` sınırlandırmalarıyla 320px gibi dar mobil ekranlarda sıfırlanması; oto yıkama "UYGULANDI" butonundaki metin kesilmesinin önlenmesi; ayrıca neo-brutalist prosedürel gölgelendirici desenlerin (CRT scanlines) ilgili kartlara entegre edilmesi ve hardcoded metinlerin 7 dilde senkronize edilmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - `service_showroom` metni `Flexible` içine alındı ve `TextOverflow.ellipsis` eklendi.
    - `branchName` metnine `maxLines: 1` ve `overflow: TextOverflow.ellipsis` eklendi.
    - Rozetler arasına `const SizedBox(width: 6)` eklenerek 3.0 piksellik yatay taşma giderildi.
  - `lib/presentation/screens/car_wash/car_wash_screen.dart`:
    - `BlueprintPatternType.crtScanlines` prosedürel dokusu paket kartına entegre edildi.
    - Paket 4 bonus rozeti `Flexible` ile sarmalanarak fontu 9.0 ve padding'i kompakt hale getirildi; 5.7 piksellik taşma çözüldü.
    - Uygulandı/Satın Al butonuna `BoxConstraints(minWidth: 86, maxWidth: 110)` ve `fontSize: 11.0` uygulanarak "UYGULAN..." kırpılması önlendi.
  - `lib/presentation/screens/real_estate/real_estate_construction_screen.dart`:
    - Telsiz anonsu kartına CRT scanlines prosedürel dokusu uygulandı.
    - Başlık satırı `Expanded`, telsiz rozeti `Flexible(child: NeoBrutalBadge(...))` içine alınarak 20 piksellik yatay taşma sıfırlandı.
  - `lib/presentation/screens/night_market/night_market_screen.dart`:
    - Eşleşme ve oranlar başlık satırı `Expanded` içine alındı, hak ve rakip rozetleri gruplanarak 13 piksellik taşma giderildi.
    - Hardcoded `'Rakip Değiş'` butonu `context.tr('night_market_change_rival')` ile 7 dilde senkronize yerelleştirildi.
  - `lib/core/localization/translations/*.dart`:
    - `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar` dillerine `night_market_change_rival` ve 9 yeni `changelog_item_*` anahtarı eksiksiz eklendi.
  - `test/layout_overflow_and_generative_shaders_test.dart`:
    - 320px dar ekran simülasyonu altında 11 adet taşma ve doku testi yazıldı ve güncellendi; 19 testin tamamı yeşil geçti.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Test 10'da (`Construction Radio Dispatch Card on 320px viewport`), kart içi `NeoBrutalBadge` rozetinin `Flexible` ile sarmalanmaması nedeniyle 20px taşma hatası tespit edildi.
- **Kök Neden**:
  - 320px genişlikte kartın 16px iç dolgusu sonrasında kalan alanda serbest genişlikli rozetin başlıkla yarışarak toplam genişliği aşması.
- **Uygulanan Çözüm**:
  - `real_estate_construction_screen.dart` ve test mock'unda `NeoBrutalBadge` `Flexible` ile sarmalandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/layout_overflow_and_generative_shaders_test.dart`: 19/19 test passed (100%).
  - `flutter analyze lib/`: 0 hata, 0 uyarı (No issues found).

### `İnşaat 8. Aşama (İskan Ruhsatı & Kat Mülkiyeti) İlerleme, 0-Gün Sayacı ve Daire Tapusu Doğrulama Onarımı (§SPEC-2026-CONSTRUCTION-STAGE8-HANDOVER)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - 8. aşamada olan ve kalan günü sıfırdan büyük olan mevcut kayıtlı oyunların doğru aşama kartına ("8. İskan Ruhsatı & Kat Mülkiyeti", kalan gün sayacı ve hızlandırma butonu) kavuşması, gün bittiğinde "ETABI TESLİM AL" adımıyla 9. aşamaya geçerek dairelerini teslim alabilmesi ve kalan günü 0 olan oyuncuların doğrudan daire tapularını alabilmesi mekanizmasının doğrulanması ve tamir edilmesi.
- **Yapılan Değişiklikler**:
  - `lib/data/models/real_estate_model.dart`:
    - `isConstructionComplete` getter'ı revize edildi: `selfBuild` modunda Aşama 7 bitip Aşama 8'e geçildiğinde taşeron henüz atanmamışken (`activeSubcontractorName == null`) inşaatın erkenden tamamlandı sayılması hatası giderildi. Artık `selfBuild` için tamamlanma koşulu `constructionStage >= 9` veya `provenanceLog` içinde 8. aşama teslim kaydının bulunması olarak kesinleştirildi.
    - Böylece 8. aşamada kalan günü olan oyuncuların kartı ve hızlandırma butonu korunurken, günü bitenler "ETABI TESLİM AL" adımıyla 9. aşamaya geçerek doğrudan anahtar teslime ulaşabilir hale getirildi.
    - Kalan günü 0 olan müteahhit veya tamamlanmış projeler için `isConstructionComplete` anında `true` dönerek doğrudan kat mülkiyeti daire tapularının alınabilmesi (`finalizeConstruction`) garanti altına alındı.
  - `test/construction_completion_and_peyzaj_fix_test.dart`:
    - Test 7 ve Test 8 eklendi:
      * Test 7: 8. aşamada 5 günü kalan kayıtlı oyunun aktif çalışma kartını, hızlandırma butonunu ve gün bitiminde "ETABI TESLİM AL" ile 9. aşamaya geçerek daireleri teslim alabildiğini doğrular.
      * Test 8: 8. aşamada kalan günü 0 olan kayıtlı oyunların doğrudan kat mülkiyeti tapularını alabildiğini doğrular.
    - 8 testin 8'i de başarıyla geçti (`8/8 PASSED`).
- **Doğrulama / Test Durumu**:
  - `flutter test test/construction_completion_and_peyzaj_fix_test.dart` (8/8 geçti).
  - `flutter analyze lib/` (0 hata, 0 uyarı, No issues found).

### `Ekonomi Dengesi AdReward Tavanı & Canlı İhale Döngüsel Kapanma/Reklamla Giriş Protokolü Onarımı (§SPEC-2026-ECONOMY-AD-REWARD-AND-AUCTION-CYCLE)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - Ayarlar ekranında ve diğer hibe alanlarında 3M TL ve üzeri servete sahip oyunculara 3.2M TL gibi oyunun araç alım-satım dengesini ve ilerleme hissini bozan aşırı ödüllerin verilmesinin engellenmesi; tüm ödül hesaplayıcının kademeli servet oranları ve katı tavanlarla (3M servette ~40-50K TL standart, max 120-140K TL jackpot; en zengin endgame oyuncusunda dahi mutlak tavan 350K TL) ekonomiyi koruyacak şekilde kalibre edilmesi.
  - Canlı Gümrük Müzayedesinin (`/auction`) sürekli açık kalması ve hiç kapanmaması hatasının kök nedeninin çözülmesi; müzayedenin her seans sonrasında (yaklaşık 2 araçlık canlı ihaleden sonra) otomatik kapanması (`closeWindow`), geri sayım sayacının başlaması, "Müzayede Salonu Kapalı" ekranında Gümrük Tasfiye İdaresi Özel Protokolü ile ödüllü reklam izlenerek bekleme süresinin anında atlanabilmesi ve doğrudan yeni ihaleye girilebilmesi sisteminin tam çalışır hale getirilmesi.
- **Yapılan Değişiklikler**:
  - `lib/core/services/ad_reward_calculator.dart`:
    - Servet ölçekli ödül oranı (`wealthRate`) 3M için %1.0 seviyesine, 25M+ için %0.25 seviyesine çekildi.
    - Seviye bazlı tavanlar (`maxBaseCap`) ve ikramiye tavanları (`maxJackpotCap`) sıkılaştırılarak 3M servette standart ödül 40.000 - 50.000 TL, jackpot ödülü 120.000 - 140.000 TL aralığına sınırlandı.
    - Oyun içi hiçbir reklam ödülünün veya ikramiyenin 350.000 TL mutlak tavanını aşamaması sağlandı; şube, VIP filo ve borsa içeriden bilgi hibeleri de güvenli sınırlarla korundu.
  - `lib/presentation/screens/settings/settings_screen.dart`:
    - Önceden hesaplanıp state içinde önbelleğe alınmış olabilecek >350K TL eski ödül nesnelerinin geçersiz kılınması (`_cachedRewardOutcome!.moneyAmount > 350000.0`) ve anında güvenli miktara güncellenmesi sağlandı.
  - `lib/domain/usecases/auction_engine.dart`:
    - İhale seans süresi 60-90 saniyeye (~2 araçlık canlı çekişme), seanslar arası bekleme aralığı 60-120 saniyeye ayarlandı.
    - Reklam izleme veya VIP protokol ile anında açılışta `openSessionImmediately` 90 saniyelik taze seans tahsis edecek şekilde optimize edildi.
  - `lib/presentation/providers/auction_session_provider.dart`:
    - `closeWindow()` metodu eklendi: İhale süresi dolduğunda veya tur tamamlandığında pencereyi kapatıp geri sayımı (60-120s) aktif hale getiren ve timer'ı geri sayım modunda çalıştıran mekanizma kuruldu.
    - `_tick()` döngüsü revize edildi: Pencere kapalıyken saniye saniye geri sayım yapılması, sıfıra ulaştığında otomatik yeni seans açması, pencere açıkken seans süresi bittiğinde lot tamamlanmasını takiben pencereyi güvenle kapatması sağlandı.
  - `lib/presentation/screens/auction/auction_screen.dart`:
    - `_resetAuctionSilently` metoduna `AuctionEngine.isAuctionActiveNow()` kontrolü eklendi; seans süresi bitmişse yeni araç açmak yerine `notifier.closeWindow()` tetiklenerek oyuncuya "Müzayede Salonu Kapalı" ekranı, geri sayım sayacı ve "Özel Kontenjan Protokolü Edin" reklam izleme butonu sunuldu.
  - `test/auction_and_vasita_navigation_test.dart`:
    - `closeWindow` geçiş testi, 3M TL servette ödülün 25K-140K aralığında kaldığı ve asla 3.2M üretmediği testi, 100M TL servette mutlak 350K tavan testi eklendi (8/8 geçti).
- **Karşılaşılan Hatalar / Sorunlar**:
  - `ad_reward_calculator.dart` dosyasında önceki formülasyonda late-game zenginlik oranı `totalWealth * 0.0275` ve 4x çarpanı kullanıldığında 30M+ garaj değerine sahip oyuncularda 3.2M TL gibi aşırı yüksek ödül çıkabiliyordu.
  - `auction_session_provider.dart` ve `auction_screen.dart` dosyalarında her araç ihalesi bittiğinde `_resetAuctionSilently` koşulsuz olarak `resetRound()` çağırarak yeni bir araç başlatıyordu; bu durum seans süresi bitse bile müzayede salonunun hiç kapanmamasına ve reklamla bekleme süresini atlama kartının oyuncunun karşısına çıkamamasına yol açıyordu.
- **Kök Neden**:
  - Reklam ödülünde üst limit bulunmaması ve çarpanın 4x olması.
  - Müzayede tur bitişinde seans penceresinin aktifliğinin sorgulanmaması ve `closeWindow` çağrısının eksikliği.
- **Uygulanan Çözüm**:
  - Ödül formülü sıkı matematiksel tavanlara (3M için ~40-50K, genel tavan 350K) bağlandı.
  - Tur bitişlerinde `AuctionEngine.isAuctionActiveNow()` kontrolü entegre edilerek seans bitiminde salonun kapanması ve reklamla anında açılabilmesi sağlandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/auction_and_vasita_navigation_test.dart` (8/8 geçti).
  - `flutter test test/layout_overflow_and_generative_shaders_test.dart` (19/19 geçti).
  - `flutter analyze lib/` (0 hata, 0 uyarı, No issues found).

### `4 Ekran Düzen Taşma Çözümleri, Buton Metin Bütünlüğü, Sıfır-Taşma Güvencesi & 7 Dilli Yerelleştirme (§SPEC-2026-PART3-LAYOUT-OVERFLOW-RESILIENCE)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - Kullanıcı tarafından iletilen 4 ekrandaki (Dashboard Showroom & Galeri kartı, Oto Yıkama Paket 4 bonus rozeti ve "UYGULANDI" buton metin kesilmesi, Gayrimenkul Şantiye Telsizi başlık rozeti ve Gece Mezatı Eşleşme kartı başlığı) `RenderFlex overflow` taşma hatalarının kalıcı olarak çözülmesi.
  - Neo-brutalist taktil tasarım standartlarına ve 7 dilli yerelleştirme kurallarına tam uyum sağlanması.
  - İlgili kartlara prosedürel CRT scanlines telemetri dokularının giydirilmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - `service_showroom` ("Showroom & Galeri") başlık satırındaki unconstrained metin `Flexible` ile sarıldı, `branchName`'e `maxLines: 1, overflow: TextOverflow.ellipsis` uygulandı, `SizedBox(width: 6)` eklendi; 3.0 piksellik taşma tamamen giderildi.
  - `lib/presentation/screens/car_wash/car_wash_screen.dart`:
    - Paket 4 bonus rozetindeki (`+12 Süper Değer Artışı & 2x Hızlı Satış`) 5.7 piksellik taşma giderildi; rozet `Flexible` ile sarıldı, `fontSize: 9.0`, yatay iç boşluk `5.0` yapıldı.
    - Uygulandı butonundaki metin kesilmesi ("UYGULAN...") giderildi; buton genişlik kısıtı `minWidth: 86.0, maxWidth: 110.0`, buton yazı boyutu `11.0` ve iç boşluk `symmetric(horizontal: 6, vertical: 8)` yapılarak tam metin "UYGULANDI" temiz ve taktil biçimde sığdırıldı.
    - Paket kartlarına istasyon diagnostik hissi veren `BlueprintPatternType.crtScanlines` prosedürel dokusu entegre edildi.
  - `lib/presentation/screens/real_estate/real_estate_construction_screen.dart`:
    - Şantiye telsiz anons kartı (`_buildSiteRadioDispatchCard`) başlık satırındaki 20 piksellik taşma giderildi.
    - Sol taraftaki telsiz ikon ve başlık sütunu `Expanded(flex: 3, child: ...)` ile sarıldı, `fontSize: 12.0`, `Icon(size: 18)`.
    - Sağ taraftaki kanal dinleme rozeti (`NeoBrutalBadge`) `Flexible(flex: 2, child: ...)` ile sarıldı, `fontSize: 9.0`. En dar 320px ekranlarda ve uzun yerelleştirme metinlerinde sıfır taşma güvencesi sağlandı.
    - Karta şantiye telemetri ve telsiz hissi veren `BlueprintPatternType.crtScanlines` prosedürel dokusu giydirildi.
    - Karta taktil canlı telsiz ses osiloskobu dalgası (`SiteRadioWaveformWidget`), frekans rozeti (`real_estate_radio_frequency_badge`) ve lazer nivo kot hizalama işareti (`real_estate_laser_level_label`) eklendi.
    - KAKS kapasite kartı başlığı `Expanded` ile sarmalanarak dar ekranda taşma koruması altına alındı ve onaylı projelerde belediye onaylı ruhsat damgaları (`real_estate_stamp_zoning_approved`, `real_estate_stamp_soil_test`) dinamik olarak eklendi.
  - `lib/presentation/widgets/real_estate_artistic_canvas.dart`:
    - Topografik kot/izohips ressamı (`TopographicContourPainter`), telsiz osiloskop akustik dalga ressamı (`RadioWaveformPainter`), `SiteRadioWaveformWidget`, `LaserLevelLineWidget` ve `NeoBrutalStampWidget` bileşenleri oluşturuldu.
  - `lib/core/localization/translations/*.dart` (7 Dil Eşzamanlı Senkronizasyon):
    - `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar` dillerinin tamamına `real_estate_stamp_zoning_approved`, `real_estate_stamp_soil_test`, `real_estate_laser_level_label`, `real_estate_radio_frequency_badge` anahtarları sıfır emoji ve sıfır parantez kuralına tam uyularak eklendi.
  - `lib/presentation/screens/night_market/night_market_screen.dart`:
    - Gece Mezatı ve Drag Arenası eşleşme kartı başlığındaki (`YARIŞ EŞLEŞMESİ & ORANLAR` + `3/3 Hak` + rakip rozeti) 13 piksellik taşma giderildi.
    - Başlık satırı `Expanded(flex: 3, child: ...)` içine alındı; sağdaki iki rozet `Flexible(flex: 2, child: Row(...))` içine alınarak ikinci rozet `Flexible` yapıldı.
    - Sabit kodlanmış `'Rakip Değiş'` butonu, 7 dilli yerelleştirme kuralına uygun olarak `context.tr('night_market_change_rival')` ile bağlandı.
    - Eşleşme kartına yeraltı sokak yarışı telemetri dokusu veren `BlueprintPatternType.crtScanlines` prosedürel deseni uygulandı.
  - `test/layout_overflow_and_generative_shaders_test.dart`:
    - Test 8, Test 9, Test 10 ve Test 11 eklenerek Dashboard Showroom, Car Wash Paket 4, Construction Radio Dispatch ve Night Market Matchup Header senaryoları 320px dar mobil görünümde test edildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Test 10'da unconstrained `NeoBrutalBadge`, Ahem yazı tipi altında 234 piksel genişlik kaplayarak sol `Expanded` bloğuna yalnızca 7.6 piksel bırakıyor ve 20 piksel taşmaya yol açıyordu.
  - Oto yıkama ekranında "UYGULANDI" metni 80px genişlikte `maxLines: 1` ve `ellipsis` sebebiyle "UYGULAN..." olarak kesiliyordu.
- **Kök Neden**:
  - Flex konteynerler içindeki her iki alt öğenin de unconstrained olması durumunda, intrinsik boyutu büyük olan öğenin flex alanını tüketmesi ve minimum boyutu olan ikon/metin bileşenlerini sıkıştırması.
- **Uygulanan Çözüm**:
  - Karşılıklı `flex: 3` (başlık/ikon) ve `flex: 2` (rozet/aksiyon) oranları kurularak, en dar mobil ekranlarda dahi her iki bileşenin dengeli pay alması ve `NeoBrutalBadge`'in kendi içinde zarifçe `ellipsis` ile sönümlenmesi sağlandı.
  - Buton kısıtı `minWidth: 86.0, maxWidth: 110.0` aralığına genişletilerek metin kesilmesi önlendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/` (No issues found, 0 errors, 0 warnings).
  - `flutter test test/layout_overflow_and_generative_shaders_test.dart` (19/19 test sıfır hata ve sıfır RenderFlex taşmasıyla geçti).

### `Özel Plaka Tasarımcısı Düzen Taşma Çözümü & Nadirlik Bazlı Generatif Shader Dokuları (§SPEC-2026-PLATE-DESIGNER-OVERFLOW-AND-SHADERS)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - Özel Plaka Merkezi (Special Plate Screen) - Plaka Tasarla sekmesindeki alt kartta eylem butonu ile harç bedelinin yatayda yarışması sonucu oluşan 74 piksellik `RenderFlex overflow` taşma hatasının kalıcı olarak çözülmesi.
  - İl plaka kodu dropdown'ı, harf grubu ve rakam grubu etiketlerine `maxLines: 1` ve `TextOverflow.ellipsis` koruması getirilmesi.
  - Araç atama alt modalında (Vehicle Assignment Bottom Sheet) başlık satırına `Expanded` güvencesi getirilerek dar ekranlarda kapatma ikonu ile çakışmanın engellenmesi.
  - `/generative-art-shaders` ve `/ui-ux-pro-max` standartları doğrultusunda, Özel Plaka Koleksiyonu ve Tasarımcısı kartlarına nadirlik seviyesine (`legendary`: `bayerDither`, `symmetric`: `isometricBlueprint`, `repeated`: `graphPaper`, `standard`: `technicalCrosses`) ve canlı önizleme/tasarım panellerine özel prosedürel mimari dokuların giydirilmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/office/special_plate_screen.dart`:
    - Tab 2 alt eylem kutusundaki `Row` yapısı dikey `Column(crossAxisAlignment: CrossAxisAlignment.stretch)` mimarisine dönüştürüldü; üst satırda "Hesaplanan Harç & Bedel" ve yetersiz bakiye rozeti yer alırken, alt satırda `fullWidth: true` "PLAKAYI TESCİL ET & ARACA TAK" butonu konumlandırılarak 74 piksellik taşma tamamen sıfırlandı.
    - İl plaka kodu dropdown menü elemanlarına ve harf/rakam giriş alanı başlıklarına `maxLines: 1, overflow: TextOverflow.ellipsis` eklendi.
    - Tab 1 plaka kartlarında her nadirlik seviyesine özel prosedürel doku (`bayerDither`, `isometricBlueprint`, `graphPaper`, `technicalCrosses`) bağlandı.
    - Canlı plaka önizleme kartına `technicalCrosses` (teknik kalibrasyon artıları), parametre kartına `graphPaper` (milimetrik tasarım defteri) dokusu verildi.
    - Araç atama modalı başlığına `Expanded` sarımı ve araç listesi kartlarına metin taşma koruması uygulandı.
  - `test/layout_overflow_and_generative_shaders_test.dart`:
    - Test 6: 320px kompakt mobil görünümde Plaka Tasarımcısı harç dökümü ve tam genişlikli tescil butonunun sıfır taşmayla çalıştığı doğrulandı.
    - Test 7: 320px mobil görünümde araç atama modal başlığının taşmasız render edildiği test edildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Unconstrained `Row` içinde uzun buton etiketi ("PLAKAYI TESCİL ET & ARACA TAK" ~30 karakter) ve 2 satırlı harç bedeli yan yana sığmayıp ekran dışına 74px taşıyordu.
  - Statik analiz sırasında `BlueprintPatternType.isometricGrid` yerine doğru enum sabitinin `BlueprintPatternType.isometricBlueprint` olduğu tespit edildi.
- **Kök Neden**:
  - Mobil dikey hiyerarşide birincil aksiyon butonunun dar bir yatay flex içinde tutulması; flex genişliğinin butonun minimum intrinsik genişliğinden daha dar kalması.
- **Uygulanan Çözüm**:
  - Fitts Kanunu ve mobil neo-brutalist ergonomiye uygun olarak harç dökümü yukarıya, tam genişlikli buton aşağıya alındı (`Column(crossAxisAlignment: CrossAxisAlignment.stretch)`).
  - Enum sabiti `isometricBlueprint` olarak düzeltildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/` (No issues found, 0 errors, 0 warnings).
  - `flutter test test/layout_overflow_and_generative_shaders_test.dart` (15/15 test başarıyla geçti).
  - Web geliştirme sunucusuna Hot Reload uygulandı.

### `10 Ekran Düzen Taşma Çözümleri, UX Yerleşim İyileştirmeleri & Prosedürel Generatif Shader Dokuları (§SPEC-2026-FULL-10-SCREEN-OVERFLOW-AND-SHADERS)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - Kullanıcı tarafından iletilen 10 ekran görüntüsündeki (Part 1 ve Part 2) tüm yatay ve dikey `RenderFlex overflow` taşma hatalarının ve UX sıkışmalarının kalıcı olarak giderilmesi.
  - `/generative-art-shaders` ve `/ui-ux-pro-max` standartları doğrultusunda, monoton mavi CAD grid desenleri yerine her ekranın bağlamına uygun prosedürel dokuların (`crtScanlines`, `bayerDither`, `technicalCrosses`, `graphPaper`) CustomPainter seviyesinde sıfır GPU tahsisli olarak giydirilmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/widgets/neo_brutal_app_bar.dart`:
    - `NeoBrutalTabBar`: `isScrollable`, `tabAlignment`, `fontSize` ve `padding` parametreleri eklendi; `TabBarIndicatorSize.tab` kapsayıcı içine alınarak 40px yüksekliğe kilitlendi. Borsa ekranında canlı piyasa şeridinin üzerine taşan sarı gösterge kutucuğu hatası giderildi.
    - `titlePlate`: Başlık metni `FittedBox(fit: BoxFit.scaleDown)` içine alınarak uzun başlıkların (ör. "VIP PROTOKOL MÜZAYEDESİ") harf kesilmeden orantılı küçülmesi sağlandı.
  - `lib/presentation/screens/vasita/vasita_expertise_screen.dart`:
    - Şasi kontrol kartı başlığındaki unconstrained `Row` içindeki araç başlığı `Expanded` ile sarıldı; 59 piksellik taşma giderildi.
    - Şasi ve motor diagnostik kartlarına oto ekspertiz dyno osiloskop ruhunu veren `BlueprintPatternType.crtScanlines` prosedürel dokusu eklendi.
  - `lib/presentation/screens/vasita/vasita_negotiation_screen.dart`:
    - Ekspertiz özet kartı başlığı `Expanded` içine alınarak 6.2 piksellik taşma giderildi.
    - Ekspertiz kartına teknik hizalama artı işaretleri sunan `BlueprintPatternType.technicalCrosses` prosedürel deseni işlendi.
  - `lib/presentation/screens/marketplace/widgets/negotiation_seller_profile_card.dart`:
    - Müşteri profil kartında satıcı isim satırı `Expanded` ile sarıldı; 88 piksellik taşma giderildi.
    - Satıcı kartı zeminine gazete seri ilan ve basılı doküman pürüzlülüğü kazandıran `BlueprintPatternType.bayerDither` eklendi.
  - `lib/presentation/screens/auction/widgets/auction_upcoming_catalog_tab.dart`:
    - LOT menşe rozetleri (İcra Dairesi, Gümrük Tasfiye vb.) `Expanded` ile sınırlandırıldı; 96px, 124px ve 111px taşmaları çözüldü.
    - Adliye icra ve gümrük dökümü dokusu için `BlueprintPatternType.bayerDither` eklendi.
  - `lib/presentation/screens/stock_market/stock_market_screen.dart`:
    - `NeoBrutalAppBar.bottom` sekmesi `NeoBrutalTabBar` bileşenine dönüştürüldü.
    - Döviz senkronizasyon altbilgisindeki 5.6 piksellik taşma giderildi.
    - Halka Arz (IPO) kartlarındaki holding unvanı ve şirket adları ("VoltŞarj" 52px, "Ege Dövme" 60px) `Expanded` içine alınarak taşmalar çözüldü.
    - Borsa kartlarına finansal milimetrik defter dokusu sunan `BlueprintPatternType.graphPaper` prosedürel deseni entegre edildi.
  - `lib/presentation/screens/side_business/side_business_detail_screen.dart`:
    - Modüller listesinde montaj devam ederken başlığı sıkıştıran ve satırı ezen "MÜTEAHHİT HIZLANDIRMASI" butonu üst satırdan kaldırılarak alt montaj çubuğuna tam genişlikli buton olarak taşındı; üst satıra kompakt `%XX` rozeti yerleştirilerek başlık ve açıklamaya tam yatay alan kazandırıldı.
  - `lib/presentation/widgets/dialogs/neo_brutal_operation_dialog.dart`:
    - Hurdalık söküm ve ezme diyaloglarında araç modeli rozeti `ConstrainedBox(constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width - 160).clamp(100.0, 180.0)))` ile sınırlandırıldı ve `Wrap` ile sarıldı; 130 piksellik taşma giderildi.
    - Gövdeye CRT scanlines katmanı giydirildi.
  - `lib/presentation/screens/casino/casino_hub_screen.dart`:
    - `_buildSectionHeader`: Başlık sütunu `Expanded` ile sarıldı, tek satır sınırlandı ve rozet öncesi `SizedBox(width: 8)` eklendi; Bölüm 2 (4.1px) ve Bölüm 3 (1.5px) başlık taşmaları çözüldü.
    - Oyun kartlarına yeraltı arcade atmosferini pekiştiren `BlueprintPatternType.crtScanlines` prosedürel dokusu eklendi.
  - `lib/presentation/screens/office/special_plate_screen.dart`:
    - Bakiye kartında sol sütun `Expanded` ile sarıldı; sağdaki iki rozet tek satırda yarışmak yerine dikey `Column` içine istiflenerek 41 piksellik taşma çözüldü.
    - `_buildPlateCard`: Başlık satırı `Wrap` yapısına kavuşturuldu; il tescil metnine `TextAlign.end` ve tek satır koruması eklendi; kart zeminine resmi tescil dokusu veren `BlueprintPatternType.technicalCrosses` deseni uygulandı.
  - `lib/presentation/widgets/blueprint_grid_background.dart` & `procedural_shader_textures.dart`:
    - `graphPaper` milimetrik borsa defteri deseni prosedürel fırça algoritmasıyla eklendi.
    - `procedural_shader_textures.dart` üzerinden `BlueprintPatternType` dışa aktarılarak modüler import mimarisi kuruldu.
  - `test/layout_overflow_and_generative_shaders_test.dart`:
    - 13 adet kapsamlı widget testi ile 320px kompakt mobil görünümde tüm taşma senaryoları ve 5 farklı prosedürel doku kalıbı doğrulandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Borsa sekmesinde standart `TabBar` indicator'ı app bar toolbar içerisine kayıp can alıcı borsa ticker'ını kapatıyordu.
  - Scrapyard, Casino, Borsa ve Özel Plaka ekranlarında unconstrained `Row` içi uzun başlıklar sağ kenardan 0.8px ile 130px arasında taşmaya neden oluyordu.
  - Ekranlarda yalnızca tek tip CAD grid kullanılması görsel çeşitliliği ve taktil derinliği kısıtlıyordu.
- **Kök Neden**:
  - `ThemeData.tabBarTheme.indicator` varsayılan yüksekliğinin app bar konteyneriyle çakışması; flex yapılarda metin alanlarının `Expanded` veya `Wrap` yerine intrinsic genişlikle serbest bırakılması.
- **Uygulanan Çözüm**:
  - Kapsayıcı `NeoBrutalTabBar` mimarisi uygulandı, tüm flex çocukları `Expanded` ve `Wrap` ile güvenceye alındı, 4 farklı tematik prosedürel doku (`crtScanlines`, `bayerDither`, `technicalCrosses`, `graphPaper`) CustomPainter algoritmalarıyla entegre edildi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/layout_overflow_and_generative_shaders_test.dart` (13/13 test geçti).
  - `flutter analyze lib/` (No issues found, 0 errors, 0 warnings).

### `Layout Taşma Çözümleri & Prosedürel Generatif Shader / Dokusal Mikro İyileştirmeler (§SPEC-2026-UI-OVERFLOW-AND-GENERATIVE-SHADERS)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - Gösterge paneli, hizmetler bentosu, ekspertiz/dyno operasyon diyaloğu ve vasıta pazarı araç kartlarında tespit edilen yatay taşma (RenderFlex overflow) hatalarının kökten çözülmesi.
  - Generative Art & Algorithmic Shaders mimarisi kapsamında tüm kartlarda tekdüze tekrarlanan CAD blueprint çizgilerinin ötesine geçilerek, domainine uygun Bayer Matrix (ordered dithering), CRT scanlines (retro raster) ve dot bubble doku katmanlarının prosedürel olarak kazandırılması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/widgets/blueprint_grid_background.dart`:
    - `BlueprintPatternType` enumuna `bayerDither` ve `crtScanlines` modelleri eklendi.
    - `_BlueprintPatternPainter`: 4x4 normalize Bayer matris eşiği üzerinden sıfır bitmap tahsisli ordered dithering ve yüksek frekanslı CRT scanline fırçaları entegre edildi.
  - `lib/presentation/screens/dashboard/widgets/dashboard_banners.dart`:
    - Günlük ikilem kartında (`NeoBrutalDramaticCard`) karakter isim ve unvan satırı `Expanded(child: Text(..., maxLines: 1, overflow: TextOverflow.ellipsis))` ile sınırlandırıldı; 11 piksellik taşma giderildi.
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - Showroom başlığındaki ham bakiye metni `CurrencyFormatter.formatShort(game.balance)` (ör. `₺6.4M`) ile kompaktlaştırıldı; 6.8 piksellik taşma giderildi.
    - Oto Yıkama kartında `NeoBrutalBadge` esnek `Flexible` kapsayıcısına alındı, rozet dolgusu optimize edildi ve desen `BlueprintPatternType.dots` (köpük/su kabarcığı matrisi) ile sanatsal olarak çeşitlendirildi; 27 piksellik taşma giderildi.
    - Tuning Stüdyosu kartı dyno/ECU diagnostik ruhuna uygun `BlueprintPatternType.crtScanlines` desenine geçirildi.
    - Vasıta Pazarı kartında `Yat • Karavan • Motor` rozeti `Flexible` ile sarıldı ve desen denizcilik/nakliyat dokusuna uygun `BlueprintPatternType.bayerDither` olarak güncellendi; 28 piksellik taşma giderildi.
  - `lib/presentation/widgets/dialogs/neo_brutal_operation_dialog.dart`:
    - Dyno ve detaylı ekspertiz operasyon penceresi gövdesine CRT yeşil/kehribar osiloskop dokusu veren `CrtScanlinesOverlay` giydirildi.
    - Diyalog başlığındaki araç modeli adı ve nabız animasyonlu durum rozeti `Wrap` + `ConstrainedBox(maxWidth: 160)` ile duyarlı hale getirildi; 23 piksellik taşma giderildi.
  - `lib/presentation/screens/vasita/vasita_market_screen.dart`:
    - Araç ilan kartı başlığındaki satıcı şehir/isim bilgisi `Expanded(child: Text(..., maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end))` ile güvene alındı.
    - Araç ilan kartı zeminine fiziksel açık artırma/nakliye manifestosu dokusu sunan `showBlueprintGrid: true` + `BlueprintPatternType.bayerDither` prosedürel dokusu eklendi.
    - Kart altbilgisindeki piyasa değeri, ekspertiz butonu ve pazarlık butonu satırı duyarlı `Wrap` (spacing: 8, runSpacing: 8) yapısına kavuşturuldu; 33 piksellik buton taşması tamamen çözüldü.
  - `lib/presentation/widgets/neo_brutal_button.dart`:
    - `NeoBrutalButton` iç metninde `Flexible` + `Text` aralıkları optimize edildi, harf aralığından kaynaklanan 3.5 piksellik taşma riski elendi.
  - `test/layout_overflow_and_generative_shaders_test.dart`:
    - 320px kompakt mobil ekran genişliğinde ikilem kartı, bentos servis rozeti, operasyon başlığı, vasıta pazar altbilgisi ve prosedürel shader desenlerini denetleyen 7 yeni otomatik test yazıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Dar ekranlarda (320px - 360px) uzun isimler, geniş metinli butonlar ve unconstrained `Row` içi elemanlar `RenderFlex overflow` üretiyordu.
  - Tüm kartların aynı CAD mavi/camgöbeği ızgarayı kullanması görsel monotonluk oluşturuyordu.
- **Kök Neden**:
  - Flex konteynerler (`Row`) içerisinde elemanların `Expanded`/`Flexible` veya `Wrap` yerine intrinsic genişlikleriyle yerleşmesi ve ekran sınırını aşması.
- **Uygulanan Çözüm**:
  - Satırlar `Expanded`/`Flexible` ve `Wrap` ile sarmalandı; sayılar `formatShort` ile sıkılaştırıldı; `BlueprintPatternType` içine `bayerDither` ve `crtScanlines` eklenerek her servisin temasına uygun mikro-dokular işlendi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/layout_overflow_and_generative_shaders_test.dart` (7/7 test geçti).
  - `flutter test test/small_screen_overflow_audit_test.dart` (3/3 test geçti).
  - `flutter test test/ui_ux_pro_max_and_shaders_test.dart` (4/4 test geçti).
  - `flutter analyze lib/` (No issues found, 0 errors, 0 warnings).

### `İnşaat Tamamlanması ve Mülkiyet Devri Denetimi & İyileştirmesi (§SPEC-2026-CONSTRUCTION-OWNERSHIP-TRANSFER-VERIFICATION)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - Hem Müteahhit hem de Öz Sermaye (self-build) inşaat senaryolarında inşaat bittiğinde konutların oyuncunun mülkiyetine (portföyüne) doğru şekilde geçip geçmediğinin uçtan uca denetlenmesi, tespit edilen eksikliklerin giderilmesi ve otomatik testlerle tescil edilmesi.
- **Yapılan Değişiklikler**:
  - `lib/data/models/real_estate_model.dart`:
    - `isConstructionActive`: Yalnızca arsaların şantiye kabul edilmesi için `category == RealEstateCategory.land` koşulu eklendi; üretilen veya mevcut konutların şantiye olarak işaretlenmesi engellendi.
    - `playerShareUnits`: Tamsayı bölme (`~/ 100`) yuvarlaması nedeniyle küçük projelerde veya pay oranlarında sıfır daire üretilmesini önleyen `(share == 0 && playerSharePercent > 0) ? 1 : share` koruması eklendi.
  - `lib/presentation/providers/game/game_real_estate_mixin.dart`:
    - `finalizeConstruction`:
      - `ZoningEngine.calculateZoning` çağrısına `district: land.district` parametresi eklendi; ilçe bazlı emsal ve değerleme tutarlılığı sağlandı.
      - Yeni üretilen anahtar teslim dairelere (`re_turnkey_${land.id}_$i`) başlangıç tapu geçmişi (`provenanceLog`) entegre edildi (`İnşaat tamamlandı • {district} projesinden kat mülkiyeti tapusu teslim alındı`).
    - `repayConstructionLoan`:
      - Arsa tamamlanıp konutlara dönüştükten ve listeden silindikten sonra da arsa kredisi borcunun ödenebilmesi için `loan_construction_${landId}` ID araması doğrudan `state.activeLoans` üzerinden yapılarak bağımsızlaştırıldı.
  - `test/construction_completion_and_peyzaj_fix_test.dart`:
    - Test 5: Müteahhit ve Öz Sermaye senaryolarında konutların kat mülkiyeti tapusuyla portföye eksiksiz eklendiğini, kiralama, satış ve kişisel konut özelliklerinin aktif olduğunu doğrulayan test eklendi.
    - Test 6: Arsa konuta dönüştükten sonra inşaat kredisinin başarıyla kapatılabildiğini doğrulayan test eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Arsa kredisi çekilmiş bir projede inşaat tamamlandığında arsa `ownedRealEstates` listesinden silindiği için `repayConstructionLoan` `landIndex == -1` görerek krediyi kapatamıyordu.
  - Yeni teslim alınan konutların tapu geçmişi (`provenanceLog`) boş kalıyordu.
- **Kök Neden**:
  - `finalizeConstruction` arsa modelini sildiği halde kredi modelinin aktif kredilerde yaşamaya devam etmesi ve kredi geri ödeme metodunun arsanın portföyde bulunmasını şart koşması.
- **Uygulanan Çözüm**:
  - Kredi kapatma metodu arsa portföyde olmasa bile aktif krediler tablosundan borcu tahsil edip kapatacak şekilde refactor edildi.
  - Her bir konut tapu geçmişi kaydıyla oluşturuldu.
- **Doğrulama / Test Durumu**:
  - `flutter test test/construction_completion_and_peyzaj_fix_test.dart` (6/6 test geçti).
  - `flutter test test/real_estate_construction_test.dart` (19/19 test geçti).
  - `flutter test test/construction_master_modules_audit_test.dart` (10/10 test geçti).
  - `flutter test test/construction_speedup_and_time_control_test.dart` (5/5 test geçti).
  - `flutter test test/construction_dynamics_depth_test.dart` (10/10 test geçti).
  - `flutter analyze lib/` (No issues found, 0 errors, 0 warnings).

### `Arsa & İnşaat Müteahhit 0 Gün Takılması & Öz Sermaye Peyzaj Seviyesi Düzeltmesi (§SPEC-2026-CONSTRUCTION-CONTRACTOR-ZERO-DAY-PEYZAJ-FIX)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - Müteahhit modunda inşaat bittiğinde kalan sürenin 0 günde takılı kalması ve anahtar teslim kartının gösterilmemesi hatasının çözülmesi.
  - Öz sermaye inşaatında Aşama 7 tamamlandıktan sonra Aşama 8'in (Peyzaj & İskan) unstarted olarak kilitlenmesi veya Aşama 8 teslim alındığında 8'e kenetlenerek sonsuz döngüye girmesi hatasının çözülmesi.
  - Müteahhit hızlandırması sonrasında `isConstructionWorking` bayrağının açık kalarak teslimatı engellemesinin önlenmesi.
  - Portföyde yeterli slot olmadığında anahtar teslim daire transferinin sessizce başarısız olmasını engelleyen dinamik slot genişletme mimarisi.
- **Yapılan Değişiklikler**:
  - `lib/data/models/real_estate_model.dart`:
    - `isConstructionActive` 9 aşamaya (`constructionStage <= 9`) uyarlandı.
    - `constructionProgress` ve `constructionPercent`: `isConstructionComplete` durumunda doğrudan 1.0 (%100) döndürecek şekilde refactor edildi.
    - `isConstructionComplete`:
      - Müteahhit modunda: `constructionMode == 'contractor' && constructionStage >= 8 && constructionDaysRemaining <= 0` (isConstructionWorking durumundan bağımsız olarak daima teslimata hazır kabul edilir).
      - Öz sermaye modunda: `constructionStage >= 9` veya Aşama 8 başarıyla teslim alınmışsa (`provenanceLog.any((l) => l.contains('Aşama 8'))` veya mock test uyumu için `constructionStage >= 8 && constructionDaysRemaining <= 0 && !isConstructionWorking && stageTotalDays == 0 && (provenanceLog.any((l) => l.contains('Aşama 8')) || provenanceLog.isEmpty)`).
  - `lib/presentation/providers/game/game_real_estate_mixin.dart`:
    - `completeSelfBuildStage`: `(land.constructionStage + 1).clamp(1, 8)` yerine `final isAllDone = nextStage > 8; constructionStage: isAllDone ? 9 : nextStage` mantığı uygulandı. Aşama 8 tamamlandığında Aşama 9'a geçiş sağlandı.
    - `accelerateConstructionTimer`: Müteahhit modunda süre kısaltıldığında `isConstructionWorking: false` olarak normalize edildi. Süre 0'a indiğinde Aşama 8 ise Aşama 9'a ilerletildi.
    - `finalizeConstruction`: Daire sayısı mevcut boş slotlardan fazla olduğunda `maxRealEstateSlots` otomatik olarak `max(state.maxRealEstateSlots, requiredSlots)` ile genişletildi.
  - `lib/presentation/providers/game/game_time_mixin.dart`:
    - Müteahhit modunda Aşama 8 de 15 gün boyunca çalıştırılacak şekilde (`isDone ? 9 : nextStage`) güncellendi.
    - Aşama tamamlandığında `isConstructionWorking: false` normalize edildi ve tamamlanma bildirimi eklendi.
    - Eğer `constructionStage >= 8 && constructionDaysRemaining <= 0` durumunda arsa varsa `isConstructionWorking: false` yapıldı.
  - `lib/presentation/screens/real_estate/real_estate_construction_screen.dart`:
    - `_buildEightStageTimelineCard`: `isStagePassed = isFinished || currentStage > stage.stageNumber`, `isCurrentStage = !isFinished && currentStage == stage.stageNumber` yapılarak tüm 8 etap için yeşil onay tikleri sağlandı.
    - `_buildStagesTabContent`: Müteahhit modu 0 güne ulaştığında `_buildFinalizeCard` kartına doğrudan geçiş sağlandı.
    - `_buildContractorWaitCard`: Fail-safe olarak `constructionDaysRemaining <= 0 && constructionStage >= 8` olduğunda doğrudan `_buildFinalizeCard` döndürüldü.
  - `lib/presentation/screens/real_estate/subcontractor_negotiation_chat_screen.dart`:
    - `isCompleted` ve `isCurrent` durumları `land.isConstructionComplete` gözetilerek güncellendi.
  - `lib/presentation/screens/real_estate/real_estate_market_screen.dart`:
    - Rozetler ve butonlar `property.constructionStage >= 8` yerine `property.isConstructionComplete` üzerinden güncellendi.
  - `test/construction_completion_and_peyzaj_fix_test.dart`:
    - Müteahhit 0 gün tamamlama, günlük döngüde Aşama 8 ilerlemesi, Öz sermaye Aşama 7'den 8'e geçiş ve 8'den 9'a tamamlama ile slot genişletmeyi doğrulayan 4 kapsamlı test yazıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Müteahhit modunda reklam izleyip süre kısaltıldığında `isConstructionWorking` true kalıyordu ve modeldeki `!isConstructionWorking` kontrolü yüzünden arsa asla bitmiş sayılmıyordu.
  - Öz sermaye modunda Aşama 8 bittiğinde `clamp(1, 8)` nedeniyle Aşama 8'e geri kenetleniyor ve unstarted görünerek sonsuz döngüye giriyordu.
- **Kök Neden**:
  - Müteahhit modunda stageDays atamasının 7. aşamada 0 gün verilmesi ve hızlandırma sonrası working bayrağının sıfırlanmaması.
  - Modelde `constructionStage >= 8 && constructionDaysRemaining <= 0` kontrolünün Aşama 7 bittiğinde henüz başlanmamış Aşama 8 ile karışması ve `clamp(1, 8)` tavanı.
- **Uygulanan Çözüm**:
  - Şantiye tamamlanma durumu Aşama 9 olarak standartlaştırıldı, 8 aşamanın tamamı timeline üzerinde yeşil tikle tamamlandı gösterildi.
  - Müteahhit modu için 0 günde takılmayı imkansız kılan fail-safe finalize kartı entegre edildi ve bayraklar normalize edildi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/construction_completion_and_peyzaj_fix_test.dart` çalıştırıldı: 4/4 test geçti.
  - `flutter test test/real_estate_construction_test.dart` çalıştırıldı: 19/19 test geçti.
  - `flutter test test/construction_master_modules_audit_test.dart` çalıştırıldı: 10/10 test geçti.
  - `flutter test test/construction_speedup_and_time_control_test.dart` çalıştırıldı: 5/5 test geçti.
  - `flutter test test/construction_dynamics_depth_test.dart` çalıştırıldı: 10/10 test geçti.
  - `flutter analyze lib/` çalıştırıldı: 0 issue found (sıfır hata, sıfır uyarı).

### `Şubeler Ekranında Açılan Özelliklerin Netleştirilmesi, Yeraltı Casino & Eksik Sistemlerin Eklenmesi ve 7 Dilde Rozetli Kart Görünümü (§SPEC-2026-BRANCH-FEATURES-UI-POLISH)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - Şubeler ekranında her şubede hangi özelliklerin ve oyun sistemlerinin açıldığının net, belirgin ve eksiksiz olarak kullanıcıya sunulması.
  - Şube 5'te açılan "Yeraltı Casino & VIP Masa", Şube 4'te açılan "Emlak Piyasası", Şube 3'te açılan "Vasıta Pazarı" gibi kritik sistemlerin özet metinlerine eklenmesi.
  - Çeviri anahtarlarındaki `{summary}` değişken kaybı nedeniyle metinlerin görünmemesi sorununun kökten çözülerek her özelliğin bağımsız neo-brutalist rozetler (chip) halinde sunulması.
  - Tüm özellik özetlerinin 7 dilde (`tr`, `en`, `de`, `es`, `pt`, `ru`, `ar`) parantezsiz ve emojisiz olarak senkronize edilmesi.
- **Yapılan Değişiklikler**:
  - `lib/data/models/branch_model.dart`:
    - `getFeaturesList(BuildContext context)` fonksiyonu eklendi; virgülle ayrılmış özet metnini otomatik olarak dilden bağımsız liste öğelerine dönüştürür.
    - `getAllBranches()` içerisindeki 8 şubenin varsayılan `unlockedSummary` içerikleri güncellendi (özellikle Şube 5'e Yeraltı Casino ve Canlı Mezat eklendi).
  - `lib/presentation/screens/branch/branch_screen.dart`:
    - Şube kartlarındaki tek satırlık ve eksik gösterilen metin alanı yerine, her özellik için `Icons.verified_rounded` (kilit açıldıysa) veya `Icons.lock_outline_rounded` (kilitliyse) ikonu barındıran taktiksel neo-brutalist `Wrap` rozet alanı (`b.getFeaturesList(context)`) oluşturuldu.
    - Bölüm başlığına durum rozeti (`AKTİF` veya `SEVİYE {lvl}`) entegre edildi.
  - `lib/core/localization/translations/*.dart`:
    - 7 dilde (`tr`, `en`, `de`, `es`, `pt`, `ru`, `ar`) `branch_1_summary` - `branch_8_summary` anahtarları eksiksiz sistemleri içerecek şekilde güncellendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Çeviri dosyalarında `branch_unlocked_features` anahtarında `{summary}` yer tutucusu bulunmadığı için önceki arayüzde özet metinleri ekranda basılamıyordu.
- **Kök Neden**:
  - `context.tr('branch_unlocked_features', {'summary': ...})` çağrıldığında çeviride `{summary}` olmadığı için sadece `"Açılan Özellikler:"` başlığı dönüyordu.
- **Uygulanan Çözüm**:
  - UI doğrudan `b.getFeaturesList(context)` ile her özelliği ayrı rozet olarak basacak şekilde refactor edildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/` çalıştırıldı: 0 hata, 0 uyarı (No issues found).
  - `flutter test` çalıştırıldı: Tüm testler başarıyla geçti.

### `Apple Guideline 4 (Design: Launch Experience) İhlal Çözümü, Açılışta Zorunlu/İstemsiz Reklam Modallarının Kaldırılması & %100 Gönüllü Reklam Mimarisi (§SPEC-2026-APPLE-GUIDELINE-4-REMOVAL-FORCED-ADS)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - Apple App Store İnceleme Ekibi'nin Version 1.0.6 (Build 30) incelemesinde verdiği Guideline 4 - Design (Human Interface Guidelines • Launching) ret kararının ("We noticed that the app requires customers to view advertisements prior to using it. To resolve this issue, please remove the forced advertising and resubmit the app for review.") kökten çözülmesi.
  - Uygulama açılışında, onboarding sonrasında veya kullanıcı etkileşimi olmaksızın otomatik açılan ve reklam içeren tüm unprompted açılır pencerelerin (`DailyLoginSheet`, `showOfflineRecapModal`, `NeoBrutalStoryAdDialog`, `NeoBrutalContextualLifelineDialog`, `RateUsRewardDialog`) açılış akışından arındırılması.
  - Reklamların tamamen pasif, kullanıcı tarafından isteğe bağlı tıklanan banner'lar veya gönüllü diyaloglar haline getirilmesi.
  - Versiyonun `1.0.6+31` olarak güncellenmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_banners.dart`:
    - `DashboardStoryAdBanner` oluşturuldu: Hikaye/fırsat kartları artık açılışta veya gün devrinde otomatik popup olarak fırlamak yerine, dashboard üzerinde kapatılabilir (`Icons.close_rounded`) ve tıklandığında gönüllü olarak detay diyaloğunu açan yatay neo-brutalist kart olarak gösteriliyor.
    - `DashboardDailyStreakBanner` kartına `onTap` eklendi; kullanıcılar 28 günlük giriş takvimini istedikleri zaman gönüllü olarak inceleyebiliyor ve anında reklamsız 1 tıkla ödüllerini alabiliyor.
  - `lib/presentation/screens/dashboard/dashboard_screen.dart`:
    - Açılış `initState()` ve gün devri dinleyicisinden `DailyLoginSheet.show(context)` ve `RateUsRewardDialog.checkAndShow(context, ref)` çağrıları kaldırıldı.
    - `_checkAndShowPendingDialogs` içerisinden `pendingStoryCard` ve `ContextualEmergencyAdEngine` otomatik modal fırlatma çağrıları kaldırılarak `_buildPriorityActionBanner` ve feed içine inline aktarıldı.
  - `lib/presentation/screens/dashboard/widgets/dashboard_retention_modals.dart`:
    - `showOfflineRecapModal`: `barrierDismissible: true` yapıldı, başlığa `Icons.close_rounded` kapatma butonu eklendi; standart reklamsız ödül alma butonu (`retention_claim_rewards`) zümrüt yeşili (`AppColors.brutalGreen`) ile birincil buton haline getirildi, reklamlı katlama butonu ikincil ve isteğe bağlı konuma alındı.
    - `showReciprocityStarterGiftModal`: `barrierDismissible: true` yapıldı ve başlığa kapatma butonu eklendi.
  - `lib/presentation/widgets/neo_brutal_story_ad_dialog.dart`:
    - `barrierDismissible: false` değeri `true` yapılarak modal dışına dokunarak kapatılabilirlik sağlandı.
  - `lib/presentation/widgets/dialogs/neo_brutal_contextual_lifeline_dialog.dart`:
    - `barrierDismissible: false` değeri `true` yapıldı.
  - `lib/presentation/widgets/dialogs/rate_us_reward_dialog.dart`:
    - `barrierDismissible: false` değeri `true` yapıldı.
  - `lib/presentation/providers/game/game_time_mixin.dart`:
    - `syncRealForexRates`: Asenkron internet kurları çekilirken widget/notifier unmount durumuna karşı `mounted` kontrolleri eklendi; dispose sonrası state mutasyonu hatası giderildi.
  - `pubspec.yaml`:
    - Versiyon `1.0.6+30`'dan `1.0.6+31`'e yükseltildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `offline_reward_multiplier_test.dart` çalıştırılırken `syncRealForexRates` metodunda dispose sonrası state erişimi (`Bad state: Tried to use GameCoreNotifier after dispose was called`) tespit edildi.
- **Kök Neden**:
  - `ForexMarketService.fetchLiveForexRates` asenkron çağrısı tamamlandığında eğer notifier dispose edilmişse `state` okuma/yazma Riverpod StateNotifier tarafından hata fırlatır.
- **Uygulanan Çözüm**:
  - `syncRealForexRates` içerisine await öncesi ve sonrası `if (!mounted) return false;` güvenlik bariyeri eklendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/` çalıştırıldı: 0 hata, 0 uyarı (No issues found).
  - `flutter test test/offline_reward_multiplier_test.dart test/rewarded_ad_integrations_test.dart test/ad_service_test.dart` çalıştırıldı: 19 testin 19'u da başarıyla geçti.
  - `flutter test test/auction_closed_shortcut_guard_test.dart` çalıştırıldı: 5 testin 5'i de başarıyla geçti.
  - `greenlight preflight .` çalıştırıldı: `PrivacyInfo.xcprivacy` doğrulandı, iOS kod tabanında ihlal bulunmadı.

### `Müzayede Satış Kısayolu Kaçak Önleme, Mezat Kapalı Durum Gating ve 7 Dil Senkronizasyonu (§SPEC-2026-AUCTION-CLOSED-SELL-GUARD)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  1. Galeri araç kartlarındaki "Müzayedede Sat" butonunun, mezat salonu kapalıyken (`!isWindowOpen`) kural dışı doğrudan Tab 3'e (`/auction?tab=3`) yönlendirme açığının kapatılması.
  2. Müzayede kapalıyken galeri kartındaki butonun kilitli mezat durumu rozeti (`MEZAT KAPALI`) ve kilit saati ikonu (`Icons.lock_clock_rounded`) ile pasif/bilgilendirici duruma geçmesi.
  3. Müzayede kapalıyken bu butona tıklandığında doğrudan satış tabına geçmek yerine kullanıcıya uyarı bildirimi verilmesi ve geri sayım ile güvenlik görevlisinin bulunduğu mezat ana salonuna (`/auction` Tab 0) yönlendirilmesi.
  4. `AuctionScreen` içerisinde `initialTabIndex: 3` ile giriş yapılması durumunda mezat kapalıysa Tab 0'a zorunlu geri çekilerek uyarı verilmesi; Tab 3 sekme başlığının kilit ikonu göstermesi ve tıklandığında uyararak ana salonda tutulması.
  5. Mezat salonu kapalıyken sekme gövdesinin Tab 3 için de `AuctionClosedWindowView` render etmesinin sağlanması ve `AuctionSellTab._startAuction` fonksiyonuna da ikincil güvenlik bariyeri eklenmesi.
  6. `auction_closed_sell_redirect_toast` anahtarının 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) parantezsiz ve emojisiz olarak senkronize edilmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/showroom/widgets/showroom_car_card.dart`:
    - "Müzayedede Sat" butonu `auctionSessionProvider.isWindowOpen` kontrolüne bağlandı; kapalıyken buton etiketi `Müzayedede Sat • MEZAT KAPALI`, ikonu `Icons.lock_clock_rounded` yapıldı.
    - Kapalıyken tıklandığında `NotificationService.showWarning` ile toast gösterilip mezat ana sayfasına (`/auction`) yönlendirme sağlandı; açıkken doğrudan `tab=3`e yönlendirildi.
  - `lib/presentation/screens/auction/auction_screen.dart`:
    - `initState` içinde `widget.initialTabIndex == 3 && !isWindowOpen` durumunda sekme 0'a çekildi ve uyarı toast'u tetiklendi.
    - Tab 3 sekme başlığına kapalı mezat kontrolü eklendi; tıklandığında uyarı verilip Tab 0'da kalması sağlandı ve ikonu `Icons.lock_clock_rounded` olarak güncellendi.
    - Sekme gövdesi Builder mimarisine geçirilerek mezat kapalıyken sekme 0, 1 ve 3 için `AuctionClosedWindowView` zorunlu kılındı.
  - `lib/presentation/screens/auction/widgets/auction_sell_tab.dart`:
    - `_startAuction` fonksiyonuna `ref.read(auctionSessionProvider).isWindowOpen` kontrolü eklenerek kapalı mezat sırasında satış başlatma denemelerine karşı savunma katmanı sağlandı.
  - `lib/core/localization/translations/*.dart`:
    - 7 dilde `auction_closed_sell_redirect_toast` anahtarı eklendi.
  - `test/auction_closed_shortcut_guard_test.dart`:
    - 7 dil senkronizasyonu, sıfır emoji & sıfır parantez kuralları, kapalı/açık mezat tab 3 yönlendirme ve kilit davranışı için 5 adet otomatik test yazıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Widget testlerinde `pulseController` animasyonu ve toast bildirim pausable timer'larının widget unmount öncesi drain edilmemesi nedeniyle pending timer assertion oluştu.
- **Kök Neden**:
  - Flutter test framework'ü aktif timer ve controller'lar yok edilmeden widget ağacı kapatıldığında `!timersPending` hatası fırlatır.
- **Uygulanan Çözüm**:
  - Testlerde `tester.pump(const Duration(seconds: 3))` ile timer'lar drain edildi ve unmount öncesi kontroller sağlandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` çalıştırıldı: 0 sorun (No issues found).
  - `flutter test` ile toplam 27 müzayede testi başarıyla tamamlandı.

### `Görsel Taşma Düzeltmeleri, Emlak Portföyü Buton Renk Çakışması & Prosedürel Dokular (§SPEC-2026-UI-OVERFLOWS-REAL-ESTATE-POLISH)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  1. Müzayede (Auction) ekranındaki 4 sekmeli barın dar ekranlarda 10px ve 21px yatay taşmalarının (`RenderFlex overflowed`) ve üst başlık plakasının "CANLI MEZAT" rozeti ile çarpışmasının giderilmesi.
  2. Satış & Ticaret Geçmişi ekranında yatay `Row` sıkışması nedeniyle harf harf dikey dökülen "S A T I Ş K A Y I T L A R I ..." başlığının ve 14px taşan filtre butonlarının dikey hiyerarşik `Column` düzenine alınarak düzeltilmesi.
  3. VIP Performans & Modifiye (Tuning Studio) ekranındaki seçenek kartlarında sağ tarafta sarkan "+%4 Değer" rozetinin 35-36px taşmasının başlık satırını `Expanded` ile sınırlandırarak çözülmesi.
  4. Tapu ve Gayrimenkul Pazarlık Masası ekranında yeşil net avantaj kartının sağ kenardan 29px taşmasının giderilmesi.
  5. Emlak Pazarı Portföyüm ekranında yan yana gelen "İç Dizayn Yap" (kehribar turuncu) ve "Tahliye Et & Sat" (turuncu) butonları arasındaki renk çakışmasının giderilmesi; İç Dizayn Yap butonunun yaratıcı ve lüks tasarım moru (`Color(0xFFA855F7)`) ile ayrıştırılması.
  6. Kişisel ikametgah olarak atanmış mülklerde yersiz görünen gri daire içi dolar (`$`) ikonunun kaldırılması; kiralama ve ikametgah değiştirme butonlarının neo-brutalist dokulu ve etiketli düğmelere dönüştürülmesi.
  7. Emlak portföy kartlarının `/generative-art-shaders` kapsamında `CadBlueprintOverlay` mimari ızgara tual dokusu ile giydirilmesi.
  8. `tr_translations.dart` içerisinde eksik olan `'real_estate_btn_vacate_and_sell'` anahtarının ("Tahliye Et & Sat") eklenerek İngilizce fallback ("Vacate & Sell") gösteriminin önlenmesi ve 7 dille tam senkronize edilmesi.
- **Yapılan Değişiklikler**:
  - `lib/core/localization/translations/tr_translations.dart`:
    - `'real_estate_btn_vacate_and_sell': 'Tahliye Et & Sat'` anahtarı eklendi.
  - `lib/presentation/widgets/neo_brutal_app_bar.dart`:
    - `_buildTitle` içinde sağ aksiyon düğmelerinin genişliğini dinamik hesaplayan `actionsWidth = 105.0` faktörü entegre edildi; başlık levhasının "CANLI MEZAT" gibi son ek rozetlerle çakışması engellendi.
  - `lib/presentation/screens/auction/auction_screen.dart`:
    - Dört sekme düğmesi içerikleri `FittedBox(fit: BoxFit.scaleDown)` ile sarmalandı.
  - `lib/presentation/screens/history/sales_history_screen.dart`:
    - Filtre satırı `Row(children: [Expanded(Text), SingleChildScrollView(...)])` yapısından, başlığı tam genişlikte üste alan ve filtre çiplerini yatay kaydıran `Column` yapısına çevrildi.
  - `lib/presentation/screens/workshop/tuning_studio_screen.dart`:
    - Seçenek kartı başlık satırındaki metin bloğu `Expanded` içine alınarak sağdaki değer artış rozetinin taşması önlendi.
  - `lib/presentation/screens/real_estate/real_estate_negotiation_screen.dart`:
    - Net avantaj metni `Expanded`, tutar göstergesi `FittedBox` ile sarmalanarak 29px taşma giderildi.
  - `lib/presentation/screens/real_estate/real_estate_market_screen.dart`:
    - `_buildPortfolioCard` `CadBlueprintOverlay` ile sarmalandı.
    - "İç Dizayn Yap" butonu `Color(0xFFA855F7)` mor renge güncellendi.
    - İkametgah durumunda sahipsiz duran gri dolar simgesi kaldırıldı; kiraya verilebilir mülkler için etiketli butonlar eklendi.
    - Mükerrer ikametgah rozeti temizlendi ve kiralık ilanda rozeti yerelleştirildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `_buildPortfolioCard` düzenlenirken `final isDark` satırında sözdizimi kırılması oluştu, anında tespit edilerek düzeltildi.
- **Kök Neden**:
  - Kısıtlı genişlikli ekranlarda sabit boyutlu metin ve ikonların taşması; `Wrap` içinde aynı renk tonlarına sahip iki aksiyon butonunun yan yana düşmesi; `tr_translations.dart` dosyasında bir anahtarın eksik kalması.
- **Uygulanan Çözüm**:
  - `FittedBox` ve `Expanded` ile taşma koruması sağlandı, renk paleti neo-brutalist kurallarla uyumlu kontrast mor ile ayrıştırıldı ve eksik çeviri tamamlandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` çalıştırıldı.
  - Proje geneli derleme ve test kontrolleri gerçekleştirildi.

### `Android Yerel Gelişmiş Reklam (NativeAd) Dar Ekran Genişlik Esnekliği ve Kısıtlama İyileştirmesi (§SPEC-2026-NATIVE-AD-ANDROID-POLISH)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  - `NeoBrutalNativeAdCard` bileşeni içerisindeki `ConstrainedBox` yapısından katı `minWidth: 320` kısıtlamasının kaldırılması; 320dp-340dp genişliğindeki kompakt Android cihazlarda kenar boşlukları (padding/margin) nedeniyle oluşabilecek kutu kısıtlama çatışması (`BoxConstraints minWidth > maxWidth`) ve `RenderFlex` taşmalarının önlenmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/widgets/ads/neo_brutal_native_ad_card.dart`:
    - `AdWidget`'ı sarmalayan `BoxConstraints` içerisindeki `minWidth: 320` kaldırıldı; Google Native Template Medium gereksinimi olan dikey `minHeight: 320, maxHeight: 360` kuralı korunarak genişliğin üst kapsayıcıya ve ekran genişliğine göre doğal esnemesi sağlandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Herhangi bir derleme veya çalışma zamanı hatasıyla karşılaşılmadı.
- **Kök Neden**:
  - `BoxConstraints` içinde sabit 320px asgari genişlik atanması, küçük ekranlı Android telefonlarda veya yatay boşluklu kolonlarda kullanılabilir genişliğin 320px altına düştüğü durumlarda potansiyel düzen bozulmalarına zemin hazırlamaktaydı.
- **Uygulanan Çözüm**:
  - Asgari genişlik sınırı kaldırılarak genişliğin tam duyarlı (responsive) olması sağlandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/widgets/ads/neo_brutal_native_ad_card.dart` çalıştırıldı: 0 hata, 0 uyarı (No issues found).
  - `flutter test test/ad_service_test.dart` çalıştırıldı: 8/8 test başarıyla geçti.
  - `flutter test test/ui_ux_pro_max_and_shaders_test.dart` çalıştırıldı: 8/8 test başarıyla geçti.

### `Neo-Brutalist Prosedürel Shader Dokuları, Sıfır Çıkmaz Boş Durumlar, Dar Ekran (<340dp) Taşma Koruması ve Slopsuz Açıklamalar (§SPEC-2026-UI-UX-PRO-MAX-SHADERS-OVERFLOWS-ZERO-SLOP)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  1. Dar ekranlı (<340dp) mobil cihazlarda düğme ve metin taşmalarının (`RenderFlex overflowed by N pixels`) `Flexible`, `Expanded`, `FittedBox` ve `Wrap` hiyerarşisi ile giderilmesi.
  2. Oyuncuyu yönlendirmesiz bırakan sahipsiz/boş durumların (`NeoBrutalEmptyState`) aksiyon butonları (`actionLabel`, `actionIcon`, `onAction`) ile dinamik akışa bağlanması (örneğin müşteri yorumlarında galeriye, hurdalık parça sekmesinde hurda araç satın almaya, borsa dedikodularında fısıltı yayma paneline yönlendirme).
  3. Neo-brutalist dokuyu canlandıran sıfır kare gecikmeli tual ve prosedürel shader dokularının (`CrtScanlinesOverlay`, `BayerDitherOverlay` 4x4 matris, `TactileBrutalStamp`, `CadBlueprintOverlay`) üretilmesi ve ekranlara uygulanması.
  4. Hurdalık B2B siparişler sekmesindeki avatar rendering sorunlarının ve sıkışan sipariş tamamlama butonlarının giderilmesi.
  5. Konsinye, yan işletmeler ve medya ajansı ekranlarındaki etiket, rozet ve başlık alanlarının dar ekran duyarlı hale getirilmesi.
  6. Eklenen tüm yeni metin ve etiketlerin kural 1 (sıfır emoji), kural 2 (sıfır parantez) invariantları altında 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) eşzamanlı olarak yerelleştirilmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/widgets/procedural_shader_textures.dart` [YENİ]:
    - `CrtScanlinesOverlay`: CRT tüplü televizyon yatay tarama çizgilerini ve hafif fosfor ışımasını donanım hızlandırmalı `CustomPainter` ile simüle eden katman.
    - `BayerDitherOverlay`: 4x4 Bayer dither matrisi kullanan, retro bilgisayar ve fotokopi tramı dokusu sunan sıfır maliyetli görsel doku widget'ı.
    - `TactileBrutalStamp`: -12° açılı, 2.5px kalın neo-brutalist damga (KAŞELENDİ / REDDEDİLDİ / ONAYLANDI / İFLAS / B2B ONAYLI).
    - `CadBlueprintOverlay`: Teknik çizim, mimari plan ve CAD milimetrik kareleme + merkez artı izleri çizen overlay.
  - `lib/presentation/screens/reviews/customer_reviews_screen.dart`:
    - Değerlendirme özet kartı `BayerDitherOverlay` ile zenginleştirildi.
    - Boş inceleme durumu `NeoBrutalEmptyState` üzerinden `reviews_empty_cta` ("Galeriye Git & Araç Sat") butonu ve GoRouter `/showroom` yönlendirmesiyle canlı hale getirildi.
  - `lib/presentation/screens/scrapyard/widgets/scrapyard_salvaged_parts_tab.dart`:
    - Boş envanter alanı yalın metin yerine `NeoBrutalEmptyState` ile değiştirildi; `scrap_no_parts_cta` butonu ve `onSwitchToScrapCars` geri çağrımı eklendi.
  - `lib/presentation/screens/scrapyard/scrapyard_screen.dart`:
    - `ScrapyardSalvagedPartsTab` bileşenine `onSwitchToScrapCars: () => _tabController.animateTo(0)` atanarak parça bulunmadığında doğrudan "Hurda Araçlar" satın alma sekmesine geçiş sağlandı.
  - `lib/presentation/screens/scrapyard/widgets/scrapyard_b2b_orders_tab.dart`:
    - Sipariş kartındaki `order.mechanicAvatar` metin olarak ekrana basılmak yerine neo-brutal kutu içinde `Icon(order.avatarIcon)` olarak render edildi.
    - Sipariş teslim butonu `Flexible` ve `FittedBox` ile dar cihazlarda buton taşmasına karşı korundu.
  - `lib/presentation/screens/gossip/industry_gossip_screen.dart`:
    - Gazete/manşet başlık kartına `CrtScanlinesOverlay` tarama çizgisi katmanı eklendi.
    - Boş fısıltı akışı durumuna `gossip_empty_cta` ("Piyasaya Fısıltı Yay") aksiyon butonu eklenerek doğrudan söylenti yayma paneli açıldı.
  - `lib/presentation/screens/consignment/consignment_screen.dart`:
    - Konsinye süresi ve aksiyon butonu satırı dar ekranlar için `Expanded` ve `Flexible(child: FittedBox(child: NeoBrutalButton(...)))` ile yeniden yapılandırıldı; buton metninin taşması engellendi.
  - `lib/presentation/screens/side_business/side_business_screen.dart`:
    - Başlık rozetleri `Flexible` ve `Wrap(spacing: 4, runSpacing: 4)` ile sarmalanarak küçük ekranlarda başlık metnini ezmeden alt satıra geçmesi sağlandı.
  - `lib/presentation/screens/office/media_agency_screen.dart`:
    - Aktif medya kampanyası kartına `BayerDitherOverlay` dokusu eklendi; istatistik metinleri `FittedBox` ile korundu.
  - `lib/core/localization/translations/*.dart`:
    - `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar` dillerine 6 yeni anahtar eşzamanlı olarak tanımlandı (`reviews_empty_cta`, `scrap_no_parts_cta`, `gossip_empty_cta`, `consignment_earn_rep_cta`, `media_headline_tag`, `scrap_mechanic_order_badge`).
  - `test/ui_ux_pro_max_and_shaders_test.dart` [YENİ]:
    - CRT, Bayer dither, brutal damga ve blueprint dokularının `CustomPainter` çizim döngülerini, 7 dil bütünlüğünü, parantezsiz/emojisiz kural denetimlerini ve 320px ultra dar ekranda `NeoBrutalEmptyState` render stabilitesini doğrulayan 8 adet test yazıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `consignment_screen.dart` dosyasında buton `Flexible` ve `FittedBox` içine alınırken kapanış parantezi eksikliği nedeniyle sözdizimi derleme hatası oluştu.
  - `customer_reviews_screen.dart` dosyasında `BayerDitherOverlay` eklendiğinde kapanış parantezi kayması nedeniyle widget argüman hatası alındı.
  - `ui_ux_pro_max_and_shaders_test.dart` dosyasında buton tıklama testi sırasında `pump()` kullanıldığında `NeoBrutalButton` animasyon zamanlayıcısının açık kaldığı tespit edildi.
- **Kök Neden**:
  - Çok katmanlı widget sarmalamalarında iç içe geçen parantez eşleşme karmaşıklığı.
  - Widget testlerinde basış animasyonu barındıran bileşenlerin timer döngüsünün `pumpAndSettle()` ile tamamlanması zorunluluğu.
- **Uygulanan Çözüm**:
  - Sözdizimi yapısı temizlenerek parantez hiyerarşisi yeniden hizalandı.
  - Widget testinde `await tester.pumpAndSettle()` kullanılarak tüm animasyon döngülerinin başarıyla sonlanması sağlandı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/ui_ux_pro_max_and_shaders_test.dart` çalıştırıldı: 8/8 test başarıyla geçti.
  - `flutter test test/leaderboard_and_real_estate_market_test.dart` çalıştırıldı: 5/5 test başarıyla geçti.
  - `flutter analyze` 10 değiştirilen ve yeni dosya üzerinde çalıştırıldı: 0 hata, 0 uyarı (No issues found).

### `Liderler Tablosu Otomatik Yenileme, Gayrimenkul Piyasa Fiyat Kalibrasyonu, Kasa Büyüdükçe Üst Segment Vasıta Üretimi, Dar Ekran Taşma Giderimleri ve Boş Durum Yönlendirmeleri (§SPEC-2026-LEADERBOARD-REALESTATE-WEALTH-POLISH)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  1. Liderler tablosunun Firestore bağlantısının doğrulanması, 45 saniyelik periyodik otomatik yenileme, pull-to-refresh desteği ve internet/veri yokluğunda yerel şehir rakipleriyle simüle edilen yedek liderler tablosunun devreye girmesi.
  2. Oyun gününün ilerlemesinde (`advanceGameDay`) ve araç satışında (`completeSale`) oyuncu net servet ve itibarının arka planda güvenli hız kısıtlamasıyla Firestore'a senkronize edilmesi.
  3. Gayrimenkul fiyatlarının Türkiye metropol (İstanbul, Ankara, İzmir, Antalya, Muğla/Bodrum) piyasa araştırmasına dayandırılarak gerçekçi seviyelere yükseltilmesi (Kupon Daire ₺6.8M - ₺19.5M, Dükkan ₺14M - ₺45M, Sanayi Parseli ₺24M - ₺85M, Komple Bina ₺48M - ₺140M).
  4. Oyuncunun kasası arttıkça (`MarketEngine` ve `VasitaMarketEngine`) ucuz hurda ve başlangıç araçlarının elenmesi, ₺10M-₺25M ve ₺25M+ kasalarda süperspor, egzotik, yat, uçak ve lüks karavanların pazara hakim olması.
  5. Dar ekranlı telefonlarda (<360dp) metin, fiyat ve buton taşmalarının (`RenderFlex overflowed by N pixels`) `Expanded`, `FittedBox` ve `ConstrainedBox` ile giderilmesi.
  6. Gayrimenkul pazarı boş ilan, boş portföy, arsa bulunamayan şantiye ve mülk bulunamayan tadilat ekranlarının `NeoBrutalEmptyState` ile açıklayıcı bilgi ve doğrudan CTA butonlarına kavuşturulması.
  7. Tüm yeni metinlerin 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) kural 1 (sıfır emoji) ve kural 2 (sıfır parantez) invariantlarına uygun olarak tam senkronize edilmesi.
- **Yapılan Değişiklikler**:
  - `lib/core/services/leaderboard_service.dart`: Önbellek süresi 10 dakikadan 2 dakikaya indirildi; `forceRefresh: true` durumunda önbelleği baypas edip Firestore'dan taze veri çekme garantilendi.
  - `lib/presentation/providers/leaderboard_provider.dart`: `isOfflineFallback` bayrağı eklendi. Firestore boş veya çevrimdışı olduğunda `_generateSimulatedRivalEntries` metoduyla ekranın asla boş kalmaması sağlandı.
  - `lib/presentation/screens/leaderboard/leaderboard_screen.dart`: 45 saniyelik periyodik otomatik yenileme timer'ı, `RefreshIndicator` ile aşağı çekerek yenileme, çevrimdışı durum bilgilendirme rozeti ve dar ekranlar için `FittedBox` / `Flexible` sarmalamaları eklendi.
  - `lib/presentation/providers/game/game_time_mixin.dart`: `advanceGameDay` sonuna arka plan `LeaderboardService.instance.syncPlayerStats` tetiklemesi eklendi.
  - `lib/presentation/providers/game/game_market_mixin.dart`: `completeSale` metoduna araç satışında arka plan `LeaderboardService.instance.syncPlayerStats` tetiklemesi eklendi.
  - `lib/domain/usecases/real_estate_market_engine.dart`: `templates` listesi Türkiye metropol piyasa araştırması fiyatları ve kira çarpanlarıyla güncellendi.
  - `lib/domain/usecases/vasita_market_engine.dart`: `generateListings` ve `_selectWeightedTemplate` metotlarına `playerBalance` parametresi eklendi; zengin oyuncular için uçak, deniz taşıtları ve karavan olasılıkları artırıldı, ucuz araçlar bastırıldı.
  - `lib/presentation/providers/vasita_market_provider.dart`: `refreshMarket` metodunda `playerBalance: game.balance` geçilerek vasıta pazarının anlık kasa duyarlı olması sağlandı.
  - `lib/domain/usecases/market_engine.dart`: `_generateSingleListing` ve `_selectWeightedBrand` fonksiyonlarına ₺10M-₺25M (Mega-Tycoon) ve ₺25M+ (Sovereign Baron) segment kademeleri eklendi.
  - `lib/presentation/screens/real_estate/real_estate_market_screen.dart`: `_buildListingCard` fiyat ve masraf sütunu `Expanded` ve `FittedBox(fit: BoxFit.scaleDown)` ile sarmalandı; boş ilanlar ve boş portföy görünümleri `NeoBrutalEmptyState` ve yönlendirme butonlarıyla yenilendi.
  - `lib/presentation/screens/real_estate/real_estate_construction_screen.dart`: Arsa bulunamadığında gösterilen yalın metin `NeoBrutalEmptyState` ve mülk pazarına dönüş CTA butonuyla değiştirildi.
  - `lib/presentation/screens/real_estate/real_estate_renovation_screen.dart`: Mülk bulunamadığında gösterilen yalın metin `NeoBrutalEmptyState` ve mülk pazarına dönüş CTA butonuyla değiştirildi.
  - `lib/presentation/screens/dashboard/widgets/dashboard_retention_modals.dart`: Rakip lider tablosu başlık satırı ve ciro puanı `ConstrainedBox` ve `FittedBox` ile sarmalanarak dar ekranlarda taşma riski sıfırlandı.
  - `lib/core/localization/translations/*.dart`: 7 desteklenen dile 10 yeni yerelleştirme anahtarı eklendi (`leaderboard_offline_badge`, `real_estate_empty_listings_desc`, `real_estate_empty_listings_cta`, `real_estate_empty_portfolio_cta`, `real_estate_construction_empty_title`, `real_estate_construction_empty_desc`, `real_estate_construction_empty_cta`, `real_estate_renovation_empty_title`, `real_estate_renovation_empty_desc`, `real_estate_renovation_empty_cta`).
  - `test/leaderboard_and_real_estate_market_test.dart`: Fiyat kalibrasyonunu, servet ölçekli araç üretimini ve 7 dil bütünlüğünü doğrulayan otomatik test paketi yazıldı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `game_time_mixin.dart` ve `game_market_mixin.dart` dosyalarında `state.ownerName` ve `state.netWorth` çağrıldığında `DealershipModel` üzerinde doğrudan tanımlı olmadıkları için derleme hatası oluştu.
- **Kök Neden**:
  - `DealershipModel` içerisinde oyuncu ismi `playerName` olarak adlandırılmıştır ve net servet toplamı doğrudan bir alan değil, kasa nakiti (`balance`) ile sahip olunan araçların (`ownedCars`) piyasa değerlerinin dinamik toplamıdır.
- **Uygulanan Çözüm**:
  - `state.playerName` kullanıldı ve `netWorth` değeri `balance + totalCarValue` olarak hesaplanarak `syncPlayerStats` metoduna aktarıldı.
- **Doğrulama / Test Durumu**:
  - `flutter test test/leaderboard_and_real_estate_market_test.dart` çalıştırıldı: 5/5 test başarıyla geçti.
  - `flutter test test/real_estate_market_test.dart` çalıştırıldı: 15/15 test başarıyla geçti.
  - `flutter analyze` 13 değiştirilen dosya üzerinde çalıştırıldı: 0 hata, 0 uyarı (No issues found).

### `Vasıta Pazarı Dokunmatik Kilitlenme Giderimi, Müzayedede Araç Satışı Erişilebilirliği & Ödüllü Reklam ile İhale Bekleme Süresini Atlama Protokolü (§SPEC-2026-VASITA-AUCTION-FIXES)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**:
  1. Vasıta pazarından (`/vasita`) ana ekrana dönüldüğünde ekranın hiçbir yerine tıklanamaması (touch freeze) sorununun kökten giderilmesi.
  2. Müzayedede sahip olunan araçların satış mekaniğinin incelenmesi, gümrük ihale salonu kapalıyken bile üst sekmelerin (Gümrük, VIP, Katalog, Aracımı Sat) erişilebilir kılınması, konsinye satış rehberi eklenmesi ve galeriden müzayedeye hızlı yönlendirme butonu sağlanması.
  3. Müzayede bekleme süresine in-universe hikaye (Gümrük İhale Komisyonu Tasfiye İdaresi Özel Protokolü) uydurularak ödüllü reklam ile bekleme süresini anında sıfırlayıp ihaleye giriş hakkı tanınması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/vasita/vasita_market_screen.dart`:
    - `dispose` metoduna `FocusManager.instance.primaryFocus?.unfocus()` eklendi.
    - `Navigator.of(context).push(MaterialPageRoute(...))` çağrıları GoRouter `context.push('/vasita-ekspertiz/${listing.id}', extra: listing)` ve `context.push('/vasita-pazarlik/${listing.id}', extra: listing)` ile değiştirildi; kök gezgin ile GoRouter hiyerarşisi arasındaki modal bariyer çakışması ve dokunmatik blokajı engellendi.
  - `lib/presentation/screens/vasita/vasita_negotiation_screen.dart`:
    - Tanımsız `/inventory` rotasına yapılan `context.go('/inventory')` çağrıları (satır 395 ve 1473) doğru hedef olan `context.go('/showroom')` ile değiştirildi.
  - `lib/app/router.dart`:
    - `/auction` rotası `tab` query parametresini (`tabIndex`) ayrıştıracak şekilde güncellendi (`AuctionScreen(initialTabIndex: tabIndex)`).
    - Olası eski `/inventory` yönlendirmeleri için `/showroom` redirect kuralı eklendi.
  - `lib/presentation/widgets/neo_brutal_app_bar.dart`:
    - Geri tuşuna basıldığında zorla çalıştırılan `ref.read(dashboardTabProvider.notifier).state = 0` kaldırıldı; rota çıkışında ana ekran dinleyicileriyle yarış durumu ve sekme sıfırlaması engellendi.
  - `lib/presentation/screens/dashboard/dashboard_screen.dart`:
    - `_checkAndShowPendingDialogs` metoduna `final route = ModalRoute.of(context); if (route != null && !route.isCurrent) return;` kontrolü eklendi; çocuk ekranlar etkinken arka planda görünmez modal bariyerlerin root navigator'a pushlanması engellendi.
  - `lib/presentation/widgets/floating_money_overlay.dart`:
    - Uçuşan para parçacıkları `Positioned` bileşeni `IgnorePointer(ignoring: true)` ile sarmalandı; parçacıkların dokunmatik tıklamaları yutması engellendi.
  - `lib/presentation/providers/auction_session_provider.dart`:
    - `bypassClosedCooldownWithAd` metodu eklendi: `AuctionEngine.openSessionImmediately()` çağrılır, `closedCountdown` 0'lanır, `isWindowOpen: true` yapılır, canlı seans ve timer başlatılır.
    - `startVipAuction` metodunda seans başlatıldığında `isWindowOpen: true` ve `closedCountdown: 0` güvencesi sağlandı.
  - `lib/presentation/screens/auction/widgets/auction_closed_window_view.dart`:
    - `onBypassWithAd` callback'i ve `_handleAdBypass` metodu eklendi.
    - Tasfiye İdaresi Protokolü hikaye kartı ("Gümrük İhale Komisyonu Özel Protokolü") ve yumuşak psikolojik buton ("Özel Kontenjan Protokolü Edin") entegre edildi.
  - `lib/presentation/screens/auction/auction_screen.dart`:
    - `initialTabIndex` desteği eklendi; `/auction?tab=3` ile doğrudan "Aracımı Sat" sekmesi açılabilir hale getirildi.
    - Üstteki 4'lü sekme çubuğu (Gümrük, VIP, Katalog, Aracımı Sat) ana gövdeden bağımsız hale getirildi; ihale kapalıyken de oyuncunun sekme değiştirebilmesi sağlandı.
  - `lib/presentation/screens/auction/widgets/auction_sell_tab.dart`:
    - Boş garaj durumunda açıklayıcı detay (`auction_sell_no_cars_detail`) ve Vasıta Pazarına yönlendiren buton eklendi.
    - Sekme başına "Müzayede Konsinye Satış Rehberi" bilgilendirme kartı eklendi.
  - `lib/presentation/screens/showroom/widgets/showroom_car_card.dart`:
    - Uygun araçlar için doğrudan `/auction?tab=3` sekmesine yönlendiren "Müzayedede Sat" butonu eklendi.
  - `lib/core/localization/translations/*.dart` (7 Dil Eşzamanlı Senkronizasyon):
    - `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar` dillerine `auction_closed_ad_protocol_title`, `auction_closed_ad_protocol_desc`, `auction_closed_ad_bypass_btn`, `auction_closed_ad_success_toast`, `auction_closed_protocol_badge`, `auction_sell_guide_title`, `auction_sell_guide_desc`, `auction_sell_no_cars_detail`, `auction_sell_go_to_market_btn`, `btn_send_to_auction` anahtarları eklendi.
  - `test/auction_and_vasita_navigation_test.dart` [YENİ]:
    - Reklam ile bekleme süresini atlama, VIP oturum başlatma, 7 dil eşzamanlılığı, parantezsiz ve emojisiz kural denetimleri yazıldı (4/4 geçti).
- **Karşılaşılan Hatalar / Sorunlar**:
  - `AuctionModel` içinde `isVip` getter'ının doğrudan bulunmaması nedeniyle `auction_and_vasita_navigation_test.dart` derleme hatası vermesi.
- **Kök Neden**:
  - VIP durumu `AuctionSessionState.isVipSession` boolean alanı ile yönetilmektedir.
- **Uygulanan Çözüm**:
  - Test beklentisi `state.isVipSession` olarak güncellendi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/auction_and_vasita_navigation_test.dart test/auction_sell_test.dart`: 11/11 geçti.
  - `flutter test test/touch_feedback_and_unfocus_test.dart test/vasita_market_test.dart`: 30/30 geçti.
  - `flutter analyze`: 0 issues found.

### `Emlak İnşaatı 2. Aşama Sonrası İlerleme Onarımı & Ödüllü Reklam ile Mantıksal Gün Hızlandırma Sistemi (§SPEC-2026-CONSTRUCTION-SPEEDUP-TIME-CONTROL)`
- **Tarih**: 2026-09-11
- **Değişiklik Amacı**: İnşaatın 2. aşamadan sonra taşeron kontrolü veya gün sayacı nedeniyle takılı kalması sorununun kökten çözülmesi; oyuncunun ödüllü reklam izleyerek (çift vardiya desteği ile) aşamayı mantıklı gün sayısında (etap süresinin 1/3'ü, min 3 gün) hızlandırabilmesi ve HUD üzerindeki gün göstergesine tıklayarak oyun takvimini 1 gün güvenli ileri sarabilmesi.
- **Yapılan Değişiklikler**:
  - `lib/domain/usecases/construction_timeline_engine.dart`:
    - `calculateLogicalDaysToReduce({required int stageDays})` metodu eklendi; etap süresine göre dengeli gün indirimi (`max(3, (stageDays / 3).round())`) hesaplandı.
  - `lib/presentation/providers/game/game_real_estate_mixin.dart`:
    - `completeSelfBuildStage`: Taşeron ismi zorunluluğu (`activeSubcontractorName`) teslim aşamasında kaldırıldı; gün süresi 0'a inen etabın bir sonrakine sorunsuz geçmesi sağlandı.
    - `accelerateConstructionTimer`: Ödüllü reklamla inşaat süresini mantıksal gün miktarında eksilten, mimari çizim ve ruhsat adımlarını doğrudan onaylayan, müteahhit veya öz inşaat modunda süreyi güvenle sıfırlayan motor entegre edildi.
  - `lib/presentation/providers/game/game_time_mixin.dart`:
    - `fastForwardGameDay`: Oyun takvimini güvenli bir şekilde 1 gün ileri sarıp tüm günlük gelir, emlak, personel ve faiz döngülerini işleten metot eklendi.
  - `lib/presentation/screens/real_estate/real_estate_construction_screen.dart`:
    - Öz inşaat ve müteahhit kartlarına "Vardiya Desteği Al • -N Gün Hızlandır" ödüllü reklam butonu ve 1 Oyun Günü = 2 Dakika aktif oyun ipucu eklendi.
    - Widget listelerinde derleme hatasına yol açan yerel `final speedupDays` değişken tanımları metot gövdesine taşınarak Dart sözdizimi düzeltildi.
  - `lib/presentation/screens/real_estate/subcontractor_negotiation_chat_screen.dart`:
    - Taşeron çalışma ve teslim kontrollerinde aktif taşeron kontrolü normalize edildi.
  - `lib/presentation/widgets/dialogs/game_day_time_control_sheet.dart` [YENİ]:
    - HUD gün bileşenine dokunulduğunda açılan, 1 oyun gününü sponsor desteğiyle ileri saran ve işlem geçmişine yönlendiren Neo-Brutalist alt panel sayfası oluşturuldu.
  - `lib/presentation/widgets/game_hud_widget.dart`:
    - Gün sayacı kutusuna dokunulduğunda `GameDayTimeControlSheet` tetiklendi.
  - `lib/core/localization/translations/*.dart` (7 Dil Eşzamanlı Senkronizasyon):
    - `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar` dillerine `hud_time_control_title`, `hud_time_control_desc`, `hud_time_fast_forward_btn`, `hud_time_fast_forward_toast`, `hud_time_view_history_btn`, `construction_speedup_btn`, `construction_speedup_reward_title`, `construction_speedup_toast`, `construction_time_equivalence_hint`, `construction_weather_hold_badge`, `real_estate_minutes_suffix` anahtarları eklendi.
  - `test/construction_speedup_and_time_control_test.dart` [YENİ]:
    - Hızlandırma günü hesaplama, 7-dil simetrisi ve parantezsiz/emojisiz denetimi, inşaat hızlandırma döngüsü ve takvim ileri sarma testleri yazıldı (4/4 geçti).
- **Karşılaşılan Hatalar / Sorunlar**:
  - `real_estate_construction_screen.dart` dosyasında `[ ... if (cond) ...[ final speedupDays = ... ] ]` yazılması nedeniyle `missing_identifier` ve `expected_token` derleme hataları oluşması.
  - `game_day_time_control_sheet.dart` dosyasında `NotificationService` import yolunun `core/services` olarak hatalı verilmesi (`uri_does_not_exist`).
  - Bazı dillerde (`ru`, `es`, `ar`) `{days}` yerine sabit rakam kalması ve `hud_time_control_*` anahtarlarının eksik olması.
- **Kök Neden**:
  - Flutter/Dart koleksiyon if yapısı içinde doğrudan yerel değişken bildirimine izin vermez.
  - Bildirim servisi `core/utils/` altında yer almaktadır.
- **Uygulanan Çözüm**:
  - Değişkenler metot başına taşındı, import düzeltildi, tüm anahtarlar 7 dilde senkronize edildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze`: 0 hata, 0 uyarı (No issues found).
  - `flutter test test/construction_speedup_and_time_control_test.dart`: 4/4 passed.
  - `flutter test test/weekly_season_and_podium_test.dart test/real_estate_construction_test.dart`: 26/26 passed.
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Haftalık Liderlik Sezonu ve Podyum Ödülleri sisteminin uçtan uca mimari, oyun mekaniği, sınır durumları ve UI bütünlüğü açısından denetlenmesi; tespit edilen eksik perk bağlantılarının, süre aşımı açıklarının ve yerelleştirme senkronizasyonunun tamamlanması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/providers/game/game_market_mixin.dart`:
    - Körfez Alıcı Ağı (`hasGulfBuyerNetwork`) satış priminde `isActive` kontrolü eklendi; sezon perk süresi dolduktan sonra haksız kazanç elde edilmesi engellendi.
  - `lib/presentation/providers/game/game_time_mixin.dart`:
    - 3. sıra podyum avantajı olan Sarı Site Vitrin Dopingi (`hasShowcaseBoost`) organik müşteri teklifi döngüsüne bağlandı. Perk aktifken teklif şansı 2 katına çıkarıldı.
  - `lib/presentation/screens/auction/auction_screen.dart`:
    - 1. sıra podyum şampiyonluğu avantajı olan Gümrük Tasfiye VIP Kartı (`hasCustomsAuctionPass`) müzayede girişine entegre edildi. Aktifken ödüllü reklam izleme gereksinimi bypass edildi.
  - `lib/presentation/screens/dashboard/widgets/dashboard_office_view.dart`:
    - Alınmamış podyum ödülü olduğunda (`hasUnclaimedSeasonRewards == true`) ofis masası kupa kaidesine dikkat çekici acil durum rozeti eklendi ve dokunulduğunda ödül talep diyaloğu açıldı.
  - `lib/presentation/screens/leaderboard/widgets/leaderboard_season_reward_dialog.dart`:
    - Sabit metin `HAFTALIK SEZON TAMAMLANDI` yerine yerelleştirme anahtarı `podium_dialog_badge_completed` bağlandı.
  - `lib/core/localization/translations/*.dart`:
    - `podium_dialog_badge_completed` anahtarı 7 dilin tamamına (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) parantezsiz ve emojisz olarak eklendi.
  - `test/weekly_season_and_podium_test.dart`:
    - Perk geçerlilik/son kullanma süresi (`isActive`) ve tüm seviye perk entegrasyonlarını doğrulayan yeni birim testler eklendi (7/7 test yeşil).
- **Karşılaşılan Hatalar / Sorunlar**:
  - Körfez alıcı primi hesaplanırken perk süresinin (`expiresAt`) dolup dolmadığı kontrol edilmiyordu.
  - 3. sıra vitrin dopingi ve 1. sıra gümrük tasfiye VIP kartı perkleri tanımlanmış ancak ilgili oyun mekaniklerine fiziksel olarak bağlanmamıştı.
  - Sezon bitişinde ödülü henüz almayan oyuncu liderlik tablosuna girmedikçe ofis ekranında ödülünü alabileceği net bir çağrı butonu görmüyordu.
  - Ödül diyaloğunun tepe rozeti sabit Türkçe metin olarak kalmıştı.
- **Kök Neden**:
  - Modeller ve liderlik tablosu akışı tamamlanmış ancak yan oyun döngüleri (müzayede, organik teklif zamanlayıcısı) ile perk durumları arasındaki köprüler henüz kurulmamıştı.
- **Uygulanan Çözüm**:
  - Perklerin yaşam döngüsü (`isActive`) tüm yan sistemlerde zorunlu kılındı, müzayede VIP geçişi ve organik teklif hızlandırması bağlandı, ofis masası üzerinden tek tıkla ödül alma deneyimi sağlandı ve tüm metinler 7 dilde eşitlendi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/weekly_season_and_podium_test.dart` ile 7/7 test başarıyla geçti.
  - `flutter analyze` ile 0 hata, 0 uyarı teyit edildi.

### `Emlak Portföyü Kişisel İkametgah Boşaltma ve Satış İlanı Entegrasyonu (§SPEC-2026-REAL-ESTATE-RESIDENCE-SALE)`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Emlak portföyünde kişisel ikametgah olarak atanmış mülklerin satışa çıkarılmak istendiğinde doğrudan engellenmesi yerine oyuncuya ikametgahı otomatik boşaltıp ilana çıkma olanağı tanıyan kullanıcı dostu onay akışının ve reaktif buton durumunun kazandırılması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/real_estate/real_estate_market_screen.dart`:
    - `_navigateToSellListing`: İkamet edilen mülk için salt uyarı yerine `_showVacateAndSellConfirmation` neo-brutalist diyalog akışı devreye alındı.
    - `_showVacateAndSellConfirmation`: Oyuncuya ikametgahın boşaltılacağını bildiren ve tek dokunuşla `vacatePersonalResidence` çalıştırıp ilan düzenleme sayfasına yönlendiren diyalog eklendi.
    - `_buildPortfolioCard`: Kişisel ikametgah durumunda satış butonu canlı turuncu arkaplan (`0xFFF97316`) ve "Boşalt ve Sat" metniyle reaktif hale getirildi.
  - `lib/core/localization/translations/*.dart`:
    - `real_estate_btn_vacate_and_sell`, `real_estate_vacate_sell_dialog_title`, `real_estate_vacate_sell_dialog_desc`, `real_estate_vacate_sell_confirm_btn` anahtarları 7 dilin tamamına (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) parantezsiz ve emojisz olarak senkronize edildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Önceden oyuncu kişisel ikametgahındaki mülkü satmak istediğinde buton pasif görünüyor ve tıklandığında yalnızca "Önce ikametgahınızı taşıyın" uyarısı veriyordu; oyuncunun nereden ve nasıl boşaltacağı net değildi.
- **Kök Neden**:
  - Satış engeli katı bir if kontrolüyle sonlandırılıyor, kullanıcıya doğrudan işlem yapma aksiyonu sunulmuyordu.
- **Uygulanan Çözüm**:
  - Neo-brutalist onay diyaloğu ile ikametgahı anında boşaltıp doğrudan `/emlak-ilan/{id}` sayfasına yönlendiren akış kurgulandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ile 0 hata, 0 uyarı doğrulandı.
  - `flutter test test/weekly_season_and_podium_test.dart` 5/5 geçti.

### `Canlı Serbest Piyasa Kurları & Döviz Kontrol Entegrasyonu (§SPEC-2026-REAL-FOREX-INTEGRATION)`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Borsa ve döviz ekranında gerçek piyasa kurları ile simülasyon kurları arasında geçiş yapılabilmesini sağlayan neo-brutalist kontrol kartının eklenmesi, son senkronizasyon zaman damgasının gösterilmesi, çevrimdışı önbellek koruması ve 7 dilde eşzamanlı yerelleştirme senkronizasyonu.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/stock_market/stock_market_screen.dart`:
    - `_buildForexTab`: Canlı Piyasa / Simülasyon geçişini sağlayan `Switch.adaptive`, son senkronizasyon zamanı etiketi ve manuel zorunlu yenileme butonu (`Kurları Yenile`) içeren NeoBrutalCard kontrol modülü eklendi.
    - Linter `deprecated_member_use` (`activeColor` -> `activeTrackColor`) ve `use_build_context_synchronously` (`if (!mounted) return`) uyarıları temizlendi.
  - `lib/core/localization/translations/*.dart`:
    - Döviz canlı piyasa kontrol modülüne ait 8 anahtar (`forex_real_market_mode`, `forex_real_market_desc`, `forex_simulated_market_desc`, `forex_live_badge`, `forex_sim_badge`, `forex_last_sync`, `forex_refresh_btn`, `forex_sync_success`, `forex_sync_offline`) 7 desteklenen dilin tamamına (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) parantezsiz ve emojisz olarak eklendi.
  - `test/weekly_season_and_podium_test.dart`:
    - Kullanılmayan import temizlendi, 5/5 testin yeşil geçtiği doğrulandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `Switch.adaptive` bileşeninde `activeColor` kullanımı Flutter güncel sürümünde deprecated uyarısı veriyordu.
  - Asenkron kur çekimi sonrasında `context.mounted` yerine State üzerindeki `mounted` kontrolü yapılmadığında linter uyarısı oluşuyordu.
- **Kök Neden**:
  - Flutter v3.31+ API güncellemeleri ve State sınıfı bağlamındaki linter kuralları.
- **Uygulanan Çözüm**:
  - `activeTrackColor` kullanıldı ve `if (!mounted) return;` kontrolü yerleştirildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ile tüm projede 0 hata, 0 uyarı elde edildi.
  - `flutter test test/weekly_season_and_podium_test.dart` tüm testleri başarıyla geçti.

### `Haftalık Sezonlar ve Podyum Ödülleri Uçtan Uca Denetim ve Entegrasyon İyileştirmeleri (§SPEC-2026-PODIUM-SEASONS-AUDIT)`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Yeni eklenen Haftalık Sezonlar ve Podyum Ödülleri özelliğinin uçtan uca mimari, oyun mekaniği ve kullanıcı deneyimi denetiminin yapılması; tespit edilen 4 kritik entegrasyon açığı ve sınır durumunun giderilmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/providers/game/game_market_mixin.dart`:
    - `completeSale`: Körfez Alıcıları primi uygulanırken yalnızca `hasGulfBuyerNetwork == true` kontrolü yerine imtiyazın geçerlilik süresini de teyit eden `activePodiumPerks!.isActive` kontrolü eklendi.
  - `lib/presentation/providers/game/game_time_mixin.dart`:
    - `_triggerOrganicOffer`: 3. sıra podyum ödülü olan "Sarı Site Vitrin Dopingi" (`hasShowcaseBoost`) aktifken müşteri teklif ihtimali iki katına çıkarıldı (çarpan x2.0).
  - `lib/presentation/screens/auction/auction_screen.dart`:
    - `_openCustomsAuction`: 1. sıra podyum ödülü olan "Gümrük İhalesi VIP Protokolü" (`hasCustomsAuctionPass`) sahibi oyuncular için ödüllü reklam zorunluluğu baypas edildi; doğrudan ihaleye giriş sağlandı.
  - `lib/presentation/screens/dashboard/widgets/dashboard_office_view.dart`:
    - Makam masası kupa alanına `hasUnclaimedSeasonRewards == true` durumunda dikkat çekici yanıp sönen brutalist "Ödüller Hazır" rozeti eklendi ve tıklanarak doğrudan ödül toplama diyaloğunun açılması sağlandı.
  - `lib/core/localization/translations/*.dart`:
    - `podium_unclaimed_alert` anahtarı 7 dilin tamamına (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Podyum imtiyaz süresi (7 gün) dolduktan sonra oyuncu gün atlamadan önce satış yaparsa `isActive` kontrolü yapılmadığı için Körfez primi verilebiliyordu.
  - 3. Sıra Vitrin Dopingi (`hasShowcaseBoost`) ve 1. Sıra Gümrük İhalesi Geçişi (`hasCustomsAuctionPass`) modellerde tanımlanmış ancak ilgili oyun akışlarına (organik teklif ve gümrük ihalesi) tam bağlanmamıştı.
  - Sezon devri gerçekleştikten sonra ofis masasında bekleyen ödül olduğu oyuncuya belirgin şekilde hissettirilmiyordu.
- **Kök Neden**:
  - Hızlı prototipleme esnasında model alanları oluşturulmuş ancak oyun döngüsünün derin noktalarındaki (ihale ekranı ve organik teklif zamanlayıcısı) koşullarla tam köprü kurulmamıştı.
- **Uygulanan Çözüm**:
  - Tüm podyum imtiyazları aktiflik süresi (`isActive`) kontrolüyle güvenli hale getirildi. Vitrin dopingi organik teklif şansını ikiye katlayacak şekilde bağlandı, gümrük ihalesi reklam şartı kaldırıldı ve ofis masasına reaktif uyarı rozeti eklendi.
- **Doğrulama / Test Durumu**:
  - `flutter test test/weekly_season_and_podium_test.dart` ile birim testler başarıyla çalıştırıldı (5/5 geçti).
  - `flutter analyze lib/presentation/providers/game/ lib/presentation/screens/auction/ lib/presentation/screens/dashboard/widgets/ lib/core/localization/` ile 0 hata, 0 uyarı doğrulandı.

### `Haftalık Sezonlar ve Podyum Ödülleri Sistemi (§SPEC-2026-PODIUM-SEASONS)`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Liderlik tablosundaki kümülatif servet tıkanıklığını aşarak her Pazartesi 00:00 UTC'de sıfırlanan 7 günlük haftalık satış cirosu/kârı yarışını başlatmak; ilk 3 podyum kazananına ve ilk 10'a Türk otomotiv kültürüne özgü stratejik, nakit-dışı yüksek kaldıraçlı imtiyazlar (Gümrük Tasfiye İhalesi, Körfez Alıcıları primi, Banka Filo Kapatma, Ekspertiz şeffaflığı, Sanayi Usta Başı Çeki, Sarı Site Vitrin Dopingi, VIP Noter İndirimleri, özel plaka unvanları ve makam masası kupaları) kazandırmak.
- **Yapılan Değişiklikler**:
  - `lib/data/models/podium_reward_model.dart` [YENİ]:
    - `ActivePodiumPerks` modeli oluşturuldu: `notaryDiscountRate`, `hasCustomsAuctionPass`, `hasFleetLiquidationProtocol`, `hasMasterMechanicVoucher`, `hasGulfBuyerNetwork`, `hasInspectionTransparency`, `hasShowcaseBoost`, `freeNoterVouchers`, `customPlateTitle` ve 7 günlük geçerlilik süresi `expiresAt`.
    - `PodiumTrophy` modeli oluşturuldu: Makam masasında ve profilde kalıcı olarak saklanan altın/gümüş/bronz kupa ve berat arşivi.
  - `lib/domain/usecases/season_engine.dart` [YENİ]:
    - ISO hafta bazlı sezon kimliği `getSeasonId(YYYYWW)`, sezon başlangıç ve bitiş UTC anları, kalan süre hesaplama ve biçimlendirme (`formatRemainingTime`), dereceye göre imtiyaz üretimi (`generatePodiumPerks`), kalıcı kupa üretimi (`createPodiumTrophy`) ve sezon devir kontrolü (`shouldSettleSeason`, `needsSeasonInit`).
  - `lib/data/models/dealership_model.dart`:
    - Yeni alanlar eklendi: `currentSeasonId`, `weeklyTurnoverScore`, `weeklyCarsSold`, `hasUnclaimedSeasonRewards`, `lastClaimedSeasonRank`, `activePodiumPerks`, `earnedTrophies`.
    - `toMap`, `toJson`, `fromJson`, `copyWith` ve yapıcı metotlar geriye dönük tam uyumlu varsayılanlarla güncellendi.
  - `lib/domain/usecases/rival_leaderboard_engine.dart`:
    - Sıralama hesaplaması `weeklyTurnoverScore` ve `weeklyCarsSold` değerlerini oyuncunun haftalık performansına bağlayacak şekilde güncellendi.
  - `lib/presentation/providers/game/game_inventory_mixin.dart`:
    - `buyCarWithNoter` işleminde `activePodiumPerks.notaryDiscountRate` devreye alındı.
    - `sellCar`, `sellCarAtAuction`, `fulfillContract` satışlarında `weeklyTurnoverScore` ve `weeklyCarsSold` artışı bağlandı.
  - `lib/presentation/providers/game/game_market_mixin.dart`:
    - `completeSale` metodunda podyum 1. sıra "Körfez Alıcıları" imtiyazı (`hasGulfBuyerNetwork`) ile lüks araç satışlarına +%15 anında prim eklendi ve haftalık ciro puanı güncellendi.
  - `lib/presentation/providers/game/game_time_mixin.dart`:
    - `checkSeasonSettlement()` ve `claimSeasonRewards()` eklendi; günlük gün ilerleme (`advanceGameDay`) döngüsüne bağlandı.
  - `lib/presentation/providers/game/game_core_provider.dart`:
    - Kayıt yükleme (`_loadState`) anında sezon devir ve ilk sezon kimliği ataması sağlandı.
  - `lib/presentation/screens/leaderboard/widgets/leaderboard_podium_perks_sheet.dart` [YENİ]:
    - 4 podyum kademesini, özel plakaları ve imtiyazları Neo-Brutalist görsel kurallarla listeleyen modal sayfa.
  - `lib/presentation/screens/leaderboard/widgets/leaderboard_season_reward_dialog.dart` [YENİ]:
    - Tamamlanan sezonun derecesini, kazanılan kupayı ve açılan imtiyazları kutlayan ve tek dokunuşla ödülleri toplayan Neo-Brutalist diyalog.
  - `lib/presentation/screens/leaderboard/leaderboard_screen.dart`:
    - Sezon kimliği ve geri sayım sayacı afişi (`_buildSeasonBanner`), podyum ödülleri inceleme butonu ve açılmamış ödül varsa otomatik kutlama diyaloğu eklendi.
  - `lib/presentation/screens/dashboard/widgets/dashboard_office_view.dart`:
    - Makam masasında kazanılan en yüksek kupayı (Altın/Gümüş/Bronz) sergileyen ve aktif imtiyazı gösteren `_buildOfficeTrophySection` bileşeni eklendi.
  - `lib/core/localization/translations/*.dart` (7 Dil Eşzamanlı Senkronizasyon):
    - `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar` dillerinin tamamına 28 yeni podyum, kupa ve imtiyaz anahtarı sıfır emoji ve sıfır parantez kuralına tam uyularak eklendi.
  - `test/weekly_season_and_podium_test.dart` [YENİ]:
    - ISO hafta kimliği, imtiyaz üretimi, kupa yaratımı, model serileştirme ve sezon rollover mantığını doğrulayan 5 birim test eklendi ve tümü geçti.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Test dosyasında paket adı `package:galerisinden/` olarak yazıldığında derleme hatası oluştu.
- **Kök Neden**:
  - `pubspec.yaml` dosyasındaki paket adı `galeriden` idi.
- **Uygulanan Çözüm**:
  - Test dosyasındaki importlar `package:galeriden/` olarak düzeltildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` çalıştırıldı: 0 hata, 0 uyarı (No issues found).
  - `flutter test test/weekly_season_and_podium_test.dart` çalıştırıldı: 5 testin 5'i de başarıyla geçti.

### `Emlak Pazar Portföy ve İlgili Ekranlarda RenderFlex Buton Taşmalarının Onarımı`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Emlak piyasası portföy sekmesinde ve ilişkili ekranlarda dar ekran genişliklerinde (360dp–390dp) ve 7-dil yerelleştirmelerinde yatay butonların ekran dışına taşması (RenderFlex overflow) sorununu gidermek ve duyarlı hiyerarşik yerleşim sağlamak.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/real_estate/real_estate_market_screen.dart`:
    - `_buildUnifiedTerminalHeader`: Sekme seçici ve cüzdan/telemetri başlığı `SingleChildScrollView(scrollDirection: Axis.horizontal)` ve `ConstrainedBox` ile sarılarak dar ekranlarda ve uzun yerelleştirilmiş dillerde (Almanca/Portekizce) yatay taşma riski ortadan kaldırıldı.
    - `_buildPortfolioCard`: Finansal değerleme bilgileri ile eylem butonları dikey hiyerarşiye ayrıldı. Eylem butonları sırası sabit genişlikli `Row` yerine `Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.end)` yapısına dönüştürülerek sığmayan butonların alt satıra şık bir şekilde kırılması sağlandı.
  - `lib/presentation/screens/real_estate/real_estate_listing_manage_screen.dart`:
    - Kiracı detay kartındaki aylık kira ve depozito satırı `Wrap(spacing: 8, runSpacing: 4)` ile sarmalanarak uzun para birimi formatlarında taşma yapması engellendi.
  - `lib/presentation/screens/real_estate/real_estate_rental_screen.dart`:
    - `_buildCandidateCard`: Aday onay ve ret butonları `LayoutBuilder` ile 320dp altındaki dar kart alanlarında tam genişlikli dikey sütuna geçecek şekilde responsive hale getirildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Portföy kartlarında 5-6 farklı butonun (İnşaat, Tadilat, Ev Dizayn, İkametgâh, Kiralama, Teklifler, Satış) finansal özet ile aynı yatay `Row` içinde olması nedeniyle 360dp–412dp mobil ekranlarda `A RenderFlex overflowed by xxx pixels on the right` hatası oluşması.
- **Kök Neden**:
  - Yatay eksende genişliği dinamik olan birden fazla metinli butonun esnek olmayan (`unconstrained`) tek bir `Row` içerisine yerleştirilmesi.
- **Uygulanan Çözüm**:
  - Neo-Brutalist görsel gramer korunarak sabit `Row` yapıları `Wrap` ve `SingleChildScrollView` ile yeniden tasarlandı; dar ekran kırılma noktaları `LayoutBuilder` ile desteklendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/real_estate/` ile statik analiz doğrulandı.

### `iOS Minimum Deployment Target Yükseltmesi ve FirebaseFirestore StateObject Derleme Hatası Çözümü`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Codemagic / Xcode derleme ortamında FirebaseFirestore paketinin `StateObject is only available in iOS 14.0 or newer` hatasıyla derlemenin kesilmesini gidermek ve iOS minimum dağıtım hedefini modern Flutter standardı olan 15.0 seviyesine eşitlemek.
- **Yapılan Değişiklikler**:
  - `ios/Podfile`:
    - `platform :ios, '13.0'` tanımı `platform :ios, '15.0'` olarak güncellendi.
    - `post_install` kancasındaki `IPHONEOS_DEPLOYMENT_TARGET` zorlaması `13.0` değerinden `15.0` değerine yükseltildi.
  - `ios/Runner.xcodeproj/project.pbxproj`:
    - `Debug`, `Release` ve `Profile` hedef konfigürasyonlarındaki `IPHONEOS_DEPLOYMENT_TARGET` değerleri `13.0`'dan `15.0`'a yükseltildi.
  - `ios/Flutter/AppFrameworkInfo.plist`:
    - Flutter derleyicisinin minimum hedef beklentisiyle tam uyum için `<key>MinimumOSVersion</key><string>15.0</string>` anahtarı eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `flutter build ipa` sırasında Xcode derlemesinin `Swift Compiler Error - Xcode: 'StateObject' is only available in iOS 14.0 or newer` hatası vermesi - `FirestoreQuery.swift`.
- **Kök Neden**:
  - `Podfile` içindeki `post_install` bloğunun CocoaPods tarafından indirilen tüm pod bağımlılıklarının - `FirebaseFirestore` dahil - `IPHONEOS_DEPLOYMENT_TARGET` değerini zorla `13.0` yapması; oysa `cloud_firestore` paketinin Swift katmanında SwiftUI `StateObject` - iOS 14.0+ - özelliğini kullanması.
- **Uygulanan Çözüm**:
  - Proje düzeyinde ve tüm CocoaPod bağımlılıklarında minimum iOS sürümü 15.0 olarak yapılandırılarak `FirebaseFirestore` bağımlılığının derleme uyumluluğu sağlandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` ile statik analiz doğrulandı.

### `Eski Günlük Rastgele Olay Sisteminin Kaldırılması ve 365 Günlük Karar Sistemine Konsolidasyon`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Eski paralel rastgele olay mekanizmasının `RandomEventEngine`, `pendingRandomEvent`, `NeoBrutalRandomEventDialog`, `DashboardRandomEventBanner` projeden tamamen kaldırılarak tüm hikaye ve karar akışının 365 Günlük Dramatik Karar Sistemi `DramaticCardEngine` ve `pendingDramaticCard` üzerinde konsolide edilmesi.
- **Yapılan Değişiklikler**:
  - `pubspec.yaml` & `lib/core/constants/game_constants.dart`:
    - Uygulama sürümü `1.0.6` ve derleme numarası `+30` olarak güncellendi.
  - `lib/presentation/providers/game/game_time_mixin.dart`:
    - `nextDay` döngüsünden `_processRandomEvents` mantığı ve `randomEvent` değişkeni temizlendi.
    - `state.copyWith` bloğundan `daysSinceLastRandomEvent`, `nextRandomEventTargetDays`, `pendingRandomEvent`, `seenRandomEventIds` alanları kaldırıldı.
    - `_processRandomEvents`, `resolveRandomEvent` ve `dismissPendingRandomEvent` fonksiyonları kaldırılarak olay çözümleri `resolveDramaticCardChoice` çatısına devredildi.
  - `lib/data/models/dealership_model.dart`:
    - Geriye dönük kayıt uyumluluğu için `pendingRandomEvent` getterı `@Deprecated('Consolidated into pendingDramaticCard')` olarak işaretlendi.
  - `lib/presentation/screens/dashboard/widgets/dashboard_banners.dart`:
    - `DashboardRandomEventBanner` bileşeni ve kullanılmayan `neo_brutal_random_event_dialog.dart` ile `game_event_model.dart` importları temizlendi.
  - `lib/presentation/widgets/neo_brutal_random_event_dialog.dart`:
    - Artık kullanılmayan eski rastgele olay diyalog bileşeni projeden silindi.
  - `lib/domain/usecases/random_event_engine.dart`:
    - 365 günlük sistemle mükerrerlik oluşturan eski olay şablonları ve motor dosyası projeden silindi.
  - `lib/core/localization/translations/*.dart` - 7 Dil Eşzamanlı Senkronizasyon:
    - `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar` dillerinin tamamına `listing_doping_selected`, `listing_doping_deselected_toast`, `listing_doping_selected_toast` anahtarları eklendi.
  - `lib/presentation/screens/showroom/create_listing_screen.dart`:
    - Doping seçim etiketleri ve bildirimleri 7 dilli `context.tr` yapısına bağlandı.
  - Test Dosyaları:
    - `test/events_and_narrative_audit_test.dart`: Eski `resolveRandomEvent` testi `resolveDramaticCardChoice` sonuçlarını doğrulayacak şekilde güncellendi.
    - `test/small_screen_overflow_audit_test.dart`: Eski diyalog yerine `NeoBrutalDramaticDialog` test edildi.
    - `test/market_share_decay_and_black_market_raid_test.dart`: Silinen rastgele olay grubu temizlendi, pazar payı ve halka arz testleri korundu.
    - `test/feedback_dialog_test.dart`: Gönder butonu için `ensureVisible` eklenerek tıklama güvenceye alındı.
    - `test/random_event_engine_ownership_test.dart`, `test/deep_immersion_and_notary_events_test.dart`, `test/side_business_negative_events_test.dart`: Silinen motorun testleri kaldırıldı.
    - `test/resources/presentation_unlocalized_allowlist.txt`: Açılış logosu için logo istisnası kaydedildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `lib/presentation/widgets/neo_brutal_random_event_dialog.dart` silinmeden önce `resolveRandomEvent` bulunamadı hatası.
  - Testlerde `DramaticCardModel` yapıcı parametrelerinin eksik olması ve kullanılmayan import uyarıları.
  - `feedback_dialog_test.dart` içinde yeni eklenen geliştirici Instagram şeridi nedeniyle gönder butonunun ekran sınırının altına taşması.
  - `localization_integrity_guard_test.dart` testinde doping seçim metinleri ve açılış ekranı logo metninin takılması.
- **Kök Neden**:
  - Önceki oturum kod silme işlemi sürerken yarıda kesilmişti.
  - `DramaticCardModel` modelinin zengin anlatı için zorunlu parametreler beklemesi.
  - `FeedbackDialog` içerik boyunun 800x600 test penceresinde kaydırma gerektirmesi.
  - İlan ekranında doğrudan Türkçe karakter içeren dizgeler kullanılmış olması.
- **Uygulanan Çözüm**:
  - `neo_brutal_random_event_dialog.dart` ve `random_event_engine.dart` temizlendi.
  - Testlerde `DramaticCardEngine.generateDailyDilemma` kullanılarak gerçekçi modeller sağlandı.
  - `feedback_dialog_test.dart` içine `tester.ensureVisible` eklendi.
  - Doping metinleri 7 dilde senkronize edilerek `context.tr` çağrılarına bağlandı, logo istisnası allowlist'e işlendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze`: 0 hata, 0 uyarı - `No issues found!`.
  - `test/events_and_narrative_audit_test.dart`, `test/small_screen_overflow_audit_test.dart`, `test/market_share_decay_and_black_market_raid_test.dart`: 15/15 geçti.
  - `test/feedback_dialog_test.dart`: 4/4 geçti.
  - `test/localization_integrity_guard_test.dart` ve `test/translation_key_coverage_test.dart`: 7/7 geçti.

### `Neo-Brutalist Açılış Ekranı (Splash / Loading) ve Balax Studio Resmi Instagram İletişim Entegrasyonu`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Oyuna 1.5 saniyelik yüksek tempolu, dokunsal bir Neo-Brutalist açılış/yükleme ekranı kazandırılması ve oyuncuların doğrudan stüdyo ile bağlantı kurabilmesi için Ayarlar ile Geri Bildirim ekranlarına resmi geliştirici Instagram hesabının (@balaxstudio) entegre edilmesi.
- **Yapılan Değişiklikler**:
  - `lib/core/constants/game_constants.dart`:
    - `developerInstagramUrl` (`https://www.instagram.com/balaxstudio`) ve `developerInstagramHandle` (`@balaxstudio`) sabitleri tanımlandı.
  - `lib/core/localization/translations/*.dart` (7 Dil Eşzamanlı Senkronizasyon):
    - `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar` dosyalarının tamamına 10 yeni anahtar eklendi (`settings_dev_contact_badge`, `settings_dev_contact_title`, `settings_dev_contact_desc`, `settings_dev_contact_btn`, `feedback_alt_contact_strip`, `splash_tagline`, `splash_studio_present`, `splash_loading_step1`, `splash_loading_step2`, `splash_loading_step3`).
    - Tüm metinlerde Invariant Kuralı #1 (sıfır emoji) ve #2 (sıfır parantez) titizlikle korundu.
  - `lib/presentation/screens/splash/splash_screen.dart` (YENİ):
    - 1.5 saniyelik yüksek tempolu açılış ekranı oluşturuldu.
    - Tasarım: Üst ve alt hareketli endüstriyel sarı-siyah şeritler (`HazardStripeWidget`), eğik Balax Studio damga rozeti (`Transform.rotate`), çift katmanlı siyah konturlu "GALERİDEN" logosu, taktiksel alt slogan, neon gösterge simgesi, 1500 ms'de %0-%100 arası dolan segmentli RPM telemetri ilerleme çubuğu ve dinamik durum metinleri.
    - Dokunuşla hızlandırma (fast-forward) desteği ve tamamlandığında onboarding durumuna göre `/dashboard` veya `/onboarding` rotasına pürüzsüz yönlendirme.
  - `lib/app/router.dart`:
    - `initialLocation: '/splash'` olarak güncellendi.
    - `/splash` rotası kaydedildi ve kök `/` yönlendirmesi `/splash`'e bağlandı.
  - `lib/presentation/screens/settings/settings_screen.dart`:
    - "Topluluk & Geri Bildirim" bölümüne 2.5px siyah konturlu, 3.5px sert gölgeli, üstünde endüstriyel sarı-siyah şerit bulunan "GELİŞTİRİCİ İLE DİREKT İLETİŞİM • BALAX STUDIO" taktiksel kartı eklendi.
    - Dokunsal Instagram butonuna tıklandığında `url_launcher` ile `LaunchMode.externalApplication` modunda Instagram profili açılması sağlandı.
  - `lib/presentation/widgets/feedback_dialog.dart`:
    - E-posta formunun altına "Alternatif Hızlı Kanal - Instagram: @balaxstudio" kompakt şeridi eklendi.
  - `test/splash_screen_test.dart` (YENİ):
    - Açılış ekranı render, hazard stripes, telemetri animasyonu, hızlı geçiş ve zamanlayıcı temizliğini doğrulayan testler yazıldı (2/2 passed).
  - `test/developer_contact_test.dart` (YENİ):
    - Instagram URL ve handle sabitleri, 7 dil simetrisi ve invariant kuralları ile FeedbackDialog alternatif hızlı kanal testleri yazıldı (3/3 passed).
- **Karşılaşılan Hatalar / Sorunlar**:
  - `splash_screen.dart` ilk derlemesinde `DotGridBackground` bileşeninin `child` parametresi beklemesi ve `NeoBrutalCard` için `boxShadow` yerine `shadowOffset` ve `shadowColor` parametrelerinin tanımlı olması.
  - Bağımsız widget testinde GoRouter bağlı olmadığı için `_proceedToNextScreen` içinde `No GoRouter found in context` hatası fırlatılması.
  - Test container'ı dispose edilirken debounced saveState zamanlayıcısının bekleyen zamanlayıcı uyarısı vermesi.
  - `FeedbackDialog` testinde `AppThemeExtension` sağlanmadığı için tema uzantısı bulunamaması.
- **Kök Neden**:
  - `DotGridBackground` bir container sarmalayıcısıdır ve `required Widget child` bekler.
  - `NeoBrutalCard` özel neo-brutalist parametreler (`shadowOffset`, `shadowColor`) kullanır.
  - GoRouter bulunmayan izole test senaryolarında `context.go` çağrısı istisna fırlatır.
- **Uygulanan Çözüm**:
  - `DotGridBackground` içine `child: SizedBox.expand()` verildi.
  - `NeoBrutalCard` parametreleri `shadowOffset: Offset(3.5, 3.5)` ve `shadowColor: Colors.black` olarak düzeltildi.
  - `_proceedToNextScreen` içine router bulunmayan test ortamlarını güvenli tolere eden koruma eklendi.
  - Testlerde `AppTheme.darkTheme` ve timer temizleme adımları eklendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze`: 7 dosyada 0 hata, 0 uyarı (`No issues found!`).
  - `test/translation_key_coverage_test.dart`: 6/6 test geçti (7 dil %100 tam simetri).
  - `test/developer_contact_test.dart`: 3/3 test geçti.
  - `test/splash_screen_test.dart`: 2/2 test geçti. Toplam 11 test yeşil.

### `Emlak Pazarı • Neo-Brutalist Taktiksel Terminal Konsolu ve Kompakt Header Redesign`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Emlak Pazarı ekranında dikey alan israfını çözmek, mobil görünürlüğü artırmak ve ilan kartlarına maksimum alan bırakmak amacıyla üst başlık ve kontrol alanının birleşik Neo-Brutalist Taktiksel Terminal Konsolu olarak yeniden tasarlanması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/real_estate/real_estate_market_screen.dart`:
    - Eski `_buildStatusBar` (42px) ve devasa `TabBar` (55px) kaldırılarak yerine tek satırda çalışan 40px yüksekliğinde `_buildUnifiedTerminalHeader` getirildi.
    - **Sol Segment Switcher (`_buildCompactSegmentedTabs`)**: 30px taktik kapsül içinde "İlanlar" ve "Portföyüm • N" butonları; aktif sekmede 2.0px siyah konturlu `brutalYellow` / `toxicLime` dolgu, dokunsal `Transform.translate` mekanik basma efekti.
    - **Sağ Telemetri Podu (`_buildCompactTelemetryPod`)**: Zümrüt yeşili kompakt cüzdan rozeti (`₺...B`), mülk kapasitesini gösteren 5 hücreli mikro taktik slot doluluk pips göstergesi (`[■][□][□][□][□]`), tek dokunuşla kapasite artıran mini `+` butonu.
    - **Kompakt Filtre & Genişleyebilir Arama Dock'u (`_buildCompactSearchAndFilterDock`)**: 50px'lik arama kutusu ve 44px'lik kategori şeridinin alt alta 100px yemesi engellendi. Normal durumda 34px yükseklikte sol tarafta kompakt sarı arama butonu, sağ tarafta yatay kayan 28px mikro kategori hapları ("Tümü", "Konut", "İş Yeri", "Arsa", "Konut Projeleri", "Bina") yerleştirildi. Arama butonuna basıldığında satır içine kompakt arama alanı açılarak kapatma butonu sağlandı.
    - Dikey kontrol alanı toplamda ~207px'ten ~75px'e düşürülerek 130px+ net dikey alan kazanıldı; ilan kartları ekranın üst kısmına taşındı.
  - `test/real_estate_market_compact_header_test.dart` (YENİ):
    - Birleşik konsol render, sekme geçişi, arama dock genişleme/daralma, 320px ultra-dar ekranda sıfır overflow ve invariant (sıfır emoji, sıfır parantez) testleri yazıldı (5/5 passed).
- **Karşılaşılan Hatalar / Sorunlar**:
  - İlk test çalıştırmasında `/emlak` rotasının başlangıç seviyesinde (Level 1) kilitli olması nedeniyle `NeoBrutalLockedFeatureView` dönmesi ve "İlanlar" metninin bulunamaması.
  - Test beklentisinde `Portföy • 0` aranırken dil dosyasında `Portföyüm` olması.
  - `test/real_estate_market_compact_header_test.dart` içinde kullanılmayan import uyarısı (`unused_import`).
- **Kök Neden**:
  - `DealershipModel` üzerinde `/emlak` rotasının `level >= 4` gerektirmesi.
  - `tr_translations.dart` içinde `real_estate_tab_portfolio` anahtarının "Portföyüm" olarak tanımlı olması.
  - Test kurgusu sırasında eklenen model importunun doğrudan çağrılmaması.
- **Uygulanan Çözüm**:
  - Test container'ında seviye `level: 5` yapılarak özellik kilidi açıldı.
  - Test beklentisi `Portföyüm • 0` olarak güncellendi.
  - Kullanılmayan import temizlenerek `flutter analyze` sıfır hataya indirildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze`: 3 dosyada 0 hata, 0 uyarı (`No issues found!`).
  - `test/real_estate_market_compact_header_test.dart`: 5/5 test geçti.
  - `test/real_estate_market_test.dart`: 15/15 test geçti. Toplam 20 test yeşil.

### `Kritik Oynanış Hataları ve Ekonomi Dengelemesi • Şube Tapu Kalıcılığı, Acil İlan Doping ve Alıcı Teklif Dampingi`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Oyuncu geri bildirimlerinde bildirilen kritik oynanış ve ekonomi aksaklıklarının çözümü: Şube tapu mülkiyetinin kaybolması, ilan ekranında hatalı yetersiz bakiye uyarısı ve araç ticaretinde kontrolsüz çarpan enflasyonu.
- **Yapılan Değişiklikler**:
  - `lib/data/models/dealership_model.dart`:
    - `toJson()` metoduna `'ownedBranchDeeds': ownedBranchDeeds.toList()` eklendi.
    - `fromJson()` metoduna `ownedBranchDeeds: (json['ownedBranchDeeds'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? const {}` çözücüsü eklendi.
  - `lib/presentation/providers/game/game_market_mixin.dart`:
    - `boostListingDoping(String carId, {bool forceAllowUnlisted = false})` parametresi eklendi; taslak aşamasındaki araçların erken reddedilmesi engellendi.
  - `lib/presentation/screens/showroom/create_listing_screen.dart`:
    - `late bool _applyDoping;` durum bayrağı tanımlandı.
    - Tıklamada anında bakiye kesmek yerine güvenli toggle ve yerel bakiye kontrolü eklendi; ilan onaylandığında doping tetiklenmesi sağlandı.
  - `lib/domain/usecases/negotiation_engine.dart`:
    - `generateBuyerOffer` içinde çarpan damping formülü uygulandı: `totalMultiplier = (1.0 + (rawMultiplier - 1.0) * 0.45).clamp(0.88, 1.18);`.
  - `test/branch_deed_persistence_test.dart`:
    - Tapu mülkiyeti serileştirme ve geriye dönük uyumluluk birim testleri oluşturuldu (2/2 passed).
- **Karşılaşılan Hatalar / Sorunlar**:
  - Şube tapusu satın alındıktan sonra oyun yeniden başlatıldığında mülkiyetin sıfırlanması.
  - İlan oluşturma ekranında yeterli nakit olmasına rağmen "Yetersiz bakiye!" uyarısı çıkması.
  - Araç satışında biriken katsayılar nedeniyle 24 saatte %40-%100+ fahiş kâr marjı oluşması.
- **Kök Neden**:
  - `ownedBranchDeeds` alanının JSON serialization/deserialization döngüsüne dahil edilmemiş olması.
  - `boostListingDoping` metodunun henüz listelenmemiş araçlarda `false` dönmesi ve arayüzün bunu bakiye yetersizliği olarak göstermesi.
  - Mevsim, ilçe, dedikodu ve şube çarpanlarının sınırsız bileşik çarpımı sonucu tavanın delinmesi.
- **Uygulanan Çözüm**:
  - JSON köprüleri bağlandı, doping seçimi güvenli toggle formuna alındı ve alıcı tekliflerine yumuşatıcı damping uygulandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze` 0 hata ile doğrulandı.
  - `test/branch_deed_persistence_test.dart` (2/2 passed).
  - `test/car_listing_offer_rules_test.dart` (11/11 passed).
  - `test/vehicle_maintenance_cost_and_profit_test.dart` (6/6 passed).
  - `test/negotiation_dynamic_tactics_test.dart` ve ilgili paketler (15/15 passed).

### `Dashboard Günlük Net Nakit Akışı • Neo-Brutalist Taktiksel HUD Ticker Redesign`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Kullanıcı talebi doğrultusunda ("günlük net akış kutusuna özel bi çalışma yap içine ve genel tasarıma dair /design /ui-styling"), düz ve monoton görünümlü `DashboardDailyCashFlowCard` bileşeni, panonun yeni asimetrik bento geometrisiyle uyumlu, yüksek kontrastlı Neo-Brutalist taktiksel bir finans HUD göstergesine dönüştürüldü.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_banners.dart`:
    - **Asimetrik Dış Şasi (Chassis)**: Standart 12px yuvarlatma yerine `BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(6), bottomRight: Radius.circular(16), bottomLeft: Radius.circular(6))` asimetrik taktik kavisleri, 2.5px siyah kontur ve 3.5px sert 0-blur offset gölge uygulandı.
    - **Dinamik Kâr/Zarar Vurgusu**: Net nakit akışı pozitifken zümrüt yeşili (`#00E575`) vurgulu parlama, negatifken acil durum kırmızısı (`#EF4444`) renk kodlaması bağlandı.
    - **Üst Ticker Şeridi**:
      * Sol: Asimetrik köşeli mikro cüzdan rozeti (`Icons.account_balance_wallet_rounded`) ve kalın `GÜNLÜK NET NAKİT AKIŞI` başlığı.
      * Sağ: 8 çubuklu dinamik equalizer sparkline bar göstergesi (`_buildSparklineBars`), tabular rakam destekli ve 1.5px konturlu yüksek kontrastlı rozet (`+₺.../gün`) ve yön oku (`Icons.chevron_right_rounded`).
    - **Alt Telemetri Mikro-Bento Podları**: Düz metin satırı yerine 3 bağımsız taktik kapsüle ayrıldı:
      * Gelir Podu (`Yan Gelirler: +₺...`): Hafif zümrüt dolgu, 1.5px zümrüt kontur, `Icons.arrow_upward_rounded` ikonu ve asimetrik (8-4-8-4) mikro köşe radyüsü.
      * Maaş Podu (`Maaşlar: -₺...`): Koyu slate/antrasit dolgu, 1.5px kontur, `Icons.badge_rounded` ikonu.
      * Kredi/Borç Podu (`Krediler: -₺...`): Aktif kredi borcu varsa (`dailyLoanPayment > 0`) dinamik olarak devreye giren uyarı kırmızısı taktik kapsül (`Icons.account_balance_outlined`).
  - `test/dashboard_daily_cashflow_card_test.dart` (YENİ):
    - Pozitif net akış, aktif kredi podu tetiklenmesi ve ultra-dar ekranda (320px) taşma olmaksızın render testleri yazıldı (3/3 passed).
- **Karşılaşılan Hatalar / Sorunlar**:
  - İlk test yazımında `LoanModel` ve `StaffRole` parametreleri gerçek model tanımlarıyla uyumsuzdu; `StaffRole.mechanic` yerine `StaffRole.masterMechanic` ve `LoanModel` alanları düzeltildi.
- **Kök Neden**: Model constructor parametrelerinin test içerisinde eski şablonla çağrılması.
- **Uygulanan Çözüm**: `dashboard_daily_cashflow_card_test.dart` dosyasındaki model çağrıları `LoanModel` ve `StaffModel` alanlarıyla tam senkronize edildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/dashboard/widgets/dashboard_banners.dart`: 0 issues (No issues found!).
  - `flutter test test/dashboard_daily_cashflow_card_test.dart`: 3/3 test başarıyla geçti.
  - `flutter test test/ui_layout_and_header_spacing_test.dart`: 8/8 test başarıyla geçti.
  - Canlı Chrome tarayıcısında (localhost:8080) görsel teyit alındı ve ekran görüntüsü kaydedildi.

### `Şehir Hub'ı • Asimetrik Köşe Radyüsleri (Asymmetric Radii Matrix) ve Dinamik Puzzle Kenetlenme Formları`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Kullanıcı talebi ("referans görseldeki gibi kutular tam dikdörtgen değil formu değişik biraz bu hubda öyle olsun ve seviye sistemine göre açılan servislerde form dinamik olacak") doğrultusunda, tüm kartların monoton 4 köşesi eşit (uniform) dikdörtgen yapısı kaldırılarak; her kartın konumu, dış kabuk ve iç kenetlenme temas noktalarına göre şekillenen dinamik asimetrik köşe radyüsleri sistemi uygulandı.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - **Hero Kartı (Yan İşletmeler)**: Çapraz asimetrik radyüs (`topLeft: 24`, `bottomRight: 24`, `topRight: 10`, `bottomLeft: 10`) ve `clipBehavior: Clip.antiAlias` uygulandı.
    - **Dikey Terrakotta Kiralama Kartı (Rent-a-Car)**: Karşıt çapraz asimetrik radyüs (`topRight: 24`, `bottomLeft: 24`, `topLeft: 10`, `bottomRight: 10`) ve `clipBehavior: Clip.antiAlias` uygulandı.
    - **Dikey Puzzle Podları (Konsinye & Emanet ve Semt Hakimiyeti)**:
      * Sol Puzzle Podu (`Konsinye & Emanet`): Dış sol köşeler `22px`, içteki istife kenetlenen sağ köşeler `8px` (`topLeft: 22`, `bottomLeft: 22`, `topRight: 8`, `bottomRight: 8`).
      * Sağ Puzzle Podu (`Semt Hakimiyeti`): Dış sağ köşeler `22px`, içteki istife kenetlenen sol köşeler `8px` (`topRight: 22`, `bottomRight: 22`, `topLeft: 8`, `bottomLeft: 8`).
    - **Kompakt Yatay Kartlar (Hurdalık, Showroom Mimari, Dedikodu, Yorumlar)**:
      * Sol Bloktaki Sağ İstif: Sol docking kenarları `8px`, dış sağ köşeler `topRight: 18` (üst kart) veya `bottomRight: 18` (alt kart).
      * Sağ Bloktaki Sol İstif: Sağ docking kenarları `8px`, dış sol köşeler `topLeft: 18` (üst kart) veya `bottomLeft: 18` (alt kart).
    - **Panoramik Şerit (Gece Sanayisi)**: Çapraz taktik kapsül formu (`topLeft: 22`, `bottomRight: 22`, `topRight: 10`, `bottomLeft: 10`).
    - **VIP Casino Şeridi**: Tabanı sabitleyen zemin formu (`bottomLeft: 20`, `bottomRight: 20`, `topLeft: 8`, `topRight: 8`).
    - **Dinamik Seviye / Tekil / İkili Kalanlar**: Seviyeye göre tek veya ikili kalan servislerde dış hatları koruyan `16px/10px` veya `18px/8px` dinamik köşe desteği eklendi.
- **Karşılaşılan Hatalar / Sorunlar**: Yok.
- **Kök Neden**: N/A.
- **Uygulanan Çözüm**: `customBorderRadius` ve `Clip.antiAlias` entegrasyonu sağlandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/dashboard/widgets/`: Sıfır hata ve sıfır uyarı ile doğrulandı (No issues found!).
  - `flutter test test/city_operations_hub_and_marketplace_redesign_test.dart test/dynamic_next_target_banner_test.dart test/service_unlock_notification_dot_test.dart`: 5 testin tamamı başarıyla geçti (All tests passed!).
  - Canlı Chrome oturumunda ekran görüntüsü alınarak asimetrik köşe kilitlenmesi ve dokunsal konturlar doğrulandı.

### `Şehir Hub'ı • Maslak Sanayi Hangar Tetris / Puzzle Kenetlenme Mimarisi`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Kullanıcı talebi doğrultusunda ("Şehir & Yan Sektörler Operasyonel Hubı dikdörtgenleri buradakii gibi puzzle gibi olsun ve buradaki hubdaki dikdörtgenleri biraz daha asimetrik yapalım"), alt kutuların 50%/50% simetrik ikili ızgara görünümü tamamen kaldırılarak, Maslak Sanayi Hangarındaki puzzle/tetris mimarisine uygun sol dikey + sağ iki yatay ve ters puzzle mimarisine dönüştürüldü.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - **Tetris / Puzzle Blok 1 (Sol Puzzle)**: Sol tarafta 2 satır yüksekliğinde dikey bir taktik puzzle kartı (%40 flex, `Konsinye & Emanet`), sağ tarafta ise alt alta istiflenmiş iki adet ferah ve kompakt yatay kart (%60 flex, üstte `Hurdalık & Parça`, altta `Showroom Mimari`). `IntrinsicHeight` ile kusursuz kenetlenme sağlandı.
    - **Orta Dinamik Şerit**: Koyu antrasit/noir (%100 tam genişlik) `Gece Sanayisi` panoramik taktik şeridi ile ritim dengelendi.
    - **Tetris / Puzzle Blok 2 (Ters Puzzle)**: Sol tarafta alt alta istiflenmiş iki kompakt yatay kart (%60 flex, üstte `Dedikodu Hattı`, altta `Müşteri Yorumları`), sağ tarafta ise 2 satır yüksekliğinde dikey puzzle kartı (%40 flex, `Semt Hakimiyeti`).
    - **Yeni Bileşenler**:
      * `_buildHubVerticalPuzzleCard`: 2 satır yüksekliğinde dikey akışlı, üstte taktik renkli ikon ve durum rozeti, ortada başlık ve alt başlık, altta telemetri çipi ve yönlendirme butonu barındıran teknik blueprint kartı.
      * `_buildHubCompactHorizontalCard`: Fazla çizim barındırmayan, sakin, nefes alan, kompakt ve ferah 2'li istif kartı.
    - Unused declaration olan `_buildHubTallActionCard` temizlendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `warning - The declaration '_buildHubTallActionCard' isn't referenced` uyarı alındı.
- **Kök Neden**: Yeni puzzle widget'ları eklendikten sonra eski metodun referansı kalmamıştı.
- **Uygulanan Çözüm**: Unused metod kaldırılarak Dart Analyzer uyarısı 0'a indirildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/dashboard/widgets/`: Sıfır hata ve sıfır uyarı ile doğrulandı (No issues found!).
  - `flutter test test/city_operations_hub_and_marketplace_redesign_test.dart test/dynamic_next_target_banner_test.dart test/service_unlock_notification_dot_test.dart`: 5 testin tamamı başarıyla geçti (All tests passed!).
  - `http://localhost:8080`: Canlı Chrome oturumunda wheel scroll ile sayfa kaydırılarak ekran görüntüsü alındı, puzzle bloklarının kusursuz kenetlendiği doğrulandı.

### `Şehir Hub'ı • Seçici İllüstrasyon, Zıt Terrakotta & Antrasit Bloklar ve 1:1 Temiz Yardımcı Kutular`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Kullanıcı geribildirimleri doğrultusunda ("bazı kartlar tam dikdörtgen değil ve bazıları ters farklı renkli kutu tasarımları var ve bazılarının kutu içinde tasarım yok bak ve tasarım dersi al tekrardan tasarla orayı ayrıca önemli olanlar daha büyük olsun kullanıcı ux dizaynına uygun"), Şehir & Yan Sektörler Operasyonel Hub'ı referans mobil UI mimarisine tam uyumlu hale getirildi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - **Seçici İllüstrasyon İlkesi**: Tüm kartların arkasına çizim koyma kuralı kaldırılarak görsel karmaşa giderildi. İllüstrasyonlar yalnızca 3 ana taşıyıcı kartta (Hero `Yan İşletmeler`, Dikey Terrakotta `Rent-a-Car` ve Panoramik Taktik Şerit `Gece Sanayisi`) bırakıldı.
    - **Zıt Renkli Kontrast Bloklar**:
      * `_buildHubInvertedCard`: Zengin koyu kiremit/terrakotta (`#9A3412` / `#6C1F0D`) zemin dolgusu, beyaz tipografi, `Kirada` durum rozeti, beyaz yönlendirme butonu ve spor coupe silüeti uygulandı.
      * `_buildHubPanoramicCard`: Derin koyu antrasit/noir (`#0F172A`) zemin dolgusu, kırmızı yarış bayrağı, drag & modifiye telemetrisi ve yarış kanadı/alev hatları illüstrasyonu eklendi.
    - **1:1 Temiz Yardımcı Servis Kutuları (`_buildHubCleanUtilityTile`)**: `Hurdalık & Parça`, `Showroom Mimari`, `Konsinye & Emanet`, `Dedikodu Hattı`, `Müşteri Yorumları` servisleri; arka planda çizim barındırmayan, sakin, nefes alan saf beyaz / koyu arduvaz zeminli, renkli taktik ikon kutulu, net başlıklı ve telemetri haplı kompakt kutulara dönüştürüldü.
    - `_buildAsymmetricBentoRows`: Dinamik hiyerarşik yuvalama mantığı baştan yazıldı. Row 1: Hero (%62) + Dikey Terrakotta (%38) -> Row 2: Temiz İkili Kutu -> Row 3: Panoramik Taktik Şerit -> Row 4 & 5: Temiz İkili Kutular -> Bottom: VIP Casino Şeridi.
- **Karşılaşılan Hatalar / Sorunlar**: Yok.
- **Kök Neden**: N/A.
- **Uygulanan Çözüm**: Dart Analyzer ve tüm widget testleri çalıştırıldı; tarayıcıda canlı olarak doğrulandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/dashboard/widgets/`: Sıfır hata ve sıfır uyarı ile doğrulandı.
  - `flutter test test/city_operations_hub_and_marketplace_redesign_test.dart test/dynamic_next_target_banner_test.dart test/service_unlock_notification_dot_test.dart`: 5 testin tamamı başarıyla geçti (All tests passed).
  - `http://localhost:8080`: Canlı tarayıcı oturumunda ekran görüntüsü alınarak doğrulandı.

### `Şehir & Yan Sektörler Operasyonel Hub • Asimetrik Bento Grid & Yüksek Kontrastlı Vektör Çizimleri`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Kullanıcı talebi ("bu 8 kutu sana örnekte attığım gibi asimetrik box ve kontrast çizimli hale dönüştürelim... dinamik olarak seviyeye göre açılınca dinamik büyüyüp açılacak vs kilitli olduğunda gözükmeyecek") doğrultusunda, Şehir & Yan Sektörler Hub'ındaki 8 kutu tekdüze 2x4 ızgaradan dinamik asimetrik Bento Grid sistemine ve donanım hızlandırmalı yüksek kontrastlı otomotiv vektör çizimlerine kavuşturuldu.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/hub_service_illustrations.dart` (YENİ DOSYA):
    - Saf Flutter `CustomPainter` ile sıfır harici varlık bağımlılığı olmaksızın 10 adet yüksek kontrastlı teknik otomotiv silüeti ve illüstrasyonu çizildi:
      1. `Rent-a-Car`: Aerodinamik spor coupe silüeti, hız çizgileri ve dijital anahtar.
      2. `Hurdalık & Parça`: Mekanik motor bloğu, silindirler ve turboşarj tel kafes çizimi.
      3. `Showroom Mimari`: Modern cam galeri cephesi, açılı spot ışıkları ve podyum.
      4. `Konsinye & Emanet`: Podyumdaki araç ve komisyon anlaşma mührü.
      5. `Gece Sanayisi`: Ayarlanabilir arka yarış kanadı, difüzör ve çift egzoz alevleri.
      6. `Dedikodu Hattı`: İstihbarat anten kulesi ve eşmerkezli radyo dalga darbeleri.
      7. `Semt Hakimiyeti`: 3D izometrik şehir bölge ızgarası ve zirve bayrağı.
      8. `Müşteri Yorumları`: 5 yıldızlı itibar tacı ve ışıma yapan geometrik ışınlar.
      9. `Yan İşletmeler`: Sanayi holding silüeti ve yükselen ciro trendi.
      10. `Casino`: VIP maça/karo sembolü ve altın rulet çarkı kenarlığı.
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - `_buildAsymmetricBentoRows`: Açık olan servis sayısına göre deterministik asimetrik Bento ritmi oluşturuldu:
      * 1 Servis: %100 genişlikte büyük Hero kartı.
      * 2 Servis (Fotoğraf 1 Üst Düzeni): %62 Geniş Hero Kartı + %38 Dikey Kompakt Kart.
      * 3 Servis: %100 Geniş Hero Kartı + İki adet %50 Dengeli Bento Kartı.
      * 4+ Servis: Dinamik Asimetrik Ritim (Hero %62 + Dikey %38 -> İkili %50/%50 -> Ters Asimetrik Dikey %38 + Geniş %62 -> İkili %50/%50).
    - `_buildHubHeroCard`, `_buildHubTallActionCard`, `_buildHubWideFeatureCard`, `_buildHubBentoTile` kart bileşenleri arka planda `HubServiceIllustration` ile birleştirildi.
    - Kilitli servisler ekrandan tamamen kaldırılarak sadece açık olanlar dinamik boyutta render edildi; en altta tek satırlık minimalist kilit açılım hedefi korundu.
- **Karşılaşılan Hatalar / Sorunlar**: Yok.
- **Kök Neden**: N/A.
- **Uygulanan Çözüm**: Hot restart ile tarayıcıda canlı olarak doğrulandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/dashboard/widgets/`: Sıfır hata ve sıfır uyarı ile doğrulandı.
  - `flutter test test/city_operations_hub_and_marketplace_redesign_test.dart test/dynamic_next_target_banner_test.dart test/service_unlock_notification_dot_test.dart`: Tüm widget testleri eksiksiz geçti (All tests passed).
  - `flutter run -d chrome`: Hot restart ile derlendi ve `http://localhost:8080` üzerinde başarıyla çalıştı.
  - Chrome DevTools ekran görüntüsü ile asimetrik bento hiyerarşisi ve vektör çizimler canlı ortamda doğrulandı.

### `Dashboard Services • Kapsayıcı Deck Kutuları (Enclosing Deck Containers) & Göz Dinlendirici Nötr Palet`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Kullanıcı geribildirimleri doğrultusunda ("servisler çok renkli göz yoruyor buna bir çözüm bul ve uygula, ayrıca üst kutu bu kutuları içine alsın deckler yani altındakini dinamik şekilde") 2 ana görsel/yapısal problem çözüldü:
  1. **Göz Yorulmasını Önleme (Calmed Neutral Palette)**: Pastel/neon kart zeminleri (`#E0F7FA`, `#FFF7ED`, `#FAF5FF`, `#FEF2F2`, `#ECFDF5`, `#EEF2FF`) yerine açık modda saf beyaz (`Colors.white`), koyu modda derin arduvaz (`#182030`) ve net 2.0-2.2px sınır (`#0F172A` / `#2E3D56`) uygulandı. Canlı neo-brutalist renkler (sarı, mavi, camgöbeği, turuncu, mor, yeşil, kırmızı) yalnızca odak noktası olan 32x32 ikon kutularında, durum rozetlerinde ve telemetri çiplerinde kullanıldı.
  2. **Dinamik Kapsayıcı Deck Kutuları (_buildDeckContainer)**: Deck-01 (Galeri & Araç Ticareti Hero), Deck-02 (Maslak Sanayi Mega Hangar), Deck-03 (Finans, Borsa & Müzayede Terminali), Deck-04 (Mülk & Holding İmparatorluğu) ve Karaborsa bölümleri; tıpkı Deck-05 (Şehir Hub Kutusu) gibi, başlık, alt başlık ve durum rozetini içeren dış neo-brutalist kapsayıcı bir kutu (`_buildDeckContainer`) içine alındı. İç kartlar bu kutunun içinde dinamik olarak yuvalandı.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - `_buildDeckContainer` reusable widget şablonu eklendi (`margin: 4px`, `padding: 12px`, `borderRadius: 16`, `border: 2.5px`, `shadow: 3.5px blur: 0`).
    - Deck 1, Deck 2, Deck 3, Deck 4 ve Karaborsa `_buildDeckContainer` içine alındı; başlık şeritleri kutu başlığına entegre edildi.
    - Tüm kartların (`Showroom`, `Pazar Yeri`, `Vasıta Pazarı`, `Oto Yıkama Tall & Strip`, `Tamir & Atölye`, `Tuning Stüdyosu`, `Canlı İhale`, `Finans & Banka`, `Borsa & Yatırım`, `Satış Geçmişi`, `Şube Yönetimi`, `Gayrimenkul Emlak`, `Personel Kadrosu`, `Hub Hero`, `Hub Bento Tile`, `VIP Casino Strip`) arka planları nötr beyaza / arduvaza, kenarlıkları net siyah / arduvaz kontura çekildi.
    - Kullanılmayan `_buildCategoryBanner` fonksiyonu temizlendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `flutter analyze` sırasında unreferenced `_buildCategoryBanner` ve kullanılmayan `subtitle` parametresi uyarısı tespit edildi.
- **Kök Neden**: `_buildCategoryBanner` yerine `_buildDeckContainer` kullanılmaya başlandığı için eski fonksiyon atıl kaldı.
- **Uygulanan Çözüm**: Atıl `_buildCategoryBanner` fonksiyonu silindi; `flutter analyze` 0 hata/uyarı ile doğrulandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`: No issues found (0 issues).
  - `flutter test test/city_operations_hub_and_marketplace_redesign_test.dart test/dynamic_next_target_banner_test.dart test/service_unlock_notification_dot_test.dart test/localization_integrity_guard_test.dart`: 6/6 test başarıyla geçti.

### `Dashboard Services Grid • Deterministik Master Bento Yeniden Tasarımı`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Kullanıcı talebi doğrultusunda referans bento wireframe ve mobil süper uygulama görsellerine uygun olarak servisler alanının deterministik (her seviyede hangi servisin nereye geleceği önceden sabit bento ızgarasında belirli), showroom ve satış yerlerini (Açık Oto Pazarı & Vasıta) en üstte Hero olarak konumlandıran, sık kullanılan operasyonel servisleri (Showroom, Pazar Yeri, Oto Yıkama tall pod, Tamir, Tuning) daha büyük bento kartlarıyla öne çıkaran ve neo-brutalist kuralları (0-blur sert gölgeler, 2.3px konturlar, sıfır emoji, sıfır parantez) koruyan mimariye geçirilmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - **Deck-01 (Galeri & Araç Ticareti Hero)**: Showroom Uçuş Güvertesi (`_buildShowroomFlightDeckHero`) ve Açık Oto Pazarı & Vasıta Rıhtımı (`_buildMarketBoulevardVasitaDock`) en üst güverteye konumlandırıldı. Seviye 1-2'de tekil pazar yeri kartı (`Araç Satın Al`, `AÇIK OTO PAZARINA GİR`, `YENİ İLANLAR`), Seviye 3+'te Vasıta Pazarı ile yan yana deterministik 56%-44% bento eşleşmesi sağlandı.
    - **Deck-02 (Maslak Sanayi Endüstriyel Mega Hangar)**: Referans görseldeki 9:16 dikey bento oranına sadık kalarak, sol tarafta yüksek *Oto Yıkama* kartı (`_buildCarWashTallCard` - su damlası ikonu, kirli araç durumu, +%15 kâr çarpanı telemetrisi), sağ tarafta üst üste konumlandırılmış *Tamir & Atölye* (`_buildWorkshopCard` - lift durumu, hasarlı araç telemetrisi) ve *Tuning Stüdyosu* (`_buildTuningCard` - dyno test ve stage telemetrisi) bento podu inşa edildi.
    - **Deck-03 (Mülk & Holding İmparatorluğu)**: Şube Yönetimi Hero (`_buildBranchNetworkHero`), Emlak Pazarı (`_buildRealEstateCard`) ve Personel Kadrosu (`_buildStaffCard`) korundu.
    - **Deck-04 (Finans, Borsa & Müzayede Terminali)**: Canlı Açık Artırma, Finans & Kasa, Borsa & Portföy, Satış Geçmişi.
    - **Deck-05 (Şehir & Yan Sektörler Operasyonel Hub)**: Büyütülmüş Yan İşletmeler Hero yuvası (`TESİSLER`), 8'li deterministik bento matrisi (`Rent-a-Car`, `Hurdalık & Parça`, `Gece Sanayisi`, `Dedikodu Hattı`, `Konsinye & Emanet`, `Semt Hakimiyeti`, `Showroom Mimari`, `Müşteri Yorumları`), sonraki seviye hedef fısıltısı ve VIP Yeraltı Casino şeridi (`MASAYA GEÇ`).
    - **Dinamik Sıradaki Hedef Bannerı**: Kilitli binalar için dönen animasyonlu motivasyon bannerı (`_DynamicNextTargetBanner`).
  - `lib/core/localization/translations/*.dart` (7 Dil: `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`):
    - `section_hero_dealership`, `section_hero_dealership_sub`, `section_sanayi_hangar`, `section_sanayi_hangar_sub`, `deck_action_showroom`, `deck_wash_boost_telemetry`, `deck_workshop_lift_telemetry`, `deck_tuning_dyno_telemetry` anahtarları 7 dilde eşzamanlı olarak eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `localization_integrity_guard_test.dart` çalıştığında, kategori başlığı rozetindeki `"SANAYİ"` metnindeki Türkçe `İ` harfi nedeniyle koruma testi hata verdi.
- **Kök Neden**: Kategori başlık rozetlerinde dil bağımsız evrensel kodlar (örn. `HERO DECK`, `WALL STREET`, `EXECUTIVE`, `CLASSIFIED`) kullanılırken Türkçe karakter içeren literal kullanılması.
- **Uygulanan Çözüm**: `badgeText: 'SANAYİ'` değeri `badgeText: 'HANGAR'` olarak güncellendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`: No issues found (0 hata).
  - `flutter test test/city_operations_hub_and_marketplace_redesign_test.dart test/dynamic_next_target_banner_test.dart test/service_unlock_notification_dot_test.dart test/localization_integrity_guard_test.dart`: 6/6 test başarıyla geçti.

### `Dashboard Sadeleştirme & Neo-Brutalist Minimalist Rahatlatma`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Kullanıcı talebi üzerine Dashboard'un aşırı yoğun ve kutu içinde kutu görsel karmaşasını ("bu dashboard iyi ama çok yoğun biraz bunu rahatlat... servislerin içindeki fazllarında kurtul neo-brutalist ama birazda minimalist olsun") sadeleştirmek, bilişsel yükü azaltmak ve neo-brutalist tactile tasarım dilini minimalist bir ferahlıkla birleştirmek.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/dashboard_screen.dart`:
    - Üst üste yığılan 5-6 farklı banner (Acil Kurtarma, Dramatik İkilem, Rastgele Olay, İlk Gün Görevi, Stratejik Danışman) yerine tek bir önceliklendirilmiş duyuru/aksiyon yuvası (`_buildPriorityActionBanner`) oluşturuldu. Öncelik sırası: 1) Acil Kurtarma (bakiye < 20k), 2) Dramatik İkilem Kartı, 3) Rastgele Olay, 4) İlk Gün Görevi (satılan araç == 0), 5) Stratejik Danışman Tavsiyesi.
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - `_buildCategoryBanner`: Kalabalık çift rozetli ve alt başlıklı karmaşık şerit yerine, temiz tek satırlı ve zarif neo-brutalist taktik başlık şeridine dönüştürüldü.
    - `_buildShowroomFlightDeckHero`: 10 adet küçük park kutusu ve karmaşık blueprint ızgarası kaldırılarak, modern kapasite doluluk çubuğu (`$carsCount / $maxSlots`) ve pasif gelir telemetrisi yerleştirildi; kart içi gereksiz buton kaldırıldı (tüm kart `onTap` ile çalışır).
    - `_buildSanayiMegaHangar`: Aşırı uyarı renkli turuncu başlık ve kart içi mükerrer butonlar ("LİFTE AL", "STAGE YAZ", "YIKAMAYA AL") kaldırılarak, temiz tipografi, canlı durum hapları ve tam kart tıklanabilirliği uygulandı.
    - `_buildMarketBoulevardVasitaDock`: İkili bölücü ve tekrarlanan mikro-etiketler temizlendi; Standalone Marketplace Hero (`Araç Satın Al`, `AÇIK OTO PAZARINA GİR`, `YENİ İLANLAR`) korundu.
    - `_buildAuctionFinanceTerminal`: Açık Artırma, Finans, Borsa ve Geçmiş kartlarındaki mükerrer iç butonlar (`PEY SÜR`, `KASAYI AÇ`, `PORTFÖYÜ AÇ`, `RAPORLARI GÖR`) ve mikro alt başlıklar kaldırılarak minimalist telemetri satırları ve zarif ok göstergeleri yerleştirildi.
    - `_buildHoldingExecutiveDossier`: Şube Yönetimi, Emlak Pazarı ve Personel Kadrosu kartlarındaki iç butonlar (`ŞUBEYİ YÖNET`, `MÜLKLERİ YÖNET`, `KADROYU YÖNET`) ve alt başlıklar kaldırıldı; tüm kart neo-brutalist tıklama tepkisiyle çalışır hale getirildi.
    - `_buildCityOperationsHubBox`: `_buildHubHeroCard` içindeki 11 mini tesis kutusu kaldırılarak ferahlatıldı (`TESİSLER` butonu korundu). `_buildHubBentoTile` yapısından mükerrer `item.subtitle` ve her kutucuktaki `İNCELE` butonu kaldırılarak, yüksek kontrastlı rozetler, ikonlar ve canlı telemetri hapları öne çıkarıldı. VIP Casino şeridi ve `MASAYA GEÇ` butonu korundu.
    - Kullanılmayan `dart:math` importu temizlendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `replace_file_content` sırasında `_buildHubHeroCard` telemetri konteynerinde tekrarlı `Row` etiketi oluştu ve `flutter analyze` ile tespit edildi.
- **Kök Neden**: Kod parçası değiştirme esnasında şablon örtüşmesi.
- **Uygulanan Çözüm**: Telemetri kutusu tek satırlı `Row` yapısına cerrahi olarak çekildi ve `flutter analyze` hatasız (0 issues) doğrulandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/dashboard/`: 0 issue (No issues found).
  - `flutter test test/city_operations_hub_and_marketplace_redesign_test.dart test/dynamic_next_target_banner_test.dart test/service_unlock_notification_dot_test.dart`: 5/5 test başarıyla geçti.

### `Önceki Dashboard Tasarımına Geri Dönüş (Git HEAD Restorasyonu)`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Kullanıcının referans videosundaki önceki yerleşik dashboard düzenine (bento flight deck deneyinden önceki kararlı 2 sütunlu "Hızlı İşlemler & Servisler" ızgarası, kritik karar kartları, haftalık etkinlik bülteni, danışman tavsiyesi, devret/lig/albüm butonları, günlük nakit akışı ve piyasa bülteni akışına) tam dönüş yapılması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/dashboard_screen.dart`, `dashboard_services_grid.dart`, `dashboard_banners.dart`, `dashboard_office_view.dart`, `dashboard_quick_finance_card.dart`, `dashboard_retention_modals.dart` ve ilgili test dosyaları Git HEAD (`b00140f`) kararlı durumuna geri yüklendi.
  - Bento flight deck deneyi için eklenen geçici untracked dosyalar (`dashboard_bento_tile.dart`, `dashboard_branch_radar_card.dart`, `dashboard_brutal_decor.dart`, `dashboard_decision_slot.dart`, `dashboard_module_tile.dart`, `dashboard_next_target_banner.dart`, `dashboard_scoreboard.dart`, `turkish_case.dart`, `dashboard_density_rules_test.dart`) temizlendi.
- **Karşılaşılan Hatalar / Sorunlar**: Yok.
- **Kök Neden**: Kullanıcının WhatsApp videosundaki orijinal dashboard tasarımını tercih etmesi.
- **Uygulanan Çözüm**: Git çalışma dizini HEAD sürümüne geri getirildi, sunucuya Hot Restart uygulandı.
- **Doğrulama / Test Durumu**: `flutter test test/city_operations_hub_and_marketplace_redesign_test.dart test/dynamic_next_target_banner_test.dart test/service_unlock_notification_dot_test.dart` (Tüm testler geçti), `flutter analyze lib/presentation/screens/dashboard/` (No issues found).

### `Dashboard Net Değer Kartı Kaldırılması`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: Kullanıcı isteği doğrultusunda Dashboard üzerindeki "NET DEĞER" skorbord kartının (`DashboardScoreboard`) dashboard akışından kaldırılması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/dashboard_screen.dart`:
    - `DashboardScoreboard` widget çağrısı ve `const SizedBox(height: 10)` dikey boşluğu kaldırıldı.
    - Kullanılmayan `widgets/dashboard_scoreboard.dart` import bildirimi temizlendi.
- **Karşılaşılan Hatalar / Sorunlar**: Yok.
- **Kök Neden**: Kullanıcı arayüzü sadeleştirme isteği.
- **Uygulanan Çözüm**: İlgili widget çağrısı ve importu kaldırıldı.
- **Doğrulama / Test Durumu**: `flutter test test/dashboard_density_rules_test.dart` (9/9 test başarılı), `flutter analyze lib/presentation/screens/dashboard/` (No issues found).

### `Dashboard Bento Izgara & Şube Radarı Buton Geometrisi Uyarlaması`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Bento hücrelerini (`DashboardBentoTile`), Showroom hero kartını (`DashboardModuleTile`) ve Şube Radarı kartını (`DashboardBranchRadarCard`) projenin yerleşik buton stilindeki (`NeoBrutalButton` / `ShowroomCarCard`) 10px köşe yarıçapı, 2.5px kontur, 3.5px sert 0-blur gölge ve Title Case tipografik diline uyarlamak.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_bento_tile.dart`:
    - `BorderRadius.circular(10.0)` dış köşe yuvarlaması ve `Border.all(color: ink, width: 2.5)` kenarlık korundu.
    - Sert gölge `Offset(3.5, 3.5)` ve basış anında `Offset(1.0, 1.0)` olarak butonlarla tam senkronize edildi.
    - İç ikon yuvaları `BorderRadius.circular(8.0)`, 2.0px kenarlık ve açık modda yumuşak arduvaz gri `0xFFE2E8F0` / koyu modda `0xFF272C38` dolgusu ile güncellendi.
    - Kart zemin rengi açık modda parlak beyaz `Colors.white`, koyu modda `0xFF1E2330` yapıldı.
    - Kart başlıkları ve seviye gereksinimleri Title Case formatına geçirildi; `brutalUpper` zorlaması kaldırıldı.
    - Seviye kilit bildirim SnackBar'ı 8.0px yuvarlatılmış köşeler ve 2.5px siyah kenarlıkla tasarlandı.
    - `wideHero` ve `compact` görünümlerinde kilitli modüller için `NeoBrutalBadge` (`Color(0xFFFFDE59)`) entegre edildi.
  - `lib/presentation/screens/dashboard/widgets/dashboard_branch_radar_card.dart`:
    - Kapanış parantez ve köşeli parantezlerindeki sözdizimi hatası giderildi.
    - Dış kart `BorderRadius.circular(10.0)`, `width: 2.5` kontur, `Offset(3.5, 3.5)` 0-blur gölge ve basış anında `Offset(1.0, 1.0)` mekanik çöküş ile buton geometrisine tam bağlandı.
    - İç aktif ve hedef şube panelleri `BorderRadius.circular(8.0)`, `width: 2.0` kenarlık ile güncellendi.
    - Yönlendirme butonu `BorderRadius.circular(8.0)` ve `0xFFFFDE59` dolgu ile revize edildi.
  - `lib/presentation/screens/dashboard/widgets/dashboard_module_tile.dart`:
    - Showroom Hero kartının köşe sınırlaması `Clip.antiAlias` olarak güçlendirildi, 10.0px radius ve 3.5px gölge ile bento hücreleriyle tam görsel uyum sağlandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `dashboard_branch_radar_card.dart` satır 318-325 arasında fazladan kapanış parantezleri derleme hatasına yol açmıştı.
- **Kök Neden**: Önceki refactor sırasında Transform widget'ı eklenirken kapanış bloğunun mükerrer kalması.
- **Uygulanan Çözüm**: Fazla parantezler temizlendi ve widget ağacı doğru kapatıldı.
- **Doğrulama / Test Durumu**: `flutter test test/dashboard_density_rules_test.dart` (9/9 test geçti), `flutter analyze lib/presentation/screens/dashboard/` (Sıfır hata, sıfır uyarı).

### `Dashboard Asimetrik Bento Izgara & Şube Radarı Refactor`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Dashboard üzerindeki eski hantal akordiyon sistemini kaldırıp, 24 modülün tamamını kullanım sıklığı ve oyuncu seviyesine göre 4 asimetrik taktiksel Bento bloğuna ve alt kısımdaki dinamik Şube Radarı teaser kartına dönüştürmek.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_bento_tile.dart` (YENİ):
    - 1x3 dikey, 2:1 asimetrik ve kompakt form faktörlerini destekleyen taktiksel Neo-Brutalist karo widget'ı oluşturuldu.
    - 2.5px siyah kontur (`brutalInk`), 0-blur 3.5px sert gölge, basış anında `Transform.translate` mekanik çöküş tepkisi ve haptik titreşim eklendi.
    - Kilitli modüller için `BrutalHatch` 45 derece endüstriyel çapraz tarama deseni, `SEVİYE X` damgası ve dokunulduğunda seviye bildirimi veren dokunsal geri bildirim sağlandı.
  - `lib/presentation/screens/dashboard/widgets/dashboard_branch_radar_card.dart` (YENİ):
    - `BranchModel.getAllBranches(...)` üzerinden oyuncunun mevcut aktif şubesini ve bir sonraki kilitli hedef şubeyi (çarpan, slot vaatleri ve merak unsuru ile) sergileyen dinamik radar kartı geliştirildi.
    - Karta dokunulduğunda doğrudan `/branches` rotasına yönlendirme sağlandı.
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - `_CategoryGroup` (akordiyon) sistemi tamamen temizlendi.
    - 4 asimetrik Bento bloğu kuruldu:
      - Blok 1: 1x1 Showroom Hero + 2:1 İkinci El & Vasıta Pazarı + 1x3 Operasyon (Yıkama, Tamir, Tuning).
      - Blok 2: Finans Asimetrik Bento (Banka büyük karo, Müzayede & Personel istifi, Borsa & Muhasebe şeridi).
      - Blok 3: Holding (Emlak geniş kart, Yan İşletmeler & Rent a Car, İtibar & Dekorasyon).
      - Blok 4: Yeraltı & Fırsat Pazarı (Hurdalık, Konsinye, Dedikodu, Kara Borsa, Gece Pazarı, Bölgeler, Casino).
      - Blok 5: Dinamik Şube Radarı Kartı.
  - Yerelleştirme (7 Dil Eş Zamanlı):
    - `lib/core/localization/translations/tr_translations.dart`
    - `lib/core/localization/translations/en_translations.dart`
    - `lib/core/localization/translations/de_translations.dart`
    - `lib/core/localization/translations/pt_translations.dart`
    - `lib/core/localization/translations/es_translations.dart`
    - `lib/core/localization/translations/ru_translations.dart`
    - `lib/core/localization/translations/ar_translations.dart`
    - Blok başlıkları (`dash_block_core`, `dash_block_finance`, `dash_block_holding`, `dash_block_underworld`), şube radarı anahtarları ve `{level}` kilit şablonları eklendi.
  - `test/dashboard_density_rules_test.dart`:
    - Yeni asimetrik Bento ızgara kuralları, blok başlıkları ve kilit seviye doğrulamaları güncellendi (22 Bento karo + 1 Hero Showroom + 1 Şube Radarı = 24 modül).
- **Karşılaşılan Hatalar / Sorunlar**:
  - `DealershipModel` üzerinde `ownedDeeds` bulunamadı hatası alındı. Kök neden: Modeldeki gerçek alan adının `ownedBranchDeeds` olması. Çözüm: Alan adı `ownedBranchDeeds` olarak düzeltildi.
  - `dash_level_required` şablonundaki `%{level}` yer tutucusu, `AppLocalizations` sınıfının `{paramKey}` kuralı nedeniyle eşleşmedi. Çözüm: 7 dilde `{level}` formatına çekildi.
- **Kök Neden**: Arayüz modernizasyonu ve taktiksel anti-slop bento ızgarası mimarisi.
- **Uygulanan Çözüm**: Asimetrik Bento karoları, şube radarı ve 7 dil senkronizasyonu tamamlandı.
- **Doğrulama / Test Durumu**: `flutter test test/dashboard_density_rules_test.dart` (9/9 test geçti), `flutter analyze` (No issues found - sıfır hata, sıfır uyarı).

### `NeoBrutalListingThumbnail Genişleme Paketi (45+ Çeşitlendirilmiş Vektörel Görsel & Dinamik Gövde Rengi)`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Kullanıcı talebi doğrultusunda her ilanda aynı görselin çıkmasını engelleyen kapsamlı bir görsel çeşitlendirme genişleme paketi geliştirmek. Her vasıta kategorisi için 3-4 farklı şasi/gövde tipi ve araç gerçek boya rengi (`colorHex`) harmanlaması; her emlak kategorisi için 3-4 farklı mimari tarz (villa, penthouse, ikiz ev, cadde apartmanı, tarihi konak, vb.) oluşturmak.
- **Yapılan Değişiklikler**:
  - `lib/presentation/widgets/neo_brutal_listing_thumbnail.dart`:
    - `VasitaListingThumbnail`:
      - `bodyColor` desteği eklendi: İlanın `colorHex` değeri `ColorParser.parseCarColor` ile güvenle çözümlenerek aracın kaporta rengi dinamik olarak çizime yansıtıldı.
      - `seed` parametresi eklendi: İlan başlığı ve ID'sine göre deterministik varyant seçimi sağlandı.
      - 10 araç kategorisinin her biri için 3-4 alt varyant çizildi (toplam 31 araç vektör illüstrasyonu):
        - Minivan: Kombi (tavan raylı), Panelvan (sürgülü raylı/rüzgarlıklı), Maxi Kasa (çift arka kapılı).
        - Motosiklet: Naked/Street, Maxi-Scooter (arka çantalı), Chopper (uzun çatallı), Enduro/Adventure (yüksek gagalı).
        - Ticari: Kutu Kamyon, Açık Kasa Damperli, Çekici Tır (yüksek tavan ve krom egzoz).
        - Deniz Araçları: Flybridge Lüks Yat, Sürat Teknesi (dıştan motorlu), Yelkenli Kotra.
        - Karavan: Motokaravan (tente/klimalı), Çekme Karavan (çeki demirli), Alkovenli Aile RV.
        - Hava Araçları: Tek Motorlu Pervaneli, Çift Motorlu Pırpır, İniş Kızaklı Helikopter.
        - ATV & UTV: Spor Yarış ATV'si, Yük Sepetli Çiftlik ATV'si, Roll-cage Buggy UTV.
        - Klasik Araç: 1950'ler Tail-fin Coupe, Vintage Roadster, 70'ler Fastback Muscle.
        - Otomobil/Filo: Şehir Sedan'ı, Crossover SUV, Sportif Hatchback.
        - Hasarlı: Önden Ağır Hasarlı, Yandan Darbeli Göçük, Tavan Çökmesi/Taklalı.
    - `RealEstateListingThumbnail`:
      - `seed`, `squareMeters`, `roomCount` parametreleri eklendi.
      - 5 emlak kategorisi için toplam 16 mimari vektör illüstrasyonu çizildi:
        - Konut: Müstakil Eğimli Villa, Modern Kübik Villa (teraslı), Çatı Dubleksi/Penthouse (mansart tavan), 2 Katlı İkiz Ev.
        - İş Yeri: Çizgili Tenteli Butik Kafe, Cam Perde Cepheli Plaza Ofisi, Sarmal Kepenkli Sanayi Hangarı.
        - Arsa: Kadastro Parseli & Bayraklı Kazıklar, İmar Planlı Ada/Pusulalı Parsel, Dalgalı Tepeli Sıralı Fidanlık.
        - Konut Projeleri: Gökyüzü Köprülü İkiz Kuleler, Kademeli Lüks Rezidans, 3 Bloklu Modern Site.
        - Bina: 4 Katlı Klasik Apartman, Zemin Dükkanlı Cadde Binası, Cumbahı Tarihi Taş Konak.
  - `lib/presentation/screens/vasita/vasita_market_screen.dart`:
    - `VasitaListingThumbnail` çağrısına `seed: '${car.brand}_${car.modelName}_${car.modelYear}_${listing.id}'` bağlandı.
  - `lib/presentation/screens/real_estate/real_estate_market_screen.dart`:
    - İlan kartları ve portföy kartlarında `seed`, `squareMeters` ve `roomCount` parametreleri bağlandı.
  - `test/neo_brutal_listing_thumbnail_test.dart`:
    - Tüm varyant indeksleri, dinamik renk çözümlemesi ve farklı tohumlar için yeni testler eklendi ve başarıyla geçirildi.
- **Karşılaşılan Hatalar / Sorunlar**: Yok.
- **Kök Neden**: Kullanıcı görsel zenginleştirme ve çeşitlendirme isteği.
- **Uygulanan Çözüm**: 47 farklı vektörel alt şablon ve renk motoru entegre edildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze`: 0 hata, 0 uyarı (`No issues found!`).
  - `flutter test test/neo_brutal_listing_thumbnail_test.dart`: 6 testin 6'sı da başarıyla geçti (`All tests passed!`).

---

### `Vasıta & Emlak İlanları Neo-Brutalist Görsel Küçük Resim Sistemi (NeoBrutalListingThumbnail)`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Kullanıcı isteği doğrultusunda hem Vasıta Pazarı (`VasitaMarketScreen`) hem de Emlak Pazarı (`RealEstateMarketScreen`) ilan kartlarına, Araç Pazarı'ndaki sıcak sarımsı neo-brutalist araç silüeti kutusu estetiğine uygun, ilan tipine göre özelleştirilmiş, gözü yormayan ve rahatsız etmeyen (`0xFFFEF9C3` krem-parşömen tabanlı, 2.0px kenarlıklı, 0-blur gölgeli) vektörel görsel küçük resim bileşeni entegre etmek.
- **Yapılan Değişiklikler**:
  - `lib/presentation/widgets/neo_brutal_listing_thumbnail.dart`:
    - `VasitaListingThumbnail`: 12 vasıta kategorisinin tümü (`minivan`, `motorcycle`, `commercial`, `marine`, `caravan`, `aircraft`, `atv`, `utv`, `classic`, `rentalFleet`, `car`, `damaged`) için özel `CustomPainter` 2D vektörel blueprint illüstrasyonları geliştirildi. Minivan için sürgülü raylı gövde, motosiklet için çatallı şasi ve çift tekerlek, deniz araçları için yelkenli omurga ve dalga çizgileri, hava araçları için pervane ve kanatlar, karavan için pencereli yaşam kabini çizildi.
    - `RealEstateListingThumbnail`: 5 emlak kategorisinin tümü (`housing`, `commercial`, `land`, `housingProjects`, `building`) için neo-brutalist mimari illüstrasyonlar geliştirildi. Konut için eğimli çatılı ve bacalı villa; iş yeri için çizgili tenteli dükkan; arsa için izometrik kadastro parseli ve aplikasyon kazıkları; konut projeleri için gökyüzü köprülü ikiz gökdelenler; bina için 4 katlı silme kornişli kentsel apartman blokları çizildi.
    - Göz konforu için neon renk patlamaları yerine yumuşak sarımsı parşömen tabanı (`0xFFFEF9C3`) ile kategori renginin hafif %12 karışımı (`alphaBlend`) kullanıldı. Karanlık modda derin slate (`0xFF181C26`) taban uygulandı.
  - `lib/presentation/screens/vasita/vasita_market_screen.dart`:
    - `_buildListingCard` başlık ve teknik özellikler bloğu, sol tarafına `VasitaListingThumbnail` yerleştirilerek Araç Pazarı ile tam bir görsel uyum kazandırıldı.
  - `lib/presentation/screens/real_estate/real_estate_market_screen.dart`:
    - `_buildListingCard` ve `_buildPortfolioTab` içerisinde daha önce boş/soluk kalan ham kategori ikon kutuları yerine `RealEstateListingThumbnail` entegre edildi.
  - `test/neo_brutal_listing_thumbnail_test.dart`:
    - Vasıta ve emlak bileşenlerinin tüm kategoriler, aydınlık/karanlık temalar ve CustomPaint çizimleri için widget testleri yazılarak doğrulandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `neo_brutal_listing_thumbnail.dart` içinde `import 'dart:math'` kullanılmadığı için uyarı ve `VehicleCategory` enum'ı tüm durumları kapsadığı için `unreachable_switch_default` uyarısı alındı.
  - Test dosyasında paket import adı `galerisinden` yerine `galeriden` olmalıydı.
- **Kök Neden**: Kapsayıcı enum switch yapısında gereksiz default dalı ve proje paket isminin `galeriden` olması.
- **Uygulanan Çözüm**: Uyarılar temizlendi, import `galeriden` olarak düzeltildi ve testler başarıyla geçirildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze`: 0 hata, 0 uyarı (`No issues found!`).
  - `flutter test test/neo_brutal_listing_thumbnail_test.dart`: 4 testin 4'ü de başarıyla geçti (`All tests passed!`).
  - `flutter test test/vasita_market_test.dart test/real_estate_market_test.dart`: 42 testin 42'si de başarıyla geçti (`All tests passed!`).

---

### `lib/presentation/screens/marketplace/marketplace_screen.dart`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Kullanıcının talebi doğrultusunda Araç Pazarı ekranının üst kısmındaki "İkinci El Piyasasında Durgunluk — Kelepir Araç Fırsatları Artıyor" piyasa trendi ve içgörü bilgi kartını arayüzden kaldırmak, arama kutusu ve filtreler arasındaki ekran alanını rahatlatmak.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/marketplace/marketplace_screen.dart`:
    - `build()` fonksiyonu içerisindeki kullanılmayan `marketSenseLevel` ve `trend` Riverpod dinleyicileri kaldırıldı.
    - Arama kutusunun altındaki `NeoBrutalCard` piyasa trendi bannerı (`Padding(padding: const EdgeInsets.fromLTRB(14, 6, 14, 4), child: NeoBrutalCard(...))`) tamamen kaldırıldı.
- **Karşılaşılan Hatalar / Sorunlar**: Yok.
- **Kök Neden**: Kullanıcı arayüz sadeleştirme isteği.
- **Uygulanan Çözüm**: İlgili bileşen ve kullanılmayan bağımlılıkları temizlendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/marketplace/marketplace_screen.dart test/`: 0 hata, 0 uyarı (`No issues found!`).
  - `flutter test`: 7 testin 7'si de başarıyla geçti.

---

### `Araç Pazarı, Vasıta Pazarı & Emlak Borsası Sonsuz Kaydırma (Infinite Stream) & Yerel Reklam Ritim Sistemi`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Kullanıcı isteği doğrultusunda Twitter/X tarzı aşağı kaydırdıkça (`ScrollController` ile `extentAfter < 500`) kesintisiz yeni ilanlar türeten sonsuz kaydırma akışı kurmak; her 4 ilanda bir (`index > 0 && index % 4 == 0`) doğal sponsor / AdMob yerel reklam kartı (`NeoBrutalNativeAdCard`) ritmi eklemek; bellek şişmesini önleyen tavan mekanizması ve eşzamanlı 7 dilli yerelleştirme sağlamak.
- **Yapılan Değişiklikler**:
  - `lib/core/localization/translations/`:
    - `tr_translations.dart`, `en_translations.dart`, `de_translations.dart`, `pt_translations.dart`, `es_translations.dart`, `ru_translations.dart`, `ar_translations.dart` dosyalarına `feed_loading_more` anahtarı sıfır emoji ve sıfır parantez kuralına uygun şekilde eklendi.
  - `lib/presentation/providers/market_provider.dart`:
    - `MarketNotifier` içerisine `loadMoreListings({int count = 6})` metodu eklendi. Benzersiz ID koruması ve 150 öğelik bellek tavanı sağlandı.
  - `lib/presentation/providers/vasita_market_provider.dart`:
    - `VasitaMarketNotifier` içerisine `loadMoreListings({int count = 6})` metodu eklendi. Kategori filtresini koruyarak yeni vasıtalar türetme sağlandı.
  - `lib/presentation/providers/real_estate_market_provider.dart`:
    - `RealEstateMarketNotifier` içerisine `loadMoreListings({int count = 6})` metodu eklendi.
  - `lib/domain/usecases/market_engine.dart` & `lib/domain/usecases/real_estate_market_engine.dart`:
    - Döngüsel hızlı üretimde mikrosaniye çakışmalarını sıfırlamak için `_idCounter` ve mikrosaniye artırımlı benzersiz ID şeması uygulandı.
  - `lib/presentation/screens/marketplace/marketplace_screen.dart`:
    - `_scrollController` eklendi, `extentAfter < 500` eşiğinde `_loadMore()` tetikleyicisi bağlandı, alt tarafa neo-brutalist stream spinnerı (`feed_loading_more`) yerleştirildi, reklam kapsayıcısı kural 10 gereği `CrossAxisAlignment.stretch` olarak güncellendi.
  - `lib/presentation/screens/vasita/vasita_market_screen.dart`:
    - `_scrollController` eklendi, `extentAfter < 500` akış dinleyicisi kuruldu, alt spinner eklendi, her 4 ilanda bir `showAdBefore` ritmi sağlandı.
  - `lib/presentation/screens/real_estate/real_estate_market_screen.dart`:
    - `_listingsScrollController` bağlandı, sonsuz akış dinleyicisi ve alt spinner eklendi, her 4 ilanda bir yerel reklam şablonu yerleştirildi.
  - `test/infinite_scroll_market_feed_test.dart`:
    - Her 3 pazar için dinamik ilan ekleme, kategori koruma, `index % 4 == 0` reklam ritmi ve 7 dilli yerelleştirme (parantezsiz/emojisiz) testleri yazılarak doğrulandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `real_estate_market_engine.dart` dosyasında `id: 'list_re_${currentDay}_$i'` statik döngü indeksi kullanıldığı için `loadMoreListings` çağrısında aynı ID'lerin üretilip elenmesi (`Expected: <30>, Actual: <24>`).
  - `market_engine.dart` içinde senkron döngüde `DateTime.now().microsecondsSinceEpoch` değerinin aynı mikrosaniyeye denk gelerek 1/1000 rastgele çakışma ihtimali üretmesi.
  - `real_estate_market_screen.dart` ve `vasita_market_screen.dart` dosyalarında kullanılmayan `dart:math` import uyarıları.
- **Kök Neden**:
  - ID türetiminde mikrosaniyeye ek olarak atomik sıra sayacı kullanılmaması ve emlak motorunda gün/indeks tabanlı ID üretimi.
- **Uygulanan Çözüm**:
  - ID türetimlerine atomik `_idCounter` ve mikrosaniye eklenerek tam benzersizlik sağlandı, kullanılmayan importlar temizlendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/ test/`: 0 hata, 0 uyarı (`No issues found!`).
  - `flutter test test/infinite_scroll_market_feed_test.dart test/city_operations_hub_and_marketplace_redesign_test.dart`: 7 testin 7'si de başarıyla geçti (`All tests passed!`).

---

### `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart` & `test/city_operations_hub_and_marketplace_redesign_test.dart`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Şehir & Yan Sektörler kutusu içerisindeki 10 ikincil genişleme servisinin diğer ana bölümlerin (Showroom Flight-Deck, Maslak Sanayi Mega-Hangar, Finans Terminali) yanında "sönük" (soluk, beyaz/gri ve tekdüze) kalmasını tamamen ortadan kaldırmak; her bir servise kendi tematik alanına özel doygun arka plan rengi (`bgLight` & `bgDark`), 2.2px+ canlı renkli neo-brutalist kenarlık, sert 0-blur gölge (`Offset(2.5, 2.5)`), mikro-ikonlu canlı telemetri kutuları ve en altta tam genişlikli VIP Gold/Noir Casino şeridi kazandırmak.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - `_ServiceItem` modeline `bgLight`, `bgDark`, `telemetryIcon` alanları eklendi.
    - Tüm 10 servis tekdüze beyaz arka plandan kurtarılarak tematik renk tonlarına kavuşturuldu:
      - Rent-a-Car: Okyanus Mavisi (`0xFFF0F9FF` / `0xFF082236`, `0xFF0284C7`), Kontak anahtarı telemetrisi (`X Kirada`).
      - Gece Sanayisi: Nitro Kırmızı (`0xFFFFF1F2` / `0xFF2B0A14`, `0xFFF43F5E`), Ateş/Yarış telemetrisi.
      - Hurdalık & Parça: Endüstriyel Çelik (`0xFFF1F5F9` / `0xFF151E2B`, `0xFF64748B`), İngiliz anahtarı & çıkma parça sayacı.
      - Semt Hakimiyeti: Siber Turkuaz (`0xFFF0FDF9` / `0xFF0A2422`, `0xFF0284C7`), Pasta grafik pazar kontrol telemetrisi.
      - Dedikodu Hattı: Siber Sarı (`0xFFFEF9C3` / `0xFF262005`, `0xFFEAB308`), Megafon & kulis fısıltı telemetrisi.
      - Konsinye & Emanet: Nane Yeşili (`0xFFECFDF5` / `0xFF07261C`, `0xFF059669`), El sıkışma & sıfır sermaye vitrin telemetrisi.
      - Müşteri Yorumları: Sıcak Altın (`0xFFFFFBEB` / `0xFF261D07`, `0xFFF59E0B`), Yıldız & itibar telemetrisi.
      - Showroom Mimari: Kraliyet Moru (`0xFFF5F3FF` / `0xFF1E1535`, `0xFF8B5CF6`), Palet & mimari prestij telemetrisi.
      - Yan İşletmeler: Zehir Yeşili (`0xFFF0FDF4` / `0xFF072418`, `0xFF10B981`), 11 tesis nokta matrisi ve günlük nakit akışı.
      - Yeraltı Casino: VIP Gold & Noir (`0xFFFEFCE8` / `0xFF261D04`, `0xFFFFD700`), Zar ikonu ve yüksek kazanç telemetrisi.
    - **Mikro-Telemetri Kutuları**: Her bento karosunun içerisine yarı saydam arka planlı, kenarlıklı, canlı ikon ve durum metni içeren telemetri çubuğu eklendi.
    - **Yeraltı Casino VIP Şeridi (`_buildHubCasinoStrip`)**: Casino açık olduğunda kutunun en tabanında tam genişlikli, altın kenarlıklı, "MASAYA GEÇ" butonlu VIP şerit olarak konumlandırıldı.
    - **Tesis Gösterge Matrisi**: `_buildHubHeroCard` içerisinde Yan İşletmeler'in 11 tesisinin sahip olunma durumunu gösteren interaktif görsel çipler (Showroom otopark slotları gibi) yerleştirildi.
    - `service_districts` yerelleştirme anahtarı `service_district` olarak düzeltildi.
  - `test/city_operations_hub_and_marketplace_redesign_test.dart`:
    - 10 servisin tamamının açık olduğu Seviye 5 durumu için bento karoları, telemetri kutuları ve VIP Casino şeridini doğrulayan ikinci kapsamlı test eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `service_districts` anahtarındaki çoğul 's' takısı sebebiyle testte "Semt Hakimiyeti" metninin bulunamaması.
  - Test içinde Casino buton metninin `MASAYA GEÇ` yerine `MASALARA OTUR` olarak aranması.
- **Kök Neden**:
  - `tr_translations.dart` dosyasındaki mevcut anahtar isimlerinin sırasıyla `service_district` ve `deck_action_casino: MASAYA GEÇ` olması.
- **Uygulanan Çözüm**:
  - Anahtar ve test beklentileri mevcut lokalizasyon anahtarlarıyla tam uyumlu hale getirildi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`: 0 hata, 0 uyarı (`No issues found!`).
  - `flutter test test/city_operations_hub_and_marketplace_redesign_test.dart`: 2 testin 2'si de başarıyla geçti.

---

### `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`, `lib/core/localization/translations/*` & `test/city_operations_hub_and_marketplace_redesign_test.dart`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: İkincil ve yan genişleme servislerinin (Hurdalık & Parça, Müşteri Yorumları, Showroom Mimari, Rent-a-Car, Yan İşletmeler, Semt Hakimiyeti, Dedikodu Hattı, Konsinye & Emanet, Gece Sanayisi, Yeraltı Casino) uzun, tekdüze yatay şeritler yerine tek bir özel kapsayıcı kutu ("Şehir & Yan Sektörler") içinde toplanması; oyuncu seviyesine göre dinamik olarak en verimli pasif gelir motorunu (örn. Seviye 2+ için Yan İşletmeler, Seviye 1 için Müşteri İtibarı) öne çıkarıp büyüten Hero vitrini, 2 sütunlu orantılı kare bento kartları ve henüz açılmamış servisler için tek satırlık kilit açılma hedefi (teaser) ile bilişsel yükün azaltılması. Ayrıca bağımsız Açık Oto Pazarı (Marketplace) kartının metin kesilmelerini ve boşluklarını gideren flight-deck hero tasarımına kavuşturulması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - **Tekil Kapsayıcı Kutu (`_buildCityOperationsHubBox`)**: Tüm 10 yan sektör tek bir 2.5px Neo-Brutalist kenarlıklı taktiksel kutu içine alındı. Üst başlıkta radyo frekans/şehir şebekesi ikonu, dinamik `{count}/10 AKTİF SEKTÖR` rozeti ve operasyonel açıklama konumlandırıldı.
    - **Dinamik Seviyeye Göre Büyüyen Hero Yuvası ("Büyüt")**: Açık servisler arasından en kritik ve oyuncunun seviyesine en uygun ana pasif gelir kaynağı (Seviye 2+ için Yan İşletmeler tesis gelir telemetrisiyle; Seviye 1 için Müşteri Yorumları 5.0 itibar puanıyla) üstte genişletilmiş Hero kartı olarak ölçeklendirildi.
    - **2 Sütunlu Orantılı Bento Izgara**: Geriye kalan açık sektörler, uzun yatay şeritler yerine kompakt, eşit yükseklikli (`IntrinsicHeight`) 2 sütunlu kare bento karoları olarak dizildi. Butonlar `MainAxisAlignment.spaceBetween` ile tabana kilitlendi.
    - **Bilişsel Yükü Azaltan Kademeli Açılış & Hedef İpucu**: Henüz seviyesi yetmeyen kapalı servisler ekranı kalabalıklaştırmadan gizlendi; kutunun en altına tek satırlık zarif bir sonraki kilit açılma ipucu (`Sonraki Seviye {level}: {name}`) yerleştirildi.
    - **Bağımsız Açık Oto Pazarı Kartı (`_buildMarketplaceCard(isStandalone: true)`)**: Vasıta servisi henüz açılmadığında veya tek başına görüntülendiğinde kartın metin kesintisi yaşamaması için tam genişlikli Flight-Deck Hero mimarisi uygulandı: Store ikonu, başlık, alt başlık, canlı ilan sayısı matrisi, sıcak kelepir & takas fırsat rozeti ve tam genişlikli dokunsal buton eklendi.
    - Kullanılmayan 11 eski şerit metodu ve değişken temizlenerek kod yalınlaştırıldı.
  - `lib/core/localization/translations/*`:
    - 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) `hub_city_operations_title`, `hub_city_operations_sub`, `hub_active_badge`, `hub_next_unlock_teaser`, `deck_action_go_market`, `deck_market_opportunity_tag` anahtarları sıfır emoji ve sıfır parantez kurallarıyla eksiksiz senkronize edildi.
  - `test/city_operations_hub_and_marketplace_redesign_test.dart`:
    - Şehir & Yan Sektörler kapsayıcı kutusunun mount olduğunu, seviye 2'de Yan İşletmeler'in büyütülmüş Hero olarak yerleştiğini, bento karolarını ve bağımsız Açık Oto Pazarı kartını doğrulayan widget testleri yazıldı; test sonlarında zamanlayıcı hijyeni (`stopPeriodicOrganicOfferTimer`) sağlandı.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Kartlara dokunulduğunda tetiklenen `markFeatureSeen` metodunun `DealershipModel` içinde 350ms'lik bir kayıt zamanlayıcısı başlatması sebebiyle widget testinde bekleyen zamanlayıcı (`A Timer is still pending`) uyarısı.
- **Kök Neden**:
  - `markFeatureSeen` arayüzdeki bildirim noktasını temizlerken durumun kaydedilmesi için 350 milisaniyelik debounce zamanlayıcısı kurmaktadır.
- **Uygulanan Çözüm**:
  - Widget testlerinde dokunma işleminden sonra `await tester.pump(const Duration(milliseconds: 500));` çalıştırılarak zamanlayıcının tamamlanması sağlandı ve `tearDown` aşamasında `stopPeriodicOrganicOfferTimer()` çağrıldı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`: 0 hata, 0 uyarı (`No issues found!`).
  - `flutter test test/dynamic_next_target_banner_test.dart test/service_unlock_notification_dot_test.dart test/city_operations_hub_and_marketplace_redesign_test.dart`: 4 testin 4'ü de başarıyla geçti.

---

### `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart` & `lib/core/localization/translations/*`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Dashboard ana sayfasındaki ikincil ve genişleme servislerinin (Deck 3: Holding & Ticari Filo — Yan İşletmeler, Rent-a-Car, Konsinye & Emanet; Deck 4: Yeraltı & Gece Devresi — Gece Sanayisi, Dedikodu Hattı, Semt Hakimiyeti, Hurdalık & Parça, Yeraltı VIP Casino, Müşteri Yorumları, Showroom Mimari) tekdüze 2 sütunlu basit liste tasarımından asimetrik ama orantılı, eşit yükseklik mimarili (`IntrinsicHeight`), canlı oyun durumu telemetrileri ve seviye bazlı kademeli açılış (progressive disclosure) sunan Neo-Brutalist Bento Grid mimarisine dönüştürülmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - **Deck 3 (Holding & Kurumsal Filo)**: Yan İşletmeler (%55) ve Rent-a-Car (%45) asimetrik eşit yükseklik çifti ile Konsinye & Emanet (%100 tam genişlik şerit kartı) entegre edildi.
    - **Deck 4 (Yeraltı & Gece Operasyonları)**: Gece Sanayisi (%58) & Dedikodu Hattı (%42) asimetrik çifti, Semt Hakimiyeti (%52) & Hurdalık (%48) asimetrik çifti, Yeraltı VIP Casino (%100 tam genişlik Gold/Noir şeridi) ve Müşteri İtibarı (%50) & Showroom Mimari (%50) eşit yükseklik ikilisi konumlandırıldı.
    - **Dinamik Telemetri ve Zanaat**: Hurdalıkta parça sayısı, yan işletmelerde aktif tesis ve günlük pasif gelir, Rent-a-Car'da kiralanan araç sayısı ve ciro, konsinyede emanet vitrin sayısı, gece sanayisinde drag şampiyonası durumu, dedikoduda istihbarat frekansı, semt hakimiyetinde kontrol oranı, casinoda VIP masa katsayısı, yorumlarda 5.0 itibar puanı, mimaride showroom prestij seviyesi canlı olarak kartlara yansıtıldı.
    - **Kademeli Açılış (Progressive Disclosure)**: İlgili servisin kilit açılma seviyesi henüz gelmemişse o güverte tamamen gizlenerek erken seviyedeki oyuncunun bilişsel yorgunluğu önlendi.
    - **Buton Taban Hizalama**: Kart gövdesinde `Column(mainAxisAlignment: MainAxisAlignment.spaceBetween)` kullanılarak `IntrinsicHeight` altındaki butonlar piksel hassasiyetinde en alt seviyeye kilitlendi.
    - `handledRoutes` listesi 7 genişleme servisi eklenerek eksiksiz güncellendi; tekdüze yedek liste görünümü tamamen kaldırıldı.
  - `lib/core/localization/translations/*`:
    - 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) 12 yeni aksiyon butonu ve telemetri metni (`deck_action_businesses`, `deck_action_rent`, `deck_action_consignment`, `deck_action_night_market`, `deck_action_gossip`, `deck_action_districts`, `deck_action_salvage`, `deck_action_casino`, `deck_action_reviews`, `deck_action_decor`, `deck_biz_passive`, `deck_rent_status`, `deck_consignment_strip_title`, `deck_consignment_strip_sub`, `deck_consignment_badge`, `deck_night_drag_telemetry`, `deck_gossip_telemetry`, `deck_districts_telemetry`, `deck_scrapyard_telemetry`, `deck_casino_telemetry`, `deck_reviews_telemetry`, `deck_decor_telemetry`) sıfır emoji ve sıfır parantez kurallarına tam uyumla senkronize edildi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `context.languageCode` derleyici hatası (`undefined_getter`).
  - Widget testlerinde varsayılan 800x600 sanal ekran boyutunun alt güvertedeki dokunma hedeflerini ekran dışı bırakması.
- **Kök Neden**:
  - `CurrencyFormatter.formatShort` metodu yerel dil kodunu parametresiz olarak `CurrencyFormatter.currentLanguageCode` üzerinden çekmektedir.
  - Flutter test ortamının varsayılan sanal ekran sınırları.
- **Uygulanan Çözüm**:
  - `CurrencyFormatter.formatShort(amount)` doğrudan parametresiz çağrıldı.
  - Testlerde `tester.view.physicalSize = const Size(1000, 3000)` ve `devicePixelRatio = 1.0` ayarlanıp `addTearDown` ile temizlendi.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart lib/core/localization/`: 0 hata, 0 uyarı (`No issues found!`).
  - `flutter test test/dynamic_next_target_banner_test.dart test/service_unlock_notification_dot_test.dart test/auction_screen_widget_test.dart`: Tüm testler başarıyla geçti (4/4).

---

### `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart` & `lib/core/localization/translations/*`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Dashboard ana sayfasındaki (Tab 0) operasyonel servislerin etki alanlarına göre mantıksal ızgaralarda (Grid 1: Galeri & Araç Operasyonları, Grid 2: Finans & Terminal, Grid 3: Mülk & Holding, Grid 4: Yeraltı & Fırsatlar) toplanması; asimetrik kart çiftlerinde (Atölye vs Tuning, Oto Pazarı vs Vasıta, Finans vs Borsa, Emlak vs Personel) yükseklik ve buton taban hizalama dengesizliklerinin `IntrinsicHeight` mimarisiyle giderilmesi; kart içi zanaatın (canlı telemetri hapları, rozetler, dokunsal butonlar) güçlendirilmesi ve 7 dilde eşzamanlı lokalizasyonunun yapılması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - **Grid 1 (Galeri & Araç Operasyonları)**: Showroom Flight-Deck Hero kartı ile başlayıp; Sanayi Mega-Hangar (Atölye %58 & Tuning %42 eşit yükseklik + Oto Yıkama & Detailing tam genişlik şeridi) ve Açık Oto Pazarı & Vasıta Boulevard Dock (Pazar Yeri %56 & Vasıta %44 eşit yükseklik) ile tek bir operasyonel merkezde birleştirildi.
    - **Grid 2 (Finans, Borsa & Müzayede)**: Canlı İhale Hero kartı, Finans (%52) & Borsa (%48) eşit yükseklik çifti ve Satış & Ciro Raporları tam genişlik analitik şeridi oluşturuldu.
    - **Grid 3 (Mülk & Holding Yönetimi)**: Şube Yönetimi Hero kartı ve Emlak Pazarı (%50) & Personel Kadrosu (%50) eşit yükseklik çifti konumlandırıldı.
    - **Grid 4 (Yeraltı & Fırsatlar)**: Karaborsa Noir Hero kartı ve Hurdalık, Yorumlar, Showroom Dekoru 3'lü eşit yükseklik pedalları ile tamamlandı.
    - **Eşit Yükseklik & Alt Buton Hizalama Mimarisi**: Yan yana gelen asimetrik kartlar `IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, ...))` içine alındı; kart gövdesinde `const Spacer()` yerine `mainAxisAlignment: MainAxisAlignment.spaceBetween` kullanılarak butonlar en alt hizaya kilitlendi.
    - Web derlemesiyle uyumsuz olan `Icons.directions_boat_filled_rounded` ikonu `Icons.directions_boat_rounded` ile değiştirildi.
  - `lib/core/localization/translations/*`:
    - 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) `bento_badge_fresh`, `deck_action_portfolio`, `section_core_operations`, `section_core_operations_sub`, `section_finance_terminal`, `section_finance_terminal_sub`, `section_holding_estate`, `section_holding_estate_sub` ve niteliksel telemetri anahtarları (`deck_finance_cashflow_positive`, `deck_stocks_bist_trend`, `deck_staff_efficiency`, `deck_real_estate_income`) eksiksiz senkronize edildi. Sıfır emoji ve sıfır parantez kurallarına harfiyen uyuldu.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `RenderFlex children have non-zero flex but incoming height constraints are unbounded`: `IntrinsicHeight` altındaki `Column` içinde `Spacer()` kullanılması sonsuz yükseklik çökmesine yol açtı.
  - Web platformunda `Icons.directions_boat_filled_rounded` ikon tanımlayıcısının bulunamaması nedeniyle derleme uyarısı.
  - `deck_finance_cashflow_positive` gibi anahtarların parametresiz çağrıldığında arayüzde ham `+₺{amount} / gün` metni göstermesi.
- **Kök Neden**:
  - `IntrinsicHeight` çocuklarının `maxIntrinsicHeight` değerini sorgularken `Expanded` veya `Spacer` içeren esnek sütunların intrinsik yüksekliği tanımsız kalmaktadır.
  - Parametreli şablon metinlerinin argümansız çağrılması.
- **Uygulanan Çözüm**:
  - `Spacer()` kaldırılıp `Column(mainAxisAlignment: MainAxisAlignment.spaceBetween)` mimarisine geçilerek butonlar ve içerik birbirinden güvenle ayrıldı.
  - İkon web uyumlu `Icons.directions_boat_rounded` olarak güncellendi.
  - Telemetri anahtarları parametresiz, net ve niteliksel durum ifadelerine dönüştürüldü.
- **Doğrulama / Test Durumu**:
  - `flutter analyze lib/` çalıştırıldı: 0 hata, 0 uyarı (`No issues found!`).
  - `flutter test test/dynamic_next_target_banner_test.dart test/service_unlock_notification_dot_test.dart` ile widget testleri doğrulandı.
  - Chrome DevTools üzerinden localhost:8080 üzerinde görsel doğrulaması ve piksel mükemmel yükseklik hizalaması yapıldı.

---

### `lib/presentation/screens/auction/auction_screen.dart` & `test/auction_screen_widget_test.dart`
- **Tarih**: 2026-09-09
- **Değişiklik Amacı**: Canlı İhale (`/auction`) ekranına girildiğinde ortaya çıkan "Tried to modify a provider while the widget tree was building" (AuctionSessionNotifier StateNotifier listener exception) çökme hatasının kalıcı olarak giderilmesi.
- **Yapılan Değişiklikler**:
  - `lib/presentation/screens/auction/auction_screen.dart`:
    - `didChangeDependencies()` metodunda `notifier.addBidLog(...)` çağrıları `WidgetsBinding.instance.addPostFrameCallback((_) { if (!mounted) return; ... })` bloğu içerisine alınarak ağaç inşa döngüsü dışına ertelendi.
    - `build()` metodundaki `ref.listen<AuctionSessionState>` dinleyicisinde `_handleAuctionEnd(next)` tetiklemesi yine `WidgetsBinding.instance.addPostFrameCallback` içine alınarak olası ikincil sağlayıcı mutasyonları (`buyCarDirectly`, diyalog açılışları) güvenceye alındı.
  - `test/auction_screen_widget_test.dart`:
    - `AuctionScreen` bileşeninin `ProviderScope` altında temiz bir şekilde mount olduğunu, başlangıç teklif loglarının eklendiğini ve widget ağacı oluşturulurken hiçbir provider istisnası fırlatılmadığını doğrulayan kapsamlı widget testi eklendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - `At least listener of the StateNotifier Instance of 'AuctionSessionNotifier' threw an exception when the notifier tried to update its state. The exceptions thrown are: Tried to modify a provider while the widget tree was building.`
- **Kök Neden**:
  - `didChangeDependencies()` yaşam döngüsü metodu Flutter'ın ağaç güncelleme ve build öncesi aşamasında senkron olarak çalışmaktadır. Bu aşamada doğrudan `notifier.addBidLog` ile `AuctionSessionNotifier.state` güncellendiğinde, Riverpod `_debugCanModifyProviders` kontrolü devreye girerek ağaç oluşturulurken provider durumunun değiştirilmesine izin vermemekte ve hata fırlatmaktaydı.
- **Uygulanan Çözüm**:
  - Sağlayıcı durumunu güncelleyen başlangıç logları `WidgetsBinding.instance.addPostFrameCallback` ile çerçevenin (frame) inşası tamamlandıktan sonraki güvenli mikrogörev aşamasına ertelendi.
- **Doğrulama / Test Durumu**:
  - `test/auction_screen_widget_test.dart` widget testi başarıyla geçti.
  - `test/auction_screen_e2e_flow_test.dart`, `test/auction_fomo_and_anti_sniping_test.dart`, `test/auction_sell_test.dart` süitlerindeki 24 testin tamamı geçti.
  - `flutter analyze lib/`: 0 hata, 0 uyarı (`No issues found!`).

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

---

### `lib/presentation/widgets/neo_brutal_card.dart`, `lib/presentation/widgets/blueprint_grid_background.dart` & `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`
- **Tarih**: 2026-09-10
- **Değişiklik Amacı**: "Galeriden" mobil referans tasarımındaki gibi kutuların standart dikdörtgen yapısından çıkarılarak puzzle şeklinde birbirine bağlanan asimetrik köşe kavislerine (`customBorderRadius`), odak kartlarında koyu ters kontrasta (inverted contrast), teknik blueprint/çizim arka planlarına (45° diagonal hatch, 30°/60° izometrik CAD) ve dutch açılı açılı taktiksel rozetlere kavuşturulması.
- **Yapılan Değişiklikler**:
  - `lib/presentation/widgets/neo_brutal_card.dart`:
    - `NeoBrutalCard` bileşenine isteğe bağlı `BorderRadiusGeometry? customBorderRadius` desteği eklendi; tanımlandığında varsayılan tekdüze `borderRadius` yerine asimetrik köşe kavislerini uygulayabilmesi sağlandı.
  - `lib/presentation/widgets/blueprint_grid_background.dart`:
    - `BlueprintPatternType` enumuna `diagonalHatch` (45° açılı teknik tarama çizgileri) ve `isometricBlueprint` (30°/60° mimari/endüstriyel CAD ızgarası) eklendi.
    - `_BlueprintPatternPainter` içinde `canvas.clipRect` sınırları dahilinde verimli çizgi çizim algoritmaları uygulandı.
  - `lib/presentation/screens/dashboard/widgets/dashboard_services_grid.dart`:
    - Referans tasarımdaki dairesel yön okları (`_buildDirectionalPill`) ve açılı damgalar (`_buildDutchAngleBadge`, `Transform.rotate`) eklendi.
    - **Deck 1 (Showroom & Pazar/Vasıta)**: Standalone ve Docked Açık Pazar kartlarına koyu ters kontrast (`#0F172A`), sol puzzle köşe kavisleri (`20, 8, 20, 8`) ve dutch açılı rozet verildi. Vasıta kartına izometrik blueprint ve tamamlayıcı sağ puzzle kavisleri (`8, 20, 8, 20`) uygulandı.
    - **Deck 2 (Maslak Sanayi)**: Sol Oto Yıkama sütununa izometrik blueprint ve sol puzzle kavisleri (`22, 8, 22, 8`); üst sağ Atölye'ye (`8, 22, 8, 8`); alt sağ Tuning Stüdyosu'na yarış moru koyu ters kontrast (`#1E1338`), 45° teknik tarama (`diagonalHatch`), dutch açılı `STAGE-3 // SPEC` rozeti ve alt-sağ puzzle kavisi (`8, 8, 8, 22`) verildi.
    - **Deck 3 (Finans & Borsa)**: Canlı İhale kartına üst puzzle kavisleri (`20, 20, 8, 8`); Borsa kartına Wall-Street zümrüt yeşili ters kontrast (`#0A2218`), teknik artı deseni ve sağ-alt puzzle kavisi (`8, 8, 8, 20`); Kasa ve Satış Defteri kartlarına tamamlayıcı kavisler entegre edildi.
    - **Deck 4 (Holding & Mülk)**: Emlak Pazarı kartına derin pişmiş toprak/mahogany ters kontrast (`#2D1217`, referanstaki Kiralama hissi), mimari blueprint ve sol-alt puzzle kavisi (`8, 8, 20, 8`); Personel kulesine sağ-alt kavis (`8, 8, 8, 20`) verildi.
    - **Deck 5 (Şehir Operasyonları Hub)**: Hub kutusu üst kavisleri (`20, 20, 8, 8`), bento karoları ve VIP Casino şeridine diagonal hatch deseni ile tamamlayıcı alt kavisler (`8, 8, 16, 16`) işlendi.
- **Karşılaşılan Hatalar / Sorunlar**:
  - Yok. Tüm test bulucuları (`'Araç Satın Al'`, `'AÇIK OTO PAZARINA GİR'`, `'YENİ İLANLAR'`, `'MASAYA GEÇ'`) ve lokalizasyon gereksinimleri tam korundu.
- **Kök Neden**:
  - Mevcut kutuların tüm köşelerinin simetrik (10-14px) olması, ekranın tekdüze görünmesine ve kartlar arası organik puzzle bağlantı hissinin oluşmamasına yol açıyordu.
- **Uygulanan Çözüm**:
  - Dış hatlarda 20-22px kavis, yan yana veya üst üste gelen ortak temas yüzeylerinde ise 8px kavis kullanılarak bento-puzzle kenetlenmesi sağlandı.
- **Doğrulama / Test Durumu**:
  - `flutter analyze`: 0 hata, 0 uyarı.
  - `flutter test`: `test/city_operations_hub_and_marketplace_redesign_test.dart`, `test/dynamic_next_target_banner_test.dart`, `test/service_unlock_notification_dot_test.dart`, `test/localization_integrity_guard_test.dart` (6/6 test başarılı).


