# Galerisinden — "Harita" Özelliği Öneri Raporu

**Konu:** Mevcut, liste/kart tabanlı (etkileşimsiz) arayüze uygun bir "harita" benzeri görsel eklemek.
**Kapsam:** Yalnızca öneri. Kod değişikliği yapılmadı, tek bir satır yazılmadı.
**Kısıt (talep gereği):** Yeni harici paket yok — tüm öneriler saf Flutter (`CustomPainter`, `GestureDetector`, `InteractiveViewer`) ile kurulabilir.

---

## 0. Önce Kritik Bir Bulgu: Aradığınız Şey Zaten Yazılmış

Öneriye geçmeden önce şunu bilmeniz gerekiyor: **Projede tam işlevsel, 2.000 satırlık bir izometrik şehir haritası zaten var** — [`lib/presentation/widgets/isometric_world_map.dart`](lib/presentation/widgets/isometric_world_map.dart). Ve bu dosya **hiçbir ekrandan çağrılmıyor.** Router'da rotası yok, Dashboard'un hiçbir sekmesinde referansı yok. `grep` ile doğruladım — tek referans, kendisini saran platform-switch dosyası (`threejs_city_view_stub.dart`) ve o dosyanın kendisi de hiçbir yerden kullanılmıyor.

Bu haritanın içinde hazır duran şeyler:

- **15 tıklanabilir bina** — her biri gerçek bir route'a bağlı (`/workshop`, `/marketplace`, `/auction`, `/scrapyard`, `/black-market`, `/finance`, `/stock-market`, `/bank-investments`, `/rent-a-car`, `/branches`, `/staff`, `/side-businesses` vb.), her birinin `requiredLevel` ve `unlockCost` alanı var ve `game.isBuildingUnlocked(b.route)` ile **canlı oyun durumuna bağlı.**
- Kilitli binalar için gri/kilit görünümü + "Kilidi Aç" butonu, `ref.read(gameProvider.notifier).unlockBuilding(...)` çağrısıyla **zaten çalışır durumda.**
- Garaj slotlarına göre araç sayısı kadar ev/showroom sprite'ı çiziliyor, dokunulduğunda araç detay sheet'i açılıyor.
- `InteractiveViewer` ile pan/zoom, gün/gece döngüsü (`game.inGameTime.hour`), müşteri figürleri, rozetler (`_buildStatBadge` gibi fonksiyonlarla tamir bekleyen araç sayısı, kiradaki araç sayısı, personel sayısı vb. canlı istatistikler) hepsi mevcut.

**Bunun sizin için anlamı:** "Nasıl yaparım" sorusunun bir kısmı zaten cevaplanmış — sıfırdan bir harita motoru yazmanıza gerek yok. Asıl karar, bu hazır motoru **olduğu gibi mi kullanacağınız**, yoksa mevcut Neo-Brutalist (düz renk, siyah kontur, kalın çizgi) arayüz diliyle **çelişen görsel stilini** yeniden mi ele alacağınız.

---

## 1. Mevcut Arayüzün Karakteri (Neye "Uygun" Olması Gerekiyor)

Öneriyi doğru kalibre etmek için mevcut yapıyı netleştirmek gerekiyor. Uygulama şu an tamamen **düz, liste/kart tabanlı** bir dil kullanıyor:

- Alt navigasyon: `AppFloatingDock` — 4 sabit sekme (Ana Sayfa · Galeri · İhale · Ofis), `IndexedStack` ile geçiş (`dashboard_screen.dart:94-138`).
- "Ofis" sekmesi (`dashboard_office_view.dart`) — tam olarak sizin "etkileşimsiz arayüz" dediğiniz şey: dikey `ListView`, her satır bir `NeoBrutalCard` (ikon + başlık + alt yazı + "Yönet/İncele/Geliştir" butonu). Mekân/uzam hissi yok, saf liste.
- Showroom, Pazar, Atölye ekranlarının hepsi aynı desende: kart listesi + filtre çubuğu.
- Renk dili: `AppColors` içinde `brutalYellow`, `brutalCyan`, `brutalPink`, siyah kontur (`0xFF0F172A`), keskin köşeler, kalın border — **düz/vektörel**, gölge-ışık simülasyonu yok.

