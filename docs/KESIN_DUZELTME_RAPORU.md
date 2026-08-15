# Galerisinden — Kesin Düzeltme Raporu (Güncel Kod Taraması)

**Kapsam:** `lib/` kaynak kodunun baştan sona güncel taraması. Kod değiştirilmedi, yalnızca okundu.
**Odak:** Oynanışı bozan, mekaniği çalışmaz kılan veya oyuncuyu sıkıp bırakmaya (churn) doğrudan sebep olan sorunlar.
**Not:** Bu oturumda daha önce yazdığım raporların (Oyun Tasarımı, Retention, Şehir Haritası, Dramatik Kartlar) neredeyse tamamı **kod tabanına işlenmiş** durumda — `dramatic_card_engine.dart`, `mission_factory.dart`, `visitor_queue_engine.dart`, `rival_leaderboard_engine.dart`, `collection_album_engine.dart`, `contract_model.dart` gibi yeni dosyalar bulundu ve git log bunu doğruluyor. Bu iyi haber: eski P0 bulgularımın (kaporta değer hatası, görev ödülü alınamaması, seviye-ceza sarmalı, banka arbitrajı) **hepsi düzeltilmiş.** Kötü haber: yeni eklenen sistemlerin kendi içinde, henüz kimsenin fark etmediği **taze buglar** var. Bu rapor onları listeliyor.

---

## Doğrulanmış Düzeltmeler (bilgi amaçlı, aksiyon gerekmiyor)

Hızlıca teyit ettim, tekrar raporlamıyorum:
- `car_model.dart:105` — kaporta hasarının değere etkisi artık çalışıyor (clamp hatası giderilmiş).
- `mission_model.dart` — `isClaimed` alanı eklenmiş, ödül talebi artık çalışıyor.
- `game_time_mixin.dart:56-63` — günlük sabit gider artık seviyeye değil, satın alınan mülk kademesine (`property_tier_2/3/4`) bağlı.
- `game_time_mixin.dart:227-234` — iflas kurtarma koşulu artık likidite bazlı (satılabilir araç değeri + banka mevduatı).
- `game_time_mixin.dart:320-324` — banka faizi %0,67 → %0,12 güne indirilmiş (arbitraj kapatılmış).
- `psychology_engine.dart:50-73` — giriş serisi artık takvim günü karşılaştırmasıyla hesaplanıyor (eski `.inDays` hatası giderilmiş), ayrıca "seri dondurma" (`hasStreakFreeze`) mekaniği eklenmiş.
- `dealership_model.dart` — `bankCreditLimit` varsayılanı ₺15.000.000 → ₺250.000'e düşürülmüş.

---

## P0 — Kesinlikle Düzeltilmesi Gereken Sorunlar

### 1. "Yokluğunda Neler Oldu?" Ekranı Asla Açılmıyor — Anahtar Uyuşmazlığı

**Dosyalar:** [game_core_provider.dart:94-100](lib/presentation/providers/game/game_core_provider.dart:94), [offline_progression.dart:123-132](lib/domain/usecases/offline_progression.dart:123)

Bu, tam da retention raporunda önerdiğim "geri dönüş özeti" özelliği — ve inşa edilmiş, UI'a bağlanmış, ama **hiçbir zaman tetiklenmiyor.**

`OfflineProgression.processOfflineTime()` şu map'i döndürüyor:
```dart
return {
  'elapsedMinutes': elapsedMinutes,
  'hoursAway': hoursAway,        // ← gerçek anahtar
  'passiveIncome': totalPassiveEarned,
  ...
  // 'partsArrivedCount' ANAHTARI HİÇ YOK
};
```

`game_core_provider.dart` ise bu map'i şu anahtarlarla okuyor:
```dart
final offlineHours = offlineResult['offlineHours'] as int? ?? 0;   // ← böyle bir anahtar yok, hep null → 0
pendingOfflineRecap = PsychologyEngine.getOfflineRecapSummary(
  offlineHours: offlineHours,
  earnedIncome: offlineResult['earnedIncome'] as double? ?? 0.0,   // ← böyle bir anahtar da yok
  partsArrivedCount: offlineResult['partsArrivedCount'] as int? ?? 0, // ← hiç üretilmiyor
  ...
if (offlineHours > 0) { ... }   // ← her zaman false, çünkü offlineHours her zaman 0
```

`offlineHours` her zaman `0` döndüğü için `if (offlineHours > 0)` bloğu **hiçbir zaman çalışmıyor.** Sonuç: `pendingOfflineRecap` hiçbir zaman set edilmiyor, Dashboard'daki `consumePendingOfflineRecap()` çağrısı hep `null` alıyor, modal hiç açılmıyor — oyuncu 8 saat sonra da dönse, 30 dakika sonra da dönse **hiçbir geri dönüş özeti görmüyor.**

