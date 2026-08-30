import 'dart:math';
import '../../data/models/customer_model.dart';
import '../../data/models/offer_model.dart';

class NegotiationSuspenseEngine {
  static final Random _random = Random();

  /// Generates a 3-stage dynamic thinking suspense script for Buying (when player makes offer to car seller)
  static List<String> getBuyingSuspenseStages({
    required CustomerArchetype archetype,
    Random? rng,
  }) {
    final r = rng ?? _random;
    final stage1List = _buyingStage1Pool[archetype] ?? _buyingStage1Pool[CustomerArchetype.skepticalOfficial]!;
    final stage2List = _buyingStage2Pool[archetype] ?? _buyingStage2Pool[CustomerArchetype.skepticalOfficial]!;
    final stage3List = _buyingStage3Pool[archetype] ?? _buyingStage3Pool[CustomerArchetype.skepticalOfficial]!;

    return [
      stage1List[r.nextInt(stage1List.length)],
      stage2List[r.nextInt(stage2List.length)],
      stage3List[r.nextInt(stage3List.length)],
    ];
  }

  /// Generates a 3-stage dynamic thinking suspense script for Selling (when showroom buyer evaluates player counter-offer)
  static List<String> getSellingSuspenseStages({
    required CustomerArchetype archetype,
    OfferType? offerType,
    Random? rng,
  }) {
    final r = rng ?? _random;
    final stage1List = _sellingStage1Pool[archetype] ?? _sellingStage1Pool[CustomerArchetype.skepticalOfficial]!;
    final stage2List = _sellingStage2Pool[archetype] ?? _sellingStage2Pool[CustomerArchetype.skepticalOfficial]!;
    final stage3List = _sellingStage3Pool[archetype] ?? _sellingStage3Pool[CustomerArchetype.skepticalOfficial]!;

    return [
      stage1List[r.nextInt(stage1List.length)],
      stage2List[r.nextInt(stage2List.length)],
      stage3List[r.nextInt(stage3List.length)],
    ];
  }

  /// Calculates thrilling, randomized suspense durations for each stage (Total: 2.6s - 4.4s)
  static List<int> generateRandomStageDurations({Random? rng}) {
    final r = rng ?? _random;
    return [
      800 + r.nextInt(500),  // Stage 1: 800ms - 1300ms (Initial reaction)
      1000 + r.nextInt(700), // Stage 2: 1000ms - 1700ms (Deep internal calculation)
      800 + r.nextInt(600),  // Stage 3: 800ms - 1400ms (Final hesitation & verdict)
    ];
  }

  // ==========================================
  // BUYING SUSPENSE POOLS (Player buys from seller)
  // ==========================================

