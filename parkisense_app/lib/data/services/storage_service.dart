import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadAudioDump(String userId, File file) async {
    final ref = _storage
        .ref()
        .child('users/$userId/audio/${DateTime.now().millisecondsSinceEpoch}.wav');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}