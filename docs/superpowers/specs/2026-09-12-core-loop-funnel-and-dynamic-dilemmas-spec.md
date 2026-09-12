# Spec: Çekirdek Döngü Dönüşüm Hunisi, Seviye 1 Kalibrasyonu, İflas Koruma Ağı ve Dinamik Durumsal Dilemma Sistemi (§SPEC-2026-09-12-CORE-LOOP-FUNNEL-AND-DYNAMIC-DILEMMAS)

## 1. Problem Tanımı ve GA4 Veri Kanıtları
Son 28 günlük Firebase/GA4 analitik verileri (`Events_Event_name.csv`) incelendiğinde oyunun erken aşamasında 4 kritik darboğaz tespit edilmiştir:
1. **Araç Satışının Sıfıra Yakın Olması (`car_sold: 5`, sadece 1 kullanıcı)**: 17 kullanıcı 213 gün atlamasına rağmen sadece 1 kullanıcı araç satabilmiştir. Alınan araçlar otomatik ilana çıkmamakta (`isListed = false`), ilan verme ekranı galeride gizli kalmakta ve ilansız araçlara müşteri teklifi üretilmemektedir (`triggerOrganicOffers`).
2. **Seviye 1 XP Barajının Aşılamaz Olması (`level_up: 9`, sadece 5 kullanıcı)**: Seviye 1 için gereken XP tam **1.500 XP**'dir. Araç alımı 30 XP, satışı 120 XP verirken, satış yapamayan bir oyuncunun Seviye 2'ye geçmesi için 50 araç alması gerekmektedir.
3. **İflas Kısır Döngüsü (`game_bankruptcy: 16`, 2 kullanıcı)**: `ContextualEmergencyAdEngine` mevcut olmasına rağmen Dashboard ve gün atlamada tetiklenmemektedir. Bakiye eksiye düştüğü an oyuncu kurtarma şansı bulamadan arka arkaya 8 gün boyunca iflas logu üretmektedir.
4. **365 Günlük Statik Kart Sistemi ve Kopuk Analitik (`random_event_choice: 10`, 1 kullanıcı)**: 365 günlük takvime bağlı statik kartlar oyuncunun anlık durumundan (iflas, atıl araç, acemilik) bağımsız çalışmakta, ana ekranda fark edilmeyen bir banner olarak kalmakta ve `resolveDramaticCardChoice` içinde analitik kaydı (`logRandomEventChoice`) çağrılmamaktadır.

---

## 2. Mimari Çözüm ve Modül Haritası (Capability Map)

| Modül ID | Sorumluluk | Bağımlılıklar | Öncelik |
| :--- | :--- | :--- | :--- |
| `quick-listing-and-first-sale` | Satın alma sonrası tek tıkla hızlı ilan verme ve ilk araç için 5-10s içinde garanti alıcı teklifi. | `game_market_mixin`, `negotiation_screen` | **P0** |
| `level-progression-calibration` | Seviye 1 barajını 250 XP'ye düşürme; ilk satış + ilk günle anında Seviye 2 açılışı. | `player_skills.dart`, `game_core_provider` | **P0** |
| `emergency-bailout-safety-net` | Negatif bakiyede Dashboard'da otomatik açılan esnaf can suyu (reklamla +₺50k hibe veya spot satış). | `contextual_emergency_ad_engine`, `game_time_mixin` | **P1** |
| `contextual-dynamic-dilemmas` | 365 günlük statik kartları kaldırıp durumsal (iflas, acemi, atıl araç, zengin) dinamik pop-up kart motoru ve analitik entegrasyonu. | `dramatic_card_engine`, `neo_brutal_dramatic_dialog` | **P1** |
| `early-ad-monetization` | İlan verirken "Sarı Site Vitrin Dopingi" ve pazarda "Listeyi Yenile" reklam modelleri. | `create_listing_screen`, `ad_service` | **P2** |

---

## 3. Detaylı Teknik Tasarım