  static const Map<CustomerArchetype, List<String>> _buyingStage1Pool = {
    CustomerArchetype.skepticalOfficial: [
      'Satıcı teklif rakamına bakıyor • Hesap makinesine sarıldı...',
      'Satıcı gözlüğünü düzeltti • Teklif rakamını dikkatle inceliyor...',
      'Satıcı servis faturalarını açtı • Yaptığı masrafları tek tek sayıyor...',
      'Satıcı ilandaki açıklamalarını gözden geçiriyor • Tereddütle başını kaldırdı...',
      'Ekspertiz raporundaki mikron boya kalınlıklarını büyüteçle kontrol ediyor...',
      'Ruhsattaki ilk tescil tarihini ve muayene kaşelerini dikkatle süzüyor...',
      'TSE onaylı servis belgelerine bakarak kafasında maliyet analizi çıkarıyor...',
      'Emeklilik ikramiyesinden araca bağladığı paranın muhasebesini yapıyor...',
    ],
    CustomerArchetype.impatientYouth: [
      'Satıcı telefondaki bildirimine baktı • Fiyatı tartıyor...',
      'Satıcı sosyal medyada yeni alacağı arabanın fotoğraflarına bakıyor...',
      'Anahtarı parmağında çevirerek teklif rakamını hızla süzüyor...',
      'Teklifi görünce arkadaşına mesaj yazmaya başladı...',
      'Yeni arabaya taktıracağı egzoz ve coilover sistemini hayal ediyor...',
      'Cebindeki son kredi kartı limitini kontrol edip heyecanla süzüyor...',
      'Sanayideki modifiye ustasına WhatsApp üzerinden fotoğraf atıyor...',
      'Bu parayla hafta sonu gazlayıp gazlayamayacağını hesaplıyor...',
    ],
    CustomerArchetype.greedyFlipper: [
      'Satıcı kâr marjını hesaplıyor • Çayından bir yudum aldı...',
      'Cebindeki altın ve döviz kurunu kontrol edip teklifi süzüyor...',
      'Maliyeti kurtarıp kurtarmadığını zihninde hızla çeviriyor...',
      'Tespihini çekerek teklif rakamını dudak bükerek inceliyor...',
      'Galericiler sitesindeki komşu esnafa uzaktan göz kırptı...',
      'Arabanın kaporta boyasızlık payını kafasında altına çeviriyor...',
      'İlan sitelerindeki fiyat grafiğini ve favoriye ekleyenleri kontrol ediyor...',
      'Dükkandaki nakit döngüsünü ve haftalık ciro hedefini gözden geçiriyor...',
    ],
    CustomerArchetype.familyMan: [
      'Satıcı bütçesini gözden geçiriyor • Derin bir nefes aldı...',
      'Bagaj hacmini ve çocukların masraflarını düşünüyor...',
      'Kredi kartı ekstrelerini ve ev bütçesini kafasında topluyor...',
      'Arabanın aileye kattığı anıları hatırlayıp hüzünlendi...',
      'Okul taksitlerini ve yaklaşan kış masraflarını kafasında tartıyor...',
      'Eşinin bu fiyata ne tepki vereceğini düşünüp yutkundu...',
      'Yıllardır gözü gibi baktığı koltuk döşemelerini süzüyor...',
      'Ailenin ilk arabasıyla yapılan memleket yolculuklarını hatırladı...',
    ],
  };

  static const Map<CustomerArchetype, List<String>> _buyingStage2Pool = {
    CustomerArchetype.skepticalOfficial: [
      'Emsal ilanları kontrol ediyor • Noter ve vergi harcını düşüyor...',
      'TÜVTÜRK muayene tarihini ve kasko bedelini sistemden teyit ediyor...',
      'Yetkili servisteki tanıdığı baş ustayı arayıp piyasa değerini danışıyor...',
      'Aracın bakım geçmişini düşünüp eline kalacak net tutarı hesaplıyor...',
      'Bankadaki vadeli mevduat getirisini ve faiz kayıplarını hesaplıyor...',
      'Memur emeklisi arkadaşına SMS atıp emsal satış fiyatlarını soruyor...',
      'Noter devir harcı ve plaka masraflarını düşüp net kârını hesaplıyor...',
      'Kafasında satır satır gelir gider tablosu oluşturup teklifi tartıyor...',
    ],
    CustomerArchetype.impatientYouth: [
      'Arkadaşına WhatsApp sesli mesaj attı • Aceleyle düşünüyor...',
      'Yeni alacağı jant ve ses sisteminin bütçesini hesaplıyor...',
      'Kapora vereceği diğer satıcıya yazıp süre istiyor...',
      'Hemen satıp yeni maceraya atılmanın heyecanını yaşıyor...',
      'Oto sanayi grubuna teklif ekranının ekran görüntüsünü gönderdi...',
      'Babasına çaktırmadan bu fiyata el sıkışıp sıkışamayacağını tartıyor...',
      'Akşamki buluşmaya yeni arabayla gitme planı yapıyor...',
      'Kafasında motor sesini ve vites geçişlerini canlandırıyor...',
    ],
    CustomerArchetype.greedyFlipper: [
      'Piyasa rayicini tartıyor • Net eline kalacak nakit parayı hesaplıyor...',
      'Sanayideki ortak esnaf arkadaşına göz işareti yaptı...',
      'Bu parayla yeni araba bağlayıp bağlayamayacağını düşünüyor...',
      'Kendi dükkanının aylık çevirme hızını ve nakit akışını tartıyor...',
      'Alttan alıp üstten satma marjını son kuruşuna kadar ölçüyor...',
      'Piyasadaki araç kıtlığını ve enflasyon beklentisini masaya yatırıyor...',
      'Komşu galericiyi gizlice arayıp arabanın giderini teyit ediyor...',
      'Parayı faize mi yoksa yeni partiye mi bağlasam diye tartıyor...',
    ],
    CustomerArchetype.familyMan: [
      'Eşiyle telefonda fısıldaşıyor • Evden onay bekliyor...',
      'Kurban bayramı ve tatil planı masraflarını hesaplıyor...',
      'Kayınpederine mesaj atıp fiyata onay verip vermediğini soruyor...',
      'Yeni alacakları geniş aile arabasının peşinatını düşünüyor...',
      'Aracın stepnesine ve yedek anahtarına kadar helallik düşünüyor...',
      'Evin mutfak masrafını kısmadan bu farkı kurtarmayı planlıyor...',
      'Çocukların güvenliği için daha yeni modele geçiş bütçesini kuruyor...',
      'Göz ucuyla arabanın bebek koltuğu bağlantılarını kontrol ediyor...',
    ],
  };

