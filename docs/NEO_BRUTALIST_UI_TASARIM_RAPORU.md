# ⚡ Galeriden — Seçici ve Dinamik Neo-Brutalist Tasarım Sistemi Raporu

**Hazırlayan:** UI/UX Design Specialist  
**Yaklaşım:** Selective & Dynamic Neo-Brutalism (Seçici Maksimalizm)  
**Hedef:** Oynanış akıcılığını ve okunabilirliği korurken, oyunun kritik zafer ve etkileşim anlarında deneyimi "epik" bir görsel şölene dönüştürmek.

---

## 🎯 1. Tasarım Vizyonu & Felsefesi

Neo-Brutalizm, Galeriden'in Türkiye otomotiv ve sanayi alt kültürüne dayanan esprili ve rekabetçi ruhunu yansıtan en büyük görsel imzasıdır. Ancak her ekranda aşırı kalın çizgiler ve sürekli bağıran öğeler kullanmak ("tekdüze maksimalizm") oyuncuyu 10 dakika içinde zihinsel olarak yorar ve küçük ekranlarda veri takibini zorlaştırır.

Bu nedenle sistemimizi **İki Katmanlı Tasarım Mimarisi (2-Tier UI Architecture)** üzerine kuruyoruz:

```
┌────────────────────────────────────────────────────────┐
│   TIER 2: EPİK ZAFER & AKSİYON KATMANI                 │
│   (Vurgun Damgaları, Ekran Sarsıntıları, Stickerlar)   │
├────────────────────────────────────────────────────────┤
│   TIER 1: TABAN & VERİ KATMANI                         │
│   (Temiz Neo-Brutalizm, Yüksek Kontrast, Net Tipografi)│
└────────────────────────────────────────────────────────┘
```

---

## 🧱 2. İki Katmanlı Tasarım Mimarisi (2-Tier Architecture)

### Tier 1: Taban & Veri Katmanı (Clean & High-Contrast Neo-Brutalism)
Oyuncunun borsa, ekspertiz raporu, araç listesi ve finansal tabloları analiz ettiği standart ekranlar.

- **Çerçeveler:** 2px net siyah sınır (`border: 2px solid #18181B`).
- **Gölgeler:** Sert, bulanıklıksız gölgeler (`box-shadow: 3px 3px 0px #18181B`).
- **Tipografi:** Başlıklarda cesur ve kompakt sans-serif fontlar, veri ve sayılarda monospaced yüksek okunurluklu rakamlar.
- **Renk Dağılımı:** %70 Dingin Zemin (Off-white `#FFFDF5` / Koyu Mod `#121216`), %20 Kart Yüzeyleri, %10 Vurgu Renkleri.

### Tier 2: Epik Aksiyon & Zafer Katmanı (Street Brutalist Explosions)
Kullanıcının başarı elde ettiği, risk aldığı veya dönüm noktasına ulaştığı anlarda patlayan dinamik görsel katman.

- **Vurgun & Kelepir Damgaları:** 12-15 derece eğimli, kalın konturlu, kabartmalı neon kaşeler.
- **Dokunsal Geri Bildirim (Tactile Physics):** Butona basıldığında gölgenin içine doğru 3px çökme (`transform: translate(3px, 3px)`).
- **Zafer Anı Partikülleri:** Standart yuvarlak konfetiler yerine geometrik liralar, lokma anahtarlar ve hız ibresi parçacıkları.
- **Ekran Titreşimi (Screen Juice / Micro-Shake):** Jackpot satışlarda veya çek patladığında 150ms'lik hafif fiziksel sarsıntı.

---

## 🎨 3. Tasarım Token'ları ve Renk Paleti (Design Tokens)

### Ana Renk Paleti
| Token Adı | HEX Kodu | Kullanım Alanı |
|---|---|---|
| `--color-cyber-yellow` | `#FFE600` | Ana aksiyon butonları, kelepir etiketleri |
| `--color-neon-green` | `#00E676` | Kârlı satışlar, onay damgaları, borsa yükselişi |
| `--color-danger-red` | `#FF1744` | Ağır hasar, borç uyarıları, riskli kararlar |
| `--color-turbo-cyan` | `#00E5FF` | Ekspertiz raporları, tuning, VIP müşteri |
| `--color-ink-black` | `#18181B` | Konturlar, sert gölgeler, ana metinler |
| `--color-paper-white` | `#FFFDF5` | Arka plan, nefes alan temiz alanlar |

