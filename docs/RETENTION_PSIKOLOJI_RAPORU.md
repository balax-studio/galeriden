# Galerisinden — Davranışsal Psikoloji, Kanca Modeli & Retention Raporu

**Tarih:** 15 Ağustos 2026 · **Sürüm:** 1.2.0 · **Branch:** `main`
**Konu:** Dopamin döngüsü mimarisi, Hook Model denetimi, D1/D7/D30 tutundurma ve "bir tur daha" hissini üreten ileri seviye oynanış özellikleri.
**Yöntem:** `lib/` altındaki 131 Dart dosyasının statik analizi. Her bulgu `dosya:satır` referanslıdır. Runtime telemetrisi yok — §7 bunun için bir ölçüm planı önerir.
**Kapsam:** Yalnızca rapor. Kod değişikliği yapılmadı.

---

## 0. Yönetici Özeti

Galerisinden'in retention sorunu **eksik mekanik** değil, **bağlanmamış mekanik.**

Kod tabanında `PsychologyEngine` adında, doğrudan davranışsal psikoloji için yazılmış bir sınıf zaten var (`lib/domain/usecases/psychology_engine.dart`). İçindeki 5 fonksiyondan **3'ü hiçbir yerden çağrılmıyor.** FOMO metinleri, pazarlık gerilimi metinleri ve batık maliyet uyarıları yazılmış, test edilmiş, kullanıma hazır — ve hiçbir ekrana takılmamış. Kanca altyapısının yarısı kutunun içinde duruyor.

Dört yapısal teşhis:

1. **D7 kancası matematiksel olarak bozuk.** Giriş serisi sayacı `.inDays` ile hesaplanıyor (`game_core_provider.dart:55`); ödül talebi ise takvim günü ile kontrol ediliyor (`dashboard_screen.dart:560`). İki farklı zaman modeli. Sonuç: her gün düzenli oynayan bir oyuncunun seri sayacı **1'de veya 2'de donuyor.** `streak_7` başarımı fiilen ulaşılamaz, ödül kademeleri hiç tırmanmıyor.

2. **D30 kancası yok.** Seri ödülü 15. günde ₺30.000'de tavan yapıyor (`psychology_engine.dart:40-46`). 15. günden 300. güne kadar her gün aynı. Uzun vadeli oyuncuya verilen mesaj: *"buradan sonrası aynı."*

3. **Dışsal tetikleyici sıfır.** `NotificationService` `toastification` paketi üzerine kurulu — yani **yalnızca uygulama içi toast.** Push/local notification altyapısı yok. Oyunu kapatan oyuncuyu geri çağıran hiçbir mekanizma bulunmuyor. Retention'ın en büyük tek yapısal limiti bu.

4. **Değişken ödül yanlış eksende uygulanmış.** Teklif üretimi `%15/dakika` rastgele (`game_time_mixin.dart:35`) — yani **belirsizlik zamanlamada.** Davranışsal olarak bu merak değil, can sıkıntısı üretir. Değişkenlik *ne zaman geleceğinde* değil, *ne geleceğinde* olmalıdır. Oyuncu ziyaretçinin ne zaman geleceğini bilmeli, ama kim olacağını ve ne teklif edeceğini bilmemeli.

**Tek cümlelik sonuç:** Oyunun dopamin döngüsü çalışmıyor çünkü ödüller *tahmin edilebilir büyüklükte* ve *tahmin edilemez zamanda* geliyor. Doğrusu tam tersidir.

---

## 1. Mevcut Kanca Altyapısı Envanteri

Öneri yapmadan önce elde ne olduğunu tespit etmek gerekiyor. Kod tabanı retention açısından sanılandan zengin — sorun bağlantılarda.

| Bileşen | Konum | Durum |
|---|---|---|
| `getStreakReward()` | `psychology_engine.dart:40` | ✅ Bağlı — ama sayacı bozuk (§4.2) |
| `getLiveViewerCount()` | `psychology_engine.dart:7` | ✅ Bağlı (2 ekran) |
| `getRandomFomoText()` | `psychology_engine.dart:11` | ❌ **0 çağrı** |
| `getSuspenseNegotiationText()` | `psychology_engine.dart:24` | ❌ **0 çağrı** |
| `getSunkCostRepairText()` | `psychology_engine.dart:35` | ❌ **0 çağrı** |
| `FloatingMoneyOverlay` | `widgets/floating_money_overlay.dart` | ✅ Ödül geri bildirimi mevcut ve iyi |
| `StoryCardModel` (8 kart) | `story_card_model.dart` | ⚠️ Anlatı ≠ mekanik (§3.4) |
| `AdService` ödüllü video | 3 çağrı noktası | ✅ Yerleşim doğru (§6.2) |
| `customerReviews` + `reputationScore` | `dealership_model.dart:43,39` | ⚠️ Sosyal kanıt altyapısı var, kullanılmıyor |
| `dealershipName` / `logoEmblemId` / tema mağazası | `dealership_identity_screen.dart` | ⚠️ Yatırım mekaniği var, çok geç sunuluyor |
| `salesHistory` | `sale_record_model.dart` | ⚠️ İlerleme arşivi var, geri besleme yok |
| Push / local notification | — | ❌ **Yok** |
| Sosyal katman / liderlik | — | ❌ **Yok** |
| Sezon / prestij döngüsü | — | ❌ **Yok** |