  static const Map<CustomerArchetype, List<String>> _buyingStage3Pool = {
    CustomerArchetype.skepticalOfficial: [
      'Kaşlarını çattı • Son kararını vermek üzere masaya eğildi...',
      'Evrak dosyasını yavaşça kapattı • Masadaki son tavrını belirliyor...',
      'Derin bir nefes alıp gözlüğünü masaya bıraktı • Kararını açıklıyor...',
      'Ciddi bir ifadeyle elini uzatmaya hazırlanıyor...',
      'Çantasından dolma kalemini çıkardı • Masadaki son sözünü söylüyor...',
      'Yüzünde tavizsiz bir ifade belirdi • Sonuca varıyor...',
      'Ciddiyetle boğazını temizledi • Kararını masaya bırakıyor...',
    ],
    CustomerArchetype.impatientYouth: [
      'Kafasını salladı • Kararını heyecanla açıklıyor...',
      'Telefonunu cebine attı • Hızlıca el sıkışmak için doğruldu...',
      'Gözleri parladı • Masadaki son sözünü söylüyor...',
      'Sabırsızca yerinde kıpırdandı • Sonuca varıyor...',
      'Araba anahtarını masaya vurup son kararını veriyor...',
      'Yüzünde kocaman bir tebessüm belirdi • Hamlesini yapıyor...',
      'Hadi hayırlısı diyerek ayağa fırlamaya hazırlanıyor...',
    ],
    CustomerArchetype.greedyFlipper: [
      'Gözlerini kıstı • Elini sertçe masaya koydu...',
      'Tespihini cebine koydu • Son kozunu oynamak üzere doğruldu...',
      'Bıyığını sıvazladı • Masadaki son esnaf kararını açıklıyor...',
      'Gülümseyerek arkasına yaslandı • Kararını masaya bırakıyor...',
      'Çay bardağını masaya sertçe bıraktı • Son sözü söylüyor...',
      'Bizde esnaflık ölmüş mü görelim diyerek dikleşti...',
      'Masada son pazarlık raconunu kesmek üzere elini uzatıyor...',
    ],
    CustomerArchetype.familyMan: [
      'Tereddütle masaya eğildi • Son sözünü söylüyor...',
      'Çocukların geleceğini düşünüp tereddütle başını salladı...',
      'Gözlerini yumup son kez aile bütçesini tarttı • Kararını veriyor...',
      'Helalleşmek üzere elini uzatmaya hazırlanıyor...',
      'Hayırlı bir işe vesile olsun diyerek derin bir nefes alıyor...',
      'Eşiyle göz göze gelip başıyla onay veriyor...',
      'İki tarafı da üzmeyecek son kararını açıklıyor...',
    ],
  };

  // ==========================================
  // SELLING SUSPENSE POOLS (Buyer purchasing from player's showroom)
  // ==========================================