Buna karşılık, orphan izometrik harita **tamamen farklı bir görsel dünyadan** geliyor: `neonCyan`, `arcadeGold`, `electricPurple`, `laserGreen`, `beneloilGrassGreen`, `beneloilAsphaltRoad` gibi ayrı bir renk seti kullanıyor (`app_colors.dart:45-58`, yorumda bile "Arcade Tycoon Vibrant Tokens" ve "Beneloil Style Game UI Tokens" diye ayrılmış). Gökyüzü gradyanı, gün/gece geçişi, gölgeli 3D bina render'ı var — yani **Neo-Brutalist düzlükle doğrudan çelişiyor.**

Bu çelişki önemli çünkü üç farklı yol açıyor:

---

## 2. Üç Seçenek

### Seçenek A — Mikro Harita Şeridi *(en düşük maliyet, en uyumlu)*

Ofis veya Ana Sayfa sekmesinin en üstüne, mevcut kart akışının **içine giren** yatay bir şerit: şubelerin (branch) küçük, düz-vektör ikonlarla dizildiği, aralarında ince kesik çizgili "yol" olan statik bir şema. Etkileşim minimal — sadece dokunma, pan/zoom yok.

**Nasıl görünebilir:**
```
┌─────────────────────────────────────────────────┐
│  🏚️──────🏭──────🏢──────🗼                      │
│  Sokak   İkitelli  Maslak  Levent                │
│  Garajı  (Lv.2)    (Lv.3)  (Lv.4)                │
│  ●AKTİF  ○kilitli  ○kilitli ○kilitli             │
└─────────────────────────────────────────────────┘
```
Her düğüm bir `NeoBrutalCard` estetiğinde (siyah kontur, düz dolgu, keskin köşe) daire/rozet; aktif şube `brutalGreen`, kilitli olanlar gri + kilit ikonu. Dokununca `BranchScreen`'e (`/branches`) gidilir — **yeni bir ekran değil, mevcut ekrana giden görsel bir kısayol.**

**Veri kaynağı:** `BranchModel.getAllBranches()` zaten 4 şubeyi `locationName` ile tanımlıyor (`branch_model.dart:30-82`) — "Sokak & Kaldırım Otoparkı", "Sanayi Sitesi", "Maslak Cam Giydirme Showroom", "Levent Gökdelen Kulesi". İçerik hazır, tek yapılacak bunu yatay bir `ListView`/`Row` + `CustomPaint` ile bir "yol" çizgisi üstünde dizmek.

**Artı:** Sıfır stil çatışması, sıfır navigasyon değişikliği, yarım günlük iş.
**Eksi:** "Harita" hissi zayıf — daha çok bir ilerleme çubuğu gibi durur.

---

### Seçenek B — Düz-Vektör "Şehir Şeması" Ekranı *(orta maliyet, önerilen)*

Gerçek bir izometrik/perspektif şehir değil; **metro haritası mantığında düz bir şema.** Binalar arasında 45°/90° açılı kalın çizgilerle bağlanan, sabit boyutlu ikon-düğümlerden oluşan tek bir statik `CustomPainter` tuvali. Neo-Brutalist dile birebir uyar çünkü zaten düz renk + siyah kontur + keskin köşe kullanır — gölge, perspektif, gradyan yok.

**Nasıl görünebilir (kavramsal düzen):**

```
        🏛️ MERKEZ GALERİ (Miras Oto)
         │
    ┌────┼────┬────────┬─────────┐
    │    │    │        │         │
  🔧   🚿   🏪         ⚖️        🏦
Atölye Yıkama Pazar   İhale    Finans
(Lv1)  (Lv2)  (Lv1)   (Lv3)    (Lv3)
    │
    ├── 🗑️ Hurdalık (Lv4)
    ├── 🕶️ Karaborsa (Lv4)   ← kilitli, soluk renk + kilit ikonu
    └── 🚗 Kiralama (Lv4)
```

