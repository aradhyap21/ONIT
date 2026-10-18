# PLAN.md

Legend: [ ] todo, [x] done

## Decisions
- App name: [APP_NAME] (placeholder). Android first, iPhone later.
- AI runs in mock mode until the user provides keys.

## Steps
- [x] Step 0: Scaffold, theme, navigation shell, cloud APK build
- [x] Step 1: Record and play back voice notes locally
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
- 2026-10-18: Added private local .m4a recording with microphone permission handling, a five-minute limit, and Today-tab playback/deletion. Recording and playback still need a real-phone check.
- 2026-10-18: Fixed the APK workflow's SDK mismatch by aligning permission_handler_android's SDK 37 requirement with Android Gradle Plugin 9.1.1 and installing Android SDK 37 in CI.
- 2026-10-18: Corrected the SDK installation step to call sdkmanager from the Android SDK command-line tools directory; GitHub Actions did not have sdkmanager on PATH.

## Test log
(user: after each APK test, write what worked and what failed)
