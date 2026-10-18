import 'package:flutter_test/flutter_test.dart';
import 'package:voice_reminder/main.dart';

void main() {
  testWidgets('tabs switch and the record button opens the record screen', (
    tester,
  ) async {
    await tester.pumpWidget(const VoiceReminderApp());
    await tester.pump();

    expect(find.text('Today'), findsWidgets);
    await tester.tap(find.text('Calendar').first);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Calendar'), findsWidgets);

    await tester.tap(find.byTooltip('Record a voice note'));
    await tester.pumpAndSettle();
    expect(find.text('Record a voice note'), findsOneWidget);
  });
}
