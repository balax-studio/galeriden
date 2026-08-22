# Galeriden Tycoon Development Guidelines

## Invariant Rules
1. **Zero Unicode Emojis**: Always use `VectorIconWidget` or native Flutter icons. No emoji characters in strings or UI.
2. **Zero Parentheses**: Do not use `(...)` in UI strings, button text, dialog descriptions, or event choices. Use ` • ` or ` - ` for formatting.
3. **Strict Ownership Gating**: Random events targeting side businesses or facilities must check `b.isOwned == true` and `isFeatureUnlocked(route)`.
4. **Reactive Button States**: State actions must immediately disable spam buttons with reactive updates (`Consumer` / `ref.watch`).
5. **No Unprompted Git Push**: Never run `git push` without explicit user request.
6. **Widget Test Timer Hygiene**: When writing widget tests that mount `gameCoreProvider`, always invoke `container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer()` during setup or teardown to prevent pending timer test assertion failures.
7. **Isolate Serialization for Heavy Models**: State persistence serialization must use Flutter `compute()` isolate execution with safe web fallback.
8. **Simultaneous 7-Language Localization**: Every newly developed feature, string, dialog, badge, and notification MUST be simultaneously and completely localized in all 7 supported languages (`tr`, `en`, `de`, `pt`, `es`, `ru`, `ar`) within `lib/core/localization/translations/` and `app_localizations.dart`. Hardcoded text or single-language additions without full 7-language synchronization are strictly forbidden.