  static const Map<CustomerArchetype, List<String>> _sellingStage1Pool = {
    CustomerArchetype.skepticalOfficial: [
      'Alıcı karşı teklifi görünce duraksadı • Banka mobil uygulamasını açtı...',
      'Ekspertiz raporundaki boya ve değişen detaylarını tekrar inceliyor...',
      'Ruhsat ve muayene kayıtlarını titizlikle gözden geçiriyor...',
      'Galerinin kurumsal puanına ve esnaf geçmişine bakıyor...',
      'Tramer sorgulama ekranındaki kaza tarihlerini tek tek eşleştiriyor...',
      'Aracın şasi ve podye kontrollerini zihninde canlandırıyor...',
      'Memur disipliniyle bütçe sınırlarını zorlayıp zorlayamayacağını ölçüyor...',
      'Kendi bütçe çizelgesine bakarak masada sessizliğe gömüldü...',
    ],
    CustomerArchetype.impatientYouth: [
      'Alıcı arabanın duruşuna ve jantlarına bakıp heyecanlandı...',
      'Karşı teklif rakamını görünce hemen arkadaş grubuna danıştı...',
      'Aracın motor sesini ve hızlanmasını kafasında canlandırıyor...',
      'Sosyal medyada paylaşacağı ilk vitrin fotoğrafının planını yapıyor...',
      'Direksiyonun başına geçip gaza basacağı anı hayal ediyor...',
      'Arkadaşlarına arabanın hikayesini şimdiden anlatmaya başladı...',
      'Cebindeki birikimi hızlıca sayıp teklifi onaylamaya meyilleniyor...',
      'Gözleri parlayarak arabanın farlarına ve çizgilerine bakıyor...',
    ],
    CustomerArchetype.greedyFlipper: [
      'Alıcı karşı teklifi duyunca bıyık altından gülümsedi • Kendi kârını hesaplıyor...',
      'İlan sitelerindeki emsal araç fiyatlarıyla galeri fiyatını kıyaslıyor...',
      'Arabanın üzerine pasta cila çekip ne kadara satacağını düşünüyor...',
      'Piyasadaki anlık likiditeyi ve araç talep hızını ölçüyor...',
      'Bu arabayı alıp aynı gün kârlı devredebileceği müşteriyi arıyor...',
      'Masadaki fiyatı biraz daha aşağı çekmenin taktiğini kuruyor...',
      'Galericiler sitesindeki son satış trendlerini gözden geçiriyor...',
      'Kendi dükkanının vitrinine yakışıp yakışmayacağını tartıyor...',
    ],
    CustomerArchetype.familyMan: [
      'Alıcı arka koltuk mesafesini ve bagaj hacmini düşünüyor...',
      'Karşı teklifi görünce eşine baktı • Bütçeyi gözden geçiriyor...',
      'Arabanın yakıt tüketimini ve periyodik bakım masraflarını inceliyor...',
      'Güvenlik donanımlarını ve çocuk koltuğu bağlantılarını kontrol ediyor...',
      'Ailenin yıllık tatil ve okul bütçesinden ne kadar fedakarlık edeceğini tartıyor...',
      'Çocukların arka koltukta rahat edip edemeyeceğini hesaplıyor...',
      'Eşinin yüzündeki tebessüme bakarak fiyatta esneklik arıyor...',
      'Arabanın temiz aile geçmişini dinleyip içine sindirmeye çalışıyor...',
    ],
  };

