# Galeriden Tycoon - Dokunsal Animasyonlar, İşlem Süreleri ve Noter Kaşe Mimarisi Tasarım Spesifikasyonu

**Tarih:** 08.09.2026  
**Durum:** Onaylandı / Tasarım Aşamasında  
**Hedef:** Oyunda anında gerçekleşen 6 ana sistem eylemine 1.2 - 2.5 saniyelik dokunsal mikro animasyonlar, sesler, haptik titreşimler ve gerilim aşamaları ekleyerek simülasyon gerçekçiliğini ve tatmin hissini zirveye çıkarmak.

---

## 1. Mimari Genel Bakış ve Birleşik Dokunsal Suspense Sistemi

Oyundaki tüm eylemler mevcut `OperationSuspenseEngine` ve `NeoBrutalOperationDialog` mimarisine bağlanacak, araç alım-satım ve resmi devir aşamaları ise `NotaryTransferDialog` içindeki resmi damga mührü ile birleştirilecektir.

```
+-------------------------------------------------------------------------+
|                  NeoBrutalOperationDialog (2.0s - 2.5s)                 |
|  +-------------------------------------------------------------------+  |
|  | Başlık: [Sistem Adı] • Rozet: [Durum]                             |  |
|  | Dinamik İlerleme Çubuğu & Aşamalı Metinler (Stage 1 -> 2 -> 3)    |  |
|  | HapticFeedback (Selection Click -> Medium -> Heavy Impact)        |  |
|  | Ses Efektleri (GameSoundHapticService)                             |  |
|  +-------------------------------------------------------------------+  |
+-------------------------------------------------------------------------+
       |                  |                   |                  |
       v                  v                   v                  v
 [Tamirhane]         [Oto Yıkama]       [Ekspertiz/Dyno]     [Hurdalık]
 Motor/Mekanik       Müşteri Talepleri  TSE Rapor Açılışı    Komple Söküm
 & Kaporta Onarımı   & Hızlı Detailing  & Dyno Ölçümü        & Presleme
```

```
+-------------------------------------------------------------------------+
|                  NotaryTransferDialog (1.2s Elastik Kaşe)               |
|  +-------------------------------------------------------------------+  |
|  | Resmi Araç Satış Sözleşmesi Kartı                                 |  |
|  | 1.2s Elastik Yay Animasyonu (CurvedAnimation / Curves.elasticOut) |  |
|  | Kırmızı/Siyah "ONAYLANDI - DEVİR TAMAMLANDI" Noter Kaşesi Mührü   |  |
|  | GameSoundHapticService.playNotaryStamp() + HapticFeedback.heavy() |  |
|  +-------------------------------------------------------------------+  |
+-------------------------------------------------------------------------+
       |                                          |
       v                                          v
 [Vasıta Satın Alma Noter Masası]           [Galeri Vitrin Teklif Kabulü]
 vasita_negotiation_screen.dart             showroom_offers_tab.dart
```

---

## 2. Kapsanan 6 Sistem ve Uygulama Detayları

### 1. Noter Satış ve Resmi Devir Masası
* **Mevcut Sorun:** Vasıta pazarında pazarlık bittiğinde açılan devir onayı sade bir `AlertDialog` kullanıyor ve anında devrediyor.
* **Tasarım:** 
  - `vasita_negotiation_screen.dart` içindeki `_showHandoverConfirmationDialog` kaldırılacak veya `NotaryTransferDialog.show` ile güçlendirilecek.
  - Alıcı ve satıcı bilgileri, plaka, şasi numarası ve satış bedeli resmi sözleşme kağıdı üzerinde sunulacak.
  - 1.2 saniyelik elastik "ONAYLANDI - DEVİR TAMAMLANDI" noter mührü tok bir ses ve sert bir haptik titreşimle kağıda inecek.

