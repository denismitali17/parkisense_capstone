import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/screening_model.dart';

class ScreeningNotifier extends StateNotifier<AsyncValue<ScreeningModel?>> {
  ScreeningNotifier() : super(const AsyncValue.data(null));

  Future<void> evaluateVoiceData(String filePath) async {
    state = const AsyncValue.loading();
    try {
      final url = Uri.parse('https://parkisense-api.onrender.com/predict');
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send().timeout(const Duration(seconds: 45));
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final Map<String, dynamic> jsonResult = jsonDecode(responseData);

        final user = FirebaseAuth.instance.currentUser;
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid ?? 'anonymous')
            .collection('screenings')
            .doc();

        final screening = ScreeningModel(
          id: docRef.id,
          userId: user?.uid ?? 'anonymous',
          timestamp: DateTime.now(),
          audioUrl: '', // Production pipelines upload to cloud storage here
          prediction: jsonResult['prediction'],
          diagnosis: jsonResult['diagnosis'],
          confidenceScore: (jsonResult['confidence_score'] as num).toDouble(),
          totalChunksAnalyzed: jsonResult['total_chunks_analyzed'],
        );

        await docRef.set(screening.toMap());
        state = AsyncValue.data(screening);
      } else {
        throw Exception("Server returned execution status error code: ${response.statusCode}");
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final screeningNotifierProvider = StateNotifierProvider<ScreeningNotifier, AsyncValue<ScreeningModel?>>((ref) {
  return ScreeningNotifier();
});