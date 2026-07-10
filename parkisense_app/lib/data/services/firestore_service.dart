import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/screening_model.dart';
import '../models/appointment_model.dart';
import '../models/doctor_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Screenings
  Stream<List<ScreeningModel>> streamUserScreenings(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('screenings')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs        
            .map((doc) => ScreeningModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> saveScreening(String uid, ScreeningModel screening) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('screenings')
        .doc(screening.id)
        .set(screening.toMap());
  }

  // Appointments
  Stream<List<AppointmentModel>> streamUserAppointments(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .orderBy('appointmentDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }

  Future<String> createAppointment(String uid, AppointmentModel appointment) async {
    print('FirestoreService: Starting createAppointment for user: $uid');
    try {
      print('FirestoreService: Getting collection reference');
      final collectionRef = _db.collection('users').doc(uid).collection('appointments');
      print('FirestoreService: Adding document with timeout');
      
      final docRef = await collectionRef.add(appointment.toMap()).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Firestore operation timed out after 5 seconds');
        },
      );
      
      print('FirestoreService: Document added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('FirestoreService: Error in createAppointment: $e');
      print('FirestoreService: Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<void> updateAppointment(String uid, String appointmentId, AppointmentModel appointment) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .doc(appointmentId)
        .update(appointment.toMap());
  }

  Future<void> deleteAppointment(String uid, String appointmentId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('appointments')
        .doc(appointmentId)
        .delete();
  }

  // Doctors
  Stream<DoctorModel?> streamDoctor(String uid) {
    return _db
        .collection('doctors')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? DoctorModel.fromFirestore(doc) : null);
  }

  Future<String> createDoctor(DoctorModel doctor) async {
    final docRef = await _db.collection('doctors').doc(doctor.id).set(doctor.toMap());
    return doctor.id;
  }

  Future<void> updateDoctor(DoctorModel doctor) async {
    await _db.collection('doctors').doc(doctor.id).update(doctor.toMap());
  }

  Future<void> addPatientToDoctor(String doctorId, String patientId) async {
    await _db.collection('doctors').doc(doctorId).update({
      'patients': FieldValue.arrayUnion([patientId]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> removePatientFromDoctor(String doctorId, String patientId) async {
    await _db.collection('doctors').doc(doctorId).update({
      'patients': FieldValue.arrayRemove([patientId]),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Doctor appointment management
  Stream<List<AppointmentModel>> streamAllAppointments() {
    return _db
        .collectionGroup('appointments')
        .orderBy('appointmentDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc))
            .toList());
  }

  Future<void> approveAppointment(String userId, String appointmentId, String doctorId, String? doctorNotes) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('appointments')
        .doc(appointmentId)
        .update({
      'status': 'confirmed',
      'approvedBy': doctorId,
      'approvedAt': Timestamp.fromDate(DateTime.now()),
      'doctorNotes': doctorNotes,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> denyAppointment(String userId, String appointmentId, String doctorId, String denialReason) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('appointments')
        .doc(appointmentId)
        .update({
      'status': 'denied',
      'deniedBy': doctorId,
      'deniedAt': Timestamp.fromDate(DateTime.now()),
      'denialReason': denialReason,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> scheduleAppointmentForPatient(String userId, AppointmentModel appointment) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('appointments')
        .doc(appointment.id)
        .set(appointment.toMap());
  }
}