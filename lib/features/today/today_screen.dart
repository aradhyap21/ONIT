import 'package:flutter/material.dart';

import '../../core/placeholder_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderScreen(
        title: 'Today',
        icon: Icons.today_outlined,
      );
}
