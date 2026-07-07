import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/screening_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
}