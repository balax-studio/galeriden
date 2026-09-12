# Spec: Halil Usta Akıllı Esnaf Rehberi Yenileme ve Geliştirme (Smart Mentor Remediation)

## Objective
Oyuncunun ilerlemesini takip eden ve oyun döngüsünde tıkanmaları önleyen Halil Usta rehber mekanizmasının (`SmartMentorEngine`, `SmartMentorDialog` ve Kontrol Paneli entegrasyonu) daha az müdahaleci, daha derin bağlamsal ve oyun zevkini artırıcı hale getirilmesi. 

Hedefler:
1. **Müdahaleci Modal İzolasyonu & Ortam Kartı (Ambient Dashboard Presence)**: Rutin tavsiyelerin (kirli araç, atıl nakit, fiyat şişkinliği, liderlik nudgesi) oyuncunun ekranını kilitleyen `showDialog` modalları yerine kontrol panelinde şık ve interaktif bir neo-brutalist "Halil Usta Masası" (`DashboardMentorCard`) olarak sunulması; modalların yalnızca iflas krizleri (`stuckBrokeNoCar`), şube kutlamaları (`branchUpgradedCelebration`) ve yeni açılan kritik tesisler (`featureUnlocked`) için kullanılması.
2. **Soğuma Süresi & Sıklık Hijyeni (Cooldown Hygiene)**: Modal tavsiyeler için en az 3 oyun günü soğuma süresi konulması; her oyun günü (120 saniyede bir) oyuncunun ekranına modal fırlatılmasının engellenmesi.
3. **Öncelik Tıkanıklığının Giderilmesi (Priority Inversion Resolution)**: Yeni açılan kritik özelliklerin (`featureUnlocked`) ilansız araç kontrolünün üzerine taşınarak oyuncunun yeni açtığı tesisleri (Atölye, Yıkama, Personel) kaçırmamasının sağlanması.
4. **3 Yeni Taktik Tavsiye Türü**:
   - `bargainMarketRadar`: Pazaryerinde rayicinin %20+ altına kelepir araç düştüğünde bildirim.
   - `unofferedListingStale`: Vitrindeki bir araca 2+ gün teklif gelmediğinde fiyat kırma veya sponsor desteğiyle alıcı çağırma tavsiyesi.
   - `debtInstallmentWarning`: Aktif banka kredisi varken nakit yönetimi hatırlatması.
5. **Dinamik Parametre Zenginliği**: Pahalı araç uyarısında araç adı (`carName`) ve fiyatının metne parametre olarak aktarılması.
6. **7 Dilde Eşzamanlı Yerelleştirme**: Sıfır emoji ve sıfır parantez kurallarına uygun olarak tüm yeni anahtarların `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar` dillerine eklenmesi.

---

## Tech Stack
- **Framework**: Flutter 3.x (Dart 3.x)
- **State Management**: Riverpod 2.6 (`StateNotifier`, `ConsumerWidget`, `ref.watch`, `ref.listen`)
- **Navigation**: GoRouter 14.8 (`context.push`, `ref.read(dashboardTabProvider.notifier).state`)
- **Visual Grammar**: Neo-brutalism (2.8px border, 0-blur offset shadow, canlı dolgular, 8-bit prosedürel piksel avatarı)
- **Testing**: `flutter_test` (Birim, widget ve entegrasyon testleri)

---

## Commands
- Test: `flutter test test/smart_mentor_engine_test.dart`
- Localization Guard: `flutter test test/localization_integrity_guard_test.dart test/translation_key_coverage_test.dart`
- Analyze: `flutter analyze`

---

## Project Structure
- `lib/domain/usecases/smart_mentor_engine.dart` (Tavsiye motoru, öncelik zinciri, yeni tavsiye türleri)
- `lib/presentation/widgets/smart_mentor_dialog.dart` (Kritik kriz modalları)
- `lib/presentation/screens/dashboard/widgets/dashboard_mentor_card.dart` [YENİ] (Dashboard ana ekranındaki kalıcı/ortam usta kartı)
- `lib/presentation/screens/dashboard/dashboard_screen.dart` (Modal tetikleme sıklığı, soğuma süresi yönetimi)
- `lib/core/localization/translations/*.dart` (7 dil dosyası)
- `test/smart_mentor_engine_test.dart` (Genişletilmiş test paketi)

---

## Code Style & Conventions
- Sıfır Unicode Emoji: Tüm simgeler `Icon(Icons.*)` veya `VectorIconWidget` olmalıdır.
- Sıfır Parantez: Metinlerde ` • ` veya ` - ` kullanılır, `(...)` kesinlikle kullanılmaz.
- Neo-Brutalist Görsel Dil: 2.0px-3.0px kalın siyah kenarlıklar, `blurRadius: 0` sert gölgeler.

---

## Boundaries
- **Always**: 
  - Modal gösterimlerinde en az 3 oyun günü cooldown enforcing yap.
  - Yeni çeviri anahtarlarını 7 dile eşzamanlı ekle.
  - Öğretici bitmeden (`tutorialCompleted == false`) mentor tavsiyesi üretme.
- **Ask First**:
  - Halil Usta dışındaki NPC sistemlerine dokunulması.
  - Veri tabanı / Save schema bozulması.
- **Never**:
  - `git push` çalıştırma (kullanıcı açıkça istemeden).
  - Kullanıcı ekranını her 120 saniyede bir donduran modal pop-up zinciri oluşturma.

---

## Success Criteria
1. `stuckBrokeNoCar`, `branchUpgradedCelebration` ve `featureUnlocked` dışındaki tavsiyeler oyuncuyu zorunlu modala maruz bırakmaz; ana ekranda dokunulabilir `DashboardMentorCard` üzerinde gösterilir.
2. Modal tavsiyeler arasında en az 3 oyun günlük soğuma süresi zorunlu kılınır.
3. Yeni açılan tesisler (`featureUnlocked`), ilansız araç tavsiyesinin önünde değerlendirilir.
4. 3 yeni tavsiye türü (`bargainMarketRadar`, `unofferedListingStale`, `debtInstallmentWarning`) kurallara uygun olarak üretilir ve test edilir.
5. Tüm 7 dil dosyası eksiksiz senkronize edilir, `flutter test test/smart_mentor_engine_test.dart` ve `flutter analyze` 0 hata ile geçer.
