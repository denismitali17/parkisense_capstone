class AppConstants {
  static const String appName = 'ParkiSense';
  static const String apiBaseUrl = 'https://parkisense-api.onrender.com';
  static const String predictEndpoint = '$apiBaseUrl/predict';
  
  // Audio Validation Parameters
  static const int maxAudioFileSizeBytes = 52428800; // 50MB
  static const int targetSampleRate = 44100;
}