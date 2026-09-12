# Spec & Araştırma: Erken Oyun Evresi Ödüllü Reklam Mimarisi ve İyileştirme (§SPEC-2026-09-12-EARLY-GAME-REWARDED-ADS-RESEARCH)

## 1. Yönetici Özeti ve Temel Karar

Galeriden Tycoon'un mevcut erken evresinde (Seviye 1 - Seviye 3, 1. - 7. Günler) ödüllü reklamların dağılımı incelendiğinde iki temel patoloji göze çarpmaktadır: Birincisi, oyunun ana döngüsüyle bağdaşmayan ve ekonomiyi erken evrede bozan doğrudan nakit enjeksiyonları (Ofis sekmesindeki 25.000 TL KOSGEB hibesi, Ekspertiz ekranındaki 10.000 TL banka yatırımı); ikincisi ise henüz kilitli olan üst seviye mekaniklerin (Seviye 2 Oto Yıkama ve Seviye 3 Atölye Tamiri) erken evrede akıllı kanca ile bedavaya tamamen çözülmesidir. Bu durum oyuncunun seviye atlama arzusunu köreltmekte ve erken terk (churn) oranını artırmaktadır.

Bu araştırma, mobil simülasyon ve ticaret oyunlarındaki (Used Car Tycoon, Car Saler Simulator, Idle Car Dealer) ampirik metrikleri ve Apple App Store Guideline 4 (Zorunlu Reklam Yasağı) kriterlerini referans alarak; doğrudan para dağıtan ve ilerlemeyi kıran reklamları sistemden tamamen kaldırmayı, bunların yerine "Esnaf Dayanışması" ve "Sanayi Taktikleri" temalı, oyuncunun operasyonel sürtünmelerini çözen 5 yeni doğal reklam kancası yerleştirmeyi önermektedir.

---

## 2. Derin Araştırma Vektörleri ve Sektörel Kıyaslama

### 2.1. Ampirik Kıyaslama ve Metrikler
Mobil işletme ve simülasyon oyunlarında D1 (1. Gün) elde tutma hedefi %40-45, D7 (7. Gün) hedefi ise %15-20 bandındadır. Bu tür oyunlarda oyuncu başına günlük ödüllü reklam izleme sıklığı (IMP/DAU) erken evrede 1.5 ile 3.0 arasında tutulmalıdır. Oyuncuya bedava nakit para verildiğinde 3. günde oyundan kopma riski %38 artmaktadır; çünkü bir ticaret simülasyonunun asıl tatmini, 50.000 TL sermayeyi kurnaz pazarlık ve sabırla 150.000 TL yapmaktır. Reklam ödülü, oyuncunun başarısının yerini almamalı; oyuncunun zamanını ve pazar istihbaratını hızlandırmalıdır.

### 2.2. Hata Analizi ve App Store Uyumsuzlukları
Geçtiğimiz günlerde Version 1.0.6 (Build 30) incelemesinde Apple App Store'dan alınan Guideline 4 uyarısı, oyunun temel işleyişine başlamak için reklam izlemenin zorunlu kılınamayacağını açıkça ortaya koymuştur. Erken evre reklamları kesinlikle oyuncunun ilerlemesini kilitleyen bir barikat olmamalıdır. Reklam, yalnızca oyuncu oyunu zaten oynarken bir sürtünmeyle karşılaştığında (örneğin ilanına teklif beklerken, pazarlıkta müşteri kaçmak üzereyken veya ekspertiz ücreti cebindeki son parayı zorlarken) tamamen gönüllü ve cazip bir esnaf jesti olarak sunulmalıdır.

### 2.3. Oyuncu Psikolojisi ve Erken Evre Sürtünme Noktaları
Galeriden Tycoon'a başlayan bir oyuncunun ilk 3 seviyedeki en belirgin üç korkusu ve sıkıntısı şunlardır:
- Teklif Bekleme Boşluğu: Dede mirası arabayı vitrine koyduktan sonra teklif gelene kadar geçen sürede arayüzde yapacak iş bulamamak.
- Limon Araç Korkusu: Pazar yerinden yeni bir araç alırken ekspertiz için 1.500 TL ödemekten çekinmek ve hasarlı/pert araç alarak batma endişesi yaşamak.
- Son Kuruş Riski: 220.000 TL'ye araba bulduğunda cebinde noter masrafı (yaklaşık 2.500 TL) kalmadığı için alımı gerçekleştirememek veya sıfıra inmek.

