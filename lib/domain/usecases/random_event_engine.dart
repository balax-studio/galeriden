import 'dart:math';
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
          title: 'Otomat Para Sıkıştırdı & Koltuk Lekesi',
          description: 'Bekleme salonundaki kahve otomatı sıkıştı ve taşan sıcak kahve deri müşteri koltuğunu lekeledi!',
          iconEmoji: 'coin',
          amount: -1800.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Teknik Servisi Çağır & Koltuğu Yıkat • -1.800 ₺', resultText: 'Koltuğu özel leke çıkarıcıyla sildirdin, otomat onarıldı.', balanceChange: -1800.0, reputationChange: 5, xpGain: 35),
            GameEventChoice(label: 'Otomatı Yumrukla Düzelt • -İtibar', resultText: 'Müşteriler bu agresif tavrı garipsedi.', balanceChange: 0.0, reputationChange: -10, xpGain: 15),
          ],
        ),
        GameEventModel(
          id: 'event_vending_spoiled_milk',
          title: 'Kahve Otomatı Süt Tozu Bozuldu',
          description: 'Hafta sonu sıcakta otomatın süt tozu ekşidi, VIP müşteriye servis edilen kapuçino skandal yarattı!',
          iconEmoji: 'coin',
          amount: -3200.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Tüm Hazneyi Yenile & Özür Paketi Ver • -3.200 ₺', resultText: 'Müşteriye hediye paketi verdin, kriz tatlıya bağlandı.', balanceChange: -3200.0, reputationChange: 15, xpGain: 50),
            GameEventChoice(label: 'Tedarikçiyi Suçla • -İtibar', resultText: 'Müşteri memnuniyetsiz ayrıldı.', balanceChange: 0.0, reputationChange: -20, xpGain: 20),
          ],
        ),

        // --- YAN İŞLETMELER: OTO YIKAMA & DETAYLANDIRMA RİSKLERİ ---
        GameEventModel(
          id: 'event_wash_pump_explosion',
          title: 'Oto Yıkama Basınç Pompası Patladı',
          description: 'Tazyikli su motorunun ana contası patladı, yıkama tüneli ve komşu dükkan su altında kaldı!',
          iconEmoji: 'wash',
          amount: -14000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'İtalyan Profesyonel Pompa Al • -14.000 ₺', resultText: 'Son teknoloji sessiz pompa takıldı, yıkama hızı arttı.', balanceChange: -14000.0, reputationChange: 10, xpGain: 80),
            GameEventChoice(label: 'Sanayide Kaynak Yaptır • -4.000 ₺', resultText: 'Geçici tamir yapıldı ama motor sesli çalışıyor.', balanceChange: -4000.0, reputationChange: -5, xpGain: 40),
          ],
        ),
        GameEventModel(
          id: 'event_wash_chemical_burn',
          title: 'Kostikli Köpük Krom Çıtaları Matlaştırdı',
          description: 'Yıkamacı çırağın yanlış oranladığı agresif şampuan, müşterinin lüks aracının krom ızgarasını lekeledi!',
          iconEmoji: 'wash',
          amount: -9500.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Krom Çıtaları Sıfırıyla Değiştir • -9.500 ₺', resultText: 'Orijinal parçayla değiştirildi, müşteri teşekkür etti.', balanceChange: -9500.0, reputationChange: 10, xpGain: 60),
            GameEventChoice(label: 'Pasta Cila İle Gizle • -1.500 ₺', resultText: 'Leke tam geçmedi, müşteri durumu fark edip içerledi.', balanceChange: -1500.0, reputationChange: -15, xpGain: 30),
          ],
        ),

        // --- YAN İŞLETMELER: ELEKTRİKLİ ARAÇ ŞARJ İSTASYONU RİSKLERİ ---
        GameEventModel(
          id: 'event_ev_transformer_trip',
          title: 'Şarj İstasyonu Ana Sigortası Yandı',
          description: 'İki elektrikli araç aynı anda 150 kW DC hızlı şarja bağlanınca istasyon ana panosu eridi!',
          iconEmoji: 'flash',
          amount: -16500.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Trifaze Sanayi Panosu Taktır • -16.500 ₺', resultText: 'Korumalı yüksek akım panosu kuruldu, kesintisiz şarj sağlandı.', balanceChange: -16500.0, reputationChange: 15, xpGain: 90),
            GameEventChoice(label: 'Geçici Kaçak Rölesi Bağla • -3.500 ₺', resultText: 'Düşük hızda şarj vermeye devam ediyor.', balanceChange: -3500.0, reputationChange: -10, xpGain: 40),
          ],
        ),
        GameEventModel(
          id: 'event_ev_cable_ripoff',
          title: 'Kablo Takılıyken Gaza Basan Sürücü',
          description: 'Dalgın bir sürücü Type-2 şarj soketini prizden çıkarmadan hareket etti, soket koptu!',
          iconEmoji: 'flash',
          amount: -12000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Orijinal Sıvı Soğutmalı Kablo Tak • -12.000 ₺', resultText: 'Yeni kablo monte edildi, istasyon yeniden açıldı.', balanceChange: -12000.0, reputationChange: 5, xpGain: 70),
            GameEventChoice(label: 'Kaskodan Masrafı İste • -2.000 ₺', resultText: 'Dosya masrafı ödendi, işlem takipte.', balanceChange: -2000.0, reputationChange: 0, xpGain: 90),
          ],
        ),

        // --- YAN İŞLETMELER: REKLAM PANOSU RİSKLERİ ---
        GameEventModel(
          id: 'event_billboard_panel_short',
          title: 'Fırtınada LED Reklam Panosu Yandı',
          description: 'Gece çıkan fırtınada cadde üstü dev ekran panosunun LED modülleri ıslandı ve piksel yanığı oluştu!',
          iconEmoji: 'star',
          amount: -7500.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Su Geçirmez LED Modül Tak • -7.500 ₺', resultText: 'Cam gibi net görüntüye kavuştu, ilanlar parlıyor.', balanceChange: -7500.0, reputationChange: 10, xpGain: 60),
            GameEventChoice(label: 'Bozuk Modülleri Sök • -1.500 ₺', resultText: 'Ekran boyutu küçüldü ama çalışıyor.', balanceChange: -1500.0, reputationChange: -5, xpGain: 30),
          ],
        ),

        // --- YAN İŞLETMELER: PPF KAPLAMA & CAM FİLMİ RİSKLERİ ---
        GameEventModel(
          id: 'event_wrap_blade_scratch',
          title: 'Kaplama Kesiminde Vernik Çizildi',
          description: 'Usta şeffaf PPF folyoyu keserken müşterinin spor otomobilinin çamurluk verniğini çizdi!',
          iconEmoji: 'vintage',
          amount: -11000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Lokal Düzeltme & Seramik Kaplama Hediye Et • -11.000 ₺', resultText: 'Müşteri memnun kaldı ve stüdyoya 5 yıldız verdi.', balanceChange: -11000.0, reputationChange: 15, xpGain: 80),
            GameEventChoice(label: 'Ekspertizde Vardı De • -İtibar', resultText: 'Müşteri internette şikayet yazdı.', balanceChange: 0.0, reputationChange: -30, xpGain: 10),
          ],
        ),

        // --- YAN İŞLETMELER: EKSPERTİZ & MUAYENE İSTASYONU RİSKLERİ ---
        GameEventModel(
          id: 'event_dyno_roller_jam',
          title: 'Dinamometre Tambur Rulmanı Kilitlendi',
          description: 'Beygir gücü ölçümü sırasında ekspertiz dyno tamburu sıkıştı, testteki aracın ön lastiği yarıldı!',
          iconEmoji: 'expertise',
          amount: -17500.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Makaraları Rulmanla Revize Et & Lastiği Karşıla • -17.500 ₺', resultText: 'Dyno kalibre edildi ve araç sahibine sıfır lastik takıldı.', balanceChange: -17500.0, reputationChange: 10, xpGain: 90),
            GameEventChoice(label: 'Çıkma Rulman Uydur • -5.000 ₺', resultText: 'Cihaz düşük devirde titriyor.', balanceChange: -5000.0, reputationChange: -10, xpGain: 40),
          ],
        ),
        GameEventModel(
          id: 'event_airbag_bypass_scandal',
          title: 'Ekspertizde Sahte Airbag Direnci Atlandı',
          description: 'Rapor verilen bir araçta emülatör dirençli patlak airbag varmış, alıcı noter ihtarı çekti!',
          iconEmoji: 'expertise',
          amount: -28000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Kusuru Kabul Et & Tazminatı Öde • -28.000 ₺', resultText: 'Dürüst kurumsal duruş sayesinde galeri itibarını korudun.', balanceChange: -28000.0, reputationChange: 10, xpGain: 120),
            GameEventChoice(label: 'Mahkemeye Git • -10.000 ₺', resultText: 'Dava süreci başladı, esnaf arasında dedikodu yayıldı.', balanceChange: -10000.0, reputationChange: -25, xpGain: 50),
          ],
        ),

        // --- YAN İŞLETMELER: YEDEK PARÇA MAĞAZASI RİSKLERİ ---
        GameEventModel(
          id: 'event_spare_parts_tax_audit',
          title: 'Yedek Parça Mağazasına Maliye Baskını',
          description: 'Maliye müfettişleri raflardaki faturasız şanzıman ve motor beyinlerini mühürledi!',
          iconEmoji: 'turbo',
          amount: -24000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Gecikme Zammını Öde & Stokları Resmileştir • -24.000 ₺', resultText: 'Tüm stoklar faturalandırıldı, ceza kalktı.', balanceChange: -24000.0, reputationChange: 15, xpGain: 110),
            GameEventChoice(label: 'Uzlaşma Komisyonuna Git • -11.000 ₺', resultText: 'Ceza indirildi ama defter incelemesi sürüyor.', balanceChange: -11000.0, reputationChange: -10, xpGain: 60),
          ],
        ),

        // --- YAN İŞLETMELER: OTO ÇEKİCİ RİSKLERİ ---
        GameEventModel(
          id: 'event_tow_truck_cable_snap',
          title: 'Oto Çekici Çelik Halatı Koptu',
          description: 'Otobanda arızalı aracı çekerken çekicinin çelik sapanı koptu ve araç tamponu asfalta çarptı!',
          iconEmoji: 'workshop',
          amount: -13500.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Sentetik Ağır Hizmet Halatı Al & Tamponu Onar • -13.500 ₺', resultText: 'Kopmaz sentetik halat takıldı ve tampon düzeltildi.', balanceChange: -13500.0, reputationChange: 10, xpGain: 80),
            GameEventChoice(label: 'Kendi Tamirhanende Macunla • -3.500 ₺', resultText: 'Ucuza kurtarıldı ama müşteri memnun kalmadı.', balanceChange: -3500.0, reputationChange: -15, xpGain: 35),
          ],
        ),

        // --- YAN İŞLETMELER: ARAÇ KİRALAMA & FİLO RİSKLERİ ---
        GameEventModel(
          id: 'event_rental_speeding_fines',
          title: 'Kiralık Araç Radar & Hız Cezası Yağmuru',
          description: 'Hafta sonu kiralanan spor araçla hız koridoruna girilmiş, 14 adet radar ve kaçak geçiş cezası tebliğ edildi!',
          iconEmoji: 'car',
          amount: -12000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Cezaları Erken Öde • İndirimli: -12.000 ₺', resultText: 'Cezalar ödendi ve kiralayan şahsın depozitosuna el konuldu.', balanceChange: -12000.0, reputationChange: 5, xpGain: 75),
            GameEventChoice(label: 'Sürücüyü İcraya Ver • Avukat Masrafı: -4.000 ₺', resultText: 'İcra takibi başlatıldı, tahsilat bekleniyor.', balanceChange: -4000.0, reputationChange: -5, xpGain: 50),
          ],
        ),

        // --- YAN İŞLETMELER: MEKANİK SERVİS & ATÖLYE RİSKLERİ ---
        GameEventModel(
          id: 'event_autoshop_lift_leak',
          title: 'Mekanik Servis 4 Tonluk Lift Yağ Kaçırdı',
          description: 'Servis liftinin hidrolik keçesi patladı, havada asılı ağır SUV araç aşağı kaymaya başladı!',
          iconEmoji: 'workshop',
          amount: -19000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'TSE Onaylı Yeni Nesil Lift Kur • -19.000 ₺', resultText: 'Çift emniyet kilitli lift kuruldu, atölye güvenliği tavan yaptı.', balanceChange: -19000.0, reputationChange: 20, xpGain: 100),
            GameEventChoice(label: 'Sanayide Keçe Çaktır • -4.500 ₺', resultText: 'Geçici olarak sızdırmazlık sağlandı.', balanceChange: -4500.0, reputationChange: -10, xpGain: 40),
          ],
        ),

        // --- HURDALIK & SÖKÜM TESİSİ RİSKLERİ ---
        GameEventModel(
          id: 'event_scrap_press_breakdown',
          title: 'Hurdalık Pres Pistonu Çatladı',
          description: '80 tonluk hurda presinin ana hidrolik pistonu çatladı, araç gövdesi presleme işlemi tamamen durdu!',
          iconEmoji: 'craftsman',
          amount: -18000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Orijinal Ağır Sanayi Pistonu Tak • -18.000 ₺', resultText: 'Pres makinesi ilk günkü gücüne kavuştu.', balanceChange: -18000.0, reputationChange: 10, xpGain: 90),
            GameEventChoice(label: 'Hurda Şasiden Piston Uydur • -6.000 ₺', resultText: 'Pres yavaş çalışıyor ama iş görüyor.', balanceChange: -6000.0, reputationChange: -10, xpGain: 50),
          ],
        ),
        GameEventModel(
          id: 'event_salvage_corrosion',
          title: 'Yedek Parça Deposu Su Bastı',
          description: 'Şiddetli yağmurda açık sundurma çöktü, depodaki sağlam çıkma motor blokları ve şanzımanlar ıslandı!',
          iconEmoji: 'craftsman',
          amount: -8500.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Endüstriyel Nem Alma & Koruyucu Yağlama • -8.500 ₺', resultText: 'Tüm parçalar yağlandı ve depoya kapalı çatı yapıldı.', balanceChange: -8500.0, reputationChange: 10, xpGain: 60),
            GameEventChoice(label: 'Tel Fırçayla Pas Kazı • -2.000 ₺', resultText: 'Parçaların kozmetiği biraz bozuldu.', balanceChange: -2000.0, reputationChange: -10, xpGain: 30),
          ],
        ),
        GameEventModel(
          id: 'event_b2b_defective_return',
          title: 'Sanayiye Satılan B2B Turbo Kusurlu Çıktı',
          description: 'Sanayideki özel servise gönderilen revizyonlu turbo yağ bastı, servis sahibi galeriyi mahkemeye vermekle tehdit etti!',
          iconEmoji: 'craftsman',
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
          title: 'Çevre Bakanlığı Atık Yağ Denetim Cezası',
          description: 'Çevre ve Şehircilik müfettişleri atık yağ ve akü depolama standartlarını denetleyip ceza yazdı!',
          iconEmoji: 'workshop',
          amount: -15000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Lisanslı Geri Dönüşüm Tankı Kur • -15.000 ₺', resultText: 'Çevre dostu yeşil işletme sertifikası aldın.', balanceChange: -15000.0, reputationChange: 25, xpGain: 100),
            GameEventChoice(label: 'Cezayı Öde & Geç • -7.500 ₺', resultText: 'Ceza ödendi ama denetimler devam edecek.', balanceChange: -7500.0, reputationChange: 0, xpGain: 40),
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

        // --- YERALTI & GECE PAZARI / İHALE OLAYLARI ---
        GameEventModel(
          id: 'event_impound_lot_auction',
          title: 'Polis Yediemin Otoparkı Terk Edilmiş Araç İhalesi',
          description: 'Emniyet otoparkında hacizden ve gümrükten kalan sahipsiz araçlar kapalı zarf usulü toplu ihaleye çıktı!',
          iconEmoji: 'auction',
          amount: 30000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Kör Paket İhaleye Gir • +30.000 ₺ Net Kâr', resultText: 'İhaleden çıkan klasik ve hurda parçalar yüksek kârla değerlendirildi.', balanceChange: 30000.0, reputationChange: 25, xpGain: 170),
            GameEventChoice(label: 'İhaleyi Pas Geç & Risk Alma', resultText: 'Sermayeni korudun.', balanceChange: 0.0, reputationChange: 0, xpGain: 20),
          ],
        ),
        GameEventModel(
          id: 'event_night_drag_sponsorship',
          title: 'Gece Drag & Roll Yarışı Sponsorluk Teklifi',
          description: 'Sanayi gençleri tuning atölyende hazırlanan canavarı gece çevre yolu drag yarışına sokup galeri adına yarışmak istiyor!',
          iconEmoji: 'turbo',
          amount: 38000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Yarışa Sponsor Ol & Pilotu Destekle • +38.000 ₺', resultText: 'Aracın geceyi birinci bitirdi, galeri logosu tüm gençlik sayfalarında paylaşıldı!', balanceChange: 38000.0, reputationChange: 40, xpGain: 180),
            GameEventChoice(label: 'Yasa Dışı Sokak Yarışına Bulaşma • +İtibar', resultText: 'Kurumsal ciddiyetini korudun, takdir topladın.', balanceChange: 0.0, reputationChange: 15, xpGain: 50),
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
        return false;
      }

      bool hasStaffRole(String roleStr) {
        return hiredStaff.any((s) {
          try {
            return s.role.toString().contains(roleStr);
          } catch (_) {
            return false;
          }
        });
      }

      // 1. General vehicle & staff prerequisites
      if (ownedCars.isEmpty) {
        candidates.removeWhere((e) =>
            e.id == 'event_sel' ||
            e.id == 'event_marti' ||
            e.id == 'event_kedi' ||
            e.id == 'event_olucu_usta' ||
            e.id == 'event_hayalet_tofas' ||
            e.id == 'event_sanayi_broker_deal' ||
            e.id == 'event_holiday_rush_sedans' ||
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
            e.id == 'event_vending_spoiled_milk');
      }

      if (!hasBusiness('carWash')) {
        candidates.removeWhere((e) =>
            e.id == 'event_wash_pump_explosion' ||
            e.id == 'event_wash_chemical_burn');
      }

      if (!hasBusiness('evCharging')) {
        candidates.removeWhere((e) =>
            e.id == 'event_ev_transformer_trip' ||
            e.id == 'event_ev_cable_ripoff');
      }

      if (!hasBusiness('billboard')) {
        candidates.removeWhere((e) => e.id == 'event_billboard_panel_short');
      }

      if (!hasBusiness('wrapStudio')) {
        candidates.removeWhere((e) => e.id == 'event_wrap_blade_scratch');
      }

      if (!hasBusiness('corporateExpertise') && !hasBusiness('inspectionStation')) {
        candidates.removeWhere((e) =>
            e.id == 'event_dyno_roller_jam' ||
            e.id == 'event_airbag_bypass_scandal' ||
            e.id == 'event_expertise_customer_distress_sale');
      }

      if (!hasBusiness('sparePartsStore')) {
        candidates.removeWhere((e) => e.id == 'event_spare_parts_tax_audit');
      }

      if (!hasBusiness('towTruck')) {
        candidates.removeWhere((e) =>
            e.id == 'event_tow_truck_cable_snap' ||
            e.id == 'event_winter_blizzard_demand');
      }

      if (!hasBusiness('carRental')) {
        candidates.removeWhere((e) => e.id == 'event_rental_speeding_fines');
      }

      if (!hasBusiness('autoShop') && !isUnlocked('/workshop')) {
        candidates.removeWhere((e) =>
            e.id == 'event_autoshop_lift_leak' ||
            e.id == 'event_night_drag_sponsorship');
      }

      // 3. Strict Scrapyard & Workshop Feature Gating
      final hasScrapyard = isUnlocked('/scrapyard');
      final hasWorkshop = isUnlocked('/workshop');

      if (!hasScrapyard) {
        candidates.removeWhere((e) =>
            e.id == 'event_scrap_press_breakdown' ||
            e.id == 'event_salvage_corrosion' ||
            e.id == 'event_b2b_defective_return');
      }

      if (!hasScrapyard && !hasWorkshop && !hasBusiness('autoShop')) {
        candidates.removeWhere((e) => e.id == 'event_workshop_waste_fine');
      }

      // Filter out last 6 seen events to avoid immediate repeats
      final recentSeen = seenIds.length > 6 ? seenIds.sublist(seenIds.length - 6) : seenIds;
      final unseen = candidates.where((e) => !recentSeen.contains(e.id)).toList();

      if (unseen.isNotEmpty) {
        return unseen[_random.nextInt(unseen.length)];
      }
    } catch (e) {
      // ignore: avoid_print
      print('RandomEventEngine error: $e');
    }

    if (candidates.isEmpty) return null;
    return candidates[_random.nextInt(candidates.length)];
  }
}
