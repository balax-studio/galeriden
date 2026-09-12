# Galeriden Tycoon • Hiper Araç Havuzu ve Kasaya Entegre Koleksiyon Çarpanı Spesifikasyonu

**Tarih:** 11.09.2026  
**Durum:** Taslak • Onay Bekliyor  
**Modül Kimliği:** hypercar-market-economy  

---

## 1. Amaç • Objective

Oyunda sermayesi 50 milyon TL ile 1 milyar TL ve üzerine ulaşan zengin oyuncuların yaşadığı ekonomik tavan ve pazar durgunluğu sorununu çözmek. 

Şu anda pazardaki en pahalı araçlar Lambo ve Ferro egzotik modelleri olup 10 - 15 milyon TL bandında tıkanmaktadır. Bu spesifikasyon;
1. Taban fiyatları 65 milyon ile 220 milyon TL arasında değişen yeni bir Hiper otomobil segmenti • Bugaç, Köniğ, Pagan, Rolso ve özel Ferro koleksiyonu oluşturmayı,
2. Oyuncunun kasasındaki bakiye 50 milyon TL üzerine çıktığında her 10 - 15 araçta bir garanti hiper araç düşüşü sağlayan acıma • pity sayacı algoritmasını,
3. Birebir Ismarlama 1/1, Zırhlı Devlet Makamı, Karbon Pist Paketi ve Kraliyet Koleksiyonu gibi dinamik prestij çarpanları ile araç değerlerini 50M - 350M TL seviyesine ölçeklemeyi,
4. Neo-brutalist tasarım diliyle uyumlu özel altın/mor vitrin rozeti ve 7 dilde eksiksiz yerelleştirmeyi tanımlar.

---

## 2. Varsayımlar • Assumptions

1. Oyuncu bakiyesi 50.000.000 TL altında iken normal pazar akışı bozulmayacak, hiper araçlar düşük sermayeli oyuncunun pazarını işgal etmeyecektir.
2. Marka ve model isimleri projenin mizahi Türk sanayi ve sokak jargonu parodi geleneğine sadık kalacaktır • Bugaç, Köniğ, Pagan, Rolso.
3. Fiyatlar ve değerlemeler tam sayı veya kuruşsuz çift duyarlıklı sayı • double olarak hesaplanacak, para birimi formatlayıcıları ₺150M veya ₺1.2B şeklinde taşma olmadan gösterecektir.
4. Sıfır Unicode Emoji ve Sıfır Parantez değişmez kuralları geçerlidir • UI metinlerinde parantez yerine tire veya nokta kullanılacaktır.

---

## 3. Komutlar • Executable Commands

- Analiz ve Lint: `flutter analyze`
- Birim Testleri: `flutter test test/unit/hyper_car_market_test.dart`
- Tüm Testler: `flutter test`
- Uygulama Derleme: `flutter build apk --debug` veya `flutter run`

---

## 4. Proje Yapısı ve Etkilenen Dosyalar • Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── game_constants.dart         → Yeni Bugaç, Köniğ, Pagan, Rolso hiper markaları
│   │   └── car_specifications.dart     → 15 yeni hiper modelin beygir, tork ve hızlanma verileri
│   └── localization/
│       └── translations/
│           ├── tr_translations.dart    → Türkçe hiper koleksiyon ve unvan anahtarları
│           ├── en_translations.dart    → İngilizce senkronizasyonu
│           ├── de_translations.dart    → Almanca senkronizasyonu
│           ├── pt_translations.dart    → Portekizce senkronizasyonu
│           ├── es_translations.dart    → İspanyolca senkronizasyonu
│           ├── ru_translations.dart    → Rusça senkronizasyonu
│           └── ar_translations.dart    → Arapça senkronizasyonu
├── data/
│   └── models/
│       └── car_model.dart              → isHyperCar tespiti ve koleksiyon prestij desteği
├── domain/
│   └── usecases/
│       └── market_engine.dart          → 'hiper' segment baz değer hesabı, koleksiyon çarpanı ve 10-15 sayaç
└── presentation/
    └── screens/
        └── vasita/
            └── vasita_market_screen.dart → ÖZEL HİPER KOLEKSİYON rozet sunumu
test/
└── unit/
    └── hyper_car_market_test.dart      → 955M TL senaryosu ve pazar garantisi testleri
