import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/screening_model.dart';
import 'results_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String audioPath;
  const ProcessingScreen({super.key, required this.audioPath});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  String _currentStage = "Reading voice recording data...";
  double _progressValue = 0.20;

  @override
  void initState() {
    super.initState();
    _processVoicePayload();
  }

  Future<void> _processVoicePayload() async {
    try {
      List<int> audioBytes;

      // Read file data securely depending on platform environment
      if (kIsWeb || widget.audioPath.startsWith('blob:') || widget.audioPath.startsWith('http')) {
        setState(() {
          _currentStage = "Fetching browser audio payload...";
        });
        final response = await http.get(Uri.parse(widget.audioPath));
        if (response.statusCode == 200) {
          audioBytes = response.bodyBytes;
        } else {
          throw Exception("Failed to extract data bytes from browser blob.");
        }
      } else {
        final File audioFile = File(widget.audioPath);
        if (!await audioFile.exists()) {
          throw Exception("Audio file path could not be located on this device.");
        }
        audioBytes = await audioFile.readAsBytes();
      }

      setState(() {
        _currentStage = "Connecting to Render service...";
        _progressValue = 0.50;
      });

      // Initialize the Multipart Request
      final url = Uri.parse('https://parkisense-api.onrender.com/predict');
      final request = http.MultipartRequest('POST', url);

      // Attach the bytes as a form file using the exact key name 'file' required by your backend
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          audioBytes,
          filename: 'voice_sample.wav',
        ),
      );

      setState(() {
        _currentStage = "Analyzing dysphonia telemetry metrics...";
        _progressValue = 0.80;
      });

      // Step 3: Send to Render and await analysis
      final streamedResponse = await request.send();
      final apiResponse = await http.Response.fromStream(streamedResponse);

      if (apiResponse.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(apiResponse.body);

        setState(() {
          _currentStage = "Structuring analysis report...";
          _progressValue = 1.0;
        });

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                screening: ScreeningModel(
                  id: data['id'] ?? 'scr_${DateTime.now().millisecondsSinceEpoch}',
                  userId: data['user_id'] ?? 'current_practitioner',
                  audioUrl: widget.audioPath,
                  timestamp: DateTime.now(),
                  prediction: data['prediction'] ?? 0,
                  diagnosis: data['diagnosis'] ?? (data['prediction'] == 1 ? 'Positive Indicators Detected' : 'Negative / Normal'),
                  confidenceScore: (data['confidence'] as num?)?.toDouble() ?? 0.95,
                  totalChunksAnalyzed: data['chunks_analyzed'] ?? 10,
                ),
              ),
            ),
          );
        }
      } else {
        throw Exception('Server rejected payload (${apiResponse.statusCode}): ${apiResponse.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Acoustic Pipeline Error: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryBlue, strokeWidth: 4),
            const SizedBox(height: 32),
            Text(_currentStage, style: const TextStyle(fontSize: 18, color: AppColors.textDark, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _progressValue, backgroundColor: AppColors.borderGrey, color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }
}