**Okuma:** Kanca mimarisinin iskeleti kurulmuş. Çoğu öneri "sıfırdan sistem yaz" değil, "yazılmış olanı bağla ve doğru eksene çevir" şeklinde olacak. Bu, uygulama maliyetini ciddi biçimde düşürüyor.

---

## 2. Hook Model Denetimi (Trigger → Action → Variable Reward → Investment)

Nir Eyal'in dört aşamalı döngüsü, alışkanlık ürünlerinin standart denetim çerçevesidir. Her aşamayı koddaki karşılığıyla puanlıyorum.

### 2.1 Tetikleyici (Trigger) — **2/10**

**Dışsal tetikleyici:** Yok. Push bildirimi altyapısı bulunmuyor. Oyuncu uygulamayı kapattığı anda oyunla arasındaki tüm iletişim kanalları kapanıyor. Mobil tycoon türünde D1 retention'ın en güçlü tek belirleyicisi budur.

**İçsel tetikleyici:** Zayıf. İçsel tetikleyici, oyuncunun *kendi duygusal durumundan* doğan geri dönme dürtüsüdür — "acaba o araba satıldı mı?", "siparişim geldi mi?". Bunun oluşması için oyuncunun zihninde **kapatılmamış bir döngü** kalması gerekir (Zeigarnik etkisi). Şu an oyundan çıkarken açık kalan tek şey `pendingOrders` (parça siparişleri) ve bunlar da `deliveryDurationSeconds` ile gerçek zamanda ilerliyor — doğru mekanik, ama oyuncuya "çıkarken" hiç hatırlatılmıyor.

Daha ağır sorun: `advanceGameDay` yalnızca uygulama açıkken çalışıyor (`game_time_mixin.dart:25`). Yani oyuncu yokken **hiçbir şey olmuyor.** Geri dönüşün ödülü yok, dolayısıyla geri dönme dürtüsü de yok.

> **Öneri T1 — Çıkış Kancası (Exit Hook).** Oyuncu uygulamayı kapatmak üzereyken (`AppLifecycleState.paused`) açık döngüleri özetleyen bir kart göster: *"3 parça siparişin yolda · Murat 124 vitrinde bekliyor · Yarınki seri ödülün ₺7.500."* Bu, dışsal tetikleyici olmadan içsel tetikleyici kurmanın en etkili yoludur ve hiçbir yeni paket gerektirmez.

> **Öneri T2 — Geri Dönüş Ödülü.** `OfflineProgression`'daki `clamp(1, 5)` limiti (`offline_progression.dart:25`) kaldırılmalı; geçen gerçek süre oyun gününe çevrilip yan işletme geliri, giderler ve ziyaretçi kuyruğu offline işletilmeli (12 saat tavanla). Dönen oyuncu **"Yokluğunda Neler Oldu"** özetiyle karşılaşmalı. Şu an 30 dakika sonra dönen de 8 saat sonra dönen de aynı 5 teklifi buluyor — geri dönmenin bir anlamı yok.

> **Öneri T3 (kapsam notu).** Gerçek push/local notification, D1 retention'ı tek başına tipik olarak 1,3–1,6× artıran müdahaledir. Bu yeni bir paket gerektirdiği için **talebin kapsam dışı maddesine takılıyor.** Kararı size bırakıyorum, ama şunu net söylemem gerekir: yukarıdaki T1 ve T2 önerileri push'un yerini tutmaz, yalnızca yokluğunu kısmen telafi eder. Paket kısıtı gevşetilirse retention için yapılacak en yüksek getirili tek iş budur.

### 2.2 Eylem (Action) — **6/10**

Fogg davranış modeli: **B = MAP** (Motivasyon × Yetenek × Tetikleyici). Eylemin gerçekleşmesi için üçünün aynı anda bulunması gerekir.

| Faktör | Değerlendirme |
|---|---|
| **Motivasyon** | ⚠️ Zayıflatılmış. Yan işletmeler ana döngüden ~23× daha verimli (bkz. Oyun Tasarım Raporu §2.3). Oyuncunun araba almak için ekonomik motivasyonu yok — beklemek daha kârlı. |
| **Yetenek (Ability)** | ✅ İyi. Arayüz akışkan, `AppTactileButton` haptik geri bildirim veriyor, evrensel swipe-to-back var. Sürtünme düşük. |
| **Tetikleyici** | ⚠️ Dashboard'daki `_buildFirstDayQuestBanner` (`dashboard_screen.dart:451`) mükemmel bir eylem tetikleyicisi — ama yalnızca ilk gün mantığı için yazılmış. Sonraki 300 gün için eşdeğeri yok. |

> **Öneri A1 — Kalıcı "Sıradaki Eylem" Kartı.** İlk gün rehber banner'ının mantığını genelleştir: oyuncunun durumuna göre her zaman tek bir sonraki eylem öner (*"2 aracın ilana çıkmayı bekliyor"*, *"Teklif süresi dolmak üzere"*, *"Bütçen 3 aracı kaldırıyor, pazara bak"*). Karar felci, tycoon oyunlarında en yaygın oturum sonlandırıcıdır.

