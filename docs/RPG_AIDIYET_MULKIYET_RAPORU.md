# Galerisinden — RPG Derinliği, Aidiyet ve Mülkiyet Raporu

**Konu:** Oyunu RPG'ye yaklaştırmak; oyuncunun oyuna karşı **aidiyet** (bu benim hikâyem) ve **mülkiyet** (bu benim galerim) hissini geliştirmek.
**Yapı:** Önce mevcut sistemde düzeltilmesi/iyileştirilmesi gerekenler, sonra eklenmesi gereken özellikler.
**Kapsam:** Yalnızca rapor. Kod okundu, hiçbir dosya değiştirilmedi.

---

## 0. Teşhis: RPG Nedir, Oyunda Neden Yok?

RPG'nin özü **sayı büyütmek değildir** — sayı büyütmek her tycoon oyununda var. RPG'nin özü şudur:

> **Geri dönülemez seçimler yoluyla, oyuncunun kendisini tanımlayan benzersiz bir karakter inşa etmesi.**

Bu tanımı üç bileşene ayırırsak, Galerisinden'in şu anki durumu:

| RPG bileşeni | Tanım | Galerisinden'de |
|---|---|---|
| **Kimlik** (Identity) | "Ben kimim?" — karakterin kendine has bir tanımı | ⚠️ Bir isim ve bir amblem var, ötesi yok |
| **Seçim** (Build) | "Neyi seçtim, neyden vazgeçtim?" — fırsat maliyeti | ❌ **Yok** — her şey max'lanabiliyor |
| **İz** (Consequence) | "Yaptıklarım dünyada kalıcı bir iz bıraktı mı?" | ❌ **Yok** — hiçbir karar kalıcı değil |

**Aidiyet ve mülkiyet** de aynı yerden doğar. Oyuncu bir şeye "benim" der çünkü:
1. Onu **kendi seçimleriyle** şekillendirmiştir (başkasınınkinden farklıdır),
2. Onun için **bir şey feda etmiştir** (bedel ödemiştir),
3. Onu **kaybetme riski** vardır (kayıptan kaçınma).

Şu an oyunda üçü de zayıf. En net kanıt aşağıda.

---

# BÖLÜM 1 — MEVCUT SİSTEMDE ÖNCE DÜZELTİLMESİ GEREKENLER

> Bu bölümdeki hiçbir madde yeni özellik değil. Hepsi **zaten var olan RPG iskeletinin** çalışmayan veya yanlış kurulmuş parçaları. Bunlar düzeltilmeden eklenecek her yeni sistem aynı zemine oturur.

## 1.1 · Yetenek Ağacı Oyuncuya Yalan Söylüyor ⭐ *en kritik*

**Dosyalar:** [player_skills.dart:73-88](lib/data/models/player_skills.dart:73), [character_growth_screen.dart:170-214](lib/presentation/screens/character/character_growth_screen.dart:170)

Karakter Gelişimi ekranı her yetenek için somut bir perk vaat ediyor. Bu vaatlerin **beşten üçü hiçbir yerde okunmuyor:**

| Ekranda yazan perk | Formül | Oyunda etkisi var mı? |
|---|---|---|
| *"Alım İndirimi / Kâr Marjı: +%18"* | `negotiationMultiplier` | ❌ **Yalnızca ekranda** — hiçbir motor okumuyor |
| *"Ekspertiz Maliyet İndirimi: -%45"* | `expertiseCostDiscount` | ✅ Gerçekten uygulanıyor |
| *"Doping & Teklif Bonusu: +%135"* | `marketingDopingBonus` | ❌ **Yalnızca ekranda** |
| *"Faiz İndirimi: -%9"* | `financeInterestDiscount` | ✅ Gerçekten uygulanıyor |
| *"Çek Riski -%4.5"* | `chequeRiskReduction` | ❌ **Yalnızca ekranda** |

Daha ince bir sorun: Pazarlık ve Piyasa Sezgisi yeteneklerinin **aslında bir etkisi var**, ama ekranda gösterilenden **tamamen farklı bir formülle**:
- Pazarlık: `negotiationLevel` ham değeri `evaluateCounterOffer`'da `+%3/seviye` kabul olasılığı olarak kullanılıyor — ama ekran `+%2/seviye kâr marjı` diyor.
- Piyasa Sezgisi: `marketSense * 0.05` ziyaretçi hızında kullanılıyor — ama ekran `+%15/seviye doping bonusu` diyor.

