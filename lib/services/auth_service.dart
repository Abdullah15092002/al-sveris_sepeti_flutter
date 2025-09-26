import 'package:alisveris_sepeti/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Başarılıysa null döner
    } on FirebaseAuthException catch (e) {
      return e.message; // Hata mesajını döner
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (userCredential.user != null) {
        await UserService().createUserDocument(
          userCredential.user!.uid,
          email.trim(),
        );
      }

      return null; // Başarılıysa null döner
    } on FirebaseAuthException catch (e) {
      return e.message; // Hata mesajını döner
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
