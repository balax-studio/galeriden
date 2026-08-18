# Galeriden Tycoon Development Guidelines

## Invariant Rules
1. **Zero Unicode Emojis**: Always use `VectorIconWidget` or native Flutter icons. No emoji characters in strings or UI.
2. **Zero Parentheses**: Do not use `(...)` in UI strings, button text, dialog descriptions, or event choices. Use ` • ` or ` - ` for formatting.
3. **Strict Ownership Gating**: Random events targeting side businesses or facilities must check `b.isOwned == true` and `isFeatureUnlocked(route)`.
4. **Reactive Button States**: State actions must immediately disable spam buttons with reactive updates (`Consumer` / `ref.watch`).
5. **No Unprompted Git Push**: Never run `git push` without explicit user request.
