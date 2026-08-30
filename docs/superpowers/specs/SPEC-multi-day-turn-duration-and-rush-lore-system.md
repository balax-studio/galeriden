# SPEC: Galeriden Tycoon Çok Günlü Süre (Turn Duration) ve Hikayeli Hızlandırma (Rush Lore) Mimari Sistemi

**Doküman Kodu:** SPEC-2026-RUSH-LORE-MASTER  
**Versiyon:** 1.0.0  
**Durum:** ONAYLANDI / UYGULAMAYA HAZIR  
**Hedef Kapsam:** 12 Hızlı Servis, 11 Yan İşletme, Plaza & Şube Genişlemesi, Atölye, Finans ve Restorasyon Sistemleri  
**Tasarım Dili & Standartlar:** Neo-Brutalism & UI/UX Pro Max (Sıfır Emoji, Sıfır Parantez, 7 Dil Eşzamanlı Senkronizasyon, 44x44pt Dokunma Alanı, Haptic & Toastification)

---

## 1. Yönetici Özeti ve Vizyon (Executive Summary)

Galeriden Tycoon projesinde oyuncu bağlılığını (retention), stratejik derinliği ve oturum süresini artırmak amacıyla anlık (0 gün) tamamlanan tüm atölye, servis, finans ve işletme geliştirme eylemleri **çok günlü (1-7 gün) işlem döngülerine** dönüştürülmektedir.

Geleneksel oyunlardaki "Reklam İzle / Bekleme Süresini Sıfırla" gibi yapay ve oyuncuyu yabancılaştıran çiğ kalıplar yerine; otomotiv dünyasının ve sanayi kültürünün gerçek dinamiklerine dayanan **Prestijli Oyun İçi Hikayeler (In-Universe Rush Lore)** inşa edilmiştir.

### Temel Prensipler
1. **Otomotiv Sanayi Ruhu:** Her hızlandırma işlemi bir reklam izletme değil; "Sanayi Odası Hibesi", "Gece Çift Vardiyası", "Gümrük Yeşil Hat Geçişi" veya "İl Trafik Tescil Protokolü" gibi oyuncunun ticari gücünü hissettiren bir avantaja dönüşür.
2. **Kademeli Gün Döngüsü Uyumu:** Oyuncu gün atladığında (`advanceDay()`), atölyedeki boya kurur, parça kargosu teslim edilir, personelin stajı ilerler ve vadeli faiz tahakkuk eder.
3. **Çift Kanallı Hızlandırma:** Oyuncu her işlem için hem **İtibar Puanı / Nakit Yatırımı** hem de **Sponsorlu Sektör Desteği (Ödüllü Video / Fallback)** ile süreci anında tamamlama seçeneğine sahip olur.

---

## 2. Sistem Mimarisi & Veri Modeli Değişiklikleri

### 2.1. Ortak Aktif İş Kuyruğu Modeli (`ActiveServiceJobModel`)
Tüm servis ve yan işletmelerin çok günlü işlemlerini tek tip, tip güvenli ve serileştirilebilir bir yapıda tutmak için `ActiveServiceJobModel` tanımlanır:

```dart
enum ServiceJobType {
  workshopEngineOverhaul,
  workshopPartsDelivery,
  workshopBarnFindRestore,
  carWashCeramicCure,
  carWashInteriorDry,
  carWashPpfArmor,
  tuningEcuRemap,
  tuningAirSuspension,
  staffAcademyTraining,
  staffExecutiveCert,
  expertiseDeepInspection,
  expertiseTuvPreparation,
  auctionVehicleTransport,
  auctionCustomsClearance,
  financeTermDeposit,
  financeChequeClearing,
  stockIpoSubscription,
  stockBlockTradeSettlement,
  showroomMarbleRenovation,
  showroomVipLounge,
  scrapyardDismantlePress,
  scrapyardMetalRecycleBatch,
  rentCarCorporateFleet,
  rentCarInsuranceAppraisal,
  consignmentVipMatchmaking,
  consignmentNotaryTransfer,
  sideBusinessLevelUpgrade,
  branchCityPermitOpening,
}

class ActiveServiceJobModel {
  final String id;
  final ServiceJobType type;
  final String targetEntityId; // Car ID, Staff ID, SideBusiness ID, etc.
  final String targetTitle;
  final int startDay;
  final int totalDurationDays;
  final int remainingDays;
  final int rushCashCost;
  final int rushReputationCost;
  final String rushLoreTitleKey;
  final String rushLoreDescKey;
  final String rushButtonActionKey;
  final Map<String, dynamic> metadata;

  const ActiveServiceJobModel({
    required this.id,
    required this.type,
    required this.targetEntityId,
    required this.targetTitle,
    required this.startDay,
    required this.totalDurationDays,
    required this.remainingDays,
    required this.rushCashCost,
    required this.rushReputationCost,
    required this.rushLoreTitleKey,
    required this.rushLoreDescKey,
    required this.rushButtonActionKey,
    this.metadata = const {},
  });
}
```

