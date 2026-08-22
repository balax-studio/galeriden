# Galeriden Project Rules

## 1. Zero Unicode Emoji Standard
- Absolutely zero Unicode emojis anywhere in the codebase (Dart code, UI labels, event descriptions, choices, logs, tests, web HTML).
- All visual badges and indicators must use `VectorIconWidget` with standard icon keys (e.g. `'wash'`, `'coin'`, `'flash'`, `'vintage'`, `'expertise'`, `'turbo'`, `'workshop'`, `'craftsman'`) or Material/FontAwesome vector icons.

## 2. Zero Parentheses `(...)` in UI & Narrative Text
- Do not use parentheses `(...)` in titles, descriptions, dialogs, choices, or button labels.
- Use hyphens ` - `, bullets ` • `, or line breaks instead of parentheses.

## 3. Strict Ownership Gating on Side Businesses & Facilities
- Negative events and risks for specific side businesses (vending, car wash, EV charging, billboard, wrap studio, corporate expertise, inspection station, spare parts, tow truck, rental, auto shop) and facilities (`/scrapyard`, `/workshop`) must ONLY trigger if the player actually owns that business (`isOwned == true`) or has unlocked the facility (`isUnlocked`).

## 4. Reactive Anti-Spam Action States
- For one-shot or multi-step actions (such as scrapyard part dismantling), UI buttons must immediately reflect reactive disabled state (`SÖKÜLDÜ` with `onPressed: null`) via Riverpod `Consumer` / `ref.watch` to prevent duplicate execution or spam clicking.

## 5. Strict Zero Git Push Rule
- Never execute `git push` under any circumstances unless explicitly commanded by the user. All testing, verification, and analysis must run locally.

## 6. Simultaneous 7-Language Localization Standard
- Every newly developed feature, UI label, dialog, toast notification, event, model key, badge, or button MUST be implemented simultaneously across all 7 supported languages (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) within `lib/core/localization/translations/` and `app_localizations.dart`.
- Hardcoded user-facing strings or partial single-language implementations are strictly prohibited.