### Tipografi Ölçeği
- **Hero / Zafer Başlıkları:** 32px – 40px, Extra Bold, Uppercase (Bebas / Montserrat Black)
- **Kart Başlıkları:** 18px – 20px, Bold
- **Finansal Rakamlar:** 16px – 22px, Semi-Bold Monospace (₺ formatında)
- **Gövde Metni:** 14px, Regular (Okunabilir, 1.4 satır yüksekliği)

---

## 🏆 4. Epik Anlar & Özelleştirilmiş Komponentler

### 1. Sokak Stili Dinamik Kaşe & Damga Sistemi (Stamp System)
Pazarlık bittiğinde, araç listelendiğinde veya satıldığında ekranın ortasına animasyonla inen damgalar:

- 🟢 **"VURGUN YAPILDI"**: %35+ kârla araç satıldığında altın/yeşil parıltılı damga.
- 🔴 **"KELEPİR YAKALANDI"**: Piyasa değerinin %25 altına araç alındığında kırmızı mühür.
- 🟡 **"ÇITIR HASARLI"**: Ekspertizde sadece tampon boyalı araçlar için esprili sanayi rozeti.
- 🔵 **"DOKTORDAN / MEMURDAN"**: Düşük kilometreli hatasız araç kartlarında retro emaye plaka.
- 🟣 **"NOTER ONAYLI"**: Ruhsat devri ve büyük satış tamamlandığında resmi noter mührü animasyonu.

### 2. İnteraktif Pazarlık Masası (High-Stakes Negotiation UI)
- Müşteri teklifi kabul ettiğinde ekranın üstünden **"EL SIKIŞTIK! 🤝"** retro neon tabelası iner.
- Müşteri masadan kalktığında **"KAPIDAN DÖNDÜ! 🚪"** kırık cam çatlak efekti ve ses efekti.

### 3. Sanayi & Restorasyon Muayene İstasyonu (Workshop Re-design)
- Hurdalık aracı (Barn Find) baştan sona toplandığında **Önce / Sonra** polaroid kartları birbirine vurarak açılır.
- Aracın üzerine **"SIFIR GİBİ / MUAYENEDEN GEÇTİ"** yeşil hologramik bandrol yapışır.

### 4. Gün Sonu Kasa Raporu (Daily Cashflow Receipt)
- Basit bir tablo yerine market kasasından çıkan **uzun perforeli fiş (Thermal Receipt)** görünümünde kayan neo-brutalist bülten.
- En kârlı satışın altında kalın fosforlu kalemle çizilmiş gibi sarı vurgu çizgisi.

---

## 📱 5. Mobil Ergonomi & WCAG AA Standartları

1. **Dokunma Hedefleri (Touch Targets):** Tüm aksiyon butonları minimum 48x48 dp boyutunda tutulacak.
2. **Kontrast Oranı:** Tüm metin ve zemin kombinasyonları en az **4.5:1** (büyük başlıklarda **7:1+**) kontrast sağlayacak.
3. **Performans (60 FPS):** Ağır gölgeler yerine vektörel `CustomPainter` ve GPU dostu `Transform` matrisleri kullanılacak; pil ve işlemci dostu kalacak.
4. **Haptic & Ses Uyumu:** Her epik damga inişinde 15ms'lik keskin dokunsal geri bildirim (Heavy Impact Haptic) tetiklenecek.

---

## 🚀 6. Uygulama Yol Haritası (Implementation Roadmap)

1. **Adım 1:** Ortak `NeoBrutalStamp` ve `JuicyBounceOverlay` widget'larının oluşturulması.
2. **Adım 2:** Pazarlık ve Satış başarı ekranlarına dinamik damga tetikleyicilerinin bağlanması.
3. **Adım 3:** Hurdalık restorasyon tamamlama ve Gün sonu fiş raporunun yeni tasarıma kavuşturulması.
4. **Adım 4:** Ses ve haptic geri bildirimlerin epik anlarla tam senkronize edilmesi.
