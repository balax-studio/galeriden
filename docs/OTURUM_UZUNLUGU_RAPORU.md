# Galerisinden — Davranışsal Tasarım & Oturum Uzunluğu Raporu

**Konu:** Oyuncunun ilk oturumlarda saatler geçirmesini sağlayacak davranışsal mekanikler.
**Kapsam:** Yalnızca rapor. Kod değiştirilmedi.

---

## 0. Çerçeve

Oturum uzunluğu tek bir mekanikle değil, **üst üste binen mekanizmalarla** uzar. Aşağıdaki 16 mekanizmayı beş katmanda gruplandırdım. Her katman farklı bir psikolojik sisteme basar; birlikte kullanıldıklarında çarpan etkisi yaparlar.

| Katman | Ne yapar | Oturum etkisi |
|---|---|---|
| 1. Dopamin döngüsü | Beklenti üretir | Anlık tekrar |
| 2. Kapatılmamış döngü | Bırakmayı zorlaştırır | Oturum uzar |
| 3. Sahiplik & yatırım | Terk maliyetini yükseltir | Geri dönüş |
| 4. Taahhüt & tutarlılık | Kararı kimliğe bağlar | Uzun vade |
| 5. Çerçeveleme | Aynı içeriği daha değerli gösterir | Her yerde |

**Temel prensip:** Oyuncuyu tutmaya çalışma — **her doğal durma noktasını yok et.**

---

# KATMAN 1 — DOPAMİN DÖNGÜSÜ

## 1.1 · Değişken Oranlı Pekiştirme *(en güçlü tek mekanizma)*

Sabit ödül alışkanlık yaratmaz; **öngörülemez ödül** yaratır. Kritik incelik: belirsizlik **ödülün büyüklüğünde** olmalı, **zamanlamasında değil.** Belirsiz zamanlama beklenti değil can sıkıntısı üretir.

**Galerisinden'de:** Ziyaretçi ne zaman geleceği **görünür sayaçla belli** olsun; kim geleceği ve ne teklif edeceği belirsiz kalsın.

Ödül dağılımı dar değil **uzun kuyruklu** olmalı:

| Olasılık | Sonuç |
|---|---|
| %70 | Sıradan teklif |
| %20 | Ölücü teklif (hayal kırıklığı — gerekli) |
| %8 | Tam istediğin fiyat |
| **%2** | **Koleksiyoner: piyasanın %140'ı** |

O %2, oyuncunun haftalarca anlatacağı andır. Değişken oranlı pekiştirmede etkiyi yaratan ortalama değil, **nadir ve büyük olan uçtur.**

## 1.2 · Yakın Kaçırma (Near-Miss)

Nörolojik olarak kıl payı kaçırma, kazanmaya **yakın bir dopamin yanıtı** üretir ve anında tekrar deneme dürtüsü doğurur. Slot makinelerinin temel mekaniği budur.

**Galerisinden'de:** `negotiation_engine.dart` "yumuşak çekilme" durumunu zaten hesaplıyor ama alıcıyı sessizce siliyor. Göster:
> *"Alıcı ₺12.000 farkla masadan kalktı."*

İhale kaybında da aynısı: *"Sabırlı Mehmet seni ₺8.000 farkla geçti."* Ödül vermeden oturum uzatan en ucuz mekanik.

## 1.3 · Beklenti > Alma

Dopamin ödülün *alınması* anında değil, *beklenmesi* anında salgılanır. Şu an satış anı: butona bas → para düşer → toast. **Beklenti fazı yok.**

**Galerisinden'de:** Kabul ile paranın düşmesi arasına 1,5 sn dramaturji: noter animasyonu, `getSuspenseNegotiationText()` (yazılmış, kullanılmıyor), sonra sayacın tırmanışı. Ödül değişmez, **hissi katlanır.**

## 1.4 · Ödül Zincirleme (Cascading Rewards)

Her ödül, bir sonraki eylemi **anında mümkün kılan** bir şeyle birlikte gelmeli. Ekranda "bitti" hissi veren boş alan kalmamalı.

| Şu an | Olması gereken |
|---|---|
| Satış → para | Satış → para **+ "Yeni kelepir ilan eklendi"** |
| Seviye → yetenek puanı | Seviye → puan **+ açılan ekranın önizlemesi + git butonu** |
| Görev bitti → ödül | Ödül **+ anında yeni görev kartı** |

## 1.5 · Zirve-Son Kuralı (Peak-End Rule)

Bir deneyim, ortalamasıyla değil **en yoğun anı + nasıl bittiğiyle** hatırlanır. Oturumun ortasındaki 20 dakikalık sıkıcı bölüm, sonu güçlüyse hatırlanmaz.