### 2.2. Günlük İlerleme Motoru (`DailyCycleEngine`) Entegrasyonu
`DealershipNotifier.advanceDay()` tetiklendiğinde:
1. `activeServiceJobs` listesindeki tüm işlerin `remainingDays` değeri 1 azaltılır.
2. `remainingDays == 0` olan işler otomatik olarak tamamlanır:
   - İlgili aracın durumu güncellenir (örn. `CarStatus.readyForSale`, motor kondisyonu %100).
   - Tamamlanan iş için `NotificationService.showSuccess` ile 7 dilde bildirim fırlatılır.
   - İlgili istatistik ve başarımlar (`PlayerAchievements`) tetiklenir.

---

## 3. 12 Hızlı Servis Modülü Kapsamlı Süre ve Hikaye Matrisi

---

### Modül 1: Oto Yıkama & Detailing (`/car-wash`)
*Kullanıcı Arayüzü: Lift, Buhar ve Fırın Kabinleri | Neo-Brutal Kart Rengi: `#00F0FF`*

#### 1.1. Seramik Kaplama & Nano Boya Kürü
- **İşlem Süresi:** 2 Gün
- **Oyun İçi Hikaye:** "Boya üzerine uygulanan 9H sertlikteki seramik nano moleküllerinin kılcal çizik bırakmadan kemikleşmesi ve fırında fiksaj kürünü tamamlaması için 2 tam gün ortam dinlenmesi gerekmektedir."
- **Hızlandırma Başlığı (Dialog Title):** `KIZILÖTESİ FIRINLAMA KABİNİ`
- **Hızlandırma Açıklaması (Lore Body):** "Sanayi Detailing Derneği akredite kızılötesi dalga boylu kürleme tüneli devreye sokularak seramik fiksaj süresi anında tamamlanır."
- **Aksiyon Butonu:** `IR FIRINLAMAYI DEVREYE AL`
- **Alternatif Hızlı Buton:** `3.500 TL • SANAYİ ELEKTRİK PROTOKOLÜ`

#### 1.2. Detaylı İç Kuaför & Ozonlama
- **İşlem Süresi:** 1 Gün
- **Oyun İçi Hikaye:** "Taban halısı, tavan döşemesi ve deri koltukların sökülerek sıcak buharla yıkanması, ardından ozon gazı ile kokulardan arındırılıp nemsiz kurutulması 1 gün sürmektedir."
- **Hızlandırma Başlığı:** `EKSPRES BUHAR VE OZON TÜNELİ`
- **Hızlandırma Açıklaması:** "Yüksek debili endüstriyel sıcak hava üfleçleri kurularak araç içi nem sıfırlanır ve anında teslime hazır hale gelir."
- **Aksiyon Butonu:** `SICAK HAVA TÜNELİNE AL`

#### 1.3. PPF Şeffaf Poliüretan Zırh Kaplama
- **İşlem Süresi:** 3 Gün
- **Oyun İçi Hikaye:** "200 mikronluk TPU zırh folyonun araç gövdesine milimetrik gerdirilmesi, kenar paylarının kıvrılması ve yapışkan polimerlerin kuruma süreci 3 gün sürer."
- **Hızlandırma Başlığı:** `LAZER DESTEKLİ DİJİTAL FOLYO KESİMİ`
- **Hızlandırma Açıklaması:** "Gövdeye özel lazer plotter kesim ve anlık ultraviyole sabitleyici tabanca kullanılarak kaplama anında tamamlanır."
- **Aksiyon Butonu:** `LAZER HATTINI BAŞLAT`

---

### Modül 2: Atölye & Mekanik Onarım (`/workshop`)
*Kullanıcı Arayüzü: Hidrolik Liftler, Yedek Parça Rafları | Neo-Brutal Kart Rengi: `#FF7A00`*

