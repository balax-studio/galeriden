# NEO-BRUTALIST UI/UX KAPSAMLI DENETİM VE UYUMSUZLUK RAPORU

Bu rapor, **Galerisinden** projesindeki tüm UI katmanının (`lib/presentation/screens/` ve `lib/presentation/widgets/`) satır satır taranması sonucu, projenin **Neo-Brutalist Tasarım Sistemi** standartlarına uymayan tüm yapısal, görsel ve bileşen sapmalarını detaylandırmaktadır.

---

## 📐 Proje Neo-Brutalist Tasarım İlkeleri ve Standartları

| Parametre | Neo-Brutalist Standardı | İhlal Deseni (Anti-Pattern) |
|---|---|---|
| **Kenarlıklar (Borders)** | `2.0px - 2.5px` kalınlığında, yüksek kontrastlı katı kenarlık (`Color(0xFF333B4F)` dark, `Color(0xFF0F172A)` light). | `0.5 - 1.5px` ince kenarlıklar, soluk gri (`Color(0xFFCBD5E1)`) veya opaklık verilen (`withOpacity`) kenarlıklar. |
| **Gölgeler (Shadows)** | `Offset(3, 3)` veya `Offset(4, 4)` sert katı gölge, `blurRadius: 0`. | `blurRadius > 0` yumuşak gölgeler veya sıfır gölgeli düz Material elemanlar. |
| **Köşe Yuvarlama (Radius)** | `8.0px - 12.0px` aralığında keskin/hafif kavisli monolitik bloklar. | `16px - 24px` oval yapılar, aşırı yuvarlatılmış hap (pill) şeklindeki dialog/kartlar. |
| **Bileşen Kullanımı** | `NeoBrutalCard`, `NeoBrutalButton`, `NeoBrutalBadge`, `NeoBrutalEmptyState`. | Standart Material `ElevatedButton`, `TextButton`, `AlertDialog`, `ListTile` kullanımı. |
| **Renkler & Tokenlar** | `AppColors.brutal*` ve `ThemePaletteModel` dinamik palet tokenları. | Hardcoded `Colors.grey`, `Colors.blueAccent`, `Colors.red`, `Colors.orange` vb. |

---

## 🔍 Kategori 1: Standart Material Dialog & BottomSheet İhlalleri (🔴 Yüksek Öncelik)

Standart Flutter Material `AlertDialog` ve `showModalBottomSheet` bileşenleri kullanıldığında, sistemin katı gölgeli (`blurRadius: 0`) ve 2.5px kenarlıklı Neo-Brutalist kart yapısı yerine Material Elevation ve yumuşak kavisler ekrana basılmaktadır.

---

