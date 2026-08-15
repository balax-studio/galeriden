# Galerisinden — Mantık Hatası Raporu

**Kapsam:** Yalnızca rapor. Kod değiştirilmedi.
**Not:** Köken ve Uzmanlık Yolu sistemleri bu oturumda ilk kez derinlemesine incelendi — önceki raporlarda önerdiğim RPG sistemleri gerçekten uygulanmış. Ama uygulamanın kendisinde ciddi bir mantık hatası var.

---

## ⭐ Ana Bulgu: Kalıcı Karar, Üç Farklı Yalan Üzerine Kuruluyor

**Dosyalar:** [dealership_model.dart:195-247](lib/data/models/dealership_model.dart:195), [dealership_identity_screen.dart:39-68](lib/presentation/screens/settings/dealership_identity_screen.dart:39), [character_growth_screen.dart:369-395](lib/presentation/screens/character/character_growth_screen.dart:369), [game_inventory_mixin.dart:70-163](lib/presentation/providers/game/game_inventory_mixin.dart:70)

Oyunda iki **geri alınamaz** karar var: Köken (oyun başında) ve Uzmanlık Yolu (Seviye 4'te, `chooseSpecialization` — geri alma fonksiyonu yok). Sorun: oyuncuya bu kararı anlatan metin **üç farklı yerde, üç farklı şekilde yazılmış** ve kodun kendisi bunların hiçbirini tam karşılamıyor.

### Uzmanlık Yolu — üç kaynak, tek gerçek

| | Model metni | Seçim ekranı metni | Kodda gerçekten olan |
|---|---|---|---|
| **Restoratör** | %100 onarım başarısı, +%25 değer, ×2 nadir parça şansı | Tamir −%20, Katma değer +%25, Montaj başarısı +%20 | **Yalnızca −%20 tamir maliyeti** |
| **Tüccar** | +2 pazarlık hakkı, müşteri niyetini bilme, −%10 alım | Alım −%10, Kabul oranı +%15, Doping ×1.5 | **Yalnızca −%10 alım fiyatı** |
| **Patron** | Yan işletme +%30, maaş −%20, +2 garaj slotu | Maaş −%20, İşletme +%30, Şube indirimi −%25 | **Yalnızca maaş −%20 + işletme +%30** (2/3) |

Üç yoldan **ikisinde** (Restoratör, Tüccar) vaat edilen 3 perk'ten yalnızca 1'i gerçek. Patron'da 2'si gerçek ama üçüncüsü iki metinde bile **farklı şeyler söylüyor** (garaj slotu vs. şube indirimi) — ve ikisi de kodda yok. Yani seçim ekranını yazan kişi, modelin kendi açıklama fonksiyonunu bile referans almamış; sıfırdan, tutarsız bir metin yazmış.

### Köken — bir seçenek tamamen boş

| Köken | Vaat edilen (enum yorumu) | Kodda olan |
|---|---|---|
| Sanayi Çırağı | Onarım −%15 + **başlangıç ekspertiz +2** | Yalnızca −%15 onarım |
| Tüccar Torunu | Alım −%8 + **başlangıç pazarlık +2** | Yalnızca −%8 alım |
| Şehirli Yatırımcı | **Başlangıç sermayesi ₺150.000** + banka faizi −%20 | Yalnızca banka faizi −%20 (bakiye hep ₺75.000'de sabit) |
| **Koleksiyoncu Yeğeni** | Miras nadir araç + değer +%20 + gider +%25 | **Hiçbir şey — sıfır kod etkisi** |

`setCharacterOrigin()` fonksiyonu yalnızca `characterOrigin` alanını set ediyor; bakiyeye, envanterken hiçbir şeye dokunmuyor. Koleksiyoncu Yeğeni'ni seçen bir oyuncu, dört seçenekten **kozmetik dışında hiçbir gerçek fark taşımayan** birini seçmiş oluyor — ve bunu asla öğrenemez, çünkü hiçbir hata mesajı yok, sadece sessiz eksiklik.

### Neden bu, önceki "vaat-ödül uyumsuzluğu" bulgularından daha ciddi

Dramatik Kartlar'daki benzer sorun (Aile Yadigârı rozeti, zam sözü) **tek seferlik olaylardı** — kart bir kez oynanır, unutulur. Bu ise oyuncunun **tüm oyun boyunca kimliğini tanımlayan, geri alınamaz** iki karardan biri. Yanlış bilgiyle verilen, geri dönüşü olmayan bir karar — RPG'nin "seçimlerin anlamı var" ilkesini doğrudan baltalıyor.

---

## Diğer Mantık Hataları

### İki farklı arayüz, aynı model alanı için farklı gereksinim metni yazıyor

`dealership_model.dart` içindeki `specializationDescription` (kilit ekranı için) *"Seviye 4 **veya 5**'e ulaştığında"* diyor. Ama gerçek koşul (`chooseSpecialization`, `character_growth_screen.dart`) net biçimde `level >= 4`. "4 veya 5" ifadesi belirsiz ve yanlış — oyuncu 5. seviyeyi beklemesi gerektiğini düşünebilir.

### `originBonusDescription` hiçbir ekranda gösterilmiyor

Model içindeki bu getter ve `specializationDescription`'ın "vaat" kısmı, tabloda görüldüğü gibi zaten yanlış — ama daha da ilginci, bu iki getter'ın **hiçbiri** hiçbir ekrandan çağrılmıyor (yalnızca kendi içinde `switch` yapıyorlar). Yani bu yanlış metinler bile oyuncuya gösterilmiyor; oyuncunun gördüğü yalnızca `character_growth_screen.dart` ve `dealership_identity_screen.dart`'taki **ayrı, kendi başına yazılmış** üçüncü metin seti. Üç kopya metin, üçü de birbirinden bağımsız evrilmiş, hiçbiri kodla senkron değil.

---

## Öncelik

| # | Sorun | Etki |
|---|---|---|
| 1 | Koleksiyoncu Yeğeni kökeni tamamen etkisiz | Bir seçenek bütünüyle sahte |
| 2 | Uzmanlık yolu perk'lerinin %70'i uygulanmamış | Kalıcı kararın vaadi tutulmuyor |
| 3 | Üç bağımsız, tutarsız metin kaynağı | Kaynak zaten belirsiz, düzeltme tek yerden yapılamıyor |
| 4 | "Seviye 4 veya 5" belirsizliği | Küçük ama kafa karıştırıcı |

**Düzeltme yönü:** Tek doğruluk kaynağı `dealership_model.dart`'taki getter'lar olmalı; her iki ekran da (`dealership_identity_screen.dart`, `character_growth_screen.dart`) kendi metnini yazmak yerine bu getter'ları çağırmalı. Ardından getter metni, gerçekte kodda uygulanan etkiyle eşleşecek şekilde ya sadeleştirilmeli ya da eksik perkler gerçekten uygulanmalı.

---

*Kod okumasına dayanır. Hiçbir dosya değiştirilmedi.*