**Etki:** Bu tesadüfi bir eksiklik değil, tam işlevsel ama tamamen ölü bir özellik. Offline geçen sürede kazanılan pasif gelir, gelen teklifler, korunan giriş serisi — hepsi hesaplanıyor ama oyuncuya hiç gösterilmiyor. Retention için inşa edilen en önemli "hoş geldin" ekranı sessizce çalışmıyor.

---

### 2. Hikâye & Dramatik Kartlar Ekranda İKİ KEZ Açılıyor

**Dosyalar:** [dashboard_screen.dart:64-80](lib/presentation/screens/dashboard/dashboard_screen.dart:64), [showroom_screen.dart:59-70](lib/presentation/screens/showroom/showroom_screen.dart:59), [dashboard_screen.dart:117-121](lib/presentation/screens/dashboard/dashboard_screen.dart:117)

`DashboardScreen`, alt sekmelerini `IndexedStack` ile yönetiyor ve `ShowroomScreen`'i (Galeri sekmesi) doğrudan çocuk widget olarak, **her zaman mount edilmiş halde** tutuyor (`IndexedStack` widget'ları dispose etmez, sadece gizler). Sorun şu: **hem `DashboardScreen` hem de `ShowroomScreen`, birebir aynı `ref.listen<DealershipModel>(gameProvider, ...)` bloğunu kendi içinde ayrı ayrı çalıştırıyor** — `pendingStoryCard` veya `pendingDramaticCard` değiştiğinde ikisi de aynı anda tetikleniyor.