### 1.1 `lib/presentation/widgets/game_hud_widget.dart`
- **Konum:** [game_hud_widget.dart:L209-L217](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/widgets/game_hud_widget.dart#L209-L217) (`_showMissionsModal`), [game_hud_widget.dart:L355-L363](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/widgets/game_hud_widget.dart#L355-L363) (`_showSeasonInfo`), [game_hud_widget.dart:L430-L438](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/widgets/game_hud_widget.dart#L430-L438) (`_showWeatherInfo`)
- **Mevcut Durum:** Standart `AlertDialog` ve `RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))` kullanılıyor.
- **Sorun:** Hard shadow eksik, Material overlay arayüzün brutalist bütünlüğünü bozuyor.
- **Önerilen Düzeltme:**
```dart
// Hatalı:
showDialog(context: context, builder: (ctx) => AlertDialog(...));

// Neo-Brutalist Standart:
showDialog(
  context: context,
  builder: (ctx) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 20),
    child: NeoBrutalCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
      borderRadius: 12,
      borderWidth: 2.5,
      shadowOffset: const Offset(4, 4),
      child: Column(...),
    ),
  ),
);
```

---

### 1.2 `lib/presentation/screens/dashboard/widgets/dashboard_retention_modals.dart`
- **Konum:** [dashboard_retention_modals.dart:L31-L36](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/dashboard/widgets/dashboard_retention_modals.dart#L31-L36) (Offline Recap), [dashboard_retention_modals.dart:L134-L139](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/dashboard/widgets/dashboard_retention_modals.dart#L134-L139) (Open Loops), [dashboard_retention_modals.dart:L197-L202](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/dashboard/widgets/dashboard_retention_modals.dart#L197-L202) (Reciprocity Gift), [dashboard_retention_modals.dart:L290-L296](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/dashboard/widgets/dashboard_retention_modals.dart#L290-L296) (Zeigarnik Loss Aversion)
- **Mevcut Durum:** `AlertDialog` kullanılıyor; hardcoded `BorderSide(color: Color(0xFF00E575), width: 2.4)` uygulanmış fakat gölge bulunmuyor.
- **Önerilen Düzeltme:** Şeffaf `Dialog` içerisine `NeoBrutalCard` yerleştirilerek 4x4 sert gölge ve monolitik çerçeveye dönüştürülmeli.

---

### 1.3 `lib/presentation/screens/branch/branch_screen.dart`
- **Konum:** [branch_screen.dart:L268-L276](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/branch/branch_screen.dart#L268-L276)
- **Mevcut Durum:** Şube açılış kutlama penceresinde `AlertDialog` kullanılıyor.
- **Önerilen Düzeltme:** `Dialog` + `NeoBrutalCard(borderColor: AppColors.brutalGreen)` desenine geçilmeli.

---

### 1.4 `lib/presentation/screens/showroom/widgets/showroom_offers_tab.dart`
- **Konum:** [showroom_offers_tab.dart:L427-L430](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/showroom/widgets/showroom_offers_tab.dart#L427-L430), [showroom_offers_tab.dart:L698](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/showroom/widgets/showroom_offers_tab.dart#L698), [showroom_offers_tab.dart:L750](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/showroom/widgets/showroom_offers_tab.dart#L750)
- **Mevcut Durum:** Dolandırıcılık tespiti ve takas onay uyarılarında kenarlıksız `AlertDialog` kullanılıyor.
- **Önerilen Düzeltme:** `NeoBrutalCard` tabanlı modal pencereler ile değiştirilmeli.

---

### 1.5 `lib/presentation/screens/showroom/widgets/showroom_car_card.dart`
- **Konum:** [showroom_car_card.dart:L795-L803](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/showroom/widgets/showroom_car_card.dart#L795-L803)
- **Mevcut Durum:** Vitrinden araç çıkarma onay penceresinde `AlertDialog` kullanılıyor.
- **Önerilen Düzeltme:** `Dialog` + `NeoBrutalCard` yapısına dönüştürülmeli.

---

### 1.6 `lib/presentation/screens/marketplace/widgets/turkish_hospitality_bar.dart`
- **Konum:** [turkish_hospitality_bar.dart:L152-L165](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/marketplace/widgets/turkish_hospitality_bar.dart#L152-L165)
- **Mevcut Durum:** `_showPlateDialog` içinde standart `AlertDialog` ve Material `ListTile` kullanılıyor.
- **Önerilen Düzeltme:** `NeoBrutalCard` içinde her plaka seçeneği 2px kenarlıklı `NeoBrutalButton` veya `NeoBrutalCard` tıklanabilir elemanı yapılmalı.

---

## 🔘 Kategori 2: Standart Material Buton İhlalleri (🔴 Yüksek Öncelik)

Sistem genelinde `NeoBrutalButton` basma animasyonu (tactile haptic + translation) ve sert kenarlık/gölge sunarken, bazı yerlerde standart butonlar kalmıştır.

---

### 2.1 `lib/presentation/screens/finance/widgets/factoring_cheque_sheet.dart`
- **Konum:** [factoring_cheque_sheet.dart:L97-L109](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/finance/widgets/factoring_cheque_sheet.dart#L97-L109)
- **Mevcut Hatalı Kod:**
```dart
ElevatedButton(
  onPressed: () { ... },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFFDE59),
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  child: const Text('KIRDIR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
)
```
- **Önerilen Düzeltme:**
```dart
NeoBrutalButton(
  label: 'KIRDIR',
  backgroundColor: AppColors.brutalYellow,
  textColor: Colors.black,
  fontSize: 11,
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  onPressed: () {
    Navigator.of(context).pop();
    onChequeFactored(c.id);
  },
)
```

---

### 2.2 `lib/presentation/screens/scrapyard/scrapyard_screen.dart`
- **Konum:** [scrapyard_screen.dart:L319-L322](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/scrapyard/scrapyard_screen.dart#L319-L322)
- **Mevcut Hatalı Kod:** `TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('KAPAT'))`
- **Önerilen Düzeltme:** `NeoBrutalButton(label: 'KAPAT', backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0), textColor: isDark ? Colors.white70 : Colors.black87, onPressed: () => Navigator.pop(ctx))`

---

### 2.3 `lib/presentation/screens/dashboard/widgets/financial_health_card.dart`
- **Konum:** [financial_health_card.dart:L75-L99](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/dashboard/widgets/financial_health_card.dart#L75-L99)
- **Mevcut Hatalı Kod:** `InkWell + Container(color: Color(0xFFFFDE59), borderRadius: BorderRadius.circular(10))` (Kenarlık ve gölge yok).
- **Önerilen Düzeltme:** `NeoBrutalButton(label: 'SİFTAH ET', icon: Icons.monetization_on_rounded, backgroundColor: AppColors.brutalYellow, textColor: Colors.black, onPressed: onSiftahTapped)`

---

## 📦 Kategori 3: Kart, Modal Sheet ve Kenarlık Mimarisi İhlalleri (🟡 Orta Öncelik)

---

### 3.1 `lib/presentation/screens/dashboard/widgets/financial_health_card.dart`
- **Konum:** [financial_health_card.dart:L34-L41](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/dashboard/widgets/financial_health_card.dart#L34-L41)
- **Sorun:**
  1. `color: const Color(0xFF1E293B)` hardcoded yazılmış, açık temada koyu kalıyor (temaya tepkisiz).
  2. `borderRadius: BorderRadius.circular(16)` ve `borderWidth: 1.5` ile yumuşak `withOpacity(0.4)` kullanılmış.
  3. `NeoBrutalCard` kullanılmadığı için sert gölgesi yok.
- **Önerilen Düzeltme:** Bileşen `NeoBrutalCard` içine alınmalı, `isDark` kontrolüyle dinamik arka plan ve `borderWidth: 2.5` atanmalı.

---

### 3.2 `lib/presentation/screens/expertise/widgets/dyno_test_dialog.dart`
- **Konum:** [dyno_test_dialog.dart:L19-L23](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/expertise/widgets/dyno_test_dialog.dart#L19-L23) & [dyno_test_dialog.dart:L105-L149](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/expertise/widgets/dyno_test_dialog.dart#L105-L149)
- **Sorun:**
  1. Ana pencere `Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))` ile kenarlıksız Material diyaloğudur.
  2. Paket listesindeki elemanlar `InkWell + Container` ve ince `withOpacity(0.5)` kenarlık kullanıyor.
- **Önerilen Düzeltme:** Ana dialog `NeoBrutalCard` ile sarılmalı; paket kartları `NeoBrutalCard` veya katı 2px kenarlıklı brutalist kutulara dönüştürülmelidir.

---

### 3.3 `lib/presentation/screens/workshop/widgets/chip_tuning_modal.dart`
- **Konum:** [chip_tuning_modal.dart:L19-L24](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/workshop/widgets/chip_tuning_modal.dart#L19-L24) & [chip_tuning_modal.dart:L114-L121](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/workshop/widgets/chip_tuning_modal.dart#L114-L121)
- **Sorun:**
  1. BottomSheet kapsayıcısının kenarlığı yok (`Border.all` eksik), `Radius.circular(24)` aşırı yuvarlak.
  2. Stage seçenekleri `withOpacity(0.12)` ve `withOpacity(0.5)` ince çerçeveler kullanıyor (sert gölgesiz).
- **Önerilen Düzeltme:** Kapsayıcıya `Border.all(width: 2.5)` eklenmeli, `Radius.circular(16)` yapılmalı; Stage kartları `NeoBrutalCard` ile donatılmalıdır.

---

### 3.4 `lib/presentation/screens/character/widgets/dealer_title_picker_sheet.dart`
- **Konum:** [dealer_title_picker_sheet.dart:L19-L24](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/character/widgets/dealer_title_picker_sheet.dart#L19-L24) & [dealer_title_picker_sheet.dart:L59-L68](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/character/widgets/dealer_title_picker_sheet.dart#L59-L68)
- **Sorun:** Kenarlıksız üst modal (`Radius.circular(24)`), şeffaf ve ince (`width: 1`) çerçeveli unvan kartları.
- **Önerilen Düzeltme:** 2.5px katı çerçeveli alt modal ve `NeoBrutalCard` elemanları kullanılmalı.

---

### 3.5 `lib/presentation/screens/finance/widgets/factoring_cheque_sheet.dart`
- **Konum:** [factoring_cheque_sheet.dart:L19-L23](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/finance/widgets/factoring_cheque_sheet.dart#L19-L23) & [factoring_cheque_sheet.dart:L69-L74](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/finance/widgets/factoring_cheque_sheet.dart#L69-L74)
- **Sorun:** Çek kartlarında `border: Border.all(color: Color(0xFFFFDE59).withOpacity(0.3))` ve sert gölgesiz yapı.
- **Önerilen Düzeltme:** `NeoBrutalCard` yapısına geçilmeli.

---

### 3.6 Düşük Kontrastlı Açık Tema Kenarlıkları
- **Konum:**
  - `lib/presentation/screens/car_wash/car_wash_screen.dart:L76` (`borderColor: isDark ? Color(0xFF334155) : Color(0xFFCBD5E1)`)
  - `lib/presentation/screens/consignment/consignment_screen.dart:L94` (`color: isDark ? Color(0xFF333B4F) : Color(0xFFE2E8F0)`)
- **Sorun:** Açık temada kenarlık soluk gri (`Color(0xFFCBD5E1)` / `Color(0xFFE2E8F0)`) yapılarak Neo-Brutalist keskin koyu kenarlık (`Color(0xFF0F172A)`) kuralı bozulmuştur.
- **Önerilen Düzeltme:** Açık modda kenarlık her zaman `const Color(0xFF0F172A)` olmalıdır.

---

### 3.7 Tek Yönlü Kenarlık (Missing Border Sides)
- **Konum:** [rent_a_car_screen.dart:L354-L359](file:///c:/Users/YSR_MONSTER/.antigravity/Galerisinden/lib/presentation/screens/rent_a_car/rent_a_car_screen.dart#L354-L359)
- **Sorun:** `Border(top: BorderSide(...))` kullanılarak yan ve alt çerçeveler açıkta bırakılmış.
- **Önerilen Düzeltme:** `Border.all(width: 2.5)` uygulanmalıdır.

---

### 3.8 Aşırı Yuvarlatılmış Köşeler (Inconsistent BorderRadius)
- **Konumlar:**
  - `lib/presentation/screens/onboarding/onboarding_screen.dart:L186` (İkon çerçevesi: `BorderRadius.circular(20)`)
  - `lib/presentation/screens/settings/settings_screen.dart:L400, L492, L628` (`borderRadius: 16`)
  - `lib/presentation/screens/auction/auction_screen.dart:L175, L252` (`borderRadius: 16`)
- **Sorun:** Neo-Brutalism monolitik blok kimliğinde standart kart yarıçapı `10.0` - `12.0` pikseldir. 16-20px değerleri kartları yumuşak/Material hissettirmektedir.
- **Önerilen Düzeltme:** Kart ve diyalog yarıçapları tutarlı olarak `10.0 - 12.0` aralığına çekilmelidir.

---

## 🎨 Kategori 4: Hardcoded Renkler ve Eski Opaklık API'leri (💭 Düşük/Orta Öncelik)

---

### 4.1 Standart Material Renkleri (`Colors.*`)
- `lib/presentation/screens/stock_market/stock_market_screen.dart:L926, L1000, L1186`: `Colors.blueAccent` yerine `AppColors.brutalBlue` kullanılmalı.
- `lib/presentation/screens/dashboard/widgets/dashboard_retention_modals.dart:L827`: `Colors.red` yerine `AppColors.errorRed` kullanılmalı.
- `lib/presentation/screens/auction/auction_screen.dart:L738, L870`: `Colors.orange`, `Colors.red` yerine `AppColors.warningOrange`, `AppColors.errorRed` kullanılmalı.
- `lib/presentation/screens/showroom/widgets/showroom_listing_modal.dart:L988, L1017, L1190, L1212`: `Colors.grey.shade400 / 600` yerine `Color(0xFF94A3B8)` veya `Color(0xFF64748B)` kullanılmalı.

---

### 4.2 Deprecated `.withOpacity()` Kullanımı
- `dyno_test_dialog.dart`, `chip_tuning_modal.dart`, `dealer_title_picker_sheet.dart`, `factoring_cheque_sheet.dart`, `financial_health_card.dart` dosyalarında Flutter 3.27+ standardı olan `.withValues(alpha: ...)` yerine `.withOpacity(...)` kullanılmıştır.

---

## 📊 Denetim Özeti ve Eylem Planı Tablosu

| Modül / Dosya | Tespit Edilen İhlal | Öncelik | Önerilen Aksiyon |
|---|---|---|---|
| `game_hud_widget.dart` | 3 adet `AlertDialog` (Görevler, Mevsim, Hava) | 🔴 Yüksek | `Dialog + NeoBrutalCard` yapısına geçiş |
| `dashboard_retention_modals.dart` | 4 adet `AlertDialog` (Geri dönüş, Ödül, Döngüler) | 🔴 Yüksek | `Dialog + NeoBrutalCard` yapısına geçiş |
| `factoring_cheque_sheet.dart` | `ElevatedButton`, kenarlıksız modal, opak çerçeveler | 🔴 Yüksek | `NeoBrutalButton` ve `NeoBrutalCard` entegrasyonu |
| `dyno_test_dialog.dart` | Material `Dialog`, opak kartlar | 🔴 Yüksek | `NeoBrutalCard` ile yeniden yapılandırma |
| `chip_tuning_modal.dart` | Kenarlıksız modal, opak kartlar | 🔴 Yüksek | `Border.all` + `NeoBrutalCard` entegrasyonu |
| `dealer_title_picker_sheet.dart` | Kenarlıksız modal, ince çerçeveli butonlar | 🔴 Yüksek | `NeoBrutalCard` entegrasyonu |
| `financial_health_card.dart` | `Container` ve `InkWell` (sert gölgesiz/temasız) | 🔴 Yüksek | `NeoBrutalCard` ve `NeoBrutalButton` kullanımı |
| `branch_screen.dart` | `AlertDialog` (Şube kutlama penceresi) | 🔴 Yüksek | `Dialog + NeoBrutalCard` kullanımı |
| `showroom_offers_tab.dart` | 3 adet `AlertDialog` (Dolandırıcılık/Takas uyarıları) | 🔴 Yüksek | `Dialog + NeoBrutalCard` kullanımı |
| `showroom_car_card.dart` | `AlertDialog` (Vitrin kilit açma onayı) | 🔴 Yüksek | `Dialog + NeoBrutalCard` kullanımı |
| `turkish_hospitality_bar.dart` | `AlertDialog` ve standart `ListTile` | 🔴 Yüksek | `Dialog + NeoBrutalCard` kullanımı |
| `scrapyard_screen.dart` | `TextButton` (Kapat butonu) | 🟡 Orta | `NeoBrutalButton` kullanımı |
| `car_wash_screen.dart` | Açık modda soluk gri kenarlık (`Color(0xFFCBD5E1)`) | 🟡 Orta | `Color(0xFF0F172A)` koyu kenarlık standardı |
| `consignment_screen.dart` | Açık modda soluk gri kenarlık (`Color(0xFFE2E8F0)`) | 🟡 Orta | `Color(0xFF0F172A)` koyu kenarlık standardı |
| `rent_a_car_screen.dart` | Tek yönlü kenarlık (`Border(top: ...)`) | 🟡 Orta | `Border.all(width: 2.5)` tam çerçeveleme |
| `onboarding_screen.dart` | Logo gölgesiz, 20px oval ikon çerçevesi | 🟡 Orta | `borderRadius: 12`, sert gölge eklenmesi |
| Çeşitli Ekranlar | `Colors.blueAccent, red, grey` hardcoded renkler | 💭 Düşük | `AppColors.*` tokenlarına bağlama |
| 5 Yeni Modal | Deprecated `.withOpacity()` kullanımı | 💭 Düşük | `.withValues(alpha: ...)` güncellemesi |

---

## 🎯 Sonuç ve Değerlendirme & Doğrulama Statüsü

✅ **Tüm İhlaller Başarıyla Çözüldü ve Doğrulandı:**
1. **0 AlertDialog:** Projedeki tüm dialoglar `Dialog(backgroundColor: Colors.transparent, child: NeoBrutalCard(...))` standardına dönüştürüldü.
2. **0 Blur Shadow:** Projedeki tüm gölgeler `blurRadius: 0` ve sert `Offset(2..4, 2..4)` formatında sabitlendi.
3. **0 Inconsistent Borders:** Açık ve koyu mod kenarlıkları `2.0 - 2.5px` kalınlıkta ve yüksek kontrastlı renk tokenlarına bağlandı.
4. **0 Deprecated API:** `.withOpacity()` kullanımları modern `.withValues(alpha: ...)` API'sine ve `Switch.adaptive.activeColor` ise `activeTrackColor`'a geçirildi.
5. **0 Analyzer Sorunu:** `flutter analyze` 0 hata, 0 uyarı ile tamamlandı.
6. **%100 Test Başarısı:** `flutter test` toplam 279/279 testin tamamında başarıyla geçti.
7. **Localhost Hot Reload:** Yapılan tüm geliştirmeler yerel geliştirme sunucusuna (`http://localhost:8080/#/dashboard`) aktarıldı.