#### 2.1. Ağır Motor & Şanzıman Revizyonu
- **İşlem Süresi:** 3 Gün
- **Oyun İçi Hikaye:** "Silindir kapak taşlama, supap taşlama, krank mili rektifiyesi ve tork konvertörü dişli yenilemesi rektifiye atölyesinde sıra beklemektedir."
- **Hızlandırma Başlığı:** `SANAYİDE GECE ÇİFT VARDİYASI`
- **Hızlandırma Açıklaması:** "Maslak Sanayi Sitesi Usta Dayanışma Ağı sayesinde gece çift vardiyası başlatılır; taşlama ve montaj sabaha kadar tamamlanır."
- **Aksiyon Butonu:** `ÇİFTE VARDİYAYA GEÇ`
- **Alternatif Hızlı Buton:** `5.000 TL • USTA MESAİ BEDELİ`

#### 2.2. Yedek Parça İthalatı & Siparişi
- **İşlem Süresi:** 2 Gün
- **Oyun İçi Hikaye:** "Araca ait orijinal OEM mekanik parçalar yurt dışı ana depodan gümrük aktarma merkezine doğru kara yoluyla transferdedir."
- **Hızlandırma Başlığı:** `EKSPRES HAVA KARGO HATTI`
- **Hızlandırma Açıklaması:** "Sektörel Lojistik Konsorsiyumu özel kargo uçağı rotasıyla parçalar gümrükten doğrudan atölye liftine indirilir."
- **Aksiyon Butonu:** `HAVA KARGO İLE GETİR`

#### 2.3. Hurdalık Efsane Restorasyonu (Barn Find)
- **İşlem Süresi:** 5 - 7 Gün
- **Oyun İçi Hikaye:** "Yıllarca samanlıkta çürümüş gövdenin saç kıvırma tezgahında baştan üretilmesi, epoksi astar atılması ve fırın boya katmanlarının çekilmesi uzun bir zanaat sürecidir."
- **Hızlandırma Başlığı:** `KLASİK OTO KULÜBÜ RESTORASYON HİBESİ`
- **Hızlandırma Açıklaması:** "Tarihi Araçlar Federasyonu usta başları ve restorasyon zanaatkarları tam teçhizat galerine gelerek aracı anında canlandırır."
- **Aksiyon Butonu:** `UZMAN EKİBİ ÇAĞIR`

---

### Modül 3: Tuning Stüdyosu & Modifiye (`/tuning-studio`)
*Kullanıcı Arayüzü: Dyno Test Tamburu, Neon Egzoz Işıkları | Neo-Brutal Kart Rengi: `#A855F7`*

#### 3.1. Stage 2 & Stage 3 ECU Yazılım Haritalandırma
- **İşlem Süresi:** 2 Gün
- **Oyun İçi Hikaye:** "Beyin yazılımının dyno üzerinde farklı devir bantlarında loglanması, hava yakıt oranı (AFR) kalibrasyonu ve ateşleme avans haritasının optimize edilmesi."
- **Hızlandırma Başlığı:** `MÜHENDİSLİK TELEMETRİ ONAYI`
- **Hızlandırma Açıklaması:** "Almanya Motor Sporları Ar-Ge Laboratuvarı telemetri ağına bağlanılarak optimize edilmiş dyno haritası anında beyne flaşlanır."
- **Aksiyon Butonu:** `DİJİTAL HARİTAYI YÜKLE`

#### 3.2. Air Süspansiyon & Varex Egzoz Sistemi
- **İşlem Süresi:** 1 Gün
- **Oyun İçi Hikaye:** "Hava tankı izolasyonu, çift kompresör tesisatı çekimi ve paslanmaz krom egzoz borularının tig kaynağı ile araca monte edilmesi."
- **Hızlandırma Başlığı:** `ÖZEL ATÖLYE HIZLANDIRMASI`
- **Hızlandırma Açıklaması:** "Performans Atölyesi hidrolik pres ve kaynak ekibi montajı bekletmeksizin tamamlar."
- **Aksiyon Butonu:** `MONTAJI ANINDA TAMAMLA`

---

### Modül 4: Personel & Usta Akademisi (`/staff`)
*Kullanıcı Arayüzü: Usta Kartları, Mezuniyet Rozetleri | Neo-Brutal Kart Rengi: `#EC4899`*

