import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/screening_model.dart';
import '../models/appointment_model.dart';
import '../models/doctor_model.dart';
import '../models/chat_message_model.dart';
import '../models/chat_conversation_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  Stream<List<ScreeningModel>> streamAllScreenings() {
    return _db
        .collectionGroup('screenings')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final screenings = snapshot.docs
              .map((doc) => ScreeningModel.fromMap(doc.data()))
              .toList();
          print('FirestoreService: Total screenings: ${screenings.length}');
          final uniqueUserIds = screenings.map((s) => s.userId).toSet();
          print('FirestoreService: Unique user IDs: $uniqueUserIds');
          return screenings;
        });
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

  // Get user info by ID (for patient names)
  Future<Map<String, dynamic>?> getUserInfo(String uid) async {
    print('FirestoreService: Getting user info for uid: $uid');
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      print('FirestoreService: User data keys: ${data?.keys.toList()}');
      print('FirestoreService: User data: $data');
      print('FirestoreService: Name field: ${data?['name']}');
      print('FirestoreService: DisplayName field: ${data?['displayName']}');
      print('FirestoreService: Email field: ${data?['email']}');
      
      // If Firestore document is empty, return null so we can use fallback display
      if (data == null || data.isEmpty) {
        print('FirestoreService: Firestore document is empty for uid: $uid');
        return null;
      }
      
      return data;
    }
    print('FirestoreService: User document does not exist for uid: $uid');
    return null;
  }

  // Stream user info by ID (for real-time updates)
  Stream<Map<String, dynamic>?> streamUserInfo(String uid) {
    print('FirestoreService: Streaming user info for uid: $uid');
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data();
        if (data == null || data.isEmpty) {
          print('FirestoreService: Stream - Firestore document is empty for uid: $uid');
          return null;
        }
        print('FirestoreService: Stream - User data for uid: $uid: $data');
        return data;
      }
      print('FirestoreService: Stream - User document does not exist for uid: $uid');
      return null;
    });
  }

  // Update user name (admin function to add missing names)
  Future<void> updateUserName(String uid, String name) async {
    print('FirestoreService: Updating name for uid: $uid to: $name');
    try {
      await _db.collection('users').doc(uid).set({
        'name': name,
        'updatedAt': DateTime.now(),
      }, SetOptions(merge: true));
      print('FirestoreService: Name updated successfully');
    } catch (e) {
      print('FirestoreService: Error updating name: $e');
      rethrow;
    }
  }

  // Get screenings for a specific user
  Stream<List<ScreeningModel>> streamScreeningsForUser(String uid) {
    print('FirestoreService: Streaming screenings for uid: $uid');
    return _db
        .collection('users')
        .doc(uid)
        .collection('screenings')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          print('FirestoreService: Got ${snapshot.docs.length} screenings for uid: $uid');
          return snapshot.docs
              .map((doc) => ScreeningModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Chat functionality
  // Get or create conversation between user and doctor
  Future<String> getOrCreateConversation(String userId, String userName, String doctorId, String doctorName) async {
    print('FirestoreService: Getting or creating conversation for user: $userId, doctor: $doctorId');
    
    // Try to find existing conversation
    final existingConv = await _db
        .collection('conversations')
        .where('userId', isEqualTo: userId)
        .where('doctorId', isEqualTo: doctorId)
        .limit(1)
        .get();
    
    if (existingConv.docs.isNotEmpty) {
      print('FirestoreService: Found existing conversation: ${existingConv.docs.first.id}');
      return existingConv.docs.first.id;
    }
    
    // Create new conversation
    print('FirestoreService: Creating new conversation');
    final newConversation = ChatConversationModel(
      id: '',
      userId: userId,
      userName: userName,
      doctorId: doctorId,
      doctorName: doctorName,
      lastMessageTime: DateTime.now(),
      createdAt: DateTime.now(),
    );
    
    final docRef = await _db.collection('conversations').add(newConversation.toMap());
    print('FirestoreService: Created conversation with ID: ${docRef.id}');
    return docRef.id;
  }

  // Send message
  Future<void> sendMessage(String conversationId, ChatMessageModel message) async {
    print('FirestoreService: Sending message to conversation: $conversationId');
    await _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add(message.toMap());
    
    // Update conversation metadata
    await _db.collection('conversations').doc(conversationId).update({
      'lastMessage': message.text,
      'lastMessageTime': Timestamp.fromDate(message.timestamp),
      if (message.senderType == 'user') 'unreadDoctorCount': FieldValue.increment(1),
      if (message.senderType == 'doctor') 'unreadUserCount': FieldValue.increment(1),
    });
    
    print('FirestoreService: Message sent successfully');
  }

  // Stream messages for a conversation
  Stream<List<ChatMessageModel>> streamMessages(String conversationId) {
    print('FirestoreService: Streaming messages for conversation: $conversationId');
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromFirestore(doc))
            .toList());
  }

  // Stream conversations for a doctor
  Stream<List<ChatConversationModel>> streamDoctorConversations(String doctorId) {
    print('FirestoreService: Streaming conversations for doctor: $doctorId');
    return _db
        .collection('conversations')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatConversationModel.fromFirestore(doc))
            .toList());
  }

  // Stream conversation for a specific user
  Stream<ChatConversationModel?> streamUserConversation(String userId, String doctorId) {
    print('FirestoreService: Streaming conversation for user: $userId with doctor: $doctorId');
    return _db
        .collection('conversations')
        .where('userId', isEqualTo: userId)
        .where('doctorId', isEqualTo: doctorId)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty 
            ? ChatConversationModel.fromFirestore(snapshot.docs.first) 
            : null);
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, String userType) async {
    print('FirestoreService: Marking messages as read for conversation: $conversationId by: $userType');
    
    // Update unread count
    if (userType == 'user') {
      await _db.collection('conversations').doc(conversationId).update({
        'unreadUserCount': 0,
      });
    } else if (userType == 'doctor') {
      await _db.collection('conversations').doc(conversationId).update({
        'unreadDoctorCount': 0,
      });
    }
    
    // Mark individual messages as read
    final messages = await _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get();
    
    for (var doc in messages.docs) {
      await doc.reference.update({'isRead': true});
    }
    
    print('FirestoreService: Messages marked as read');
  }

  // Get doctor info by ID
  Future<Map<String, dynamic>?> getDoctorInfo(String uid) async {
    print('FirestoreService: Getting doctor info for uid: $uid');
    final doc = await _db.collection('doctors').doc(uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }
}