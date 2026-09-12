# Galeriden Tycoon • VIP Dış Kaynak Modifiye Evleri (Contract Tuning Houses) ve Oyun Süreli Boru Hattı Spesifikasyonu

**Tarih:** 11.09.2026  
**Durum:** Taslak • Kullanıcı Onayı Bekliyor  
**Modül Kimliği:** contract-tuning-pipeline  

---

## 1. Amaç • Objective

Oyuncuların mevcut iç garaj atölyesinden farklı olarak; araçlarını dışarıdaki profesyonel, seviyeli ve hikayeli parodi tuning/modifiye evlerine emanet edebileceği, aktif oyun süresi (dakika/saniye) ve gün atlamasıyla çalışan, ödüllü reklamla süre kısaltılabilen ve işlem bitince kârla satışa sunulmak üzere envantere geri dönen **VIP Dış Kaynak Modifiye Evleri (Contract Tuning Houses)** boru hattını oyuna kazandırmak.

---

## 2. Derin Araştırma Bulguları: 5 Parodi Tuning Evi

Gerçek dünya tuning kültüründen (Alpina, Brabus, Singer, Liberty Walk, Mansory ve Maslak Oto Sanayi) esinlenilen 5 parodi atölye:

| Firma Adı | Açılış Seviyesi | Kabul Kriteri | İşçilik Maliyeti | Aktif Oyun Süresi / Gün | Değer Artışı (ROI) | Özel Kazanım & Rozet |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Sanayi Çırakları & Yaşar Usta** | Seviye 2+ | **Her aracı kabul eder** | ₺25.000 - ₺65.000 | **15 Dakika** (3 Gün) | +%20 Değer Artışı | Vanalı Egzoz • Çırak İşi Rozeti |
| **Tokyo Kaydırak & Maslak JDM** | Seviye 4+ | **Sadece Asya & Japon** (Tota, Nisso, Hondi, Mitsu) | ₺120.000 - ₺350.000 | **30 Dakika** (6 Gün) | +%35 Değer Artışı | Twin-Turbo & Anti-Lag • Drift Ustası Rozeti |
| **Bavyera Güç & Herr Klaus** | Seviye 6+ | **Sadece Alman Prestij** (Bavyera, Merso, Porş, Volk) | ₺650.000 - ₺1.800.000 | **60 Dakika** (10 Gün) | +%40 Değer Artışı | Dövme Piston & ECU • Autobahn Hazır Rozeti |
| **Nostalji Sanat & Usta Hilmi** | Seviye 7+ | **Sadece Klasik & Efsane** (Yıl <= 2002 veya Klasik segment) | ₺950.000 - ₺3.500.000 | **90 Dakika** (15 Gün) | 1.55x Koleksiyon Çarpanı | Birebir Ismarlama • 1/1 Restomod Başyapıtı |
| **Monaco Hypercraft & Karbon** | Seviye 9+ | **Sadece Egzotik & Hiper** (Ferro, Lambo, Bugaç, Köniğ, Pagan, Rolso) | ₺8.000.000 - ₺40.000.000 | **120 Dakika** (20 Gün) | +%45 Değer Artışı | Dövme Karbon Gövde • VIP HiperCraft Altın Rozeti |

---

## 3. Süre, Zamanlayıcı ve Reklam Hızlandırma Mekaniği

1. **Çift Motorlu Zaman İlerlemesi (Dual Progression)**:
   - **Aktif Oyun Süresi (Countdown Timer)**: Sipariş verildiğinde `durationSeconds` (15 dk = 900s, 30 dk = 1800s, 60 dk = 3600s, 90 dk = 5400s, 120 dk = 7200s) atanır. Oyuncu oyunda kaldığı her saniye süre canlı olarak geri sayar.
   - **Oyun Günü Atlaması (`nextDay()`)**: Oyuncu gün atladığında her gün için süreden 5 dakika (300 saniye) düşülür; gün hedefi tamamlandığında işlem anında biter.
2. **Ödüllü Reklamla Süre Kısaltma (AdMob Rewarded Speedup)**:
   - CTA başlığı: "Atölye Ustasına Çay Ismarla • Süreyi Kısalt" / "Sponsor Parça Desteği Al".
   - Etki: Kalan sürenin %50'sini (veya 15-30 dakikalık bloğu) anında düşürür.
   - Sınır: Sipariş başına en fazla 2 reklam hakkı verilir; spam ve AdMob request storm engellenir.