### 2.3 Değişken Ödül (Variable Reward) — **3/10** ← *en kritik aşama*

Bu, dopamin döngüsünün motorudur ve şu an **yanlış eksende çalışıyor.**

**Temel prensip:** Dopamin, ödülün *alınması* anında değil, ödülün *beklenmesi* anında salgılanır. Ve yalnızca sonuç belirsizse salgılanır. Kritik incelik şudur: belirsizlik **ödülün içeriğinde** olmalı, **ödülün zamanlamasında** değil. Zamanlaması belirsiz ödül, beklenti üretmez — çünkü oyuncu ne zaman heyecanlanacağını bilemez, sadece bekler.

**Şu anki durum (`game_time_mixin.dart:31-38`):**

```dart
double dayFactor = 0.8 + (random.nextDouble() * 0.4);
if (state.ownedCars.isNotEmpty && random.nextDouble() < (0.15 * dayFactor)) {
  triggerOrganicOffers();
}
```

Dakikada %15 olasılık → ilk teklif için ortalama **6,7 dakika belirsiz bekleme.** Ödülün kendisi ise oldukça öngörülebilir: `generateBuyerOffer` (`negotiation_engine.dart:171-243`) çoğunlukla gerçek değerin %85–105'i arasında bir sayı üretiyor.

**Sonuç: belirsiz zaman + öngörülebilir ödül = can sıkıntısı.** Olması gereken: öngörülebilir zaman + belirsiz ödül = beklenti.

Eyal'in üç değişken ödül tipi üzerinden envanter:

| Tip | Tanım | Galerisinden'deki karşılığı |
|---|---|---|
| **Av (Hunt)** | Kaynak arayışı, "acaba iyi bir şey çıkacak mı" | ⚠️ Pazar taraması var ama kâr marjı görünmüyor, filtre yok. Av hissi zayıf. |
| **Benlik (Self)** | Ustalık, ilerleme, yeterlilik | ⚠️ Yetenek ağacının 5 dalından 2'si tamamen ölü (`marketSense`, `financeSense` hiçbir yerden okunmuyor). |
| **Kabile (Tribe)** | Sosyal onay, statü, karşılaştırma | ❌ **Tamamen yok.** |

> **Öneri VR1 — Ekseni Çevir: Randevu Kuyruğu.** Rastgele tetiklemeyi kaldır; her ilandaki araç için **görünür bir geri sayım** koy (*"Sonraki Ziyaretçi: 01:47"*). Süre deterministik ve modifiye edilebilir olsun: itibar (−%8/seviye), doping (−%40), satış danışmanı (−%25), piyasa altı fiyat (−%30). Belirsizlik ziyaretçinin **kim olduğuna** kayar: nakitçi mi, ölücü mü, koleksiyoner mi, senetli mi.
>
> Oyuncu artık "ne zaman?" diye beklemez, "kim gelecek?" diye merak eder. Aynı bekleme süresi, tamamen farklı bir psikolojik deneyim.

> **Öneri VR2 — Ödül Dağılımını Genişlet.** `generateBuyerOffer` şu an dar bir bantta üretiyor. Uzun kuyruklu bir dağılım ekle: %70 sıradan teklif, %20 ölücü (zaten var: `isLowball`, %25), **%8 "tam istediğin fiyat"**, **%2 "koleksiyoner — piyasanın %140'ı"**. O %2, oyuncunun haftalarca anlatacağı an olur. Değişken oranlı pekiştirmede etkiyi yaratan, nadir ve büyük olan uçtur.

> **Öneri VR3 — Kıl Payı Kaçırma (Near-Miss).** Nörolojik olarak kıl payı kaçırma, kazanmaya yakın bir dopamin yanıtı üretir. Malzeme kodda hazır: `NegotiationEngine.evaluateCounterOffer` (`:302-311`) "yumuşak çekilme" durumunu zaten hesaplıyor. Şu an alıcı sessizce siliniyor. Bunun yerine göster: *"Alıcı ₺15.000 farkla masadan kalktı."* Ve kullanılmayan `getSuspenseNegotiationText()` fonksiyonunu (`psychology_engine.dart:24`) tam da buraya bağla — pazarlıkta 1,5 saniyelik bir "Alıcı düşünüyor..." gerilim duraklaması, kabul anının değerini katlar.