**Galerisinden'de:** Her oturumun sonunda bir zirve yaratmaya çalış — çıkış kancası ekranı sadece "açık döngüler" değil, o oturumun **en iyi anını** da hatırlatsın: *"Bugünün en kârlı satışı: Murat 124 → +₺83.500."*

---

# KATMAN 2 — KAPATILMAMIŞ DÖNGÜ

## 2.1 · Zeigarnik & Ovsiankina Etkisi

Zeigarnik: yarım kalan görevler tamamlananlardan daha iyi hatırlanır.
Ovsiankina: yarım kalan görevi **tamamlama dürtüsü** kendiliğinden geri döner.

**Galerisinden'de:** Oyun asla "her şey bitti" ekranı göstermemeli. Her oturum en az bir açık döngüyle bitmeli: bir sipariş yolda, bir teklif bekliyor, bir görev %70'te. `PsychologyEngine.getOpenLoopsSummary()` **zaten yazılmış**, sadece bağlanmayı bekliyor.

## 2.2 · Hedef Gradyanı (Goal Gradient)

Hedefe yaklaştıkça çaba artar. %80 dolu bir çubuğu bırakma olasılığı, %10'dakinden çok daha düşük.

**Galerisinden'de:**
- XP çubuğu HUD'da **her zaman görünür**, kalan miktar sayı olarak: *"Seviye 3'e 240 XP"*
- Görevler **birden fazla** olsun; en az biri hep yarılanmış görünsün
- Koleksiyon albümü dashboard'da: *"12/30 model"*
- *"10 satışa 2 kaldı"* yakınlık bildirimleri

## 2.3 · Bağışlanmış İlerleme (Endowed Progress)

Klasik deney: 10 damgalı boş kart vs 12 damgalı ama 2'si **hediye dolu** kart. İkinci grup tamamlama oranını neredeyse **iki katına** çıkarır. Sıfırdan başlamak ile "zaten başlamış olmak" arasında büyük fark var.

**Galerisinden'de:**
- Yeni görevler `0/5` değil `1/5` başlasın ("ilk adımı senin için attık")
- Koleksiyon albümü miras araçla **zaten 1/30** olsun
- Başarım listesi ilk girişte 1 tanesi açılmış görünsün

Bu, en az bilinen ama en yüksek getirili mekanizmalardan biri.

## 2.4 · Zincirleme Görev Kuşağı

Tek tek görevler yerine 3-5 adımlık zincirler: *"Araç al → ekspertiz → onar → ilana koy → sat."* Her adım küçük ödül, zincir sonunda büyük ödül.

Zincir, zihinde **tek bir iş** olarak kodlanır; yarıda bırakmak psikolojik olarak zorlaşır. `MissionFactory` altyapısı hazır.

## 2.5 · Bekleme Süresini Karara Çevir

Boş bekleme = çıkış noktası. Dolu bekleme = oturum uzaması.

Teklif beklerken oyuncuya ücretli/ücretsiz eylemler ver: ilanı öne çıkar, fiyat kır, sosyal medyada paylaş, başka aracı hazırla.

---

# KATMAN 3 — SAHİPLİK & YATIRIM

## 3.1 · Sahiplik Etkisi (Endowment Effect)

İnsan sahip olduğu şeye, sahip olmadığı özdeş şeyden **yaklaşık 2 kat** fazla değer biçer. Sahiplik hissi ne kadar erken kurulursa terk maliyeti o kadar yükselir.

**Galerisinden'de:** Oyuncunun adı ve galerisinin adı **her yerde** görünmeli — satış sözleşmelerinde, müşteri diyaloglarında ("Selam Ahmet Usta"), ekspertiz raporlarında, liderlik tablosunda. Şu an `playerName` yalnızca 2 yerde görünüyor. Saf metin işi, en ucuz sahiplik kazancı.

## 3.2 · IKEA Etkisi

İnsan **kendi emeğiyle şekillendirdiği** şeye orantısız değer verir. Restorasyon oyunlarının çekirdek gücü budur.

**Galerisinden'de:** Onarımın **öncesi/sonrası** görsel karşılaştırması olmalı — kaydırıcıyla hasarlı ↔ onarılmış. Oyuncu emeğini *görmeli.* Şu an sadece bir sayı değişiyor. Araç künyesi (kimden alındı, neler yapıldı, ne kadar harcandı) bu etkiyi katlar.

## 3.3 · Kayıptan Kaçınma (Loss Aversion)

Kayıp, eşdeğer kazançtan **yaklaşık 2 kat** güçlü hissedilir. Ama kritik kural: kayıp **oyuncunun kendi kararından** doğmalı, sistemden değil.

