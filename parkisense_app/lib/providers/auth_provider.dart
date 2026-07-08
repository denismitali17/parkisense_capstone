import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  AuthNotifier(this._auth, this._firestore) : super(const AsyncValue.data(null));

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      state = AsyncValue.data(credential.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUpWithEmail(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);
      await credential.user?.sendEmailVerification();
      
      // Store user data in Firestore
      await _firestore.collection('users').doc(credential.user?.uid).set({
        'name': name,
        'email': email,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
      
      state = AsyncValue.data(credential.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // 1. Handle user cancellation (closing the popup window) gracefully
      if (googleUser == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 2. Only proceed if tokens are present, preventing unexpected null errors
      if (googleAuth.accessToken != null || googleAuth.idToken != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await _auth.signInWithCredential(credential);
        
        // Store user data in Firestore if new user
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await _firestore.collection('users').doc(userCredential.user?.uid).set({
            'name': userCredential.user?.displayName ?? 'User',
            'email': userCredential.user?.email,
            'createdAt': DateTime.now(),
            'updatedAt': DateTime.now(),
          });
        }
        
        state = AsyncValue.data(userCredential.user);
      } else {
        throw Exception("Missing authentication tokens from Google provider.");
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> updateUserProfile({
    required String newName,
    required String newEmail,
    String? newPassword,
  }) async {
    state = const AsyncValue.loading();
    try {
      User? user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Update email if changed
      if (newEmail != user.email) {
        await user.updateEmail(newEmail);
      }

      // Update password if provided
      if (newPassword != null && newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }

      // Update display name
      await user.updateDisplayName(newName);

      // Update Firestore document
      await _firestore.collection('users').doc(user.uid).update({
        'name': newName,
        'email': newEmail,
        'updatedAt': DateTime.now(),
      });

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});