# Şartname: Galeriden Tycoon Elde Tutma (Retention) İyileştirme Yol Haritası (§SPEC-2026-09-12-RETENTION-RECOVERY-ROADMAP)

## 1. Amaç ve Kapsam

Bu şartname, App Store Connect analitiklerinde tespit edilen kritik sızıntıyı (D1: %15.7, D7: %1.5, D14: %0.4, D28: %0.3) çözmek üzere hazırlanan 5 aşamalı eylem planının teknik mimarisini, veri modellerini, UI/UX standartlarını ve doğrulama kriterlerini belirler.

Temel hedef:
- İlk oturum temposunu hızlandırarak D1 oranını %15.7 seviyesinden %35+ bandına çıkarmak.
- Çevrimdışı cezalandırmayı kaldırıp yerel bildirim ve 7 günlük karşılama döngüsü kurarak D7 oranını %1.5 seviyesinden %10+ bandına yükseltmek.

---

## 2. Modül Haritası ve Bağımlılık Yönü

| Modül ID | Sorumluluk | Bağımlılık |
| :--- | :--- | :--- |
| `session-cadence` | İlk 3 satışta anlık teklif ve Seviye 1-2 hızlı organik teklif zamanlayıcısı | `game_inventory_mixin`, `game_time_mixin` |
| `offline-balance` | Seviye 1-2 çevrimdışı kira/vergi muafiyeti ve erken teklif birikimi | `offline_progression` |
| `mentor-quests` | Halil Usta Seviye 1-2 görev zincirinin revizyonu ve yönlendirici hedef kartı | `mentor_quest_engine`, `dashboard_mentor_card` |
| `local-notifications` | Çevrimdışı geri çağırma bildirimleri (90 dk ve 24 saat) | `flutter_local_notifications`, `notification_scheduler` |
| `welcome-streak` | Açılışta 7 günlük karşılama modalı ve Day 7 büyük ödül vaadi | `daily_login_sheet`, `daily_login_reward_model` |

---

## 3. Aşama Detayları ve Teknik Tasarım

### Aşama 1: `session-cadence` • İlk Oturum Akışını ve Teklif Hızını Hızlandırma
- **Dosyalar:** `lib/presentation/providers/game/game_inventory_mixin.dart`, `lib/presentation/providers/game/game_time_mixin.dart`
- **Tasarım:**
  - `updateCarListingDetails`: `state.salesHistory.length < 3` şartı eklenerek, ilk 3 aracın satışında araç ilana verildiği anda anında kârlı bir alıcı teklifi oluşturulur.
  - `startPeriodicOrganicOfferTimer`: Seviye 1 ve 2 için süre 120 saniyeden 45 saniyeye indirilir, teklif düşme olasılığı %25'ten %60'a çıkarılır.
  - UI/UX: Teklif geldiğinde Neo-Brutalist sarı bildirim efekti ve dokunsal geri bildirim (`GameSoundHapticService.playCashSuccess()`) tetiklenir.

### Aşama 2: `offline-balance` • Çevrimdışı Ekonomiyi Oyuncu Lehine Dengeleme
- **Dosyalar:** `lib/domain/usecases/offline_progression.dart`
- **Tasarım:**
  - `processOfflineTime` içinde `dealership.level <= 2` ise `propertyDailyBurn = 0.0` ve `dailyTax = 0.0` uygulanır. Oyuncu çevrimdışıyken kasasındaki sermaye asla erimez.
  - İlk 2 saatlik çevrimdışı sürede (`elapsedMinutes >= 30`), vitrinde ilanda araç varsa en az 2 alıcı teklifi doğrudan `incomingOffers` listesine eklenir (`minutesPerOffer = 25`).

### Aşama 3: `mentor-quests` • Halil Usta Erken Görev Zincirini Düzeltme
- **Dosyalar:** `lib/domain/usecases/mentor_quest_engine.dart`, `lib/presentation/screens/dashboard/widgets/dashboard_mentor_card.dart`
- **Tasarım:**
  - `questHeritageRestore` (Atölye gerektiren restorasyon) Seviye 3'e taşınır.
  - Yeni Seviye 1-2 sıralaması:
    1. `questFirstPurchase`: Pazar yerinden ilk aracını al (Hedef: 1 araç, Ödül: 15.000 TL, 100 XP).
    2. `questFirstProfitSale`: Pazardan aldığın aracı kârla sat (Hedef: 1 satış, Ödül: 25.000 TL, 150 XP).
    3. `questReachLevelTwo`: Galeri itibarını artır ve Seviye 2'ye ulaş (Hedef: Seviye 2, Ödül: 35.000 TL, 200 XP).
  - Dashboard kartında oyuncunun şu an ne yapması gerektiği canlı yönlendirme butonuyla sunulur.

### Aşama 4: `local-notifications` • Yerel Bildirim Entegrasyonu
- **Dosyalar:** `pubspec.yaml`, `lib/core/services/local_notification_service.dart`
- **Tasarım:**
  - Tamamen yerel, sunucu veya internet gerektirmeyen `flutter_local_notifications` motoru entegre edilir.
  - İki kritik tetikleyici:
    - 90 Dakika Tetikleyicisi: Vitrinde bekleyen araç varsa "Galerine hevesli bir alıcı geldi • Teklif masada!"
    - 24 Saat Tetikleyicisi: "Halil Usta 2. Gün esnaf desteğini hazırladı • Dükkan seni bekliyor!"
  - Bildirim izni kibar bir dille ilk satış tamamlandığında istenir (Onboarding sırasında zorlanmaz).

### Aşama 5: `welcome-streak` • 7 Günlük Coşkulu Başlangıç Takvimi
- **Dosyalar:** `lib/presentation/screens/dashboard/dashboard_screen.dart`, `lib/presentation/widgets/dialogs/daily_login_sheet.dart`
- **Tasarım:**
  - Günlük giriş sayfası açılışta günün ödülü henüz alınmadıysa otomatik olarak gösterilir.
  - 7. gün büyük ödülü (nadir klasik araç ve "Usta Esnaf" unvanı) takvim başında parlatılarak oyuncuya uzun vadeli hedef sunulur.
  - 7 dilde eşzamanlı yerelleştirme tam senkronize edilir.

---

## 4. Değişmez Kurallar ve Kısıtlar (Invariants)

1. Sıfır Unicode Emoji: Tüm ikonlar `VectorIconWidget` veya Flutter native ikonları ile oluşturulur.
2. Sıfır Parantez: UI metinlerinde `(...)` kullanılmaz; ` • ` veya ` - ` kullanılır.
3. 7 Dil Senkronizasyonu: Yeni eklenen tüm görev metinleri ve bildirimler 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) tanımlanır.
4. Neo-Brutalist Tasarım Dili: 2.5px siyah çerçeve, sıfır yumuşatma, 3.5px sert gölge ve yüksek doygunluklu renkler korunur.
5. Değişiklik Takibi: Her adım `docs/FILE_CHANGELOG.md` kütüğüne işlenir.
