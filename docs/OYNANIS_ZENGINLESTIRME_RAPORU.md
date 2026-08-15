# Galerisinden — Oynanış Zenginleştirme Raporu

**Konu:** Oyun zevkini artıracak yeni mekanikler, ilave özellikler ve iyileştirmeler.
**Kapsam:** Yalnızca öneri raporu. Kod okundu, hiçbir dosya değiştirilmedi.
**Kısıt:** Tüm öneriler mevcut mimari ve harici paket eklemeden uygulanabilir olacak şekilde seçildi.

---

## 0. Önce Bir Yapısal Gözlem

Kodu bu oturumda dördüncü kez tarıyorum ve tekrar eden çok net bir örüntü var:

> **Bu projede içerik üretimi, içerik bağlamayı sürekli geçiyor.**

Somut kanıtlar — hepsi *yazılmış, test edilebilir, kullanıma hazır* ama **hiçbir yerden çağrılmıyor**:

| Varlık | Konum | Durum |
|---|---|---|
| **16 adet seçimli rastgele olay** (zabıta baskını, sel, çırağın boya kazası, kaputtaki kediler…) | [random_event_engine.dart](lib/domain/usecases/random_event_engine.dart) | ❌ Motorun tamamı ölü — `RandomEventEngine` hiçbir dosyadan çağrılmıyor |
| **6 adet amaca özel ses/titreşim** (`playCashSuccess`, `playNotarySignature`, `playAuctionBid`…) | [game_sound_haptic_service.dart](lib/core/services/game_sound_haptic_service.dart) | ❌ 6 metottan yalnızca jenerik dokunma efekti kullanılıyor; satış, noter ve ihale sesleri hiç çalmıyor |
| **2.000 satırlık izometrik şehir haritası** | [isometric_world_map.dart](lib/presentation/widgets/isometric_world_map.dart) | ❌ Hiçbir rotaya bağlı değil |
| **Müşteri arketipi kişilik metinleri** (`preferredDialogueTrait`) | [customer_model.dart:23](lib/data/models/customer_model.dart:23) | ❌ Hiç okunmuyor |
| **FOMO metinleri** (`getRandomFomoText`) | [psychology_engine.dart:12](lib/domain/usecases/psychology_engine.dart:12) | ❌ Hiç çağrılmıyor |

Bu rapor bu yüzden iki bölüme ayrılıyor: **Bölüm 1 zaten var olanı açmak** (neredeyse bedava zevk artışı), **Bölüm 2+ gerçek yeni mekanikler.** Bölüm 1'i atlayıp doğrudan yeni özellik eklemek, aynı örüntüyü bir kez daha tekrarlamak olur.

---

# BÖLÜM 1 — Zaten Yazılmış, Bağlanmayı Bekleyen Zevk

Bunlar "yeni özellik" değil, **ödenmiş ama teslim alınmamış içerik.** Getiri/maliyet oranı diğer her şeyden yüksek.

## 1.1 · 16 Rastgele Olayı Devreye Al ⭐ *en yüksek öncelik*

`RandomEventEngine.getRandomEvent()` ([random_event_engine.dart:219](lib/domain/usecases/random_event_engine.dart:219)) hazır. İçindeki olaylar sadece "para eksildi" bildirimi değil — her birinin **iki gerçek seçeneği, farklı para/itibar/XP sonuçları** var:

> **"Mahallenin Kedileri Kaputta!"** — Sıcak kaputların üstüne 8 sokak kedisi kurulmuş, müşteriler içeri girmeye çekiniyor.
> · *Mama Al & Sev* → −₺500, **+15 İtibar**
> · *Pışt De & Kov* → ₺0, **−15 İtibar**

> **"Çırağın Boya Kazası"** — Çırak Emre müşterinin siyah aracını kırmızı astara sürtmüş.
> · *Fırın Boyaya Al* → −₺12.000, +5 İtibar
> · *Pasta Cila ile Kurtar* → −₺3.000, −10 İtibar

