# PLAN.md

Legend: [ ] todo, [x] done

## Decisions
- App name: [APP_NAME] (placeholder). Android first, iPhone later.
- AI runs in mock mode until the user provides keys.

## Steps
- [x] Step 0: Scaffold, theme, navigation shell, cloud APK build
- [ ] Step 1: Record and play back voice notes locally
- [ ] Step 2: Supabase schema, auth, audio upload
- [ ] Step 3: AI pipeline (transcribe, parse tasks, confirm screen)
- [ ] Step 4: Today screen, categories, follow-ups, manual tasks
- [ ] Step 5: Scheduled reminders (notifications)
- [ ] Step 6: Call-style ringing screen that plays the user's voice
- [ ] Step 7: Snooze, move, marked calendar
- [ ] Step 8: Shared dump and accountability check-ins
- [ ] Step 9: Home screen widget and record deep link
- [ ] Step 10: Real phone calls (optional, behind a feature flag)
- [ ] Step 11: Polish, privacy, release signing, app bundle

## Notes and blockers
- 2026-10-18: Created the Android Flutter scaffold, dark theme, navigation shell and GitHub Actions APK workflow. Android SDK and local APK builds are intentionally not part of this step.

## Test log
(user: after each APK test, write what worked and what failed)
