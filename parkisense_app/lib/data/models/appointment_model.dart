import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String userId;
  final String doctorName;
  final DateTime appointmentDate;
  final String timeSlot;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'in_progress', 'confirmed', 'cancelled', 'denied'
  final String? notes;
  final String? doctorNotes;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? deniedBy;
  final DateTime? deniedAt;
  final String? denialReason;

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.doctorName,
    required this.appointmentDate,
    required this.timeSlot,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'in_progress',
    this.notes,
    this.doctorNotes,
    this.approvedBy,
    this.approvedAt,
    this.deniedBy,
    this.deniedAt,
    this.denialReason,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp).toDate(),
      timeSlot: data['timeSlot'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'in_progress',
      notes: data['notes'],
      doctorNotes: data['doctorNotes'],
      approvedBy: data['approvedBy'],
      approvedAt: data['approvedAt'] != null ? (data['approvedAt'] as Timestamp).toDate() : null,
      deniedBy: data['deniedBy'],
      deniedAt: data['deniedAt'] != null ? (data['deniedAt'] as Timestamp).toDate() : null,
      denialReason: data['denialReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'doctorName': doctorName,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'timeSlot': timeSlot,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status,
      'notes': notes,
      'doctorNotes': doctorNotes,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'deniedBy': deniedBy,
      'deniedAt': deniedAt != null ? Timestamp.fromDate(deniedAt!) : null,
      'denialReason': denialReason,
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? userId,
    String? doctorName,
    DateTime? appointmentDate,
    String? timeSlot,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    String? notes,
    String? doctorNotes,
    String? approvedBy,
    DateTime? approvedAt,
    String? deniedBy,
    DateTime? deniedAt,
    String? denialReason,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      doctorName: doctorName ?? this.doctorName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      timeSlot: timeSlot ?? this.timeSlot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      deniedBy: deniedBy ?? this.deniedBy,
      deniedAt: deniedAt ?? this.deniedAt,
      denialReason: denialReason ?? this.denialReason,
    );
  }
}
