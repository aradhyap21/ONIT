import 'package:flutter/material.dart';

import 'core/router.dart';
import 'core/theme.dart';

void main() {
  runApp(const VoiceReminderApp());
}

class VoiceReminderApp extends StatelessWidget {
  const VoiceReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Voice Reminder',
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