Bu, oyunun **tonunu** taşıyan içerik: Türk sanayi kültürü, mizah, küçük ahlaki kararlar. Dramatik Kartlar'ın (15-30 günde bir, ağır) tersine bunlar **hafif ve sık** olmalı — 3-5 oyun gününde bir. İkisi birlikte sağlıklı bir ritim kurar: sık küçük kararlar + seyrek büyük kararlar.

**Ek öneri:** Şu an olaylar tamamen rastgele. Bağlama duyarlı hale getirilirse çok daha iyi çalışır — sel baskını yalnızca garajda araç varken, zabıta denetimi yalnızca belirli seviyeden sonra, çırak kazası yalnızca çırak personeli işe alınmışsa.

## 1.2 · Ses ve Titreşimi Anlara Bağla

`playCashSuccess()`, `playNotarySignature()`, `playAuctionBid()` — üç metot, üç kritik an, sıfır bağlantı. Satışın kapandığı an sessiz geçiyor; oyunun en tatmin edici anı hiçbir duyusal geri bildirim vermiyor.

| Metot | Bağlanması gereken an |
|---|---|
| `playCashSuccess()` | Teklif kabul → `FloatingMoneyOverlay` ile eşzamanlı |
| `playNotarySignature()` | Satış tamamlandığında, para düşmeden hemen önce |
| `playAuctionBid()` | Her ihale teklifinde (kendi + rakip) |
| `playWarningVibration()` | Dramatik kart kötü sonuç, araç kaybı, ceza |

Maliyeti bir günden az, algılanan kalite farkı orantısız biçimde büyük.

## 1.3 · Müşteri Kişiliğini Satış Tarafında Göster

Şu an ciddi bir asimetri var: **araç alırken** satıcının kişiliğini görüyorsun ([interactive_negotiation_sheet.dart:150](lib/presentation/screens/marketplace/interactive_negotiation_sheet.dart:150)), ama **araç satarken** alıcı sadece bir isim ve rakam.

`CustomerModel.generateRandomCustomer()` şu an satış anında ([showroom_offers_tab.dart:169](lib/presentation/screens/showroom/widgets/showroom_offers_tab.dart:169)) rastgele üretiliyor — yani teklifin kendisine bağlı değil, sadece sahtekârlık kontrolü için anlık yaratılıyor. Dolayısıyla oyuncu "Çakal Selim ölücü teklif verdi" hissini hiç yaşamıyor.

**Öneri:** Arketip, teklif oluşturulurken (`generateBuyerOffer`) belirlensin ve teklife iliştirilsin. Teklif kartında görünsün. Bu tek değişiklik, teklif listesini bir sayı tablosundan **karakter galerisine** çevirir — ve zaten yazılmış olan 4 arketip metnini hayata döndürür.

---

# BÖLÜM 2 — Çekirdek Döngüye Derinlik Katacak Yeni Mekanikler

## 2.1 · İlan Hazırlama Sanatı ⭐ *tematik olarak en isabetli öneri*

**Sorun:** Oyunun adı "Galerisinden" ve tüm kültürel dokusu Sahibinden ilan kültüründen geliyor. Ama ilan verme mekaniği şu an sadece **fiyat kaydırıcısı + beyan tipi seçimi** ([showroom_listing_modal.dart](lib/presentation/screens/showroom/widgets/showroom_listing_modal.dart)). Oyunun en karakteristik olması gereken anı, en sığ anı.

**Öneri — İlan üç eksende hazırlansın:**

**(a) Fotoğraf Çekimi**
- *Mekân:* Sanayi önü (bedava) / Yıkanmış asfalt (₺500) / Profesyonel stüdyo (₺3.000) / Boğaz manzarası (₺8.000)
- *Kare sayısı:* 3 / 8 / 20 fotoğraf — her kademe ziyaretçi hızını artırır
- Hasarlı parçalar fotoğrafta görünür; oyuncu "hasarlı tarafı gösterme" seçebilir → beyan tipi sistemine (`ListingDeclarationType`) doğal bir görsel karşılık

