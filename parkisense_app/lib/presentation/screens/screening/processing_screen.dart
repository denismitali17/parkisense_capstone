import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/screening_model.dart';
import '../../../../data/services/firestore_service.dart';
import 'results_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String? audioPath;
  final List<int>? audioBytes;
  const ProcessingScreen({super.key, this.audioPath, this.audioBytes});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  String _currentStage = "Reading voice recording data...";
  double _progressValue = 0.20;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _processVoicePayload();
  }

  Future<void> _processVoicePayload() async {
    try {
      List<int> audioBytes;

      // Handle uploaded file bytes directly
      if (widget.audioBytes != null) {
        audioBytes = widget.audioBytes!;
      } 
      // Read file data from path for recorded files
      else if (widget.audioPath != null) {
        if (kIsWeb || widget.audioPath!.startsWith('blob:') || widget.audioPath!.startsWith('http')) {
          setState(() {
            _currentStage = "Fetching browser audio payload...";
          });
          final response = await http.get(Uri.parse(widget.audioPath!));
          if (response.statusCode == 200) {
            audioBytes = response.bodyBytes;
          } else {
            throw Exception("Failed to extract data bytes from browser blob.");
          }
        } else {
          final File audioFile = File(widget.audioPath!);
          if (!await audioFile.exists()) {
            throw Exception("Audio file path could not be located on this device. Path: ${widget.audioPath}");
          }
          audioBytes = await audioFile.readAsBytes();
        }
      } else {
        throw Exception("No audio data provided.");
      }

      setState(() {
        _currentStage = "Connecting to Render service...";
        _progressValue = 0.50;
      });

      // Initialize the Multipart Request
      final url = Uri.parse('https://parkisense-api.onrender.com/predict');
      final request = http.MultipartRequest('POST', url);

      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          audioBytes,
          filename: 'voice_sample.wav',
          contentType: http.MediaType.parse('audio/wav'),
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

        // Get the actual user ID from Firebase Auth
        final user = FirebaseAuth.instance.currentUser;
        final actualUserId = user?.uid ?? 'unknown_user';

        final screening = ScreeningModel(
          id: data['id'] ?? 'scr_${DateTime.now().millisecondsSinceEpoch}',
          userId: actualUserId, // Use actual Firebase user ID instead of API response
          audioUrl: widget.audioPath ?? 'uploaded_file',
          timestamp: DateTime.now(),
          prediction: data['prediction'] ?? 0,
          diagnosis: data['diagnosis'] ?? (data['prediction'] == 1 ? 'Positive Indicators Detected' : 'Negative / Normal'),
          confidenceScore: (data['confidence_score'] as num?)?.toDouble() ?? 0.0,
          totalChunksAnalyzed: data['total_chunks_analyzed'] ?? 1,
        );

        // Save screening to Firestore
        if (user != null) {
          try {
            await _firestoreService.saveScreening(user.uid, screening);
          } catch (e) {
            // Log error but don't block the user from seeing results
            print('Error saving screening to Firestore: $e');
          }
        }

        setState(() {
          _currentStage = "Structuring analysis report...";
          _progressValue = 1.0;
        });

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                screening: screening,
                showAppointmentDialog: data['prediction'] == 1,
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

  void _showAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Parkinson\'s Detected',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.dangerRed,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_rounded,
              color: AppColors.dangerRed,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Based on the analysis, indicators of Parkinson\'s disease were detected. We recommend booking an appointment with a specialist for further evaluation.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe Later',
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/appointment');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Book Appointment',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}