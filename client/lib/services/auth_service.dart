import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up new user
  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Update display name
      await userCredential.user!.updateDisplayName(fullName.trim());

      // Save user data to Firestore
      await _saveUserDataToFirestore(
        userCredential.user!.uid,
        fullName,
        email,
        phone,
      );

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserDataToFirestore(
    String uid,
    String fullName,
    String email,
    String phone,
  ) async {
    try {
      DocumentReference docRef = _firestore.collection('users').doc(uid);

      await docRef.set({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'role': 'primary_caregiver',
        'profileImageUrl': '',
        'languagePreference': 'en',
        'notificationPreferences': {
          'medicationReminders': true,
          'taskAlerts': false,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'families': [],
      });
    } on FirebaseException catch (e) {
      throw Exception('Firestore error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