**(b) İlan Metni Tonu**
- *Dürüst & Detaylı* → `skepticalOfficial` ve `familyMan` arketiplerini çeker (yavaş ama yüksek teklif)
- *Abartılı & Vurgulu* ("KUSURSUZ! HATASIZ! ACİL!") → `impatientYouth` ve `greedyFlipper` çeker (hızlı ama ölücü teklif riski)
- *Samimi & Hikâyeli* ("Dedemden kalma, gözüm gibi baktım") → dengeli, itibar bonusu

**(c) Yayın Zamanlaması**
`WeeklyEventEngine` zaten haftanın günlerini tanımlamış ([weekly_event_engine.dart:22](lib/domain/usecases/weekly_event_engine.dart:22)) — Cuma Galeri Pazarı %40, Cumartesi Açık Oto Pazarı %60 daha hızlı ziyaretçi. Oyuncu ilanı **bekletip** doğru güne denk getirmeyi öğrenirse gerçek bir strateji doğar.

**Neden bu öneri diğerlerinden önemli:** Yeni bir sistem icat etmiyor — var olan üç sistemi (`ListingDeclarationType`, `CustomerArchetype`, `WeeklyEventEngine`) birbirine bağlayıp oyuncuya **anlamlı bir hazırlık kararı** veriyor. Ve satış öncesi ölü zamanı (retention raporundaki en büyük sorun) aktif bir zanaate çeviriyor.

## 2.2 · Test Sürüşü

**Sorun:** `engineCondition` ve `transmissionCondition` şu an sadece bir sayı ve bir formül girdisi. Oyuncu motorun kötü olduğunu *hissetmiyor*, sadece okuyor.

**Öneri:** Alıcı satın almadan önce test sürüşü isteyebilsin (arketipe göre olasılık: `skepticalOfficial` %90, `impatientYouth` %25). Sonuç motor/şanzıman kondisyonuna bağlı:

| Kondisyon | Sonuç |
|---|---|
| 85+ | *"Saat gibi çalışıyor"* → teklifte +%5 |
| 60–85 | Nötr |
| 40–60 | *"Rölantide titriyor"* → alıcı %20 indirim ister |
| <40 | *"Şanzıman vites atlıyor"* → alıcı çekilir, teklif iptal |

Ayrıca tuning yapılmış araçlarda (`tuning_studio_screen.dart` içindeki 6 seçenek) `impatientYouth` test sürüşünden coşkuyla döner ve **fazladan öder** — bu, şu an sadece bir değer çarpanı olan tuning sistemine karakter kazandırır.

**Katma değeri:** Satış anına gerilim ekler ve mekanik bakımın bedelini somutlaştırır. "Motoru onarmasam da satarım" stratejisini gerçek bir riske dönüştürür.

## 2.3 · Pazarlıkta Müşteri Okuma

**Sorun:** Pazarlık şu an bir kaydırıcı ve "karşı teklif" düğmesi. `NegotiationEngine.evaluateCounterOffer` matematiksel olarak sağlam ama oyuncunun tek girdisi bir sayı.

**Öneri:** Karşı teklif verirken oyuncu bir de **yaklaşım** seçsin. `CustomerModel.preferredDialogueTrait` alanı zaten bunun için yazılmış ve hiç kullanılmıyor:

| Yaklaşım | Kimde işe yarar |
|---|---|
| *"Ekspertiz raporunu masaya koy"* | `skepticalOfficial` → kabul olasılığı +%20 |
| *"Bu motor 300 beygir, denemeden gitme"* | `impatientYouth` → +%20 |
| *"Bugün kapatırsan bu fiyat"* | `greedyFlipper` → +%20 |
| *"Çocuklar için bundan güvenlisi yok"* | `familyMan` → +%20 |

Yanlış arketipe yanlış yaklaşım → −%10. Arketip ipucu, alıcının mesaj metninden ve avatarından **sezilebilir** ama açıkça yazılmasın — oyuncu zamanla okumayı öğrensin.

