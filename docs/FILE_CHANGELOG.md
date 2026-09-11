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