Merkezde oyuncunun galerisi büyük bir düğüm; ondan çıkan kalın "yollar" mevcut route'lara gidiyor. Kilit durumu, ikonun arka plan rengiyle kodlanıyor (aktif = dolgu renkli + siyah kontur; kilitli = gri + kesik çizgi kontur). Dokunma → ilgili route'a git; basılı tutma → küçük bir tooltip kartı (gereken seviye, açılış maliyeti).

Bu, teknik olarak `IsometricWorldMap`'teki `WorldBuilding` veri modelini (**route, name, requiredLevel, unlockCost**) doğrudan yeniden kullanabilir — sadece render katmanını izometrik sprite'lardan düz ikon+çizgiye indirger. Yani veri modeli ve kilit mantığı **hazır**, yeniden yazılacak olan yalnızca `CustomPainter`'ın çizim kısmı.

**Nereye bağlanır:** Dock'a 5. bir sekme eklemek yerine — 4 sekmeli düzeni bozmadan — Ofis sekmesindeki ilk karta *"🗺️ Şehir Haritasını Aç"* girişi eklenip tam ekran bir sayfa (`/city-map`) olarak açılabilir. Böylece mevcut navigasyon hiyerarşisi bozulmaz, harita **isteğe bağlı bir keşif katmanı** olarak durur.

**Artı:** Gerçek "harita" hissi verir, stil tutarlı kalır, mevcut route/kilit sistemini olduğu gibi görselleştirir — yeni oyun mantığı gerekmez, sadece **var olan ilerleme sisteminin (Level → route kilitleri) mekânsal bir görselleştirmesi.**
**Eksi:** Yeni bir `CustomPainter` + layout matematiği yazmak gerekiyor (orphan dosyadaki `IsoWorld.isoToScreen` gibi koordinat dönüşümü örnek alınabilir, ama düz şema için çok daha basit — sadece sabit x/y grid yeterli).

---

### Seçenek C — Orphan İzometrik Haritayı Diriltmek *(en yüksek görsel etki, stil uyuşmazlığı riski)*

`IsometricWorldMap`'i olduğu gibi bir rotaya bağlamak (`/city-map` veya 5. dock sekmesi). Teknik olarak **en ucuz seçenek** — motor zaten yazılmış, test edilmemiş olsa da derlenebilir durumda duruyor.

**Nasıl görünebilir:** Üstten açılı (izometrik), gökyüzü gradyanlı, gün/gece geçişli bir mini-şehir; galeri binası merkezde, etrafında dükkânlar; garaj slotlarına göre gerçek araç sayısı kadar sprite; dokunca route'a gidiyor; pan/zoom ile gezilebiliyor; canlı istatistik rozetleri (tamirde kaç araç, kiradaki araç sayısı vb.) köşede.

