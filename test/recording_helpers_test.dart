import 'package:flutter_test/flutter_test.dart';
import 'package:voice_reminder/features/record/recording_helpers.dart';

void main() {
  test('recording file names include a timestamp and m4a extension', () {
    final timestamp = DateTime(2026, 10, 18, 9, 8, 7, 6, 5);

    expect(
      recordingFileName(timestamp),
      'voice_note_20261018_090807_006005.m4a',
    );
  });

  test('recording duration is formatted as minutes and seconds', () {
    expect(formatRecordingDuration(Duration.zero), '00:00');
    expect(formatRecordingDuration(const Duration(seconds: 65)), '01:05');
    expect(formatRecordingDuration(maxRecordingDuration), '05:00');
  });
}
