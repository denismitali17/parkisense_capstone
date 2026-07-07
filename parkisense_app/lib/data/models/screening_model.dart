import 'package:cloud_firestore/cloud_firestore.dart';

class ScreeningModel {
  final String id;
  final String userId;
  final DateTime timestamp;
  final String audioUrl;
  final int prediction; // 0 = Healthy, 1 = PD
  final String diagnosis;
  final double confidenceScore;
  final int totalChunksAnalyzed;
  final Map<String, dynamic>? metadata;

  ScreeningModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.audioUrl,
    required this.prediction,
    required this.diagnosis,
    required this.confidenceScore,
    required this.totalChunksAnalyzed,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'audioUrl': audioUrl,
      'prediction': prediction,
      'diagnosis': diagnosis,
      'confidenceScore': confidenceScore,
      'totalChunksAnalyzed': totalChunksAnalyzed,
      'metadata': metadata,
    };
  }

  factory ScreeningModel.fromMap(Map<String, dynamic> map) {
    return ScreeningModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      audioUrl: map['audioUrl'] ?? '',
      prediction: map['prediction'] ?? 0,
      diagnosis: map['diagnosis'] ?? 'Healthy Control',
      confidenceScore: (map['confidenceScore'] as num).toDouble(),
      totalChunksAnalyzed: map['totalChunksAnalyzed'] ?? 0,
      metadata: map['metadata'],
    );
  }
}