# Deep Research Dossier: Galeriden Tycoon Orta ve Uzun Vadeli Tutundurma (D1 - D28 Retention) Stratejisi

## Yönetici Özeti (Executive Summary)

Aşama 1-5 kapsamında uygulanan ilk oturum hızlandırması, erken kârlı teklifler, çevrimdışı masraf muafiyeti ve zamana duyarlı sessiz saat korumalı yerel bildirimler, D1 tutundurmasını kritik eşiğe (%15 bandından %30-35 bandına) çıkarma zeminini hazırlamıştır. 

Ancak D7 (%1.5), D14 (%0.4) ve D28 (%0.3) seviyesindeki dramatik düşüşü tersine çevirmek, yalnızca ilk 5 dakikayı hızlandırmakla mümkün değildir. Yapılan derin kod tabanı ve sektör araştırması (Deep Research), oyuncuların 2. günden itibaren oyunu terk etmesine yol açan 6 yapısal tıkanıklık (friction point) ve bu tıkanıklıkları ortadan kaldıracak 6 yüksek kaldıraçlı fırsat alanı ortaya koymuştur.

---

## 1. Karşılaştırmalı Endüstri Metrikleri ve Hedef Eğrisi

| Metrik / Aşama | Galeriden Tycoon Mevcut Durum | Tycoon / Simülasyon Medyanı | Üst Çeyrek (Top 25% Best-in-Class) | Aşama 2 Hedefimiz |
| :--- | :--- | :--- | :--- | :--- |
| **D1 Retention** | ~%15.7 (Düşük) | %28 - %32 | %38 - %45 | **%35+** |
| **D3 Retention** | ~%4.2 (Sızıntı) | %16 - %20 | %24 - %28 | **%22+** |
| **D7 Retention** | ~%1.5 (Kritik Düşüş) | %7 - %10 | %14 - %18 | **%14+** |
| **D14 Retention** | ~%0.4 (Terk) | %3 - %5 | %7 - %10 | **%8+** |
| **D28 Retention** | ~%0.3 (Sıfırlanma) | %1.5 - %2.5 | %4 - %6 | **%5+** |
| **Ortalama Oturum / Gün** | 1.4 oturum | 2.5 - 3.2 oturum | 4.0 - 5.5 oturum | **3.0+ oturum** |

---

## 2. Kod Tabanında Tespit Edilen 6 Derin Sürtünme Noktası (Friction Points)

### A. Açılışta Diyalog Çarpışması ve Yığılması (The Startup Modal Storm)
`dashboard_screen.dart` (177 - 220. satırlar) incelendiğinde, `tutorialCompleted` olan bir oyuncu oyuna döndüğünde şu 5 pencerenin aynı anda açılmaya çalıştığı görülmüştür:
1. `DashboardRetentionModals.showReciprocityStarterGiftModal` (Haydar Usta Başlangıç Hibesi)
2. `DashboardRetentionModals.showOfflineRecapModal` (Çevrimdışı İlerleme Özeti)
3. `DailyLoginSheet.show(context)` (7 Günlük Giriş Takvimi)
4. `WhatsNewDialog.checkAndShow` (Yenilikler Penceresi)
5. `NotificationPrimerDialog.checkAndShow` (Halil Usta Bildirim Ön İzni)

Flutter'da bu pencereler art arda `showDialog` veya `showModalBottomSheet` ile tetiklendiğinde `Navigator` yığıtında üst üste biner. Oyuncu oyunu açar açmaz bir pencereyi kapatıp arkasından başka bir pencereyle karşılaşınca bilişsel yorgunluk yaşamakta ve uygulamayı terk etmektedir.

### B. iOS Platformunda Çıkış Kancası Körlüğü (iOS Exit Hook Blindness)
`dashboard_screen.dart` dosyasındaki `showExitHookDialog` (Açık Döngüler ve Geri Dönüş Nedenleri) mekanizması yalnızca Android geri tuşu (`PopScope`) üzerinden tetiklenmektedir. App Store Connect verilerinin geldiği iOS cihazlarında donanımsal veya yazılımsal bir geri tuşu yoktur; iPhone kullanıcıları oyundan çıkmak için alt çubuğu yukarı kaydırarak uygulamayı arka plana atar. Dolayısıyla **iOS oyuncularının yüzde yüzü çıkış kancasını ve yarım kalan işler özetini hiç görmemektedir**.

### C. Seviye 2 - 3 Sermaye Kilitlenmesi (The Zero-Liquidity Trap)
Seviye 2'ye geçen bir oyuncu elindeki ₺100.000 - ₺150.000 ile pazardan ağır hasarlı veya yüksek kilometreli bir araç aldığında kasasında ₺2.000 - ₺5.000 kalabilmektedir. Atölye tamir masrafını ödeyemeyen, garaj slotu dolu olduğu için yeni araç alamayan ve vitrindeki hasarlı aracı hemen satamayan oyuncu tam bir likidite tuzağına (capital lock) düşmektedir. Yapacak hiçbir aksiyonu kalmayan oyuncu 3. günde oyunu silmektedir.

### D. Seviye 2 ile Seviye 5 Arasındaki Hedef Çölü (Progression Plateau)
Seviye 2'de oto yıkama açıldıktan sonra, bir sonraki büyük özellik açılışı (Emlak, Personel, Borsa) uzak seviyelerde yer almaktadır. Oyuncunun her gün ne için oynadığını somutlaştıran bir ilerleme karnesi veya sezonluk yol haritası (Battle Pass / Esnaf Şöhret Basamakları) eksiktir.

