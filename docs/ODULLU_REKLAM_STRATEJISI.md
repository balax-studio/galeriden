# Galerisinden — Ödüllü Reklam Stratejisi Raporu

**Konu:** Oyuncuyu sıkmadan, tamamen tercihe dayalı biçimde ödüllü reklam izlenme oranını artırmak.
**Kapsam:** Yalnızca rapor. Kod değiştirilmedi.

---

## 0. Mevcut Durum

Oyunda `AdService.showRewardedAd` **üç yerde** çağrılıyor:

| # | Yerleşim | Durum |
|---|---|---|
| 1 | Ayarlar ekranı | ✅ Çalışıyor — ama oyuncu ayarlara nadiren girer |
| 2 | Atölye: parça kargosunu hızlandır | ❌ **Ölü** — `orderPart` arayüze bağlı olmadığı için `pendingOrders` hep boş, bu buton hiç görünmüyor |
| 3 | Hikâye kartları (8 kart) | ✅ Çalışıyor — 7-21 oyun günü = **14-42 gerçek dakikada bir** |

Gerçekçi tahmin: **oturum başına ~0,5-1 reklam.** İyi tasarlanmış bir tycoon oyununda bu sayı **oturum başına 3-6** olur. Yani sorun oyuncunun reklama direnci değil, **teklif edilecek anın olmaması.**

---

## 1. Temel İlke

> **Reklam, BEKLEMEYE veya KAYBETMEYE alternatif olmalı — OYNAMAYA değil.**

Bu tek cümle, "sıkıcı reklam" ile "memnuniyetle izlenen reklam" arasındaki farkın tamamıdır.

- ❌ *"Devam etmek için reklam izle"* → duvar → churn
- ✅ *"4:32 bekle **veya** 30 sn reklam izle"* → seçim → izlenme

İkinci formda oyuncu reklamı bir **kayıp** olarak değil, **kısayol** olarak algılar. Ve kritik olan: **bekleme seçeneği gerçekten uygulanabilir kalmalı.** Bekleme cezalandırıcı hale gelirse, seçim illüzyona döner ve oyuncu bunu hisseder.

İkinci ilke: **değer, butonun üstünde yazmalı.**

| ❌ Zayıf | ✅ Güçlü |
|---|---|
| "Reklam İzle" | "**+₺12.400 Kâr Ekle** (30 sn)" |
| "Bonus Al" | "**Ziyaretçiyi Şimdi Çağır** — 4:32 beklemek yerine" |
| "Ödül Kazan" | "**Seri Ödülünü 2× Yap: ₺25.000 → ₺50.000**" |

Oyuncu 30 saniyesini soyut bir "bonus" için değil, **somut bir sayı** için verir.

---

## 2. Beş Yerleşim Tipi

### A. Zaman Atlama *(en yüksek hacim)*

Oyunun temposu buna çok uygun: 1 oyun günü = 120 saniye, bekleme noktaları sık.

| Yerleşim | Tetikleyici | Buton metni |
|---|---|---|
| **Ziyaretçi çağır** ⭐ | Vitrindeki aracın geri sayımı (3-7 dk) | *"Ziyaretçiyi Şimdi Çağır (4:32 kaldı)"* |
| **Parça kargosu** | Sipariş bekliyor | *"Kargoyu Hızlandır"* — **kod zaten var, sadece `orderPart` bağlanmalı** |
| **İhale salonu** | Sonraki seans 45-180 sn | *"Salonu Şimdi Aç"* |
| **Hurdalık / Karaborsa stoğu** | 3 günde bir yenileniyor | *"Yeni Stok Getir"* |
| **Pazar ilanları** | Kısmi yenileme | *"Pazarı Tazele — 5 yeni ilan"* |

**Neden en yüksek hacim:** Oyuncu zaten bekliyor ve zaten sıkılıyor. Reklam burada oyunu kesintiye uğratmaz, **kesintiyi ortadan kaldırır.**

Kritik kural: Ziyaretçi çağırma **araç başına günde 1-2 kez** sınırlanmalı. Sınırsız olursa ziyaretçi kuyruğu mekaniği tamamen çöker ve oyun "reklam izle → sat" döngüsüne indirgenir.

### B. Kayıp Önleme *(en yüksek dönüşüm oranı)*

Kayıptan kaçınma, kazanç arzusundan ~2 kat güçlüdür. Bu yerleşimlerde izlenme oranı diğerlerinin 2-3 katıdır.

| Yerleşim | Tetikleyici | Buton |
|---|---|---|
| **Teklif süresi doluyor** | Son 1 saat | *"Alıcıyı 3 Saat Daha Tut"* |
| **Seri kırılmak üzere** | Bir gün kaçırıldı | *"Giriş Serini Koru: 12 gün"* — `hasStreakFreeze` alanı **zaten var, kazanma yolu yok** |
| **Onarım başarısız** | Çırak/Kalfa başarısızlığı | *"Usta Tekrar Denesin"* — `RepairTier` sistemi mevcut ama arayüze bağlı değil |
| **İhale kıl payı kaybedildi** | Rakip son anda geçti | *"Son Teklif Hakkı"* |
| **Nakit sıkışması** | Bakiye < ₺20.000 | *"Acil Nakit Desteği ₺25.000"* |

