# GALERİSİNDEN: RADİKAL NEO-BRUTALİST, ENDÜSTRİYEL & RETRO-OTOMOTİV MAKSİMALİST UI/UX MİMARİ VE TASARIM RAPORU

---

## 1. YÖNETİCİ ÖZETİ & TASARIM FELSEFESİ

Mobil oyun ve simülasyon dünyasındaki standart, jenerik ve yumuşak (soft/pastel/glassmorphic) UI şablonlarını bütünüyle reddeden bu vizyon; **1980-90'lar Türk Oto Sanayi kültürü**, **İsviçre Tipografik Endüstriyel Baskı Mimarisi** ve **Maksimalist Neo-Brutalist Taktik Arayüz Fiziğini** tek bir potada eritir.

Amaç: Oyuncunun ekrandaki her karta dokunduğunda sanayideki bir takoz anahtarına basmış gibi hissetmesi, her ekspertiz raporunda resmi bir devlet mühürünün veya noter tasdiğinin ağırlığını görmesi, vitrindeki arabaların camındaki parlak sarı kelepir çıkartmalarının fiziksel gerçekliğini yaşamasıdır.

---

## 2. ÇEKİRDEK TASARIM DİREKTİFLERİ & MATEMATİKSEL İLKELER

### 2.1. Uncompromising Border & Shadow Architecture (Sıfır Yumuşatma)
- **Sert Dış Hatlar (Hard Outlines):** Tüm kartlar, butonlar ve rozetler minimum `2.5px`, maksimum `4.0px` kalınlığında saf karbon siyahı (`#000000` / `#0A0A0A`) katı kenarlıklarla çerçevelenir.
- **Sıfır Bulanıklık (Zero-Blur Hard Drop Shadows):** Hiçbir bileşende `blurRadius > 0` kullanılamaz. Gölgeler ışık kaynağına göre değil, mekanik izdüşüme göre `Offset(4.0, 4.0)` ila `Offset(6.0, 6.0)` katı siyah bloklar olarak çizilir.
- **Fiziksel Basılma Translasyonu (Click-Down Compression):** Dokunulduğu anda kart/buton tam olarak gölgenin başladığı koordinata doğru kayar (`Transform.translate(offset: Offset(3.0, 3.0))`) ve gölge ofseti `Offset(1.0, 1.0)`a düşerek mekanik bir butonun switch kapanışını simüle eder.

### 2.2. Retro-Otomotiv Tipografi & Veri Hiyerarşisi
- **Monolitik Başlıklar (Macro-Typography):** Fiyatlar, model adları ve bakiye göstergeleri `FontWeight.w900`, `letterSpacing: -0.5` ila `-1.2`, tamamen `BÜYÜK HARF` (UPPERCASE) olarak dizilir.
- **Sanayi Telemetrisi (Micro-Data Monospace):** Kilometre, tramer, şasi no, parça aşınma oranları ve motor kompresyon değerleri `JetBrains Mono` veya `Space Mono` benzeri teknik fontlarla, `[TRMR: ₺0]`, `<COMP: 94%>`, `REV#2024.08` gibi ASCII braketleri içinde gösterilir.
- **Dinamik Fiyat Etiketleri:** Vitrin araçlarında fiyatlar klasik oto pazarındaki gibi ön cama yapıştırılmış neon sarı/kırmızı çıkartmalar şeklinde hafif asimetrik açıyla (`Transform.rotate(angle: -0.035)`) yerleştirilir.

### 2.3. Sanayi & Galeri Tematik Dokuları
1. **Tehlike Şeritleri (Hazard Warning Stripes):** Yüksek kar marjlı kelepir fırsatlarda, ağır hasarlı araçlarda veya gece pazarı tekliflerinde `45°` açılı siyah-sarı (`#E5C158` - `#000000`) veya siyah-kırmızı (`#E61919` - `#000000`) emniyet şeritleri.
2. **Resmi Ekspertiz Damgaları (Rubber Ink Stamp Effects):** "BOYASIZ", "DEĞİŞENSİZ", "AĞIR HASARLI", "NOTER ONAYLI", "KELEPİR" gibi ibareler; `15°` eğik, kalın kırmızı/yeşil çerçeveli ve hafif pürüzlü damga mühürleri olarak araç detaylarının üzerine basılır.
3. **Nokta Izgara Arka Planı (Halftone Dot-Matrix Grid):** Kartların veya ekranların zemininde mikro noktalı teknik ızgara (dot-grid) deseniyle mühendislik ve çizim masası hissi uyandırılır.
4. **Koli Bandı & Etiket Efekti (Tape & Sticker Peel):** Modal başlıkları veya önemli uyarılar, kenarları tırtıklı şeffaf gri koli bandıyla yapıştırılmış gibi tasarlanır.

