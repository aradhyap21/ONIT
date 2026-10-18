import 'package:flutter/material.dart';

import '../../core/placeholder_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderScreen(
        title: 'Calendar',
        icon: Icons.calendar_month_outlined,
      );
}