**Dikkat:** Dramatik kartların kötü sonucunu reklamla geri almayı **önermiyorum.** O kartların tüm değeri sonucun kalıcı olmasından geliyor; "tekrar dene" seçeneği anlatının ağırlığını yok eder.

### C. Ödül Katlama *(en yüksek memnuniyet)*

Oyuncunun zaten kazandığı anı büyütmek. Hiçbir kayıp hissi yok — saf artı.

| Yerleşim | Buton |
|---|---|
| **Satış tamamlandı** ⭐ | *"Kârı %50 Artır: ₺83.500 → ₺125.250"* |
| **Görev ödülü** | *"Ödülü 2× Yap"* |
| **Günlük seri ödülü** | *"₺25.000 → ₺50.000"* |
| **Koleksiyon kilometre taşı** | *"Milestone Ödülünü Katla"* |
| **Sözleşme teslimi** | *"Prim Bonusunu 2× Yap"* |

Satış anı özellikle değerli: oyuncu zaten dopamin zirvesinde, teklif olumlu bir sürpriz olarak gelir. **Oturum başına 3-6 satış** olduğu düşünülürse tek başına en yüksek hacimli B/C yerleşimi budur.

### D. Bilgi & Önizleme *(düşük hacim, yüksek algılanan değer)*

| Yerleşim | Buton |
|---|---|
| **Pazar ilanı ekspertizi** | *"Bu Aracı Bedava Ekspertiz Yaptır"* |
| **Pazarlıkta alıcı bütçesi** | *"Alıcının Tavan Fiyatını Gör"* |
| **İhalede rakip bütçesi** | *"Rakiplerin Limitini Öğren"* |
| **Mevsim/piyasa tahmini** | *"Gelecek Haftanın Trendini Gör"* |

Bu tip, ödülü **para değil bilgi** olduğu için ekonomiyi bozmaz — enflasyon yaratmadan reklam hacmi ekler. Az bilinen ama çok değerli bir kategori.

### E. Anlatı *(mevcut sistem — iyileştirilmeli)*

Hikâye kartları doğru tasarlanmış ama iki sorunu var:

1. **Frekans düşük:** 14-42 gerçek dakikada bir. 8-15 dakikaya indirilebilir (kart havuzu 8 → 15-20'ye çıkarılarak).
2. **Vaat-ödül uyumsuzluğu:** Bazı kartlar hâlâ anlattığından farklı şey veriyor. Oyuncu bunu ikinci-üçüncü seferde fark eder ve **tüm kartları reddetmeye başlar** — reklam geliri, anlatı ve retention aynı anda ölür. Bu, reklam gelirini artırmanın en ucuz yolu: mevcut izlenmeleri kaybetmemek.

---

## 3. Diegetik Çerçeve: Kendi Reklam Panon ⭐

Oyunda zaten **"Dijital Reklam Panosu & Medya Cephesi"** adlı bir yan işletme var (`SideBusinessType.billboard`). Bu, ödüllü reklamı **oyunun kurgusuna gömmek** için mükemmel bir fırsat:

> *"Galerinin cephesindeki LED panoya sponsor reklamı al — 30 saniye yayınla, kirasını kasana ekle."*

Neden güçlü:
- Reklam artık oyunun **dışından** gelen bir kesinti değil, **içinden** gelen bir gelir kalemi
- Oyuncunun rolüyle (galeri sahibi, reklam alanı kiralayan) tutarlı
- Panoyu yükselttikçe reklam ödülü artar → oyuncu **kendi isteğiyle** daha fazla reklam izlemek ister
- Ayarlar ekranındaki bağlamsız reklam butonunun yerine geçer

Bu, "reklamı tercihe sunma" isteğinin en zarif cevabı: oyuncu reklamı katlanılan bir şey olarak değil, **işlettiği bir varlık** olarak görür.

---

## 4. Günlük Sponsor Kontratı *(hacim çarpanı)*

Tek tek yerleşimler fırsat yaratır; asıl hacmi **günlük hedef** üretir.

> **Günlük Sponsor Kontratı** — Bugün izlediğin her reklam kontratı ilerletir:
> - 1. reklam → ₺15.000
> - 2. reklam → ₺35.000
> - 3. reklam → ₺60.000 + 1 Seri Koruma hakkı
> - 4. reklam → Nadir araç fırsatı
> - 5. reklam → **Günlük kontrat tamamlandı** (rozet + büyük bonus)

Neden çalışır:
- **Hedef gradyanı:** 3/5'te olan oyuncu 4. ve 5. reklamı izler
- **Bağışlanmış ilerleme:** kontrat 0/5 değil **1/5** başlasın
- Görünür ilerleme çubuğu dashboard'da dursun
- Ertesi gün sıfırlanır → günlük dönüş sebebi

Sektörde ödüllü reklam hacmini en çok artıran tek mekanik budur. Ama tavan (5) şart — sınırsız olursa oyun reklam izleme simülasyonuna döner.

---

## 5. Tasarım Kuralları

| # | Kural | Neden |
|---|---|---|
| 1 | **Her zaman çift seçenek** — "Bekle" / "İzle" | Tek seçenek = duvar |
| 2 | **Ödül butonun üstünde, rakamla** | Soyut ödül izlenmez |
| 3 | **Alternatif maliyeti göster** ("4:32 kaldı") | Karşılaştırma ikna eder |
| 4 | **Reklam yüklü değilse butonu gizle** | Şu an *"Reklam henüz hazır değil"* hatası gösteriliyor — bu bir başarısızlık deneyimi |
| 5 | **Yerleşim başına ayrı frekans limiti** | Global limit, iyi yerleşimleri kötülerin yüzünden bloklar |
| 6 | **İlk reklam yüksek ödülle** | Oyuncu "reklam = iyi anlaşma" öğrenir; ilk deneyim tüm sonrakileri belirler |
| 7 | **Frustrasyon anında teklif etme** | Oyunun sebep olduğu kayıptan hemen sonra reklam = sömürü hissi |
| 8 | **İlerlemeyi asla kilitleme** | Tek istisna yok |
| 9 | **Reklam sonrası ödülü görsel olarak kutla** | `FloatingMoneyOverlay` + `playCashSuccess()` (yazılmış, bağlı değil) |

---

## 6. Kaçınılması Gerekenler

| Teknik | Neden |
|---|---|
| **Interstitial (zorunlu geçiş reklamı)** | Ödüllü reklamın izlenme oranını düşürür — oyuncu "zaten reklam gördüm" hisseder. Bu oyunun akışkan temposuna da aykırı |
| Reklamı ilerlemenin önüne koymak | Terk sebebi #1 |
| Dramatik kart sonucunu reklamla geri alma | Anlatının ağırlığını yok eder |
| Sınırsız zaman atlama | Ziyaretçi kuyruğu mekaniği çöker |
| Reklam sonrası ikinci reklam teklifi | Güven kırıcı |
| Ödülü reklam sonrası küçültme / gizli kesinti | Bir kez fark edilirse hiçbir reklam bir daha izlenmez |

---

## 7. Öncelik & Tahmini Etki

| Sıra | İş | Ek reklam / oturum | Maliyet |
|---|---|---|---|
| 1 | **Satış sonrası "Kârı %50 Artır"** | +1,5-3 | Düşük |
| 2 | **Ziyaretçi çağır (zaman atlama)** | +1-2 | Orta |
| 3 | **Günlük Sponsor Kontratı** | +1-2 | Orta |
| 4 | **`orderPart`'ı bağla** → kargo hızlandırma canlanır | +0,5-1 | **Düşük — kod zaten yazılmış** |
| 5 | **Seri koruma** (`hasStreakFreeze` kazanma yolu) | +0,3 | **Çok düşük — alan zaten var** |
| 6 | Hikâye kartı vaatlerini düzelt | Mevcut izlenmeyi korur | Düşük |
| 7 | Teklif süresi uzatma | +0,5 | Düşük |
| 8 | Reklam Panosu diegetik çerçeve | Algı + hacim | Orta |
| 9 | Bilgi/önizleme yerleşimleri | +0,5 | Orta |
| 10 | Günlük ödül 2× | +0,5 | Düşük |

**Hedef:** oturum başına ~0,5-1 → **4-6**. Bu, reklam gelirinde yaklaşık **5-6 kat** artış demek — ve tamamı tercihe dayalı, hiçbir duvar eklemeden.

---

## Kapanış

Üç maddeyle özet:

1. **En ucuz kazanç:** `orderPart`'ı arayüze bağlamak. Kargo hızlandırma reklam yerleşimi **zaten yazılmış**, sadece hiç tetiklenmiyor. Sıfır yeni reklam tasarımı, doğrudan gelir.

2. **En yüksek hacimli tek yerleşim:** Satış sonrası kâr katlama. Oyuncu zaten dopamin zirvesinde, teklif olumlu sürpriz olarak geliyor, oturum başına 3-6 kez tekrar ediyor.

3. **En stratejik hamle:** Reklamı kendi Reklam Panonuza gömmek. Oyuncunun reklamla ilişkisini "katlandığım bir şey"den "işlettiğim bir gelir kalemi"ne çevirir — ve "sıkmadan, tercihe sunarak" isteğinizin tam karşılığı budur.

Son bir not: reklam gelirini artırmanın en gözden kaçan yolu, **mevcut izlenmeleri kaybetmemektir.** Hikâye kartlarındaki vaat-ödül uyumsuzluğu düzeltilmezse, oyuncu birkaç kart sonra hepsini reddetmeye başlar. Yeni yerleşim eklemeden önce bunu kapatmak, hiçbir maliyeti olmayan bir kazançtır.

---

*Kod okumasına dayanır. Hiçbir dosya değiştirilmedi.*