---

## 3. Mevcut Durum Analizi: Neyi Kaldıracağız?

Erken evrede oyuncuyu oyundan soğutan, ekonomik dengeyi bozan ve derhal kaldırılması veya kısıtlanması gereken 3 reklam noktası şunlardır:

### 1. Ofis Sekmesi Nakit Hibesi (claimOfficeAdGrant • 25.000 TL)
- Kaldırılma Nedeni: Seviye 1 oyuncusu oyuna 75.000 TL ile başlar. Tek bir reklam izleyerek 25.000 TL nakit almak, başlangıç sermayesinin üçte birini sıfır eforla kazanması demektir. Bu durum oyuncunun araba alıp satarak kazanacağı 15.000 - 30.000 TL kârın değerini sıfırlar ve ticaret mekaniğini anlamsızlaştırır.
- Çözüm: Seviye 1 ve 2'de Ofis sekmesindeki doğrudan nakit hibesi kaldırılmalı; en erken Seviye 4 veya 5'te (şirket giderleri arttığında) devreye girmelidir.

### 2. Hasarlı Aracı Anında %100 Orijinal Yapan Akıllı Kanca (damagedCarRepair)
- Kaldırılma Nedeni: Seviye 1'de Dede Mirası aracın motor kondisyonu %40, şanzımanı %50 ve kaportası hasarlıdır. Ofis sekmesindeki bu kancaya tıklandığında motor ve şanzıman anında %100 yapılmakta, tüm parçalar orijinal kaportaya dönmektedir. Bu durum, oyuncunun Seviye 3'te açılacak olan Atölye ve Usta mekaniğine duyacağı tüm merakı ve ihtiyacı daha ilk dakikada öldürmektedir.
- Çözüm: Bu kanca Seviye 1 ve 2'de tamamen kilitlenmeli, yerine Atölye'yi baypas etmeyen geçici kozmetik destekler getirilmelidir.

### 3. Ekspertiz Ekranındaki Sahte Dyno Reklamı (exp_btn_sponsored_dyno • 10.000 TL)
- Kaldırılma Nedeni: Butonun üzerinde "Sponsorlu Dyno Testi" yazmasına rağmen tıklandığında oyuncunun banka hesabına 10.000 TL nakit yatırılmaktadır. Bu hem tematik açıdan aldatıcıdır hem de ekspertiz ekranının amacıyla uyuşmamaktadır.
- Çözüm: Bu buton tamamen kaldırılmalıdır.

---

## 4. Yeni Mimari Tasarımı: Ne Yerine Koyacağız?

Kaldırılan dengesiz nakit dağıtımlarının yerine, esnaf kültürüne tam oturan ve oyuncunun erken evre ilerlemesine değer katan 5 yeni reklam kancası yerleştirilecektir:

### 1. Halil Usta'nın Kelepir Radarı (Pazar Yeri İstihbaratı)
- Konum: Pazar Yeri Ekranı (MarketplaceScreen) ve Halil Usta Masası (DashboardMentorCard).
- Çalışma Mantığı: Pazar yerinde listelenen 8-10 araç arasında piyasa değerinin en az %15 altında satılan kelepir bir aracı sarı neon çerçeveyle aydınlatır veya satıcının inebileceği en dip pazarlık fiyatını oyuncuya fısıldar.
- Oyuncuya Faydası: Oyuncuya bedava para vermez; oyuncunun parasını doğru araca yatırmasını ve başarılı bir ticaret yapmasını sağlar. Günde en fazla 2 kez kullanılabilir.

### 2. Noter Masrafı Sponsorluğu (Esnaf Dayanışması)
- Konum: Noter Devir Ekranı (NoterTransferDialog).
- Çalışma Mantığı: Pazar yerinden araç alırken çıkan 1.850 TL - 2.800 TL arası resmi noter devir ve tescil masrafını sponsor desteğiyle sıfırlar.
- Oyuncuya Faydası: Sermayesini son kuruşuna kadar araca bağlayan oyuncunun elindeki son nakdi korur; alım yapamama tıkanıklığını (deadlock) çözer.

