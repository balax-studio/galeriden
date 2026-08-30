# Spec: In-Universe Narrative & Lore Refinement for Rush Training (Staff Academy)

## Objective
Transform the raw, utilitarian "Reklam İzle" (Watch Ad) phrasing in the Staff Academy rush diploma system into an immersive, in-universe automotive story ("Otomotiv Sanayi Odası • Hızlandırılmış Burs ve Seminer Programı").
This makes the reward mechanic feel natural, prestigious, and lore-grounded rather than immersion-breaking, while maintaining 100% functionality and full 7-language synchronization.

---

## In-Game Lore & Narrative Context
- **Kurum**: *Otomotiv Sanayi & Ticaret Odası* (Automotive Chamber of Commerce & Industry)
- **Hikaye (Lore)**: Otomotiv Sanayi Odası, sektördeki nitelikli usta ve uzman personel ihtiyacını karşılamak amacıyla yetkili kurumsal iş ortaklarıyla **"Hızlandırılmış Burs ve Yoğunlaştırılmış Seminer Programı"** sunmaktadır.
- **Akış**: Kursiyerin kalan eğitim günlerini sıfırlamak için sponsorlu kısa bir sektörel tanıtım/sunum izlenir. Sponsorluk onayı ile personelin ustalık diploması anında teslim edilir.

---

## 7-Language Key Mapping

### 1. `rush_training_dialog_title`
- **TR**: `ÖZEL SANAYİ SEMİNERİ`
- **EN**: `INDUSTRY SEMINAR GRANT`
- **DE**: `INDUSTRIESEMINAR-STIPENDIUM`
- **PT**: `BOLSA DE SEMINÁRIO INDUSTRIAL`
- **ES**: `BECA DE SEMINARIO INDUSTRIAL`
- **RU**: `СТИПЕНДИЯ ОТРАСЛЕВОГО СЕМИНАРА`
- **AR**: `منحة الندوة المهنية`

### 2. `rush_training_dialog_desc`
- **TR**: `Otomotiv Sanayi Odası ve iş ortaklarımızın sponsorluk desteğiyle, personeliniz için yoğunlaştırılmış seminer düzenlenir. Kısa bir sponsorluk sunumu eşliğinde eğitim tamamlanarak diploma anında teslim edilir.`
- **EN**: `With sponsorship support from the Chamber of Automotive Commerce, an intensive seminar is arranged for your trainee. Following a short sponsored presentation, training days are completed and the diploma is granted immediately.`
- **DE**: `Mit Sponsorenunterstützung der Automobilkammer wird ein Intensivseminar für Ihren Auszubildenden organisiert. Nach einer kurzen Präsentation wird die Ausbildung sofort abgeschlossen und das Diplom verliehen.`
- **PT**: `Com apoio de patrocínio da Câmara Automotiva, um seminário intensivo é organizado para o seu estagiário. Após uma breve apresentação patrocinada, o treinamento é concluído e o diploma é concedido imediatamente.`
- **ES**: `Con el patrocinio de la Cámara Automotriz, se organiza un seminario intensivo para su aprendiz. Tras una breve presentación patrocinada, la capacitación se completa y el diploma se entrega de inmediato.`
- **RU**: `При спонсорской поддержке Автомобильной палаты для вашего стажера организуется интенсивный семинар. После короткой спонсорской презентации обучение завершается, и диплом выдается немедленно.`
- **AR**: `بدعم ورعاية من الغرفة التجارية للسيارات، يتم تنظيم ندوة مكثفة لمتدربك. بعد عرض رعاية قصير، تنتهي فترة التدريب ويتم تسليم الدبلوم فورا.`

### 3. `rush_training_btn_watch`
- **TR**: `SPONSOR DESTEĞİ AL & MEZUN ET`
- **EN**: `CLAIM SPONSOR GRANT & GRADUATE`
- **DE**: `SPONSOREN-STIPENDIUM & ABSCHLUSS`
- **PT**: `OBTER BOLSA & FORMAR`
- **ES**: `OBTENER BECA Y GRADUAR`
- **RU**: `ПОЛУЧИТЬ СТИПЕНДИЮ И ВЫПУСТИТЬ`
- **AR**: `الحصول على المنحة وتخريج المتدرب`

### 4. `staff_btn_rush_training` (Screens trigger button)
- **TR**: `SPONSORLU BURS • MEZUN ET`
- **EN**: `SPONSOR GRANT • GRADUATE`
- **DE**: `STIPENDIUM • ABSCHLUSS`
- **PT**: `BOLSA PATROCINADA • FORMAR`
- **ES**: `BECA PATROCINADA • GRADUAR`
- **RU**: `СТИПЕНДИЯ • ВЫПУСТИТЬ`
- **AR**: `منحة الرعاية • تخرج`

---

## Tech Stack & Project Structure
- **Framework**: Flutter 3.x with Flutter Riverpod
- **Affected Files**:
  - `lib/core/localization/translations/tr_translations.dart` (+ 6 other language files)
  - `lib/presentation/widgets/dialogs/rush_training_confirmation_dialog.dart`
  - `test/rush_training_dialog_test.dart`

---

## Boundaries & Invariants
- **Always**:
  - Keep Zero Unicode Emojis (use `Icons.school_rounded`, `Icons.card_membership_rounded` or `VectorIconWidget`).
  - Keep Zero Parentheses in UI strings (use ` • ` or ` - ` for separators).
  - Synchronize all 7 supported languages simultaneously (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`).
- **Never**:
  - Break fallback rewarded ad logic in offline or test environments.
  - Leave unhandled async timer disposal in test suites.

---

## Success Criteria & Verification
1. `RushTrainingConfirmationDialog` displays the new in-universe seminar grant title and storytelling copy.
2. The action button displays the soft, lore-friendly label without raw "Reklam İzle".
3. All 7 language translation files are updated with 0 missing keys.
4. `test/rush_training_dialog_test.dart` passes 100% (4/4 tests).
5. `flutter analyze` returns 0 issues.
