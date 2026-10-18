# AGENTS.md: rules for this project

## Product
[APP_NAME] is an Android-first Flutter app. The user records a voice note, AI turns it into categorized tasks with reminders, and at the due time the app rings like a call and plays the user's own voice. Check-ins keep the user accountable.

## Stack
- Flutter (stable), Dart with null safety
- State: flutter_riverpod. Navigation: go_router
- Backend: Supabase (Auth, Postgres, Storage, Edge Functions)
- AI runs only inside Supabase Edge Functions. Never put API keys in the app, in git or in logs.
- Approved packages: record, permission_handler, just_audio, path_provider, flutter_local_notifications, timezone, table_calendar, google_fonts, supabase_flutter, go_router, flutter_riverpod. Later: home_widget, flutter_tts.

## Working rules
1. Read PLAN.md first. Do only the step the user names. Never start the next step.
2. Keep changes small. Prefer simple code over clever code.
3. Before finishing run `flutter pub get`, `flutter analyze` and `flutter test`. Fix issues you caused. If you cannot run a command, say so.
4. Never invent API keys, URLs or credentials. Use placeholders and tell the user what to fill in.
5. Use feature folders under lib/features/<name>/.
6. Add a unit test for any parsing, date or scheduling logic.
7. Ask before adding any dependency not listed above, with a one-line reason.
8. Never run destructive commands (deleting folders, force-push, git reset) without asking.
9. After each step: update PLAN.md (tick items, note decisions), commit with a clear message, then reply in at most 10 lines: what changed, what the user must test on a real phone, and any blocker.

## Design tokens (match the mockups)
- Font: DM Sans (google_fonts)
- Background #0F1220, nav bar #14182A, card #1A1E30, border #2A2F47
- Text #F2F4FA, muted text #A9B0C9, accent mint #5EEAD4 (use dark text #0F1220 on it)
- Categories: Work #8BA8FF, Health #FF9DB1, Errands #FFC857, Finance #B8A6FF, Personal #5EEAD4
- Touch targets at least 44px. Icon-only buttons need semantic labels.

## Folder layout
lib/main.dart
lib/core/ (theme, router, constants)
lib/data/ (supabase client, models, repositories)
lib/features/ (capture, today, reminders, calendar, dump, checkins)
supabase/migrations/
supabase/functions/
.github/workflows/

## Privacy
Voice notes are personal. Use a private storage bucket, row-level security on every table, a delete-all-my-data option, and never log audio or transcripts.
