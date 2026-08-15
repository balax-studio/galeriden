# Galerisinden — Dramatik Karar Kartları Tasarım Raporu

**Konu:** Oyuncuyu gerçek riskli, bazen trajik, bazen psikolojik ikilemlere zorlayan yeni bir kart sistemi.
**Kapsam:** Yalnızca tasarım/içerik önerisi. Kod taranmadı, hiçbir dosya okunmadı veya değiştirilmedi — bu rapor, oturum boyunca edinilen oyun evreni bilgisine (karakterler, ton, ekonomi) dayanır.

---

## 0. Neden Bu Sistem Gerekli

Oyunda zaten bir hikâye kartı sistemi var (`StoryCardModel`, 8 kart) ama o sistemin karakteri tek yönlü: reklam izle → **her zaman olumlu** bir ödül al. Risk yok, kayıp yok, karar zor değil — "Evet" demek her zaman doğru cevap.

Bu, kısa vadede rahatsızlık üretmez ama uzun vadede iki şeyi öldürür: **anlatının ağırlığını** (hiçbir seçimin bedeli yoksa hiçbir seçim akılda kalmaz) ve **oyuncunun tetikte olma hissini** (galerisinin güvende olmadığını hissetmeyen oyuncu, galerisine bağlanmaz).

Önerilen sistem bunun tam tersini yapıyor: **gerçek kayıp riski taşıyan, doğru cevabı olmayan, bazen oyuncuyu pişman edecek kararlar.** İki referans nokta:

- **This War of Mine / Reigns** tarzı ikilem kartları — her seçenek bir şeyi kazandırır, bir şeyi feda ettirir.
- Oyunun kendi mirası: **Dede Hasan Usta'nın Tofaşk Hacı Murat 124'ü.** Oyun zaten "miras", "emek", "güven" temalarıyla açılıyor. Bu kartlar o duygusal zemini genişletir, ondan kopmaz.

**Temel ilke: her kart gerçek bir bedel taşımalı.** Bir seçenek her zaman güvenliyse, kart bir ikilem değil bir formaliteye dönüşür.

---

## 1. Tasarım İlkeleri

