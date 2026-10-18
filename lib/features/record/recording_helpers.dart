const maxRecordingDuration = Duration(minutes: 5);

String recordingFileName(DateTime timestamp) {
  final value = timestamp.toLocal();
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  String threeDigits(int number) => number.toString().padLeft(3, '0');

  return 'voice_note_${value.year}${twoDigits(value.month)}${twoDigits(value.day)}'
      '_${twoDigits(value.hour)}${twoDigits(value.minute)}${twoDigits(value.second)}'
      '_${threeDigits(value.millisecond)}${threeDigits(value.microsecond)}.m4a';
}

String formatRecordingDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