  static const Map<CustomerArchetype, List<String>> _sellingStage2Pool = {
    CustomerArchetype.skepticalOfficial: [
      'Taşıt kredisi faiz oranlarını ve aylık taksit limitini hesaplıyor...',
      'Galerinin garanti ve servis taahhüdünü tartıyor...',
      'Noter masrafları ve kasko bedelini toplam bütçesine ekliyor...',
      'Kendi bankacısını arayıp limit artırımını teyit ediyor...',
      'Aracın ikinci el değer kaybı riskini ve amortismanını ölçüyor...',
      'Kasko poliçesindeki muafiyet ve hasarsızlık indirimini hesaplıyor...',
      'Tüm evrakları bir kez daha düzenli klasörüne yerleştiriyor...',
      'Son kuruşuna kadar planlı harcama limitine sadık kalmaya çalışıyor...',
    ],
    CustomerArchetype.impatientYouth: [
      'Maaş avansını ve kredi kartı limitini birleştirmeyi planlıyor...',
      'Arabayı bu akşam hemen teslim alıp alamayacağını düşünüyor...',
      'Benzin masrafını ve ilk hafta gezeceği rotaları hesaplıyor...',
      'Arkadaşından borç alıp bu farkı kapatmayı değerlendiriyor...',
      'Galeriden hemen çıkıp notere koşmanın sabırsızlığını yaşıyor...',
      'Müzik listesini hazırlayıp bluetooth bağlantısını test etmeyi bekliyor...',
      'Masada daha fazla vakit kaybetmeden anahtarı kapmak istiyor...',
      'Yeni arabanın anahtarlığını şimdiden seçti bile...',
    ],
    CustomerArchetype.greedyFlipper: [
      'Aracı alıp hemen üzerine kâr koyarak satıp satamayacağını tartıyor...',
      'Kendi hazır müşterisini arayıp anında devir yapıp yapamayacağını yokluyor...',
      'Sanayideki boyacı arkadaşına parçaların masrafını soruyor...',
      'Nakit parasını bu araca bağlamanın fırsat maliyetini hesaplıyor...',
      'Parayı burada bağlayıp başka fırsatı kaçırma ihtimalini ölçüyor...',
      'Esnaf pazarlığında son bir jest koparabilir miyim diye yokluyor...',
      'Aracın ekspertizindeki ufak kusurları fiyattan düşmeye çalışıyor...',
      'Kendi komisyon ve vergi maliyetlerini masadaki fiyata yediriyor...',
    ],
    CustomerArchetype.familyMan: [
      'Kasko ve sigorta masraflarını toplam maliyete ekliyor...',
      'Aile bütçesini sarsmadan bu rakamı ödeyip ödeyemeyeceğini hesaplıyor...',
      'Evin ihtiyaçlarını erteleyip bu aracı almanın mantıklı olup olmadığını tartışıyor...',
      'Kayınpederiyle telefonda son bir durum değerlendirmesi yapıyor...',
      'Kış lastiği ve periyodik bakım masrafını kafasında topluyor...',
      'Eşine dönüp son onay işaretini bekliyor...',
      'Bu arabanın aileye huzur ve bereket getireceğine inanmak istiyor...',
      'Çocukların konforu için bu bütçeyi zorlamaya karar veriyor...',
    ],
  };

  static const Map<CustomerArchetype, List<String>> _sellingStage3Pool = {
    CustomerArchetype.skepticalOfficial: [
      'Gözlüğünü taktı • Karşı teklife bütçesinin yetip yetmeyeceğine karar veriyor...',
      'Evrak çantasını açtı • Son cevabını vermek üzere masaya eğildi...',
      'Ciddi bir duruşla karşı teklife cevabını netleştiriyor...',
      'Son kez arabanın kaportasına bakıp kararını açıklıyor...',
      'Son derece resmi bir tavırla masadaki kararını bildiriyor...',
      'Titizlikle not aldığı kağıdı katlayıp cebine koydu...',
      'Karar anı geldi • Masadaki son sözünü söylüyor...',
    ],
    CustomerArchetype.impatientYouth: [
      'Anahtarı sabırsızlıkla bekleyerek son kararını açıklıyor...',
      'Gözleri parladı • Masadaki karşı teklife yanıtını veriyor...',
      'Heyecanla yerinden doğrulup elini uzatıyor...',
      'Hızlıca notere geçmek için sabırsızlanıyor...',
      'Yüzündeki coşkuyla masadaki anlaşmayı netleştiriyor...',
      'Bu iş bitti dercesine elini masaya vuruyor...',
      'Hayırlı olsun demek için can atıyor...',
    ],
    CustomerArchetype.greedyFlipper: [
      'Elini cebine attı • Son pazarlık hamlesini netleştiriyor...',
      'Ciddi bir ifadeyle masaya doğru eğildi • Son sözü söylüyor...',
      'Gözlerini kısıp galeriye son teklifini tartıyor...',
      'Masadan kalkıp kalkmayacağını kafasında kesinleştiriyor...',
      'Son bir esnaf tokalaşması için elini uzatmaya hazırlanıyor...',
      'Kârını garantiye almış bir tüccar edasıyla kararını veriyor...',
      'Masadaki son raconunu kesiyor...',
    ],
    CustomerArchetype.familyMan: [
      'Derin bir nefes aldı • Ailesi için son kararını veriyor...',
      'Masaya dönüp elini uzatmaya hazırlanıyor...',
      'Tereddütleri geride bırakıp son cevabını açıklıyor...',
      'Hayırlısı olsun diyerek masadaki net kararını veriyor...',
      'Eşine bakıp gülümseyerek son onayını veriyor...',
      'İki tarafa da hayırlar getirmesini dileyerek elini uzatıyor...',
      'Aile bütçesini zorlasa da gönül rahatlığıyla son kararını açıklıyor...',
    ],
  };
}
