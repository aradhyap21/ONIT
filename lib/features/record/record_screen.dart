import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../core/theme.dart';
import 'recording_helpers.dart';
import 'voice_note_store.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen>
    with WidgetsBindingObserver {
  final _recorder = AudioRecorder();
  final _stopwatch = Stopwatch();
  final _levels = List<double>.filled(31, 0.08);
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  Timer? _ticker;
  Timer? _recordingLimit;
  File? _activeFile;
  Duration _elapsed = Duration.zero;
  bool _isRecording = false;
  bool _isBusy = false;
  bool _isFinishing = false;
  bool _returningFromSettings = false;
  bool _permanentlyDenied = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _recordingLimit?.cancel();
    unawaited(_amplitudeSubscription?.cancel());
    unawaited(_disposeRecorder());
    super.dispose();
  }

  Future<void> _disposeRecorder() async {
    if (_isRecording) {
      try {
        await _recorder.cancel();
      } catch (_) {}
    }
    await _recorder.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _returningFromSettings) {
      _returningFromSettings = false;
      unawaited(_refreshMicrophonePermission());
    }
  }

  Future<void> _refreshMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (!mounted || !status.isGranted) return;
    setState(() {
      _permanentlyDenied = false;
      _message = 'Microphone access is enabled. Tap the mic to start.';
    });
  }

  Future<void> _requestPermission({bool explain = true}) async {
    if (_isBusy || _isRecording) return;
    setState(() {
      _isBusy = true;
      _message = null;
    });

    try {
      if (explain) {
        final continueToPermission = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text('Allow microphone access'),
            content: const Text(
              'Voice Reminder uses your microphone to record voice notes. '
              'Recordings are saved privately on this device.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not now'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
        if (!mounted || continueToPermission != true) return;
      }

      final status = await Permission.microphone.request();
      if (!mounted) return;
      if (status.isGranted) {
        _permanentlyDenied = false;
        await _beginRecording();
      } else {
        setState(() {
          _permanentlyDenied = status.isPermanentlyDenied;
          _message = _permanentlyDenied
              ? 'Microphone access is blocked. Turn it on in app settings to record.'
              : 'Microphone access was denied. Allow it to record a voice note.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = 'Could not start recording. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _beginRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    if (!mounted) return;
    await directory.create(recursive: true);
    final file = File(
      '${directory.path}${Platform.pathSeparator}'
      '${recordingFileName(DateTime.now())}',
    );

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, numChannels: 1),
      path: file.path,
    );
    if (!mounted) {
      await _recorder.cancel();
      return;
    }
    _activeFile = file;
    _stopwatch
      ..reset()
      ..start();
    if (mounted) {
      setState(() {
        _isRecording = true;
        _elapsed = Duration.zero;
        _message = null;
      });
    }

    _amplitudeSubscription = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((amplitude) {
          if (!mounted || !_isRecording) return;
          final level = ((amplitude.current + 60) / 60).clamp(0.0, 1.0);
          setState(() {
            _levels.removeAt(0);
            _levels.add(level.toDouble());
          });
        });

    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted || !_isRecording || _isFinishing) return;
      final elapsed = _stopwatch.elapsed;
      setState(() => _elapsed = elapsed);
      if (elapsed >= maxRecordingDuration) unawaited(_stopRecording());
    });
    _recordingLimit = Timer(maxRecordingDuration, () {
      unawaited(_stopRecording());
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _isFinishing) return;
    setState(() => _isFinishing = true);
    _ticker?.cancel();
    _recordingLimit?.cancel();
    _stopwatch.stop();
    await _amplitudeSubscription?.cancel();

    try {
      final savedPath = await _recorder.stop();
      final file = File(savedPath ?? _activeFile!.path);
      if (!await file.exists() || await file.length() == 0) {
        throw const FileSystemException('Recording file is empty.');
      }
      voiceNoteStore.add(file);
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _isFinishing = false;
      });
      Navigator.of(context).pop(true);
    } catch (_) {
      try {
        await _recorder.cancel();
      } catch (_) {}
      final partialFile = _activeFile;
      if (partialFile != null && await partialFile.exists()) {
        await partialFile.delete();
      }
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isFinishing = false;
          _message = 'The recording could not be saved. Please try again.';
        });
      }
    }
  }

  Future<void> _cancelRecording() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);
    _ticker?.cancel();
    _recordingLimit?.cancel();
    _stopwatch.stop();
    await _amplitudeSubscription?.cancel();
    try {
      await _recorder.cancel();
      final file = _activeFile;
      if (file != null && await file.exists()) await file.delete();
    } catch (_) {
      if (mounted) {
        setState(() {
          _isFinishing = false;
          _message = 'Could not cancel this recording. Please try again.';
        });
      }
      return;
    }
    if (mounted) {
      setState(() => _isRecording = false);
      Navigator.of(context).pop(false);
    }
  }

  Future<void> _openSettings() async {
    _returningFromSettings = true;
    final opened = await openAppSettings();
    if (!mounted || opened) return;
    _returningFromSettings = false;
    setState(() => _message = 'Could not open app settings.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record a voice note'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                _isRecording ? 'Listening…' : 'Get it out of your head',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _isRecording
                    ? 'Your voice note stays on this device.'
                    : 'Tap the microphone and say what you need to remember.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 48),
              Semantics(
                button: true,
                label: _isRecording
                    ? 'Recording in progress'
                    : 'Start recording',
                child: GestureDetector(
                  onTap: _isRecording || _isBusy || _isFinishing
                      ? null
                      : () => _requestPermission(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 176,
                    height: 176,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.mint,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mint.withValues(
                            alpha: _isRecording ? 0.34 : 0.14,
                          ),
                          blurRadius: _isRecording ? 42 : 24,
                          spreadRadius: _isRecording ? 7 : 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording
                          ? Icons.graphic_eq_rounded
                          : Icons.mic_rounded,
                      color: AppColors.background,
                      size: 68,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Semantics(
                label: 'Recording time ${formatRecordingDuration(_elapsed)}',
                child: Text(
                  formatRecordingDuration(_elapsed),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 64,
                child: _isRecording
                    ? _buildLevelBars()
                    : const SizedBox.shrink(),
              ),
              if (_isRecording) ...[
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _isFinishing ? null : _cancelRecording,
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: _isFinishing ? null : _stopRecording,
                      icon: const Icon(Icons.stop_rounded),
                      label: Text(_isFinishing ? 'Saving…' : 'Stop & save'),
                    ),
                  ],
                ),
              ] else if (_isBusy) ...[
                const SizedBox(height: 28),
                const CircularProgressIndicator(color: AppColors.mint),
              ] else ...[
                const SizedBox(height: 28),
                const Text(
                  'Recording stops automatically after 5 minutes.',
                  style: TextStyle(color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
              ],
              if (_message != null) ...[
                const SizedBox(height: 24),
                _buildMessage(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelBars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final level in _levels)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 4,
              height: 10 + (level * 52),
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(alpha: 0.55 + (level * 0.45)),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(_message!, textAlign: TextAlign.center),
          if (_permanentlyDenied) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _openSettings,
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Open app settings'),
            ),
          ] else if (_message!.contains('denied')) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _requestPermission(explain: false),
              icon: const Icon(Icons.mic_none_rounded),
              label: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }
}