---

## 3. BİLEŞEN BAZLI GELİŞTİRME & FLUTTER UYGULAMA REÇETELERİ

### 3.1. `NeoBrutalStamp` (Ekspertiz ve Kelepir Damgası)
```dart
class NeoBrutalStamp extends StatelessWidget {
  final String text;
  final Color color;
  final double angle;

  const NeoBrutalStamp({
    super.key,
    required this.text,
    this.color = const Color(0xFFE61919),
    this.angle = -0.15,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3.0),
          borderRadius: BorderRadius.circular(4),
          color: color.withOpacity(0.08),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 1.5,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
```

### 3.2. `HazardStripePainter` (Sarı-Siyah Emniyet / Fırsat Şeridi)
```dart
class HazardStripePainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double stripeWidth;

  HazardStripePainter({
    this.color1 = const Color(0xFFE5C158),
    this.color2 = const Color(0xFF0F172A),
    this.stripeWidth = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = color1;
    final paint2 = Paint()..color = color2;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint1);

    final path = Path();
    for (double x = -size.height; x < size.width + size.height; x += stripeWidth * 2) {
      path.moveTo(x, size.height);
      path.lineTo(x + stripeWidth, size.height);
      path.lineTo(x + stripeWidth + size.height, 0);
      path.lineTo(x + size.height, 0);
      path.close();
    }
    canvas.drawPath(path, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### 3.3. `DotGridBackground` (Teknik Çizim Masası Zemin Deseni)
```dart
class DotGridBackground extends StatelessWidget {
  final Widget child;
  final Color dotColor;
  final double spacing;

  const DotGridBackground({
    super.key,
    required this.child,
    this.dotColor = const Color(0x1FFFFFFF),
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotGridPainter(dotColor: dotColor, spacing: spacing),
      child: child,
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;

  _DotGridPainter({required this.dotColor, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

---

## 4. OYUN EKRANLARI İÇİN MAKSİMALİST REVİZYON YOL HARİTASI

| Ekran | Mevcut Durum | Abartılmış Neo-Brutalist & Endüstriyel Dokunuş |
|---|---|---|
| **Showroom (Vitrin)** | Temiz araç kartları, standart rozetler | Ön camda asimetrik sarı oto pazarı fiyat bandı, 5px sert gölge, "KELEPİR" / "KOLEKSİYON" damgaları, sol kenarda mekanik durum renk çubuğu |
| **Marketplace (İlanlar)** | Liste filtreleme ve kart yapısı | Gazete/Sarı Sayfalar ilan kupürü dokusu, kesik makbuz kenarlıkları, ilan aciliyetini belirten sarı-siyah tehlike şeritleri |
| **Expertise (Ekspertiz)** | 2D araba hasar şeması ve barlar | 1990 sanayi ekspertiz formu estetiği, kırmızı mühür damgaları ("KUSURSUZ", "DEĞİŞEN VAR"), daktilo/monospace parça raporu dökümü |
| **Workshop (Tamirhane)** | İstasyon kartları ve onar butonları | Ağır sanayi alet kutusu hissi, vida/civata görsel köşe aksanları, yağ lekesi/işaretçi telemetry etiketleri, tamir tamamlandığında yeşil sanayi mühürü |
| **Night Market (Gece Pazarı)** | Koyu kartlar ve geri sayım | Koyu CRT terminal monitörü, yeşil fosforlu dijital sayaç (`00:42:15`), gizli kelepir araçlarda siyah-kırmızı alarm şeritleri |
| **HUD / Üst Panel** | Kompakt bakiye ve gün göstergesi | Analog takometre ve mekanik sayaç tarzı rakamlar, basılabilir fiziksel galeri tabelası rozetleri |

---

## 5. DOKUNSAL (HAPTIC) VE İŞİTSEL MİKRO-ETKİLEŞİMLER
1. **Ağır Basma Hissi (Heavy Haptic Click):** Her buton basımında `HapticFeedback.heavyImpact()` veya çift hafif titreşimle mekanik buton anahtarı (mechanical switch) hissi.
2. **Yaylı Animasyonlar (Spring Curves):** Modal açılışlarında `Curves.elasticOut` veya `Curves.easeOutBack` kullanılarak kartların bir zıplama/çarpma tokluğuyla ekrana oturması.
3. **Sürükle-Bırak & Çift Dokunma İmzası:** Teklif kabul etme veya satış tamamlama anında noter damgası basılma animasyonu (`ScaleTransition` 1.4x -> 1.0x slam + haptic).