#### 4.1. Usta & Eksper Uzmanlık Eğitimi
- **İşlem Süresi:** 2 - 3 Gün
- **Oyun İçi Hikaye:** "Çırak ve kalfaların Mesleki Yeterlilik Kurumu müfredatı gereği motor, kaporta ve dyno simülatörlerinde staj görmesi."
- **Hızlandırma Başlığı:** `ÖZEL SANAYİ SEMİNERİ`
- **Hızlandırma Açıklaması:** "Otomotiv Sanayi Odası sponsorluğundaki hızlandırılmış ustalık semineri ile personel eğitimini anında tamamlar."
- **Aksiyon Butonu:** `SPONSOR DESTEĞİ AL & MEZUN ET`

#### 4.2. Kurumsal Yönetici & Filo Satış Sertifikasyonu
- **İşlem Süresi:** 4 Gün
- **Oyun İçi Hikaye:** "Satış danışmanının lüks filo finansmanı, müşteri psikolojisi ve kurumsal portföy yönetimi eğitimi."
- **Hızlandırma Başlığı:** `TİCARET ODASI BURSU`
- **Hızlandırma Açıklaması:** "Türkiye Odalar ve Borsalar Birliği Üst Düzey Yönetici Bursu ile sertifika anında takdim edilir."
- **Aksiyon Butonu:** `BURS İLE DİPLOMAYI AL`

---

### Modül 5: Ekspertiz & Muayene İstasyonu (`/expertise`)
*Kullanıcı Arayüzü: Diagnostik Ekranı, Fren Test Tamburu | Neo-Brutal Kart Rengi: `#14B8A6`*

#### 5.1. 101 Nokta Kurumsal Ekspertiz Raporu
- **İşlem Süresi:** 1 Gün
- **Oyun İçi Hikaye:** "Aracın kaporta mikron boya kalınlığı, şase podye kontrolü, obd beyin arıza geçmişi ve dyno motor tork testinin sırayla yapılması."
- **Hızlandırma Başlığı:** `VIP EKSPERTİZ ÖNCELİĞİ`
- **Hızlandırma Açıklaması:** "Kurumsal ekspertiz merkezinde VIP test lifti tahsis edilir ve detaylı rapor anında sisteme düşer."
- **Aksiyon Butonu:** `VIP LİFTE AL & RAPORLA`

#### 5.2. TÜV Ön Muayene Hazırlığı
- **İşlem Süresi:** 2 Gün
- **Oyun İçi Hikaye:** "Fren sapma yüzdesi, far yükseklik ayarları, egzoz emisyon değerleri ve alt takım rot boşluklarının resmi muayene öncesi sıfırlanması."
- **Hızlandırma Başlığı:** `TÜV AKREDİTE HIZLI TEST BANDI`
- **Hızlandırma Açıklaması:** "Yetkili muayene simülasyon bandı çalıştırılarak ağır kusurlar anında taranır ve onaylanır."
- **Aksiyon Butonu:** `TEST BANDINI HIZLANDIR`

---

### Modül 6: Araç İhalesi & Lojistik (`/auction`)
*Kullanıcı Arayüzü: Canlı Tokmak, Sevkiyat Tırları | Neo-Brutal Kart Rengi: `#EF4444`*

#### 6.1. Şehirlerarası İhale Aracı Tır Sevkiyatı
- **İşlem Süresi:** 2 - 3 Gün
- **Oyun İçi Hikaye:** "İhaleden kazanılan lüks otomobilin Ankara / İzmir / Adana bölgesinden 8'li oto taşıyıcı tır ile İstanbul galerine nakliyesi."
- **Hızlandırma Başlığı:** `VIP OTO TAŞIYICI TIR FİLOSU`
- **Hızlandırma Açıklaması:** "Özel tekli hidrolik çekici tırı doğrudan araca yönlendirilir ve oto yoldan ekspres transfer sağlanır."
- **Aksiyon Butonu:** `EKSPRES SEVKİYATI BAŞLAT`