3. **Rastgele Atölye Fırsatları (Random Special Deals)**:
   - Pazar yenilenirken veya gün geçerken %25 ihtimalle atölyelerden birinde "Özel Fırsat İşi" belirir (örneğin "Herr Klaus'ta bugün %35 işçilik indirimi").

---

## 4. Araç Durum Kilitleri ve Envanter Teslimatı

1. **Atölyedeyken Kilit**:
   - `car.isOutsourcedTuning = true` ve `activeTuningOrderId` atanır.
   - Araç satılamaz, galeri vitrinine konamaz, kiralanamaz veya dyno testine sokulamaz.
   - Garaj ekranında sarı/siyah taktiksel ikaz şeridi ve geri sayım sayacı ile gösterilir.
2. **Tamamlanma & Teslim Alma**:
   - Süre dolduğunda durum `readyForPickup` olur.
   - "Aracı Teslim Al" aksiyonu ile araç garaja döner; kilit kalkar, beygir gücü ve tork güncellenir, yeni unvan ve değer kazancı kalıcı olarak işlenir.
   - Oyuncu aracı dilerse hemen piyasaya ilan olarak verip kâr elde edebilir.

---

## 5. Görsel Tasarım ve Generative Art Shaders

1. **Karbon Dokuma Arka Planı (Carbon Weave CustomPainter)**:
   - 45 derece açılı çift yönlü dokuma çizgileri ve dither matrisi ile çizilen hafif, yüksek performanslı retro-teknik doku.
2. **Telemetri CRT Scanlines**:
   - Atölye telemetri kartlarında yatay CRT tarama çizgileri ve retro osiloskop dalgası.
3. **Neo-Brutalist Taktik Dil**:
   - 2.5px katı siyah kenarlık, 0-blur 4px ofset gölge, canlı dolgu renkleri (`toxicLime`, `brutalYellow`, `brutalCyan`, `brutalOrange`).
   - Sıfır Unicode Emoji: Yalnızca `VectorIconWidget` veya `Icons.*`.
   - Sıfır Parantez: ` • ` veya ` - ` kullanımı.

---

## 6. Proje Yapısı ve Etkilenen Dosyalar

```
lib/
├── data/
│   └── models/
│       ├── outsourced_tuning_model.dart     → Atölye, sipariş ve fırsat veri modelleri
│       └── car_model.dart                   → isOutsourcedTuning, activeTuningOrderId kilitleri
├── domain/
│   └── usecases/
│       └── outsourced_tuning_engine.dart    → Sipariş oluşturma, süre takibi, teslimat ve ekonomi formülleri
├── presentation/
│   ├── providers/
│   │   └── outsourced_tuning_provider.dart  → Aktif siparişler, canlı saniye sayacı ve state yönetimi
│   └── screens/
│       └── workshop/
│           ├── outsourced_tuning_screen.dart → 5 firma seçimi, sipariş paneli, teslimat vitrini
│           └── widgets/
│               ├── carbon_weave_painter.dart → Generative art karbon dokuma CustomPainter
│               └── tuning_order_timer_card.dart → Canlı geri sayım ve reklam hızlandırma kartı
test/
└── outsourced_tuning_test.dart               → Boru hattı, süre azalışı, reklam kısaltma ve ROI testleri
```

---

## 7. Başarı Kriterleri

1. 5 parodi tuning evi doğru seviye, marka ve araç kabul filtreleriyle çalışmalıdır.
2. Süreler 15 - 120 dakika arasında olmalı; aktif oyun süresinde saniye saniye geri saymalı ve gün atlamalarında da ilerlemelidir.
3. Reklam izlendiğinde süre en fazla 2 kez güvenle kısalmalıdır.
4. Modifiyedeki araç kilitlenmeli, işlem bitip teslim alındığında güncellenmiş değer ve teknik verilerle doğrudan ilana verilebilir olmalıdır.
5. Tüm metinler 7 dilde eksiksiz yerelleştirilmeli, sıfır emoji ve sıfır parantez kuralına titizlikle uyulmalıdır.
6. Birim testleri ve statik analiz hatasız geçmelidir.
