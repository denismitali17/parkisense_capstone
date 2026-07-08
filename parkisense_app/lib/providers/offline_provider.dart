import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum SyncStatus {
  synced,
  pending,
  error,
  offline,
}

class OfflineData {
  final String key;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final SyncStatus syncStatus;

  OfflineData({
    required this.key,
    required this.data,
    required this.timestamp,
    required this.syncStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'syncStatus': syncStatus.toString(),
    };
  }

  factory OfflineData.fromJson(Map<String, dynamic> json) {
    return OfflineData(
      key: json['key'],
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp']),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.toString() == json['syncStatus'],
        orElse: () => SyncStatus.pending,
      ),
    );
  }
}

class OfflineNotifier extends StateNotifier<Map<String, OfflineData>> {
  OfflineNotifier() : super({}) {
    _loadOfflineData();
  }

  Future<void> _loadOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    final offlineDataJson = prefs.getString('offline_data');
    
    if (offlineDataJson != null) {
      final Map<String, dynamic> decoded = json.decode(offlineDataJson);
      final Map<String, OfflineData> data = {};
      
      decoded.forEach((key, value) {
        data[key] = OfflineData.fromJson(value as Map<String, dynamic>);
      });
      
      state = data;
    }
  }

  Future<void> _saveOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> encoded = {};
    
    state.forEach((key, value) {
      encoded[key] = value.toJson();
    });
    
    await prefs.setString('offline_data', json.encode(encoded));
  }

  Future<void> saveData(String key, Map<String, dynamic> data) async {
    final offlineData = OfflineData(
      key: key,
      data: data,
      timestamp: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    final newState = Map<String, OfflineData>.from(state);
    newState[key] = offlineData;
    state = newState;

    await _saveOfflineData();
  }

  Future<void> markAsSynced(String key) async {
    if (!state.containsKey(key)) return;

    final updatedData = state[key]!.copyWith(
      syncStatus: SyncStatus.synced,
      timestamp: DateTime.now(),
    );

    final newState = Map<String, OfflineData>.from(state);
    newState[key] = updatedData;
    state = newState;

    await _saveOfflineData();
  }

  Future<void> markAsError(String key) async {
    if (!state.containsKey(key)) return;

    final updatedData = state[key]!.copyWith(
      syncStatus: SyncStatus.error,
      timestamp: DateTime.now(),
    );

    final newState = Map<String, OfflineData>.from(state);
    newState[key] = updatedData;
    state = newState;

    await _saveOfflineData();
  }

  Future<void> removeData(String key) async {
    final newState = Map<String, OfflineData>.from(state);
    newState.remove(key);
    state = newState;

    await _saveOfflineData();
  }

  Future<void> clearAllOfflineData() async {
    state = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('offline_data');
  }

  SyncStatus getSyncStatus(String key) {
    return state[key]?.syncStatus ?? SyncStatus.offline;
  }

  List<OfflineData> getPendingSync() {
    return state.values
        .where((data) => data.syncStatus == SyncStatus.pending)
        .toList();
  }

  int get pendingCount => getPendingSync().length;
  bool get hasPendingSync => pendingCount > 0;
  bool get isOffline => state.isEmpty;

  // Sync all pending data to cloud
  Future<void> syncToCloud() async {
    final pendingData = getPendingSync();
    
    for (final data in pendingData) {
      try {
        // TODO: Implement actual cloud sync logic with Firebase
        // This would upload the data to Firestore
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network call
        await markAsSynced(data.key);
      } catch (e) {
        await markAsError(data.key);
      }
    }
  }

  // Check network connectivity status
  Future<bool> checkConnectivity() async {
    // TODO: Implement actual connectivity check using connectivity_plus
    // For now, return true (online)
    return true;
  }
}

final offlineProvider = StateNotifierProvider<OfflineNotifier, Map<String, OfflineData>>((ref) {
  return OfflineNotifier();
});

final syncStatusProvider = Provider<SyncStatus>((ref) {
  final offlineData = ref.watch(offlineProvider);
  if (offlineData.isEmpty) return SyncStatus.offline;
  
  final hasPending = offlineData.values.any((data) => data.syncStatus == SyncStatus.pending);
  final hasError = offlineData.values.any((data) => data.syncStatus == SyncStatus.error);
  
  if (hasError) return SyncStatus.error;
  if (hasPending) return SyncStatus.pending;
  return SyncStatus.synced;
});
