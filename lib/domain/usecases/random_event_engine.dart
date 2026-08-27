import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../data/models/game_event_model.dart';

class RandomEventEngine {
  static final Random _random = Random();

  /// Comprehensive Database of Turkish Automotive, Business Risk & Trade Events
  static List<GameEventModel> get allEventTemplates => [
        // --- GENEL KÖTÜ OLAYLAR ---
        GameEventModel(
          id: 'event_black_market_raid',
          title: 'GECE PAZARI POLİS BASKINI • MALİYE & KAÇAKÇILIK OPERASYONU',
          description: 'Gece pazarından temin edilen şüpheli araçlar için Kaçakçılık ve Organize Suçlarla Mücadele ekipleri galerine baskın düzenledi!',
          iconEmoji: 'siren',
          amount: 0.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(
              label: 'Hukuk Danışmanını Ara • -25.000 ₺',
              resultText: 'Avukatın savcılık tedbir kararını durdurdu, araçları ve itibarını kurtardı.',
              balanceChange: -25000.0,
              reputationChange: 5,
              xpGain: 120,
            ),
            GameEventChoice(
              label: 'Cezayı Kabul Et & Aracı Teslim Et • -60.000 ₺',
              resultText: 'İdari para cezasını ödedin ve şüpheli araç yediemin otoparkına çekildi.',
              balanceChange: -60000.0,
              reputationChange: -20,
              xpGain: 50,
            ),
            GameEventChoice(
              label: 'Gece Yarısı Aracı Kaçırmaya Çalış • Riskli',
              resultText: 'Polis ekipleri kaçırma girişimini tespit etti! Ağır kaçakçılık cezası uygulandı.',
              balanceChange: -150000.0,
              reputationChange: -35,
              xpGain: 20,
            ),
          ],
        ),
        GameEventModel(
          id: 'event_belediye',
          title: 'Zabıta & Belediye Denetimi',
          description: 'Ruhsat ve kaldırım işgali denetimine gelen zabıtalar ceza kesti!',
          iconEmoji: 'siren',
          amount: -5000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Cezayı Öde • -5.000 ₺', resultText: 'Ceza makbuzunu ödedin, itibarın korundu.', balanceChange: -5000.0, reputationChange: 5, xpGain: 30),
            GameEventChoice(label: 'İtiraz Et & Çay Ismarla', resultText: 'Çay sohbetiyle ceza yarıya indi!', balanceChange: -2500.0, reputationChange: 0, xpGain: 50),
          ],
        ),
        GameEventModel(
          id: 'event_sel',
          title: 'Şiddetli Sağanak & Su Baskını',
          description: 'Galerinin açık otoparkını su bastı. Araçların alt takımları çamur oldu.',
          iconEmoji: 'rain',
          amount: -8000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Detaylı Temizlik Yaptır • -8.000 ₺', resultText: 'Tüm araçlar pırıl pırıl temizlendi.', balanceChange: -8000.0, reputationChange: 10, xpGain: 60),
            GameEventChoice(label: 'Kendi İmkanlarınla Yıka', resultText: 'Yorucu oldu ama az masrafla atlattın.', balanceChange: -2000.0, reputationChange: -5, xpGain: 40),
          ],
        ),
        GameEventModel(
          id: 'event_kedi',
          title: 'Mahallenin Kedileri Kaputta',
          description: 'Sıcak kaputların üstüne 8 tane sokak kedisi kuruldu. Müşteriler içeri girmeye çekiniyor.',
          iconEmoji: 'cat',
          amount: 0.0,
          type: GameEventType.meme,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Mama Al & Sev • +İtibar, -500 ₺', resultText: 'Kedisever müşteriler galeriye akın etti!', balanceChange: -500.0, reputationChange: 15, xpGain: 50),
            GameEventChoice(label: 'Pışt De & Kov • -İtibar', resultText: 'Mahalleli bu duruma biraz içerledi.', balanceChange: 0.0, reputationChange: -15, xpGain: 10),
          ],
        ),
        GameEventModel(
          id: 'event_cirak',
          title: 'Çırağın Boya Kazası',
          description: 'Yeni işe başlayan çırak Emre, müşterinin siyah Bavyera Makasçısı aracını yanlışlıkla kırmızı astara sürttü!',
          iconEmoji: 'wrench',
          amount: -12000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Hemen Fırın Boyaya Al • -12.000 ₺', resultText: 'Kusursuz boyandı, müşteri fark etmedi bile.', balanceChange: -12000.0, reputationChange: 5, xpGain: 80),
            GameEventChoice(label: 'Pasta Cila ile Kurtar • -3.000 ₺', resultText: 'Belli belirsiz oldu ama ucuz kurtardın.', balanceChange: -3000.0, reputationChange: -10, xpGain: 40),
          ],
        ),
        GameEventModel(
          id: 'event_vergi',
          title: 'Maliye Vergi İncelemesi',
          description: 'Vergi dairesi geçmiş dönem araç satış faturalarını inceledi.',
          iconEmoji: 'money',
          amount: -15000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Muhasebeciyle Çöz • -15.000 ₺', resultText: 'Tüm evraklar düzenlendi, sorun kalmadı.', balanceChange: -15000.0, reputationChange: 10, xpGain: 100),
          ],
        ),
        GameEventModel(
          id: 'event_yol_coktu',
          title: 'Galerinin Önündeki Yol Çöktü',
          description: 'Belediye altyapı çalışması yüzünden 2 gün boyunca galerinin kapısına araç giremedi.',
          iconEmoji: 'pothole',
          amount: 0.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Online İlanlara Ağırlık Ver • +XP', resultText: 'İnternet satışlarıyla açığı kapattın!', balanceChange: 5000.0, reputationChange: 5, xpGain: 120),
            GameEventChoice(label: 'Tadilatı Bekle', resultText: 'Yol nihayet açıldı.', balanceChange: 0.0, reputationChange: 0, xpGain: 20),
          ],
        ),
        GameEventModel(
          id: 'event_marti',
          title: 'Martı Filosu Baskını',
          description: 'Denizden gelen martı sürüsü yeni boyanıp parlatılan araçları hedef aldı.',
          iconEmoji: 'eagle',
          amount: -2500.0,
          type: GameEventType.meme,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Hızlıca Yıkat • -2.500 ₺', resultText: 'Boya yanmadan hemen temizlendi.', balanceChange: -2500.0, reputationChange: 5, xpGain: 30),
            GameEventChoice(label: 'Kuş Yemiyle Uzaklaştır • -200 ₺', resultText: 'Martılar komşu oto yıkamaya doğru uçtu!', balanceChange: -200.0, reputationChange: 5, xpGain: 60),
          ],
        ),
        GameEventModel(
          id: 'event_viral_kotu',
          title: 'Sosyal Medyada Viral Kötü Yorum',
          description: 'Pazarlıkta anlaşamadığın bir müşteri sosyal medyada abartılı bir şikayet videosu çekti!',
          iconEmoji: 'phone',
          amount: 0.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Samimi Açıklama Videosu Çek • +İtibar', resultText: 'Dürüst tavrın sayesinde takipçin 2 katına çıktı!', balanceChange: 0.0, reputationChange: 25, xpGain: 100),
            GameEventChoice(label: 'Yorumları Kapat & Görmezden Gel', resultText: 'Olay birkaç güne unutuldu ama itibar zedelendi.', balanceChange: 0.0, reputationChange: -15, xpGain: 10),
          ],
        ),

        // --- YAN İŞLETMELER: OTOMAT & KAHVE MAKİNESİ RİSKLERİ ---
        GameEventModel(
          id: 'event_vending_coin_jam',
          title: 'Kahve Otomatı Bozuk Para Yuttu & Anakart Yandı',
          description: 'Bekleme salonundaki otomat para kanalına sıkışan jeton yüzünden sigorta attırdı ve ana kartı yandı!',
          iconEmoji: 'coffee',
          amount: -6500.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Yetkili Servis Çağır & Temassız POS Tak • -6.500 ₺', resultText: 'Otomat dijital ödemeye geçti, kahve satışları ikiye katlandı.', balanceChange: -6500.0, reputationChange: 10, xpGain: 45),
            GameEventChoice(label: 'Otomatı Fişten Çek & 3 Gün Kapat', resultText: 'Müşteriler çay ocağına gitmek zorunda kaldı, biraz homurdandılar.', balanceChange: 0.0, reputationChange: -10, xpGain: 15),
          ],
        ),
        GameEventModel(
          id: 'event_vending_spoiled_milk',
          title: 'Otomat Süt Haznesi Bozuldu & Ekşime Şikayeti',
          description: 'Sıcak havada otomatın soğutma fanı durunca süt tozu haznesi ekşidi, müşteriler tepki gösterdi!',
          iconEmoji: 'coffee',
          amount: -5000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Tüm Malzemeleri İtalyan Çekirdekle Yenile • -5.000 ₺', resultText: 'Otomat baştan aşağı dezenfekte edildi, birinci sınıf kahve kondu.', balanceChange: -5000.0, reputationChange: 10, xpGain: 40),
            GameEventChoice(label: 'Mağdur Müşterilere Paralarını İade Et • -800 ₺', resultText: 'Kriz yatıştırıldı ama lezzet puanı geçici olarak geriledi.', balanceChange: -800.0, reputationChange: -12, xpGain: 20),
          ],
        ),

        // --- YAN İŞLETMELER: OTO YIKAMA & DETAYLANDIRMA RİSKLERİ ---
        GameEventModel(
          id: 'event_wash_pump_explosion',
          title: 'Oto Yıkama Basınçlı Pompa Patlaması',
          description: 'Oto yıkama istasyonundaki 250 bar basınçlı yıkama pompası yüksek basınçtan patladı ve su hattı taştı!',
          iconEmoji: 'water',
          amount: -14000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Orijinal İtalyan Pompa Al & Taktır • -14.000 ₺', resultText: 'Yeni nesil seramik pistonlu pompa takıldı, yıkama hızı ve itibar arttı.', balanceChange: -14000.0, reputationChange: 10, xpGain: 70),
            GameEventChoice(label: 'Çıkma Pompayla İdare Et • -4.000 ₺', resultText: 'Pompa geçici olarak çalıştı ama yıkama performansı biraz düştü.', balanceChange: -4000.0, reputationChange: -5, xpGain: 35),
          ],
        ),
        GameEventModel(
          id: 'event_wash_chemical_burn',
          title: 'Agresif Kostikli Şampuan Boya Yandı Skandalı',
          description: 'Çırağın kullandığı agresif kostikli köpük lüks bir müşterinin siyah kaput verniğini matlaştırdı!',
          iconEmoji: 'spray',
          amount: -18000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Kaputu Fırın Boyaya Al & Kusuru Kapat • -18.000 ₺', resultText: 'Kusursuz işçilikle kaput yenilendi, müşteri galericilik ahlakını takdir etti.', balanceChange: -18000.0, reputationChange: 15, xpGain: 85),
            GameEventChoice(label: 'Pasta Cilayla Kurtarmayı Dene • -3.000 ₺', resultText: 'Leke tam geçmedi, müşteri sosyal medyada galeriye 1 yıldız verdi.', balanceChange: -3000.0, reputationChange: -20, xpGain: 25),
          ],
        ),

        // --- YAN İŞLETMELER: ELEKTRİKLİ ARAÇ ŞARJ İSTASYONU RİSKLERİ ---
        GameEventModel(
          id: 'event_ev_transformer_trip',
          title: 'Hızlı DC Şarj Trafosu Yüksek Akımdan Şalter Attı',
          description: 'Aynı anda şarj olan üç elektrikli araç sanayi trafosunu aşırı yükledi ve ana şalteri attırdı!',
          iconEmoji: 'battery',
          amount: -28000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Sanayi Trafosunu Güçlendir & Kompanzasyon Yap • -28.000 ₺', resultText: 'Kapasite 300 kW seviyesine çıkarıldı, istasyon kesintisiz hizmet veriyor.', balanceChange: -28000.0, reputationChange: 25, xpGain: 105),
            GameEventChoice(label: 'Şarj Hızını %50 Kıs & Masraf Yapma', resultText: 'Trafoyu korudun ama araç sahipleri yavaş şarjdan şikayet etti.', balanceChange: 0.0, reputationChange: -20, xpGain: 25),
          ],
        ),
        GameEventModel(
          id: 'event_ev_cable_ripoff',
          title: 'Dikkatsiz Sürücü Şarj Kablosunu Koparıp Kaçtı',
          description: 'İstasyondan erken ayrılmak isteyen acemi sürücü tabancayı çıkarmadan gaza basıp kabloyu kopardı!',
          iconEmoji: 'battery',
          amount: -22000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Sıfır Sıvı Soğutmalı CCS2 Kablo Tak • -22.000 ₺', resultText: 'Yüksek akımlı yeni kablo takıldı, istasyon tam randımana kavuştu.', balanceChange: -22000.0, reputationChange: 15, xpGain: 85),
            GameEventChoice(label: 'Kamera Kaydını Polise Ver & Bekle • -3.000 ₺', resultText: 'İstasyon birkaç gün tek soketle çalışmak zorunda kaldı.', balanceChange: -3000.0, reputationChange: -10, xpGain: 40),
          ],
        ),

        // --- YAN İŞLETMELER: REKLAM PANOSU RİSKLERİ ---
        GameEventModel(
          id: 'event_billboard_panel_short',
          title: 'Dijital Billboard Fırtına Kısa Devresi',
          description: 'Şiddetli yağmurda ana cadde billboard panelinin LED kartı su aldı ve reklam yayını kesildi!',
          iconEmoji: 'billboard',
          amount: -16000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Su Geçirmez Yeni LED Modül Tak • -16.000 ₺', resultText: 'Billboard 4K parlaklıkla parıldadı, reklam verenler çok memnun kaldı.', balanceChange: -16000.0, reputationChange: 15, xpGain: 65),
            GameEventChoice(label: 'Sigortayı İndir & 4 Gün Karart', resultText: 'Reklam geliri birkaç gün kesildi ama nakit çıkışı olmadı.', balanceChange: 0.0, reputationChange: -15, xpGain: 15),
          ],
        ),
        GameEventModel(
          id: 'event_billboard_wind_damage',
          title: 'Fırtına Billboard Sacını Söktü • Zabıta Uyarısı',
          description: 'Rüzgarda sallanan dış çerçeve sacı tehlike yarattığı için belediye zabıtası acil müdahale istedi!',
          iconEmoji: 'billboard',
          amount: -12000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Mühendis Onaylı Statik Güçlendirme Yap • -12.000 ₺', resultText: 'Tabela fırtınaya dayanıklı hale getirildi, zabıta teşekkür tutanağı tuttu.', balanceChange: -12000.0, reputationChange: 15, xpGain: 55),
            GameEventChoice(label: 'Kaynakla Tuttur • -3.000 ₺', resultText: 'Geçici olarak tuttu ama şiddetli rüzgarda tekrar kontrol edilmeli.', balanceChange: -3000.0, reputationChange: -10, xpGain: 25),
          ],
        ),

        // --- YAN İŞLETMELER: PPF KAPLAMA & CAM FİLMİ RİSKLERİ ---
        GameEventModel(
          id: 'event_wrap_blade_scratch',
          title: 'Çırak Folyo Keserken Kaporta Boyasını Çizdi',
          description: 'PPF kaplama stüdyosunda yeni çırak kesim yaparken falçatayı fazla bastırıp müşterinin tavanını çizdi!',
          iconEmoji: 'spray',
          amount: -20000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Tavanı Fırın Boyaya Al & Ücretsiz PPF Çek • -20.000 ₺', resultText: 'Kusursuz teslimat yapıldı, müşteri esnafın mertliğine hayran kaldı.', balanceChange: -20000.0, reputationChange: 20, xpGain: 85),
            GameEventChoice(label: 'Rötuş Yap & Belli Etmemeye Çalış • -3.000 ₺', resultText: 'Müşteri güneş altında çiziği fark etti, dükkanı ayağa kaldırdı.', balanceChange: -3000.0, reputationChange: -30, xpGain: 20),
          ],
        ),
        GameEventModel(
          id: 'event_wrap_bubble_peel',
          title: 'Güneşte Kabaran Ucuz Folyo Müşteri İtirazı',
          description: 'Geçen hafta kaplanan aracın folyosu sıcakta kabarcık yaptı, müşteri aracı dükkanın önüne çekti!',
          iconEmoji: 'spray',
          amount: -15000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Cast Folyo ile Sıfırdan Kapla • -15.000 ₺', resultText: 'Alman malı folyo ile kaplandı, müşteri memnun ayrıldı.', balanceChange: -15000.0, reputationChange: 15, xpGain: 75),
            GameEventChoice(label: 'Isı Tabancasıyla Havasını Al • -1.500 ₺', resultText: 'Geçici çözüm oldu ama müşteri memnun kalmadı.', balanceChange: -1500.0, reputationChange: -15, xpGain: 20),
          ],
        ),

        // --- YAN İŞLETMELER: EKSPERTİZ & MUAYENE İSTASYONU RİSKLERİ ---
        GameEventModel(
          id: 'event_dyno_roller_jam',
          title: 'Fren & Dinamometre Test Tamburu Kilitlendi',
          description: 'Muayene istasyonundaki fren test cihazı tambur rulmanı dağıttı, araç geçişleri durma noktasına geldi!',
          iconEmoji: 'chart',
          amount: -18000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Kalibrasyon Mühendisini Çağır & Onar • -18.000 ₺', resultText: 'Cihaz sıfır hata toleransıyla kalibre edildi, kuyruk hızla eridi.', balanceChange: -18000.0, reputationChange: 20, xpGain: 85),
            GameEventChoice(label: 'Göz Kararı Manuel Teste Geç', resultText: 'Testler aksadı, müşteriler rapor doğruluğundan şüphe etti.', balanceChange: 0.0, reputationChange: -20, xpGain: 20),
          ],
        ),
        GameEventModel(
          id: 'event_airbag_bypass_scandal',
          title: 'Dirençle Kandırılmış Hava Yastığı Atlandı Skandalı',
          description: 'Kurumsal ekspertizde çırağın gözden kaçırdığı dirençli patlak airbag ortaya çıktı, alıcı noter önünde çıngar çıkardı!',
          iconEmoji: 'siren',
          amount: -45000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Aracı Değerinden Geri Al & Mağduru Tazmin Et • -45.000 ₺', resultText: 'Büyük itibar felaketi önlendi, galeri dürüstlüğüyle bölgede efsane oldu.', balanceChange: -45000.0, reputationChange: 30, xpGain: 130),
            GameEventChoice(label: 'Ekspertiz Şerhine Sığın & Mahkemeye Git • -10.000 ₺', resultText: 'Hukuki süreç başladı ama piyasada ciddi itibar kaybı yaşandı.', balanceChange: -10000.0, reputationChange: -40, xpGain: 35),
          ],
        ),
        GameEventModel(
          id: 'event_expertise_chassis_miss',
          title: 'Gözden Kaçan Kaynaklı Şasi Podye Kusuru',
          description: 'Ekspertiz raporunda temiz yazılan aracın podyesinde sonradan ekleme kaynak tespit edildi!',
          iconEmoji: 'shield',
          amount: -32000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Kusuru Kabul Et & Tazminat Öde • -32.000 ₺', resultText: 'Zarar tazmin edildi, eksper ustasına ek eğitim verildi.', balanceChange: -32000.0, reputationChange: 15, xpGain: 95),
            GameEventChoice(label: 'Eski Sahibine Dava Aç & Masrafı Böl • -6.000 ₺', resultText: 'Dava süreci uzadı, alıcı memnuniyetsiz ayrıldı.', balanceChange: -6000.0, reputationChange: -25, xpGain: 40),
          ],
        ),

        // --- YAN İŞLETMELER: YEDEK PARÇA MAĞAZASI RİSKLERİ ---
        GameEventModel(
          id: 'event_spare_parts_tax_audit',
          title: 'Maliye Faturasız Yedek Parça İncelemesi',
          description: 'Yedek parça deposundaki gümrüksüz ve faturasız motor parçaları için vergi müfettişi denetime geldi!',
          iconEmoji: 'box',
          amount: -25000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Mali Müşavirle Uzlaş & Vergiyi Kapat • -25.000 ₺', resultText: 'Tüm stoklar resmileştirildi, mağazanın ticari sicili temizlendi.', balanceChange: -25000.0, reputationChange: 15, xpGain: 95),
            GameEventChoice(label: 'İtiraz Et & Dava Aç • -8.000 ₺', resultText: 'Dava süreci depoyu kilitledi, parça satışları duraksadı.', balanceChange: -8000.0, reputationChange: -25, xpGain: 35),
          ],
        ),
        GameEventModel(
          id: 'event_spare_parts_water_damage',
          title: 'Yedek Parça Deposunu Su Bastı • Elektronik Beyinler Islandı',
          description: 'Depo tavanındaki su kaçağı rafındaki hassas araç kontrol beyinlerini - ECU - ıslattı!',
          iconEmoji: 'box',
          amount: -14000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Kurutma & İlaçlama Hizmeti Al • -14.000 ₺', resultText: 'Elektronik üniteler kurtarıldı, depoya su yalıtımı yapıldı.', balanceChange: -14000.0, reputationChange: 10, xpGain: 65),
            GameEventChoice(label: 'Islanan Parçaları Hurdaya Çıkar • -6.000 ₺', resultText: 'Zarar kabul edildi, sağlam parçalar raflara dizildi.', balanceChange: -6000.0, reputationChange: -10, xpGain: 30),
          ],
        ),

        // --- YAN İŞLETMELER: OTO ÇEKİCİ RİSKLERİ ---
        GameEventModel(
          id: 'event_tow_truck_cable_snap',
          title: 'Çekici Çelik Halatı Koptu • Taşınan SUV Kaydı',
          description: 'Oto kurtarma aracının tambur halatı aşırı yükten koptu, platformdaki araç tampon hasarı aldı!',
          iconEmoji: 'tow',
          amount: -24000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Kaskodan Karşıla & Mağduriyeti Gider • -24.000 ₺', resultText: 'Hasar eksiksiz karşılandı, çekiciye güçlendirilmiş sentetik halat takıldı.', balanceChange: -24000.0, reputationChange: 20, xpGain: 95),
            GameEventChoice(label: 'Müşteriyle Tutanak Tutup Masrafı Böl • -8.000 ₺', resultText: 'Müşteri duruma bozuldu ama mahkemelik olmadan tatlıya bağlandı.', balanceChange: -8000.0, reputationChange: -25, xpGain: 35),
          ],
        ),
        GameEventModel(
          id: 'event_tow_hydraulic_fail',
          title: 'Çekici Hidrolik Kol Kaçağı & Otoyol Gecikmesi',
          description: 'Kurtarma operasyonu sırasında çekici kayar kasa hidrolik pistonu yağ kaçırdı ve otoyolda kaldı!',
          iconEmoji: 'tow',
          amount: -11000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Hidrolik Pistonları Çift Keçeyle Yenile • -11.000 ₺', resultText: 'Çekici fabrika kondisyonuna döndü, 7/24 göreve hazır.', balanceChange: -11000.0, reputationChange: 10, xpGain: 55),
            GameEventChoice(label: 'Yağ Ekleyip Geçici Devam Et • -2.500 ₺', resultText: 'İdare etti ama sonraki kurtarmada daha dikkatli olmak gerek.', balanceChange: -2500.0, reputationChange: -10, xpGain: 20),
          ],
        ),

        // --- YAN İŞLETMELER: ARAÇ KİRALAMA & FİLO RİSKLERİ ---
        GameEventModel(
          id: 'event_rental_speeding_fines',
          title: 'Kiralık Araç Gece Yarısı EDS Radar Cezası Yağmuru',
          description: 'Filodan kiralanan spor coupe ile müşteri gece boyu radar hız sınırlarını ihlal etti, ceza tebligatları galeriye yağdı!',
          iconEmoji: 'car',
          amount: -12000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Cezayı Erken Öde & İndirimden Faydalan • -12.000 ₺', resultText: 'Trafik cezaları kapandı, depozito güvencesi güncellendi.', balanceChange: -12000.0, reputationChange: 5, xpGain: 45),
            GameEventChoice(label: 'Sürücüye İcra Başlat • Masraf -4.000 ₺', resultText: 'Hukuki takip açıldı ama tahsilat zaman alacak.', balanceChange: -4000.0, reputationChange: -10, xpGain: 30),
          ],
        ),
        GameEventModel(
          id: 'event_rental_clutch_burn',
          title: 'Acemi Sürücü Kiralık Araç Debriyajını Yaktı',
          description: 'Haftalık kiralanan sedan dik yokuşta debriyaj balatası yakılarak çekiciyle geri getirildi!',
          iconEmoji: 'car',
          amount: -17000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Orijinal Baskı Balata & Volan Tak • -17.000 ₺', resultText: 'Şanzıman sıfırlandı, araç yeniden kiralama filosuna katıldı.', balanceChange: -17000.0, reputationChange: 10, xpGain: 65),
            GameEventChoice(label: 'Yan Sanayi Debriyaj Tak • -6.000 ₺', resultText: 'Ekonomik tamir yapıldı ama vites geçişleri biraz sertleşti.', balanceChange: -6000.0, reputationChange: -10, xpGain: 30),
          ],
        ),

        // --- YAN İŞLETMELER: MEKANİK SERVİS & ATÖLYE RİSKLERİ ---
        GameEventModel(
          id: 'event_autoshop_lift_leak',
          title: 'Hızlı Bakım Hidrolik Lift Contası Patladı',
          description: 'Yağ değişim atölyesindeki 4 tonluk araç kaldırma lifti basınç düşürdü, araç havada asılı kaldı!',
          iconEmoji: 'wrench',
          amount: -15000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Sıfır İtalyan Keçe Takımı Al & Montaj Yap • -15.000 ₺', resultText: 'Lift pürüzsüz çalışıyor, servis kapasitesi ve güvenlik en üst düzeye çıktı.', balanceChange: -15000.0, reputationChange: 10, xpGain: 75),
            GameEventChoice(label: 'Geçici Yamayla Çalıştır • -4.000 ₺', resultText: 'Lift indirildi ama ağır SUV araçları kaldırmaktan kaçınmak gerekecek.', balanceChange: -4000.0, reputationChange: -15, xpGain: 30),
          ],
        ),
        GameEventModel(
          id: 'event_autoshop_oil_spill',
          title: 'Karter Tapası Yalama Oldu • Motor Yağı Kaçağı',
          description: 'Hızlı bakımda karter tapasını fazla sıkan çırak diş kaptırdı, müşteri yola çıkınca yağ ikazı yaktı!',
          iconEmoji: 'wrench',
          amount: -9000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Sıfır Karter Tak & Yağı Ücretsiz Yenile • -9.000 ₺', resultText: 'Müşterinin gönlü alındı, esnaflık takdir topladı.', balanceChange: -9000.0, reputationChange: 15, xpGain: 65),
            GameEventChoice(label: 'Helicoil Diş Açıp Gönder • -2.500 ₺', resultText: 'Kurtardı ama müşteri servise biraz temkinli yaklaşıyor.', balanceChange: -2500.0, reputationChange: -10, xpGain: 25),
          ],
        ),

        // --- HURDALIK & SÖKÜM TESİSİ RİSKLERİ ---
        GameEventModel(
          id: 'event_scrap_press_breakdown',
          title: 'Hurdalık Hidrolik Sac Presi Piston Kırdı',
          description: 'Hurdalıktaki dev pres gövdesi kalın şasi sacını ezerken hidrolik silindir pistonunu kırdı!',
          iconEmoji: 'wrench',
          amount: -24000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Ağır Sanayi Revizyonu Yaptır • -24.000 ₺', resultText: 'Pres yenilendi, hurda söküm hızı ve verimliliği arttı.', balanceChange: -24000.0, reputationChange: 20, xpGain: 95),
            GameEventChoice(label: 'Manuel Parçalama Yap • Verim Düşüşü', resultText: 'İşler yavaşladı ama nakit harcanmadı.', balanceChange: 0.0, reputationChange: -15, xpGain: 25),
          ],
        ),
        GameEventModel(
          id: 'event_salvage_corrosion',
          title: 'Açık Alandaki Hurda Şanzıman Blokları Paslandı',
          description: 'Yağmur altında kalan hurda döküm şanzıman ve motor blokları pas tutarak kilitlendi!',
          iconEmoji: 'wrench',
          amount: -9000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Özel Korozyon Önleyici Solüsyon Al • -9.000 ₺', resultText: 'Parçalar kurtarıldı ve kapalı depoya taşındı.', balanceChange: -9000.0, reputationChange: 10, xpGain: 55),
            GameEventChoice(label: 'Demir Fiyatına Hurdacıya Ver • -2.000 ₺', resultText: 'Parçalar eritilmeye gitti, düşük kârla kapandı.', balanceChange: -2000.0, reputationChange: -10, xpGain: 20),
          ],
        ),
        GameEventModel(
          id: 'event_b2b_defective_return',
          title: 'Sanayiye Satılan B2B Turbo Kusurlu Çıktı',
          description: 'Sanayideki özel servise gönderilen revizyonlu turbo yağ bastı, servis sahibi galeriyi mahkemeye vermekle tehdit etti!',
          iconEmoji: 'wrench',
          amount: -21000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Sıfır Sandık Parça Ver & Masrafı Karşıla • -21.000 ₺', resultText: 'Esnaflık duruşun sanayide takdir topladı.', balanceChange: -21000.0, reputationChange: 20, xpGain: 110),
            GameEventChoice(label: 'Garantimiz Yok De & İadeyi Çevir • -İtibar', resultText: 'Sanayi esnafı senin hurdalıktan parça almayı bıraktı.', balanceChange: 0.0, reputationChange: -35, xpGain: 15),
          ],
        ),
        GameEventModel(
          id: 'event_workshop_waste_fine',
          title: 'Çevre Bakanlığı Atık Yağ & Filtre Denetimi',
          description: 'Atölyenin atık yağ varillerinde usulsüz depolama tespit eden çevre müfettişleri ceza kesti!',
          iconEmoji: 'siren',
          amount: -16000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Lisanslı Atık Toplama Sözleşmesi Yap • -16.000 ₺', resultText: 'Tesis çevre dostu sertifika aldı, kurumsal itibar kazandı.', balanceChange: -16000.0, reputationChange: 20, xpGain: 85),
            GameEventChoice(label: 'İdari Para Cezasını İtirazla Öde • -6.000 ₺', resultText: 'Ceza hafifletildi ama sıkı denetim takibine alındın.', balanceChange: -6000.0, reputationChange: -20, xpGain: 35),
          ],
        ),

        // --- OFİS & YÖNETİM KRİZLERİ ---
        GameEventModel(
          id: 'event_office_safe_jam',
          title: 'Ofis Çelik Kasa Şifre Mekanizması Kilitlendi',
          description: 'Mekanik şifreli çelik kasa çarkı sıkıştı, günlük sıcak nakit ve araç anahtarları içeride kaldı!',
          iconEmoji: 'shield',
          amount: -7500.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Uzman Çilingir Çağır & Kasayı Hasarsız Aç • -7.500 ₺', resultText: 'Kasa açıldı, kilit göbeği yüksek güvenlikli dijital modele yükseltildi.', balanceChange: -7500.0, reputationChange: 5, xpGain: 45),
            GameEventChoice(label: 'Levyeyle Zorla Aç • Hasar -2.000 ₺', resultText: 'Kasa açıldı ama kapağı eğrildi, yenisi gerekecek.', balanceChange: -2000.0, reputationChange: -10, xpGain: 20),
          ],
        ),
        GameEventModel(
          id: 'event_office_fake_cheque',
          title: 'Muhasebe Masasında Karşılıksız Sahte Senet Paniği',
          description: 'Geçen hafta araç satışında alınan 90 gün vadeli senet banka takasında şüpheli ve sahte çıktı!',
          iconEmoji: 'money',
          amount: -12000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Avukat Aracılığıyla İcra Başlat • -12.000 ₺', resultText: 'Hızlı hukuki baskı ile borçlu sıkıştırıldı, anapara teminata bağlandı.', balanceChange: -12000.0, reputationChange: 15, xpGain: 75),
            GameEventChoice(label: 'Senet Sahibini Ofise Çağırıp Uzlaş • -4.000 ₺', resultText: 'Bir miktar nakit kurtarıldı ama zarar hanesine yazıldı.', balanceChange: -4000.0, reputationChange: -10, xpGain: 40),
          ],
        ),

        // --- YAN İŞLETMELER: OTO YIKAMA FIRSATLARI & B2B SÖZLEŞMELER ---
        GameEventModel(
          id: 'event_wash_wedding_convoy_rush',
          title: 'Hafta Sonu Gelin Arabası & Konvoy Hücumu',
          description: 'Gelin arabası ve arkasındaki 15 araçlık lüks düğün konvoyu acil VIP kuaför ve köpüklü yıkama istedi!',
          iconEmoji: 'water',
          amount: 18000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Tüm Peronları Kapat & VIP Hizmet Ver • +18.000 ₺', resultText: 'Gelin konvoyu ışıl ışıl ayrıldı, bol bahşiş ve itibar kazanıldı.', balanceChange: 18000.0, reputationChange: 35, xpGain: 120),
            GameEventChoice(label: 'Sırayla Normal Yıka • +6.000 ₺', resultText: 'Standart yıkama yapıldı, diğer müşteriler de bekletilmedi.', balanceChange: 6000.0, reputationChange: 10, xpGain: 50),
          ],
        ),
        GameEventModel(
          id: 'event_wash_ceramic_bulk_contract',
          title: 'Taksi Kooperatifi Toplu Cilalama Sözleşmesi',
          description: 'Şehir içi taksi kooperatifi 100 ticari taksi için haftalık fırçasız yıkama ve hızlı cila anlaşması sundu!',
          iconEmoji: 'water',
          amount: 36000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Sözleşmeyi İmzala & Toptan Peşin Al • +36.000 ₺', resultText: 'Taksi kooperatifi bağlandı, peronlar aralıksız ciro üretiyor.', balanceChange: 36000.0, reputationChange: 25, xpGain: 140),
            GameEventChoice(label: 'Kapasite Yetmez De & Reddet', resultText: 'Bireysel müşterilerin peron sırası korunmuş oldu.', balanceChange: 0.0, reputationChange: 5, xpGain: 20),
          ],
        ),
        GameEventModel(
          id: 'event_wash_foam_cannon_upgrade',
          title: 'İtalyan Kar Köpüğü Tabancası & Seramik Şampuan',
          description: 'Yeni nesil yoğun köpük atan İtalyan nozul sistemi araç başına yıkama süresini yarıya indiriyor!',
          iconEmoji: 'water',
          amount: 12000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Sistemi Kur • Masraf -6.000 ₺ • Getiri +12.000 ₺', resultText: 'Yıkama hızı ikiye katlandı, araçlar ayna gibi parlıyor.', balanceChange: 6000.0, reputationChange: 30, xpGain: 100),
            GameEventChoice(label: 'Klasik Nozul İle Devam Et', resultText: 'Mevcut ekipmanla standart hizmete devam edildi.', balanceChange: 0.0, reputationChange: 0, xpGain: 15),
          ],
        ),

        // --- YAN İŞLETMELER: OTOMAT & KAHVE BARI FIRSATLARI ---
        GameEventModel(
          id: 'event_vending_artisan_roastery_deal',
          title: 'Yerel Nitelikli Kahve Kavurucusu Ortaklığı',
          description: 'Özel çekirdek kahve kavurucusu otomatına taze İtalyan çekirdekleri koymayı teklif etti, dükkana yayılan taze koku araç satışlarını hızlandırıyor!',
          iconEmoji: 'coffee',
          amount: 8000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Nitelikli Çekirdeğe Geç • Masraf -3.000 ₺ • Kazanç +8.000 ₺', resultText: 'Müşteriler kahve eşliğinde pazarlık yaparken daha cömert davranıyor!', balanceChange: 5000.0, reputationChange: 35, xpGain: 90),
            GameEventChoice(label: 'Granül Kahveyle Devam Et', resultText: 'Standart kahve servisi sürdürüldü.', balanceChange: 0.0, reputationChange: 0, xpGain: 10),
          ],
        ),
        GameEventModel(
          id: 'event_vending_energy_drink_exclusive',
          title: 'Global Enerji İçeceği Otomat Sponsorluğu',
          description: 'Global içecek markası otomatı giydirip özel soğutucu raf tahsis etmek için peşin sponsorluk parası sundu!',
          iconEmoji: 'coffee',
          amount: 15000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Sponsorluk Sözleşmesini İmzala • +15.000 ₺', resultText: 'Otomat baştan aşağı giydirildi, sıcak nakit kasaya girdi.', balanceChange: 15000.0, reputationChange: 15, xpGain: 80),
            GameEventChoice(label: 'Kurumsal Sadeliği Koru • +20 İtibar', resultText: 'Galeri kurumsal ve ağırbaşlı görüntüsünü muhafaza etti.', balanceChange: 0.0, reputationChange: 20, xpGain: 40),
          ],
        ),

        // --- YAN İŞLETMELER: OTO ÇEKİCİ & KURTARMA FIRSATLARI ---
        GameEventModel(
          id: 'event_tow_sports_club_bus_rescue',
          title: 'Süper Lig Takım Otobüsü Otoyolda Kaldı',
          description: 'Şehirdeki stada yetişmeye çalışan Süper Lig takım otobüsü arızalandı, çekicin derhal yetişip kafileyi maça ulaştırdı ve ulusal basına konu oldu!',
          iconEmoji: 'tow',
          amount: 25000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Kusursuz Kurtarma Yap & Basına Poz Ver • +25.000 ₺', resultText: 'Kulüp başkanı teşekkür plaketi verdi, televizyonlarda haber oldun!', balanceChange: 25000.0, reputationChange: 50, xpGain: 180),
            GameEventChoice(label: 'Standart Çekici Tarifesi Kes • +8.000 ₺', resultText: 'Görev sessiz sedasız tamamlandı, ücret tahsil edildi.', balanceChange: 8000.0, reputationChange: 10, xpGain: 60),
          ],
        ),
        GameEventModel(
          id: 'event_tow_insurance_annual_tender',
          title: 'Büyük Sigorta Şirketi Bölge Çekici İhalesi',
          description: 'Türkiye çapında faaliyet gösteren kasko devi, çevre ilçelerdeki tüm kaza ve arıza çekimlerini senin filoya bağlamak istiyor!',
          iconEmoji: 'tow',
          amount: 45000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Teminat Yatır & İhaleyi Al • Masraf -15.000 ₺ • Getiri +45.000 ₺', resultText: 'Bölgenin tek resmi anlaşmalı kurtarıcısı oldun, çağrılar aralıksız akıyor.', balanceChange: 30000.0, reputationChange: 40, xpGain: 200),
            GameEventChoice(label: 'İhaleye Girme & Bağımsız Kal', resultText: 'Bireysel çağrılara odaklanmaya devam edildi.', balanceChange: 0.0, reputationChange: 5, xpGain: 20),
          ],
        ),

        // --- YAN İŞLETMELER: DİJİTAL BİLLBOARD FIRSATLARI ---
        GameEventModel(
          id: 'event_billboard_politician_election_campaign',
          title: 'Seçim Dönemi Aday Adayı Reklam Kampanyası',
          description: 'Yerel milletvekili adayı ana caddeye bakan dev dijital ekranı 30 gün boyunca kapatmak için devasa teklif sundu!',
          iconEmoji: 'billboard',
          amount: 45000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Billboardu Kirala & Peşin Nakit Al • +45.000 ₺', resultText: 'Dev afiş yayında, seçim dönemi sıcak para kasayı coşturdu.', balanceChange: 45000.0, reputationChange: 15, xpGain: 150),
            GameEventChoice(label: 'Siyasi Tarafsızlığı Koru • +30 İtibar', resultText: 'Galeri bağımsız ve tarafsız duruşuyla tüm müşterilerin saygısını kazandı.', balanceChange: 0.0, reputationChange: 30, xpGain: 70),
          ],
        ),
        GameEventModel(
          id: 'event_billboard_viral_3d_anamorphic',
          title: 'Viral 3D Anamorfik Ekran Gösterisi',
          description: 'Yazılım ajansı billboardda ekrandan fırlayan 3 boyutlu spor araba animasyonu başlattı, video TikTok ve Instagramda milyonlar izlendi!',
          iconEmoji: 'billboard',
          amount: 30000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Yazılım Telifini Öde & Yayında Tut • Masraf -8.000 ₺ • Getiri +30.000 ₺', resultText: 'Galeri önünde selfie çeken yüzlerce insan showrooma akın etti!', balanceChange: 22000.0, reputationChange: 60, xpGain: 220),
            GameEventChoice(label: 'Klasik Reklam Döngüsüne Dön', resultText: 'Standart reklamlar yayınlanmaya devam etti.', balanceChange: 5000.0, reputationChange: 10, xpGain: 40),
          ],
        ),

        // --- YAN İŞLETMELER: HIZLI SERVİS & MEKANİK BAKIM FIRSATLARI ---
        GameEventModel(
          id: 'event_autoshop_supercar_oil_service',
          title: 'Milyonluk İtalyan Süper Spor Yağ Bakımı',
          description: 'Şehre tatile gelen koleksiyoner süper spor aracının kuru karter yarış yağını senin serviste değiştirmek istedi!',
          iconEmoji: 'wrench',
          amount: 22000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Özel İthal Yağ Getirt & Titizlikle Yap • +22.000 ₺', resultText: 'Kusursuz bakım yapıldı, süper spor sahibinden dev bahşiş ve teşekkür geldi.', balanceChange: 22000.0, reputationChange: 45, xpGain: 170),
            GameEventChoice(label: 'Risk Alma & Yetkili Bayiye Yönlendir', resultText: 'Mütevazı esnaflık tavrı takdir topladı.', balanceChange: 0.0, reputationChange: 10, xpGain: 30),
          ],
        ),
        GameEventModel(
          id: 'event_autoshop_bulk_drum_oil_deal',
          title: 'Toptan Varil Motor Yağı İndirim Partisi',
          description: 'Gümrük tasfiyesinden çıkan 50 varil orijinal tam sentetik 5W-30 motor yağı piyasa değerinin üçte birine teklif edildi!',
          iconEmoji: 'wrench',
          amount: 40000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Tüm Partiyi Kapat • Masraf -20.000 ₺ • Kazanç +40.000 ₺', resultText: 'Depo kaliteli yağla doldu, servis marjları tavan yaptı.', balanceChange: 20000.0, reputationChange: 25, xpGain: 130),
            GameEventChoice(label: 'Nakitini Sakla & Pas Geç', resultText: 'Sermaye sıcak tutuldu.', balanceChange: 0.0, reputationChange: 0, xpGain: 10),
          ],
        ),

        // --- YAN İŞLETMELER: ARAÇ MUAYENE & ÖN KONTROL FIRSATLARI ---
        GameEventModel(
          id: 'event_inspection_commercial_fleet_audit',
          title: 'Lojistik Şirketi Kamyonet Filosu Ön Muayenesi',
          description: '40 araçlık şehir içi kargo filosu resmi muayene öncesi tüm fren, far ve egzoz kusurlarını gidermen için istasyona geldi!',
          iconEmoji: 'chart',
          amount: 38000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Ek Mesai Yap & Filoyu Muayene Et • +38.000 ₺', resultText: 'Tüm araçlar kusursuz geçirildi, şirketle yıllık protokol imzalandı.', balanceChange: 38000.0, reputationChange: 40, xpGain: 190),
            GameEventChoice(label: 'Rutin Randevuları Bozma • +10.000 ₺', resultText: 'Sadece 10 araç kabul edildi, geri kalanı yönlendirildi.', balanceChange: 10000.0, reputationChange: 10, xpGain: 50),
          ],
        ),
        GameEventModel(
          id: 'event_inspection_laser_alignment_upgrade',
          title: 'Lazerli 3D Far & Ön Düzen Kalibrasyon Cihazı',
          description: 'Yeni nesil optik lazer kalibrasyon standı araç geçiş hızını ve raporlama güvenilirliğini en üst seviyeye çıkarıyor!',
          iconEmoji: 'chart',
          amount: 25000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Lazerli Cihazı Kur • Masraf -12.000 ₺ • Getiri +25.000 ₺', resultText: 'Muayene hattı saat gibi işliyor, esnaf odasından takdirname geldi.', balanceChange: 13000.0, reputationChange: 35, xpGain: 140),
            GameEventChoice(label: 'Mevcut Optik Cihazla Devam Et', resultText: 'Klasik yöntemle muayeneler sürdürüldü.', balanceChange: 0.0, reputationChange: 5, xpGain: 20),
          ],
        ),

        // --- YAN İŞLETMELER: KURUMSAL EKSPERTİZ FIRSATLARI ---
        GameEventModel(
          id: 'event_expertise_youtube_phenomenon_review',
          title: 'Ünlü Otomobil Fenomeni Gizli Müşteri Teftişi',
          description: '1 Milyon takipçili otomobil YouTuberı gizlice kaportası hileli araç getirip ekspertiz merkezini denedi ve tam not verdi!',
          iconEmoji: 'star',
          amount: 30000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Videonun Sponsoru Ol & Paylaş • +30.000 ₺', resultText: 'Video trendlere girdi, Türkiye genelinden ekspertiz randevusu yağdı!', balanceChange: 30000.0, reputationChange: 70, xpGain: 250),
            GameEventChoice(label: 'Mütevazı Esnaf Kal • +25 İtibar', resultText: 'Şov yapmadan dürüst ticaretinle anıldın.', balanceChange: 5000.0, reputationChange: 25, xpGain: 60),
          ],
        ),
        GameEventModel(
          id: 'event_expertise_court_expert_assignment',
          title: 'Adliye Mahkeme Bilirkişilik Görevi',
          description: 'Bölge adliyesi ihtilaflı ağır hasar ve tramer davalarında ekspertiz merkezini resmi adli bilirkişi tayin etti!',
          iconEmoji: 'shield',
          amount: 25000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Görevi Kabul Et & Raporları Hazırla • +25.000 ₺', resultText: 'Adli bilirkişi unvanı merkeze muazzam bir kurumsal güvenilirlik kattı.', balanceChange: 25000.0, reputationChange: 50, xpGain: 180),
            GameEventChoice(label: 'Vaktim Yok De & Reddet', resultText: 'Rutin ekspertiz işlerine odaklanıldı.', balanceChange: 0.0, reputationChange: 0, xpGain: 20),
          ],
        ),

        // --- YAN İŞLETMELER: RENT A CAR & FİLO FIRSATLARI ---
        GameEventModel(
          id: 'event_rental_cinema_movie_production',
          title: 'Dizi & Sinema Filmi Çekim Filosu Kiralama',
          description: 'Bölgede çekilen aksiyon dizisi yapımcısı 5 adet siyah lüks SUV ve sedanı 2 hafta boyunca kapatmak istiyor!',
          iconEmoji: 'car',
          amount: 65000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Filoyu Diziye Tahsis Et • +65.000 ₺', resultText: 'Araçlar sette başrolde boy gösterdi, yüksek kiralama geliri kasaya girdi.', balanceChange: 65000.0, reputationChange: 40, xpGain: 240),
            GameEventChoice(label: 'Bireysel Müşterileri Mağdur Etme • +18.000 ₺', resultText: 'Sadece 2 araç tahsis edildi, sabit müşteriler korundu.', balanceChange: 18000.0, reputationChange: 15, xpGain: 70),
          ],
        ),
        GameEventModel(
          id: 'event_rental_airport_vip_transfer_franchise',
          title: 'Havalimanı VIP Transfer Acentelik Teklifi',
          description: 'Turizm firması havalimanı transferleri için lüks araçlarına sabit yüksek karlı yolcu yönlendirmeyi teklif etti!',
          iconEmoji: 'car',
          amount: 42000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Acenteliği Al & Seferleri Başlat • +42.000 ₺', resultText: 'Havalimanı hattı bağlandı, kiralık araçlar hiç boş yatmıyor.', balanceChange: 42000.0, reputationChange: 35, xpGain: 180),
            GameEventChoice(label: 'Sadece Günlük Kiralamada Kal', resultText: 'Rutin operasyonla devam edildi.', balanceChange: 0.0, reputationChange: 5, xpGain: 20),
          ],
        ),

        // --- YAN İŞLETMELER: ELEKTRİKLİ ŞARJ İSTASYONU FIRSATLARI ---
        GameEventModel(
          id: 'event_ev_solar_canopy_installation',
          title: 'Güneş Enerjili Solar Sundurma Kurulumu',
          description: 'Şarj istasyonunun üzerine kurulan güneş panelleri gündüz şebeke elektriğini sıfırlayıp devlete elektrik satışı başlattı!',
          iconEmoji: 'battery',
          amount: 35000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Solar Sundurmayı Kur • Masraf -18.000 ₺ • Kazanç +35.000 ₺', resultText: 'Yeşil enerji sertifikası alındı, elektrik maliyeti sıfırlandı!', balanceChange: 17000.0, reputationChange: 55, xpGain: 210),
            GameEventChoice(label: 'Klasik Şebekeden Beslenmeye Devam Et', resultText: 'Mevcut şebekeyle standart şarj hizmeti sürdürüldü.', balanceChange: 0.0, reputationChange: 0, xpGain: 15),
          ],
        ),
        GameEventModel(
          id: 'event_ev_fleet_overnight_depot',
          title: 'Elektrikli Kurye Filosu Gece Şarj Anlaşması',
          description: '50 adet elektrikli teslimat aracı her gece istasyonda şarj olmak için aylık peşin toplu abonelik satın aldı!',
          iconEmoji: 'battery',
          amount: 34000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Gece Şarj Anlaşmasını İmzala • +34.000 ₺', resultText: 'Gece boş kalan istasyon kesintisiz para basan bir tesise dönüştü.', balanceChange: 34000.0, reputationChange: 30, xpGain: 160),
            GameEventChoice(label: 'Bireysel Müşterilere Açık Tut', resultText: 'Gece peronları serbest bırakıldı.', balanceChange: 4000.0, reputationChange: 5, xpGain: 30),
          ],
        ),

        // --- YAN İŞLETMELER: YEDEK PARÇA MAĞAZASI FIRSATLARI ---
        GameEventModel(
          id: 'event_spare_parts_german_oem_distributorship',
          title: 'Alman Orijinal Yedek Parça Bölge Bayiliği',
          description: 'Alman yedek parça devi, bölgedeki sanayi esnafına toptan orijinal parça dağıtımı için mağazana ana bayilik verdi!',
          iconEmoji: 'box',
          amount: 55000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Distribütörlük Sözleşmesini İmzala • Masraf -20.000 ₺ • Getiri +55.000 ₺', resultText: 'Tüm sanayi ustaları parçayı senin mağazadan almaya başladı!', balanceChange: 35000.0, reputationChange: 50, xpGain: 220),
            GameEventChoice(label: 'Perakende Satışa Devam Et', resultText: 'Standart dükkan satışları sürdürüldü.', balanceChange: 0.0, reputationChange: 10, xpGain: 30),
          ],
        ),
        GameEventModel(
          id: 'event_spare_parts_performance_exhaust_trend',
          title: 'Sanayide Paslanmaz Varex Egzoz & Filtre Modası',
          description: 'Genç modifiye tutkunları paslanmaz varex egzoz ve açık hava filtreleri için dükkan önünde kuyruk oluşturdu!',
          iconEmoji: 'box',
          amount: 28000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Egzoz Stokunu Doldur & Satış Yap • +28.000 ₺', resultText: 'Stoklar tükendi, tuning camiasında mağazanın adı yayıldı.', balanceChange: 28000.0, reputationChange: 25, xpGain: 130),
            GameEventChoice(label: 'Sadece Orijinal Parça Sat • +20 İtibar', resultText: 'Orijinalciler mağazanın prensiplerine hayran kaldı.', balanceChange: 0.0, reputationChange: 20, xpGain: 40),
          ],
        ),

        // --- YAN İŞLETMELER: KAPLAMA & PPF STÜDYOSU FIRSATLARI ---
        GameEventModel(
          id: 'event_wrap_supercar_matte_chameleon',
          title: 'Koleksiyoner Bukalemun Renk Değişim Projesi',
          description: 'Zengin iş insanı yeni aldığı süper spor araca dünyada eşi benzeri olmayan renk geçişli mat zırh kaplama istedi!',
          iconEmoji: 'spray',
          amount: 48000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Özel Folyoyu Getirt & Sanat Eseri Çıkar • +48.000 ₺', resultText: 'Kaplama kusursuz bitti, araba otomobil dergilerine kapak oldu!', balanceChange: 48000.0, reputationChange: 65, xpGain: 240),
            GameEventChoice(label: 'Standart Şeffaf Folyoyla Kapla • +18.000 ₺', resultText: 'Klasik PPF çekildi, müşteri memnun ayrıldı.', balanceChange: 18000.0, reputationChange: 20, xpGain: 80),
          ],
        ),
        GameEventModel(
          id: 'event_wrap_commercial_fleet_branding',
          title: 'Zincir Kargo Şirketi 30 Araçlık Filo Giydirme',
          description: 'Ulusal kargo şirketi tüm dağıtım araçlarına kurumsal sarı kaplama ve logo uygulaması için atölyeyi kapattı!',
          iconEmoji: 'spray',
          amount: 52000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Gece Vardiyası Aç & Filoyu Giydir • +52.000 ₺', resultText: '30 araç ışıl ışıl teslim edildi, kargo devinden teşekkür mektubu geldi.', balanceChange: 52000.0, reputationChange: 45, xpGain: 230),
            GameEventChoice(label: 'Kapasite Aşımı De & Yarısını Al • +22.000 ₺', resultText: '15 araç yapıldı, atölye aşırı yorulmadı.', balanceChange: 22000.0, reputationChange: 15, xpGain: 90),
          ],
        ),

        // --- HURDALIK & AĞIR REVİZYON ATÖLYESİ FIRSATLARI ---
        GameEventModel(
          id: 'event_scrap_classic_chassis_treasure',
          title: 'Hurdalıkta Çürümeye Bırakılmış Klasik Kasa Keşfi',
          description: 'Söküm için getirilen eski bir kamyonetin arkasında 1968 model klasik spor araba şasisi bulundu!',
          iconEmoji: 'wrench',
          amount: 75000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Şasiyi Atölyeye Çek & Restore Et • Masraf -20.000 ₺ • Değer +75.000 ₺', resultText: 'Klasik araç canlandırıldı, koleksiyonerler sıraya girdi!', balanceChange: 55000.0, reputationChange: 60, xpGain: 260),
            GameEventChoice(label: 'Hurda Demir Fiyatına Sat • +12.000 ₺', resultText: 'Şasi hızlıca elden çıkarıldı, nakit alındı.', balanceChange: 12000.0, reputationChange: 5, xpGain: 50),
          ],
        ),
        GameEventModel(
          id: 'event_workshop_b2b_engine_rebuild_contract',
          title: 'Sanayi Servisleri İçin Toplu Motor Rektifiye İhalesi',
          description: 'Çevre ilçelerdeki oto tamircileri motor honlama ve krank taşlama işlerini senin usta atölyene bağlamak istiyor!',
          iconEmoji: 'wrench',
          amount: 46000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Ağır Revizyon Sözleşmesi İmzala • +46.000 ₺', resultText: 'Atölye bölgenin motor rektifiye merkez üssü haline geldi.', balanceChange: 46000.0, reputationChange: 40, xpGain: 210),
            GameEventChoice(label: 'Kendi Araçlarımıza Odaklanalım', resultText: 'Dış iş alımı reddedildi.', balanceChange: 0.0, reputationChange: 5, xpGain: 20),
          ],
        ),

        // --- OFİS & YÖNETİM FIRSATLARI ---
        GameEventModel(
          id: 'event_office_classic_espresso_upgrade',
          title: 'İtalyan Barista Kahve Makinesi & VIP Ağırlama',
          description: 'Ofise kurulan profesyonel bakır gövdeli barista espresso makinesi araç pazarlıklarında psikolojik üstünlük sağladı!',
          iconEmoji: 'coffee',
          amount: 15000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Barista Makinesini Kur • Masraf -8.000 ₺ • Getiri +15.000 ₺', resultText: 'Müşteriler kahve içerken rahatlayıp daha kolay el sıkışıyor.', balanceChange: 7000.0, reputationChange: 35, xpGain: 110),
            GameEventChoice(label: 'Termos Çayla Devam Et', resultText: 'Geleneksel ikram sürdürüldü.', balanceChange: 0.0, reputationChange: 0, xpGain: 10),
          ],
        ),
        GameEventModel(
          id: 'event_office_antique_leather_chesterfield',
          title: 'Tarihi Chester Koltuk Takımı & Baron Havası',
          description: 'Eski bir büyükelçilik müzayedesinden hakiki deri Chesterfield koltuk takımı ofis köşesine çıktı!',
          iconEmoji: 'star',
          amount: 25000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Müzayededen Koltukları Al • Masraf -10.000 ₺ • Değer +25.000 ₺', resultText: 'Ofis adeta bir holding yönetim odasına dönüştü, VIP alıcılar büyülendi.', balanceChange: 15000.0, reputationChange: 50, xpGain: 160),
            GameEventChoice(label: 'Mevcut Koltuklarla Devam Et', resultText: 'Sermaye korundu.', balanceChange: 0.0, reputationChange: 5, xpGain: 15),
          ],
        ),

        // ==========================================
        // --- GENİŞLEME PAKETİ: ZİNCİRLEME & ÇOK AŞAMALI OLAYLAR ---
        // ==========================================
        GameEventModel(
          id: 'event_scrap_classic_auction_climax',
          title: 'Restore Edilen 1968 Klasik Şasi Müzayedede Rekor Kırdı',
          description: 'Hurdalıktan kurtarıp atölyede sıfırdan topladığın 1968 klasik otomobil uluslararası müzayedede vitrine çıktı, koleksiyonerler nefesini tuttu!',
          iconEmoji: 'trophy',
          amount: 140000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'En Yüksek Teklifi Veren Koleksiyonere Sat • +140.000 ₺', resultText: 'Müzayede çeki tahsil edildi, galeri otomotiv camiasında efsane oldu!', balanceChange: 140000.0, reputationChange: 50, xpGain: 350),
            GameEventChoice(label: 'Satma & Galeri Müze Köşesinde Sergile • +85 İtibar', resultText: 'Klasik araç showroomun gözbebeği oldu, gelen her müşteri hayran kalıyor.', balanceChange: 0.0, reputationChange: 85, xpGain: 200),
          ],
        ),
        GameEventModel(
          id: 'event_rental_movie_gala_premiere',
          title: 'Aksiyon Filmi Gala Gecesi & Kırmızı Halı Sponsorluğu',
          description: 'Galerinin kiralık SUV filosunu kullanan aksiyon dizisi sinema filmine uyarlandı ve galaya ana sponsorluk teklif etti!',
          iconEmoji: 'star',
          amount: 45000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Gala Sponsoru Ol & Kırmızı Halıda Boy Göster • Masraf -15.000 ₺ • Getiri +45.000 ₺', resultText: 'Gala gecesinde ünlüler araçlarının önünde röportaj verdi, prestij tavan yaptı.', balanceChange: 30000.0, reputationChange: 80, xpGain: 300),
            GameEventChoice(label: 'Sadece Teşekkür Plaketi Al • +25 İtibar', resultText: 'Sade bir teşekkürle yetinildi.', balanceChange: 0.0, reputationChange: 25, xpGain: 50),
          ],
        ),
        GameEventModel(
          id: 'event_ev_epdk_green_energy_rebate',
          title: 'EPDK Yeşil Enerji Teşvik İkramiyesi',
          description: 'Elektrikli şarj istasyonundaki güneş enerjisi yatırımı nedeniyle Enerji Piyasası Kurumu yeşil dönüşüm hibe desteği onayladı!',
          iconEmoji: 'battery',
          amount: 50000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Hibe Desteğini Tahsil Et • +50.000 ₺', resultText: 'Devlet teşvik primi hesaba yattı, istasyon tamamen kâra geçti.', balanceChange: 50000.0, reputationChange: 45, xpGain: 220),
          ],
        ),
        GameEventModel(
          id: 'event_expertise_airbag_redemption_award',
          title: 'Tüketici Federasyonu Yılın En Şeffaf Esnafı Beratı',
          description: 'Hatalı ekspertiz mağduriyetini tereddütsüz cebinden karşılayıp müşteriye sahip çıktığın için Tüketici Dernekleri seni örnek esnaf gösterdi!',
          iconEmoji: 'shield',
          amount: 35000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Beratla Birlikte Güven Kampanyası Başlat • +35.000 ₺', resultText: 'Bölgedeki tüm ikinci el alıcıları artık ekspertiz için sana akın ediyor!', balanceChange: 35000.0, reputationChange: 75, xpGain: 260),
          ],
        ),

        // ==========================================
        // --- GENİŞLEME PAKETİ: MEVSİMSEL & MAKRO ÇEVRE OLAYLARI ---
        // ==========================================
        GameEventModel(
          id: 'event_winter_blizzard_crisis',
          title: 'Dondurucu Kış Fırtınası & Yolda Kalanlar Akını',
          description: 'Sıfırın altında 15 derece dondurucu kar fırtınası şehri kilitledi! Oto kurtarma çekicisi, donan aküler ve antifriz servisi için telefonlar kilitlendi!',
          iconEmoji: 'tow',
          amount: 42000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: '7/24 Acil Kış Kurtarma Hattı Aç • Masraf -10.000 ₺ • Getiri +42.000 ₺', resultText: 'Çekiciler ve atölye gece gündüz çalıştı, kışın kahramanı ilan edildin.', balanceChange: 32000.0, reputationChange: 60, xpGain: 250),
            GameEventChoice(label: 'Sadece Standart Mesaiyi Açık Tut • +14.000 ₺', resultText: 'Gündüz gelen araçlara müdahale edildi.', balanceChange: 14000.0, reputationChange: 15, xpGain: 60),
          ],
        ),
        GameEventModel(
          id: 'event_summer_tourism_boom',
          title: 'Kavurucu Yaz Sezonu & Turist Akını',
          description: 'Yaz tatili ve gurbetçi sezonunda şehre inen turistler lüks kiralık araç, seramik koruma ve hızlı yıkama için kapıda sıra oldu!',
          iconEmoji: 'car',
          amount: 55000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Turizm Fiyat Tarifesiyle Tam Kapasite Çalış • +55.000 ₺', resultText: 'Sezon cirosu rekor kırdı, döviz kasaya aktı.', balanceChange: 55000.0, reputationChange: 40, xpGain: 230),
            GameEventChoice(label: 'Sabit Esnaf Fiyatıyla Devam Et • +22.000 ₺', resultText: 'Yerel müşteriler hakkaniyetli tavrını takdir etti.', balanceChange: 22000.0, reputationChange: 25, xpGain: 90),
          ],
        ),
        GameEventModel(
          id: 'event_holiday_rush_maintenance',
          title: 'Bayram Öncesi Memleket Yolu Bakım Hücumu',
          description: 'Bayram tatilinde uzun yola çıkacak yüzlerce aile hızlı bakım, fren testi ve muayene ön kontrolü için dükkan önünde kuyruk oldu!',
          iconEmoji: 'wrench',
          amount: 48000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Çift Vardiya Aç & Tüm Araçları Yola Hazırla • +48.000 ₺', resultText: 'Tüm ailelerin araçları yola sorunsuz çıktı, dualar ve teşekkürler yağdı.', balanceChange: 48000.0, reputationChange: 50, xpGain: 240),
            GameEventChoice(label: 'Normal Mesaiyle Yetin • +16.000 ₺', resultText: 'Sadece randevulu araçlar yetiştirildi.', balanceChange: 16000.0, reputationChange: 15, xpGain: 70),
          ],
        ),
        GameEventModel(
          id: 'event_macro_import_customs_quota',
          title: 'Otomotiv İthalatında Gümrük Ek Fon Kararı',
          description: 'Sıfır araç ithalatına gelen ek gümrük fonu sonrası ikinci el araç piyasası ve yerli yedek parça talebi patlama yaptı!',
          iconEmoji: 'chart',
          amount: 60000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Yedek Parça & İkinci El Stokunu Genişlet • Masraf -25.000 ₺ • Kazanç +60.000 ₺', resultText: 'Stoklanan parçalar ve araçlar değer kazandı, büyük kâr elde edildi.', balanceChange: 35000.0, reputationChange: 30, xpGain: 200),
            GameEventChoice(label: 'Temkinli Bekle & Nakitini Tut', resultText: 'Piyasa dalgalanmasında risk alınmadı.', balanceChange: 0.0, reputationChange: 5, xpGain: 20),
          ],
        ),

        // ==========================================
        // --- GENİŞLEME PAKETİ: SEKTÖREL GÜÇLER, LONCA & BANKACILIK ---
        // ==========================================
        GameEventModel(
          id: 'event_guild_presidency_election',
          title: 'Oto Galericiler Sitesi Yönetim Kurulu Başkanlığı',
          description: 'Bölgenin en büyük oto galericiler sitesinde yönetim kurulu başkanlığına güçlü aday olarak gösterildin!',
          iconEmoji: 'trophy',
          amount: 0.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Aday Ol & Seçim Kampanyası Yürüt • Masraf -20.000 ₺ • +100 İtibar', resultText: 'Büyük oy farkıyla başkan seçildin, tüm sanayi ve galeri esnafı arkanda!', balanceChange: -20000.0, reputationChange: 100, xpGain: 350),
            GameEventChoice(label: 'Kendi Ticaretime Bakarım De & Çekil • +10 İtibar', resultText: 'Ticaretine odaklanmaya devam ettin.', balanceChange: 0.0, reputationChange: 10, xpGain: 40),
          ],
        ),
        GameEventModel(
          id: 'event_apprentice_vocational_school_deal',
          title: 'Meslek Lisesi Genç Usta Stajyer Protokolü',
          description: 'Mesleki ve Teknik Anadolu Lisesi Motor Bölümü en başarılı 5 son sınıf öğrencisini senin serviste yetiştirmek için protokol teklif etti!',
          iconEmoji: 'wrench',
          amount: 30000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Öğrencilere Burs Ver & Atölyeye Al • Masraf -10.000 ₺ • Kazanç +30.000 ₺', resultText: 'Genç ustalar arı gibi çalıştı, işçilik verimi ikiye katlandı.', balanceChange: 20000.0, reputationChange: 80, xpGain: 280),
            GameEventChoice(label: 'Stajyerle Uğraşacak Vaktim Yok De', resultText: 'Protokol nazikçe geri çevrildi.', balanceChange: 0.0, reputationChange: -5, xpGain: 15),
          ],
        ),
        GameEventModel(
          id: 'event_bank_manager_vip_credit_line',
          title: 'Banka Bölge Müdürü Özel Ticari Protokol & POS İndirimi',
          description: 'Galerinin işlem hacmini gören banka bölge müdürü kahveye geldi, düşük komisyonlu özel POS ve devasa ticari kredi limiti sundu!',
          iconEmoji: 'money',
          amount: 15000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Özel Bankacılık Protokolünü İmzala • +15.000 ₺', resultText: 'POS komisyonları sıfıra yaklaştı, finansal işlemler hızlandı.', balanceChange: 15000.0, reputationChange: 50, xpGain: 190),
            GameEventChoice(label: 'Borçlanmadan Öz Sermayeyle Devam Et • +20 İtibar', resultText: 'Öz kaynak gücün bankacıları bile şaşırttı.', balanceChange: 0.0, reputationChange: 20, xpGain: 50),
          ],
        ),
        GameEventModel(
          id: 'event_auto_festival_sponsorship',
          title: 'Organize Sanayi Modifiye & Drift Festivali Ana Sponsorluğu',
          description: 'Şehir stadı otoparkında düzenlenen resmi drift ve otomobil festivali ana sponsorluk ve onur jüriliği için kapını çaldı!',
          iconEmoji: 'star',
          amount: 50000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Festivalin Ana Sponsoru Ol • Masraf -25.000 ₺ • Getiri +50.000 ₺', resultText: 'Festivalde yüzbinler adını haykırdı, showroom siparişle doldu taştı!', balanceChange: 25000.0, reputationChange: 120, xpGain: 400),
            GameEventChoice(label: 'Küçük Bir Stant Aç • Masraf -5.000 ₺ • Getiri +12.000 ₺', resultText: 'Mütevazı bir tanıtım yapıldı.', balanceChange: 7000.0, reputationChange: 30, xpGain: 90),
          ],
        ),

        // --- İYİ OLAYLAR ---
        GameEventModel(
          id: 'event_tv',
          title: 'Otomobil Programı Çekimi',
          description: 'Ünlü bir YouTube otomobil kanalı klasik araçlarını incelemek için galeriye geldi!',
          iconEmoji: 'party',
          amount: 15000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Programda Röportaj Ver • +20.000 ₺, +İtibar', resultText: 'Milyonlar izledi, dükkana telefon yağdı!', balanceChange: 20000.0, reputationChange: 40, xpGain: 150),
          ],
        ),
        GameEventModel(
          id: 'event_miras_amca',
          title: 'Almanya\'daki Zengin Amca',
          description: 'Almanya\'da oto galeri işleten uzaktan bir akraban sana sürpriz döviz desteği gönderdi!',
          iconEmoji: 'cash',
          amount: 35000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Sermayeye Ekle • +35.000 ₺', resultText: 'Kasan bayram etti!', balanceChange: 35000.0, reputationChange: 5, xpGain: 80),
          ],
        ),
        GameEventModel(
          id: 'event_odul',
          title: 'Bölgenin En Güvenilir Galerisi Ödülü',
          description: 'Otomotiv Esnaf Odası tarafından Yılın En Şeffaf Ekspertizli Galerisi seçildin!',
          iconEmoji: 'trophy',
          amount: 10000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Ödülü Vitrine As • +60 İtibar', resultText: 'Müşteriler artık gözü kapalı araç alıyor!', balanceChange: 10000.0, reputationChange: 60, xpGain: 200),
          ],
        ),
        GameEventModel(
          id: 'event_unlu_musteri',
          title: 'Süper Lig Futbolcusu Ziyareti',
          description: 'Milli futbolcu lüks SUV bakmak için menajeriyle birlikte galerine uğradı!',
          iconEmoji: 'star',
          amount: 25000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Fotoğraf Çekil & Paylaş • +40 İtibar, +Bahşiş', resultText: 'Futbolcu aracı beğendi ve galeriye prim kazandırdı!', balanceChange: 25000.0, reputationChange: 40, xpGain: 150),
          ],
        ),

        // --- KOMİK & MEME OLAYLAR ---
        GameEventModel(
          id: 'event_olucu_usta',
          title: 'Pazarlık Şampiyonu Ölücü Alıcı',
          description: 'Bir müşteri 650.000 ₺ değerindeki araç için 35.000 ₺ nakit ve 2 çuval fındık teklif etti!',
          iconEmoji: 'clown',
          amount: 0.0,
          type: GameEventType.meme,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Nazikçe Hayırlı İşler De • +İtibar', resultText: 'Mizah anlayışın dükkanda neşe yarattı.', balanceChange: 0.0, reputationChange: 10, xpGain: 50),
            GameEventChoice(label: 'Dükkandan Kov', resultText: 'Adam kapıdan homurdanarak çıktı gitti.', balanceChange: 0.0, reputationChange: -5, xpGain: 20),
          ],
        ),
        GameEventModel(
          id: 'event_kopek_karabas',
          title: 'Nöbetçi Köpek Karabaş',
          description: 'Sanayiden gelen sevimli bir köpek galerinin kapısını mesken tuttu. Geceleri bekçilik yapıyor!',
          iconEmoji: 'dog',
          amount: 0.0,
          type: GameEventType.meme,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Kulübe Yap & Besle • -1.000 ₺, +İtibar', resultText: 'Karabaş galerinin resmi maskotu oldu!', balanceChange: -1000.0, reputationChange: 30, xpGain: 80),
            GameEventChoice(label: 'Barınağa Bildir', resultText: 'Güvenli şekilde barınağa teslim edildi.', balanceChange: 0.0, reputationChange: 5, xpGain: 30),
          ],
        ),
        GameEventModel(
          id: 'event_hayalet_tofas',
          title: 'Gece Çalışan Hayalet Murat 124',
          description: 'Gece bekçisi dededen kalan Murat 124 aracının farlarının kendi kendine yandığını iddia ediyor!',
          iconEmoji: 'ghost',
          amount: 0.0,
          type: GameEventType.meme,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Akü Kutup Başını Kontrol Et • +XP', resultText: 'Meğer şase kablosu gevşemiş! Tamir ettin.', balanceChange: 0.0, reputationChange: 5, xpGain: 100),
            GameEventChoice(label: 'Medyumlara Haber Ver • -2.000 ₺', resultText: 'Mahalleli gece galerinin önüne toplanıp dua etti.', balanceChange: -2000.0, reputationChange: 15, xpGain: 50),
          ],
        ),
        GameEventModel(
          id: 'event_sanayi_tostu',
          title: 'Sanayi Tostçusu Erol Usta Ziyafeti',
          description: 'Meşhur sanayi tostçusu Erol Usta galeri personeline 10 adet karışık atom tost ısmarladı!',
          iconEmoji: 'sandwich',
          amount: 0.0,
          type: GameEventType.meme,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Afiyetle Ye & Moral Depola • +XP', resultText: 'Tüm ekibin çalışma hızı ikiye katlandı!', balanceChange: 0.0, reputationChange: 10, xpGain: 90),
          ],
        ),

        // --- NOTER, VERGİ & BÜROKRASİ RİSKLERİ & FIRSATLARI ---
        GameEventModel(
          id: 'event_notary_fake_cash',
          title: 'Noter Masasında Sahte Deste Şoku',
          description: 'Araç devri sırasında alıcının getirdiği nakit deste içinde noter sahte banknot yakaladı ve işlemi durdurdu!',
          iconEmoji: 'money',
          amount: -3500.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Noter Güvenli Satış Sistemiyle Yeniden Başlat • -3.500 ₺', resultText: 'İşlem resmi güvenceye alındı, devir tamamlandı.', balanceChange: -3500.0, reputationChange: 15, xpGain: 90),
            GameEventChoice(label: 'Parayı Sayma Makinesinden Geçir • -1.000 ₺', resultText: 'Şüpheli paralar ayrıldı, alıcı kalanını tamamladı.', balanceChange: -1000.0, reputationChange: 5, xpGain: 60),
            GameEventChoice(label: 'Satışı İptal Et & Müşteriyi Kov • -İtibar', resultText: 'Noter katibine tutanak tutuldu, satış yattı.', balanceChange: 0.0, reputationChange: -15, xpGain: 20),
          ],
        ),
        GameEventModel(
          id: 'event_notary_power_of_attorney_expired',
          title: '30 Günlük Noter Vekaleti Süresi Doldu',
          description: 'Takasla alınan aracın eski sahibinden alınan alım satım vekaletnamesinin süresi dolmuş. Ruhsat sahibi memleketten vekalet yenilemek için yol parası istiyor!',
          iconEmoji: 'document',
          amount: -2500.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Yol Masrafı & Yeni Noter Harcı Gönder • -2.500 ₺', resultText: 'Yeni vekalet geldi, araç satışa hazır hale geldi.', balanceChange: -2500.0, reputationChange: 10, xpGain: 70),
            GameEventChoice(label: 'Avukat İle Noterden Resmi İhtar Çek • -4.500 ₺', resultText: 'Hukuki süreç başlatıldı, araç bir süre otoparkta bekleyecek.', balanceChange: -4500.0, reputationChange: 20, xpGain: 110),
          ],
        ),
        GameEventModel(
          id: 'event_notary_hidden_tax_block',
          title: 'Noter Devrinde Gizli MTV & İcra Kilidi',
          description: 'Tertemiz ekspertizli aracın noter devri sırasında vergi dairesinden 3 yıllık birikmiş MTV ve otoyol icra borcu çıktı, noter ekranı kilitlendi!',
          iconEmoji: 'tax',
          amount: -6500.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Borcu Satıcının Parasından Kesip Anında Öde • -6.500 ₺', resultText: 'Kilit kalktı, devir saniyeler içinde tamamlandı.', balanceChange: -6500.0, reputationChange: 25, xpGain: 100),
            GameEventChoice(label: 'Satışı İptal Et & Noter Harcını Al • -800 ₺', resultText: 'Satıştan vazgeçildi, araç sahibine iade edildi.', balanceChange: -800.0, reputationChange: -5, xpGain: 30),
          ],
        ),
        GameEventModel(
          id: 'event_vip_special_plate_request',
          title: 'VIP Müşteriden Özel Harf Grubu Plaka Talebi',
          description: 'Lüks araç satın alan holding patronu aracına memleketine ve ismine özel harf grubu plaka tahsisi talep etti!',
          iconEmoji: 'star',
          amount: 20000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Trafik Şube Vakfına Bağış Yap & Plakayı Al • +20.000 ₺', resultText: 'Özel plaka takıldı, holding patronu büyük prim bıraktı!', balanceChange: 20000.0, reputationChange: 45, xpGain: 150),
            GameEventChoice(label: 'Standart Sıradan Plaka ile Teslim Et', resultText: 'Standart plaka verildi, rutin teslimat yapıldı.', balanceChange: 0.0, reputationChange: 0, xpGain: 30),
          ],
        ),

        // --- MÜŞTERİ PSİKOLOJİSİ & SATIŞ TUZAKLARI ---
        GameEventModel(
          id: 'event_customer_deposit_ghosting',
          title: 'Kapora Verip Ortadan Kaybolan Alıcı',
          description: '10.000 ₺ kapora bırakıp aracı 7 gün boyunca kimseye sattırmayan müşteri telefonlarını tamamen kapattı!',
          iconEmoji: 'handshake',
          amount: 10000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Kaporayı İrat Kaydet & Aracı Vitrine Çıkar • +10.000 ₺', resultText: 'Kapora kasaya gelir yazıldı, araç yeniden ilana çıktı.', balanceChange: 10000.0, reputationChange: 5, xpGain: 80),
            GameEventChoice(label: '3 Gün Daha Bekle & Noter Tebligatı Çek • -600 ₺', resultText: 'Hukuki tebligat çekildi, dürüst tüccar imajı pekişti.', balanceChange: -600.0, reputationChange: 15, xpGain: 50),
          ],
        ),
        GameEventModel(
          id: 'event_night_shady_buyer',
          title: 'Akşam Karanlığında Araba İnceleyen Müşteri',
          description: 'Hava karardıktan sonra gelen gizemli bir alıcı, galerideki kaporta kusurlu araca hiç pazarlıksız hemen talip oldu!',
          iconEmoji: 'night',
          amount: 22000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Loş Işıkta Sözleşmeyle Sat • +22.000 ₺', resultText: 'Araç yüksek kârla elden çıktı, nakit kasaya girdi.', balanceChange: 22000.0, reputationChange: -10, xpGain: 100),
            GameEventChoice(label: 'Yarın Gündüz Ekspertize Davet Et • +İtibar', resultText: 'Müşteri şeffaflığına hayran kaldı, güven tazeledi.', balanceChange: 0.0, reputationChange: 30, xpGain: 80),
          ],
        ),
        GameEventModel(
          id: 'event_buyer_knowitall_uncle',
          title: 'Alıcının Yanında Gelen Sanayici Enişte',
          description: 'Aracı almaya gelen müşterinin oto tamircisi eniştesi her parçaya kusur bularak 35.000 ₺ indirim koparmaya çalışıyor!',
          iconEmoji: 'wrench',
          amount: 0.0,
          type: GameEventType.meme,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Otomat & Kahve İkram Et & Gönlünü Al • -250 ₺', resultText: 'Enişteye taze espresso ısmarladın, yumuşayıp satışı onayladı.', balanceChange: -250.0, reputationChange: 20, xpGain: 75),
            GameEventChoice(label: 'Ekspertiz Raporunu Masaya Vur & Fiyatta Diren • +İtibar', resultText: 'TSE belgeli rapor karşısında enişte söyleyecek söz bulamadı.', balanceChange: 0.0, reputationChange: 35, xpGain: 120),
            GameEventChoice(label: 'Pazarlığı Bitir & Müşteriyi Uğurla', resultText: 'Zaman kaybetmedin, başka müşteriye odaklandın.', balanceChange: 0.0, reputationChange: -10, xpGain: 20),
          ],
        ),
        GameEventModel(
          id: 'event_suspicious_lost_registration_swap',
          title: 'Şüpheli Kayıp Ruhsatlı Lüks Takas Teklifi',
          description: 'Gece vakti gelen bir satıcı piyasa değeri 1.200.000 ₺ olan spor aracı ruhsatın kayıp olduğunu söyleyerek 450.000 ₺ nakite bırakmak istedi!',
          iconEmoji: 'siren',
          amount: 0.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Asayiş Şubeye ve Polise İhbar Et • +İtibar, +Ödül', resultText: 'Çalıntı şebekesi çökertildi, emniyetten teşekkür plaketi aldın!', balanceChange: 15000.0, reputationChange: 50, xpGain: 180),
            GameEventChoice(label: 'Teklifi Reddet & Güvenliği Sağla', resultText: 'Riskli tekliften uzak durdun, başını ağrıtmadın.', balanceChange: 0.0, reputationChange: 15, xpGain: 60),
          ],
        ),

        // --- PERSONEL DİNAMİKLERİ & SANAYİ AĞI ---
        GameEventModel(
          id: 'event_master_mechanic_poached',
          title: 'Baş Ustanın Karşıya Dükkan Açma Tehdidi',
          description: 'Rakip galeri Baş Ustana ortaklık teklif etti. Usta en iyi çırakları da alıp karşı kaldırıma servis açmayı düşünüyor!',
          iconEmoji: 'craftsman',
          amount: -16000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Yıllık Usta Primi & Kârdan Pay Ver • -16.000 ₺', resultText: 'Usta galeride kaldı, ekibin sadakati ve çalışma azmi zirve yaptı.', balanceChange: -16000.0, reputationChange: 30, xpGain: 130),
            GameEventChoice(label: 'Kapıyı Göster & Yeni Ekip Kur • -İtibar', resultText: 'Usta ayrıldı, servisteki araçlar birkaç gün gecikti.', balanceChange: 0.0, reputationChange: -25, xpGain: 40),
          ],
        ),
        GameEventModel(
          id: 'event_sanayi_broker_deal',
          title: 'Sanayi Ayakçısından Hızlı Eritme Teklifi',
          description: 'Sanayideki ayakçı komisyoncu esnafı, galeride uzun süredir bekleyen ağır hasarlı aracı komisyonla 24 saatte bağlamayı teklif etti!',
          iconEmoji: 'coin',
          amount: 28000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Komisyoncuya Ver & Anında Nakite Dön • +28.000 ₺', resultText: 'Araç aynı gün elden çıkarıldı, taze nakit girişi sağlandı.', balanceChange: 28000.0, reputationChange: 5, xpGain: 90),
            GameEventChoice(label: 'Kendi Vitrininde Bekletmeye Devam Et', resultText: 'Komisyon vermedin, vitrinde bekletiyorsun.', balanceChange: 0.0, reputationChange: 0, xpGain: 20),
          ],
        ),
        GameEventModel(
          id: 'event_apprentice_graduation_milestone',
          title: 'Çırağın Kalfalık & Ustalık Belgesi Töreni',
          description: 'Atölyede yüzlerce başarılı onarım yapan çırağın Esnaf Odasından resmi Ustalık Belgesi geldi!',
          iconEmoji: 'trophy',
          amount: -4000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Sanayi Ziyafeti Ver & Maaşına Zam Yap • -4.000 ₺', resultText: 'Ustalık belgesi vitrine asıldı, atölye onarım hızı arttı.', balanceChange: -4000.0, reputationChange: 35, xpGain: 150),
            GameEventChoice(label: 'Tebrik Et & Mevcut Şartlarla Devam Et', resultText: 'Çırak ustalık unvanıyla çalışmaya devam ediyor.', balanceChange: 0.0, reputationChange: 5, xpGain: 40),
          ],
        ),

        // --- YAN İŞLETMELER ÇAPRAZ SİNERJİSİ ---
        GameEventModel(
          id: 'event_expertise_customer_distress_sale',
          title: 'Ekspertize Gelen Müşteriden Kelepir Araç Fırsatı',
          description: 'Dışarıdan ekspertiz yaptırmaya gelen bir araç sahibi acil kredi borcu için arabasını ilana koymadan piyasa değerinin altına satmak istiyor!',
          iconEmoji: 'expertise',
          amount: 35000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Fırsatı Kaçırma & Anında Satın Al • +35.000 ₺ Kâr', resultText: 'Kelepir araç anında bağlandı, galeri portföyüne katıldı!', balanceChange: 35000.0, reputationChange: 25, xpGain: 160),
            GameEventChoice(label: 'Sadece Ekspertiz Ücretini Al & Gönder • +3.500 ₺', resultText: 'Rutin ekspertiz hizmet geliri kasaya girdi.', balanceChange: 3500.0, reputationChange: 10, xpGain: 50),
          ],
        ),

        // --- MEVSİMSEL & EKONOMİK DALGALANMALAR ---
        GameEventModel(
          id: 'event_winter_blizzard_demand',
          title: 'Bölgesel Kar Fırtınası & 4x4 SUV Patlaması',
          description: 'Şehirde başlayan yoğun kar yağışı ve don olayları nedeniyle 4x4 SUV araçlara ve oto çekici kurtarma hizmetlerine talep patladı!',
          iconEmoji: 'flash',
          amount: 32000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Çekici Filosunu 24 Saat Sahaya Sür & Kârı Katla • +32.000 ₺', resultText: 'Gece gündüz kurtarma yapıldı, rekor çekici cirosu elde edildi!', balanceChange: 32000.0, reputationChange: 25, xpGain: 140),
            GameEventChoice(label: 'Galeride Sıcak Çayını İç', resultText: 'Fırtınanın geçmesini bekledin.', balanceChange: 0.0, reputationChange: 0, xpGain: 30),
          ],
        ),
        GameEventModel(
          id: 'event_holiday_rush_sedans',
          title: 'Bayram Öncesi Memleket Sezonu Hücumu',
          description: 'Kurban Bayramı tatili öncesi memlekete gidecek aileler geniş bagajlı sedan ve dizel araçlar için galeriye akın etti!',
          iconEmoji: 'car',
          amount: 40000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Bayram Kampanyası Başlat & Hızlı Satış Yap • +40.000 ₺', resultText: 'Stoktaki araçlar saatler içinde eridi, taze sermaye oluştu!', balanceChange: 40000.0, reputationChange: 30, xpGain: 150),
            GameEventChoice(label: 'Fiyatları Sabit Tut • +15.000 ₺', resultText: 'Rutin bayram satışları gerçekleşti.', balanceChange: 15000.0, reputationChange: 5, xpGain: 60),
          ],
        ),
        GameEventModel(
          id: 'event_interest_rate_hike_shock',
          title: 'Merkez Bankası Faiz Şoku & Senetli Satış Patlaması',
          description: 'Bankaların taşıt kredisi faizlerini artırmasıyla müşteriler galeri vadeli ve senetli satışlarına hücum etti!',
          iconEmoji: 'chart',
          amount: 26000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Senetli Satış Portföyünü Genişlet & Kârı Artır • +26.000 ₺', resultText: 'Vadeli sözleşmelerden yüksek komisyon ve faiz geliri bağlandı.', balanceChange: 26000.0, reputationChange: 20, xpGain: 130),
            GameEventChoice(label: 'Sadece Peşin Nakit Çalışmaya Devam Et', resultText: 'Nakit disiplinini korudun.', balanceChange: 0.0, reputationChange: 5, xpGain: 40),
          ],
        ),
        GameEventModel(
          id: 'event_impound_lot_auction',
          title: 'Yediemin Otoparkı İcra İhalesi Fırsatı',
          description: 'İcra dairesi yediemin otoparkında hacizli bekleyen lüks araçları toplu ihale ile piyasa değerinin altına satışa çıkardı!',
          iconEmoji: 'gavel',
          amount: -15000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'İhaleye Katıl & Dosya Masrafını Yatır • -15.000 ₺', resultText: 'İhaleden 2 adet kelepir araç kapıldı, büyük kâr sağlandı.', balanceChange: -15000.0, reputationChange: 20, xpGain: 140),
            GameEventChoice(label: 'İhaleyi Pas Geç & Risk Alma', resultText: 'İhaleye katılmadın, sermayeni korudun.', balanceChange: 0.0, reputationChange: 0, xpGain: 20),
          ],
        ),
        GameEventModel(
          id: 'event_night_drag_sponsorship',
          title: 'Gece İllegal Drag Yarışı Sponsorluk Teklifi',
          description: 'Şehrin hız tutkunları modifiyeli araçların kapışacağı gece yarışı için galerine sponsorluk teklif etti!',
          iconEmoji: 'flag',
          amount: -12000.0,
          type: GameEventType.meme,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Atölyeyi Yarış Takımına Aç & Sponsor Ol • -12.000 ₺', resultText: 'Modifiye ettiğin araç birinci geldi, galerinin şöhreti ve genç müşteri akını patladı!', balanceChange: -12000.0, reputationChange: 35, xpGain: 180),
            GameEventChoice(label: 'Yarış Teklifini Reddet & Kurumsal Çizgini Koru', resultText: 'İllegal yarıştan uzak durdun, kurumsal itibarını korudun.', balanceChange: 0.0, reputationChange: 10, xpGain: 30),
          ],
        ),
      ];

  /// Randomly pick an event
  static GameEventModel getRandomEvent() {
    final templates = allEventTemplates;
    return templates[_random.nextInt(templates.length)];
  }

  /// Context-aware event picker strictly gated by dealership ownership and features
  static GameEventModel? getFilteredRandomEvent(dynamic state) {
    var candidates = List<GameEventModel>.from(allEventTemplates);

    try {
      final ownedCars = state.ownedCars as List? ?? [];
      final hiredStaff = state.hiredStaff as List? ?? [];
      final seenIds = (state.seenRandomEventIds as List? ?? []).cast<String>();
      final sideBusinesses = (state.sideBusinesses as List?) ?? [];
      final unlockedBuildings = (state.unlockedBuildings as Set?) ?? {};
      final balance = (state.balance as num?)?.toDouble() ?? 0.0;

      bool hasBusiness(String typeName) {
        return sideBusinesses.any((b) {
          try {
            final isOwned = b.isOwned == true;
            final bType = b.type.toString();
            return isOwned && (bType == typeName || bType.endsWith(typeName) || bType.endsWith('.$typeName'));
          } catch (_) {
            return false;
          }
        });
      }

      bool isUnlocked(String route) {
        if (unlockedBuildings.contains(route)) return true;
        try {
          if (state.isFeatureUnlocked(route) == true) return true;
        } catch (_) {}
        if (route == '/scrapyard') {
          return unlockedBuildings.contains('property_tier_2') ||
              unlockedBuildings.contains('property_tier_3') ||
              unlockedBuildings.contains('property_tier_4') ||
              unlockedBuildings.contains('property_tier_5') ||
              unlockedBuildings.contains('property_tier_6') ||
              unlockedBuildings.contains('property_tier_7') ||
              unlockedBuildings.contains('property_tier_8');
        }
        if (route == '/workshop') {
          return unlockedBuildings.contains('property_tier_3') ||
              unlockedBuildings.contains('property_tier_4') ||
              unlockedBuildings.contains('property_tier_5') ||
              unlockedBuildings.contains('property_tier_6') ||
              unlockedBuildings.contains('property_tier_7') ||
              unlockedBuildings.contains('property_tier_8');
        }
        return true;
      }

      bool hasStaffRole(String roleName) {
        return hiredStaff.any((s) {
          try {
            final r = s.role.toString();
            return r == roleName || r.endsWith(roleName) || r.endsWith('.$roleName');
          } catch (_) {
            return false;
          }
        });
      }

      // 1. Garage Car Count Gating
      if (ownedCars.isEmpty) {
        candidates.removeWhere((e) =>
            e.id == 'event_paint_scratched' ||
            e.id == 'event_vandalism' ||
            e.id == 'event_showroom_light_shatter' ||
            e.id == 'event_hail_storm' ||
            e.id == 'event_vip_special_plate_request' ||
            e.id == 'event_night_shady_buyer' ||
            e.id == 'event_buyer_knowitall_uncle');
      }

      if (hiredStaff.isEmpty) {
        candidates.removeWhere((e) => e.id == 'event_cirak');
      }

      // Staff specific gating
      if (!hasStaffRole('masterMechanic')) {
        candidates.removeWhere((e) => e.id == 'event_master_mechanic_poached');
      }
      if (!hasStaffRole('apprentice')) {
        candidates.removeWhere((e) => e.id == 'event_apprentice_graduation_milestone');
      }

      // Capital gating for large auctions
      if (balance < 25000.0) {
        candidates.removeWhere((e) => e.id == 'event_impound_lot_auction');
      }

      // 2. Strict Side Business Ownership Gating
      if (!hasBusiness('vendingMachine')) {
        candidates.removeWhere((e) =>
            e.id == 'event_vending_coin_jam' ||
            e.id == 'event_vending_spoiled_milk' ||
            e.id == 'event_vending_artisan_roastery_deal' ||
            e.id == 'event_vending_energy_drink_exclusive');
      }

      if (!hasBusiness('carWash')) {
        candidates.removeWhere((e) =>
            e.id == 'event_wash_pump_explosion' ||
            e.id == 'event_wash_chemical_burn' ||
            e.id == 'event_wash_wedding_convoy_rush' ||
            e.id == 'event_wash_ceramic_bulk_contract' ||
            e.id == 'event_wash_foam_cannon_upgrade');
      }

      if (!hasBusiness('evCharging')) {
        candidates.removeWhere((e) =>
            e.id == 'event_ev_transformer_trip' ||
            e.id == 'event_ev_cable_ripoff' ||
            e.id == 'event_ev_solar_canopy_installation' ||
            e.id == 'event_ev_fleet_overnight_depot' ||
            e.id == 'event_ev_epdk_green_energy_rebate');
      }

      if (!hasBusiness('billboard')) {
        candidates.removeWhere((e) =>
            e.id == 'event_billboard_panel_short' ||
            e.id == 'event_billboard_wind_damage' ||
            e.id == 'event_billboard_politician_election_campaign' ||
            e.id == 'event_billboard_viral_3d_anamorphic');
      }

      if (!hasBusiness('wrapStudio')) {
        candidates.removeWhere((e) =>
            e.id == 'event_wrap_blade_scratch' ||
            e.id == 'event_wrap_bubble_peel' ||
            e.id == 'event_wrap_supercar_matte_chameleon' ||
            e.id == 'event_wrap_commercial_fleet_branding');
      }

      if (!hasBusiness('corporateExpertise') && !hasBusiness('inspectionStation')) {
        candidates.removeWhere((e) =>
            e.id == 'event_dyno_roller_jam' ||
            e.id == 'event_airbag_bypass_scandal' ||
            e.id == 'event_expertise_chassis_miss' ||
            e.id == 'event_expertise_customer_distress_sale' ||
            e.id == 'event_expertise_youtube_phenomenon_review' ||
            e.id == 'event_expertise_court_expert_assignment' ||
            e.id == 'event_expertise_airbag_redemption_award' ||
            e.id == 'event_inspection_commercial_fleet_audit' ||
            e.id == 'event_inspection_laser_alignment_upgrade');
      }

      if (!hasBusiness('sparePartsStore')) {
        candidates.removeWhere((e) =>
            e.id == 'event_spare_parts_tax_audit' ||
            e.id == 'event_spare_parts_water_damage' ||
            e.id == 'event_spare_parts_german_oem_distributorship' ||
            e.id == 'event_spare_parts_performance_exhaust_trend');
      }

      if (!hasBusiness('towTruck')) {
        candidates.removeWhere((e) =>
            e.id == 'event_tow_truck_cable_snap' ||
            e.id == 'event_tow_hydraulic_fail' ||
            e.id == 'event_tow_sports_club_bus_rescue' ||
            e.id == 'event_tow_insurance_annual_tender' ||
            e.id == 'event_winter_blizzard_demand' ||
            e.id == 'event_winter_blizzard_crisis');
      }

      if (!hasBusiness('carRental')) {
        candidates.removeWhere((e) =>
            e.id == 'event_rental_speeding_fines' ||
            e.id == 'event_rental_clutch_burn' ||
            e.id == 'event_rental_cinema_movie_production' ||
            e.id == 'event_rental_airport_vip_transfer_franchise' ||
            e.id == 'event_rental_movie_gala_premiere');
      }

      if (!hasBusiness('autoShop') && !isUnlocked('/workshop')) {
        candidates.removeWhere((e) =>
            e.id == 'event_autoshop_lift_leak' ||
            e.id == 'event_autoshop_oil_spill' ||
            e.id == 'event_autoshop_supercar_oil_service' ||
            e.id == 'event_autoshop_bulk_drum_oil_deal' ||
            e.id == 'event_holiday_rush_maintenance' ||
            e.id == 'event_night_drag_sponsorship');
      }

      // 3. Strict Scrapyard & Workshop Feature Gating
      final hasScrapyard = isUnlocked('/scrapyard');
      final hasWorkshop = isUnlocked('/workshop');

      if (!hasScrapyard) {
        candidates.removeWhere((e) =>
            e.id == 'event_scrap_press_breakdown' ||
            e.id == 'event_salvage_corrosion' ||
            e.id == 'event_b2b_defective_return' ||
            e.id == 'event_scrap_classic_chassis_treasure' ||
            e.id == 'event_scrap_classic_auction_climax');
      }

      if (!hasScrapyard && !hasWorkshop && !hasBusiness('autoShop')) {
        candidates.removeWhere((e) =>
            e.id == 'event_workshop_waste_fine' ||
            e.id == 'event_workshop_b2b_engine_rebuild_contract');
      }

      // Filter out last 6 seen events to avoid immediate repeats
      final recentSeen = seenIds.length > 6 ? seenIds.sublist(seenIds.length - 6) : seenIds;
      final unseen = candidates.where((e) => !recentSeen.contains(e.id)).toList();

      if (unseen.isNotEmpty) {
        return unseen[_random.nextInt(unseen.length)];
      }
    } catch (e) {
      debugPrint('RandomEventEngine error: $e');
    }

    if (candidates.isEmpty) return null;
    return candidates[_random.nextInt(candidates.length)];
  }
}