**Artı:** Neredeyse sıfır geliştirme maliyeti — motor hazır, sadece bağlanması ve muhtemelen küçük bug taraması gerekiyor (uzun süre kullanılmadığı için `game_provider` API'lerinde küçük kaymalar olabilir, örn. `ref.read(gameProvider.notifier).unlockBuilding` imzasının hâlâ eşleştiğini doğrulamak gerekir).
**Eksi:** Sizin "etkileşimsiz arayüzümüze uygun" tarifinize **doğrudan ters** — bu, uygulamanın geri kalanından görsel olarak kopuk, ayrı bir "arcade" katman. Kullanıcı bu ekrana girdiğinde bambaşka bir oyunda gibi hissedebilir. Ayrıca 2.000 satırlık, uzun süredir dokunulmamış kod her zaman gizli regresyon riski taşır.

---

## 3. Öneri

**Seçenek B.** Gerekçe:

1. Sizin tarif ettiğiniz "etkileşimsiz arayüze uygun" ifadesiyle en iyi örtüşen bu — düz, vektörel, Neo-Brutalist dille aynı gramerde.
2. Orphan dosyadaki **veri modelini** (`WorldBuilding`: route + requiredLevel + unlockCost) çöpe atmadan yeniden kullanır; sadece render katmanını basitleştirir. Yani "sıfırdan yazma" değil, "yeniden derleme."
3. Yeni oyun mantığı gerektirmez — mevcut `isBuildingUnlocked` / `unlockBuilding` sistemini olduğu gibi görselleştirir. Risk yüzeyi düşük.
4. İsteğe bağlı bir keşif katmanı olarak konumlandığı için mevcut 4 sekmelik navigasyonu bozmaz.

Seçenek A, eğer bütçe/zaman en kısıtlı senaryosuysa **B'nin ilk fazı** olarak da düşünülebilir: önce yatay şerit, memnun kalınırsa tam ekran şemaya genişletilir.

Seçenek C'yi tamamen elemiyorum ama önerim: **eğer ileride oyunun görsel kimliğini "arcade/izometrik" yönüne çevirmeyi düşünüyorsanız** o zaman C mantıklı bir temel olur — ama bugünkü Neo-Brutalist kimlikle yan yana durduğunda iki farklı oyun gibi hissettirir.

---

## 4. Seçenek B İçin Yüksek Seviye Uygulama Planı

Kod yazmadım; bu, ileride uygulamaya geçerken izlenebilecek mimari taslak.

1. **Veri:** `WorldBuilding` sınıfını (`isometric_world_map.dart:41-82`) ya olduğu gibi ya da sadeleştirilmiş haliyle (`route`, `shortName`, `emoji`, `color`, `requiredLevel`, `unlockCost`, artı düz şema için `gridRow`/`gridCol` gibi basit tam sayı koordinatlar) yeni bir dosyaya taşı: örn. `lib/presentation/widgets/city_map/city_map_nodes.dart`.
2. **Layout matematiği:** İzometrik dönüşüm (`IsoWorld.isoToScreen`) yerine sabit bir grid — `Offset(col * spacing, row * spacing)`. Çok daha basit, ekran boyutuna göre ölçeklenmesi kolay.
3. **Çizim:** Tek bir `CustomPainter` — önce düğümler arası bağlantı çizgileri (kalın, siyah, köşeli), sonra düğümler (daire/kare + emoji/ikon + siyah kontur). Kilitli düğümler için `Paint()..color = Colors.grey` + kesik çizgi kontur (`Path.dashPath` yerine basit `drawLine` segmentasyonuyla, ekstra paket gerekmez).
4. **Etkileşim:** `GestureDetector.onTapUp` + her düğümün `Rect` alanına basit nokta-içinde-mi testi (orphan dosyadaki `hitRect` mantığı doğrudan örnek alınabilir, `isometric_world_map.dart:73-81`).
5. **Oyun durumu bağlama:** `ref.watch(gameProvider)` ile `game.isBuildingUnlocked(route)` ve `game.level` okunur — mevcut API'ler değişmeden kullanılır.
6. **Giriş noktası:** `router.dart`'a `/city-map` rotası eklenir; `dashboard_office_view.dart`'taki kart listesine bir `_buildOfficeItem(... title: 'Şehir Haritası', actionLabel: 'Haritayı Aç', onTap: () => context.push('/city-map'))` satırı eklenir. Dock'ta değişiklik gerekmez.

**Paket notu:** Adımların hiçbiri yeni bir bağımlılık gerektirmiyor — `CustomPainter`, `GestureDetector`, `Path` hepsi Flutter çekirdeğinde.

---

## 5. Bonus Bağlantı (isteğe bağlı, zorlamıyorum)

Bu oturumda daha önce hazırladığım retention raporunda "Rakip Galeri Sistemi" ve "Sezon/Prestij Döngüsü" önerileri geçmişti. Eğer ileride o yöne gidilirse, Seçenek B'deki şema kolayca genişler: rakip galeri düğümleri (farklı renk, kilitli/pasif görünüm), şube genişleme düğümleri, hikâye kartı karakterlerinin "bulunduğu" noktalar aynı grid üzerine eklenebilir. Ama bu şu anki öneriye bağımlı değil — B, bugünkü haliyle de kendi başına tamamlanmış bir öneri.

---

*Bu rapor `lib/` kaynak kodunun statik incelemesine dayanır; herhangi bir dosya değiştirilmedi.*