Sonuç: bir hikâye/dramatik kart geldiğinde `NeoBrutalDramaticDialog.show(...)` (veya `NeoBrutalStoryAdDialog.show(...)`) **iki kez** çağrılıyor, biri Dashboard'un context'inden biri Showroom'un context'inden — iki ayrı dialog route push ediliyor. `barrierDismissible: false` olduğu için oyuncu üstteki dialogda bir seçim yaptığında (`resolveDramaticCardChoice` çağrılıp kart state'ten temizlendiğinde), **altta duran ikinci dialog hâlâ aynı (artık geçersiz) kartı gösteriyor olacak** — oyuncu ikinci kez "seçim" yapabilir, bu da `resolveDramaticCardChoice`'ı zaten temizlenmiş bir kart üzerinden tekrar çağırır (çift ödül/çift ceza riski) veya en iyi ihtimalle oyuncu art arda iki tıklama yapmak zorunda kalır.

**Etki:** Bu, oyuncunun karşısına "neden aynı pencere iki kez açılıyor" diye çıkacak, kafa karıştırıcı ve güven kırıcı bir bug. Özellikle **Dramatik Kartlar** gibi ağırlıklı, tek seferlik olması gereken anlarda iki kez tetiklenmesi anlatının etkisini tamamen kırıyor — tam olarak "oyuncuyu sıkıp bırakma" tanımına giren bir hata.

---

### 3. "Aile Yadigârı" Kilidi Sadece Görsel — Hiçbir Şeyi Kilitlemiyor

**Dosyalar:** [dramatic_card_engine.dart:100-159](lib/domain/usecases/dramatic_card_engine.dart:100), [dramatic_card_model.dart:842-857](lib/data/models/dramatic_card_model.dart:842), [neo_brutal_dramatic_dialog.dart:479-485](lib/presentation/widgets/neo_brutal_dramatic_dialog.dart:479)

D1 kartı ("Dede'nin Eski Çırağı") oyuncuya miras Murat 124'ü **kalıcı olarak satılamaz koleksiyon statüsüne** alma seçeneği sunuyor: *"Araç satılamaz koleksiyon statüsü kazanır"* diyor, seçim sonucunda `makeFamilyHeirloom: true` outcome'u dönüyor, ve sonuç ekranında oyuncuya büyük, altın renkli bir rozet gösteriliyor: **"AİLE YADİGARI TESCİLLENDİ."**

Ama `DramaticCardEngine.resolveChoice()` fonksiyonunu baştan sona okudum — `selectedOutcome.makeFamilyHeirloom` alanı **hiçbir yerde kullanılmıyor.** `loseTargetCar`, `recoverCarValueMultiplier`, `spawnBargainCar` alanlarının hepsi işleniyor, ama `makeFamilyHeirloom` için tek bir satır bile yok. `CarModel`'de bu amaç için zaten bir alan var (`isLockedInShowcase`), ama bu seçimde hiçbir araca `isLockedInShowcase: true` set edilmiyor.

**Etki:** Oyuncu "AİLE YADİGARI TESCİLLENDİ" rozetini görüp aracını korumaya aldığına inanıyor — ama araç, önceki gibi tamamen satılabilir, tamamen "çalınabilir" durumda kalıyor. Bu, StoryCardModel'de daha önce tespit ettiğim "vaat-ödül uyumsuzluğu" probleminin **aynısı, ama bu sefer UI'da açıkça yazılı bir yalan olarak.** Bir oyuncu bu kartı oynayıp sonra Murat 124'ünü (yanlışlıkla ya da mecburen) satarsa ya da B1 kartıyla kaybederse, "bana kilitlendi demişti" diye haklı olarak güvenini kaybeder — bu tür bir kırılma bir daha telafi edilmesi zor bir güven erozyonudur.

---

### 4. Miras Araç, Hırsızlık Kartına Karşı Hiç Korumasız

**Dosyalar:** [dramatic_card_model.dart:403-465](lib/data/models/dramatic_card_model.dart:403), [dramatic_card_engine.dart:107-113](lib/domain/usecases/dramatic_card_engine.dart:107)

B1 kartı ("Gece Yarısı Telefonu", `severity: extreme`, yalnızca `minPlayerLevel: 2` ve `requiresCarInGarage: true` şartı var) tetiklendiğinde motor şunu yapıyor:
```dart
updatedCars.sort((a, b) => b.estimatedRealValue.compareTo(a.estimatedRealValue));
updatedCars.removeAt(0); // en değerli aracı kaybet
```
Bu, **hiçbir istisna yapmadan** garajdaki en değerli aracı hedef alıyor. Eğer oyuncu henüz D1 kartını görmediyse (kart havuzundan ağırlıklı-rastgele seçiliyor, sıra garantisi yok) ve miras aracı (Tofaşk Hacı Murat 124, `isRare: true` olduğu için genelde garajın en yüksek değerli aracı) hâlâ elindeyse, **oyunun kendi anlatısının merkezine koyduğu miras araç, oyuncunun hiçbir seçim hakkı olmadan, %55 ihtimalle kalıcı olarak silinebiliyor.**

Bu, sistemin kendi iç tutarlılığıyla çelişiyor: D1 kartının tüm amacı oyuncuya "bu arabayı koru ya da satmaya karar ver" demekken, B1 kartı aynı arabayı oyuncunun herhangi bir tercihi olmadan elinden alabiliyor. Üstelik B1, Lv2 gibi düşük bir seviyede ve dramatik kartların ilk tetiklenme günü olan gün 20 civarında (oyunun ilk ~40 dakikasında) zaten tetiklenebilir durumda — oyuncu galerisiyle henüz gerçek bir bağ kurmadan en değerli/duygusal varlığını kaybedebilir.

**Etki:** Retention raporunda B1 için özellikle uyarmıştım: "en ağır kartlar nadir ve yalnızca ilerlemiş oyunculara (Lv3+) sunulmalı." Şu anki `minPlayerLevel: 2` eşiği bu uyarıyı karşılamıyor ve daha da önemlisi, miras aracı özel olarak hedef dışı bırakan bir istisna hiç yok.

---

### 5. "Zam Yap" Seçimi Hiçbir Şey Yapmıyor

**Dosyalar:** [dramatic_card_model.dart:479-495](lib/data/models/dramatic_card_model.dart:479), [dramatic_card_engine.dart:100-159](lib/domain/usecases/dramatic_card_engine.dart:100), [staff_model.dart](lib/data/models/staff_model.dart)

B2 kartında ("Güvenilir Çalışanın Teklifi") "Zammı Kabul Et" seçeneği `staffSalaryMultiplier: 1.40` ve metinde *"+%15 Servis Verimi"* vaat ediyor. Ama:

1. `resolveChoice()` içinde `staffSalaryMultiplier` alanı **hiç okunmuyor/uygulanmıyor** (`makeFamilyHeirloom` ile aynı desen).
2. Zaten uygulansa bile uygulanacak bir yer yok — `StaffModel`'de maaş, kişiye özel bir alan değil, `StaffRole.dailySalary` üzerinden **statik, role bağlı sabit bir getter.** Bireysel personelin maaşını artıracak hiçbir alan model içinde mevcut değil.

**Etki:** Oyuncu "zam yaptım, ustam sadık kaldı, hizmet kalitesi arttı" mesajını okuyor, reputasyon +2 ve XP +70 alıyor — ama vaat edilen mekanik sonuç (maaş artışı, %15 servis verimi) hiçbir şekilde gerçekleşmiyor. Küçük ölçekli ama aynı güven-kırma probleminin bir örneği daha.

---

### 6. Günlük Görevler Tamamlanmadan Siliniyor — Her ~6 Dakikada Bir

**Dosyalar:** [game_time_mixin.dart:327-331](lib/presentation/providers/game/game_time_mixin.dart:327), [mission_factory.dart:9-78](lib/domain/usecases/mission_factory.dart:9)

```dart
// 15. Daily Missions Rotation (if all claimed or every 3 in-game days)
List<MissionModel> updatedMissions = List.from(state.activeMissions);
if (updatedMissions.isEmpty || updatedMissions.every((m) => m.isClaimed) || nextDay % 3 == 0) {
  updatedMissions = MissionFactory.generateDailyMissions(state.level);
}
```

Bu kod `advanceGameDay()` içinde çalışıyor ve **1 oyun günü = 120 gerçek saniye.** `nextDay % 3 == 0` koşulu, oyuncunun mevcut görevlerdeki **ilerlemesi ne olursa olsun**, her 3 oyun gününde bir (yani **her 6 gerçek dakikada bir**) tüm görev listesini sıfırdan, `currentProgress: 0` ile yeniden üretiyor.

Somut senaryo: "Galerinden 2 araç sat" görevinde oyuncu 1 aracı zaten satmış (`currentProgress: 1/2`), ama henüz ikinciyi satamadan 6 dakika geçti — görev sessizce silinip yerine tamamen farklı, sıfır ilerlemeli 3 yeni görev geliyor. Oyuncunun harcadığı emek görünürde hiçbir sebep olmadan buharlaşıyor.

**Etki:** Bu, retention raporunda "günlük görev rotasyonu" için önerdiğim mekaniğin doğrudan tersine dönmüş hali — görevler motive etmek yerine **kısa süreli ilerlemeyi cezalandırıyor.** Özellikle `earnProfit` (Lv1'de ₺25.000 hedef) veya `sellCars` (Lv4+'ta 2 araç) gibi, çekirdek döngünün doğal temposunda (bir satış döngüsü ortalama birkaç dakika sürüyor) 6 dakikadan uzun sürebilecek görevler bu rotasyonda **yapısal olarak tamamlanamaz** hale geliyor.

---

### 7. Dramatik Kart Motoru Bakiye Kontrolü Yapmıyor (Şu An UI Tarafından Maskeleniyor)

**Dosya:** [dramatic_card_engine.dart:100-102](lib/domain/usecases/dramatic_card_engine.dart:100)

```dart
double newBalance = state.balance - choice.upfrontCost + selectedOutcome.moneyDelta;
if (newBalance < 0) newBalance = 0;
```

`resolveChoice()` fonksiyonunun kendisi, seçilen seçimin `upfrontCost`'unun oyuncunun bakiyesinde olup olmadığını **hiç kontrol etmiyor** — negatif bakiyeyi sessizce sıfıra clamp'liyor. Bugün bu risksiz çünkü tek çağrı noktası olan `neo_brutal_dramatic_dialog.dart:81` UI katmanında `canAfford` kontrolü var ve karşılanamayan seçimler buton seviyesinde devre dışı bırakılıyor.

**Neden yine de raporluyorum:** Bu bir savunma katmanı eksikliği. `resolveDramaticCardChoice` motor fonksiyonu, kendi başına çağrıldığında (örn. ileride eklenecek bir test, bir başka UI yolu, ya da bir hata payı bırakan gelecekteki bir değişiklik) hâlâ bakiyesi yetersiz bir oyuncuya ₺150.000'lik bir seçimi "bedava" (bakiye 0'a düşer ama gerçek bedel ödenmez) sundurabilir. Motor katmanı, UI'ın nazikliğine güvenmeden kendi başına güvenli olmalı.

---

## Öncelik Sırası

| # | Sorun | Neden en önce |
|---|---|---|
| 1 | Offline recap hiç açılmıyor | Retention'ın en büyük yatırımı tamamen ölü, tek satırlık anahtar düzeltmesi |
| 2 | Kartlar çift açılıyor | Her oyun oturumunda görünür, kafa karıştırıcı, potansiyel çift-ödül/çift-ceza riski |
| 4 | Miras araç korumasız | Oyunun duygusal çekirdeğini (Dede mirası) baltalıyor, erken oyunda tetiklenebilir |
| 3 | Aile Yadigârı yalanı | Güven erozyonu, ama yalnızca D1 kartını oynayan ve sonra kaybı yaşayan oyuncuları etkiler |
| 6 | Görevler siliniyor | Sürekli, sessiz, günlük motivasyon kaynağını doğrudan zehirliyor |
| 5 | Zam etkisiz | Düşük görünürlük, ama aynı güven sorunu |
| 7 | Motor bakiye kontrolsüz | Şu an risksiz, yalnızca gelecekteki kırılganlık |

---

*Bu rapor `lib/` kaynak kodunun taze, uçtan uca taranmasına dayanır. Hiçbir dosya değiştirilmedi.*
