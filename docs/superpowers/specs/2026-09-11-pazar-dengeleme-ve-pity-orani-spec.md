# Galeriden Tycoon • Pazar Dengeleme, Doğal Çeşitlilik ve Hiper Araç Pity Oranı Spesifikasyonu

**Tarih:** 11.09.2026  
**Durum:** Taslak • Kullanıcı Onayı Bekliyor  
**Modül Kimliği:** market-pity-distribution-balance  

---

## 1. Amaç • Objective

Oyuncunun sermayesi 50 milyon TL ve üzerine (örneğin 955 milyon TL) ulaştığında, pazardaki normal arabaların (%98 oranında) filtrelenerek yok edilmesi ve marka ağırlıklarının aşırı açılması sonucu pazarın neredeyse %100 oranında sadece 100M - 350M TL bandındaki hiper araçlarla dolması ("full pahalı araç oldu") sorununu çözmek.

Bu spesifikasyon;
1. ₺15M altındaki araçları %98, ₺35M altındakileri %75 oranında çöpe atan yapay eleme filtresini tamamen kaldırarak pazarın doğal ve zengin çeşitliliğini (Egea, Passat, BMW 3/5, Mercedes C/E, Porsche, Range Rover vb.) korumayı,
2. Milyarder oyuncu seviyesinde (`playerBalance >= 50,000,000`) `hiper` segment ağırlığını 20.0 gibi devasa bir değerden makul bir tabana (~1.0 - 1.2, yaklaşık %7 - %9 doğal düşüş ihtimali) çekmeyi,
3. Kullanıcının asıl talebi olan **"her 10 - 15 araçta bir adet hiper otomobil"** kuralını 12 araçlık kayar blok acıma (pity) sayacı ile tam olarak 1 adet (nadir durumlarda en fazla 2 adet) olacak şekilde garanti etmeyi,
4. Test paketini bu yeni dengeye göre güncelleyerek 40 araçlık bir pazar listesinde hiper araç sayısının 3 ile 6 arasında (yaklaşık her 10-12 araçta 1 adet) kalmasını ve pazarın geri kalanının gerçekçi çeşitlilikte olmasını doğrulamayı hedefler.

---

## 2. Varsayımlar • Assumptions

1. Zengin bir galerici (955M TL bakiye) bile pazarda sadece hiper arabalar değil, alıp satabileceği veya galerisinde sergileyebileceği prestijli günlük arabalar (BMW, Mercedes, Audi, Porsche, Range Rover vb.) görmek ister.
2. Hiper otomobiller pazarın %90'ını istila etmemeli, her 10 - 15 araçta bir karşılaşılan heyecan verici, altın rozetli "nadir bir koleksiyon cevheri" olmalıdır.
3. 12 araçlık her alt kümede (chunk) acıma garantisi çalışmaya devam edecek; eğer o 12 araç içinde doğal olarak hiç hiper araç çıkmadıysa tam olarak 1 adet hiper araç üretilecektir.
4. Sıfır Unicode Emoji ve Sıfır Parantez mimari değişmez kuralları geçerliliğini korur.

---

## 3. Komutlar • Executable Commands

- Analiz ve Lint: `flutter analyze lib/domain/usecases/market_engine.dart test/hyper_car_market_test.dart`
- Pazar Dengeleme Testi: `flutter test test/hyper_car_market_test.dart`
- Vasita Regresyon Testi: `flutter test test/vasita_market_test.dart`
- Tüm Testler: `flutter test`

---

## 4. Proje Yapısı ve Etkilenen Dosyalar • Project Structure

```
lib/
└── domain/
    └── usecases/
        └── market_engine.dart      → Agresif re-roll filtresinin kaldırılması, dengeli segment ağırlıkları (hiper: 1.0)
test/
└── hyper_car_market_test.dart      → 40 araçlık havuzda tam 3 - 6 hiper araç dengesinin ve çeşitliliğin testi
docs/
├── superpowers/
│   └── specs/
│       └── 2026-09-11-pazar-dengeleme-ve-pity-orani-spec.md
└── FILE_CHANGELOG.md               → Değişiklik ve doğrulama kayıtları
```

---

## 5. Kod Standartları ve Matematiksel Tasarım • Code Style & Balance

### A. Agresif Re-roll Filtresinin Kaldırılması
`_generateSingleListing` içerisinde bakiye >= 50M olduğunda çalışan aşağıdaki filtre kaldırılır:
```dart
// KALDIRILACAK KOD:
if (playerBalance >= 50000000) {
  if (price < 15000000 && _random.nextDouble() < 0.98) continue;
  if (price < 35000000 && _random.nextDouble() < 0.75) continue;
}
```
Bunun yerine sadece sermayesi 50M+ olan oyuncunun pazarında ₺100.000 altındaki aşırı hurda araçlar elenir (tüm orta/lüks araçlar korunur).

### B. Milyarder Oyuncu Segment Ağırlıkları (`_selectWeightedBrand`)
`playerBalance >= 50,000,000` durumunda:
```dart
switch (segment) {
  case 'hiper':
    return 1.0; // Doğal düşme şansı ~%7 - %8
  case 'egzotik':
    return 3.0; // Lambo, Ferro
  case 'süperspor':
    return 3.5; // Porş, vb.
  case 'lüks':
    return 4.0; // Merso, Bavyera, vb.
  case 'premium':
    return 3.0;
  case 'elektrikli':
    return 1.5;
  case 'popüler':
  case 'güvenilir':
    return 1.0;
  case 'halk':
    return 0.3;
  case 'ekonomi':
  case 'efsane':
  case 'klasik':
    return 0.1;
  default:
    return 0.5;
}
```
Bu dağılım ile 12 araçlık bir grupta doğal hiper çıkma olasılığı yaklaşık %8'dir. Pity mekanizması ise eğer o grupta hiper çıkmadıysa 1 adet zorunlu hiper araç ekler. Böylece 12 araçta neredeyse daima **tam 1 adet** (çok nadir durumlarda 2 adet) hiper araç bulunur!

---

## 6. Sınırlar ve Kurallar • Boundaries

### Kesinlikle Yapılacaklar • Always Do
- 10-15 araçta bir hiper araç oranı korunacak; 40 araçlık listede hiper sayısı 3 - 6 bandında kalacak.
- Normal arabaların pazarda yer alması garanti edilecek (BMW, Merso, Porş, halk arabaları).
- Yapılan değişiklikler `test/hyper_car_market_test.dart` ve `docs/FILE_CHANGELOG.md` dosyalarına işlenecek.

### Asla Yapılmayacaklar • Never Do
- Hiper araçlar tamamen yok edilmeyecek; 12'li blok pity garantisi kesinlikle korunacak.
- Düşük bakiye (₺100k) oyuncusuna hiper araç düşürülmeyecek.

---

## 7. Başarı Kriterleri • Success Criteria

1. Kasasında 955M TL olan bir oyuncu 40 araçlık pazar ürettiğinde:
   - Hiper araç sayısı en az 3, en fazla 6 adet olmalıdır (ortalama her 10-12 araçta tam 1 adet).
   - Pazardaki araçların en az %80'i normal lüks/spor/orta segment (₺500k - ₺25M) olmalıdır.
2. Kasasında 100k TL olan bir oyuncu için hiper araç sayısı kesinlikle 0 olmalıdır.
3. `flutter test test/hyper_car_market_test.dart` ve `flutter analyze` hatasız geçmelidir.