**Neden RPG için ölümcül:** RPG'de yetenek ağacı bir **sözleşmedir**. Oyuncu "3 puanımı Pazarlığa yatırırsam şu olur" diye plan yapar. Vaat tutmuyorsa oyuncu ağacı okumayı bırakır, rastgele dağıtır — ve yetenek sistemi bir karakter inşa aracı olmaktan çıkıp anlamsız bir tıklama işine döner.

**Düzeltme yönü:** Her perk metni, gerçekten okunan formülü yazmalı. Ya perkler motorlara bağlanmalı, ya metinler gerçek formüle göre düzeltilmeli. İkisinden biri — ama ikisi arasındaki boşluk kapatılmalı.

## 1.2 · Yetenek Ağacında Seçim Yok — Bu Yüzden RPG Değil ⭐

**Dosya:** [player_skills.dart:59-71](lib/data/models/player_skills.dart:59)

Matematik şöyle işliyor:
- 5 dal × her biri max 10 seviye → toplam **45 yetenek puanı** gerekiyor
- Her seviye atlama 1 puan veriyor (`totalSkillPointsEarned = (currentLevel - 1) + bonusSkillPoints`)
- Başarımlardan gelen bonus puanlar: **18 puan** ([player_achievements.dart](lib/data/models/player_achievements.dart) `rewardSkillPoints` toplamı)

Sonuç: **Seviye ~28'de her yetenek dalı max'lanmış oluyor.** Hiçbir dal diğerini dışlamıyor, hiçbir puan geri alınamaz bir tercih değil.

Bu, RPG'nin en temel unsurunun — **fırsat maliyeti** — tamamen yokluğu demek. Bir oyuncunun karakteri diğerinden farklı olamıyor; herkes yeterince oynadığında **birebir aynı karaktere** dönüşüyor. Dolayısıyla:
- "Ben pazarlıkçı bir galericiyim" diyecek bir oyuncu yok
- Yetenek dağıtımı bir kimlik ifadesi değil, sadece bir sıralama tercihi
- Yeniden oynama sebebi yok (farklı bir build denenemez)

**Düzeltme yönü — üç seçenek, artan iddia sırasıyla:**
1. **Puan kıtlığı:** Toplam kazanılabilir puanı ~45'ten ~25'e indir. Oyuncu 5 dalın hepsini max'layamaz, seçmek zorunda kalır.
2. **Dal kilidi:** Bir dalda 7+ seviyeye çıkmak, başka bir dalın tavanını düşürsün (uzmanlaşma bedeli).
3. **Uzmanlık yolu:** Belirli seviyede oyuncu üç yoldan birini kalıcı olarak seçsin (bkz. §2.2).

En küçük müdahale (1) bile sistemi anında RPG'ye yaklaştırır.

## 1.3 · Seviye Bir Sayı, Kimlik Değil

**Dosya:** [dealership_model.dart](lib/data/models/dealership_model.dart), [game_core_provider.dart](lib/presentation/providers/game/game_core_provider.dart)

Şu an "Seviye 4" sadece bir kilit anahtarı. Oyuncu için hiçbir **anlam** taşımıyor:
- Bir unvan yok ("Sanayi Çırağı" → "Galeri Sahibi" → "Otomotiv Baronu")
- Seviye atlama anı kutlanmıyor (ne açıldığı, ne değiştiği gösterilmiyor)
- Seviye 4'ten sonra ilerleme göstergesi tamamen duruyor

**Düzeltme yönü:** Her seviyeye bir unvan ver ve bu unvanı oyuncunun **her yerde gördüğü** yere koy (HUD, ayarlar, satış geçmişi, liderlik tablosu). Unvan, RPG'de kimliğin en ucuz ve en etkili taşıyıcısıdır. `RivalLeaderboardEngine` zaten bir sıralama üretiyor — unvan oraya doğal olarak oturur.

## 1.4 · İki Ayrı "İtibar" Sistemi Aynı İsmi Taşıyor

**Dosyalar:** [dealership_model.dart:104](lib/data/models/dealership_model.dart:104), [player_skills.dart:7](lib/data/models/player_skills.dart:7)

Oyunda **iki farklı itibar** var:

