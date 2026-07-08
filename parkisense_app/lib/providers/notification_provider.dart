import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  final bool enabled;
  final bool monthlyReminder;
  final bool appointmentReminders;
  final bool riskAlerts;

  NotificationSettings({
    required this.enabled,
    required this.monthlyReminder,
    required this.appointmentReminders,
    required this.riskAlerts,
  });

  NotificationSettings copyWith({
    bool? enabled,
    bool? monthlyReminder,
    bool? appointmentReminders,
    bool? riskAlerts,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      monthlyReminder: monthlyReminder ?? this.monthlyReminder,
      appointmentReminders: appointmentReminders ?? this.appointmentReminders,
      riskAlerts: riskAlerts ?? this.riskAlerts,
    );
  }

  Map<String, bool> toJson() {
    return {
      'enabled': enabled,
      'monthlyReminder': monthlyReminder,
      'appointmentReminders': appointmentReminders,
      'riskAlerts': riskAlerts,
    };
  }

  factory NotificationSettings.fromJson(Map<String, bool> json) {
    return NotificationSettings(
      enabled: json['enabled'] ?? true,
      monthlyReminder: json['monthlyReminder'] ?? true,
      appointmentReminders: json['appointmentReminders'] ?? true,
      riskAlerts: json['riskAlerts'] ?? true,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationSettings> {
  NotificationNotifier() : super(NotificationSettings(
    enabled: true,
    monthlyReminder: true,
    appointmentReminders: true,
    riskAlerts: true,
  )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? true;
    final monthlyReminder = prefs.getBool('monthly_reminder') ?? true;
    final appointmentReminders = prefs.getBool('appointment_reminders') ?? true;
    final riskAlerts = prefs.getBool('risk_alerts') ?? true;

    state = NotificationSettings(
      enabled: enabled,
      monthlyReminder: monthlyReminder,
      appointmentReminders: appointmentReminders,
      riskAlerts: riskAlerts,
    );
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', newSettings.enabled);
    await prefs.setBool('monthly_reminder', newSettings.monthlyReminder);
    await prefs.setBool('appointment_reminders', newSettings.appointmentReminders);
    await prefs.setBool('risk_alerts', newSettings.riskAlerts);

    state = newSettings;
  }

  Future<void> toggleEnabled(bool value) async {
    final newSettings = state.copyWith(enabled: value);
    await updateSettings(newSettings);
  }

  Future<void> toggleMonthlyReminder(bool value) async {
    final newSettings = state.copyWith(monthlyReminder: value);
    await updateSettings(newSettings);
  }

  Future<void> toggleAppointmentReminders(bool value) async {
    final newSettings = state.copyWith(appointmentReminders: value);
    await updateSettings(newSettings);
  }

  Future<void> toggleRiskAlerts(bool value) async {
    final newSettings = state.copyWith(riskAlerts: value);
    await updateSettings(newSettings);
  }

  // Schedule monthly reminder notification
  Future<void> scheduleMonthlyReminder() async {
    if (!state.monthlyReminder) return;
    
    // TODO: Implement actual notification scheduling using flutter_local_notifications
    // This would schedule a notification every 30 days
    print('Monthly reminder scheduled');
  }

  // Schedule appointment reminder
  Future<void> scheduleAppointmentReminder(DateTime appointmentDate) async {
    if (!state.appointmentReminders) return;
    
    // TODO: Implement actual notification scheduling
    print('Appointment reminder scheduled for $appointmentDate');
  }

  // Send risk alert notification
  Future<void> sendRiskAlert() async {
    if (!state.riskAlerts) return;
    
    // TODO: Implement actual notification sending
    print('Risk alert sent');
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationSettings>((ref) {
  return NotificationNotifier();
});