**Katma değeri:** Pazarlığı "doğru sayıyı bul" oyunundan "doğru insanı oku" oyununa çevirir. Ve `eyeForDetail` / `negotiation` yeteneklerine ipucu netliğini artırma gibi gerçek bir işlev verilebilir.

## 2.4 · Sökme Parçalarını Gerçek Envantere Çevir

**Sorun:** Hurdalıktan çıkan parçalar (`SalvagedPart`) şu an ya düz nakde satılıyor ya da kategoriye göre sabit bir motor/şanzıman artışı veriyor ([game_inventory_mixin.dart](lib/presentation/providers/game/game_inventory_mixin.dart) `installPartToCar`). Parçanın **hangi araçtan çıktığı** (`carModelName` alanı mevcut!) hiç önemsenmiyor.

**Öneri — uyum sistemi:**
- Parça **aynı markadan** bir araca takılırsa: tam etki, maliyet sıfır
- **Farklı markadan** takılırsa: %60 etki + araç değerinde küçük düşüş ("muadil parça" damgası)
- Ekspertizde bu görünsün → dürüst beyan eden oyuncu daha düşük fiyata satar

**Katma değeri:** Hurdalığı bir "para düğmesi"nden **eşleştirme bulmacasına** çevirir. Oyuncu artık "şu Bemeve'nin şanzımanı lazım" diye hurdalığa gider — yani hurdalık ana döngüye bağlanır, ondan kopmaz.

## 2.5 · Restorasyon Projesi Araçları (Ahır Buluntusu)

**Öneri:** Pazarda nadiren (%3-5) çıkan, çok ucuz ama korkunç durumda özel araçlar: motor 10, şanzıman 15, tüm kaporta hasarlı, 40 yıllık klasik. Tam restorasyon çok pahalı ve uzun — ama tamamlandığında `isRare` + yüksek `baseMarketValue` ile devasa kâr ve bir **başarım anı** verir.

Şu an oyunda "birkaç dakikada çevir" dışında bir tempo yok. Bu, oyuncuya **uzun vadeli bir proje** verir: garajda duran, üzerinde günlerce çalışılan, bitince gurur duyulan bir araç. Restorasyon oyunlarının duygusal çekirdeği tam olarak budur ve şu an oyunda karşılığı yok.

---

# BÖLÜM 3 — Stratejik & Ekonomik Katman

## 3.1 · Mevsim Döngüsü ⭐

**Sorun:** `WeeklyEventEngine` günlük ritmi kurmuş ama **uzun vadeli piyasa ritmi yok.** `MarketEngine.generateMarketTrend()` rastgele 4 trend arasında geçiş yapıyor — öngörülemez olduğu için üzerine strateji kurulamaz.

**Öneri:** 28 oyun günlük (≈1 saat) bir mevsim döngüsü, `bodyType` üzerinden:

| Mevsim | Yükselen | Düşen |
|---|---|---|
| İlkbahar | Hatchback, Sedan | SUV |
| Yaz | **Spor, Klasik** (+%30) | SUV, Van |
| Sonbahar | Sedan | Spor |
| Kış | **SUV, 4x4** (+%35) | Spor (−%25) |

**Neden rastgele trendden üstün:** Öngörülebilir olduğu için oyuncu **spekülasyon** yapabilir — kışın ucuz spor araba toplayıp yazın satmak. Bu, oyuna ilk kez gerçek bir *uzun vadeli strateji* katmanı ekler ve şu an tamamen ölü olan `marketSense` yeteneğine ("mevsim dönüşünü 3 gün önceden gör") gerçek bir işlev kazandırır.

## 3.2 · Stok Bayatlaması

**Sorun:** Araç garajda sonsuza kadar bekleyebilir, hiçbir baskı yok. Bu, fiyatlama kararını önemsizleştiriyor — oyuncu her zaman en yüksek fiyatı isteyip beklemekte özgür.