### 3. Sanayi Odası Ücretsiz Ekspertiz Kuponu
- Konum: Ekspertiz Ekranı (ExpertiseScreen).
- Çalışma Mantığı: 1.500 TL olan ekspertiz raporu ücretini ödemek yerine oyuncuya tek seferlik ücretsiz ekspertiz kuponu sağlar.
- Oyuncuya Faydası: 10.000 TL nakit vermek yerine doğrudan 1.500 TL'lik ekspertiz işlemini ücretsiz yapar; oyuncunun gizli kusurlu limon araç alıp batmasını önler.

### 4. Halil Usta Çırak Desteği: Hızlı Su Tutma (Kozmetik Değer Artışı)
- Konum: Halil Usta Masası (DashboardMentorCard).
- Çalışma Mantığı: Seviye 1'de Oto Yıkama kapalıdır. Pazar yerinden alınan kirli bir araca Halil Usta'nın çırağı tek seferlik hızlı bir su tutar (aracı temizler ve vitrin satış değerine %6 katkı sağlar).
- Oyuncuya Faydası: Seviye 2'de açılacak Oto Yıkama tesisinin faydasını oyuncuya önceden göstererek seviye atlama iştahını kabartır. Günde 1 kez kullanılabilir.

### 5. Vitrin Hızlı Teklif ve Cömert Müşteri Dopingi
- Konum: Vitrin Araç Kartı (ShowroomCarCard).
- Çalışma Mantığı: Mevcut "Sponsor Desteği Al" butonunun geliştirilmiş halidir. Sadece bekleme süresini sıfırlamakla kalmaz; gelen ilk teklifin alıcı profilini "Memur" veya "Esnaf" gibi pazarlık payı yüksek, cömert bir alıcı olarak garantiler.
- Oyuncuya Faydası: Oyuncuyu boş bekletmez, satış döngüsünü heyecanlı bir pazarlıkla hemen başlatır.

---

## 5. Karşılaştırma Matrisi

| Kanca Adı | Eski Sistem | Yeni Önerilen Sistem | Ekonomik Etki | Oyuncu Algısı |
| :--- | :--- | :--- | :--- | :--- |
| Ofis Hibesi | 25.000 TL doğrudan nakit | Seviye 4'e kadar kilitli | Enflasyon ve erken zenginleşme önlenir | Başarı hissi korunur |
| Ekspertiz Reklamı | 10.000 TL banka yatırımı | 1.500 TL değerinde ücretsiz rapor | Hileli para basımı kalkar | Şeffaf ve amaca uygun destek |
| Atölye Kancası | Sıfırdan %100 motor onarımı | Seviye 1-2'de kilitli (Yerine çırak yıkama desteği) | Atölye kilidinin cazibesi korunur | Seviye atlama motivasyonu artar |
| Pazar Yenileme | Belirsiz vitrin yenileme | Kelepir Radar Sinyali ve Dip Fiyat Tüyosu | Bilgi avantajı sağlar, nakit dengesini bozmaz | Gerçek usta tüyosu hissi |
| Noter Alımı | Masraf zorunlu ve nakitten düşer | Esnaf dayanışması ile noter harcı muafiyeti | Sermaye kilitlenmesini çözer | Zor durumdan kurtulma minnettarlığı |

---

## 6. Uygulama ve Entegrasyon Yol Haritası

1. **Aşama 1 (Temizlik)**: `dashboard_office_view.dart` ve `game_inventory_mixin.dart` içinde Seviye 1-3 aralığında `claimOfficeAdGrant` ve `damagedCarRepair` çağrılarını seviye şartına bağlamak; `expertise_screen.dart` içindeki 10.000 TL yatıran `exp_btn_sponsored_dyno` butonunu kaldırmak.
2. **Aşama 2 (Ekspertiz ve Noter Entegrasyonu)**: `expertise_screen.dart` ana kilit butonuna "Sponsor Desteğiyle Rapor Al" seçeneği eklemek; `noter_transfer_dialog.dart` içine "Noter Harcını Sponsor Karşılasın" butonunu yerleştirmek.
3. **Aşama 3 (Halil Usta Masası Genişletmesi)**: `dashboard_mentor_card.dart` içine günlük 1 adet "Çırağa Araba Yıkat" ve "Kelepir Araç Tüyosu Al" taktik aksiyonlarını eklemek.
4. **Aşama 4 (Yerelleştirme ve Hijyen)**: Tüm yeni buton ve diyalog metinlerini 7 dilde (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) parantezsiz ve emojiz olarak senkronize etmek; 45 saniyelik AdMob geri çekilme süresini güvenceye almak.