### 3.1. Modül 1: Hızlı İlan ve İlk Satış Garantisi (P0)
- **Noter Sonrası Hızlı İlan BottomSheet'i (`QuickListingSheet`)**:
  - Noter devri (`NotaryTransferDialog`) kapandığında, oyuncu doğrudan pazara dönmek yerine `QuickListingSheet` ile karşılanır.
  - Formül: `tavsiyeEdilenFiyat = (estimatedRealValue * 1.15).roundToDouble()`
  - Tek dokunuşla "HEMEN İLANA KOY & MÜŞTERİ BEKLE" butonu araca `customListingPrice` atar ve `isListed = true` yapar.
  - "Daha Sonra Galeriden Ayarla" butonu ile kapatılabilir.
- **İlk Satış Garantisi (Guaranteed First Buyer)**:
  - `game_market_mixin.dart` -> `triggerOrganicOffers()`:
  - Eğer `state.salesHistory.isEmpty` ve `eligibleCars.isNotEmpty` ise:
    - 5 ile 8 saniye gecikmeyle (veya gün atlandığında kesin olarak) ilk alıcı teklifi oluşturulur.
    - Alıcı teklifi kârlıdır: `offeredAmount = (car.currentPurchasePrice * 1.12).roundToDouble()`
    - Sistem HUD'ında veya ekranda "İlk Müşterin Kapıda!" bildirimi gösterilir.

### 3.2. Modül 2: Seviye 1 XP Barajının Kalibrasyonu (P0)
- `lib/data/models/player_skills.dart`:
  - `requiredXpForLevel(1)`: 1.500 XP -> **250 XP**
  - `requiredXpForLevel(2)`: 3.750 XP -> **750 XP**
  - `requiredXpForLevel(3)`: 7.500 XP -> **1.800 XP**
  - `requiredXpForLevel(4)`: 14.000 XP -> **4.500 XP**
- İlk Oyun Akışı Hesabı:
  - 1. Araç Satın Alımı: 30 XP
  - 1. Araç Detaylı Temizlik / Yıkama: 40 XP
  - 1. Araç Satışı: ~150 XP
  - 1. Gün Atlama: 50 XP
  - **Toplam: 270 XP >= 250 XP -> Seviye 2'ye Geçiş ve Kutlama Modalı!**

### 3.3. Modül 3: İflas Koruma Ağı & Esnaf Can Suyu (P1)
- `lib/presentation/providers/game/game_time_mixin.dart`:
  - Gün atlandığında `newBalance < 0` ise körü körüne `logBankruptcy` basmak yerine:
    - Önce `state.hasActiveBailoutOffer = true` yapılır.
    - Dashboard açıldığında veya gün geçişinde `EmergencyBailoutDialog` açılır:
      - **A Seçeneği: Esnaf Can Suyu Desteği**: Ödüllü reklam izlenir (`AdService.showRewardedAdWithFallback`), oyuncunun bakiyesine +₺50.000 hibe yatırılır, bakiye pozitife çekilir.
      - **B Seçeneği: Spot Pazara Acil Satış**: Garajdaki en ucuz araç anında piyasa değerinin %75'i nakit ödenerek galericiler sitesine satılır.
      - **C Seçeneği: İflası Kabul Et**: Oyuncu yardım istemezse o zaman konkordato / icra süreci çalışır ve `logBankruptcy` loglanır.