| Alan | Aralık | Ne yapıyor |
|---|---|---|
| `reputationScore` | 0–100 | Galeri itibarı; dramatik kartlar ve müşteri yorumları değiştiriyor |
| `skills.reputation` | 1–10 | Bir yetenek dalı; offline teklif hızını etkiliyor |

İkisi de arayüzde "İtibar" olarak geçiyor. Oyuncu "itibarımı artırdım" dediğinde hangisini kastettiğini bilemiyor, ve ikisi birbirini hiç etkilemiyor. Bu, kimlik sisteminin merkezinde duran bir kavram karmaşası.

**Düzeltme yönü:** İkisini ayır ve isimlendir — `reputationScore` → **"Esnaf İtibarı"** (dünyanın sana bakışı), `skills.reputation` → **"Çevre & Tanınırlık"** (senin yeteneğin). Ya da daha iyisi: yetenek dalını başka bir isme çevirip (`networking`) itibarı tek bir kavram olarak bırak.

## 1.5 · Araçlar Nesne, Mülk Değil

Şu an bir araç oyuncu için sadece **bir sayı taşıyıcısı**: al, onar, sat, unut. Mülkiyet hissi için gereken üç şeyin hiçbiri yok:

| Eksik | Sonuç |
|---|---|
| **Geçmiş** — kimden alındı, neler yapıldı | Araç bir hikâye taşımıyor |
| **İsim/kimlik** — oyuncunun verdiği bir ad, bir plaka | Araç kişiselleştirilemiyor |
| **Kalıcılık** — elde tutmanın bir anlamı | Her araç eninde sonunda satılıyor |

**Düzeltme yönü:** `CarModel`'de `isLockedInShowcase` alanı **zaten var** ve dramatik kart D1 bunu kullanıyor. Ama:
- Kilit tek dokunuşla geri alınabiliyor ([showroom_car_card.dart:477](lib/presentation/screens/showroom/widgets/showroom_car_card.dart:477) `toggleShowcaseLock`) — yani hiçbir bedeli yok
- Kilitli aracın oyuncuya sağladığı **hiçbir pasif fayda yok** — sadece satılamaz oluyor

Yani mülkiyet mekaniğinin iskeleti var ama hem bedelsiz hem faydasız. Bu ikisi düzeltilirse (geri almak bedelli/onaylı olsun, kilitli araç kalıcı bonus versin) mevcut kodla gerçek bir mülkiyet hissi doğar.

## 1.6 · Personel İnsan Değil, İkon

**Dosya:** [staff_model.dart](lib/data/models/staff_model.dart)

`StaffModel` yalnızca `id`, `name`, `role`, `hiredAt` içeriyor. Personelin:
- Gelişimi yok (çırak hep çırak kalıyor)
- Kişiliği yok
- Oyuncuyla ilişkisi yok

Oysa dramatik kart B2 ("Güvenilir Çalışanın Teklifi") tam olarak bir **ilişki** anlatısı kuruyor: emektar usta, sadakat, ihanet. Anlatı var, arkasında sistem yok.

**Düzeltme yönü:** `StaffModel`'e deneyim/uzmanlık alanı eklemek, RPG'nin "parti üyeleri" katmanını neredeyse bedava kurar. `staff_academy_screen.dart` zaten mevcut.

## 1.7 · Onboarding Kimlik Soruyor Ama Kimlik Kullanılmıyor

**Dosyalar:** [onboarding_screen.dart:74](lib/presentation/screens/onboarding/onboarding_screen.dart:74), [dealership_identity_screen.dart](lib/presentation/screens/settings/dealership_identity_screen.dart)

İyi haber: onboarding artık oyuncuyu `/dealership-identity` ekranına yönlendiriyor — oyuncu adını, galerisinin adını ve amblemini seçiyor. Bu, mülkiyet hissinin doğru başlangıcı.

Kötü haber: bu bilgiler neredeyse hiç kullanılmıyor. `playerName` yalnızca **iki yerde** görünüyor ([dashboard_banners.dart:105](lib/presentation/screens/dashboard/widgets/dashboard_banners.dart:105) ve ayarlar). Galerinin adı ve amblemi de benzer şekilde arka planda kalıyor.

**Düzeltme yönü:** Oyuncunun adı ve galerisinin adı **her yerde** görünmeli — satış sözleşmelerinde ("Bu araç Miras Oto Galeri'den satılmıştır"), müşteri diyaloglarında ("Selam Ahmet Usta"), liderlik tablosunda, ekspertiz raporlarında, dramatik kart metinlerinde. Bir isim ne kadar çok yerde görünürse, o kadar "benim" olur. Bu, sıfır yeni sistem gerektiren, saf metin işi.

