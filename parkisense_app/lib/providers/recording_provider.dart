import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class RecordingState {
  final bool isRecording;
  final int durationSeconds;
  final String? path;
  final List<double> waveAmplitudes;

  RecordingState({
    required this.isRecording,
    required this.durationSeconds,
    this.path,
    required this.waveAmplitudes,
  });

  RecordingState copyWith({
    bool? isRecording,
    int? durationSeconds,
    String? path,
    List<double>? waveAmplitudes,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      path: path ?? this.path,
      waveAmplitudes: waveAmplitudes ?? this.waveAmplitudes,
    );
  }
}

class RecordingNotifier extends StateNotifier<RecordingState> {
  final _audioRecorder = AudioRecorder();
  Timer? _timer;
  Timer? _amplitudeTimer;

  RecordingNotifier() : super(RecordingState(isRecording: false, durationSeconds: 0, waveAmplitudes: []));

  Future<void> startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 44100,
            numChannels: 1,
          ),
          path: path
        );

        state = RecordingState(isRecording: true, durationSeconds: 0, path: path, waveAmplitudes: []);
        _startTimers();
      }
    } catch (_) {
      // Gracefully handle internal recording engine configurations
    }
  }

  void _startTimers() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      state = state.copyWith(durationSeconds: state.durationSeconds + 1);
    });

    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (t) async {
      final amp = await _audioRecorder.getAmplitude();
      // Normalize values from log scale to absolute UI ratios [0.0 - 1.0]
      double normalized = (amp.current + 50.0) / 50.0;
      normalized = normalized.clamp(0.05, 1.0);

      List<double> currentAmps = List.from(state.waveAmplitudes);
      if (currentAmps.length >= 20) currentAmps.removeAt(0);
      currentAmps.add(normalized);

      state = state.copyWith(waveAmplitudes: currentAmps);
    });
  }

  // REMOVED 'async' from the very front of this line
  Future<String?> stopRecording() async {
    _timer?.cancel();
    _amplitudeTimer?.cancel();
    final path = await _audioRecorder.stop();
    state = state.copyWith(isRecording: false);
    return path;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }
}

final recordingNotifierProvider = StateNotifierProvider<RecordingNotifier, RecordingState>((ref) {
  return RecordingNotifier();
});