### E. Uyuyan Zengin Varlıklar (Dormant Engine Assets)
Kod tabanında muazzam bir zenginlik bulunmaktadır ancak kullanıcı arayüzünde oyuncunun önüne yeterince çekilmemiştir:
- `collection_album_engine.dart`: 30 araçlık koleksiyon albümü ve kademeli ödüller mevcuttur ancak ana akışta görünür bir kanca ile sunulmamaktadır.
- `contract_model.dart` (`WantedCarContract`): Doktor Selim Bey, Mimar Aylin gibi VIP müşteri siparişleri vardır ancak Seviye 1-2 için bütçeleri dinamik ölçeklenmediği için ulaşılamaz kalmaktadır.
- `rival_leaderboard_engine.dart`: Şehirdeki rakip galeriler ve Near-Miss motivasyonu vardır ancak oyuncuya düzenli bir rekabet hissi yaşatılmamaktadır.

### F. Günlük Randevu Mekaniğinin Eksikliği (Appointment Mechanics)
Oyuncunun her akşam aynı saatte (örneğin saat 20:00) oyunu açmasını tetikleyen canlı bir etkinlik (örneğin Canlı Akşam İhalesi veya Gece Pazarı Fırsatı) bulunmamaktadır.

---

## 3. Elde Tutmayı Uçuracak 6 Stratejik Eylem Alanı

### 1. Sıralı ve Öncelikli Diyalog Yöneticisi (Modal Queue Coordinator)
Açılışta pencerelerin birbirini ezmesini önlemek için tek bir `DashboardModalCoordinator` oluşturulmalıdır.
- Öncelik 1: Çevrimdışı İlerleme Özeti (Kazanılan para hissi en önce verilmelidir).
- Öncelik 2: Günlük Giriş Takvimi (Sadece çevrimdışı özet kapatıldıktan sonra yumuşak bir geçişle açılmalıdır).
- Öncelik 3: Ön izin ve diğer pencereler ilk oturumda değil, ilgili eylem tetiklendiğinde gösterilmelidir.

### 2. Dükkanı Kapat / Gün Sonu Muhasebesi Butonu (Manual Session Closure Ritual)
iOS kullanıcılarının uygulamayı doğrudan kaydırıp çıkmasını önlemek ve oturumu bir zafer duygusuyla kapatmak için panoda dokunsal bir `Dükkanı Kapat • Gün Sonu` butonu yerleştirilmelidir:
- Günün kârını, satılan araç sayısını ve yarın sabah vitrinde bekleyecek teklif potansiyelini özetler.
- Oyuncuya "Bugünkü esnaflığın bereketi kasada. Gece nöbetine geçiyoruz, sabah ilk tekliflerle dükkanı açarız!" mesajı vererek Zeigarnik etkisini (bitmemiş iş dürtüsünü) pekiştirir.

### 3. Galericiler Odası Acil Can Suyu ve Toptancı Alışı (Anti-Bankruptcy Lifeline)
Oyuncunun parası ₺10.000 altına düştüğünde ve elindeki araç satılmadığında devreye giren esnaf dayanışması:
- **Toptancıya Acil Satış (Wholesale Quick Cash)**: Rayicin %75'ine anında nakde çevirme imkanı.
- **Halil Usta Sıfır Faizli Can Suyu Kredisi**: Oyuncuyu oyunda tutacak ₺25.000 acil esnaf avansı.

### 4. VIP Özel Müşteri Siparişleri (Wanted Vehicle Radar)
Mevcut `WantedCarContract` motoru aktif hale getirilerek oyuncunun seviyesine ve nakit gücüne uygun özel siparişler üretilmelidir:
- Örnek: "Doktor Selim Bey siyah bir sedan arıyor • 3 gün içinde bulup teslim edersen ₺30.000 prim!"
- Bu mekanik pazaryerinde amaçsızca gezinmeyi sonlandırır, hedefe yönelik heyecan verici bir dedektiflik oyununa dönüştürür.

### 5. Akşam 20:00 Canlı İhale Randevusu (Daily Mystery Auction)
Her akşam 20:00 - 22:00 saatleri arasında düzenlenen, oyuncuya önceden bildirilen özel bir ihale seansı:
- Sadece bu saatlerde nadir ve kelepir araçlar podyuma çıkar.
- Yerel bildirim: `Halil Usta • Akşam İhalesi Başladı! Podyumda kelepir bir klasik var, bayrağı kap gel!`
- D7 ve D14 geri dönüş oranlarını doğrudan yukarı çeken en güçlü sektör kancasıdır.

### 6. Koleksiyon Albümü ve Ahır Keşifleri (Barn Finds & Album Hook)
- Panoda `Koleksiyon Albümü: 3/30 Keşfedildi` kartı ile oyuncunun koleksiyoncu kimliği beslenmelidir.
- Hurdalıkta veya pazarda gizli `Ahır Buluntusu (Barn Find)` paslı araçlar bulunabilmeli; temizlenip restore edildiğinde albümde efsanevi rozet açılmalıdır.

---

## 4. Uygulama Önceliklendirmesi (Roadmap)

1. **Öncelik A (Kritik - Hemen)**: Açılış diyalog yığılmasını çözen sıralı kuyruk mekanizması (`ModalQueueCoordinator`).
2. **Öncelik B (Yüksek - 1-2 Gün)**: Panoda iOS uyumlu `Dükkanı Kapat • Gün Sonu Ritüeli` kartı ve açık döngü özetleyici.
3. **Öncelik C (Yüksek - 2-3 Gün)**: Seviye 1-3 oyuncuları için dinamik ölçeklenen `VIP Müşteri Siparişleri (WantedCarContract)`.
4. **Öncelik D (Orta - 3-5 Gün)**: Akşam 20:00 Randevu İhalesi ve Hurdalık Ahır Keşifleri döngüsü.
