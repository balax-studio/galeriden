# Spec: Hızlandırılmış Diploma Reklam Onay Diyaloğu & Platform Yönlendirmesi (Rush Diploma Ad Confirmation Spec)

## 1. Objective
Personel Sanayi Akademisi ve Personel Yönetimi ekranlarında personelin çıraklık veya uzmanlık eğitimini anında bitirmesini sağlayan **Hızlandırılmış Diploma** butonuna basıldığında, kullanıcıya doğrudan reklam başlatmak yerine açık ve şeffaf bir Neo-Brutalist onay modalı sunmak. Oyuncu onay verdiğinde cihazın platformuna (`iOS` veya `Android`) uygun AdMob ödüllü reklam birimine yönlendirilecek; reklam izlendiğinde personel mezun edilip kalıcı sertifika ve bonusları verilecektir.

## 2. Tech Stack & Environment
- **Framework**: Flutter 3.x / Dart 3.x
- **State Management**: Riverpod (`gameProvider`, `game_staff_mixin.dart`)
- **Monetization**: Google Mobile Ads SDK (`AdService.instance.showRewardedAdWithFallback`)
  - **Android Ad Unit ID**: `ca-app-pub-2626843024156194/9140182901` (Test: `ca-app-pub-3940256099942544/5224354917`)
  - **iOS Ad Unit ID**: `ca-app-pub-2626843024156194/6070487811` (Test: `ca-app-pub-3940256099942544/1712485313`)
- **Localization**: 7 Simultaneous Languages (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`)
- **Design System**: Neo-Brutalism (Zero Unicode Emojis, Zero Parentheses, 3px solid black borders, hard drop shadows, high contrast)

## 3. Invariant Rules & Boundaries
- **Always**:
  - Zero Unicode Emojis: Use `VectorIconWidget` or native Flutter icons.
  - Zero Parentheses: Use ` • ` or ` - ` for formatting.
  - Simultaneous 7-Language Synchronization: Every new key must exist in all 7 translation files.
  - Show explicit confirmation before any rewarded ad load/play.
  - Platform detection: Use `defaultTargetPlatform == TargetPlatform.iOS` / `Android` via `AdService`.
  - Provide 100% rewarded completion fallback via `showRewardedAdWithFallback`.
- **Never**:
  - Never trigger rewarded ads without prior user consent/dialog.
  - Never allow duplicate enrollment during active training.
  - Never run unprompted `git push`.

## 4. User Flow & Screen Architecture

```
[StaffScreen / StaffAcademyScreen]
       │
       ▼ (Tap "HIZLANDIRILMIŞ DİPLOMA")
[RushTrainingConfirmationDialog]
 ├── Header: "HIZLANDIRILMIŞ DİPLOMA" + Warning Badge
 ├── Trainee Card: Staff Name, Role, Remaining Days
 ├── Explanatory Message: "Kısa bir sponsorlu video reklam izleyerek eğitimi anında tamamlayabilirsiniz."
 ├── Platform Info Chip: "Platform • iOS AdMob" or "Platform • Android AdMob"
 ├── [ VAZGEÇ ] Button ──→ Closes Dialog (No action)
 └── [ REKLAM İZLE & MEZUN ET ] Button ──→ Closes Dialog & Calls AdService
                                                    │
                                                    ▼
                                     [Platform Specific Rewarded Ad]
                                                    │
                                                    ▼ (Reward Earned)
                                      [rushStaffTraining Executed]
                                                    │
                                                    ▼
                                      [Graduation Toast & State Update]
```

## 5. UI Component Design: `RushTrainingConfirmationDialog`

- **File**: `lib/presentation/widgets/dialogs/rush_training_confirmation_dialog.dart`
- **Widgets**:
  - `NeoBrutalCard` with 16px radius, 3px border, hard shadow.
  - Header with `Icons.bolt_rounded` or `Icons.school_rounded` and `NeoBrutalBadge`.
  - Trainee Summary Row (Staff name, training course title, days remaining).
  - Info notice explaining the short video ad requirement.
  - Two action buttons: Cancel (outlined/gray) and Watch Ad (bold yellow / black).

## 6. Localization Keys (7-Language Sync)

| Key | TR | EN | DE | PT | ES | RU | AR |
|---|---|---|---|---|---|---|---|
| `rush_training_dialog_title` | HIZLANDIRILMIŞ DİPLOMA | RUSH DIPLOMA | EXPRESS DIPLOM | DIPLOMA EXPRESS | DIPLOMA EXPRÉS | УСКОРЕННЫЙ ДИПЛОМ | دبلوم سريع |
| `rush_training_dialog_desc` | Kısa bir video reklam izleyerek çıraklık veya uzmanlık eğitimini beklemeden anında tamamlayabilirsiniz. | You can instantly finish the apprenticeship or training without waiting by watching a short video ad. | Sie können die Ausbildung sofort abschließen, indem Sie eine kurze Videoanzeige ansehen. | Você pode concluir o treinamento instantaneamente assistindo a um anúncio em vídeo curto. | Puedes completar la capacitación al instante viendo un breve anuncio de video. | Вы можете мгновенно завершить обучение, посмотрев короткое видео. | يمكنك إتمام التدريب المهني فورا دون انتظار من خلال مشاهدة إعلان فيديو قصير. |
| `rush_training_btn_watch` | REKLAM İZLE & MEZUN ET | WATCH AD & GRADUATE | WERBUNG SEHEN & ABSCHLIESSEN | ASSISTIR E FORMAR | VER ANUNCIO Y GRADUAR | СМОТРЕТЬ И ВЫПУСТИТЬ | مشاهدة الإعلان والتخرج |
| `rush_training_target_staff` | Kursiyer • {name} | Trainee • {name} | Auszubildender • {name} | Estagiário • {name} | Pasante • {name} | Стажёр • {name} | المتدرب • {name} |

## 7. Testing Strategy
- Unit & Widget tests in `test/rush_training_dialog_test.dart`:
  1. Dialog renders staff details, course name, and duration without overflow.
  2. Tapping Cancel dismisses without firing `rushStaffTraining`.
  3. Tapping Watch Ad triggers `showRewardedAdWithFallback` and completes graduation upon reward.
  4. Platform routing verified for iOS and Android Ad Unit IDs.
- Run `flutter test test/rush_training_dialog_test.dart`.
- Run `flutter analyze` ensuring 0 warnings.
