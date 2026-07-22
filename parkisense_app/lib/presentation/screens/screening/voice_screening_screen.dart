import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:record/record.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
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
  AnimationController? _waveController;
  int _recordingDuration = 0;

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
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _pulseController?.dispose();
    _waveController?.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    try {
      if (!_isRecording) {
        if (await _audioRecorder.hasPermission()) {
          // On web, use empty path (browser handles storage)
          // On mobile, use app documents directory
          String? path;
          if (!kIsWeb) {
            final directory = await getApplicationDocumentsDirectory();
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            path = '${directory.path}/recording_$timestamp.wav';
          }
          
          await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.wav), path: path ?? '');
          setState(() {
            _isRecording = true;
            _recordingDuration = 0;
            _pulseController?.repeat(reverse: true);
            _waveController?.repeat();
          });
          _startTimer();
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
          _waveController?.stop();
        });
        if (mounted) {
          // On web, path will be a blob URL, on mobile it's a file path
          if (kIsWeb) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProcessingScreen(audioPath: path ?? "LiveStream")));
          } else if (path != null) {
            // Verify file exists before navigating
            final file = File(path);
            if (await file.exists()) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProcessingScreen(audioPath: path)));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Recording file not found at: $path'), backgroundColor: AppColors.dangerRed),
              );
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Audio Engine Error: $e'), backgroundColor: AppColors.dangerRed));
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_isRecording && mounted) {
        setState(() {
          _recordingDuration++;
        });
        return true;
      }
      return false;
    });
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['wav', 'mp3', 'm4a'],
      );
      if (result != null) {
        // Check if we got bytes directly 
        if (result.files.single.bytes != null) {
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProcessingScreen(audioBytes: result.files.single.bytes!)));
          }
        } 
        // If we got a path instead (Android/iOS), read the file
        else if (result.files.single.path != null) {
          final file = File(result.files.single.path!);
          final bytes = await file.readAsBytes();
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProcessingScreen(audioBytes: bytes)));
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File System Exception: $e'), backgroundColor: AppColors.dangerRed));
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Voice Screening'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode 
                ? [AppColors.darkSurface, AppColors.darkCard]
                : [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).scaffoldBackgroundColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
              ? [AppColors.darkBackground, AppColors.darkSurface]
              : [Theme.of(context).scaffoldBackgroundColor, AppColors.backgroundLight],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Header Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue.withOpacity(0.1),
                        AppColors.primaryBlue.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.mic_rounded,
                        size: 48,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Voice Analysis',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Record your voice or upload an audio file for Parkinson\'s disease screening',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Recording Section
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Wave Animation
                      if (_isRecording)
                        SizedBox(
                          height: 60,
                          child: AnimatedBuilder(
                            animation: _waveController!,
                            builder: (context, child) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(20, (index) {
                                  final delay = index * 0.05;
                                  final animation = (delay + _waveController!.value) % 1.0;
                                  final height = 10 + (animation * 40);
                                  return Container(
                                    width: 4,
                                    height: height,
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      
                      const SizedBox(height: 32),
                      
                      // Recording Button
                      AnimatedBuilder(
                        animation: _pulseController ?? AlwaysStoppedAnimation(1.0),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isRecording ? _pulseController!.value : 1.0,
                            child: GestureDetector(
                              onTap: _toggleRecording,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isRecording
                                      ? [AppColors.dangerRed, AppColors.dangerRed.withOpacity(0.8)]
                                      : [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isRecording ? AppColors.dangerRed : AppColors.primaryBlue).withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Recording Status
                      Text(
                        _isRecording ? 'Recording...' : 'Tap to Start Recording',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      if (_isRecording) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.dangerRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fiber_manual_record,
                                size: 12,
                                color: AppColors.dangerRed,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDuration(_recordingDuration),
                                style: TextStyle(
                                  color: AppColors.dangerRed,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Upload Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Upload Audio File',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Supports WAV, MP3, M4A formats',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _pickAudioFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Choose File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Tips Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tips for Best Results',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTip('• Speak clearly and at a normal pace'),
                      _buildTip('• Record in a quiet environment'),
                      _buildTip('• Hold the device close to your mouth'),
                      _buildTip('• Record for at least 10-15 seconds'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}