**Öneri:** İlanda 10+ oyun günü bekleyen araç "bayat ilan" olur: ziyaretçi hızı yavaşlar, ilan kartında *"Bu ilan 14 gündür yayında"* uyarısı çıkar. Çözüm oyuncunun elinde: fiyat kır, doping at, ilanı yenile (küçük ücret), veya bekle.

**Katma değeri:** Fiyatlamayı gerçek bir karara dönüştürür ve dolaşım hızını (dolayısıyla oyun temposunu) artırır. Ceza değil, **baskı** — oyuncu istediği zaman çözebilir.

## 3.3 · Kendi Finansmanını Sun

**Sorun:** `OfferType.installment` ve `OfferType.cheque` var, ama bunlar alıcının dayattığı koşullar. Oyuncu pasif.

**Öneri:** Oyuncu ilanına *"Senetle satılır — 12 ay, %20 vade farkı"* etiketi koyabilsin. Bu, bütçesi yetmeyen alıcıları çeker (ziyaretçi havuzunu genişletir) ve toplam geliri artırır — ama `customerCreditScore` üzerinden batma riski taşır. `financeSense` yeteneği (şu an tamamen ölü) bu riski azaltsın.

**Katma değeri:** Galeriyi bir *ticaret* işletmesinden bir *finans* işletmesine büyütür — tycoon türünün klasik ve tatmin edici derinleşme yönü. Ve ölü bir yeteneği hayata döndürür.

---

# BÖLÜM 4 — Duygusal Bağ

## 4.1 · Araç Künyesi (Provenance)

Her araç kendi geçmişini biriktirsin: kimden alındı, kaç gün garajda kaldı, hangi onarımlar yapıldı, ne kadar harcandı, kime satıldı. Satış ekranında **"Bu Aracın Hikâyesi"** olarak gösterilsin:

> *17 gün önce "Acil Satılık Sahibinden"den ₺180.000'e alındı · Motor rektifiye + 3 kaporta onarımı (₺46.500) · Bugün Mustafa Bey'e ₺310.000'e satıldı · **Net kâr ₺83.500***

`SaleRecordModel` ve `salesHistory` altyapısı zaten var; eksik olan yalnızca araç bazlı olay günlüğü. Düşük maliyet, yüksek duygusal getiri — ve satış anını bir işlemden bir **finale** çevirir.

## 4.2 · Vitrin Yerleşimi

`isometric_showroom_canvas.dart` zaten araçları slot'lara diziyor. Oyuncu hangi aracın **cam kenarı "hero" pozisyonunda** duracağını seçebilsin → o araç %30 daha hızlı ziyaretçi çeksin.

Kozmetik bir sistemi tek bir kuralla gerçek bir karara çevirir: hangi aracı öne çıkarıyorum?

## 4.3 · Usta Yetiştirme

`StaffRole` şu an 4 sabit rol, maaş `dailySalary` üzerinden statik. `staff_academy_screen.dart` mevcut ama personel gelişimi yok.

**Öneri:** Çırak zamanla ustalaşsın (yaptığı iş sayısına göre), uzmanlık dalı seçsin (kaporta / mekanik / boya), belirli seviyeden sonra rakip galerilerden teklif alsın — oyuncu elde tutmak için zam yapmak zorunda kalsın. *(Not: Dramatik Kart B2 bu senaryoyu zaten anlatıyor ama arkasında mekanik yok — bu öneri o boşluğu doldurur.)*

---

# BÖLÜM 5 — His & Cila (Düşük Maliyet, Yüksek Algı)

| # | Öneri | Not |
|---|---|---|
| 1 | **Onarım öncesi/sonrası karşılaştırma** | Kaydırıcıyla hasarlı ↔ onarılmış görsel; restorasyonun ödülünü görünür kılar |
| 2 | **Noter animasyonu + `playNotarySignature()`** | Satış kapanışına 1,5 sn dramaturji; §1.2 ile birlikte |
| 3 | **Ekspertiz "inceleme modu"** | İzometrik araca dokunup panelleri tek tek muayene etme; `car_damage_schema_widget.dart` mevcut |
| 4 | **Kâr marjı rozeti** | Pazar ilanlarında tahmini kâr; av içgüdüsünü besler |
| 5 | **Günlük kapanış özeti** | Her oyun günü sonunda kısa kart: gelir, gider, net — para akışını görünür kılar |
| 6 | **`getRandomFomoText()` bağlama** | Pazar ilanlarında "5 galerici bu aracı inceliyor" |
| 7 | **Pazarlıkta kalan hak sayacı** | `maxCounters = 3` görünmüyor; oyuncu kaç hakkı kaldığını bilmiyor |

