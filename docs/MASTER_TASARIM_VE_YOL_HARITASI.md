# GALERİDEN TYCOON — MASTER OYUN TASARIMI, MEKANİK, HİSSİYAT VE TUTUNDURMA RAPORU

**Tarih:** 16 Ağustos 2026 · **Sürüm:** `GameConstants.appVersion = 1.2.0` · **Branch:** `main`
**Kapsam:** Çekirdek döngü, ekonomi dengesi, arayüz hissiyatı, retention psikolojisi, özgün mekanikler, sosyal katman, yol haritası.
**Yöntem:** `lib/` altındaki 140 Dart dosyasının (38.807 satır) statik analizi + tasarım sentezi. Her tespit `dosya:satır` referanslıdır. Runtime telemetrisi yoktur; §7 bunun için ölçüm planı önerir.
**Kod değişikliği yapılmadı.** Bu rapor yalnızca tasarım ve yol haritası dokümanıdır.

---

## 0. YÖNETİCİ ÖZETİ

Galeriden'in sorunu **içerik eksikliği değil.** 11 yan işletme, 8 hikâye kartı, 16 rastgele olay, dramatik ikilem kartları, müzayede, hurdalık, karaborsa, borsa, banka, personel akademisi, tuning stüdyosu — hepsi yazılmış ve büyük kısmı artık arayüze bağlanmış durumda. Önceki raporlarda tespit edilen "ölü sistem" örüntüsünün çoğu kapatılmış (FOMO metinleri, near-miss, rastgele olaylar, ses/haptik çağrıları artık canlı).

Bu aşamada oyunu sınırlayan şey **beş yapısal denge sorunu.** Hepsi tasarım kararı, hiçbiri "eksik özellik" değil:

### Teşhis 1 — Oyunun iki farklı zaman evreni var, birbirini yiyorlar

`game_time_mixin.dart:33-37`: timer 60 saniyede bir tikliyor, her 2 tikte 1 oyun günü ilerliyor. Yani:

| Oyun içi süre | Gerçek süre |
|---|---|
| 1 gün | 2 dakika |
| 1 hafta (haftalık etkinlik döngüsü) | **14 dakika** |
| 1 mevsim (7 gün) | 14 dakika |
| 1 yıl (28 günlük tam mevsim döngüsü) | **56 dakika** |

Buna karşılık giriş serisi (`psychology_engine.dart:50-73`) **gerçek takvim gününe** bağlı. Sonuç: oyuncu tek oturumda 3 kez kış görüyor, ama giriş serisi 1 artıyor.

Bunun tasarımsal maliyeti çok yüksek: **mevsimsellik anlamsızlaşıyor.** "Kışın SUV +%35 talep görür" (`dealership_model.dart:270-273`) güzel bir mekanik ama oyuncu kışlık SUV stoklayıp bekleyemiyor — 14 dakika sonra yaz geliyor. Aynı şekilde "Cuma Galeri Pazarı" (`weekly_event_engine.dart:51-57`) her 14 dakikada bir tekrarlıyor; bir *olay* olmaktan çıkıp arka plan gürültüsüne dönüşüyor. Haftalık etkinlik takvimi, ancak oyuncunun onu **bekleyebildiği** ölçüde etkinliktir.

### Teşhis 2 — Pasif gelir, aktif oynanışı sayısal olarak yok ediyor

11 yan işletmenin tüm yükseltmeleri alındığında toplam pasif gelir (`dealership_model.dart:482-681`):

| Kalem | Değer |
|---|---|
| Toplam günlük pasif gelir (tam upgrade) | **≈ ₺927.800 / oyun günü** |
| Gerçek zamanda karşılığı | **≈ ₺27.800.000 / saat** |
| Toplam yatırım maliyeti (satın alma + yükseltmeler) | ≈ ₺26.800.000 |
| Amortisman süresi | ≈ 29 oyun günü = **≈ 58 gerçek dakika** |

Karşısında ana döngü: 240.000 ₺'lik bir "halk" segmenti aracı alıp onarıp satmak, pazarlık becerisi tavanda (`player_skills.dart:79`, max %20) olsa bile ~80-120 bin ₺ brüt kâr üretiyor ve oyuncunun 8-12 dakikasını alıyor. Yani **oyuncu, ana döngüyü oynayarak dakikada ~10 bin ₺, hiçbir şey yapmayarak dakikada ~463 bin ₺ kazanıyor.**

Oyuncu bunu 2. saatte fark eder. Fark ettiği an araba alıp satmayı bırakır, uygulamayı arka planda açık bırakır. Tasarlanan oyun budur değil.

> Not: Bu, önceki raporda tespit edilen sorunun **azalmış ama devam eden** hâli. Sabit gider artık mülk kademesine bağlanmış (`game_time_mixin.dart:57-66`) ve tavan ₺45.000/gün — pasif gelirin %5'i bile değil. Gider tarafı, gelir tarafına yetişmiyor.

### Teşhis 3 — Risk mekaniklerinin dişleri sökülmüş

Üç ayrı yerde risk var, üçü de fiilen risk üretmiyor:

- **İflas imkânsız.** `game_time_mixin.dart:236-241`: bakiye eksiye düşer ve likidite ₺25.000'in altındaysa, bakiye ₺25.000'e sabitlenir **ve tüm krediler silinir.** Yani en kötü senaryo "borçsuz, 25 bin lirayla yeniden başla". Bu bir güvenlik ağı değil, ödül.
- **Ekspertiz bir karar değil, bir vergi.** Ekspertiz sabit ₺1.500 (`game_constants.dart:29`). Ekspertizsiz alımda %30 ihtimalle tuzak, ortalama değer kaybı ~%28 (`risk_engine.dart:24-117`). 240 bin ₺'lik bir araçta beklenen kayıp ≈ ₺20.000. Yani ekspertiz **her zaman doğru cevap.** Doğru cevabı tek olan seçim, seçim değildir.
- **Alıcı tavanı gerilimi öldürüyor.** `negotiation_engine.dart:405-408`: alıcı asla aracın gerçek değerinin %115'inin üzerine çıkmaz. Bu, "hayatının pazarlığını yapma" fantezisini matematiksel olarak imkânsız kılıyor. Koleksiyoner jackpot'u (%2, +%20-40) bu tavanla çelişiyor.

### Teşhis 4 — Dışsal tetikleyici yok: retention'ın sert tavanı

`pubspec.yaml`'da hiçbir bildirim paketi yok; `notification_service.dart` tamamen `toastification` üzerine kurulu — yani **yalnızca uygulama içi toast.** Oyunu kapatan oyuncuyu geri çağıran tek bir mekanizma bulunmuyor.

