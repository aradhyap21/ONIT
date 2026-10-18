import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class VoiceNoteStore {
  final notes = ValueNotifier<List<File>>(<File>[]);

  Future<void> reload() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = await directory
        .list(followLinks: false)
        .where((entity) => entity is File)
        .cast<File>()
        .where((file) {
          final name = file.path.split(Platform.pathSeparator).last;
          return name.startsWith('voice_note_') && name.endsWith('.m4a');
        })
        .toList();
    files.sort((a, b) => b.path.compareTo(a.path));
    notes.value = files;
  }

  void add(File file) {
    notes.value = [...notes.value.where((note) => note.path != file.path), file]
      ..sort((a, b) => b.path.compareTo(a.path));
  }

  Future<void> delete(File file) async {
    if (await file.exists()) await file.delete();
    notes.value = notes.value.where((note) => note.path != file.path).toList();
  }
}

final voiceNoteStore = VoiceNoteStore();