---

# Öncelik Matrisi

Getiri/maliyet oranına göre sıralı.

### Kademe 1 — Bağlantı işi *(gün mertebesinde, çok yüksek getiri)*

| # | İş | Neden önce |
|---|---|---|
| 1 | 16 rastgele olayı devreye al (§1.1) | Hazır içerik, oyunun tonunu taşıyor, sıfır tasarım maliyeti |
| 2 | Ses/titreşimi anlara bağla (§1.2) | Algılanan kalitede en ucuz sıçrama |
| 3 | Müşteri arketipini tekliflere iliştir (§1.3) | Yazılmış 4 karakteri hayata döndürür, §2.3'ün önkoşulu |
| 4 | His paketi #4, #6, #7 (§5) | Birkaç saatlik işler |

### Kademe 2 — Çekirdek döngü derinliği *(asıl zevk artışı burada)*

| # | İş | Neden |
|---|---|---|
| 5 | **İlan Hazırlama Sanatı** (§2.1) | Tematik olarak en isabetli; ölü bekleme süresini zanaate çevirir |
| 6 | **Pazarlıkta müşteri okuma** (§2.3) | Ana etkileşimi sayı oyunundan insan okumaya çevirir |
| 7 | **Test sürüşü** (§2.2) | Mekanik bakımı somutlaştırır, satışa gerilim katar |
| 8 | **Stok bayatlaması** (§3.2) | Fiyatlamayı gerçek karar yapar, tempoyu hızlandırır |

### Kademe 3 — Stratejik katman *(uzun vadeli tutundurma)*

| # | İş | Neden |
|---|---|---|
| 9 | **Mevsim döngüsü** (§3.1) | İlk kez uzun vadeli strateji; `marketSense`'i diriltir |
| 10 | **Araç künyesi** (§4.1) | Duygusal bağ, düşük maliyet |
| 11 | **Parça uyum sistemi** (§2.4) | Hurdalığı ana döngüye bağlar |
| 12 | **Kendi finansmanını sun** (§3.3) | `financeSense`'i diriltir, tycoon derinliği |

### Kademe 4 — Büyük yatırımlar

| # | İş |
|---|---|
| 13 | Restorasyon projesi araçları (§2.5) |
| 14 | Usta yetiştirme sistemi (§4.3) |
| 15 | Vitrin yerleşimi (§4.2) |

---

## Kapanış

Eğer bu listeden **tek bir şey** seçilecekse: **§1.1 — 16 rastgele olayı devreye almak.** Sıfır tasarım maliyeti, sıfır yeni içerik, oyunun tonunu en iyi taşıyan malzeme, ve şu an tamamen çöpe gidiyor.

Eğer **tek bir yeni mekanik** seçilecekse: **§2.1 — İlan Hazırlama Sanatı.** Oyunun adı, kültürel dokusu ve en zayıf noktası (satış öncesi ölü zaman) aynı yerde kesişiyor. Üç mevcut sistemi birbirine bağlayarak, yeni bir sistem icat etmeden, oyuncuya oyunun şu an sunmadığı şeyi verir: **satıştan önce yapacak anlamlı bir iş.**

Ve genel bir tavsiye: yeni özellik eklemeden önce Bölüm 1'i kapatmak, projedeki "üret ama bağlama" örüntüsünü kırmak açısından da değerli olur.

---

*Bu rapor `lib/` kaynak kodunun okunmasına dayanır. Hiçbir dosya değiştirilmedi.*