### 2. Tamirhane ve İstasyon Onarımları
* **Mevcut Sorun:** `workshop_garage_repairs_tab.dart` içindeki motor, şanzıman, kaporta ve periyodik bakım butonları veritabanını anında güncelleyip direkt başarı tostu atıyor.
* **Tasarım:**
  - Butona tıklandığında `NeoBrutalOperationDialog.show` devreye girecek.
  - `OperationSuspenseType.workshopRepair` ve `workshopMaintenance` tipleri kullanılacak.
  - 3 Aşamalı Akış:
    1. Aşama: Hidrolik Lift Aracı Kaldırıyor • Teşhis Başladı
    2. Aşama: Cırcır ve Tork Anahtarı Sıkılıyor • Parça Revizyonu
    3. Aşama: Yağ Seviyesi ve Basınç Test Edildi • Tamir Tamamlandı
  - Tamamlanınca araç kondisyonu güncellenecek, kondisyon artış rozeti parlayacak.

### 3. Oto Yıkama ve Detailing İstasyonu
* **Mevcut Sorun:** Müşteri yıkama talepleri tek tıkla tamamlanıyor.
* **Tasarım:**
  - `car_wash_screen.dart` içindeki `_customerWashJobs` yıkama butonları `NeoBrutalOperationDialog.show` ile bağlanacak.
  - İlgili paket türüne göre (`washFoam`, `washInterior`, `washPolish`, `washCeramic`) aşamalı köpük, su jeti ve mikrofiber parlatma sekansı oynatılacak (2.0 saniye).
  - İşlem sonunda müşteri ödemesi kasaya aktarılacak ve başarı bildirimi verilecek.

### 4. Ekspertiz ve Dyno Testi
* **Mevcut Sorun:** İlan detay ekranında veya pazarda ekspertiz raporu butonuna basıldığı an alttan sheet doğrudan açılıyor, hiçbir gerilim kalmıyor.
* **Tasarım:**
  - `listing_detail_screen.dart` ve `vasita_market_screen.dart` üzerinden rapor açılırken `OperationSuspenseType.expertiseInspection` ile 2.5 saniyelik dyno sekansı başlatılacak.
  - 3 Aşamalı Akış:
    1. Aşama: Dyno Silindirleri Hızlanıyor • Motor Gücü Ölçülüyor
    2. Aşama: Mikron Boya Probu Kaportayı Taramakta • Tramer Sorgulanıyor
    3. Aşama: TSE Onaylı Rapor Kalibre Edildi • Mühür Basıldı
  - Sekans bittiğinde `ExpertiseReportSheet` ekranı tüm verileriyle oyuncunun önüne açılacak.

### 5. Hurdalık Presi ve Parça Sökümü
* **Mevcut Sorun:** Hurdalıkta `buyAndDismantleScrapCar` (komple parça sökümü) anında envantere parçaları aktarıyor.
* **Tasarım:**
  - `scrapyard_scrap_cars_tab.dart` butonuna `OperationSuspenseType.scrapyardDismantle` bağlanacak.
  - 3 Aşamalı Akış (2.5 saniye):
    1. Aşama: Vinç Aracı Söküm Bandına İndiriyor
    2. Aşama: Pnömatik Kesiciler ve Spiral Taşlama Devrede
    3. Aşama: Çıkma Parçalar Envantere Ayrıştırıldı
  - İşlem tamamlandığında çıkan sağlam parçalar dökülecek.

### 6. Tuning ve Modifiye Stüdyosu
* **Mevcut Sorun:** Stage yazılım ve modifiye parçaları takılırken kullanıcıya daha derin bir dyno eğrisi tatmini sunulmalı.
* **Tasarım:**
  - `tuning_studio_screen.dart` içindeki `OperationSuspenseType.tuningPowertrain` ve `tuningPreset` akışı doğrulanacak, ECU yazılım haritası yükleme çubuğu ve dyno tekerlek ivmelenme haptikleri eksiksiz çalıştırılacak.

---

## 3. Kurallar ve Kısıtlamalar
1. **Sıfır Unicode Emoji:** Sadece `VectorIconWidget`, `IconData` veya `AvatarIconWidget` kullanılacak.
2. **Sıfır Parantez:** UI metinlerinde `(...)` kesinlikle olmayacak, ` • ` veya ` - ` formatı kullanılacak.
3. **Eşzamanlı 7 Dilde Senkronizasyon:** `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar` dillerinde tüm yeni anahtarlar eksiksiz tanımlanacak.
4. **Dosya Değişiklik Takibi:** Yapılan tüm işlemler `docs/FILE_CHANGELOG.md` dosyasına kaydedilecek.