D1 retention'ın en güçlü tek kaldıracı push bildirimidir. Oyunda D1'i taşıyacak **içerik** var (giriş serisi ödülleri ₺200.000'e kadar tırmanıyor, `psychology_engine.dart:75-89`), ama oyuncuya bunu **hatırlatan** hiçbir şey yok. Bu, dolu bir depoyu borusuz bırakmak demek.

İkinci kırık: **offline dönüş ödülü ters ölçekli.** `offline_progression.dart:40` — 30 offline dakika = 1 oyun günü. Online'da 30 dakika = 15 oyun günü. Yani **oyuncu offline kaldığında 15 kat yavaş ilerliyor.** "Yokluğunda Neler Oldu?" ekranı, 12 saatlik yokluğu 24 dakikalık online oyuna eşitliyor. Geri dönüşün ödülü, geri dönmemenin cezasından küçük.

### Teşhis 5 — Seviye 4'ten sonra içerik uçurumu

`dealership_model.dart:280-313` — `getRequiredLevel` en fazla **4** döndürüyor. Seviye 4'te tüm rotalar (hurdalık, rent-a-car, karaborsa, yan işletmeler, şubeler) açılmış oluyor.

Buna karşılık `rpgTitle` (`dealership_model.dart:173-195`) Seviye 12+ için unvan tanımlıyor ve XP eğrisi (`player_skills.dart:23-29`) Seviye 4'ten sonra ×1,35 üstel büyüyor. Yani oyuncu Seviye 5-12 arasında **giderek artan XP ödüyor ve karşılığında yalnızca yetenek puanı alıyor** — yeni oda, yeni mekanik, yeni oyuncak yok. Beceri ağacı da 5 dallı ve dal başına tavanlı (`player_skills.dart:79-91`), yani ~10 seviyede doyuyor.

Uzun vadeli oyuncunun ilerleme hissi Seviye 4'te duruyor. D30 sorunu buradan başlıyor; ödül tablosundan değil.

### En yüksek getirili üç hamle

| # | Hamle | Neden bu üçü |
|---|---|---|
| **1** | **Zaman mimarisini yeniden ölçekle** (§1.1) | Tek bir sabitin değişmesi mevsimselliği, haftalık etkinlikleri, pazar spekülasyonunu ve offline dengesini aynı anda düzeltir. Efor: çok düşük. Etki: sistemik. |
| **2** | **Push/yerel bildirim altyapısı + randevulu kanca sistemi** (§3.1, §3.3) | D1 retention'ın tek sert limiti. İçerik zaten hazır, boru hattı yok. |
| **3** | **Pasif geliri "kapasite"ye bağla** (§1.2) | Yan işletmelerin geliri, ana döngü hacminin bir *fonksiyonu* olmalı — bağımsız bir musluk değil. Bu, tycoon türünün temel sözleşmesidir. |

---

# 1. ÇEKİRDEK OYUN DÖNGÜSÜ VE EKONOMİ DENGESİ

## 1.1 Zaman Mimarisi: Tek Sabit, Beş Sistem

**Mevcut:** `game_time_mixin.dart:33-37` — `Timer.periodic(60s)`, her 2 tikte `advanceGameDay()`.

**Sorun:** Tek bir "gün" tanımı beş farklı sistemi besliyor ve hepsi için yanlış hızda:

| Sistem | İhtiyaç duyduğu tempo | Aldığı tempo |
|---|---|---|
| Sabit gider / maaş tahakkuku | Sık (baskı hissi için) | 2 dk — doğru |
| Kredi taksiti (7 günde bir) | Orta | 14 dk — doğru |
| Mevsim döngüsü (28 gün) | **Yavaş** (spekülasyon için) | 56 dk — **çok hızlı** |
| Haftalık etkinlik takvimi | **Yavaş** (beklenti için) | 14 dk — **çok hızlı** |
| İlan bayatlaması (`daysListed >= 10`) | Orta | 20 dk — doğru |

### Öneri: Çift Katmanlı Takvim

Tek bir "gün" yerine iki ayrı saat çalıştır:

**Katman A — Operasyon Günü (2 dakika, mevcut hâliyle kalsın).**
Sabit gider, maaş, kira geliri, ilan yaşlanması, çek/senet vadesi, borsa dalgalanması. Bunlar oyuncunun *nabzı*; sık olmalı.

**Katman B — Piyasa Sezonu (gerçek takvim gününe bağlansın).**
Mevsim, haftalık etkinlik takvimi, piyasa trendi (`market_engine.dart:12-63`), sanayi bülteni, müzayede takvimi. Bunlar oyuncunun *stratejisi*; yavaş olmalı ve **gerçek dünya takvimiyle senkron** olmalı.

Somut kural önerisi:
- Gerçek Pazartesi → oyun içi "Kredi Kolaylığı Pazartesisi"
- Gerçek Cumartesi → "Hafta Sonu Açık Oto Pazarı" (ziyaretçi ×1,6)
- Gerçek ay → mevsim (Aralık-Şubat kış, SUV +%35)

**Kazanç zinciri:**
1. Oyuncu "cumartesi oynamalıyım" öğrenir → haftalık ritim doğar (D7 kancası, bedava).
2. Kışın SUV stoklamak **gerçek bir yatırım kararı** olur; oyuncu 3 gün bekleyip satar → *spekülasyon* mekaniği ilk kez çalışır.
3. Push bildirimi için doğal içerik doğar: "Cumartesi pazarı açıldı, vitrinindeki 3 araca alıcı akını başladı."
4. Offline dengesizliği kendiliğinden çözülür — sezon zaten gerçek zamanda akıyor.

> **Duygusal Etki:** *Sabır artık bir strateji.* Oyuncu ilk kez "şimdi satmayacağım, kışı bekleyeceğim" diyebilir. Bu cümle, bir tycoon oyununun olgunluk göstergesidir — oyuncu artık tepki vermiyor, **plan yapıyor.**

---

## 1.2 Pasif ve Aktif Gelir Dengesi: "Musluk" Değil "Kapasite"

**Mevcut:** Yan işletmeler mutlak sabit gelir üretiyor (`game_time_mixin.dart:244-253`). Bir kez satın alındı mı, oyuncunun ne yaptığından bağımsız olarak akıyor. Oto Yıkama'nın günlük geliri, oyuncunun kaç araç yıkadığıyla ilgisiz.

Bu, türün temel sözleşmesini bozuyor: **bir tycoon oyununda pasif gelir, aktif faaliyetin *kaldıracı*dır, ikamesi değil.**

### Öneri A — Doluluk Katsayısı (Utilization)

Her yan işletmenin geliri, ana döngüdeki faaliyetin bir fonksiyonu olsun:

```
efektif_gelir = baz_gelir × doluluk_katsayısı
doluluk_katsayısı = clamp(0.25, 1.60, f(ilgili_aktivite))
```

| İşletme | Doluluk sürücüsü | Boşta (min) | Tam (maks) |
|---|---|---|---|
| Oto Yıkama | Son 7 günde yıkanan araç sayısı | %25 | %160 |
| Ekspertiz İstasyonu | Son 7 günde yapılan ekspertiz | %25 | %160 |
| Reklam Panosu | Vitrindeki listelenmiş araç sayısı | %30 | %150 |
| Yedek Parça Deposu | Atölyede tamamlanan onarım | %25 | %160 |
| Çekici Filosu | Hurdalıktan çekilen araç | %30 | %150 |
| Kiralama | Filodaki aktif kira sözleşmesi | %20 | %170 |

**Neden bu tasarım doğru:** Oyuncu yan işletmeyi kapatmıyor, ama **oynamadığında yarı verimle çalışıyor.** Oynadığında ise pasif gelir *artıyor* — yani aktif oynanış, pasif geliri de büyütüyor. Ana döngü ile pasif katman birbirini besliyor, birbirinin yerine geçmiyor.

### Öneri B — Ölçek Kilidi (Sermaye Basamakları)

Yan işletme yükseltmeleri şu an sadece parayla açılıyor. Ekle: **her yükseltme aynı zamanda bir operasyonel eşik istesin.**

> "DC 180kW Ultra Hızlı Supercharger — ₺660.000 **ve** en az 3 elektrikli araç satmış olmak."
> "Kurumsal Şirket Filo Sözleşmeleri — ₺810.000 **ve** eş zamanlı 5 aktif kira sözleşmesi."

Bu, parayı tek başına yeterli olmaktan çıkarır ve oyuncuyu ana döngüye geri iter.

> **Duygusal Etki:** *"Galerim benim yüzümden büyüyor."* Şu an oyuncu bir musluğu açıyor ve izliyor. Bu değişiklikle her satış, her yıkama, her ekspertiz **imparatorluğunun bir tuğlası** oluyor. Sahiplik hissi (ownership) buradan doğar.

### Öneri C — Enflasyon: Yumuşak Para Emici

Şu an ekonomide para yok edici yok denecek kadar az (sabit gider tavanı ₺45.000/gün). Öneri:

- **Sanayi Enflasyon Endeksi:** Her 10 oyun gününde yedek parça, boya, işçilik maliyetleri +%3-6 artsın; araç piyasa değerleri +%2-4 artsın. Yani **maliyet, değerden hızlı artsın.** Bu, "eskiden ne ucuzdu" hissini üretir ve marjı doğal olarak sıkar.
- **Vergi Dilimi:** `dailyTaxRate` sabit ₺150 (`dealership_model.dart:368`). Bunu ciroya bağla: son 7 günün cirosunun %2-4'ü. Zengin oyuncu daha çok öder.
- **Amortisman:** Vitrinde 20+ gün bekleyen araç günde %0,3 değer kaybetsin. `daysListed` alanı zaten var (`car_model.dart:30`) ve `isStaleListing` getter'ı hazır (`car_model.dart:91`) — sadece ekonomik sonuç bağlanmamış.

> **Duygusal Etki:** *Tatlı bir tedirginlik.* Para artık "biriken" değil, "eriyen" bir kaynak. Oyuncu her sabah bakiyesine bakıp "bugün ne yapmalıyım?" diye sorar. Tycoon türünün motoru bu sorudur.

---

## 1.3 Kelepir Avı ve Gizli Kusur: Ekspertizi Gerçek Bir Karara Dönüştürmek

**Mevcut:** Ekspertiz ₺1.500 sabit; ekspertizsiz alımda %30 tuzak riski. Matematik ekspertizden yana ezici — dolayısıyla karar yok.

### Öneri: Üç Kademeli Bilgi Ekonomisi

| Yöntem | Maliyet | Süre | Ne gösterir | Ne gizler |
|---|---|---|---|---|
| **Göz Kararı** (Bedava) | ₺0 | Anlık | `eyeForDetail` becerisine göre 1-3 rastgele parçanın durumu + "içimde kötü bir his var" sinyali | Kalan her şey |
| **Hızlı Bakı** (Sanayide usta) | Araç değerinin **%0,4'ü** | 1 oyun günü | Motor/şanzıman skoru + tramer tutarı | Kaporta detayı, KM oynaması |
| **Tam Ekspertiz** (Kurumsal) | Araç değerinin **%1,2'si** | 2 oyun günü | Her şey + KM taraması + **garanti** (yanlış çıkarsa masraf ekspertizcinin) | — |

**Kritik değişiklikler:**
1. **Maliyet araç değerine oranlansın.** ₺6.500.000'luk bir Ferro için ₺1.500 ekspertiz saçma; ₺45.000 anlamlı. Ucuz araçlarda ekspertiz ihmal edilebilir hâle gelir → *gerçek bir risk iştahı kararı doğar.*
2. **Ekspertiz zaman alsın.** Kelepir ilan 1 gün beklerken kapılabilir. "Ekspertiz yaptırayım mı, yoksa kaçar mı?" — işte bu bir karardır.
3. **`ExpertiseEngine.detectHiddenTampering`** (`expertise_engine.dart:8-13`) zaten var ve yalnızca KM oynaması için kullanılıyor. Bunu "Göz Kararı" katmanının motoru yap — beceri seviyesi arttıkça bedava bilgi artsın. Beceri ağacına gerçek bir anlam kazandırır.
4. **Satıcı yalanı katmanı:** `sellerProfiles` (`game_constants.dart:279-285`) şu an sadece kozmetik metin. Her profile bir **doğruluk oranı** ver:
   - "Doktordan Temiz" → %90 dürüst
   - "Acil Satılık Sahibinden" → %55 dürüst (aceleci = bir şey saklıyor)
   - "Galeriden Takaslı" → %40 dürüst (meslektaş, oyunu biliyor)
   - "Koleksiyoner" → %95 dürüst ama fiyat kırmaz

> **Duygusal Etki:** *Kumarbazın kalp atışı — ama bilgiye dayalı.* Oyuncu ilanı okur, satıcı profiline bakar, cebindeki paraya bakar ve "riske gireyim mi?" der. Kazandığında zekâsıyla övünür, kaybettiğinde kendini suçlar. İkisi de bağımlılık yapar; şansa yenilmek yapmaz.

### Alt Mekanik: "Kelepir Radarı" (Piyasa Sezgisi becerisinin karşılığı)

`marketSense` becerisi şu an yalnızca doping etkinliğini artırıyor (`player_skills.dart:85`). Ekle: seviye başına %8 ihtimalle ilan listesinde bir araca **"👃 BURNUMA BİR KOKU GELİYOR"** rozeti düşsün. Rozet, aracın gerçek değerinin ilan fiyatının %25 üzerinde olduğunu *ima etsin* — ama %20 ihtimalle yanılsın.

> **Duygusal Etki:** *Uzmanlık gururu.* Oyuncu piyasayı kendi gözüyle okuduğunu hisseder. Yanıldığında bile "bu sefer olmadı" der — çünkü sistem ona bilgi değil, *sezgi* vermiştir.

---

## 1.4 Pazarlık: Tavanı Kaldır, Kişiliği Derinleştir

**Mevcut:** `negotiation_engine.dart:405-408` — alıcı hiçbir koşulda gerçek değerin %115'ini geçmez. 4 müşteri arketipi var (`customer_model.dart:1-6`) ve 4 pazarlık stratejisiyle eşleşiyor (`negotiation_engine.dart:314-339`) — bu kısım iyi tasarlanmış.

### Öneri A — Tavanı koşullu kaldır

%115 tavanı **genel kural olarak kalsın**, ama şu üç durumda esnesin:

| Koşul | Yeni tavan |
|---|---|
| Alıcı = Koleksiyoner arketipi + araç `isRare` | %165 |
| Araç, aktif bir "Aranan Araç Sözleşmesi"ne uyuyor (`contract_model.dart` zaten var) | %140 |
| Oyuncu itibarı ≥ 90 **ve** araç `provenanceLog`'unda restorasyon kaydı var | %135 |

Böylece "hayatının satışı" mümkün olur ama nadirdir — tam da olması gerektiği gibi.

### Öneri B — Müşterinin Hafızası

`loyalCustomerNames` alanı kayıtlı (`dealership_model.dart:133`) ve `generateLoyalCustomerOffer` fonksiyonu yazılmış (`negotiation_engine.dart:440-468`) ama **hiçbir yerden çağrılmıyor.** Bu bağlanmalı ve genişletilmeli:

- Memnun müşteri 5-15 gün sonra **kendi kendine** geri gelir, %98-106 teklif verir (kod hazır).
- Memnun müşteri **arkadaşını getirir**: "Kuzenim senden almış, çok memnun. Bana da bakar mısın?"
- Aldatılmış müşteri (§4.5) geri gelir — ama teklif vermek için değil.

> **Duygusal Etki:** *Esnaflık gururu.* Tanıdık bir isim ekranda belirdiğinde oyuncu gerçekten sevinir. Bu, oyunun en ucuz ve en güçlü duygusal kancasıdır: dünyanın oyuncuyu hatırladığı hissi.

### Öneri C — Pazarlıkta "Sıcak Çay" Ekonomisi

Türk oto galericiliğinin en ikonik ritüeli oyunda yok. Pazarlık ekranına küçük bir eylem çubuğu ekle:

| Eylem | Maliyet | Etki |
|---|---|---|
| ☕ Çay ısmarla | ₺50 | Alıcının sabrı +1 tur, cüzdanı +%2 |
| 🚬 Bir sigara molası | ₺0 | Karşı teklifi 1 tur geciktirir, alıcı arketipini açığa çıkarır |
| 🤝 "Hayırlı olsun" el sıkışması | — | Anlaşma kapanır, itibar +1 |
| 📞 "Bir dakika, ortağımı arayayım" | ₺0 (1 kez) | Yeni teklif üretir ama %15 ihtimalle alıcı sıkılıp gider |

> **Duygusal Etki:** *Kültürel tanınma.* Türk oyuncu için bu, "bu oyun beni tanıyor" anıdır. Küresel oyuncu için ise egzotik ve akılda kalıcı bir imza mekaniği — oyunun App Store ekran görüntüsünde göstereceği şey.

---

## 1.5 İflas ve Gerilim: Kurtarma Ağını Yeniden Tasarla

**Mevcut:** `game_time_mixin.dart:236-241` — bakiye eksiye düşerse ₺25.000 hibe + **tüm krediler silinir.**

**Sorun:** Batmak ödüllendiriliyor. Bir oyuncu bunu keşfederse optimal strateji "kredi çek, hepsini harca, bat, borçlar silinsin" olur.

### Öneri: Üç Aşamalı Batma

| Aşama | Tetik | Sonuç |
|---|---|---|
| **1. Sıkışma** | Bakiye < günlük gider × 3 | Kırmızı HUD, "Bu ay maaşları zor ödersin" uyarısı, acil satış paneli açılır (araçlar %85 değerine anında nakde çevrilebilir) |
| **2. İcra** | Bakiye < 0, 3 gün üst üste | Rastgele bir araca **haciz** konur (satılamaz, kilitli), personel ayrılır, itibar -10 |
| **3. Konkordato** | Bakiye < 0, 7 gün üst üste | Galeri bir alt kademeye düşer (şube kaybı), krediler **silinmez, yeniden yapılandırılır** (vade 2×, faiz +%50), oyuncuya ₺25.000 sermaye verilir |

Ve kritik ekleme: **Konkordato bir "Hanedan Kaydı" bırakır.** `dynastyHistoryLog` alanı zaten var (`dealership_model.dart:84`) ve kullanılmıyor. Batış oraya yazılsın: *"2. Nesil — Gün 340: Levent Plazası elden çıktı. Yeniden başladık."*

> **Duygusal Etki:** *Gerçek korku, sonra gerçek onur.* Kaybetme ihtimali olmayan oyunda kazanmanın tadı yoktur. Ama batış **hikâyeye dönüştüğünde** oyuncu oyunu bırakmaz — anlatacak bir şeyi olur.

---

## 1.6 Seviye 4 Uçurumu: İlerlemeyi Yeniden Aç

**Mevcut:** Tüm içerik Seviye 4'te açılıyor (`dealership_model.dart:280-313`). Seviye 5-12 boş.

### Öneri: İkinci Yarı İlerleme Ekseni — "Kademeler" (Prestige Tiers)

Seviye yerine **kurumsal kademe** ekseni ekle. Her kademe seviye + operasyonel eşik ister:

| Kademe | Şart | Açılan |
|---|---|---|
| **Sanayi Esnafı** (Lv 5) | 25 araç satışı | Semt Hakimiyeti sistemi (§4.1), Sanayi Dedikodu Hattı (§4.7) |
| **Bölge Bayii** (Lv 7) | 3 semtte pazar payı ≥ %20 | Konsinye & Emanet (§4.6), İkinci şube yönetimi |
| **Plaza Sahibi** (Lv 9) | Koleksiyon albümü ≥ %40 | İthalat & Gümrük hattı, VIP randevu takvimi |
| **Otomotiv Baronu** (Lv 11) | Net varlık ₺50M | Sanayi Odası / Lonca (§5.3), Franchise verme |
| **Galeriler Şahı** (Lv 13+) | Şehir liderliği 7 gün | Prestij döngüsü (yeniden başla, kalıcı %15 çarpan) |

`rpgTitle` (`dealership_model.dart:173-195`) bu unvanları zaten tanımlıyor — sadece arkalarında içerik yok. Prestij sistemi de kısmen bağlı (`game_market_mixin.dart:347` çarpanı uyguluyor). Yapılacak iş, mevcut iskelete et giydirmek.

> **Duygusal Etki:** *Ufuk hissi.* Oyuncu Seviye 4'te "hepsini gördüm" demek yerine, kilitli "Bölge Bayii" kartını görüp "oraya gideceğim" der. Retention, ödülden değil **görünür ufuktan** doğar.

---

# 2. ARAYÜZ, MİKRO-HİSSİYAT VE "JUICY" ETKİLEŞİMLER

## 2.1 En Büyük Boşluk: Oyunda Ses Yok

**Tespit:** `pubspec.yaml`'da hiçbir ses paketi yok. `assets/` altında tek bir `.mp3`/`.wav` yok. `GameSoundHapticService` (`game_sound_haptic_service.dart`) yalnızca `SystemSound.play(SystemSoundType.click)` — yani işletim sisteminin jenerik tık sesi — ve `HapticFeedback` kullanıyor.

Bu, Neo-Brutalist bir tycoon oyunu için **kritik** bir eksik. Neo-Brutalizm'in tamamı "ağırlık" hissi üzerine kurulu: kalın konturlar, sert gölgeler, sıfır blur. Bu görsel dil **sesle tamamlanmadığında yarım kalır** — göz "TAK" diyor, kulak sessiz.

### Öneri: 12 Sesli Minimal Kütüphane (~400 KB)

| Olay | Ses karakteri | Süre |
|---|---|---|
| Buton basımı | Kalın mekanik klik (ağır anahtar) | 60ms |
| Para kazanımı | Yazarkasa çekmecesi + madeni para | 400ms |
| Büyük satış (>%30 kâr) | Kasa + kısa zafer korno | 900ms |
| Noter imzası | Kaşe damgası "TAK" | 250ms |
| Müzayede teklifi | Tokmak vuruşu | 180ms |
| Müzayede kazanma | Üçlü tokmak + kalabalık uğultusu | 1,2sn |
| Ekspertiz açılışı | Kaporta metal tıkırtısı | 300ms |
| Tuzak/hasar tespiti | Alçak uğursuz vuruş | 500ms |
| Seviye atlama | Yükselen 3 nota + tabela çakması | 1,0sn |
| Yeni teklif geldi | Kısa telefon bildirimi (esnaf telefonu) | 350ms |
| Gün geçişi | Kepenk sesi | 600ms |
| Hata / yetersiz bakiye | Kısa "vızzt" reddi | 200ms |

**Uygulama notu:** `audioplayers` veya `just_audio` paketi yeterli. Ayarlarda "Ses: Açık/Kapalı" anahtarı zorunlu.

> **Duygusal Etki:** *Fiziksellik.* Para kazandığında oyuncunun elinde bir şey olduğunu hissetmesi. Bu tek başına oturum süresini ölçülebilir biçimde uzatan, en düşük efor/en yüksek etki oranına sahip müdahaledir.

---

## 2.2 Haptik Dilbilgisi: 6 Metot Var, Anlam Haritası Yok

**Mevcut:** 6 haptik metot tanımlı ve artık çağrılıyor (`playCashSuccess`, `playNotarySignature`, `playAuctionBid`, `playWarningVibration` — auction, showroom offers ve random event dialog'larında canlı). Ama bir **dilbilgisi** yok: hangi olay hangi yoğunlukta titreşir, tutarlı değil.

### Öneri: Üç Yoğunluk Sınıfı

| Sınıf | Haptik | Kullanım |
|---|---|---|
| **Seçim** | `selectionClick` | Sekme değişimi, kaydırma durağı, filtre, seçenek işaretleme |
| **Onay** | `lightImpact` → `mediumImpact` | Buton basımı → işlem tamamlandı |
| **Sonuç** | `heavyImpact` (+ 2× pattern) | Satış kapandı, tuzak açığa çıktı, seviye atlandı, müzayede kazanıldı |

**Kritik kural:** *Kayıp ve kazanç farklı hissettirmeli.* Kazanç = tek net `heavyImpact`. Kayıp = çift kısa `vibrate` (kesik, rahatsız edici). Oyuncu ekrana bakmadan ne olduğunu anlayabilmeli.

### Anti-örüntü uyarısı
`playTapImpact()` global dokunma geri bildirimi olarak her ekran dokunuşunda tetikleniyor (`neo_brutal_touch_feedback_overlay.dart`). Bu **haptik körlüğü** yaratır — her şey titreşiyorsa hiçbir şey titreşmiyordur. Öneri: global dokunma haptiğini kaldır, yalnızca **etkileşimli öğelere** bağla.

> **Duygusal Etki:** *Güven.* Titreşim tutarlı bir dil konuştuğunda oyuncu arayüze güvenir; kaotik olduğunda ayar menüsünden kapatır.

---

## 2.3 Neo-Brutalist Doygunluk ve Kontrast Disiplini

**Mevcut:** `app_colors.dart` içinde **üç ayrı ve çelişen palet** yaşıyor:
- "Quiet Luxury" (şampanya altını, platin buz — satır 19-22)
- "Arcade Tycoon" (neon cyan, arcade gold, electric purple — satır 47-52)
- "Neo-Brutalism" (brutalYellow, brutalPink, brutalCyan... — satır 61-75)

Ayrıca "Beneloil" adında dördüncü bir token grubu var (satır 55-58). Üç farklı görsel felsefe aynı dosyada duruyor ve ekranlar farklı gruplardan besleniyor.

### Öneri: Tek Palet Otoritesi + Renk Anlam Sözleşmesi

Neo-Brutalist paleti **tek kaynak** ilan et; diğerlerini deprecate et. Ve renklere **anlam** ata — Neo-Brutalizm'de renk dekorasyon değil, işaretleme aracıdır:

| Renk | Anlam | Asla kullanılmaz |
|---|---|---|
| `brutalYellow` #FFDE59 | **Para & fırsat** — kâr, ödül, kelepir | Uyarı için |
| `brutalGreen` #00E575 | **Sağlam & orijinal** — orijinal parça, tamamlanan iş | Para için |
| `brutalPink` #FF54B0 | **Nadir & koleksiyon** — rare araç, albüm | Hata için |
| `brutalOrange` #FF7A00 | **Dikkat** — boyalı parça, bayat ilan, vade yaklaşıyor | Başarı için |
| `errorRed` #F43F5E | **Kayıp & risk** — hasar, zarar, yakalanma | Vurgu için |
| `brutalCyan` #00F0FF | **Bilgi & piyasa** — trend, haber, istatistik | Eylem için |

**Kontrast disiplini (WCAG AA zorunlu):** `brutalYellow` üzerinde beyaz metin okunmaz — sarı zeminde **her zaman siyah**. Bu kural şu an `notification_service.dart`'ta doğru uygulanmış (`textColor: Colors.black`); tüm bileşenlere yayılmalı.

**Neo-Brutalist imza tutarlılığı:** kontur 2,8px, gölge offset (4,4), blur 0, radius 8-10. Bu değerler `notification_service.dart:96-107`'de doğru; `app_spacing.dart` üzerinden tek kaynağa taşınmalı.

> **Duygusal Etki:** *Netlik ve karakter.* Oyuncu ekrana baktığında rengin ne anlama geldiğini öğrenir ve bir daha okumak zorunda kalmaz. Bu, bilgi yoğun bir tycoon oyununda hızın kaynağıdır.

---

## 2.4 Sürtünme: 28 Ekran, Düz Bir Menü

**Tespit:** `router.dart`'ta 28 rota var, hepsi düz (nested route yok). Ana ekrandan hizmet ızgarasıyla (`dashboard_services_grid.dart`) erişiliyor.

**Sorun:** Ana döngü — *ilan gör → ekspertiz → satın al → atölye → yıkama → vitrin → pazarlık* — **6 ekran geçişi** gerektiriyor. Bir araç için 6 kez ana ekrana dönüp yeni bir kart tıklamak, oyunun ritmini kesiyor.

### Öneri A — "Araç Dosyası" Tam Ekran Bağlamı

Bir araca dokunulduğunda ekran değiştirmek yerine, o aracın **tam ekran dosyası** açılsın; içinde sekmeler olsun:

```
┌─ 2016 BEMEVE 3.20d ────────────────── ₺485.000 ─┐
│ [DURUM] [EKSPERTİZ] [ATÖLYE] [BAKIM] [İLAN]     │
│                                                  │
│  ... aktif sekme içeriği ...                     │
│                                                  │
│ [◀ Önceki Araç]              [Sonraki Araç ▶]   │
└──────────────────────────────────────────────────┘
```

Oyuncu aracı bırakmadan tüm işlemleri yapar. Alt kısımdaki "Önceki/Sonraki Araç" gezinmesi, garajı **tek bir akışta** işlemeyi sağlar. Bu tek değişiklik, ana döngüdeki tıklama sayısını yaklaşık yarıya indirir.

### Öneri B — Bağlamsal Kısayollar

Her ekranın altında "sıradaki mantıklı adım" butonu olsun:
- Ekspertiz bittiğinde → **[SATIN AL]** (fiyat + tahmini kâr üstünde yazılı)
- Satın alma bittiğinde → **[ATÖLYEYE GÖNDER]** veya **[DOĞRUDAN VİTRİNE KOY]**
- Onarım bittiğinde → **[YIKAMAYA GÖNDER]**
- Yıkama bittiğinde → **[İLANI YAYINLA]**

Oyuncu ana ekrana hiç dönmeden bir aracı baştan sona işleyebilmeli.

### Öneri C — "Toplu İşlem" (Batch)
Garajda 6+ araç olduğunda tek tek işlem yorucudur. Vitrin ekranına: **[TÜMÜNÜ YIKA]**, **[TÜMÜNÜ PİYASA FİYATINA LİSTELE]**, **[BAYAT İLANLARI %5 İNDİR]** butonları.

> **Duygusal Etki:** *Akış (flow).* Sürtünme azaldığında oyuncu "işlem yapıyorum" hissinden "galeri işletiyorum" hissine geçer. Oturum süresi burada uzar — ödülle değil, kesintisizlikle.

---

## 2.5 Bilgi Yoğunluğu: Tek Bakışta Karar

**Sorun:** Oyuncunun bir araç hakkında bilmesi gereken 4 şey var ve şu an 4 farklı yerde:
1. Hasar geçmişi → ekspertiz ekranı
2. Kâr marjı → hesaplaması oyuncuya bırakılmış
3. Piyasa trendi → dashboard banner'ı
4. İlan yaşı → kart üzerinde küçük metin

### Öneri: "Üç Bantlı Araç Kartı"

Neo-Brutalist mantıkla, her araç kartı tek bakışta üç şeyi söylesin:

```
┌────────────────────────────────────────────────┐
│ ████████████░░░  KAPORTA SAĞLIK: %78          │ ← Bant 1: Fiziksel durum
│ 🟩🟩🟧🟩🟥🟩🟩🟩🟩🟩🟧🟩  (12 parça haritası)  │
├────────────────────────────────────────────────┤
│ 2016 BEMEVE 3.20d Yanlama E-90                │
│ Alış ₺340.000  →  Masraf ₺62.000              │
│ ╔══════════════════════════════════════════╗   │
│ ║  NET KÂR:  +₺83.000   (+%20,5)  ▲       ║   │ ← Bant 2: Para
│ ╚══════════════════════════════════════════╝   │
├────────────────────────────────────────────────┤
│ 📈 SEDAN PİYASASI: +%15  •  ⏱ İLAN 4. GÜN     │ ← Bant 3: Zaman & piyasa
└────────────────────────────────────────────────┘
```

**Tasarım kuralları:**
- 12 parçalık renk haritası (`car_damage_schema_widget.dart` zaten var) **kartın üstünde** olsun, ayrı ekranda değil. `AppColors.partOriginal/partPainted/partChanged/partDamaged` renkleri hazır.
- **Net kâr her zaman görünür** ve *işlenmiş* olsun: alış + tüm masraflar düşülmüş. Oyuncu asla hesap yapmasın.
- Kâr negatifse kutu kırmızıya döner ve **"ZARARDA"** yazar — belirsizlik bırakma.
- İlan 10. günü geçtiyse (`isStaleListing`) bant 3 turuncu yanıp söner: **"BAYATLIYOR — FİYAT KIR"**

### Öneri: Kâr Marjı Isı Şeridi
Vitrin listesinin sol kenarında dikey 4px şerit: yeşil (>%25 marj), sarı (%10-25), turuncu (%0-10), kırmızı (zarar). Oyuncu listeyi kaydırırken **okumadan** hangi araçların iyi durumda olduğunu görür.

> **Duygusal Etki:** *Kontrol hissi.* "Ben bu işi biliyorum" duygusu, bilginin bol olmasından değil **doğru sıralanmasından** doğar. Oyuncu hesap makinesi olmaktan çıkıp patron olur.

---

## 2.6 Juice: Para Sıçraması ve Sayaç Psikolojisi

**Mevcut:** `floating_money_overlay.dart` var — iyi bir başlangıç.

### Öneri: 5 Katmanlı Kazanç Anı

Bir satış kapandığında sırayla (toplam ~1,4 saniye):

| Sıra | Efekt | Süre |
|---|---|---|
| 1 | Ekran hafif "sarsılır" (2px, 80ms) + `heavyImpact` haptik | 80ms |
| 2 | Kasa sesi + araç kartı fiziksel olarak yukarı fırlar ve yok olur | 300ms |
| 3 | ₺ ikonları alıcıdan HUD'daki bakiyeye doğru **yay çizerek** uçar (8-15 adet, kâr miktarına göre) | 500ms |
| 4 | HUD bakiyesi **eski değerden yeni değere sayarak** artar (asla anında değişmez) | 400ms |
| 5 | Kâr yüzdesi büyük harflerle ekranda belirip söner: **"+%23 KÂR"** | 600ms (overlap) |

**Neden sayaç kritik:** Bakiyenin anında değişmesi, kazancı *bilgi* yapar. Sayarak artması, kazancı *deneyim* yapar. Bu, oyun tasarımındaki en ucuz dopamin kaldıracıdır.

### Ekstra Juice Anları

| An | Efekt |
|---|---|
| Nadir araç bulundu | Kart altın konturla parlar, ekran kenarları karararak kartı vurgular |
| Ekspertizde tuzak çıktı | Ekran kırmızı flaş + kâğıt yırtılma animasyonu + alçak uğursuz ses |
| Seviye atlandı | Galeri tabelası ekrana "TAK" diye çakılır, yeni unvan yazılır |
| Koleksiyon kartı kazanıldı | Kart döner ve "yeni" damgası basılır |
| Müzayede kazanıldı | Tokmak 3 kez vurur, ekran her vuruşta sarsılır |

> **Duygusal Etki:** *Haz.* Juice, oyuncunun aynı eylemi 200 kez yapmayı neden sıkıcı bulmadığının cevabıdır. Mekanik aynıdır; his her seferinde tazedir.

---

# 3. PSİKOLOJİK TUTUNDURMA VE SÜREKLİLİK

## 3.1 Kırık Halka: Dışsal Tetikleyici Yok

Bu, raporun **en kritik tek bulgusudur.** Nir Eyal'in Hook Model'i dört adımdan oluşur: *Tetikleyici → Eylem → Değişken Ödül → Yatırım.* Galeriden'de son üçü mevcut ve iyi tasarlanmış. **Birincisi tamamen yok.**

Oyuncu uygulamayı kapattığı an oyunla arasındaki tüm bağ kopuyor. Giriş serisi ₺200.000'e tırmanıyor (`psychology_engine.dart:86`) ama oyuncuya bunu hatırlatan hiçbir şey yok.

### Öneri: Yerel Bildirim Takvimi (backend gerektirmez)

`flutter_local_notifications` ile, tamamen cihaz üzerinde:

| Zaman | Bildirim türü | Örnek metin |
|---|---|---|
| Çıkıştan 3 saat sonra | Açık döngü | "Vitrindeki Bemeve'ye 2 yeni teklif geldi. Biri liste fiyatının üstünde." |
| Ertesi gün 09:00 | Seri koruma | "🔥 7. gün serindesin. Bugün giriş yaparsan ₺25.000 hazır." |
| Ertesi gün 20:00 (giriş yapılmadıysa) | Kayıp uyarısı | "Serin bu gece sıfırlanıyor. Bir dokunuş yeter." |
| Cumartesi 11:00 | Takvim etkinliği | "Hafta sonu açık oto pazarı açıldı! Alıcı akını başladı." |
| Randevu saati | VIP müşteri | "Kadir Bey randevusuna geliyor. 15 dakikan var." |
| 3 gün sessizlik | Geri kazanım | "Haydar Usta arıyor: 'Evladım galeri sensiz durgun. Sana bir araç ayırdım.'" |
| 7 gün sessizlik | Son kanca | "Dedenin Hacı Murat'ı hâlâ garajda bekliyor." |

**Etik sınır (önemli):** Günde en fazla 2 bildirim. Suçluluk dili yasak ("Bizi unuttun mu?"). Her bildirim **somut bir bilgi** taşımalı. Ayarlarda tam kontrol.

> **Duygusal Etki:** *Dünyanın devam ettiği hissi.* Oyuncu telefonuna baktığında galerisinin onsuz da yaşadığını görür. Bu, "bir oyun oynuyorum"dan "bir işletmem var"a geçiş anıdır.

---

## 3.2 D1 / D7 / D30 Kanca Haritası

### D1 — İlk 24 saat: "Yarım kalan iş"

| Kanca | Durum | Öneri |
|---|---|---|
| Haydar Usta hoşgeldin hediyesi | ✅ Bağlı (`psychology_engine.dart:131`) | Koru |
| Miras araç görevi | ✅ Var | Koru — ilk 5 dakikada tamamlanmalı |
| Açık döngü özeti | ✅ Bağlı (`getOpenLoopsSummary`) | Çıkışta göster + bildirime bağla |
| **Gece boyunca devam eden iş** | ❌ Yok | **Ekle:** ilk oturumun sonunda oyuncuya "yarın sabah teslim" bir onarım siparişi verilsin |
| **D1 bildirimi** | ❌ Yok | **Ekle** (§3.1) |

**Yeni öneri — "Gece Vardiyası Emaneti":** İlk oturum bitiminde bir NPC, oyuncuya bir araç emanet eder: *"Bunu sabaha kadar bitirebilir misin usta? Parasını peşin veririm."* Oyuncu ertesi gün girdiğinde iş bitmiş ve para hazır olur. Yarım kalmış iş, bitmiş işten daha güçlü bir geri dönüş sebebidir (Zeigarnik etkisi).

### D7 — İlk hafta: "Ritim ve kimlik"

| Gün | Olması gereken olay |
|---|---|
| 2 | İlk rakip karşılaşması — Star Motors aynı ilana teklif verir, oyuncu kaybeder (kontrollü near-miss) |
| 3 | İlk dramatik ikilem kartı (`dramatic_card_engine.dart` hazır) |
| 4 | Atölye açılır (Lv2) + ilk personel |
| 5 | İlk koleksiyon kartı düşer |
| 6 | İlk VIP randevusu (§3.3) |
| 7 | **Haftanın Galerisi sıralaması açıklanır** + ₺25.000 seri ödülü |

Kritik: bu 7 gün **elle tasarlanmış** olmalı, rastgele değil. Şu an 5-30 gün aralıklı rastgele tetikleyiciler (`game_time_mixin.dart:318-356`) ilk haftayı boş bırakabiliyor.

### D30 — İlk ay: "Ufuk ve kimlik"

| Kanca | Durum | Öneri |
|---|---|---|
| Seri ödülü | ✅ D30'da ₺200.000, sonrası doğrusal | Koru |
| **Kademe sistemi** | ❌ Yok | **Ekle** (§1.6) — asıl D30 çözümü budur |
| **Sezon (aylık meta)** | ❌ Yok | **Ekle:** her 30 gerçek günde bir "Sanayi Sezonu" — sezona özel araç, sezon sonu sıralaması, sezon rozeti |
| Koleksiyon albümü | ⚠️ Kısmi (`collection_album_engine.dart` 30 araçlık sabit hedef) | **Genişlet** (§3.4) |
| Prestij | ⚠️ Çarpan uygulanıyor (`game_market_mixin.dart:347`), giriş yolu belirsiz | Kademe sistemine bağla |

> **Duygusal Etki (D30):** *Yatırımın korunması.* 30 gün oynamış oyuncu artık ödül için değil, **inşa ettiğini kaybetmemek için** girer. İşte bu yüzden D30'un çözümü ödül değil, sahip olunacak bir şeydir.

---

## 3.3 Gün İçi Ritim: Oyuncuyu Aynı Gün İçinde Geri Getirmek

**Mevcut:** Müzayede penceresi 45-180 saniyede bir rastgele açılıyor (`auction_engine.dart:52-60`). Bu, oyun *açıkken* işe yarar ama oyuncu kapattığında hiçbir şey ifade etmez.

### Öneri A — Randevulu VIP Müşteri (gerçek saate bağlı)

Oyuncu bir VIP müşteriyle **randevu alır**: "Kadir Bey bugün 18:30'da galeriye gelecek."

| Özellik | Detay |
|---|---|
| Randevu penceresi | 15 dakika. Kaçırılırsa müşteri gider (ama itibar düşmez, sadece fırsat kaçar) |
| Ödül | Liste fiyatının %120-140'ı, nakit, pazarlıksız |
| Şart | Müşterinin aradığı segmentte hazır araç bulundurmak |
| Bildirim | Randevudan 15 dk önce |
| Sıklık | Günde 1-2, oyuncunun seçtiği saatlerde (!) |

**Kritik tasarım detayı:** Oyuncu randevu saatini **kendisi seçsin.** "Yarın kaçta müsaitsin?" diye sorulsun. Bu, oyunu oyuncunun gününe uydurur — tersi değil. Etik ve etkili.

> **Duygusal Etki:** *Sorumluluk ve heyecan.* "Saat 18:30'da bir işim var" hissi. Oyuncu bunu bir görev değil, bir **randevu** olarak yaşar. Fark, gönüllülüktedir.

### Öneri B — Günlük Sanayi Bülteni (sabah kancası)

Her gerçek sabah, tek ekranlık bir bülten:

```
╔══ SANAYİ BÜLTENİ · 16 AĞUSTOS ══════════════╗
║ 📈 BUGÜNÜN PİYASASI                          ║
║    SUV +%12  •  Sedan −%4  •  Klasik +%22   ║
║                                              ║
║ 🔥 GÜNÜN FIRSATI                             ║
║    Ankara'da 2008 Merso W-124 — ekspertizsiz║
║    ₺185.000 (piyasa ₺240.000?)              ║
║                                              ║
║ 🗣 SANAYİDEN DUYDUKLARIM                     ║
║    "Boğaziçi Otomotiv bu hafta 6 klasik     ║
║     araç almış. Bir şey biliyorlar."         ║
║                                              ║
║ ⚠️ SENİN GALERİN                             ║
║    2 ilan bayatladı  •  1 çek vadesi 3 gün  ║
╚══════════════════════════════════════════════╝
```

**"Sanayiden Duyduklarım" bölümü kritik:** Rakiplerin hareketlerini haber vererek piyasaya **asimetrik bilgi** katar. Oyuncu "klasik araç toplayayım mı?" diye düşünür. Bu, bir bülteni gazete olmaktan çıkarıp **istihbarat** yapar.

`MarketNewsModel` altyapısı zaten var (`dealership_model.dart:94`) ve 5 günde bir dönüyor — bülten formatına taşınmalı.

> **Duygusal Etki:** *Ritüel.* Sabah kahvesiyle bülten okumak, oyunu günlük hayata yerleştirir. En güçlü retention, alışkanlıktır — ödül değil.

### Öneri C — Süreli Müzayede (gerçek saate bağlı)

Rastgele 45-180 saniyelik pencereler yerine **sabit ve öngörülebilir** seanslar:

| Saat | Seans | Karakter |
|---|---|---|
| 12:30-12:45 | Öğle Arası Mezatı | Ekonomi & halk segmenti, hızlı |
| 19:00-19:20 | Akşam Ana Mezatı | Karışık, en yoğun |
| 23:00-23:15 | **Gece Sanayisi Mezatı** (§4.4) | Şaibeli, yüksek risk/ödül |

Öngörülebilirlik burada **doğru** tasarımdır: oyuncu planlayabilmeli. Değişkenlik *zamanlamada* değil, **çıkan araçta** olmalı — bu, davranışsal olarak merak üretir; rastgele zamanlama ise yalnızca hayal kırıklığı üretir.

> **Duygusal Etki:** *Kaçırma korkusunun sağlıklı hâli.* "Akşam 7'de mezat var" bilgisi, oyuncuya güç verir. "Ne zaman açılacağı belli değil" ise güçsüzleştirir.

---

## 3.4 Koleksiyon Tutkusu: Albümü Gerçek Bir Avcılığa Dönüştür

**Mevcut:** `collection_album_engine.dart` — 30 araçlık sabit hedef, `discoveredCarModelIds` listesi, kilometre taşı ödülleri. Altyapı iyi ama **avlanacak bir şey yok**: araç modelini bir kez görmek yeterli.

### Öneri: Dört Boyutlu Koleksiyon

**1. Model Albümü (mevcut, genişletilsin)**
`game_constants.dart`'ta 21 marka × ~4-6 model = **~90 araç modeli** tanımlı. Hedefi 30'dan 90'a çıkar; her marka için ayrı sayfa yap. "Tofaşk Serisi: 4/6" gibi.

**2. Nadir Renk Avı**
Şu an 6 sabit renk var (`market_engine.dart:465-468`). Ekle:

| Nadirlik | Örnek | Düşme oranı | Değer etkisi |
|---|---|---|---|
| Standart | Beyaz, siyah, gri | %85 | — |
| Nadir | Şampanya, bordo metalik | %12 | +%5 |
| **Efsanevi** | "Fabrika Çıkışı Sünger Sarısı", "Sipariş Üzeri Mor" | %3 | **+%18** ve albümde ayrı kart |

**3. Plaka Avcılığı** *(Türk pazarına özel, çok güçlü)*
Her aracın plakası olsun. Plaka desenleri toplanabilir:

| Desen | Örnek | Nadirlik | Etki |
|---|---|---|---|
| Standart | 34 KFR 128 | %90 | — |
| Tekrarlı | 34 AB 3333 | %6 | +%8 değer, koleksiyon kartı |
| Simetrik | 06 XY 1221 | %2,5 | +%12 değer |
| **Efsane** | 34 AA 0001 | %0,5 | **+%35 değer**, albümde altın kart, koleksiyoner müşterisi otomatik gelir |

Plaka aynı zamanda **şehir kimliği** taşır (34 İstanbul, 06 Ankara, 35 İzmir) — §4.1'deki Semt Hakimiyeti sistemine doğrudan bağlanır.

**4. Hikâyeli Araçlar** *(en değerlisi)*
`provenanceLog` alanı zaten var ve yazılıyor (`game_inventory_mixin.dart:102, 236, 745`). Bunu koleksiyona bağla: bir araç şu şartları taşıyorsa **"Efsane Araç"** olur ve satılsa bile albümde kalır:
- Barn find olarak alınmış **ve** restore edilmiş
- Nadir renk **ve** nadir plaka
- Bir VIP koleksiyonerden satın alınmış
- Oyuncunun rekor kârını yaptığı araç

Albümdeki kartta oyuncunun kendi hikâyesi yazsın: *"Gün 47'de Konya'daki bir samanlıktan çıkardım. 6 gün restore ettim. Kadir Bey'e ₺840.000'e sattım — o güne kadarki rekorum."*

> **Duygusal Etki:** *Nostalji ve mülkiyet.* Oyuncu 3 ay sonra albümü açtığında kendi hikâyesini okur. Bu, bir oyunu silinmez yapan tek şeydir: **oyuncunun kendi anıları.**

---

## 3.5 FOMO ve Near-Miss: Etik Çerçeve

**Mevcut:** Sistem şaşırtıcı derecede iyi kurulmuş:
- `getRandomFomoText()` bağlı (`interactive_negotiation_sheet.dart:50`, `listing_detail_screen.dart:106`)
- `getSuspenseNegotiationText()` bağlı (pazarlıkta bekleme metinleri)
- Rakip liderlik tablosunda near-miss mesajı (`rival_leaderboard_engine.dart:267-274`): *"Star Motors'u geçmek için sadece ₺X kaldı"*

### Etik sınır çizgisi (koruma tavsiyesi)

| ✅ Adil (koru & genişlet) | ❌ Manipülatif (asla ekleme) |
|---|---|
| "3 kişi bu ilanı inceliyor" — *simülasyon ama tutarlı* | Sahte gerçek zamanlı oyuncu sayısı |
| "₺12.000 farkla ikinci oldun" — *gerçek veri* | Kaybı abartan uydurma yakınlık |
| "Bu fırsat 15 dakika geçerli" — *gerçekten 15 dakika* | Süre dolunca gizlice uzatma |
| Seri kaybı uyarısı | Seriyi para karşılığı kurtarma dayatması |
| Kaçırılan fırsatı **gösterme** | Kaçırılanı sürekli hatırlatıp suçluluk üretme |

### Öneri: "Yakın Kaçırma"yı Bilgiye Çevir

Bir müzayedeyi/pazarlığı kaybedince, oyuncuya **ne yapsaydı kazanacağını** söyle:

> ❌ Kötü: *"Kaçırdın! Bir daha dene."*
> ✅ İyi: *"₺8.000 daha verseydin senindi. Boğaziçi Otomotiv aldı — bu ay 3. klasik araçları."*

Fark: birincisi hayal kırıklığı, ikincisi **ders.** Oyuncu ikincisinde oyuna kızmaz, kendine kızar ve daha iyi oynamak ister. Ayrıca rakip hakkında bilgi kazandığı için kayıp bile bir ödül taşır.

> **Duygusal Etki:** *Yapıcı pişmanlık.* En güçlü tekrar oynama motivasyonu "bir daha kaçırmam" cümlesidir. Ama bu, ancak oyuncu **neyi kaçırdığını anladığında** çalışır.

---

## 3.6 Offline Dönüşü: Ödülü Tersine Çevir

**Mevcut:** `offline_progression.dart:40` — 30 offline dakika = 1 oyun günü. Online 30 dakika = 15 oyun günü. **Offline 15 kat cezalı.**

### Öneri

| Parametre | Mevcut | Önerilen |
|---|---|---|
| Offline gün oranı | 30 dk = 1 gün | **4 dk = 1 gün** (online'ın yarısı) |
| Tavan | 12 saat | **16 saat** (bir gece uykusu + iş günü) |
| Offline verim | %100 pasif gelir | **%60 pasif gelir** ama teklif üretimi %100 |
| Boşta kalma | Yok | **8 saat sonra "galeri durgunlaştı"** — üretim %30'a düşer, geri dönmek için sebep |

Ve dönüşte **"Yokluğunda Neler Oldu?"** ekranı zenginleşsin (`getOfflineRecapSummary` bağlı, `game_core_provider.dart:103`):
- Kazanılan para (sayaç animasyonuyla)
- **Kaçırılan fırsatlar** (1-2 tane, adil dozda): *"Bir koleksiyoner Klasik aradı ama seni bulamadı."*
- Bekleyen teklifler
- Seri durumu

> **Duygusal Etki:** *Ödüllendirilmiş dönüş.* Oyuncu geri döndüğünde hediye paketi açmalı, fatura görmemeli. Bu ilk 10 saniye, oturumun geri kalanının tonunu belirler.

---

# 4. YENİLİKÇİ VE ÖZGÜN MEKANİKLER

## 4.1 Semt Hakimiyeti — Şehir Pazar Payı Savaşı

**Hazır altyapı:** `sellerCity` alanı listing modelinde var (`listing_model.dart:8`), 9 şehir tanımlı (`market_engine.dart:401`), ama **yalnızca ekspertiz ekranında metin olarak görünüyor** (`expertise_screen.dart:84`). Mekanik hiç yok.

### Tasarım

Şehir **6-8 semte** bölünsün. Her semtin karakteri olsun:

| Semt | Karakter | Talep profili | Rakip |
|---|---|---|---|
| **İkitelli Sanayi** | Esnaf, ticari araç | Ticari van, dizel, ucuz | Altınel Galeri |
| **Maslak Plaza** | Kurumsal, prestij | Premium sedan, SUV | Boğaziçi Otomotiv |
| **Bağcılar Oto Pazarı** | Halk, hacim | Ekonomi, hatchback | Yıldız Auto |
| **Nişantaşı Vitrin** | Lüks, gösteriş | Egzotik, süperspor | Anadolu Plaza |
| **Kadıköy Klasik Sokağı** | Koleksiyoner | Klasik, nadir | Star Motors |
| **Ankara Kızılay Hattı** | Memur, güvenilir | Aile sedanı, düşük tramer | (boş — fırsat) |

### Mekanik

```
Semt Pazar Payı = (senin o semtteki satışın) / (semtteki toplam satış)
```

| Pay | Unvan | Etki |
|---|---|---|
| %0-10 | Yabancı | — |
| %10-25 | Tanınan | Semtteki ilanlarda -%3 alış fiyatı |
| %25-50 | **Semt Sakini** | -%6 alış, ziyaretçi hızı +%15, semte özel müşteri arketipi |
| %50-75 | **Semtin Adamı** | -%10 alış, semtte kelepir ilan önceliği, rakip ilanlarına önizleme |
| %75+ | **Semt Hakimi** | -%15 alış, o semtte rakipler zayıflar, pasif "himaye geliri" |

**Rakip tepkisi (kritik):** Pay kaptıkça rakip **karşılık versin.**
- %25'i geçince: rakip fiyat kırar (o semtteki ilanlar %8 ucuzlar ama alıcılar da kırar)
- %50'yi geçince: rakip bir kampanya açar, 3 gün boyunca o semtte senin ziyaretçin -%20
- %75'i geçince: rakip **karalama kampanyası** yapar — itibarına -5, bir dramatik ikilem kartı tetiklenir: *"Boğaziçi Otomotiv, senin bir müşterine 'o galeri KM oynatır' demiş. Ne yapacaksın?"*

**Haftalık Semt Savaşı:** Her gerçek hafta bir semt "çekişmeli bölge" ilan edilsin. O hafta oradaki satışlar 2× pazar payı verir.

> **Duygusal Etki:** *Bölgesel gurur ve rekabet.* Harita üzerinde semtlerin senin renginle dolması, tycoon oyunlarının en tatmin edici görsel geri bildirimidir. Rakibin karşılık vermesi ise oyunu bir tabloya değil, bir **kavgaya** dönüştürür.

---

## 4.2 Gizli Araç Hikâyeleri — Torpido Gözü ve Geçmiş

**Hazır altyapı:** `provenanceLog` alanı var ve 3 yerden yazılıyor. Şu an yalnızca teknik kayıt (onarım geçmişi) tutuyor.

### Mekanik A — Torpido Buluntusu

Her araç alındığında %35 ihtimalle "torpido gözünü karıştır" seçeneği çıksın. İçinden çıkabilecekler:

| Buluntu | Oran | Etki |
|---|---|---|
| Boş / çöp | %30 | Küçük komik metin |
| Eski servis fişleri | %20 | Aracın gerçek bakım geçmişi açığa çıkar (bedava kısmi ekspertiz) |
| Unutulmuş para/altın | %12 | ₺500-15.000 |
| Eski kaset / CD | %10 | Kozmetik koleksiyon eşyası ("Sanayi Müzesi" vitrinine konur) |
| Aile fotoğrafı / mektup | %10 | **Hikâye zinciri başlar** (aşağıda) |
| Ruhsat fotokopisi | %8 | Önceki sahibin kim olduğu ortaya çıkar → §4.5'e bağlanır |
| Şüpheli evrak | %6 | Aracın karanlık geçmişi var — satarken risk, ama karaborsada değerli |
| **Anahtarlık / özel eşya** | %4 | Eski sahibi geri gelir ve **piyasa üstü fiyat** öder |

### Mekanik B — Hikâye Zinciri (Multi-Session Quest)

Aile fotoğrafı veya mektup çıktığında 3 aşamalı bir mini-hikâye başlar:

> **Aşama 1 (bulunduğu gün):** *"Torpidoda solmuş bir fotoğraf var. Arkasında 'Babamla, Ege sahili, 1994' yazıyor."*
> **Aşama 2 (2-4 gün sonra):** Bir müşteri gelir: *"Bu araç... babamın arabasıydı. Yıllar önce satmak zorunda kaldık."*
> **Aşama 3 (oyuncunun kararı):**
> - **Piyasa fiyatına sat** → normal kâr, hikâye biter
> - **Maliyetine ver** → ₺0 kâr, ama **itibar +8**, bu kişi kalıcı sadık müşteri olur, koleksiyon albümüne "Vefa" kartı düşer
> - **Fiyatı yükselt** (duygusal şantaj) → +%40 kâr, ama **itibar −12** ve §4.5 yankısı tetiklenir

> **Duygusal Etki:** *Merak, sonra ahlaki ağırlık.* Torpido gözünü karıştırmak saf merak dopamini — küçük, ucuz, sonsuz tekrarlanabilir. Hikâye zinciri ise oyuncuyu gerçek bir karar karşısında bırakır ve **hatırlanır.** Oyuncular bu anları arkadaşlarına anlatır; bu, satın alınamayacak pazarlamadır.

---

## 4.3 Barn Find Restorasyon Hattı — Yarım Kalmış Bir Vaat

**Hazır altyapı:** `isBarnFind` ve `isBarnFindRestored` alanları var; restore edilmiş barn find değerin +%40'ını alıyor (`car_model.dart:167-171`); restorasyon `game_inventory_mixin.dart:743-758`'de işleniyor; ilanlarda `[SAMANLIK KELEPİRİ]` etiketi düşüyor (`market_engine.dart:406`).

**Eksik olan:** Restorasyon *süreci* yok. Şu an normal onarımdan farksız — oysa bu, oyunun en duygusal potansiyele sahip mekaniği.

### Öneri: 5 Aşamalı Restorasyon Projesi

Barn find araçlar normal atölyeye girmesin; **ayrı bir "Restorasyon Hangarı"na** alınsın. Her aşama zaman + para + bazen nadir parça ister:

| Aşama | Süre | Gereksinim | Görsel geri bildirim |
|---|---|---|---|
| **1. Söküm & Temizlik** | 1 gün | ₺15.000 | Araç tozdan arınır, gerçek rengi ortaya çıkar |
| **2. Motor Revizyonu** | 2 gün | ₺45.000 + hurdalıktan uyumlu motor parçası | Motor çalışır — **ses efekti anı** |
| **3. Kaporta & Şasi** | 3 gün | ₺80.000 + Restoratör uzmanlığı varsa -%20 | Ezikler düzelir |
| **4. Boya** | 2 gün | ₺60.000 + **renk seçimi** (orijinal / özel) | Araç parlar |
| **5. İç Döşeme & Detay** | 1 gün | ₺35.000 | Tamamlanma animasyonu |

**Kritik tasarım kararları:**

1. **Yarıda bırakılabilsin.** Oyuncu 3. aşamada durup satabilsin (kısmi değer artışı). Bu, sunk cost'u sömürmeden bir seçim sunar.
2. **Orijinal Parça Bonusu:** Her aşamada "orijinal parça bul" (pahalı, hurdalıkta ara, zaman alır) veya "muadil tak" (ucuz, hızlı) seçeneği. Tümü orijinal olursa **"Numaratör Orijinal"** rozeti + %25 ek değer + koleksiyon kartı.
3. **Öncesi/Sonrası kartı:** Restorasyon bitince oyuncuya iki panelli bir kart üretilsin — solda samanlıktan çıkan hâli, sağda tamamlanmış hâli. Paylaşılabilir (§5.2).
4. **Restoratör uzmanlığı** (`SpecializationPath.restorer`) burada gerçek anlam kazansın: %20 daha ucuz, %30 daha hızlı, orijinal parça bulma şansı ×2.

> **Duygusal Etki:** *Emeğin görünür karşılığı — oyunun en güçlü tek anı.* Bir enkazı 9 gün ve ₺235.000 harcayarak pırıl pırıl bir klasiğe dönüştürmek ve "Öncesi/Sonrası" kartını görmek, tycoon türünün sunabileceği en saf tatmin duygusudur. Bu mekanik doğru yapılırsa oyunun **imza deneyimi** olur.

---

## 4.4 Gece Sanayisi ve Yeraltı Buluşmaları

**Hazır altyapı:** `inGameTime => DateTime.now()` (`dealership_model.dart:142`) — gerçek saat erişilebilir ama **hiçbir yerde kullanılmıyor.** `parallax_skyline_painter.dart` bir `hour` parametresi alıyor ama sabit 21 geçiliyor. Karaborsa sistemi (`black_market_screen.dart`) var ama zamandan bağımsız.

Bu, neredeyse bedava bir mekanik: gerçek saat zaten elde.

### Tasarım: 22:00 – 04:00 "Gece Vardiyası"

Gece saatlerinde arayüz **görsel olarak değişsin** (mevcut "Gece Vardiyası" teması zaten var — `theme_provider.dart`) ve şu içerikler açılsın:

| Etkinlik | Saat | Mekanik | Risk |
|---|---|---|---|
| **Çıkmacılar Mezatı** | 22:00-00:00 | Hurdalık parçaları %40-60 ucuz, ama parça durumu gizli | %20 ihtimalle "bu parça tutmadı" |
| **Gece Sanayisi Modifiye Yarışı** | 23:00-01:00 | Kendi modifiye ettiğin aracı yarıştır — motor/şanzıman/tuning skoruna göre | Kaybedersen araç hasar alır; kazanırsan ₺ + prestij + "Sokak Efsanesi" rozeti |
| **Kapalı Devre Mezat** | 00:00-02:00 | Yalnızca davetiye ile — itibar ≥70 **veya** NPC ilişkisi ≥70 gerekir. Nadir/egzotik araçlar | Gerçek değer gizli, ekspertiz yok |
| **Şafak Teslimatı** | 03:00-04:00 | Karaborsa aracı devretme — en yüksek marj | Polis riski %25-35 (`black_market_car_model.dart` hazır) |

### Gece Ekonomisi Dengesi

Gece her şey **daha ucuz ama daha az bilgiyle.** Gündüz güvenli ve şeffaf, gece riskli ve kârlı. Bu, oyuncunun kişiliğini ifade etmesine izin verir:

> "Ben dürüst esnafım, geceleri kapalıyım." → itibar yolu, sadık müşteri, VIP randevular
> "Gece kuşuyum." → yüksek marj, karaborsa, düşük itibar, gerilim

**Gece NPC'leri** (`npcRelationships` alanı zaten hazır — `golge_ibrahim`, `cikmaci_ibo` tanımlı):
- **Çıkmacı İbo** — parça, güvenilir ama pahalı
- **Gölge İbrahim** — karaborsa aracı, ilişki 70+ olmadan riskli teklifler verir
- **Vlogger Berk** — gece yarışlarını çeker, kazanırsan itibar +, kaybedersen küçük düşme

> **Duygusal Etki:** *Yasak heyecanı ve kimlik seçimi.* Gece açılan farklı bir oyun olması, oyuncuya "sadece bana ait bir dünya" hissi verir. Ayrıca gerçek hayattaki gece kullanıcılarına (mobil oyunların en yoğun saati 21:00-24:00) özel içerik sunar — retention açısından doğrudan ölçülebilir kazanç.

---

## 4.5 Müşteri İtibar Yankısı — Yalanın Bedeli Zamana Yayılsın

**Mevcut:** `evaluatePlayerFraudInspection` (`negotiation_engine.dart:57-98`) — müşteri satış anında ekspertiz yaparsa yakalanırsın: ₺10.000 ceza + itibar -15. **Ama sonuç anında ve tek seferlik.**

**Sorun:** Yalan söylemenin bedeli anında ödenip bitiyor. Gerçek hayatta esnaflıkta olan şey ise **yankı**: söylenti yayılır, müşteri geri gelir, mahkeme açılır.

### Tasarım: Üç Dalgalı Yankı Sistemi

**Dalga 1 — Anında (mevcut):** %X ihtimalle yakalanma, ceza + itibar kaybı.

**Dalga 2 — Gecikmeli Keşif (3-10 gün sonra):** Satış anında yakalanmadıysan bile, alıcı sonradan öğrenebilir:

| Sonuç | Oran | Etki |
|---|---|---|
| Hiç fark etmez | %55 | Temiz kurtuldun (ama "Kirli Sicil" sayacın +1) |
| Söylenir | %25 | İtibar -5, o semtte ziyaretçi hızı -%10, 5 gün |
| **Kapıya dayanır** | %12 | Dramatik ikilem kartı: *"Adam galerinin önünde bağırıyor. Para iade et / Kapıyı kapat / Polisi ara"* |
| **Mahkemeye verir** | %8 | 7 gün sonra dava: satış bedelinin %40'ı tazminat + itibar -20 + 3 gün "haciz" damgası |

**Dalga 3 — Sicil (kalıcı):** "Kirli Sicil" sayacı bir eşiği geçince kalıcı sonuçlar:

| Kirli Sicil | Sonuç |
|---|---|
| 3+ | Bazı müşteri arketipleri (Şüpheci Memur, Aile Babası) sana hiç gelmez |
| 5+ | Ekspertiz istasyonları "bu galeriye rapor vermiyoruz" der — kurumsal ekspertiz kapanır |
| 8+ | Sanayi Odası'ndan ihraç, semt hakimiyeti kaybı, **yalnızca karaborsa müşterisi** kalır |

### Ve Karşı Kutup: Dürüst Esnaf Prestiji

Simetri olmadan ahlaki sistem çalışmaz. Dürüstlüğün de birikimli bir ödülü olmalı:

| Temiz Satış Serisi | Ödül |
|---|---|
| 10 | **"Sözü Senet"** rozeti — müşterilerin %10'u pazarlıksız liste fiyatı öder |
| 25 | **"Mahallenin Güvendiği"** — sadık müşteri dönüş oranı 2×, `loyalCustomerNames` aktifleşir |
| 50 | **"Sanayinin Namuslu Adamı"** (`rpgTitle`'da zaten tanımlı!) — VIP randevu sıklığı 2×, ekspertiz maliyeti -%30 |
| 100 | **"Duayen"** — rakip galeriler senden araç almaya başlar (B2B gelir kanalı açılır) |

**Kritik denge kuralı:** Dürüst yol **daha yavaş ama daha istikrarlı**, hileli yol **daha hızlı ama volatil** olmalı. İkisi de kazanan bir strateji olmalı — aksi hâlde ahlaki seçim değil, optimizasyon problemi olur.

> **Duygusal Etki:** *Ahlaki ağırlık ve kimlik.* Oyuncu artık "kârlı mı?" değil, **"ben nasıl bir galericiyim?"** diye sorar. Bir tycoon oyununun karakter oyununa dönüştüğü an budur. Ve yakalandığında hissedeceği şey ceza değil — **utanç.** Bu çok daha güçlü bir duygudur.

---

## 4.6 Ek Özgün Mekanikler (Aklınıza Gelmeyenler)

### 4.6.1 Konsinye & Emanet — Sermayesiz Ticaret

Başkalarının aracını **satın almadan** vitrine koy:

| Özellik | Detay |
|---|---|
| Sermaye | ₺0 — araç senin değil |
| Kâr | Satış bedelinin %8-15'i komisyon |
| Risk | Araç garaj slotu işgal eder; satılmazsa 14 gün sonra sahibi geri alır ve **itibar -3** |
| Şart | Araç sahibi NPC ile ilişki ≥60 |
| Tuzak | Emanet araçta kusur çıkarsa sorumluluk **sende** — ekspertiz yapmadan almak riskli |

**Neden güçlü:** Oyunun erken safhasında para sıkıntısı çeken oyuncuya **sermayesiz oynama yolu** açar. Geç safhada ise garaj slotu optimizasyonu problemi yaratır.

> **Duygusal Etki:** *Zekâ gururu.* "Param yokken de iş yapabiliyorum." Kaynak kıtlığını yaratıcılığa çeviren mekanikler, oyuncunun kendini akıllı hissettirir.

### 4.6.2 Takas Zinciri — Türk Galericiliğinin Kalbi

Türkiye'de araç ticaretinin yarısı takasla döner ve oyunda hiç yok.

Müşteri: *"Ben bunu alırım ama benim aracımı da alman lazım."*

- Oyuncu takas aracını **ekspertiz etmeden** görür (sadece dış görünüş + beyan)
- Takas farkı pazarlığa açık
- Zincir kurulabilir: aldığın takas aracı başka bir müşterinin takasına gider
- **3+ zincirli takas** tamamlanınca **"Takas Ustası"** başarımı + XP bonusu

> **Duygusal Etki:** *Satranç zevki.* Takas zinciri kurmak, doğrusal alım-satımdan tamamen farklı bir zihinsel oyun. Oyuncu bir tüccar gibi değil, bir **stratejist** gibi düşünür.

### 4.6.3 Sanayi Dedikodu Hattı — Asimetrik Bilgi Pazarı

Bilgi bir ticaret malı olsun. NPC'lerden bilgi satın al:

| Bilgi | Kaynak | Fiyat | İçerik |
|---|---|---|---|
| Piyasa tüyosu | Çaycı Necati | ₺2.000 | "Önümüzdeki hafta SUV talebi patlayacak" (%75 doğru) |
| Rakip istihbaratı | Vlogger Berk | ₺8.000 | "Boğaziçi klasik topluyor" (%85 doğru) |
| Kelepir ihbarı | Çıkmacı İbo | ₺15.000 | Belirli bir kelepir ilanın koordinatı (%95 doğru) |
| Gizli kusur | Usta Selim | ₺5.000 | Hedef aracın en kötü parçası açığa çıkar (%100 doğru) |

**Kritik:** Bilgi bazen **yanlış** olsun. %75 doğruluk, bilgiyi bir bahis hâline getirir ve NPC ilişkisi (`npcRelationships`) doğruluk oranını yükseltsin — ilişki 90+ ise %95.

> **Duygusal Etki:** *İçeriden olma hissi.* "Ben bir şey biliyorum" duygusu, piyasa oyunlarının en güçlü kancasıdır. Ve yanlış çıktığında oyuncu sisteme değil, **kaynağa** kızar — bu, NPC'leri gerçek karakterlere dönüştürür.

### 4.6.4 Araç "Ruhu" — Görünmeyen Yedinci İstatistik

Her aracın gizli bir **karakter** özelliği olsun (oyuncu göremez, sadece hisseder):

| Ruh | Tezahür |
|---|---|
| **Uğurlu** | Bu araç hep beklenenden yüksek teklif alır |
| **Uğursuz** | Onarımlar hep bir masraf daha çıkarır |
| **Sadık** | Kiralamada hiç bozulmaz |
| **Huysuz** | Test sürüşlerinde hep bir sorun çıkar |
| **Efsane** | Nadir; her etkileşiminde küçük pozitif sürprizler |

Oyuncu 3-4 etkileşimden sonra sezmeye başlar. Araç satılınca `provenanceLog`'a yazılır: *"Bu araba uğurluydu."*

> **Duygusal Etki:** *Batıl inanç ve bağlanma.* Oyuncular araçlarına isim takmaya başlar. Ölçülemez ama en derin bağlanma mekanizmalarından biridir — insan beyni örüntü arar ve bulduğunda sahiplenir.

### 4.6.5 Hava Durumu & Yol Testi

Gerçek saat gibi, hava durumu da neredeyse bedava bir mekanik:

| Hava | Etki |
|---|---|
| Yağmur | Ziyaretçi -%30, ama yıkama işi +%50; test sürüşlerinde fren/lastik sorunları ortaya çıkar |
| Kar | SUV talebi +%60, spor -%40; yolda kalma → çekici işletmesi geliri patlar |
| Sıcak | Klima arızası şikâyetleri; cabrio/spor talebi +%35 |
| Sisli | Ekspertizde "göz kararı" doğruluğu -%20 |

> **Duygusal Etki:** *Canlı dünya.* Oyun dışarıdaki havayla uyumlandığında (gerçek hava API'si opsiyonel), oyuncu oyunun kendisiyle aynı dünyada olduğunu hisseder.

### 4.6.6 Çırak Yetiştirme & Hanedan

**Hazır altyapı:** `dynastyGeneration` ve `dynastyHistoryLog` alanları var (`dealership_model.dart:83-84`), kullanılmıyor. `CharacterOrigin` sistemi zaten miras temasıyla açılıyor (Dede Hasan Usta'nın Tofaşk'ı).

**Tasarım:** Oyuncu bir çırak alsın. Çırak zamanla öğrenir (oyuncunun *nasıl oynadığına göre*):
- Oyuncu hep dürüstse → çırak dürüst usta olur
- Oyuncu hep hile yapıyorsa → çırak da hilekâr olur, hatta **bir gün oyuncuyu dolandırır**

Prestij döngüsünde (yeniden başlama) çırak, **yeni nesil oyuncu karakteri** olur ve önceki neslin özelliklerini miras alır. `dynastyHistoryLog` her nesli kaydeder.

> **Duygusal Etki:** *Süreklilik ve miras.* "Dedemden aldım, torunuma bırakıyorum." Oyunun açılış teması (miras) kapanış temasına dönüşür. Bu, oyuna dairesel bir anlam kazandırır ve prestij döngüsünü mekanik bir sıfırlama olmaktan çıkarıp **anlatısal bir olay** yapar.

---

# 5. SOSYAL VE REKABETÇİ VİZYON

## 5.1 Backend'siz Asenkron Sosyallik (Faz 1 — hemen uygulanabilir)

**Mevcut:** `RivalLeaderboardEngine` tamamen deterministik NPC üretiyor (5 sabit arketip, `rival_leaderboard_engine.dart:78-124`). Gerçek oyuncu verisi yok.

Gerçek sosyal katman backend ister — ama **backend'siz de çok yol alınabilir:**

### Öneri A — Hayalet Veri (Ghost Data)
Oyuncunun kendi geçmiş performansı rakip olarak dönsün:
> *"Geçen haftaki sen: ₺840.000 ciro. Bu hafta: ₺712.000. **Kendi rekorunun ₺128.000 gerisindesin.**"*

Bu, sıfır altyapıyla gerçek rekabet hissi üretir ve psikolojik olarak yabancı rakipten daha etkilidir.

### Öneri B — Zenginleştirilmiş NPC Rakipler
Mevcut 5 NPC'yi **karaktere** dönüştür:
- Her rakibin bir **stratejisi** olsun (Boğaziçi = premium, Yıldız Auto = hacim/ucuz)
- Rakipler oyuncunun stratejisine **tepki versin** (§4.1)
- Haftalık "rakip hamlesi" bildirimi: *"Star Motors 3 klasik araç aldı. Klasik piyasası ısınıyor."*
- Rakiplerle **doğrudan etkileşim**: araç takası, ortak müzayede kartelı, fiyat savaşı

> **Duygusal Etki:** *Kişiselleşmiş rekabet.* İsimsiz bir sıralama numarası değil, **tanıdığı bir düşman.** Oyuncular NPC rakiplerinden nefret etmeyi sever.

## 5.2 Paylaşılabilir Vitrin Kartı (Faz 1 — düşük efor, yüksek organik erişim)

Backend gerekmez; cihazda görsel üretip paylaş:

| Kart türü | İçerik | Tetikleyici |
|---|---|---|
| **Restorasyon Kartı** | Öncesi/Sonrası, süre, maliyet | Barn find restorasyonu tamamlandı |
| **Rekor Satış Kartı** | Araç, kâr, yüzde, galeri adı ve logosu | Yeni kâr rekoru |
| **Vitrin Kartı** | 3 aracın izometrik görüntüsü + galeri kimliği | Manuel |
| **Koleksiyon Kartı** | Albüm ilerlemesi + nadir bulgular | Milestone |
| **Sezon Özeti** | Aylık ciro, unvan, semt haritası | Sezon sonu |

Neo-Brutalist estetik burada **büyük avantaj**: kalın kontur, yüksek kontrast, sıfır blur — sosyal medya küçük resminde (thumbnail) mükemmel okunur. Bu, oyunun görsel dilinin doğrudan pazarlama varlığına dönüşmesidir.

> **Duygusal Etki:** *Gösterme arzusu.* Oyuncu emeğinin görünür bir kanıtını üretir. Bu, hem tatmin hem de bedava kullanıcı kazanımıdır.

## 5.3 Sanayi Odası / Lonca (Faz 2 — backend gerektirir)

| Özellik | Detay |
|---|---|
| Üye sayısı | 10-20 oyuncu |
| Ortak hedef | Haftalık lonca cirosu → herkese ödül |
| Lonca deposu | Üyeler yedek parça bağışlar, ihtiyacı olan alır |
| Lonca ustası | Haftada 1 kez bir üyenin aracına bedava uzman onarımı |
| Lonca savaşı | İki lonca arasında semt hakimiyeti yarışı (§4.1 ile birleşir) |

## 5.4 Haftalık Lig ve Meta Vitrin (Faz 2)

| Lig | Terfi/Tenzil |
|---|---|
| Kaldırım Ligi → Sanayi Ligi → Plaza Ligi → Baron Ligi | Her hafta ilk %20 terfi, son %20 tenzil |

**Meta Vitrin:** Oyuncular vitrinlerini sergiler; başkaları **teklif verebilir.** Oyuncular arası araç ticareti — ekonomi enflasyonu riski taşır, bu yüzden:
- Yalnızca **komisyon karşılığı** (%5 sistem kesintisi — para emici)
- Fiyat bandı sınırlı (piyasa değerinin %70-130'u)
- Günde en fazla 2 işlem

> **Duygusal Etki:** *Sosyal statü.* Bir oyuncunun vitrinini başka birinin görüp teklif vermesi, koleksiyon avcılığına gerçek bir izleyici kazandırır. Koleksiyon ancak **görülebilirse** anlamlıdır.

---

# 6. EYLEME DÖKÜLEBİLİR ÖNCELİKLENDİRME MATRİSİ

**Ölçek:** Etki 1-5 (oyuncu deneyimine katkı) · Efor 1-5 (geliştirme yükü) · **Ö/E = Etki/Efor oranı** (yüksek = önce yap)

## 6.1 HIZLI KAZANIMLAR (Quick Wins) — 1-2 haftalık iş

| # | Öneri | Bölüm | Etki | Efor | Ö/E |
|---|---|---|---|---|---|
| Q1 | **Ses kütüphanesi** (12 ses + audioplayers) | §2.1 | 5 | 2 | **2,50** |
| Q2 | **Bakiye sayaç animasyonu + para uçuş efekti** | §2.6 | 4 | 1 | **4,00** |
| Q3 | **Kâr marjı her kartta görünür + ısı şeridi** | §2.5 | 5 | 2 | **2,50** |
| Q4 | **Bağlamsal "sıradaki adım" butonları** | §2.4 | 4 | 1 | **4,00** |
| Q5 | **Haptik dilbilgisi + global dokunma haptiğini kaldır** | §2.2 | 3 | 1 | **3,00** |
| Q6 | **Renk anlam sözleşmesi + tek palet otoritesi** | §2.3 | 3 | 2 | 1,50 |
| Q7 | **Offline oranını düzelt** (30dk→4dk/gün, tavan 16sa) | §3.6 | 4 | 1 | **4,00** |
| Q8 | **Sadık müşteri teklifini bağla** (`generateLoyalCustomerOffer` yazılı, çağrılmıyor) | §1.4 | 4 | 1 | **4,00** |
| Q9 | **Ekspertiz maliyetini araç değerine oranla** (%1,2) | §1.3 | 4 | 1 | **4,00** |
| Q10 | **İflas kurtarmasını düzelt** (borç silme → yapılandırma) | §1.5 | 3 | 1 | **3,00** |
| Q11 | **Torpido gözü buluntusu** (basit tablo) | §4.2 | 4 | 2 | 2,00 |
| Q12 | **Plaka sistemi + nadirlik** | §3.4 | 4 | 2 | 2,00 |
| Q13 | **Nadir renk katmanı** | §3.4 | 3 | 1 | **3,00** |
| Q14 | **Near-miss'i bilgiye çevir** ("₺8.000 daha verseydin…") | §3.5 | 4 | 1 | **4,00** |
| Q15 | **Toplu işlem butonları** (tümünü yıka / listele) | §2.4 | 3 | 1 | **3,00** |
| Q16 | **Çay/sigara pazarlık eylemleri** | §1.4 | 3 | 2 | 1,50 |
| Q17 | **Amortisman:** bayat ilan değer kaybı (`daysListed` hazır) | §1.2 | 3 | 1 | **3,00** |

**Toplam tahmini süre: 2-3 hafta.** Bu 17 madde tek başına oyunun "his" kalitesini bir sınıf yukarı taşır.

---

## 6.2 BÜYÜK OYUN DEĞİŞTİRİCİLER (Game Changers) — 1-2 aylık iş

| # | Öneri | Bölüm | Etki | Efor | Ö/E |
|---|---|---|---|---|---|
| **G1** | **Yerel bildirim altyapısı + kanca takvimi** | §3.1 | **5** | 2 | **2,50** |
| **G2** | **Çift katmanlı takvim** (operasyon günü + gerçek sezon) | §1.1 | **5** | 3 | 1,67 |
| **G3** | **Doluluk katsayısı** — pasif geliri aktifliğe bağla | §1.2 | **5** | 3 | 1,67 |
| **G4** | **Barn Find Restorasyon Hattı** (5 aşama + Öncesi/Sonrası kartı) | §4.3 | **5** | 4 | 1,25 |
| **G5** | **Semt Hakimiyeti** (6-8 semt + rakip tepkisi) | §4.1 | **5** | 4 | 1,25 |
| **G6** | **Müşteri İtibar Yankısı** (3 dalga + dürüst esnaf prestiji) | §4.5 | **5** | 3 | 1,67 |
| **G7** | **Kademe sistemi** (Lv 5-13 içerik uçurumunu kapat) | §1.6 | **5** | 3 | 1,67 |
| **G8** | **Gece Sanayisi** (gerçek saate bağlı 4 etkinlik) | §4.4 | 4 | 3 | 1,33 |
| **G9** | **Üç kademeli ekspertiz** (göz kararı / hızlı bakı / tam) | §1.3 | 4 | 3 | 1,33 |
| **G10** | **Araç Dosyası tam ekran bağlamı** (sekmeli, 6 geçiş → 1) | §2.4 | 4 | 3 | 1,33 |
| **G11** | **Randevulu VIP müşteri** (oyuncu saati seçiyor) | §3.3 | 4 | 3 | 1,33 |
| **G12** | **Günlük Sanayi Bülteni** + dedikodu bölümü | §3.3 | 4 | 2 | **2,00** |
| **G13** | **Koleksiyon albümü genişletme** (90 model + 4 boyut) | §3.4 | 4 | 3 | 1,33 |
| **G14** | **Sabit saatli müzayede seansları** | §3.3 | 3 | 2 | 1,50 |
| **G15** | **Takas zinciri** | §4.6.2 | 4 | 3 | 1,33 |
| **G16** | **Hikâye zinciri** (torpido → müşteri → ahlaki karar) | §4.2 | 4 | 3 | 1,33 |
| **G17** | **Paylaşılabilir kart üretimi** | §5.2 | 4 | 2 | **2,00** |
| **G18** | **Enflasyon + vergi dilimi** (para emici) | §1.2 | 4 | 2 | **2,00** |
| **G19** | **Üç aşamalı batma** (sıkışma → icra → konkordato) | §1.5 | 4 | 3 | 1,33 |
| **G20** | **Sanayi Dedikodu Hattı** (asimetrik bilgi pazarı) | §4.6.3 | 4 | 2 | **2,00** |

---

## 6.3 GELECEK VİZYONU (Long-term) — 3+ ay / altyapı gerektirir

| # | Öneri | Bölüm | Etki | Efor | Not |
|---|---|---|---|---|---|
| L1 | **Backend + gerçek oyuncu liderlik tabloları** | §5.4 | 5 | 5 | Tüm sosyal katmanın önkoşulu |
| L2 | **Meta Vitrin** (oyuncular arası araç ticareti) | §5.4 | 5 | 5 | Ekonomi denge riski yüksek — komisyon + fiyat bandı şart |
| L3 | **Sanayi Odası / Lonca** | §5.3 | 4 | 5 | L1'e bağımlı |
| L4 | **Haftalık lig + terfi/tenzil** | §5.4 | 4 | 4 | L1'e bağımlı |
| L5 | **Hanedan & Çırak sistemi** (prestij döngüsü) | §4.6.6 | 4 | 4 | `dynastyGeneration` altyapısı hazır |
| L6 | **Sezon sistemi** (30 günlük meta, sezona özel araç) | §3.2 | 5 | 4 | D30+ retention'ın asıl çözümü |
| L7 | **İthalat & Gümrük hattı** | §1.6 | 3 | 4 | Kademe 9 içeriği |
| L8 | **Şehir haritası görselleştirmesi** (semt hakimiyeti haritası) | §4.1 | 4 | 4 | G5'in görsel karşılığı |
| L9 | **Hava durumu sistemi** | §4.6.5 | 3 | 3 | Gerçek API opsiyonel |
| L10 | **Araç "Ruhu" gizli istatistiği** | §4.6.4 | 3 | 2 | Düşük efor ama diğer sistemler oturduktan sonra anlamlı |
| L11 | **Konsinye & Emanet** | §4.6.1 | 4 | 3 | Kademe 7 içeriği |
| L12 | **Franchise verme** (rakip galerilere bayilik) | §1.6 | 3 | 4 | Kademe 11 içeriği |

---

## 6.4 Önerilen 90 Günlük Dalga Planı

### Dalga 1 (Hafta 1-3) — "His"
> Q1-Q17 (tüm hızlı kazanımlar) + G1 (bildirim altyapısı)

**Hedef:** Oyun aynı oyun ama **çok daha iyi hissettiriyor.** Ses var, para uçuyor, kâr görünüyor, tıklama sayısı yarıya indi, bildirimler çalışıyor.
**Ölçülecek:** Oturum süresi, D1 retention.

### Dalga 2 (Hafta 4-7) — "Denge"
> G2 (takvim), G3 (doluluk), G7 (kademe), G9 (ekspertiz), G18 (enflasyon), G19 (batma)

**Hedef:** Ekonomi gerçekten çalışıyor. Ana döngü kârlı, pasif gelir kaldıraç, seviye 4 uçurumu kapandı, risk gerçek.
**Ölçülecek:** D7 retention, ana döngü/pasif gelir oranı, Lv5+ oyuncu yüzdesi.

### Dalga 3 (Hafta 8-11) — "Kimlik"
> G4 (restorasyon), G5 (semt), G6 (itibar yankısı), G8 (gece), G16 (hikâye zinciri)

**Hedef:** Oyun bir kimlik oyununa dönüşüyor. Oyuncu artık "nasıl bir galericiyim?" sorusunu cevaplıyor.
**Ölçülecek:** D30 retention, tekrar oynanabilirlik, sosyal paylaşım.

### Dalga 4 (Hafta 12+) — "Toplum"
> G11, G12, G13, G17, G20 + L6 (sezon) → sonra L1 (backend)

**Hedef:** Günlük ritim yerleşiyor, koleksiyon derinleşiyor, sosyal katmana zemin hazırlanıyor.

---

# 7. ÖLÇÜM PLANI

Telemetri olmadan bu raporun hiçbir önerisi doğrulanamaz. Minimum ölçüm seti:

| Metrik | Neden kritik | Hedef |
|---|---|---|
| D1 / D7 / D30 retention | Temel sağlık | %40 / %18 / %8 (tycoon türü ortalaması üstü) |
| Ortalama oturum süresi | Juice ve akış etkisi | 12+ dakika |
| Günlük oturum sayısı | Kanca sistemi etkisi | 2,5+ |
| **Ana döngü geliri / pasif gelir oranı** | §1.2'nin doğrudan testi | 1,5-3,0 arası (şu an tahmini 0,05) |
| Ekspertiz yapma oranı | §1.3'ün doğrudan testi | %55-75 (şu an tahmini ~%95) |
| Seviye 5+ ulaşan oyuncu % | §1.6 uçurumunun testi | %35+ |
| Bildirimden dönüş oranı | §3.1 etkisi | %12+ |
| Restorasyon tamamlama oranı | §4.3 etkisi | Başlayanların %60'ı |
| Kirli Sicil dağılımı | §4.5'in denge testi | %30 hilekâr / %70 dürüst civarı (tek yol domine etmemeli) |
| Semt pazar payı dağılımı | §4.1 dengesi | Hiçbir semt %5'ten az oynanmamalı |

---

# 8. RİSKLER VE UYARILAR

| Risk | Etki | Azaltma |
|---|---|---|
| **Aşırı sistem yükü** — oyun zaten 28 ekran, yeni mekanikler karmaşıklığı patlatabilir | Yüksek | Her yeni sistem bir kademede **kilitli** açılsın (§1.6). Oyuncu her şeyi aynı anda görmesin. |
| **Doluluk katsayısı oyuncuyu cezalandırabilir** | Orta | Alt sınır %25'ten aşağı inmesin; "cezalandırma" değil "ödüllendirme" olarak çerçevele ("Aktif oynadın, işletmen %160 verimde!") |
| **Bildirim yorgunluğu** | Yüksek | Günde maks 2, her biri somut bilgi taşısın, tam kullanıcı kontrolü |
| **Gece içeriği erişilemez olabilir** | Orta | Gece etkinliklerinin gündüz dengi olsun (daha düşük ödülle); kimse saat 3'te oynamaya zorlanmasın |
| **Meta vitrin ekonomiyi patlatır** | Yüksek | %5 komisyon, fiyat bandı %70-130, günlük işlem limiti; **launch'ta değil, ekonomi oturduktan sonra** |
| **İtibar yankısı çok sert olabilir** | Orta | Kirli Sicil eşikleri geniş tutulsun; "temizlenme" yolu olsun (10 dürüst satış = 1 kirli sicil silinir) |
| **Palet birleştirme regresyon riski** | Düşük | Deprecate önce, kaldırma sonra; ekran ekran geçiş |
| **Ses dosyaları uygulama boyutunu artırır** | Düşük | 12 ses, sıkıştırılmış OGG, toplam <400KB |

---

# 9. KAPANIŞ: ÜÇ CÜMLELİK ÖZET

1. **Galeriden'in içerik hacmi ve görsel kimliği güçlü; sorun beş yapısal denge kararında** — zaman ölçeği, pasif/aktif dengesi, risk mekaniklerinin dişsizliği, dışsal tetikleyici yokluğu ve Seviye 4 içerik uçurumu.

2. **En yüksek getirili üç hamle sırasıyla:** zaman mimarisini gerçek takvime bağlamak (tek sabit, beş sistemi düzeltir), yerel bildirim altyapısı kurmak (D1'in tek sert limiti), ve pasif geliri aktif oynanışa bağlamak (tycoon türünün temel sözleşmesi).

3. **Oyunun imza deneyimi olmaya en yakın mekanik Barn Find Restorasyon Hattı** — bir enkazı 9 gün emek vererek klasiğe dönüştürmek ve "Öncesi/Sonrası" kartını görmek; bu, oyuna hem duygusal doruk hem de paylaşılabilir bir kimlik kazandırır.

---

*Bu rapor kod değişikliği içermez. Tüm satır referansları 16 Ağustos 2026 tarihli `main` branch (commit `1e549fd`) durumuna göredir.*
