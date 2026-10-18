import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/calendar/calendar_screen.dart';
import '../features/dump/dump_screen.dart';
import '../features/record/record_screen.dart';
import '../features/stats/stats_screen.dart';
import '../features/today/today_screen.dart';
import 'theme.dart';

final appRouter = GoRouter(
  initialLocation: '/today',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        _branch('/today', const TodayScreen()),
        _branch('/calendar', const CalendarScreen()),
        _branch('/dump', const DumpScreen()),
        _branch('/stats', const StatsScreen()),
      ],
    ),
    GoRoute(
      path: '/record',
      builder: (context, state) => const RecordScreen(),
    ),
  ],
);

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
      routes: [GoRoute(path: path, builder: (context, state) => screen)],
    );

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              _tab(context, 0, Icons.today_outlined, 'Today'),
              _tab(context, 1, Icons.calendar_month_outlined, 'Calendar'),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: FloatingActionButton(
                      heroTag: 'record-button',
                      tooltip: 'Record a voice note',
                      backgroundColor: AppColors.mint,
                      foregroundColor: AppColors.background,
                      onPressed: () => context.push('/record'),
                      child: const Icon(Icons.mic_none_rounded, size: 27),
                    ),
                  ),
                ),
              ),
              _tab(context, 2, Icons.inbox_outlined, 'Dump'),
              _tab(context, 3, Icons.bar_chart_rounded, 'Stats'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(BuildContext context, int index, IconData icon, String label) {
    final selected = navigationShell.currentIndex == index;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: () => navigationShell.goBranch(index),
          child: SizedBox(
            height: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: selected ? AppColors.mint : AppColors.muted),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppColors.text : AppColors.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
