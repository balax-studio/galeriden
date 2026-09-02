# Spec: Çevrimdışı İlerleme Dengesi ve Karar Kartı Senkronizasyonu (SPEC-offline-progression-and-card-sync)

## Objective
Oyuncunun oyundan ayrıldığı çevrimdışı sürede (offline progression) takvim ve ekonomi simülasyonunu dengeli ve kontrollü bir tempoya çekmek (her 30 dakika = 1 oyun günü, maksimum tavan = 3 gün) ve oyuna dönüldüğünde açılan karar kartı (Dramatic Dilemma Card) rozetindeki gün numarasını anlık güncel oyun günüyle (`currentDay`) tam senkronize etmek.

## Tech Stack
- Flutter & Dart
- Flutter Riverpod (`GameCoreProvider`, `GameTimeMixin`)
- Domain usecases: `OfflineProgression`, `DramaticCardEngine`

## Commands
- Test: `flutter test`
- Analyze: `flutter analyze`

## Project Structure
- `lib/domain/usecases/offline_progression.dart` → Çevrimdışı simülasyon hesaplama algoritması (30 dk/gün, max 3 gün).
- `lib/presentation/providers/game/game_core_provider.dart` → Çevrimdışı sonuçların yüklenmesi ve `pendingDramaticCard` gün senkronizasyonu.
- `test/economy_and_xp_anti_inflation_test.dart` & `test/dramatic_cards_chaos_resilience_test.dart` → Birim testler.

## Specifications & Rules

### 1. Çevrimdışı Gün Simülasyonu
- **Oran:** `elapsedMinutes < 30 ? 0 : (elapsedMinutes / 30).floor().clamp(1, 3)`
- 0 - 29 dakika çevrimdışı: 0 gün ilerler (`currentDay` değişmez).
- 30 - 59 dakika çevrimdışı: 1 gün ilerler.
- 60 - 89 dakika çevrimdışı: 2 gün ilerler.
- 90+ dakika çevrimdışı: Maksimum 3 gün ile sınırlandırılır.

### 2. Karar Kartı (Dramatic Dilemma) Senkronizasyonu
- Çevrimdışı simülasyon tamamlandığında, `updated.pendingDramaticCard` mevcutsa `dayNumber` değeri `updated.currentDay` ile eşitlenir.
- Eğer kart yoksa `DramaticCardEngine.generateDailyDilemma(updated.currentDay, updated)` ile güncel gün için üretilir.
- Böylece HUD'daki `GÜN: X` ile karttaki `GÜNLÜK İKİLEM • X. GÜN` her zaman birebir aynı olur.

## Boundaries
- Always: `flutter analyze` ve `flutter test` çalıştırarak tüm testlerin geçtiğini doğrula.
- Never: Günlük giriş serisi (Daily Login Streak) gerçek zamanlı 24 saat kuralını bozma.

## Success Criteria
1. 20 dakikalık çevrimdışı kalmada gün ilerlemez (0 gün).
2. 8 saatlik çevrimdışı kalmada gün en fazla 3 gün ilerler.
3. Karar kartı rozeti her zaman `state.currentDay` ile eşleşir.
4. Tüm testler (856+ test) sıfır hata ile geçer.
