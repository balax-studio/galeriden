# Spec: Radial Clock Ring & Micro Day Phase Progression (Dairesel Gün İlerleme Halkası)

## 1. Objective
Add a dynamic, neo-brutalist radial clock progress ring and contextual time-of-day phase indicators to the game's top HUD "GÜN" (Day) badge.
This sets the in-game calendar day duration to **2 minutes (120 seconds)** of active gameplay (calibrated from the longer 420-second cycle) and provides immediate visual feedback on the passage of time, upcoming daily events (salaries, interest, loan installments, dramatic dilemma cards, and night market transitions), and a tactile micro-animation when the calendar day advances.

## 2. Tech Stack
- Flutter 3.x / Dart 3.x
- Flutter Riverpod (State Management)
- CustomPainter / SingleTickerProviderStateMixin for 60fps hardware-accelerated ring drawing
- Neo-Brutalist design tokens (`AppColors`, `AppThemeExtension`, `AppTypography`)
- AppLocalizations (7 languages: `tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`)

## 3. Core Mechanics & Duration
- **1 In-Game Day = 2 Minutes (120 Seconds)**: Defined as `GameTimeMixin.inGameDayDurationSeconds = 120`.
- **4 Time-of-Day Phases (120s Timeline)**:
  - **Phase 1: Sabah / Morning (000s - 030s / 0.00 - 0.50 dk)**: `Color(0xFFFFB703)` (Gold) • Icon: `Icons.wb_sunny_rounded`
  - **Phase 2: Öğle / Noon (030s - 071s / 0.50 - 1.18 dk)**: `Color(0xFF38BDF8)` (Sky Blue) • Icon: `Icons.storefront_rounded`
  - **Phase 3: Akşam / Evening (071s - 104s / 1.18 - 1.73 dk)**: `Color(0xFFF97316)` (Sunset Orange) • Icon: `Icons.wb_twilight_rounded`
  - **Phase 4: Gece / Night (104s - 120s / 1.73 - 2.00 dk)**: `Color(0xFF818CF8)` (Midnight Indigo) • Icon: `Icons.nightlight_round`

## 4. Commands
- Build/Run: `flutter run -d web-server --web-port=8080`
- Test: `flutter test test/day_progress_ring_test.dart`
- Analyze: `flutter analyze`

## 5. Project Structure
- `lib/presentation/providers/game/game_time_mixin.dart` [MODIFY]: Update `_organicOfferTimer` to `inGameDayDurationSeconds = 120` and track day start timestamp.
- `lib/presentation/widgets/radial_day_progress_widget.dart` [NEW]: Dedicated 120-second radial progress painter and day phase widget.
- `lib/presentation/widgets/game_hud_widget.dart` [MODIFY]: Integrate `RadialDayProgressWidget` and animated day counter into `_buildPill`.
- `lib/core/localization/translations/*.dart` [MODIFY]: 7-language localization strings for day phases.
- `test/day_progress_ring_test.dart` [NEW]: Comprehensive widget and unit tests for timer synchronization, phase progression, and day rollover.

## 6. Visual & Code Style
- **Radial Ring Dimensions**: 24x24 px square badge. 2.5px stroke width. Crisp 0-blur neo-brutalist outline.
- **Day Advance Transition**: When `currentDay` increments, a quick 300ms scale/bounce pulse (1.0 -> 1.15 -> 1.0) with subtle haptic feedback.
- **Zero Parentheses / Zero Emojis**: All strings formatted with ` • ` or ` - `. Only Flutter Material icons.

## 7. Testing Strategy
- Unit & Widget tests in `test/day_progress_ring_test.dart`:
  1. Ring progress calculation across the 120-second timeline.
  2. Micro-phase icon & color switching at exact threshold intervals (30s, 71s, 104s, 120s).
  3. Day advance trigger and animation reset.
  4. Timer hygiene verification (no dangling timers after dispose).
  5. 7-language localization completeness check.

## 8. Success Criteria
- [ ] 1 In-Game Day is exactly 2 minutes (120 seconds).
- [ ] The "GÜN" badge shows a live radial circular arc filling smoothly over 2 minutes.
- [ ] Center icon dynamically reflects the time of day (Morning -> Noon -> Dusk -> Night).
- [ ] Day rollover produces a crisp, smooth pulse animation and resets the ring to 0°.
- [ ] Tapping the pill navigates to `/history` with no lag.
- [ ] 100% localized in all 7 supported languages.
- [ ] All tests pass without warnings or timer leaks.
