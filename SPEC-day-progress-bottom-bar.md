# Spec: Bottom Gauge Bar & Micro Day Phase Progression for HUD Day Pill

## 1. Objective
Replace the cramped radial ring with a full-width **Bottom Gauge Bar** integrated directly into the "GÜN" (Day) HUD pill. 
The 7-minute (420 seconds) day progression is displayed as a crisp, high-visibility 3px progress bar spanning the entire width of the pill, accompanied by a clean square icon box that dynamically transitions between the 4 time-of-day phases (Sabah, Öğle, Akşam, Gece).

## 2. Visual Architecture
- **Pill Layout**:
  - Top Row: Dynamic Time-of-Day Icon Badge (20x20px square with 1.5px border) + `GÜN` label + Animated Day Number (`20`).
  - Bottom Row: Full-width 3.0px rounded gauge bar:
    - Background Track: `Color(0xFF2A3142)` (Dark) / `Color(0xFFE2E8F0)` (Light)
    - Active Progress: Solid accent color matching current time phase (`#FFB703`, `#38BDF8`, `#F97316`, `#818CF8`).
- **4 Time-of-Day Phases (420s Timeline)**:
  1. **Phase 1: Sabah (000s - 105s / 0 - 1.75 dk)**: `#FFB703` (Gold) • `Icons.wb_sunny_rounded`
  2. **Phase 2: Öğle (105s - 250s / 1.75 - 4.15 dk)**: `#38BDF8` (Sky Blue) • `Icons.storefront_rounded`
  3. **Phase 3: Akşam (250s - 365s / 4.15 - 6.10 dk)**: `#F97316` (Sunset Orange) • `Icons.wb_twilight_rounded`
  4. **Phase 4: Gece (365s - 420s / 6.10 - 7.00 dk)**: `#818CF8` (Midnight Indigo) • `Icons.nightlight_round`

## 3. Tech Stack & Performance
- `StatefulWidget` with `SingleTickerProviderStateMixin` (`BottomGaugeDayProgressWidget` / `NeoBrutalDayProgressPill`).
- Zero `DealershipModel` state pollution: Progress is hardware-accelerated via `AnimatedBuilder` & `FractionallySizedBox`.
- Day rollover triggers a 320ms bounce pulse and resets the gauge bar to 0%.

## 4. Testing Strategy
- Unit and widget tests in `test/day_progress_ring_test.dart`:
  1. Full-width gauge bar renders and spans the pill without layout overflow.
  2. Progress width factor accurately tracks elapsed time (0.0 to 1.0).
  3. Phase visuals switch at 105s, 250s, 365s, 420s.
  4. Day rollover resets progress bar.
  5. 7-language localization verified.

## 5. Success Criteria
- [ ] The entire bottom of the "GÜN" pill displays a clear, highly visible 3px progress bar.
- [ ] The icon box is clean, square, and devoid of awkward circular clipping.
- [ ] At 7 minutes (420s), the day counter increments with a tactile pulse and the gauge bar resets smoothly.
- [ ] All tests pass with zero warnings.
