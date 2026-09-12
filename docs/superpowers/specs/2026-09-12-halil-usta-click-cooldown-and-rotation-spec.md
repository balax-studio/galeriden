# Spec: Halil Usta Masası Tıklama Sonrası Anında Rotasyon & Cooldown Mekanizması (§SPEC-2026-HALIL-USTA-CLICK-COOLDOWN-ROTATION)

## Objective
Oyuncunun pazar yerinde sürekli kelepir araç bulunması durumunda, Halil Usta Masası'nın (`DashboardMentorCard`) aynı kelepir tavsiyesinde (`bargainMarketRadar`) takılı kalmasını önlemek; oyuncu aksiyon butonuna tıkladığı anda o tavsiye türünü o gün için tamamlanmış/soğumaya alınmış kabul ederek kartın anında sıradaki operasyonel ihtiyaca (yıkanmamış kirli araç, atölye tamir fırsatı, vitrinsiz araç, şube büyütme) dinamik olarak geçmesini sağlamak.

### Temel Hedefler:
1. **Tıklama Sonrası Anında Soğuma (Click-Triggered Instant Cooldown)**:
   - Oyuncu masadaki aksiyon butonuna (`recordMentorAdvice`) bastığında, ilgili tavsiye türü (`SmartMentorAdviceType`) ve hedef nesne kimliği (örn. `carId`) `mentorMemory['adviceCooldowns']` ve `mentorMemory['lastClickedAdvice']` alanlarına işlenir.
   - Aktif soğumada olan bir tavsiye türünün fayda puanı o gün için baskılanır (`utilityScore *= 0.10`), böylece masadaki kart beklemeden anında sıradaki en yüksek öncelikli tavsiyeye döner.
2. **Görülen Kelepir Araç Hafızası (Seen Bargain Car Tracking)**:
   - `bargainMarketRadar` tetiklendiğinde hedef aracın kimliği (`bargain.car.id`) usta hafızasında saklanır. Oyuncu aksiyona geçtiğinde bu araç `seenBargainCarIds` listesine eklenir ve aynı araç için aynı gün içinde tekrar radar uyarısı üretilmez; yalnızca pazara yeni ve farklı bir kelepir düştüğünde radar tekrar devreye girebilir.
3. **Gerçekçi Esnaf Öncelik Hiyerarşisi (Fleet Maintenance Over Purchasing)**:
   - Garajda kirli/çamurlu araç varken `dirtyCarValueLoss` fayda puanı 0.45'ten **0.72**'ye çıkarılır.
   - Garajda hasarlı parçası olan araç varken `damagedCarRepairOpportunity` fayda puanı 0.50'den **0.75**'e çıkarılır.
   - `bargainMarketRadar` temel puanı 0.85'ten **0.70**'e dengelenir; böylece garajda acil bakımsızlık varken ustanın yeni araç alma hevesi dükkan içi bakımın önüne geçmez.
4. **Hafıza Sıfırlama & Günlük Yenilenme**:
   - Gün atlandığında (`currentDay > lastAdvisedDay`) günlük tıklama soğumaları sıfırlanır ve usta yeni günün şartlarını taze olarak değerlendirir.
5. **Reaktif Kart Güncellemesi**:
   - `DashboardMentorCard` üzerindeki buton tıklandığında Riverpod durumu güncellenir ve arayüz animasyonlu/akıcı şekilde bir sonraki tavsiyeye geçiş yapar.

---

## Tech Stack
- **Framework**: Flutter 3.x (Dart 3.x)
- **State Management**: Flutter Riverpod 2.6 (`ref.watch(gameProvider)`, `ref.read(gameProvider.notifier).recordMentorAdvice(advice)`)
- **Architecture**: Domain UseCase (`SmartMentorEngine`, `MentorQuestEngine`) + Presentation (`DashboardMentorCard`)
- **Testing**: `flutter_test`

---

## Commands
- Test: `flutter test test/smart_mentor_engine_test.dart`
- Localization Guard: `flutter test test/localization_integrity_guard_test.dart test/translation_key_coverage_test.dart`
- Analyze: `flutter analyze`

---

## Project Structure
- `lib/domain/usecases/smart_mentor_engine.dart`: Cooldown filtreleme, `recordAdviceGiven` genişletmesi, `seenBargainCarIds` takibi ve öncelik kalibrasyonu.
- `lib/presentation/screens/dashboard/widgets/dashboard_mentor_card.dart`: Tıklama anında `recordMentorAdvice` üzerinden reaktif güncelleme teyidi.
- `lib/presentation/providers/game/game_base_notifier.dart`: Mentor tavsiyesi kaydedildiğinde `saveState()` ile kalıcı hafıza senkronizasyonu.
- `test/smart_mentor_engine_test.dart`: Tıklama sonrası soğuma, kelepir araç rotasyonu ve yeni öncelik sıralaması testleri.

---

## Code Style & Conventions
- **Sıfır Unicode Emoji**: İkonlar için `Icons.*` kullanılır, UI metinlerinde emoji bulunmaz.
- **Sıfır Parantez**: UI metinlerinde ` • ` veya ` - ` kullanılır, `(...)` kullanılmaz.
- **Minimal & Performanslı Kod (Ponytail)**: Ekstra model veya soyutlama katmanı eklemek yerine mevcut `mentorMemory` haritası genişletilir.
- **Simultaneous 7-Language Localization**: Yeni metin gereksinimi olursa 7 dile senkronize edilir (bu özellik mevcut yerelleştirilmiş anahtarları kullanır).

---

## Testing Strategy
- **Birim Testleri (`test/smart_mentor_engine_test.dart`)**:
  - Tıklama öncesinde kelepir radarının başarıyla aday üretmesi.
  - `recordAdviceGiven` çağrıldıktan sonra `bargainMarketRadar`'ın o gün için soğumaya girmesi ve sıradaki tavsiyenin (örn. `dirtyCarValueLoss` veya `damagedCarRepairOpportunity`) kazanması.
  - Gün atlandığında soğumanın kalkarak yeni kelepir araçların tekrar radara girmesi.
  - Aynı kelepir araç için tekrar eden uyarı üretilmemesi (`seenBargainCarIds`).

---

## Boundaries
- **Always**:
  - Öğretici tamamlanmamışsa mentor tavsiyesi üretilmez.
  - Tavsiye motoru saf fonksiyon prensibini korur (`DealershipModel` alır, `SmartMentorAdvice?` döner).
  - Değişiklikler `docs/FILE_CHANGELOG.md` dosyasına işlenir.
- **Ask First**:
  - Save schema sürümünde geriye dönük uyumsuzluk yaratacak köklü yapı değişiklikleri.
- **Never**:
  - `git push` komutunu izinsiz çalıştırma.
  - Kod değişikliğini spec ve plan onayından önce uygulama.

---

## Success Criteria
1. Oyuncu kelepir araç tavsiyesinde "Pazara İn" butonuna bastığı anda `bargainMarketRadar` aynı gün için soğumaya girer.
2. Butona basıldığı anda masadaki kart sıradaki en yüksek öncelikli tavsiyeyi gösterir (örn. yıkanmamış araç varsa yıkama, hasarlı araç varsa atölye, şube yükseltme hazırsa şube).
3. `flutter test test/smart_mentor_engine_test.dart` suite'indeki tüm testler (yeni rotasyon testleri dahil) sıfır hatayla geçer.
4. `flutter analyze` analizinde sıfır hata ve sıfır uyarı raporlanır.