#### 6.2. Gümrük Çıkışı & Ordino Tescili
- **İşlem Süresi:** 3 Gün
- **Oyun İçi Hikaye:** "İthal araçların gümrük antreposunda bandrol, tse uygunluk ve ordino evraklarının incelenmesi."
- **Hızlandırma Başlığı:** `GÜMRÜK YEŞİL HAT GEÇİŞ PROTOKOLÜ`
- **Hızlandırma Açıklaması:** "Dış Ticaret Müsteşarlığı Yeşil Hat imtiyazı kullanılarak evrak kuyruğu atlanır ve araç serbest dolaşıma çıkar."
- **Aksiyon Butonu:** `YEŞİL HAT ONAYI AL`

---

### Modül 7: Banka, Finans & Faktoring (`/finance`)
*Kullanıcı Arayüzü: Kasa Defteri, Faiz Eğrisi, Çek Çekmecesi | Neo-Brutal Kart Rengi: `#00E575`*

#### 7.1. Vadeli Mevduat & Hazine Bonosu Vadesi
- **İşlem Süresi:** 7 - 14 Gün
- **Oyun İçi Hikaye:** "Bankaya yatırılan yüksek tutarlı nakdin bileşik faiz getirisini tamamlaması için gereken vade süresi."
- **Hızlandırma Başlığı:** `ERKEN FAİZ TEMLİK PROTOKOLÜ`
- **Hızlandırma Açıklaması:** "Banka genel müdürlüğü özel müşteri protokolü ile faiz tahakkukunu anında hesaba aktarır."
- **Aksiyon Butonu:** `VADEYİ ERKEN BOZDUR`

#### 7.2. Müşteri Vadeli Çek Tahsilatı
- **İşlem Süresi:** 5 - 10 Gün
- **Oyun İçi Hikaye:** "Araç satışında takasa alınan müşteri çekinin bankalar arası kliring takas odasındaki tahsilat vadesi."
- **Hızlandırma Başlığı:** `KOMİSYONSUZ FAKTORİNG FONU`
- **Hızlandırma Açıklaması:** "Finansman konsorsiyumu çeki %0 komisyonla iskonto eder ve nakit tutarı anında kasana yatırır."
- **Aksiyon Butonu:** `FON DESTEĞİYLE NAKDE ÇEVİR`

---

### Modül 8: Borsa & Fon Piyasası (`/stock-market`)
*Kullanıcı Arayüzü: Mum Grafikleri, Portföy Dağılımı | Neo-Brutal Kart Rengi: `#6366F1`*

#### 8.1. Halka Arz (IPO) Talep Toplama & Dağıtım
- **İşlem Süresi:** 3 Gün
- **Oyun İçi Hikaye:** "Otomotiv yan sanayi şirketinin halka arz talep toplama defterinin kapanması ve hisselerin takasa aktarılması."
- **Hızlandırma Başlığı:** `FON KURUCUSU İMTİYAZI`
- **Hızlandırma Açıklaması:** "Konsorsiyum lideri aracı kurum kurucu paylarını anında portföyüne aktarır."
- **Aksiyon Butonu:** `HİSSELERİ ERKEN DAĞIT`

#### 8.2. Blok Emtia & Hisse Takas Süreci (T+2)
- **İşlem Süresi:** 2 Gün
- **Oyun İçi Hikaye:** "Yüksek hacimli hisse ve altın alımlarında takas saklama merkezinin T+2 valör beklemesi."
- **Hızlandırma Başlığı:** `ANLIK T+0 TAKAS PROTOKOLÜ`
- **Hızlandırma Açıklaması:** "Merkezi Kayıt Kuruluşu anlık valör onayı vererek varlıkları saniyesinde serbest bırakır."
- **Aksiyon Butonu:** `TAKASI HEMEN TAMAMLA`

---

### Modül 9: Showroom Dekorasyonu & Plaza (`/showroom-decor`)
*Kullanıcı Arayüzü: Zemin Döşemeleri, Işıklandırma, Duvar Temaları | Neo-Brutal Kart Rengi: `#06B6D4`*

#### 9.1. İtalyan Mermer Zemin & Vitrin Tadilatı
- **İşlem Süresi:** 3 Gün
- **Oyun İçi Hikaye:** "Lüks showroom zeminine İtalyan granit mermer döşenmesi, derz dolgularının donması ve vitrin spot ışıklarının çekilmesi."
- **Hızlandırma Başlığı:** `MİMARİ ŞANTİYE ÇİFT VARDİYA`
- **Hızlandırma Açıklaması:** "İç mimarlık ofisi ustaları 24 saat kesintisiz şantiye çalışması ile tadilatı anında teslim eder."
- **Aksiyon Butonu:** `MİMARİ EKİBİ DEVREYE AL`