### 3.4. Modül 4: Durumsal Dinamik Dilemma Kartları & Pop-up Entegrasyonu (P1)
- **365 Günlük Statik Tablonun Kaldırılması**:
  - `daily_life_cards_data.dart` yerine 4 durumsal havuz içeren `ContextualDilemmaPool` kurulur:
    1. **Acemi Galeri Havuzu (Gün 1-5, Seviye 1-2)**:
       - *Çay Ocağı Çırağı*: Komşu esnaf sıcak çay getirdi (küçük moral, +10 XP, +2 itibar).
       - *Eski Galericinin Sırrı*: Mahalledeki emekli oto galericisi piyasa tüyosu verdi (+1 Piyasa Hissi, +20 XP).
    2. **Nakit Krizi / Borç Havuzu (Bakiye < ₺25.000)**:
       - *Hurda Parça Alıcısı*: Bagajdaki eski akü ve jantları alıp peşin ₺15.000 vermeyi teklif eder.
       - *Senet Kırdırma Teklifi*: Nakit akışı için riskli veya güvenli finans seçimi.
    3. **Atıl Araç / İlanda Bekleyen Araç Havuzu (Araç günlerdir ilanda)**:
       - *Gezici Alıcı Fırsatı*: Araca uzun süredir teklif gelmemişken galerinin önüne bir müşteri gelir.
    4. **Büyüyen Galeri & Genel Pazar Havuzu (Seviye 3+, ₺100k+ bakiye)**:
       - *Maliye Yoklaması*, *Sosyal Medya Fenomeni Ziyareti*, *Modifiye Çılgını Genç*.
- **Ana Ekranda Pop-up Olarak Açılma**:
  - Gün atlandığında veya tetikleyici şart sağlandığında, kart Dashboard'da arka planda gizli bir banner olarak kalmaz; `NeoBrutalDramaticDialog.show(context, card)` ile şık, taktil ve generatif shader dokulu bir modal olarak doğrudan açılır.
- **Analitik Bağlantısı**:
  - `resolveDramaticCardChoice` içine `AnalyticsService.instance.logRandomEventChoice(eventId: card.id, choiceId: choice.id)` çağrısı eklenerek GA4 senkronizasyonu sağlanır.

### 3.5. Modül 5: Erken Aşama Reklam Noktaları (P2)
- **Sarı Site Vitrin Dopingi**:
  - İlan verme ekranında ve hızlı ilan modalında yer alır.
  - "Sponsor Desteğiyle Vitrin Dopingi Al" butonuna basıldığında ödüllü reklam izletilir ve aracın gelen teklif sıklığı 2 katına çıkarılır (`car.isDoped = true`).
- **Pazar Listesini Tazele**:
  - Pazar ekranının üst kısmına "Pazarı Yenile • Sponsor Desteği" butonu eklenir; gün atlamadan pazar araç havuzu taze fırsatlarla doldurulur.

---

## 4. Kurallara Uyum & Değişmezler
- **Sıfır Unicode Emojisi**: Tüm metinlerde ve bildirimlerde `VectorIconWidget` veya Flutter native ikonları kullanılacak.
- **Sıfır Parantez**: `(...)` yerine ` • ` veya ` - ` kullanılacak.
- **Eşzamanlı 7-Dil Senkronizasyonu**: Eklenen tüm yeni metinler ve diyaloglar 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) eksiksiz tanımlanacak.
- **Neo-Brutalist Görsel Dil**: 2.5px solid border, 0-blur offset gölge, basma kompresyonu, `/generative-art-shaders` dokuları (`crtScanlines`, `bayerDither`).
- **FILE_CHANGELOG.md**: Yapılan tüm dosya bazlı değişiklikler sistematik olarak işlenecek.

---

## 5. Doğrulama & Test Planı
1. **Otomatik Birim Testleri**:
   - `test/core_loop_funnel_and_dilemma_test.dart` yazılarak:
     - Hızlı ilan verme ve ilk alıcı teklifi oluşturulması test edilecek.
     - Seviye 1 XP'sinin 250 XP olduğu ve 270 XP ile Seviye 2'ye geçildiği doğrulanacak.
     - Negatif bakiyede acil can suyu desteğinin çalıştığı ve gereksiz iflas logu atılmadığı kanıtlanacak.
     - Dinamik durumsal kartların oyuncunun durumuna göre doğru kartı seçtiği ve analitik fonksiyonunu çağırdığı test edilecek.
2. **Statik Analiz**:
   - `flutter analyze` ile 0 hata, 0 uyarı teyit edilecek.
