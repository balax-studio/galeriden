# SPEC-004: UI Ekran Modülerleştirmesi (Hotspot Refactoring) ve Altın Widget Testleri (Golden Tests)

## 1. Hedef ve Kapsam (Objective)

Bu şartname, Galeriden Tycoon kod tabanında 1.900 ile 2.100 satır arasındaki 5 büyük UI ekranının (`ScrapyardScreen`, `NegotiationScreen`, `InteractiveNegotiationSheet`, `WorkshopScreen`, `AuctionScreen`) Single Responsibility ve Clean Architecture prensiplerine uygun olarak bağımsız, yeniden kullanılabilir ve test edilebilir alt bileşenlere ayrıştırılmasını ve temel Neo-Brutalist bileşenler için Piksel Düzeyinde Altın Widget Testlerinin (Golden Tests) eklenmesini tanımlar.

**Hedef:** Kod tabanındaki tüm dosyaların 800 satır altına indirilerek **Modülerlik ve Kod Sağlığı Skorunun %100'e (10.0 / 10.0 - Derece A+)** çıkarılması.

---

## 2. Modülerleştirme Mimarisi (Phase 4)

### 2.1. Hurdalık Ekranı (`ScrapyardScreen` • 2.104 satırdan ~250 satıra)
- **Ana Dosya:** [`lib/presentation/screens/scrapyard/scrapyard_screen.dart`](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/scrapyard/scrapyard_screen.dart)
- **Yeni Alt Bileşenler:**
  - `lib/presentation/screens/scrapyard/widgets/scrapyard_inventory_tab.dart`: Çıkma yedek parça listesi, kalite filtre çipleri (Aşınmış, Kullanılabilir, İyi, Kusursuz), parça arama ve envanter istatistikleri.
  - `lib/presentation/screens/scrapyard/widgets/scrapyard_dismantle_tab.dart`: Hurda araç seçimi, `ScrapyardTeardownCanvas` mini oyun entegrasyonu ve parça söküm ödülleri.
  - `lib/presentation/screens/scrapyard/widgets/scrapyard_crusher_tab.dart`: Hidrolik pres animasyonu (`HydraulicCrushWaveWidget`), hurda eritme çarpanı ve anında nakit satışı.
  - `lib/presentation/screens/scrapyard/widgets/scrapyard_install_dialog.dart`: Sökülen parçayı garajdaki uygun araca monte etme seçim modalı.

### 2.2. Atölye Ekranı (`WorkshopScreen` • 1.994 satırdan ~280 satıra)
- **Ana Dosya:** [`lib/presentation/screens/workshop/workshop_screen.dart`](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/workshop/workshop_screen.dart)
- **Yeni Alt Bileşenler:**
  - `lib/presentation/screens/workshop/widgets/workshop_stations_tab.dart`: 5 tamir lifti (Motor, Şanzıman, ECU, Kaporta, Şasi), arıza tespit raporu ve tamir tier seçim paneli.
  - `lib/presentation/screens/workshop/widgets/workshop_orders_tab.dart`: Bekleyen kargo siparişleri, `AnimatedOrderCard` listesi ve hava kargo hızlandırma entegrasyonu.
  - `lib/presentation/screens/workshop/widgets/workshop_upgrades_tab.dart`: Lift kapasite artırımı, diagnostik cihaz alımı ve atölye prestij rozetleri.

### 2.3. Müzayede Ekranı (`AuctionScreen` • 1.945 satırdan ~260 satıra)
- **Ana Dosya:** [`lib/presentation/screens/auction/auction_screen.dart`](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/auction/auction_screen.dart)
- **Yeni Alt Bileşenler:**
  - `lib/presentation/screens/auction/widgets/auction_live_bidding_view.dart`: Canlı teklif podyumu, geri sayım sayacı, rakip bot teklif akışı ve oyuncu pey sürme butonları.
  - `lib/presentation/screens/auction/widgets/auction_upcoming_lots_tab.dart`: Müzayede kataloğu, ekspertiz ön izlemesi, piyasa değeri tahmini ve takvim.
  - `lib/presentation/screens/auction/widgets/auction_hammer_result_modal.dart`: Tokmak vurma animasyonu, kazanılan/kaybedilen araç sonuç raporu ve komisyon ödeme akışı.

### 2.4. Pazarlık Ekranı & Çarşafı (`NegotiationScreen` & `InteractiveNegotiationSheet` • 4.133 satırdan modüler yapıya)
- **Ana Dosyalar:** 
  - [`lib/presentation/screens/marketplace/negotiation_screen.dart`](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/marketplace/negotiation_screen.dart)
  - [`lib/presentation/screens/marketplace/interactive_negotiation_sheet.dart`](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/marketplace/interactive_negotiation_sheet.dart)
- **Paylaşılan Alt Bileşenler:**
  - `lib/presentation/screens/marketplace/widgets/negotiation/negotiation_dialogue_card.dart`: Müşteri psikolojik durum ikonu, diyalog balonu ve sabır göstergesi.
  - `lib/presentation/screens/marketplace/widgets/negotiation/negotiation_offer_keypad.dart`: Hızlı teklif artırma/azaltma çipleri, özel fiyat slider'ı ve el sıkışma aksiyonu.
  - `lib/presentation/screens/marketplace/widgets/negotiation/negotiation_deal_outcome_modal.dart`: Başarılı anlaşma / masadan kalkma sonuç penceresi ve noter yönlendirmesi.

---

## 3. Altın Widget Testleri (Phase 5: Golden Regression Suite)

### 3.1. Test Kapsamı (`test/golden_widget_tests.dart`)
- `NeoBrutalButton`: Standart, ikonsuz, devre dışı (disabled) ve tehlike (danger) durumları.
- `NeoBrutalBadge`: Çeşitli renk temaları (Sarı, Yeşil, Kırmızı, Mavi) ve kompakt boyutlar.
- `NeoBrutalCard`: Kalın 2.5px/3px siyah kenarlık, 4x4 offset sert gölge ve yuvarlatılmış köşe render doğrulaması.
- `CarDamageSchemaWidget`: 320dp dar ekran ve 400dp standart ekranda araç parça hasar şemasının Wrap düzeni.
- `GenericRushJobDialog`: Hızlandırma modalının başlık rozeti, hikaye gövdesi ve reaktif buton hiyerarşisi.

---

## 4. Değişmez Kurallar (Invariant Boundaries)

1. **Sıfır Davranış Değişikliği (Pure Refactoring):** Hiçbir oyun mekaniği, kuralı, state akışı veya buton davranışı değişmeyecektir.
2. **Sıfır Unicode Emoji & Sıfır Parantez:** Tüm yeni ayrıştırılan dosyalarda bu kural korunacaktır.
3. **7 Dilde Eksiksiz Çeviri:** Tüm metinler `context.tr()` üzerinden çekilmeye devam edecektir.
4. **%100 Yeşil Test Güvencesi:** 695 testin tamamı ve yeni eklenen testler kesintisiz geçecektir.

---

## 5. Başarı Kriterleri (Success Criteria)

- [ ] `lib/` altındaki hiçbir Dart dosyasının satır sayısı 800 satırı geçmeyecek (çeviri dosyaları hariç).
- [ ] `flutter analyze`: 0 hata, 0 uyarı, 0 lint kusuru.
- [ ] `flutter test`: 695 mevcut test + yeni altın ve birim testlerinin tümü başarılı olacak.
- [ ] Kod Sağlığı Skoru **10.0 / 10.0 (%100)** seviyesine ulaşacak.