#### 9.2. VIP Puro & Espresso Lounge Kurulumu
- **İşlem Süresi:** 2 Gün
- **Oyun İçi Hikaye:** "Özel deri koltuk takımları, puro nemlendirme dolabı ve endüstriyel kahve barı montajı."
- **Hızlandırma Başlığı:** `ÖZEL JET TESLİMAT LOJİSTİĞİ`
- **Hızlandırma Açıklaması:** "İtalyan mobilya ve ekipmanlar ekspres kurye ile getirilerek anında kullanıma açılır."
- **Aksiyon Butonu:** `LOUNGE'U ANINDA AÇ`

---

### Modül 10: Hurdalık & Ağır Metal Söküm (`/scrapyard`)
*Kullanıcı Arayüzü: Hurda Pres Makinesi, Ayrıştırma Konteynerleri | Neo-Brutal Kart Rengi: `#64748B`*

#### 10.1. Ağır Kazalı Araç Söküm & Parça Ayrıştırma
- **İşlem Süresi:** 1 - 2 Gün
- **Oyun İçi Hikaye:** "Pert aracın motor bloğu, şanzımanı, bakır tesisatı ve kapı saclarının oksijen kaynağı ile ayrıştırılması."
- **Hızlandırma Başlığı:** `HİDROLİK ENDÜSTRİYEL PRES`
- **Hızlandırma Açıklaması:** "Ağır sanayi parçalama makinesi çalıştırılarak tüm sağlam parçalar saniyeler içinde tasnif edilir."
- **Aksiyon Butonu:** `PRESLERİ TAM GÜÇ ÇALIŞTIR`

#### 10.2. Geri Dönüşüm Çelik Sevkiyatı
- **İşlem Süresi:** 2 Gün
- **Oyun İçi Hikaye:** "Toplanan 50 tonluk hurda sacın döküm fabrikasına tren vagonlarıyla taşınması ve tartım kabulü."
- **Hızlandırma Başlığı:** `LİMAN GERİ DÖNÜŞÜM PROTOKOLÜ`
- **Hızlandırma Açıklaması:** "Demir çelik tesisleri öncelikli kabul fişi keserek hurda gelirini doğrudan hesabına aktarır."
- **Aksiyon Butonu:** `SEVKİYAT TAHAKKUKUNU AL`

---

### Modül 11: Rent A Car & Filo Kiralama (`/rent-a-car`)
*Kullanıcı Arayüzü: Sözleşmeler, Takvim Çizelgesi, Kilometre Takibi | Neo-Brutal Kart Rengi: `#38BDF8`*

#### 11.1. Kurumsal VIP Filo Kiralama Süresi
- **İşlem Süresi:** 3 - 5 Gün
- **Oyun İçi Hikaye:** "Holding yöneticilerine veya dizi çekim ekibine sözleşmeli olarak tahsis edilen lüks aracın kira süresi."
- **Hızlandırma Başlığı:** `ERKEN KİRA DÖNÜŞ İSTİSNASI`
- **Hızlandırma Açıklaması:** "Holding yöneticisi protokolü erken tamamlayarak aracı ful depo ve temiz şekilde galeriye iade eder."
- **Aksiyon Butonu:** `ARACI HEMEN TESLİM AL`

#### 11.2. Hasarlı Dönüş Kasko Ekspertiz Onayı
- **İşlem Süresi:** 2 Gün
- **Oyun İçi Hikaye:** "Kiradan tampon hasarıyla dönen aracın kasko şirketince incelenmesi ve hasar tazminat dosyasının onaylanması."
- **Hızlandırma Başlığı:** `KASKO HIZLI ÖDEME JESTİ`
- **Hızlandırma Açıklaması:** "Sigorta şirketi kurumsal acente önceliği tanıyarak tazminatı bekletmeden hesaba aktarır."
- **Aksiyon Butonu:** `KASKO TAZMİNATINI ONAYLA`

---

### Modül 12: Konsinye & Emanet Satış (`/consignment`)
*Kullanıcı Arayüzü: Emanet Sözleşmeleri, Müşteri Teklifleri | Neo-Brutal Kart Rengi: `#10B981`*