---

# BÖLÜM 2 — EKLENMESİ GEREKEN RPG & AİDİYET ÖZELLİKLERİ

> Bölüm 1'deki düzeltmeler yapıldıktan sonra bu özellikler sağlam bir zemine oturur. Sırayla önem taşıyorlar.

## 2.1 · Karakter Yaratma & Köken Seçimi ⭐ *aidiyetin başlangıç noktası*

**Fikir:** Onboarding'de oyuncu adını girdikten sonra bir **köken** seçsin. Her köken farklı başlangıç koşulları ve kalıcı bir pasif özellik verir:

| Köken | Başlangıç avantajı | Kalıcı özellik | Dezavantaj |
|---|---|---|---|
| **Sanayi Çırağı** | +2 Ekspertiz Sezgisi | Onarım maliyetleri −%15 | Başlangıç sermayesi ₺50.000 |
| **Tüccar Torunu** | +2 Pazarlık | Alım fiyatlarında −%8 | Atölye Lv3'e kadar kilitli |
| **Şehirli Yatırımcı** | Başlangıç ₺150.000 | Banka faizi avantajı | Ekspertiz Sezgisi tavanı 7 |
| **Kolleksiyoner Yeğeni** | Miras araç + 1 nadir araç | Nadir araç değeri +%20 | Sabit gider +%25 |

**Neden en önemli madde:** RPG'de aidiyet **ilk 60 saniyede** kurulur. Oyuncu bir seçim yapıp "ben buyum" dediği an, oyunun hikâyesi onun hikâyesi olur. Şu an oyun herkese aynı Murat 124'ü ve aynı ₺75.000'i veriyor — yani her oyuncunun hikâyesi birebir aynı başlıyor.

Ayrıca bu, §1.2'deki "seçim yok" problemini kökten çözmenin en zarif yolu: köken, geri alınamaz ilk build kararıdır.

## 2.2 · Uzmanlık Yolları (Prestij Sınıfları) ⭐

**Fikir:** Oyuncu belirli bir seviyede (örn. Lv5) **üç yoldan birini kalıcı olarak** seçsin. Seçim geri alınamaz ve o yola özel bir yetenek alt-ağacı açar:

| Yol | Kimlik | Özel yetenekler |
|---|---|---|
| **🔧 Restoratör** | *"Ben araba yaparım, satmak sonra gelir"* | Kaporta onarımı %100 başarı · Nadir araç bulma şansı ×2 · Restore edilen araçlarda +%25 değer |
| **💰 Tüccar** | *"Ben insan okurum"* | Pazarlıkta +2 hak · Müşteri arketipini önceden görme · Alımda −%15 |
| **🏢 Patron** | *"Ben sistem kurarım"* | Yan işletme geliri +%30 · Personel maaşı −%20 · +2 garaj slotu |

**Neden çalışır:** Üç yol da aynı çekirdek döngüyü oynatır ama **farklı hissettirir.** Bir Restoratör hurdalıkta yaşar, bir Tüccar pazarda, bir Patron ofiste. Oyuncu artık "Galerisinden oynuyorum" demez, **"Restoratör oynuyorum"** der — bu, aidiyetin tam tanımıdır.

Ayrıca yeniden oynanabilirliği üçe katlar ve §2.7'deki sezon sistemine doğal olarak bağlanır.

## 2.3 · Unvan & İtibar Kimliği

**Fikir:** Oyuncunun unvanı iki eksenden hesaplansın: **seviye** (ne kadar büyüksün) + **itibar** (nasıl bir insansın).

| İtibar | Düşük seviye | Yüksek seviye |
|---|---|---|
| 80–100 | *"Dürüst Çırak"* | *"Sanayinin Namuslu Adamı"* |
| 40–79 | *"Sanayi Esnafı"* | *"Cadde Galericisi"* |
| 0–39 | *"Kurnaz Çırak"* | *"Sanayi Kurdu"* |

Bu unvan HUD'da, liderlik tablosunda, müşteri diyaloglarında görünsün. Dürüst oynayan oyuncuyla sömürücü oynayan oyuncu **farklı isimler taşısın.**