**Galerisinden'de doğru kullanım:**
- Giriş serisi: kaybedilecek bir şey biriktikçe korumak için dönülür (`hasStreakFreeze` mekaniği var, kazanma yolu yok — ödül olarak verilmeli)
- Oturum içi çarpan: kesintisiz oyunda büyüyen ×1.1 → ×1.5 çarpan, çıkınca sıfırlanır. Cezalandırıcı değil, ödülü artırır. Tavan şart.
- Vitrinde kilitli koleksiyon araçları: kaybetmemek için geri dönülür

## 3.4 · Batık Maliyet (Sunk Cost) — Dikkatli Kullan

`PsychologyEngine.getSunkCostRepairText()` doğrudan bu yanılgıyı hedefliyor: *"Bu araca ₺X harcadın, bir parça daha..."*

**Önerim: yön değiştirsin.** Geçmiş harcamayı vurgulamak yerine **ileriye dönük net getiriyi** göster:
> *Bu parça ₺7.500 · Değer artışı ₺12.400 · **Net +₺4.900***

Aynı yerde, aynı anda, aynı eylemi teşvik eder — ama doğru bilgiyle. Ve dürüst versiyon uzun vadede **daha iyi** çalışır: oyuncu sayıların güvenilir olduğunu öğrenince onarım kararlarını daha rahat verir. `getNetRoiRepairText()` bu amaçla zaten yazılmış.

---

# KATMAN 4 — TAAHHÜT & TUTARLILIK

## 4.1 · Taahhüt & Tutarlılık İlkesi

İnsan, verdiği bir karara **tutarlı kalma** eğilimindedir — özellikle karar açıkça ifade edilmişse.

**Galerisinden'de:**
- Köken/uzmanlık seçimi ("Ben Restoratörüm") → sonraki tüm davranışı o kimliğe hizalar
- Dramatik kart D1: *"Bu arabayı asla satmayacağıma söz veriyorum"* → verilen söz, oyuncuyu bağlar
- Unvan sistemi: dürüst oynayanın taşıdığı isim, dürüst oynamaya devam etmesini teşvik eder

## 4.2 · Küçük Taahhütle Başla (Foot-in-the-Door)

Küçük bir evet, büyük evetlerin kapısını açar. Onboarding'de oyuncuya önce **çok küçük** bir seçim yaptır (amblem seç), sonra biraz büyüğü (galeri adı), sonra gerçek olanı (köken). Her adım bir öncekine yatırım ekler.

## 4.3 · Karşılıklılık (Reciprocity)

Karşılıksız verilen şey, geri verme borcu hissi yaratır.

**Galerisinden'de:** Oyunun ilk dakikasında beklenmedik bir hediye — *"Dedenin eski dostu Haydar Usta ilk ekspertizini bedava yaptı."* Küçük ama karşılıksız. Sonraki isteklerde (görev, geri dönüş) direnç düşer.

---

# KATMAN 5 — ÇERÇEVELEME

## 5.1 · Çapa Etkisi (Anchoring)

İlk görülen sayı, sonraki tüm değerlendirmeleri şekillendirir.

**Galerisinden'de:** İlan fiyatı belirlerken oyuncuya önce **piyasa değerinin %120'si** gösterilsin, sonra kaydırıcı. Aynı şekilde alıcı teklifinde önce "piyasa değeri ₺310.000" yazsın, sonra teklif. Aynı teklif daha iyi/kötü hissedilir.

## 5.2 · Yem Etkisi (Decoy Effect)

Üç seçenekten ortadaki, kasıtlı olarak kötü kurgulanmış üçüncüyle daha cazip görünür.

**Galerisinden'de:** Onarım kademeleri zaten üçlü (Çırak/Kalfa/Usta — ama sistem şu an ölü). Fiyatlandırma şöyle olmalı: Çırak ₺5.500 (%68 başarı) · Kalfa ₺10.000 (%88) · Usta ₺17.500 (%100). Ortadaki seçenek "akıllı seçim" gibi hissedilir. Aynı yapı doping/detay paketlerinde de kullanılabilir.

## 5.3 · Sosyal Kanıt (Social Proof)

Başkalarının davranışı, kararı meşrulaştırır.

**Galerisinden'de:** `getLiveViewerCount()` ve `getRandomFomoText()` yazılmış — ikincisi hiç kullanılmıyor. *"5 galerici bu aracı inceliyor"*. Bu **kurgusal NPC'ler hakkında** olduğu için meşru: oyuncu bunun oyunun kurgusu olduğunu bilir. Gerçek bir pazaryerinde sahte kıtlık üretmekten kategorik olarak farklı.

Rakip galeri liderlik tablosu (`RivalLeaderboardEngine` mevcut) da bu katmana girer.

## 5.4 · Kıtlık & FOMO — Ölçülü

Pazarda ara sıra **15 dakika geçerli** kelepir ilan: *"Sahibi yurt dışına çıkıyor, acil."*