docs/
├── superpowers/
│   └── specs/
│       └── 2026-09-11-hiper-arac-ve-koleksiyon-spec.md
└── FILE_CHANGELOG.md                   → Değişiklik ve doğrulama kayıtları
```

---

## 5. Kod Standartları ve Örnek Uygulama • Code Style

### Örnek Segment ve Fiyatlandırma Kodu

```dart
// market_engine.dart içerisinde
case 'hiper':
  if (modelName.contains('Karasu')) return 220000000.0;
  if (modelName.contains('Divo')) return 145000000.0;
  if (modelName.contains('Jesko')) return 135000000.0;
  if (modelName.contains('Şiron') || modelName.contains('Chiron')) return 110000000.0;
  if (modelName.contains('Ütopya') || modelName.contains('Utopia')) return 105000000.0;
  if (modelName.contains('Agera')) return 95000000.0;
  if (modelName.contains('Zonda')) return 90000000.0;
  if (modelName.contains('LaFerro')) return 85000000.0;
  if (modelName.contains('Veyron')) return 75000000.0;
  if (modelName.contains('Fantom')) return 65000000.0;
  return 65000000.0 + (year >= 2018 ? (year - 2018) : 0) * 8000000.0;
```

### Örnek Koleksiyon Prestij Çarpanı

```dart
// Kasadaki para 50M TL ve üzeri olduğunda çalışan çarpan
if (playerBalance != null && playerBalance >= 50000000.0 && isHyper) {
  final roll = _random.nextDouble();
  if (roll < 0.25) {
    // Birebir Ismarlama 1/1
    baseValue *= 1.8;
  } else if (roll < 0.50) {
    // Zırhlı Devlet Makamı
    baseValue *= 1.6;
  } else if (roll < 0.70) {
    // Karbon Pist Paketi
    baseValue *= 1.4;
  } else if (roll < 0.85) {
    // Kraliyet Koleksiyonu Çıkması
    baseValue *= 2.2;
  }
}
```

---

## 6. Sınırlar ve Kurallar • Boundaries

### Kesinlikle Yapılacaklar • Always Do
- Sıfır Unicode Emoji kuralı korunacak • Yalnızca VectorIconWidget veya native ikonlar kullanılacak.
- Sıfır Parantez kuralına titizlikle uyulacak • UI metinlerinde ` • ` veya ` - ` tercih edilecek.
- 7 dilde eşzamanlı yerelleştirme yapılacak • `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`.
- Neo-Brutalist görsel geometri korunacak • 2.0 - 3.0px siyah kenarlık, 0-blur ofset gölge.
- Değişiklikler ve test sonuçları `docs/FILE_CHANGELOG.md` dosyasına işlenecek.

### Önce Sorulacaklar • Ask First
- Bakiye 50 milyon TL altındaki oyunculara da düşük olasılıkla samanlık buluntusu hiper araç çıkması istenirse onay alınacak.
- Yeni bir bağımlılık veya paket ekleme ihtiyacı doğarsa danışılacak.

### Asla Yapılmayacaklar • Never Do
- Onaysız git push yapılmayacak.
- Mevcut testler geçersiz kılınmayacak veya silinmeyecek.
- Sabit Türkçe string'ler kod içerisine gömülmeyecek • Mutlaka lokalizasyon anahtarı tanımlanacak.

---

## 7. Başarı Kriterleri • Success Criteria

1. Kasasında 955M TL olan bir oyuncu pazarı yenilediğinde veya kaydırdığında her 10 - 15 araçlık grupta en az 1 adet 50M - 350M TL aralığında hiper araç üretilmelidir.
2. Bugaç, Köniğ, Pagan, Rolso ve Ferro özel modelleri `CarSpecifications` üzerinden gerçekçi teknik verilerle • beygir, tork, 0-100 beslenmelidir.
3. İlan kartında bu araçlar özel `ÖZEL HİPER KOLEKSİYON` rozetiyle parlamalı ve görsel hiyerarşide ayrışmalıdır.
4. 7 dil dosyasının tamamı yeni anahtarlarla eksiksiz donatılmalı ve hiçbir dilde eksik anahtar kalmamalıdır.
5. Yazılan yeni birim testi `flutter test test/unit/hyper_car_market_test.dart` ve projedeki tüm testler yeşil yanmalıdır.