> **Öneri VR4 — Kabile Katmanı (backend'siz).** Sosyal ödül tipi tamamen eksik ve bu, D30'un en büyük açığı. Backend olmadan üç yerel proxy kurulabilir:
> - **NPC Rakip Galeriler:** 4–6 isimli rakip (*"Kadir Oto", "Boğaziçi Motors"*) haftalık ciro üretsin, oyuncu sıralamada kendini görsün. Tamamen simüle, sunucusuz.
> - **Müşteri yorumları:** `customerReviews` ve `reputationScore` altyapısı **zaten var** ama satış sonrası akışa bağlı değil. Bağlandığında oyuncu her satıştan sonra bir "sosyal yargı" alır.
> - **Şehir İtibar Tablosu:** İtibar puanına göre unvan (*"Sanayi Çırağı" → "Cadde Galerisi" → "Plaza Bayii" → "Otomotiv Baronu"*).

### 2.4 Yatırım (Investment) — **4/10**

Yatırım aşaması, oyuncunun ürüne emek/veri/kimlik yatırarak **bir sonraki döngüyü kendi eliyle daha değerli hale getirmesidir.** Biriken değer, terk etme maliyetini yükseltir.

**Var olan ama kullanılmayan yatırım araçları:**

| Araç | Konum | Sorun |
|---|---|---|
| Galeri adı + logo amblemi | `dealership_identity_screen.dart` | Ayarlar menüsüne gömülü — çoğu oyuncu hiç görmüyor |
| Tema mağazası | `theme_store_screen.dart` | Kozmetik yatırım, iyi — ama geç |
| Showroom dekorasyonu | `showroom_decor_screen.dart` | Lv3 kilitli |
| Yetenek ağacı | `character_growth_screen.dart` | 5 daldan 2'si ölü |
| Satış geçmişi | `sales_history_screen.dart` | Arşiv var, oyuncuya "ne kadar yol katettin" geri beslemesi yok |

> **Öneri I1 — Kimliği Öne Al.** Galeri adı ve amblem seçimini **onboarding'in içine** taşı. Oyuncu "Miras Oto Galeri" yerine kendi koyduğu ismi gördüğü anda mülkiyet hissi (endowment effect) başlar. Bu, tek satırlık bir akış değişikliğiyle elde edilen en ucuz retention kazancıdır.

> **Öneri I2 — Koleksiyon Vitrini.** Nadir araçlar (`isRare`) vitrine **kalıcı olarak** kilitlenebilsin; satılamaz hale gelsin ve karşılığında kalıcı pasif bonus versin. Bu hem gerçek bir money sink hem de en güçlü yatırım mekaniğidir: oyuncu bir şeyi *kaybetmemek için* geri döner. Dede'nin Murat 124'üne duygusal bir final vermesi de cabası.

> **Öneri I3 — Galeri Yıllığı.** `salesHistory` verisiyle haftalık özet kartı: en kârlı satış, en iyi pazarlık, toplam restore edilen araç. Oyuncunun kendi ilerlemesini görmesi, "Benlik" tipi değişken ödülü besler.

---

## 3. Dopamin Döngüsü Mimarisi

### 3.1 Döngü Uzunluğu Analizi

Sağlıklı bir tycoon oyununda **iç içe geçmiş üç zaman ölçeğinde** ödül döngüsü bulunur. Galerisinden'in mevcut profili:

| Döngü | İdeal süre | Galerisinden'de | Durum |
|---|---|---|---|
| **Mikro** (saniyeler) | 5–30 sn | Pazarlık turu, onarım dokunuşu | ✅ Var, `FloatingMoneyOverlay` ile iyi desteklenmiş |
| **Orta** (dakikalar) | 2–5 dk | Araç al → onar → sat: **~10+ dk**, teklif beklemesi ~6,7 dk | ❌ **Çok uzun ve ölü zamanlı** |
| **Makro** (oturumlar) | günler | Seviye atlama, yan işletme | ⚠️ Seviye bir *ceza* (gider 369× artıyor) |

**Teşhis:** Orta döngü kırık. "Bir tur daha oynayayım" hissi tam olarak orta döngüden doğar — çünkü oyuncu bir turun ne kadar süreceğini bilir ve "buna vaktim var" der. 10+ dakikalık, çoğu bekleme ile geçen bir tur bu hesabı yapılamaz kılar.

> **Hedef:** Orta döngüyü **3–4 dakikaya** indir. VR1'deki randevu kuyruğu (2–4 dk görünür bekleme) + bekleme sırasında eylem imkânı bunu tek başına sağlar.

### 3.2 Beklenti > Alma İlkesi

Şu an satış anı şöyle işliyor: oyuncu "Kabul Et"e basar → para hesaba geçer → toast çıkar. **Beklenti fazı yok.**

> **Öneri D1 — Kabul Anını Geciktir.** Kabul ile paranın düşmesi arasına 1,2–2 saniyelik bir dramaturji koy: noter animasyonu, `getSuspenseNegotiationText()` metni, sonra sayacın tırmanışı. `FloatingMoneyOverlay` zaten var; eksik olan **öncesindeki boşluk.** Ödülün kendisi değişmez, ödülün hissi katlanır.

### 3.3 Açık Döngüler (Zeigarnik Etkisi)

İnsan beyni tamamlanmamış görevleri tamamlanmışlardan daha iyi hatırlar. Oyunun oyuncunun zihninde kalması için oturum **her zaman en az bir açık döngüyle** bitmelidir.

Kodda açık döngü üretebilecek üç sistem var — hiçbiri bu amaçla kullanılmıyor:

- `pendingOrders` — gerçek zamanlı parça teslimatı (`part_order_model.dart`) ✅ mekanik doğru, hatırlatma yok
- `activeCheques` / `activeInstallments` — 30 günlük vadeler ✅ mekanik doğru, görünürlük düşük
- `pendingStoryCard` — bekleyen hikâye kartı ⚠️ oyuncu bunun beklediğini bilmiyor

> **Öneri D2.** Öneri T1'deki çıkış kartı, bu üç sistemi tek ekranda özetlemeli. "Kapatırken açık döngüyü göster" — en düşük maliyetli içsel tetikleyici kurulumu.

### 3.4 Kırık Vaat: Hikâye Kartları

Bu, raporun en ciddi güven bulgusu.

8 hikâye kartının anlatı vaadi ile `resolveStoryCard`'ın (`game_time_mixin.dart:349-455`) gerçek ödülü örtüşmüyor:

| Kart | Oyuncuya söylenen | Kodun verdiği |
|---|---|---|
| Vlogger Berk | *"3 adet hazır alıcı teklifi yağar"* | `balance += 40000` |
| Hüsnü Bey (Kahve) | *"liste fiyatının %10 üzerine satış fırsatı"* | `balance += 30000` |
| Eksper Melih | *"ihale kâr marjı bonusu"* | `balance += 30000` |
| Çıkmacı İbo | *"₺35.000 parça kredisi"* | `balance += 35000` |
| Çekici Remzi | *"lojistik fonu"* | `balance += 25000` |

8 ödül tipinden **5'i düz nakit.** Oyuncu reklamı bir *anlatı sonucu* için izliyor, karşılığında bir *sayı* alıyor.

**Psikolojik maliyet:** Bu, klasik bir güven erozyonu döngüsüdür. İlk seferde oyuncu ikna olur. İkinci seferde vaadin karşılanmadığını fark eder. Üçüncü seferde **tüm hikâye kartlarını reddetmeye başlar** — ve bununla birlikte reklam geliri, anlatı katmanı ve retention kancası aynı anda ölür. Sekiz güzel yazılmış karakter boşa gider.

> **Öneri D3 — Vaadi Mekaniğe Bağla.** Her ödül tipi anlattığı şeyi yapmalı:
> - `viralBuyerOffers` → gerçekten 3 teklif üret (`triggerOrganicOffers()` × 3 — fonksiyon zaten var)
> - `bonusSaleBoost` → mevcut tekliflerden birini liste fiyatının %110'una yükselt
> - `auctionMarginReport` → bir sonraki açık artırmada gerçek bir bilgi avantajı ver
> - `partsDiscountCredit` → nakit yerine **kısıtlı para birimi** (yalnızca atölyede harcanabilir bir kredi bakiyesi)
>
> Sonuncusu ayrıca ikinci bir para birimi kurar; bu, ödül algısını yükseltirken ana ekonomiyi enflasyona sokmaz.

---

## 4. D1 / D7 / D30 Retention Mimarisi

Üç zaman ufkunun **farklı mekaniklerle** çözülmesi gerekir. Tek bir sistemin üçünü birden taşımasını beklemek, en yaygın tasarım hatasıdır.

### 4.1 D1 — İlk 24 Saat: *"Anladım ve bir şey başardım"*

D1'i belirleyen tek soru: **oyuncu ilk oturumda bir zafer yaşadı mı?**

| Bulgu | Durum |
|---|---|
| Onboarding rehberi (12 adımlı `TutorialStep`) | ✅ İyi tasarlanmış |
| İlk gün hedef banner'ı | ✅ Mevcut, işlevsel |
| **İlk zaferin ödülü alınamıyor** | ❌ `claimMissionReward` her zaman `false` dönüyor — ₺35.000 + 250 XP hiç verilmiyor |
| **Tutorial'ın vaat ettiği değer artışı gerçekleşmiyor** | ❌ Kaporta onarımı araç değerini artırmıyor (`car_model.dart:83` clamp hatası) |
| İlk teklif bekleme süresi | ⚠️ ~6,7 dk — ilk oturum için çok uzun |

**Kritik okuma:** Tutorial oyuncuyu 9 adım boyunca kaporta onarımına yönlendiriyor ve 9. adımda *"Yenilenen aracın piyasa değerinin yükseldiğini gör!"* diyor (`tutorial_provider.dart:46`). Değer yükselmiyor. **Oyunun ilk vaadi, ilk 10 dakikada tutulmuyor.** D1 açısından bundan daha zararlı bir şey yok — ve bu iki hata, ilgili teknik raporda P0-1 ve P0-2 olarak zaten belgelendi.

> **Öneri R1.** D1 için yeni mekanik gerekmiyor. Gereken tek şey, mevcut ilk-oturum vaadinin tutulması: değer artışının gerçekleşmesi ve ilk görev ödülünün ödenmesi. İlk teklifin gelme süresi ise ilk araç için özel olarak **60–90 saniyeye** sabitlenmeli — ilk zafer beklemeye kurban edilmemeli.

### 4.2 D7 — İlk Hafta: *"Alışkanlık kuruluyor"* ← **şu an bozuk**

Giriş serisi, D7'nin ana kancasıdır ve **sayacı çalışmıyor.**

`game_core_provider.dart:53-60`:

```dart
final diffDays = now.difference(loaded.lastLoginDate).inDays;
if (diffDays == 1) { streak += 1; }
else if (diffDays > 1) { streak = 1; }
```

`.inDays` **tam 24 saatlik blokları** sayar, takvim günlerini değil. Buna karşılık ödül talebi takvim günü ile kontrol ediliyor (`dashboard_screen.dart:560`). İki farklı zaman modeli, tek sistemde.

**Gerçek oyuncu senaryosu:**

| Gün | Giriş saati | `.inDays` farkı | Ödül alınır mı? | Seri sayacı |
|---|---|---:|---|---:|
| Pazartesi | 21:00 | — | ✅ | 1 |
| Salı | 09:00 | 0 (12 saat) | ✅ (takvim günü farklı) | **1** ❌ |
| Çarşamba | 20:00 | 1 (35 saat) | ✅ | 2 |
| Perşembe | 08:00 | 0 (12 saat) | ✅ | **2** ❌ |

Her gün düzenli oynayan oyuncunun serisi **1–2 arasında donuyor.** Sonuçlar:

- Ödül hiç tırmanmıyor: oyuncu ₺30.000 kademesini görmüyor, ₺1.000–2.500'de kalıyor
- `streak_7` başarımı (₺15.000 + 300 XP + 2 yetenek puanı) **fiilen ulaşılamaz**
- Serinin psikolojik gücü — kayıptan kaçınma (loss aversion) — hiç devreye girmiyor. Kaybedecek bir seri yoksa korumak için de geri dönülmez.

> **Öneri R2 — Seriyi Takvim Gününe Çevir.** Her iki tarafta da takvim günü karşılaştırması kullanılmalı (gece yarısına normalize edilmiş tarih farkı). Bu, tek fonksiyonluk bir düzeltme ve D7 üzerindeki etkisi orantısız biçimde büyük.

> **Öneri R3 — Seri Koruması (Streak Freeze).** Bir gün kaçıran oyuncunun serisi anında sıfırlanmasın; ayda bir kez ödüllü reklamla veya nakitle "dondurma" hakkı olsun. Seri sıfırlanması, oyuncuyu geri getirmek yerine **tamamen terk etmeye** iten en bilinen tetikleyicidir — çünkü biriktirilen yatırım bir anda silinir.

> **Öneri R4 — Haftalık Etkinlik.** D7'nin ikinci ayağı, haftanın belirli bir gününe bağlı tekrarlayan bir olaydır: *"Cumartesi Sanayi Pazarı — bugün tüm ilanlar %20 indirimli"* veya *"Perşembe Açık Artırma Günü"*. Bu, haftalık bir randevu oluşturur. `MarketNewsModel` rotasyon altyapısı (`game_time_mixin.dart:272`) buna hazır — şu an haberler yalnızca dekoratif, oynanışa hiç etki etmiyor.

### 4.3 D30 — Uzun Vade: *"Hâlâ ulaşacak bir şey var"* ← **şu an yok**

30. günde oyuncuyu tutan şey ödül miktarı değil, **ufkunda hâlâ bir hedef bulunmasıdır.**

| Sorun | Detay |
|---|---|
| Seri ödülü tavanı | 15. günde ₺30.000'de sabitleniyor (`psychology_engine.dart:45`) — sonraki 285 gün aynı |
| Seviye tavanı | Lv4 son seviye; sonrasında ilerleme göstergesi yok |
| Yetenek tavanı | Her dal max 10; toplam 45 puanla dolar |
| Başarım havuzu | 11 başarım, 3'ü ulaşılamaz |
| Prestij / sezon | ❌ Yok |
| Koleksiyon hedefi | ❌ Yok |

**Teşhis:** Oyunun 30. günde oyuncuya sunduğu yeni hiçbir şey yok. Tüm sistemler ~15. günde doygunluğa ulaşıyor.

> **Öneri R5 — Sezon / Prestij Döngüsü (New Game+).** D30'un tek gerçek çözümü, ilerlemenin **yeniden başlayabilmesidir.** Oyuncu galerisini devredip yeni bir "sezona" başlasın; karşılığında kalıcı bir prestij bonusu (başlangıç sermayesi +%10, nadir araç oranı +%5) ve bir unvan taşısın. Bu, tycoon türünde D30'u tek başına en çok artıran mekaniktir çünkü tavanı kaldırır.

> **Öneri R6 — Koleksiyon Tamamlama.** `GameConstants.carBrands` içinde 20 marka ve ~80 model tanımlı — devasa bir koleksiyon hedefi hazır bekliyor. "Satın aldığın her benzersiz model kalıcı olarak kaydedilsin, %25/%50/%100 tamamlamada ödül." Toplama davranışı, ekonomik motivasyon tükendikten sonra bile çalışan en dayanıklı içsel motivasyondur.

> **Öneri R7 — Seri Ödülünü Tavansız Yap.** Kademeli tavan yerine 15. günden sonra logaritmik büyüme + her 10 günde bir özel ödül (nadir araç, yetenek puanı, kozmetik).

---

## 5. İleri Seviye Oynanış Özellikleri

Yukarıdaki düzeltmeler döngüyü onarır. Bu bölüm, döngüyü **derinleştiren** özellikleri sıralar. Hepsi mevcut altyapıyla, harici paket olmadan uygulanabilir.

### 5.1 Rakip Galeri Sistemi *(Kabile ödülü + rekabet)*
4–6 simüle NPC galeri; her biri haftalık ciro üretir, bazen oyuncunun gözüne kestirdiği aracı **kapar**. Pazarda bir ilan "Kadir Oto tarafından satıldı" diye kaybolduğunda, oyuncu bir dahaki sefere daha hızlı davranır. Kayıptan kaçınmayı rekabete çeviren, sunucusuz çalışan en güçlü mekanik.

### 5.2 Canlı Açık Artırma Dramaturjisi *(değişken ödülün zirvesi)*
`auction_engine.dart` mevcut. Açık artırma, doğası gereği değişken ödül üreten en güçlü formattır: gerilim, rakip, geri sayım, kıl payı kayıp. Şu an Lv3 kilitli ve dramaturjisi zayıf. Öneri: geri sayım + rakip tekliflerin canlı akışı + son 3 saniyede uzatma ("sniping"). Ayrıca `getSuspenseNegotiationText()` burada da kullanılabilir.

### 5.3 Sadık Müşteri Ağı (CRM) *(yatırım)*
Satış yapılan alıcılar hafızada kalsın; memnun müşteri 10–20 gün sonra **isimle** geri dönsün: *"Geçen sene aldığım Golf'ten memnun kaldım, şimdi eşime bakıyorum."* Sadık müşteri daha yüksek teklif verir, ekspertiz yaptırmaz. Bu, `customerReviews` ve `reputationScore` altyapısına doğrudan oturur ve oyuncunun geçmiş kararlarını geleceğe bağlar — yatırım aşamasının tanımı budur.

### 5.4 Araç Geçmişi / Provenance *(duygusal bağ)*
Her araç kendi hikâyesini biriktirsin: kaç sahip değiştirdi, hangi onarımları gördü, kim sattı. Satış ekranında "bu aracın hikâyesi" görünsün. Restorasyon oyunlarında duygusal bağ, ekonomik motivasyondan daha uzun ömürlüdür.

### 5.5 Usta–Çırak Sistemi *(uzun vadeli yatırım)*
`staff_academy_screen.dart` mevcut. Personel yalnızca satın alınan bir bonus değil, **yetiştirilen** bir varlık olsun: çırak zamanla ustalaşsın, uzmanlık dalı seçsin, bazen daha iyi teklifle ayrılsın (elde tutma kararı). İnsan kaynağına yapılan yatırım, terk etme maliyetini en çok yükselten yatırım türüdür.

### 5.6 Piyasa Haberlerini Oynanışa Bağla *(öngörü ödülü)*
`MarketNewsModel` rotasyonu var ama etkisi yok. Haberler gerçek fiyat etkisi yapsın ve **1 gün önceden sinyal versin** (*"Söylenti: yakıt zammı geliyor"*). Oyuncu doğru tahmin ederse kâr eder. Bu, `marketSense` yeteneğine (şu an tamamen ölü) gerçek bir işlev kazandırır: sinyali daha erken görme.

### 5.7 Zaman Sınırlı Konsinye Sözleşmeleri *(aciliyet)*
*"5 gün içinde tramersiz bir SUV bul ve teslim et → piyasa değerinin %125'i."* Pazar taramasına amaç katar ve gerçek bir zaman baskısı yaratır — şu an oyunda hiç aciliyet yok (teklifler 12 gerçek saat geçerli).

---

## 6. Etik Sınır & Güven Bütçesi

Retention mekanikleri iki kategoriye ayrılır: oyuncuyu **daha çok eğlendirerek** tutanlar ve **bilişsel önyargılarını sömürerek** tutanlar. İkincisi kısa vadede metrikleri yükseltir, uzun vadede güveni ve LTV'yi düşürür. Kodda her iki türden de örnek var; sınırı net çizmek gerekiyor.

**Sorunsuz — kurgu içi ikna:**
`getLiveViewerCount()` ve `getRandomFomoText()` ("3 kişi teklif vermeye hazırlanıyor") **kurgusal NPC alıcılar** hakkındadır. Bu, gerçek bir pazaryerinde sahte kıtlık üretmekten kategorik olarak farklıdır — burada FOMO oyunun kurgusunun parçası ve oyuncu bunu bilir. Rahatlıkla kullanılabilir; nitekim `getRandomFomoText()` şu an hiç kullanılmıyor ve bağlanması önerilir.

**Dikkat gerektiren — batık maliyet:**
`getSunkCostRepairText()` (`psychology_engine.dart:35`) doğrudan batık maliyet yanılgısını hedefliyor: *"Şu ana kadar bu araca ₺X harcadın. Bir parça daha boyatsan..."* Bu, oyuncuyu geçmiş harcaması nedeniyle kötü bir karara itmek için tasarlanmış bir cümle. **Önerim: kalsın ama yön değiştirsin.** Geçmiş harcamayı vurgulamak yerine **ileriye dönük net getiriyi** göstersin: *"Bu parça ₺7.500 · Satış değerine katkı ₺12.400 · Net +₺4.900."* Aynı yerde, aynı anda, aynı eylemi teşvik eder — ama oyuncuyu kandırarak değil, doğru bilgiyle. Ve dürüst versiyon uzun vadede daha iyi çalışır, çünkü oyuncu sayıların güvenilir olduğunu öğrenir.

**Sınır çizgisi — ödüllü reklamlar:**
Mevcut 3 yerleşim (ayarlar, atölye hızlandırma, hikâye kartı) **doğru tarafta:** hepsi opsiyonel hızlandırma veya bonus, hiçbiri ilerlemeyi kilitlemiyor. Bu konumu koruyun. Reklam, oyuncunun *isteyerek* aldığı bir kısayol olduğu sürece sağlıklıdır; ilerlemenin önündeki duvar haline geldiği anda churn üretir.

Tek düzeltme gerektiren nokta §3.4'te belgelenen **vaat–ödül uyumsuzluğu.** Reklam izleten bir kartın söylediğini yapmaması, yukarıdaki tüm etik dengeyi tek başına bozar: oyuncu reklamın kandırma aracı olduğunu öğrenir ve bir daha izlemez.

---

## 7. Ölçüm Planı

Bu raporun tüm iddiaları kod okumasına dayanıyor. Hiçbiri gerçek oyuncu verisiyle doğrulanmadı — çünkü projede telemetri yok. Önerilerin etkisini ölçebilmek için minimum event seti:

| Event | Neyi cevaplar |
|---|---|
| `session_start` / `session_end` (+süre) | Oturum uzunluğu, orta döngü hedefi tutuyor mu |
| `tutorial_step_completed` (adım no) | Onboarding'de nerede düşüyorlar |
| `first_sale_completed` (+dakika) | D1 zaferi ne kadar sürüyor |
| `offer_received` / `offer_accepted` / `offer_expired` | Teklif döngüsü sağlığı, bekleme toleransı |
| `streak_claimed` (+seri no) | R2 düzeltmesi çalıştı mı — **serinin 3'ü geçip geçmediği tek başına en kritik metrik** |
| `story_card_shown` / `_accepted` / `_declined` | D3 vaat düzeltmesinin etkisi (kabul oranı yükselmeli) |
| `rewarded_ad_completed` (+yerleşim) | Hangi yerleşim çalışıyor |
| `session_end_open_loops` (açık döngü sayısı) | T1 çıkış kancasının etkisi |

**Kritik uyarı:** Metrikleri düzeltmelerden **önce** toplamaya başlayın. Aksi halde iyileşmenin hangi müdahaleden geldiği ayrıştırılamaz.

---

## 8. Öncelik Matrisi

Etki/maliyet oranına göre sıralandı.

### Kademe 1 — Bozuk kancaları onar *(düşük maliyet, yüksek etki)*

| # | İş | Etki |
|---|---|---|
| 1 | Giriş serisi sayacını takvim gününe çevir (R2) | **D7** — şu an fiilen çalışmıyor |
| 2 | İlk görev ödülünü ödenebilir yap + kaporta değer hatası | **D1** — ilk oturum vaadi |
| 3 | Hikâye kartı vaatlerini mekaniğe bağla (D3) | Güven + reklam geliri |
| 4 | `getSuspenseNegotiationText` + `getRandomFomoText` bağla (VR3) | Mikro döngü hissi |
| 5 | Çıkış kancası kartı (T1) | İçsel tetikleyici |

### Kademe 2 — Döngüyü doğru eksene çevir *(orta maliyet, yüksek etki)*

| # | İş | Etki |
|---|---|---|
| 6 | Randevu kuyruğu: görünür süre, belirsiz ziyaretçi (VR1) | **Orta döngü** — ana onarım |
| 7 | Ödül dağılımını genişlet + near-miss (VR2, VR3) | Değişken ödül |
| 8 | Gerçek offline ilerleme + dönüş özeti (T2) | Geri dönme sebebi |
| 9 | Seri koruması + tavansız ödül (R3, R7) | D7 → D30 köprüsü |
| 10 | Kimliği onboarding'e taşı (I1) | Mülkiyet hissi |

### Kademe 3 — Tavanı kaldır *(yüksek maliyet, D30 için zorunlu)*

| # | İş | Etki |
|---|---|---|
| 11 | Sezon / prestij döngüsü (R5) | **D30** — tek gerçek çözüm |
| 12 | Koleksiyon vitrini + tamamlama (I2, R6) | Money sink + toplama motivasyonu |
| 13 | Rakip galeri sistemi (5.1) | Kabile ödülü |
| 14 | Sadık müşteri ağı (5.3) | Yatırım derinliği |
| 15 | Haftalık etkinlik takvimi (R4) | Haftalık randevu |

---

## Kapanış Notu

Bu raporun en önemli bulgusu bir eksiklik değil, bir **israf**: `PsychologyEngine` sınıfı, projenin bu konuyu zaten düşündüğünü gösteriyor. FOMO metinleri, gerilim metinleri, seri ödülü eğrisi — hepsi yazılmış. Aynı şekilde `customerReviews`, `reputationScore`, `salesHistory`, `dealershipName`, 20 markalık araç kataloğu; retention mimarisinin hammaddesi kod tabanında hazır duruyor.

Eksik olan psikolojik içgörü değil, **bağlantı.** Kademe 1'deki beş maddenin tamamı mevcut kodu bağlamak veya bir karşılaştırma operatörünü düzeltmekten ibaret — ve bunlar D1 ile D7'nin bugün neden çalışmadığının doğrudan cevabı.

D30 farklı bir iş: orada gerçekten yeni bir tavan (§Kademe 3) inşa etmek gerekiyor. Ama o yatırıma girmeden önce ilk iki kademe tamamlanmalı — çünkü 30. güne hiç ulaşamayan bir oyuncu kitlesi için D30 mekaniği yazmak, kapısı kilitli bir binanın üst katını döşemektir.

---

*Rapor statik kod analizine dayanır; oyun içi telemetri ile doğrulanması önerilir (§7).*