Kritik kural: **kaçırmanın cezası olmamalı, sadece fırsat kaybı olmalı.** Ve gerçekten kıt olmalı — hep var olan sahte sayaç, bir kez fark edildiğinde tüm bildirimlere olan güveni bitirir.

## 5.5 · Erken Yoğun Zafer Serisi

İlk 20 dakikada oyuncu **8-10 kez** ödül almalı. Şu an ilk zafer ~10 dakika sürüyor ve arası boş.

| Dakika | Ödül |
|---|---|
| 0-1 | Kimlik seçimi → bonus (+ karşılıklılık hediyesi §4.3) |
| 2 | İlk ekspertiz → XP + başarım ilerlemesi |
| 3-5 | İlk onarım → **öncesi/sonrası animasyonu** (§3.2) |
| 6 | İlk ilan → vitrin kutlaması |
| 7-8 | İlk teklif bildirimi |
| 9-10 | İlk satış → para + XP + başarım + **seviye atlama** |
| 11 | Yeni görev + yeni pazar ilanları (§1.4) |

**Kritik:** İlk seviye atlama 10. dakikadan önce olmalı. Şu an 25-40 dakika.

---

# ÖNCELİK

| # | Mekanizma | Bölüm | Etki | Maliyet |
|---|---|---|---|---|
| 1 | Erken zafer takvimi | §5.5 | Çok yüksek | Orta |
| 2 | Ödül zincirleme | §1.4 | Çok yüksek | Orta |
| 3 | **Çıkış kancası** — zaten yazılmış | §2.1 | Yüksek | **Çok düşük** |
| 4 | İlerleme çubuklarını göster | §2.2 | Yüksek | Düşük |
| 5 | Bağışlanmış ilerleme (`1/5` başlat) | §2.3 | Yüksek | **Çok düşük** |
| 6 | Yakın kaçırma | §1.2 | Yüksek | Düşük |
| 7 | Uzun kuyruklu ödül dağılımı | §1.1 | Yüksek | Düşük |
| 8 | Öncesi/sonrası görseli | §3.2 | Yüksek | Orta |
| 9 | Beklenti duraklaması | §1.3 | Orta | Düşük |
| 10 | İsim/kimlik yayma | §3.1 | Orta | **Çok düşük** |
| 11 | Zincirleme görevler | §2.4 | Yüksek | Orta |
| 12 | Kademeli onarım + yem etkisi | §5.2 | Orta | Orta |
| 13 | Batık maliyeti net ROI'ye çevir | §3.4 | Orta | Düşük |
| 14 | Sosyal kanıt metinleri | §5.3 | Orta | **Çok düşük** |
| 15 | Oturum çarpanı | §3.3 | Orta | Düşük |
| 16 | Karşılıklılık hediyesi | §4.3 | Orta | Düşük |

---

# ÖNERMEDİKLERİM

Kısa vadede oturumu uzatır, orta vadede oyuncuyu kaybettirir:

| Teknik | Neden |
|---|---|
| Enerji/yakıt barı | Galerisinden'in akışkan temposunu (1 gün = 120 sn) öldürür |
| Yapay bekleme duvarı ("4 saat bekle veya öde") | Terk sebebi #1 |
| Sahte kıtlık (hep var olan "son 1 adet") | Bir kez fark edilince **tüm** bildirimlere güven biter — gerçek fırsatlar da çalışmaz |
| İlerlemeyi geri alan sistem cezaları | Kayıp oyuncunun kararından doğmalı |
| Reklamı ilerlemenin önüne koymak | Mevcut yerleşim (opsiyonel hızlandırma) doğru |
| Kaybedilen seriyi parayla geri alma | `hasStreakFreeze` **ödül** olarak verilmeli, satılmamalı |
| Klasik batık maliyet metni | §3.4 — net ROI versiyonu hem dürüst hem daha etkili |

Ortak mantık: oyuncunun zamanını **dolu** hissettiren mekanikler kalıcı, **tuzağa düşmüş** hissettirenler geçicidir. Bu bir ahlak tercihi değil, ölçülebilir bir LTV farkı.

---

## Kapanış

Tek bir şey yapılacaksa: **§5.5 — ilk seviye atlamayı 10. dakikanın altına indirmek.** İlk oturumda ilerleme hissi kurulmazsa, diğer 15 mekanizmanın uygulanacağı bir oyuncu kalmaz.

En ucuz üçlü: **çıkış kancası** (§2.1, kod yazılmış), **bağışlanmış ilerleme** (§2.3, görevleri `1/5` başlat), **isim yayma** (§3.1, saf metin). Üçü birlikte bir günden az iş, etkisi orantısız.

---

*Kod okumasına dayanır. Hiçbir dosya değiştirilmedi.*