#### 12.1. Lüks Koleksiyoncu Konsinye Araç Eşleştirmesi
- **İşlem Süresi:** 3 - 6 Gün
- **Oyun İçi Hikaye:** "Zengin bir iş insanının galeriye bıraktığı nadide klasik aracın doğru koleksiyonere sunulup pazarlık edilmesi."
- **Hızlandırma Başlığı:** `ÖZEL VIP MÜŞTERİ DAVETİYESİ`
- **Hızlandırma Açıklaması:** "Kapalı müzayede üyelerine anlık bildirim gönderilerek araç anında nakde çevrilir."
- **Aksiyon Butonu:** `KAPALI PORTFÖYE SUN`

#### 12.2. Noter Mülkiyet & Haciz Temizleme Tescili
- **İşlem Süresi:** 1 Gün
- **Oyun İçi Hikaye:** "Araç üzerindeki rehin ve vergi borçlarının takyidat düşümü ve konsinye sahibinin vekalet onayı."
- **Hızlandırma Başlığı:** `NÖBETÇİ NOTER PROTOKOLÜ`
- **Hızlandırma Açıklaması:** "Noterler Birliği online entegrasyonuyla devir tescili anında tamamlanır."
- **Aksiyon Butonu:** `VEKALETİ ANINDA TESCİL ET`

---

## 4. 11 Yan İşletme Seviye Yükseltme & Genişleme Süreleri

Yan işletmeler seviye atlatıldığında inşaat ve ruhsat süreçleri devreye girer:

| Yan İşletme | Seviye Yükseltme Süresi | Hızlandırma Başlığı | Hikaye & Açıklama | Aksiyon Butonu |
|---|---|---|---|---|
| **Oto Yıkama & Detailing** | 2 Gün | `BELEDİYE SU & KANALİZASYON İZNİ` | "Arıtma tesisi ve su tahliye onayları hızlandırılır." | `BELEDİYE İZNİNİ AL` |
| **Otomat & Kahve İstasyonu** | 1 Gün | `KAHVE DÜNYASI LOJİSTİK AKIŞI` | "Yeni nesil dokunmatik kahve robotları kurulur." | `ROBOTLARI KUR` |
| **Oto Kurtarma & Çekici** | 3 Gün | `ULAŞTIRMA BAKANLIĞI K1 BELGESİ` | "Çekici araç filosuna ekspres yetki belgesi çıkartılır." | `K1 BELGESİNİ ONAYLA` |
| **Dijital Reklam & Billboard** | 2 Gün | `KENTSEL TASARIM REKLAM TESCİLİ` | "Belediye estetik kurulundan anlık led ekran izni alınır." | `REKLAM TESCİLİNİ AL` |
| **Yedek Parça & Modifiye Dükkanı** | 3 Gün | `TSE ONAYLI RAF STOK PROTOKOLÜ` | "İthalatçı distribütör rafları tam kapasite doldurur." | `STOKLARI DOLDUR` |
| **TÜV & Oto Muayene İstasyonu** | 4 Gün | `BAKANLIK AKREDİTASYON DENETİMİ` | "Muayene istasyonu kalibrasyon denetimi anında geçer." | `AKREDİTASYONU AL` |
| **Filo Kiralama Şirketi** | 3 Gün | `FİLO KASKO TEMİNAT MEKTUBU` | "Banka teminat mektubu komisyonsuz onaylanır." | `TEMİNATI ONAYLA` |
| **Elektrikli Şarj İstasyonu (EV)** | 3 Gün | `YÜKSEK GERİLİM TRAFO PROTOKOLÜ` | "Enerji dağıtım şirketi ek güç trafosunu anında bağlar." | `TRAFO PROTOKOLÜNÜ İMZALA` |
| **Kurumsal Ekspertiz Merkezi** | 2 Gün | `DİJİTAL DYNO AKREDİTASYONU` | "Mekanik test cihazları yazılım güncellemesini tamamlar." | `DYNO ONAYINI AL` |
| **Büyük Oto Sanayi Parça Deposu** | 4 Gün | `GÜMRÜK LOJİSTİK ANTREPO PROTOKOLÜ` | "Ana dağıtım merkezi antrepo kapılarını açar." | `ANTREPOYU DEVREYE AL` |
| **Özel Araç Kaplama Stüdyosu** | 2 Gün | `TOZSUZ İKLİMLENDİRME KABİNİ` | "Özel hava filtreleme kabini montajı anında biter." | `KABİNİ ÇALIŞTIR` |

---

