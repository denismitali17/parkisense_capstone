import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';
import 'processing_screen.dart';

class VoiceScreeningScreen extends StatefulWidget {
  const VoiceScreeningScreen({super.key});
  @override
  State<VoiceScreeningScreen> createState() => _VoiceScreeningScreenState();
}

class _VoiceScreeningScreenState extends State<VoiceScreeningScreen> with SingleTickerProviderStateMixin {
  late AudioRecorder _audioRecorder;
  bool _isRecording = false;
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.8,
      upperBound: 1.2,
    );
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    try {
      if (!_isRecording) {
        if (await _audioRecorder.hasPermission()) {
          // Fallback storage paths for cross-platform compliance (Web/Desktop/Mobile)
          await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.wav), path: '');
          setState(() {
            _isRecording = true;
            _pulseController?.repeat(reverse: true);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied. Enable it in your system settings.')),
          );
        }
      } else {
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
          _pulseController?.stop();
        });
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProcessingScreen(audioPath: path ?? "LiveStream")));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Audio Engine Error: $e'), backgroundColor: AppColors.dangerRed));
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['wav', 'mp3', 'm4a'],
      );
      if (result != null && result.files.single.bytes != null) {
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProcessingScreen(audioPath: "UploadedFile")));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File System Exception: $e'), backgroundColor: AppColors.dangerRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acoustic Screening'), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: AppColors.textDark)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController ?? AlwaysStoppedAnimation(_isRecording ? 1.2 : 1.0),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isRecording ? _pulseController!.value : 1.0,
                    child: FloatingActionButton.large(
                      onPressed: _toggleRecording,
                      backgroundColor: _isRecording ? AppColors.dangerRed : AppColors.primaryBlue,
                      child: Icon(_isRecording ? Icons.stop : Icons.mic, size: 36, color: Colors.white),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(_isRecording ? 'Recording Live Audio...' : 'Tap Mic to Start Screen', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 64),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size(220, 48), side: const BorderSide(color: AppColors.primaryBlue)),
                onPressed: _pickAudioFile,
                icon: const Icon(Icons.upload_file, color: AppColors.primaryBlue),
                label: const Text('Upload Native Audio File', style: TextStyle(color: AppColors.primaryBlue)),
              )
            ],
          ),
        ),
      ),
    );
  }
}