**Neden önemli:** `reputationScore` şu an sadece bir sayı. Ona bir **isim** verdiğin an, oyuncunun ahlaki seçimleri (dramatik kartlar C1, C2, C3) kimliğine dönüşür. Vicdan kartlarının mekanik ödülü olmaması gerektiğini daha önce savunmuştum — unvan, mekanik ödül olmadan **anlam** vermenin doğru yoludur.

## 2.4 · NPC İlişki Sistemi ⭐ *RPG'nin kalbi*

**Fikir:** Oyunda zaten isimli karakterler var — Haydar Usta, Çıkmacı İbo, Gölge İbrahim, Vlogger Berk, Eski Ortak Necati, Usta Selim. Ama hepsi **tek seferlik.** Her biriyle bir **ilişki seviyesi** (0–100) tutulsun:

- Necati'ye borç verdin ve o ödedi → ilişki +30 → ileride sana kelepir araç getirir
- Necati'ye borç verdin, kaçtı → ilişki −50 → bir daha görünmez
- Gölge İbrahim'e rüşvet ödedin → ilişki +20 → karaborsa fiyatları senin için düşer
- Haydar Usta'yla 5 kez çalıştın → ekspertiz ücretin kalıcı olarak yarıya iner

**Neden RPG'nin kalbi:** RPG'yi tycoon'dan ayıran temel şey **ilişkilerdir.** Oyuncu sayıları değil insanları hatırlar. Ve bu sistem, dramatik kartların hâlihazırdaki en büyük zayıflığını (her kart bağımsız, geçmişi olmayan bir olay) çözer: kartlar birbirine bağlanır, bir **anlatı** oluşur.

**Uygulama notu:** `DealershipModel`'e `Map<String, int> npcRelations` eklemek yeterli. Dramatik kart motorunda `seenDramaticCardIds` zaten benzer bir hafıza tutuyor — mimari hazır.

## 2.5 · Galeri = Ev (Fiziksel Mülkiyet)

**Fikir:** Mülkiyet hissi soyut sayılardan değil, **bakıp "burası benim" diyebileceğin bir mekândan** doğar.

- Vitrin yerleşimi: hangi araç cam kenarında duracak? (o araç daha hızlı ziyaretçi çeker)
- Duvara asılan öğeler: dedenin fotoğrafı (D2 kartından çıkan!), ilk satış sözleşmesi, başarım plaketleri
- Galerinin adı ve amblemi tabelada fiziksel olarak görünsün
- Zamanla eskime/yenileme: boya, tabela, zemin

**Mevcut altyapı:** `isometric_showroom_canvas.dart` (797 satır) araçları zaten dizyor, `showroom_decor_screen.dart` mevcut, `logoEmblemId` alanı var. **Sistem hazır, anlam eksik.**

D2 dramatik kartı ("Eski Fotoğraf") oyuncuya dedesinin fotoğrafını veriyor ve *"Fotoğrafı çalışma masana koy"* diyor — ama koyacak bir masa yok. Bu bağlantıyı kurmak, tek bir kartı bütün bir mekân sistemine bağlar.

## 2.6 · Koleksiyon & Yadigâr (Kalıcılık)

**Fikir:** Oyuncunun **sattığı değil, sakladığı** şeyler kimliğini oluştursun.

- Nadir araçlar vitrine kalıcı olarak kilitlenebilsin (`isLockedInShowcase` zaten var)
- Kilitli araç: satılamaz + hırsızlıktan korunur (bu **zaten çalışıyor**) + **kalıcı pasif bonus verir** (eksik olan bu)
- Kilidi açmak bedelli ve onaylı olsun — geri dönülemezlik hissi için (§1.5)
- `CollectionAlbumEngine` (mevcut, [collection_album_engine.dart](lib/domain/usecases/collection_album_engine.dart)) 30 modelli bir albüm tanımlıyor — bunu tam bir koleksiyon hedefine çevir

**Neden mülkiyetin özü:** Ekonomiden **gerçekten çıkardığın** tek şey, gerçekten senin olandır. Satılabilir her araç bir stok kalemidir; satılamaz araç bir **mülktür.**

## 2.7 · Miras & Sezon Döngüsü (Uzun Vadeli Aidiyet)

**Fikir:** Belirli bir noktada (Lv10 / 100 satış) oyuncu galerisini **devredebilsin** — yeni bir sezona başlasın:

- Kalıcı prestij bonusu taşır (başlangıç sermayesi, nadir araç oranı)
- Vitrinde kilitlediği araçlar **yeni sezona geçer** — koleksiyon kalıcıdır
- Önceki sezonun unvanı bir "hanedan" kaydında görünür
- Yeni sezonda farklı bir köken (§2.1) ve farklı bir uzmanlık yolu (§2.2) denenebilir

**Neden en güçlü aidiyet mekaniği:** Oyunun açılış anlatısı zaten **miras** üzerine kurulu (Dede Hasan Usta'nın Murat 124'ü). Sezon sistemi bu temayı tamamlar: oyuncu bir gün kendi mirasını bırakan taraf olur. Anlatı bir döngü kapatır ve oyuncunun 30. gündeki hikâyesi 1. günkü hikâyesiyle rezonansa girer.

---

# BÖLÜM 3 — ÖNCELİK YOL HARİTASI

## Faz 1 — Zemini Düzelt *(yeni özellik yok, güven onarımı)*

| # | İş | Bölüm | Neden önce |
|---|---|---|---|
| 1 | Yetenek perk metinlerini gerçek formüllere bağla | §1.1 | Yetenek ağacına güven olmadan RPG kurulamaz |
| 2 | İki "itibar" kavramını ayrıştır | §1.4 | Kimlik sisteminin merkezindeki karmaşa |
| 3 | Yadigâr kilidini bedelli/onaylı yap + pasif bonus ver | §1.5, §2.6 | Mevcut mekaniği gerçek mülkiyete çevirir |
| 4 | Oyuncu adını & galeri adını her yere yay | §1.7 | Saf metin işi, en ucuz aidiyet kazancı |

## Faz 2 — RPG İskeleti *(asıl dönüşüm)*

| # | İş | Bölüm | Etki |
|---|---|---|---|
| 5 | **Yetenek puanı kıtlığı** (45 → ~25) | §1.2 | Tek satırlık değişiklikle fırsat maliyeti doğar |
| 6 | **Köken seçimi** (onboarding) | §2.1 | İlk 60 saniyede kimlik kurulur |
| 7 | **Unvan sistemi** (seviye × itibar) | §1.3, §2.3 | Ahlaki seçimlere anlam kazandırır |
| 8 | **Uzmanlık yolları** (Restoratör/Tüccar/Patron) | §2.2 | Yeniden oynanabilirliği üçe katlar |

## Faz 3 — İlişki & Mekân *(derinlik)*

| # | İş | Bölüm |
|---|---|---|
| 9 | **NPC ilişki sistemi** | §2.4 |
| 10 | Personel gelişimi & uzmanlaşma | §1.6 |
| 11 | Galeri mekânı & duvar öğeleri | §2.5 |
| 12 | Koleksiyon albümü tamamlama | §2.6 |

## Faz 4 — Döngüyü Kapat

| # | İş | Bölüm |
|---|---|---|
| 13 | **Miras & sezon sistemi** | §2.7 |

---

## Kapanış

Eğer **tek bir düzeltme** yapılacaksa: **§1.1 — yetenek perk metinlerini gerçeğe bağlamak.** Çünkü bir RPG'de oyuncunun sisteme güveni, sistemin kendisinden önce gelir. Yalan söyleyen bir yetenek ağacı, üzerine kurulacak her şeyi zehirler.

Eğer **tek bir yeni özellik** eklenecekse: **§2.1 — köken seçimi.** Çünkü aidiyet ilk dakikada kurulur ve şu an her oyuncunun hikâyesi birebir aynı başlıyor. Tek bir seçim ekranı, "bu oyunun hikâyesi" ile "benim hikâyem" arasındaki farkı yaratır.

Ve genel çerçeve olarak şunu vurgulamak isterim: bu raporun neredeyse tamamı **yeni sistem inşa etmiyor** — `isLockedInShowcase`, `reputationScore`, `logoEmblemId`, `CollectionAlbumEngine`, `showroom_decor_screen`, `staff_academy_screen`, dramatik kart karakterleri… RPG ve mülkiyet iskeleti kod tabanında zaten dağınık halde duruyor. Eksik olan, bunları **tek bir kimlik anlatısı etrafında birleştirmek.**

---

*Bu rapor `lib/` kaynak kodunun okunmasına dayanır. Hiçbir dosya değiştirilmedi.*
