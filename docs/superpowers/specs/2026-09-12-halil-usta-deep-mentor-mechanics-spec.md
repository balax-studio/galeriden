# Spec: Halil Usta Akıllı Mentor Derinlik Mekaniği (§SPEC-2026-09-12-HALIL-USTA-DEEP-MENTOR)

## Objective
Halil Usta mentor mekaniğini statik bir if-else yönlendirmesinden çıkarıp; dinamik fayda skorlama motoru (utility-based scoring), kalıcı usta hafızası (mentor memory state), 7 dilli çoklu diyalog havuzu (anti-fatigue dialogue), 4 duygu moduna sahip prosedürel piksel avatarı, kritik kriz anları için analog CRT glitch efekti ve usta anlatı görevleri (narrative side quests) ile tam teşekküllü, yaşayan bir esnaf ortağına dönüştürmek.

---

## Capability Map (Phase 0)

| Modül ID | Sorumluluk | Bağımlılık |
|---|---|---|
| `mentor-core-scoring` | Fayda tabanlı dinamik skorlama (utility-based scoring), yorulma sönümlemesi ve mentorHistory kalıcı durum modeli | DealershipModel |
| `mentor-visual-shaders` | 4 farklı duygu haline (proud, worried, clever, teaSip) sahip PixelMentorAvatar ve acil durumlarda analog CRT glitch / kromatik sapma | PixelMentorAvatar, CrtScanlinesOverlay |
| `mentor-dialogue-variety` | 7 dilde her tavsiye için en az 3 varyantlı esnaf aforizma havuzu (sıfır emoji, sıfır parantez) | AppLocalizations, 7 çeviri dosyası |
| `mentor-narrative-quests` | Halil Usta'nın kişisel anlatı görevleri (Hurda Klasik Restorasyonu, Parça Arayışı, Kelepir Avcısı) ve ödül sistemi | mentor-core-scoring |

İnşa Sırası: mentor-core-scoring → mentor-dialogue-variety → mentor-visual-shaders → mentor-narrative-quests

---

## 1. Modül: mentor-core-scoring (Fayda Tabanlı Dinamik Skorlama & Hafıza)

### 1.1. Dinamik Fayda Skorlaması (Utility-Based Scoring)
Mevcut katı if-else merdiveni yerine her tavsiye adayı için 0.0 ile 1.0 arasında bir dinamik fayda skoru (utilityScore) hesaplanır:
- `stuckBrokeNoCar`: Nakit < 25.000 TL ve 0 araç → Skor: 1.00 (Kritik Modal).
- `debtInstallmentWarning`: Yaklaşan taksit nakitten büyükse → Skor: 0.95 (Kritik Modal); aksi halde gün % 3 == 0 ve nakit < 50.000 TL ise → Skor: 0.70.
- `branchUpgradedCelebration`: Şube yeni kutlandıysa → Skor: 0.90 (Kritik Modal).
- `featureUnlocked`: Yeni açılan tesis rota başına → Skor: 0.82.
- `bargainMarketRadar`: Fiyat <= %75 rayiç ve nakit yetiyorsa → Skor: 0.85.
- `unofferedListingStale`: 2 günden uzun süredir ilanda ve 0 teklif → Taban Skor: 0.75.
- `stuckNoListing`: Garajda araç var ama vitrinde ilan yok → Skor: 0.72.
- `branchUpgradeReady`: Kasa ve seviye bir sonraki şubeye yetiyorsa → Skor: 0.68.
- `stuckOverpriced`: Araç rayicinin %25 üstündeyse → Skor: 0.65.
- `idleCashSurplus`: Kasa >= 150.000 TL ve boş slot var → Skor: 0.58.
- `damagedCarRepairOpportunity`: Hasarlı araç ve atölye açık → Skor: 0.50.
- `dirtyCarValueLoss`: Kirli araç ve yıkama açık → Skor: 0.45.
- `rivalDominanceNudge`: Liderlik hatırlatması → Skor: 0.35.

### 1.2. Yorulma ve Tekrar Sönümlemesi (Fatigue Damping)
Bir tavsiye türü dün gösterildiyse ve oyuncu aksiyon almadıysa:
- Skor her tekrar eden gün için %20 sönümlenir (utilityScore *= 0.80).
- Böylece teklif almayan bir ilan arka arkaya 2 gün gösterildikten sonra skoru 0.75 → 0.60 → 0.48'e geriler; bu sırada pazara düşen 0.85 skorlu kelepir araç veya şube yükseltmesi ekranı devralabilir.

### 1.3. Usta Hafıza Durumu (MentorMemoryModel)
`DealershipModel` içinde `mentorMemory` alanı eklenir:
- `lastAdvisedType`: En son gösterilen tavsiye türü adı.
- `lastAdvisedDay`: Tavsiyenin verildiği oyun günü.
- `consecutiveDays`: Bu tavsiyenin art arda kaç gündür verildiği.
- `ignoredBargainCarNames`: Oyuncunun uyarılmasına rağmen almadığı kelepir araçlar.
- `warnedOverpricedCarIds`: Oyuncunun pahalıya ilan verip ısrar ettiği araçlar.
- `completedNarrativeQuestIds`: Tamamlanan Halil Usta görevleri.