## 5. UI/UX Pro Max Standartlarında Hızlandırma Modal Tasarımı

### 5.1. Görsel & Yapısal Spesifikasyonlar
- **Kart Mimarisi:** Neo-Brutalism, 3.5px sert siyah kenarlık (`#000000`), 6px offset gölge (`AppThemeExtension.neoShadow`).
- **Renk Skalası:**
  - Arka Plan: Koyu Modda `#18181B` / Açık Modda `#F4F4F5`
  - Vurgu Başlık Rozeti: `#FFDE59` (Canlı Sarı)
  - Sponsor Butonu: `#00E575` (Canlı Neon Yeşil)
  - Alternatif Nakit Butonu: `#38BDF8` (Elektrik Mavisi)
- **Tipografi:** Başlıklar `900 Black` büyük harf, gövde metinleri `500 Medium` rahat okunabilir satır aralığı (1.5 line-height).
- **İkon Standardı:** Sıfır Unicode Emoji. Tamamı `VectorIconWidget` ve `Icons.*` platform-native ikon setinden seçilir.
- **Yazım Kuralı:** Sıfır Parantez `(...)`. Tüm açıklama ve düğmelerde ` • ` veya ` - ` kullanılır.

### 5.2. Dokunmatik & Haptic Geri Bildirim
- Dialog açıldığında hafif haptic titreşim: `HapticFeedback.mediumImpact()`.
- Butona basıldığında anlık yükleme animasyonu, spam engelleme (`isSubmitting` reactive flag).
- Tamamlandığında Toastification ile başarılı yeşil toast bildirimi.

---

## 6. Eşzamanlı 7 Dil Senkronizasyonu (7-Language Synchronization)

Tüm hızlandırma başlıkları, açıklamaları ve butonları aşağıdaki 7 dilde eşzamanlı olarak üretilmiştir:

```text
Diller:
1. Türkçe (tr)
2. İngilizce (en)
3. Almanca (de)
4. Portekizce (pt)
5. İspanyolca (es)
6. Rusça (ru)
7. Arapça (ar)
```

Örnek Sözlük Eşleşmesi:
- **tr:** `SANAYİDE GECE MESAİSİ` • `Maslak Sanayi Sitesi çift vardiya desteği ile işlem anında tamamlanır.` • `ÇİFTE VARDİYAYA GEÇ`
- **en:** `NIGHT SHIFT OVERTIME` • `Double shift at the industrial zone completes the job instantly.` • `ACTIVATE NIGHT SHIFT`
- **de:** `INDUSTRIE-NACHTSCHICHT` • `Doppelschicht im Industriegebiet schließt den Auftrag sofort ab.` • `NACHTSCHICHT STARTEN`
- **pt:** `TURNO DA NOITE INDUSTRIAL` • `Turno duplo na zona industrial conclui o serviço imediatamente.` • `ATIVAR TURNO NOTURNO`
- **es:** `TURNO DE NOCHE INDUSTRIAL` • `El doble turno en el polígono industrial completa el trabajo al instante.` • `ACTIVAR TURNO DE NOCHE`
- **ru:** `НОЧНАЯ СМЕНА В АВТОСЕРВИСЕ` • `Двойная смена в промышленной зоне мгновенно завершает работу.` • `ЗАПУСТИТЬ НОЧНУЮ СМЕНУ`
- **ar:** `وردية ليلية صناعية` • `الوردية المزدوجة في المنطقة الصناعية تنهي العمل على الفور.` • `بدء الوردية الليلية`

---

## 7. Test ve Kalite Güvencesi (Verification Plan)

1. **Unit Testleri:**
   - `advanceDay()` çağrıldığında `ActiveServiceJobModel` kalan günlerinin doğru düşmesi.
   - 0 güne ulaşan işlerin otomatik teslim edilmesi ve state'in güncellenmesi.
   - Hızlandırma (`rushJob()`) yapıldığında reklam fallback ve nakit ödeme testleri.
2. **Widget Testleri:**
   - Tüm servis sayfalarındaki geri sayım rozetlerinin (`X GÜN KALDI`) render doğrulaması.
   - Hızlandırma modalının 7 dilde doğru açılıp kapanması ve `stopPeriodicOrganicOfferTimer` temizliği.
3. **Statik Analiz:**
   - `flutter analyze` ile 0 uyarı, 0 hata, 0 lint kusuru.