1. **İki seçenek de gerçek bir şey feda ettirmeli.** "Kabul et → kazan, reddet → hiçbir şey olmaz" asla olmamalı. Reddetmenin de bir bedeli veya kaçırılan bir fırsatı olmalı.
2. **Sonuç olasılıksal olmalı, garanti olmamalı.** Aynı seçim iki farklı oyuncuda (veya aynı oyuncuda iki farklı seferde) farklı sonuç verebilmeli — bu, kartın tekrar oynanabilirliğini ve anlatılabilirliğini artırır ("bende öyle olmadı, bana ihanet etti" hikâyeleri retention'ın kendisidir).
3. **Önsezi (foreshadowing) şart, ama garanti değil.** Oyuncu "bu riskli" hissini almalı (metin tonundan, karakterin güvenilmezliğinden) ama kesin sonucu bilmemeli. Sinyal ver, sonucu gizle.
4. **Kayıp asla oyunu bitirmemeli.** İflas soft-lock'a yol açacak kadar ağır bir kayıp olmamalı; en ağır sonuç bile "acı ama devam edilebilir" olmalı.
5. **Her trajik kartın psikolojik bir karşılığı olmalı.** Salt para cezası sıkıcıdır. Kayıp bir duyguya bağlanmalı: pişmanlık, güven kaybı, vicdan azabı, nostalji.
6. **Tekrar oynanabilir ama nadir.** Bu kartlar StoryCardModel'in 7-21 günlük ritminden **daha seyrek** görünmeli (önerilen: 15-30 oyun günü) — sıklaşırsa "kader" hissi "sıradan risk"e döner.

---

## 2. Kart Taksonomisi (5 Kategori)

| Kategori | Ne riske ediliyor | Duygu |
|---|---|---|
| **A. Kayıp Kartları** | Para | Pişmanlık, açgözlülük cezası |
| **B. İhanet & Çalınma Kartları** | Araç, envanter | Güvensizlik, savunmasızlık |
| **C. Vicdan Kartları** | İtibar, ahlaki konum | Suçluluk, ikircik |
| **D. Miras Kartları** | Duygusal/sembolik varlık | Nostalji, bağlılık |
| **E. Kumar Kartları** | Her şey (çift yönlü risk) | Heyecan, adrenalin |

Aşağıdaki 16 kart, bu beş kategoriye dağılmış somut örneklerdir. Her biri oyunun mevcut karakter evrenini (Haydar Usta, karaborsa figürleri, Dede Hasan Usta mirası) kullanır veya genişletir — böylece anlatı tutarlı kalır.

---

## 3. Örnek Kart Seti

### KATEGORİ A — Kayıp Kartları

---

**A1 · "Acil Nakit İhtiyacı"**
> **Karakter:** Eski Ortak Necati
> **Bağlam:** Galerinin kapısında, gözleri çukura kaçmış bir adam. Yıllar önce beraber iş yaptığınız Necati.
>
> *"Usta... biliyorum aramız iyi değildi ama başım dertte. Kızımın ameliyatı var, elimde avucumda hiçbir şey kalmadı. ₺40.000 versen, bir ay içinde ikiye katlayıp öderim, söz."*
>
> **Seçenek 1 — Ver:** %55 ihtimalle 30 gün içinde ₺80.000 olarak geri gelir + itibar +5 ("cömert galerici" söylentisi yayılır). %45 ihtimalle Necati bir daha görünmez, ₺40.000 gider, hiçbir açıklama gelmez.
> **Seçenek 2 — Verme:** Hiçbir kayıp yok, ama itibar −3 ("Necati'ye yüzüne bile bakmadı" lafı sanayi esnafında dolaşır).
>
> *Tasarım notu: klasik borç ver/verme ikilemi. "Cömertlik her zaman ödüllendirilmez" mesajı önemli — %45 kayıp oranı, kartın gerçek bir kumar olduğunu garantiler.*

---

**A2 · "Sahte Ekspertiz Teklifi"**
> **Karakter:** Bir ekspertiz firması temsilcisi
> **Bağlam:** Elinde bir zarf, gülümseyerek yaklaşır.
>
> *"Usta, o hasarlı Bemeve'yi 'hatasız' raporla süsleyebilirim. ₺8.000 ver, kâğıt üstünde tertemiz çıksın. Kimse anlamaz."*
>
> **Seçenek 1 — Kabul et:** Aracın ekspertiz raporu anında "A+ Kusursuz" olur (satış fiyatı yükselir), ama müşteri ilerde ekspertize soktururken %30 ihtimalle yakalanma riski aynı satışa bağlı kalır (mevcut sahtekârlık cezası mekaniğiyle aynı mantık: itibar cezası + para cezası).
> **Seçenek 2 — Reddet:** ₺8.000 harcanmaz, ama araç gerçek durumuyla satılmak zorunda — daha düşük fiyat.
>
> *Tasarım notu: bu kart aslında oyunun var olan "beyan tipi" (dürüst/hatasız iddiası/km düşürme) mekaniğinin dramatize edilmiş bir dış temsilcisi. Yeni mekanik gerekmez, var olan risk formülüne bir giriş noktası ekler.*

---

**A3 · "Vergi Denetimi Söylentisi"**
> **Karakter:** Muhasebeci Kemal Bey
> **Bağlam:** Telefonla arar, sesi telaşlı.
>
> *"Patron, bu ay defterlerde ufak tefek karışıklıklar var. Denetim gelirse başımız derde girer. ₺15.000'e bu işi 'hallederim' diyen biri var — riske girmek ister misin?"*
>
> **Seçenek 1 — Öde:** %70 ihtimalle hiçbir şey olmaz (para gider, sorun "çözülür"). %30 ihtimalle hem para gider hem de itibar −10 ("rüşvet" söylentisi çıkar).
> **Seçenek 2 — Ödeme, riske gir:** %20 ihtimalle gerçek bir denetim gelir ve ceza öder (parayı zaten ödeyeceğinden daha fazla), %80 ihtimalle hiçbir şey olmaz, hiçbir kayıp yok.
>
> *Tasarım notu: burada "güvenli" görünen seçenek (öde) aslında istatistiksel olarak daha riskli — oyuncunun sezgisini test eden bir kart.*

---

### KATEGORİ B — İhanet & Çalınma Kartları

---

**B1 · "Gece Yarısı Telefonu"** ← *En ağır kart, dikkatli konumlandırılmalı*
> **Karakter:** Gece bekçisi Şükrü Amca
> **Bağlam:** Sabaha karşı telefon çalar.
>
> *"Patron... galerinin arka kapısı kırık. Biri içeri girmiş. Vitrindeki en değerli araç yerinde yok."*
>
> **Sonuç (kart, seçim değil, doğrudan olay):** Oyuncunun envanterindeki **en yüksek değerli araç** çalınır (kalıcı kayıp). Ama karta bir "sonrası" eklenir:
> **Seçenek 1 — Sigorta soruşturması başlat (₺5.000 masraf):** 10 gün sonra %40 ihtimalle araç bulunur (hasarlı geri gelir, %60 değerinde), %60 ihtimalle bulunamaz.
> **Seçenek 2 — Unut, devam et:** Masraf yok, ama araç kesin kayıp.
>
> *Tasarım notu: bu, sistemin en travmatik kartı olmalı ve nadiren tetiklenmeli (yılda 1-2 kez, yalnızca oyuncunun envanterinde ₺500.000+ değerinde en az bir araç varken). Amaç ceza değil, an — oyuncunun "galerim güvende değil" hissini bir kez, unutulmayacak şekilde yaşaması. Sık tekrarlanırsa cezalandırıcı ve adaletsiz hisettirir; StoryCardModel'in 7-21 günlük ritmiyle KARIŞTIRILMAMALI, çok daha seyrek bir "kader olayı" katmanında durmalı.*

---

**B2 · "Güvenilir Çalışanın Teklifi"**
> **Karakter:** Uzun süredir yanınızda çalışan bir usta (oyuncunun `hiredStaff` listesinden biri, isim dinamik)
> **Bağlam:** Mesai sonrası, gözlerini kaçırarak konuşur.
>
> *"Patron, bir teklif aldım. Rakip galeriden. Maaşımı iki katına çıkarıyorlar ama... sana da bir şey söylemem lazım: gitmeden önce bizim müşteri listesini onlara götürmemi istediler. Sana sadık kalmamı istersen, zam yapman lazım."*
>
> **Seçenek 1 — Zam yap (günlük maaşın %40 fazlası):** Personel kalır, sadakat bonusu (performansı +%10). Uzun vadede maliyetli.
> **Seçenek 2 — Zam yapma:** %50 ihtimalle personel ayrılır ama müşteri listesini götürmez (nötr sonuç), %50 ihtimalle ayrılır VE 5 gün içinde itibar −8 ("eski çalışanları rakiplere kaptırıyor" söylentisi).
> **Seçenek 3 — Şimdi kov (ihanet riskini göze alma):** Personel gider, tazminat ödenmez ama %25 ihtimalle itibar −12 (haksız kovulma söylentisi).
>
> *Tasarım notu: üç seçenekli, klasik "sadakat satın al mı" ikilemi. Doğru cevap yok — hepsi bir şeyi feda ettiriyor (para, itibar riski, ya da personel).*

---

**B3 · "Sahte Alıcı, Gerçek Dolandırıcı"**
> **Karakter:** "Cüzdanını Unutan Adam" — çekici, kibar bir alıcı
> **Bağlam:** Aracı beğenir, coşkuyla anlatır, sonra "cüzdanımı arabada unuttum, sen anahtarı ver bir çıkarayım" der.
>
> **Seçenek 1 — Anahtarı ver, güven:** %65 ihtimalle gerçekten cüzdanını alıp döner ve satış tamamlanır (normal fiyat). %35 ihtimalle araçla birlikte kaybolur — **araç kalıcı kayıp, hiçbir tazminat yok.**
> **Seçenek 2 — Önce parayı gör, sonra anahtarı ver:** Satış gerçekleşmez (alıcı gücenip gider), ama hiçbir risk yok.
>
> *Tasarım notu: en klasik "sokak tuzağı" senaryosu — gerçekçi, oyuncunun "ben bunu biliyorum, tuzağa düşmem" diye düşünüp yine de bazen düşeceği bir kart. B1'den daha hafif ama aynı aileden (araç kaybı riski).*

---

**B4 · "Karaborsa İhbarı"**
> **Karakter:** Gölge İbrahim (karaborsa evreninden tanıdık bir isim — devamlılık için)
> **Bağlam:** Daha önce karaborsadan araç aldıysanız bu kart tetiklenir.
>
> *"Usta, o aldığın araç hakkında soruşturma açıldı. Polis kapına gelmeden ben hallederim ama bedeli var. Ya öde, ya da aracı şimdi elden çıkar, riski bana bırak."*
>
> **Seçenek 1 — Rüşvet öde (aracın değerinin %15'i):** Sorun kapanır, araç güvenle elde kalır.
> **Seçenek 2 — Aracı hemen elden çıkar (piyasa değerinin %60'ına, acil satış):** Risk sıfırlanır ama büyük zarar.
> **Seçenek 3 — Hiçbir şey yapma:** %50 ihtimalle olay kapanır (blöftü), %50 ihtimalle araç el konur (kalıcı kayıp) + itibar −15.
>
> *Tasarım notu: bu, oyunun var olan karaborsa riskini (satın alma anındaki %20-35 "polis yakalama riski") satın alma sonrasına taşıyan bir takip kartı — karaborsadan araç almanın bedelini tek seferlik bir zar atışından, süregelen bir gerilime çevirir.*

---

### KATEGORİ C — Vicdan Kartları

---

**C1 · "Dul Kadının Arabası"**
> **Karakter:** Yaşlı bir kadın, kocasından kalan arabayı satmaya gelir.
> **Bağlam:** Araç ekspertizden geçer — sizin bildiğiniz gerçek değeri kadının söylediğinden çok daha yüksek. Kadın hiçbir fikri olmadığını, "eşim ne derse o" dediğini anlatır.
>
> **Seçenek 1 — Gerçek değerini söyle, adil fiyat teklif et:** Daha düşük kâr marjı, ama itibar +8 ve **nadir bir "dürüst galerici" başarımı** tetiklenir.
> **Seçenek 2 — Söylediği düşük fiyata al:** Yüksek kâr marjı, ama hiçbir ceza yok — **bu tam olarak mesele:** oyun bunu cezalandırmaz, tamamen oyuncunun vicdanına bırakılır.
>
> *Tasarım notu: bu kartta kasıtlı olarak "kötü" seçimin mekanik cezası yok. Amaç, oyuncuya bir ahlaki ayna tutmak — bazı kartların bedeli parasal değil, tamamen oyuncunun kendi rahatsızlığı olmalı. Bu, tüm sette en "psikolojik" olan kart.*

---

**C2 · "Rakibin Zor Günü"**
> **Karakter:** Rakip galericilerden biri (varsa "Rakip Galeri Sistemi" mekaniğiyle, yoksa jenerik bir isimle)
> **Bağlam:** Rakip galerinin nakit sıkıntısı olduğu, envanterini zararına elden çıkarmaya çalıştığı haberi gelir.
>
> **Seçenek 1 — Fırsatı değerlendir, ucuza topla:** Piyasa altı fiyata 1-2 araç alma şansı; ama rakip galeri kapanırsa (uzun vadede) piyasadaki rekabet azalır — bu iyi de olabilir kötü de (fiyatlar sizin lehinize kayar ama pazar canlılığı azalır).
> **Seçenek 2 — Teklif verme, rakibin toparlanmasını bekle:** Hiçbir kısa vadeli kazanç yok, ama itibar sanayi esnafı arasında yükselir ("centilmen galerici").
>
> *Tasarım notu: rakip galeri sistemi henüz kodda yok (retention raporunda önerilmişti); bu kart o sistem eklenirse doğrudan kullanılabilir, eklenmezse jenerik bir "meslektaşın zor günü" hikâyesi olarak da çalışır.*

---

**C3 · "Genç Çiftin İlk Arabası"**
> **Karakter:** Heyecanlı, bütçesi çok kısıtlı genç bir çift.
> **Bağlam:** Beğendikleri araç bütçelerinin biraz üstünde. "Bu bizim ilk arabamız olacak, evleniyoruz" derler.
>
> **Seçenek 1 — Fiyatı kır, kârdan feragat et:** Düşük/sıfır kâr, ama itibar +6 ve galeri "sıcak" bir söylenti kazanır (gelecekte %5 daha fazla organik teklif olasılığı — küçük, kalıcı bir bonus).
> **Seçenek 2 — Standart fiyatta ısrar et:** Normal kâr, çift üzgün ayrılır, hiçbir ceza yok ama hiçbir kazanç da yok.
>
> *Tasarım notu: C1'in tersine burada küçük ve kalıcı bir mekanik ödül var — "iyilik her zaman cezasız kalır ama bazen ödüllenir" dengesini kurmak için. Tüm vicdan kartları cezasız olursa "iyilik anlamsız" hissi oluşur; bu kart onu dengeler.*

---

### KATEGORİ D — Miras Kartları

---

**D1 · "Dede'nin Eski Ortağı"**
> **Karakter:** Yaşlı bir adam, Hasan Usta'nın (dede) eski çırağı olduğunu söyler.
> **Bağlam:** *"Ustan bana bir söz vermişti — o Murat 124'ü asla satmayacaktı. Şimdi senin elinde, biliyorum paran lazım ama... o arabanın hikâyesini biliyor musun gerçekten?"*
>
> **Eğer miras araç (Tofaşk Hacı Murat 124) hâlâ elinizdeyse:**
> **Seçenek 1 — Aracı asla satmayacağına söz ver:** Araç kalıcı olarak "Aile Yadigârı" statüsü kazanır (satılamaz hale gelir), karşılığında küçük kalıcı bir itibar bonusu (+3, kalıcı).
> **Seçenek 2 — "Zamanı geldi, hayat devam ediyor" de:** Hiçbir mekanik değişiklik yok, ama karakterin hayal kırıklığı diyaloğu oyuncuya gösterilir.
>
> **Eğer miras araç zaten satılmışsa (farklı diyalog):**
> Karakter üzgün ayrılır, hiçbir mekanik sonuç yok — **saf duygusal geri bildirim.** ("Keşke tutsaydın" dedirtme anı.)
>
> *Tasarım notu: bu kart, retention raporundaki "Koleksiyon Vitrini" önerisiyle doğrudan örtüşüyor — miras aracı satmak yerine kalıcı bir sembolik varlığa çevirme yolu. Oyuncunun Gün 1'de verdiği kararın (miras aracı sattı mı, tuttu mu) haftalar sonra geri gelen bir yankısı.*

---

**D2 · "Eski Fotoğraf"**
> **Karakter:** Yok — bir zarf, galerinin kapısının altından bırakılmış.
> **Bağlam:** İçinde eski, sararmış bir fotoğraf: genç Hasan Usta, aynı sanayi sokağında, ilk galerisinin önünde. Arkasında el yazısı: *"Bir gün torunum burayı benden daha büyük yapacak."*
>
> **Seçenek yok — saf anlatı kartı.** Oyuncuya sadece gösterilir, "Devam Et" butonu vardır. Karşılığında küçük bir XP bonusu (50-100) "duygusal an" olarak verilir.
>
> *Tasarım notu: her kartın bir ikilem olması gerekmez. Bazen amaç sadece **duraklatmak** ve oyuncuya ne inşa ettiğini hatırlatmaktır. Bu tür "seçimsiz" kartlar, seçimli kartların ağırlığını artırır çünkü ritmi kırar — hepsi ikilem olursa ikilem sıradanlaşır.*

---

**D3 · "Kardeşin Payı"**
> **Karakter:** Oyuncunun hiç bahsedilmemiş bir "kuzeni" — Hasan Usta'nın başka bir torunu.
> **Bağlam:** *"Dedemin sana bıraktığı her şeyde benim de hakkım var. Mahkemeye vermeden konuşalım — sana ₺60.000 nakit teklif ediyorum, karşılığında bir daha bu galeriyle ilgili hiçbir hak iddia etmeyeceğim, imza atarım."*
>
> **Seçenek 1 — Parayı al, imzayı al:** ₺60.000 hemen kasaya girer. Anlatı kapanır.
> **Seçenek 2 — Reddet, "bu miras bölünmez" de:** Hiçbir mekanik kazanç yok, ama itibar +4 ("aile onurunu korudu" söylentisi) ve karakterin saygıyla ayrıldığı bir diyalog.
> **Seçenek 3 — Ondan da payını iste, pazarlık et:** %50 ihtimalle daha yüksek bir anlaşmayla kapanır (₺90.000), %50 ihtimalle küskün ayrılır ve hiçbir şey alınmaz.
>
> *Tasarım notu: doğrudan nakit teklifiyle "kolay para" cazibesi kurup karşısına aile/onur temasını koyan klasik bir ahlaki tuzak. Üç seçenek de makul; hangisinin "doğru" olduğu oyuncunun değerlerine bağlı.*

---

### KATEGORİ E — Kumar Kartları

---

**E1 · "Kapalı Zarf İhalesi"**
> **Karakter:** Gizemli bir aracı, ihale evreninden.
> **Bağlam:** *"İçinde ne olduğunu söylemiyorum ama zarfı ₺50.000'e satıyorum. Bazen bir koleksiyon parçası çıkar, bazen hurda çıkar. Şansını dener misin?"*
>
> **Seçenek 1 — Al, riske gir:** %10 nadir/koleksiyon araç (piyasa değeri ₺500.000+), %30 ortalama araç (₺80.000-150.000 değerinde, kâr), %60 hurda/düşük değer (net zarar).
> **Seçenek 2 — Alma:** Hiçbir risk yok, hiçbir kazanç yok.
>
> *Tasarım notu: saf, şeffaf bir kumar kartı — dramatik gerilim yok, doğrudan olasılık oyunu. Setin "eğlence" ucu; diğer kartların ağırlığına karşı bir nefes alma noktası.*

---

**E2 · "Çifte veya Hiç"**
> **Karakter:** Elinizdeki en değerli aracı almak isteyen agresif bir alıcı.
> **Bağlam:** *"Bu aracı normal fiyatına alırım ama sana bir teklifim var: yazı tura at. Tura gelirse aracı %80 fazlasına alırım. Yazı gelirse... aracı bedavaya bırakırsın."*
>
> **Seçenek 1 — Kabul et, riske gir:** %50 ihtimalle aracın değerinin %180'ine satılır (büyük kâr), %50 ihtimalle araç bedavaya gider (**tam kayıp**).
> **Seçenek 2 — Reddet, normal sat:** Standart fiyat, sıfır risk.
>
> *Tasarım notu: en agresif kumar kartı — %50/%50, tam kazanç veya tam kayıp. Sık sunulmamalı (nadir, yüksek değerli araçlarla sınırlı) çünkü tekrar tekrar görülürse oyuncuyu obje olarak değil sayı olarak görmeye başlar.*

---

## 4. Mekanik Çerçeve Önerisi (Kavramsal — Kod Değil)

Bu bölüm uygulama detayı değil, **nasıl bir sistemin bu kartları taşıyabileceğine dair kavramsal bir çerçeve.**

- **Tetikleme sıklığı:** StoryCardModel'in 7-21 günlük ritminden ayrı, daha seyrek bir katman — 15-30 oyun günü arası. Amaç: bu kartların "sıradan içerik" değil, **anılan anlar** olarak kalması.
- **Ağırlıklı seçim:** Kategori E (kumar) ve B1 (gece yarısı hırsızlığı) gibi en ağır kartlar, toplam havuzun küçük bir yüzdesi olmalı (örn. %10-15); Kategori A ve C gibi daha hafif kartlar daha sık gelmeli. Her seferinde en travmatik kart çıkarsa sistem adaletsiz hisettirir.
- **Bağlama duyarlılık:** B4 (Karaborsa İhbarı) gibi kartlar yalnızca oyuncu ilgili eylemi yapmışsa (karaborsadan araç almış) havuza girmeli — rastgele bir oyuncuya hiç yapmadığı bir şeyin cezası gelmemeli. D1/D3 gibi miras kartları, miras aracın hâlâ elde olup olmamasına göre dallanmalı.
- **Kayıp tavanı:** Hiçbir kart, oyuncunun toplam varlığının belirli bir oranından (örn. %25) fazlasını tek seferde riske atmamalı. B1 istisnası bile en pahalı **tek aracı** hedef alıyor, tüm envanteri değil.
- **Anlatı hafızası:** Kartların sonuçları küçük bir "geçmiş" olarak tutulabilirse (örn. "Necati'ye güvenmiştin, seni kandırmıştı" gibi ileride başka bir kartta referans verilebilir bir hafıza), tekrarlayan karakterler duygusal ağırlığı katlar. Şu an oyunda `recentEvents` benzeri bir olay geçmişi kavramı zaten var — bu tür bir hafıza doğal bir uzantı olur.

---

## 5. Ton ve Etik Sınır

- **Asla saf ceza hissi vermemeli.** Her kayıp kartının bir anlatısı olmalı — oyuncu "sistem beni cezalandırdı" değil "ben bu kararı verdim ve bedelini ödedim" hissetmeli. Bu ayrım, Retention raporunda (§6) çizilen etik sınırla aynı mantık: sömürü değil, kurgu içi sonuç.
- **En ağır kartlar (B1, E2) nadir ve öngörülür şekilde konumlanmalı.** Oyuncu galerisi küçükken veya ilk haftasındayken bu kartlar tetiklenmemeli — D1 retention'ı, kurulmamış bir bağı yıkarak zedelenir. Bu kartların hedef kitlesi, oyuna yatırım yapmış (Lv3+) oyunculardır.
- **Vicdan kartları (C1, C3) için mekanik ceza olmamalı.** "Kötü" seçim mekanik olarak cezalandırılırsa, kart bir optimizasyon problemine döner ve ahlaki ağırlığını kaybeder. Ceza yerine sessizlik veya küçük bir fırsat maliyeti yeterli.
- **Şeffaflık:** Kart metninin tonu her zaman riski sezdirmeli (gözlerini kaçıran karakter, "cüzdanımı unuttum" gibi klişe uyarı sinyalleri). Amaç oyuncuyu kör noktadan vurmak değil, "bunu biliyordum ama yine de riske girdim" dedirtmek.

---

## 6. Özet Tablo

| # | Kart | Kategori | Risk Türü | Şiddet |
|---|---|---|---|---|
| A1 | Acil Nakit İhtiyacı | Kayıp | Para | Orta |
| A2 | Sahte Ekspertiz Teklifi | Kayıp | Para + İtibar | Orta |
| A3 | Vergi Denetimi Söylentisi | Kayıp | Para + İtibar | Düşük |
| B1 | Gece Yarısı Telefonu | İhanet/Çalınma | Araç (kalıcı) | **Yüksek** |
| B2 | Güvenilir Çalışanın Teklifi | İhanet/Çalınma | Personel + İtibar | Orta |
| B3 | Sahte Alıcı, Gerçek Dolandırıcı | İhanet/Çalınma | Araç (kalıcı) | Yüksek |
| B4 | Karaborsa İhbarı | İhanet/Çalınma | Araç + Para + İtibar | Yüksek |
| C1 | Dul Kadının Arabası | Vicdan | Kâr marjı (saf ahlaki) | Düşük |
| C2 | Rakibin Zor Günü | Vicdan | Fırsat maliyeti | Düşük |
| C3 | Genç Çiftin İlk Arabası | Vicdan | Kâr marjı | Düşük |
| D1 | Dede'nin Eski Ortağı | Miras | Sembolik/duygusal | Yok (mekanik) |
| D2 | Eski Fotoğraf | Miras | Yok (saf anlatı) | Yok |
| D3 | Kardeşin Payı | Miras | Para/İtibar seçimi | Orta |
| E1 | Kapalı Zarf İhalesi | Kumar | Para | Orta |
| E2 | Çifte veya Hiç | Kumar | Araç (tam risk) | **Yüksek** |

---

*Bu rapor tamamen içerik/tasarım önerisidir. Hiçbir kaynak dosya okunmadı veya değiştirilmedi; karakterler ve ton, oturum boyunca incelenen mevcut anlatı unsurlarıyla (Dede Hasan Usta, karaborsa karakterleri, itibar sistemi) tutarlı kalacak şekilde kurgulanmıştır.*