---

## 2. Modül: mentor-dialogue-variety (7 Dilli Çoklu Diyalog Havuzu)

Her tavsiye türü için 3'er varyant oluşturulur (_v1, _v2, _v3). Seçim (currentDay + adviceType.index) % 3 veya consecutiveDays sayacına göre dinamik belirlenir:
- **Varyant 1 (İlk Uyarı - Nazik Esnaf Dili)**: "Evlat vitrinde bekleyen mal para getirmez, şu ilana bir el atalım."
- **Varyant 2 (İkinci Gün - Hafif İğneleyici Esnaf Tecrübesi)**: "Bizim araba vitrinde rafta toz tuttu, piyasa fiyatına çekmezsek alıcı kaçacak."
- **Varyant 3 (Üçüncü Gün - Net ve Taktiksel)**: "Bekleyen mal sermayeyi kilitler. Ya fiyatı kır ya vitrin reklamıyla müşteri çağır!"

Desteklenen diller: tr, en, de, pt, es, ru, ar.
Tüm metinlerde Değişmez Kural 1 (Sıfır Emoji) ve Değişmez Kural 2 (Sıfır Parantez) tam uygulanır.

---

## 3. Modül: mentor-visual-shaders (4 Duygu Modu & Analog CRT Glitch)

### 3.1. 4 Duygu Modu (MentorMood)
PixelMentorAvatar içine MentorMood mood parametresi eklenir:
1. `MentorMood.proud` (Keyifli / Gururlu): Bıyık uçları yukarı kıvrık, gözlükte beyaz parıltı, gözler güler yüz formunda. (branchUpgradedCelebration, şube atlama, karlı satışlar).
2. `MentorMood.worried` (Endişeli / Düşünceli): Kaşlar çatık, alın çizgisi pikselleri, hafif aşağı sarkık bıyık. (stuckBrokeNoCar, debtInstallmentWarning, stuckOverpriced).
3. `MentorMood.clever` (Uyanık / Kurnaz): Sağ göz kırpma, sol gözde altın renkli parıltı. (bargainMarketRadar, idleCashSurplus).
4. `MentorMood.teaSip` (Çay İçme & Rahat): Sağ tarafta ince belli çay bardağı tutuşu ve keyifli esnaf pozu. (stuckNoListing, dirtyCarValueLoss, rölanti durumları).
5. `MentorMood.neutral`: Klasik mevcut duruş.

### 3.2. Analog CRT Glitch & Renk Sapması (Chromatic Aberration)
Kritik kriz tavsiyelerinde (isCriticalModal == true veya type == stuckBrokeNoCar || type == debtInstallmentWarning):
- PixelMentorAvatar ve CrtScanlinesOverlay üzerine hafif yatay çizgi kayması (sin(phase * 15) * 2.0px) uygulanır.
- Çerçeve kenarlarında hafif kırmızı/mavi renk ayrışması yapılarak acil telsiz anonsu hissi verilir.

---

## 4. Modül: mentor-narrative-quests (Halil Usta Anlatı Görevleri)

Oyuncunun usta ile bağını güçlendiren hikayeli görevler:
1. `m_quest_halil_heritage_restore`: "Eski Dostun Yadigarı" • Hurdalıktan veya pazardan eski model bir aracı alıp motor ve kaportasını %85 üzerine çıkar.
2. `m_quest_halil_bargain_sniper`: "Piyasa Kurdu" • Halil Usta'nın radarına giren 2 kelepir aracı değerinin %75 altına yakala.
3. `m_quest_halil_tea_hospitality`: "Esnaf Bereketi" • Halil Usta'ya 3 gün boyunca çay ısmarlayarak atölye işçilik indirimini aç.

---

## Success Criteria
1. SmartMentorEngine.evaluateAdvice katı if-else yerine tüm adayları skorlayıp en yüksek skoru seçer.
2. Dün gösterilen ve aksiyon alınmayan tavsiyeler %20 sönümlenir, böylece yeni fırsatlar öne geçer.
3. dealership_model.dart içindeki mentorMemory alanı durumu kalıcı kaydeder ve test izolasyonunda sorunsuz serileşir.
4. PixelMentorAvatar 4 duygu modunu (proud, worried, clever, teaSip) 16x16 matris üzerinde piksel doğruluğuyla çizer.
5. Kritik uyarılarda CRT glitch efekti çalışır.
6. 7 dilde her tavsiye için en az 3'er varyant sıfır emoji ve sıfır parantez ile sunulur.
7. Tüm testler (flutter test) ve statik analiz (flutter analyze) 0 hata ile geçer.
