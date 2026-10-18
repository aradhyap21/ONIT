import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/theme.dart';
import '../record/voice_note_store.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  String? _activePath;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (!mounted || _isPlaying == state.playing) return;
      setState(() => _isPlaying = state.playing);
    });
    unawaited(_loadNotes());
  }

  @override
  void dispose() {
    unawaited(_playerStateSubscription?.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _loadNotes() async {
    try {
      await voiceNoteStore.reload();
    } catch (_) {
      _loadError = 'Could not load your voice notes.';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _togglePlayback(File file) async {
    try {
      if (_activePath == file.path) {
        if (_player.playing) {
          await _player.pause();
        } else {
          if (_player.processingState == ProcessingState.completed) {
            await _player.seek(Duration.zero);
          }
          unawaited(_play());
        }
        return;
      }

      await _player.setFilePath(file.path);
      if (!mounted) return;
      setState(() {
        _activePath = file.path;
        _isPlaying = true;
      });
      unawaited(_play());
    } catch (_) {
      _showMessage('Could not play this voice note.');
    }
  }

  Future<void> _play() async {
    try {
      await _player.play();
    } catch (_) {
      _showMessage('Playback stopped because the file could not be read.');
    }
  }

  Future<void> _delete(File file) async {
    try {
      if (_activePath == file.path) {
        await _player.stop();
        if (mounted) {
          setState(() {
            _activePath = null;
            _isPlaying = false;
          });
        }
      }
      await voiceNoteStore.delete(file);
    } catch (_) {
      _showMessage('Could not delete this voice note.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _noteTime(File file) {
    final name = file.path.split(Platform.pathSeparator).last;
    final timestamp = name
        .replaceFirst('voice_note_', '')
        .replaceFirst('.m4a', '');
    return timestamp.replaceAll('_', '  ·  ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        backgroundColor: AppColors.background,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.mint),
            )
          : _loadError != null
          ? Center(child: Text(_loadError!))
          : ValueListenableBuilder<List<File>>(
              valueListenable: voiceNoteStore.notes,
              builder: (context, notes, _) {
                if (notes.isEmpty) return _emptyState(context);
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: notes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final file = notes[index];
                    final isActive = _activePath == file.path;
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.navigation,
                          child: Icon(
                            Icons.graphic_eq_rounded,
                            color: AppColors.mint,
                          ),
                        ),
                        title: const Text('Voice note'),
                        subtitle: Text(_noteTime(file)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: isActive && _isPlaying
                                  ? 'Pause voice note'
                                  : 'Play voice note',
                              onPressed: () => _togglePlayback(file),
                              icon: Icon(
                                isActive && _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: AppColors.mint,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete voice note',
                              onPressed: () => _delete(file),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic_none_rounded, color: AppColors.mint, size: 44),
            const SizedBox(height: 14),
            Text(
              'Your day starts here',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Record a voice note and it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
