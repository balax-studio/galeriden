import 'dart:math';
import '../../data/models/game_event_model.dart';

class RandomEventEngine {
  static final Random _random = Random();

  /// Comprehensive Database of 20 Turkish Automotive & Meme Random Events
  static List<GameEventModel> get allEventTemplates => [
        // --- KÖTÜ OLAYLAR ---
        GameEventModel(
          id: 'event_belediye',
          title: 'Zabıta & Belediye Denetimi',
          description: 'Ruhsat ve kaldırım işgali denetimine gelen zabıtalar ceza kesti!',
          iconEmoji: 'siren',
          amount: -5000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Cezayı Öde (-5.000 ₺)', resultText: 'Ceza makbuzunu ödedin, itibarın korundu.', balanceChange: -5000.0, reputationChange: 5, xpGain: 30),
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
            GameEventChoice(label: 'Detaylı Temizlik Yaptır (-8.000 ₺)', resultText: 'Tüm araçlar pırıl pırıl temizlendi.', balanceChange: -8000.0, reputationChange: 10, xpGain: 60),
            GameEventChoice(label: 'Kendi İmkanlarınla Yıka', resultText: 'Yorucu oldu ama az masrafla atlattın.', balanceChange: -2000.0, reputationChange: -5, xpGain: 40),
          ],
        ),
        GameEventModel(
          id: 'event_kedi',
          title: 'Mahallenin Kedileri Kaputta!',
          description: 'Sıcak kaputların üstüne 8 tane sokak kedisi kuruldu. Müşteriler içeri girmeye çekiniyor.',
          iconEmoji: 'cat',
          amount: 0.0,
          type: GameEventType.meme,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Mama Al & Sev (+İtibar, -500 ₺)', resultText: 'Kedisever müşteriler galeriye akın etti!', balanceChange: -500.0, reputationChange: 15, xpGain: 50),
            GameEventChoice(label: 'Pışt De & Kov (-İtibar)', resultText: 'Mahalleli bu duruma biraz içerledi.', balanceChange: 0.0, reputationChange: -15, xpGain: 10),
          ],
        ),
        GameEventModel(
          id: 'event_cirak',
          title: 'Çırağın Boya Kazası',
          description: 'Yeni işe başlayan çırak Emre, müşterinin siyah Bavyera Makasçısı\'nı yanlışlıkla kırmızı astara sürttü!',
          iconEmoji: 'wrench',
          amount: -12000.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Hemen Fırın Boyaya Al (-12.000 ₺)', resultText: 'Kusursuz boyandı, müşteri fark etmedi bile.', balanceChange: -12000.0, reputationChange: 5, xpGain: 80),
            GameEventChoice(label: 'Pasta Cila ile Kurtar (-3.000 ₺)', resultText: 'Belli belirsiz oldu ama ucuz kurtardın.', balanceChange: -3000.0, reputationChange: -10, xpGain: 40),
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
            GameEventChoice(label: 'Muhasebeciyle Çöz (-15.000 ₺)', resultText: 'Tüm evraklar düzenlendi, sorun kalmadı.', balanceChange: -15000.0, reputationChange: 10, xpGain: 100),
          ],
        ),
        GameEventModel(
          id: 'event_yol_coktu',
          title: 'Galerinin Önündeki Yol Çöktü!',
          description: 'Belediye altyapı çalışması yüzünden 2 gün boyunca galerinin kapısına araç giremedi.',
          iconEmoji: 'pothole',
          amount: 0.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Online İlanlara Ağırlık Ver (+XP)', resultText: 'İnternet satışlarıyla açığı kapattın!', balanceChange: 5000.0, reputationChange: 5, xpGain: 120),
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
            GameEventChoice(label: 'Hızlıca Yıkat (-2.500 ₺)', resultText: 'Boya yanmadan hemen temizlendi.', balanceChange: -2500.0, reputationChange: 5, xpGain: 30),
            GameEventChoice(label: 'Kuş Yemiyle Uzaklaştır (-200 ₺)', resultText: 'Martılar komşu oto yıkamaya doğru uçtu!', balanceChange: -200.0, reputationChange: 5, xpGain: 60),
          ],
        ),
        GameEventModel(
          id: 'event_viral_kotu',
          title: 'Sosyal Medyada Viral Kötü Yorum',
          description: 'Pazarlıkta anlaşamadığın bir müşteri TikTok\'ta abartılı bir şikayet videosu çekti!',
          iconEmoji: 'phone',
          amount: 0.0,
          type: GameEventType.badEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Samimi Açıklama Videosu Çek (+İtibar)', resultText: 'Dürüst tavrın sayesinde takipçin 2 katına çıktı!', balanceChange: 0.0, reputationChange: 25, xpGain: 100),
            GameEventChoice(label: 'Yorumları Kapat & Görmezden Gel', resultText: 'Olay birkaç güne unutuldu ama itibar zedelendi.', balanceChange: 0.0, reputationChange: -15, xpGain: 10),
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
            GameEventChoice(label: 'Programda Röportaj Ver (+20.000 ₺, +İtibar)', resultText: 'Milyonlar izledi, dükkana telefon yağdı!', balanceChange: 20000.0, reputationChange: 40, xpGain: 150),
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
            GameEventChoice(label: 'Sermayeye Ekle (+35.000 ₺)', resultText: 'Kasan bayram etti!', balanceChange: 35000.0, reputationChange: 5, xpGain: 80),
          ],
        ),
        GameEventModel(
          id: 'event_odul',
          title: 'Bölgenin En Güvenilir Galerisi Ödülü',
          description: 'Otomotiv Esnaf Odası tarafından "Yılın En Şeffaf Ekspertizli Galerisi" seçildin!',
          iconEmoji: 'trophy',
          amount: 10000.0,
          type: GameEventType.goodEvent,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Ödülü Vitrine As (+60 İtibar)', resultText: 'Müşteriler artık gözü kapalı araç alıyor!', balanceChange: 10000.0, reputationChange: 60, xpGain: 200),
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
            GameEventChoice(label: 'Selfie Çekil & Paylaş (+40 İtibar, +Bahşiş)', resultText: 'Futbolcu aracı beğendi ve galeriye prim kazandırdı!', balanceChange: 25000.0, reputationChange: 40, xpGain: 150),
          ],
        ),

        // --- KOMİK & MEME OLAYLAR ---
        GameEventModel(
          id: 'event_olucu_usta',
          title: 'Pazarlık Şampiyonu Ölücü Alıcı',
          description: 'Bir müşteri 650.000 ₺\'lik Das Aşiret Vagonu için 35.000 ₺ nakit ve 2 çuval fındık teklif etti!',
          iconEmoji: 'clown',
          amount: 0.0,
          type: GameEventType.meme,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Nazikçe "Allah Razı Olsun" De (+İtibar)', resultText: 'Mizah anlayışın dükkanda neşe yarattı.', balanceChange: 0.0, reputationChange: 10, xpGain: 50),
            GameEventChoice(label: 'Dükkandan Kov', resultText: 'Adam kapıdan homurdanarak çıktı gitti.', balanceChange: 0.0, reputationChange: -5, xpGain: 20),
          ],
        ),
        GameEventModel(
          id: 'event_kopek_karabas',
          title: 'Nöbetçi Köpek "Karabaş"',
          description: 'Sanayiden gelen sevimli bir köpek galerinin kapısını mesken tuttu. Geceleri bekçilik yapıyor!',
          iconEmoji: 'dog',
          amount: 0.0,
          type: GameEventType.meme,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Kulübe Yap & Besle (-1.000 ₺, +İtibar)', resultText: 'Karabaş galerinin resmi maskotu oldu!', balanceChange: -1000.0, reputationChange: 30, xpGain: 80),
            GameEventChoice(label: 'Barınağa Bildir', resultText: 'Güvenli şekilde barınağa teslim edildi.', balanceChange: 0.0, reputationChange: 5, xpGain: 30),
          ],
        ),
        GameEventModel(
          id: 'event_hayalet_tofas',
          title: 'Gece Çalışan Hayalet Murat 124!',
          description: 'Gece bekçisi dededen kalan Murat 124\'ün farlarının kendi kendine yandığını iddia ediyor!',
          iconEmoji: 'ghost',
          amount: 0.0,
          type: GameEventType.meme,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Akü Kutup Başını Kontrol Et (+XP)', resultText: 'Meğer şase kablosu gevşemiş! Tamir ettin.', balanceChange: 0.0, reputationChange: 5, xpGain: 100),
            GameEventChoice(label: 'Medyumlara Haber Ver (-2.000 ₺)', resultText: 'Mahalleli gece galerinin önüne toplanıp dua etti.', balanceChange: -2000.0, reputationChange: 15, xpGain: 50),
          ],
        ),
        GameEventModel(
          id: 'event_sanayi_tostu',
          title: 'Sanayi Tostçusu Erol Usta\'dan Ziyafet',
          description: 'Meşhur sanayi tostçusu Erol Usta galeri personeline 10 adet karışık atom tost ısmarladı!',
          iconEmoji: 'sandwich',
          amount: 0.0,
          type: GameEventType.meme,
          date: DateTime.now(),
          choices: [
            GameEventChoice(label: 'Afiyetle Ye & Moral Depola (+XP)', resultText: 'Tüm ekibin çalışma hızı ikiye katlandı!', balanceChange: 0.0, reputationChange: 10, xpGain: 90),
          ],
        ),
      ];

  /// Randomly pick an event
  static GameEventModel getRandomEvent() {
    final templates = allEventTemplates;
    return templates[_random.nextInt(templates.length)];
  }

  /// Context-aware event picker based on current dealership state
  static GameEventModel? getFilteredRandomEvent(dynamic state) {
    var candidates = List<GameEventModel>.from(allEventTemplates);

    try {
      final ownedCars = state.ownedCars as List? ?? [];
      final hiredStaff = state.hiredStaff as List? ?? [];
      final seenIds = (state.seenRandomEventIds as List? ?? []).cast<String>();

      if (ownedCars.isEmpty) {
        candidates.removeWhere((e) =>
            e.id == 'event_sel' ||
            e.id == 'event_marti' ||
            e.id == 'event_kedi' ||
            e.id == 'event_olucu_usta' ||
            e.id == 'event_hayalet_tofas');
      }

      if (hiredStaff.isEmpty) {
        candidates.removeWhere((e) => e.id == 'event_cirak');
      }

      // Filter out last 6 seen events to avoid repeats
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
