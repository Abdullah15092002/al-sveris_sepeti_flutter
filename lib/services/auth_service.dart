// Firebase Authentication işlemlerini (giriş, kayıt, çıkış) yönetir.
import 'package:alisveris_sepeti/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcının e-posta ve şifre ile giriş yapmasını sağlar.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Yeni bir kullanıcı kaydı oluşturur ve Firestore'da kullanıcı belgesini tetikler.
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
          uid: userCredential.user!.uid,
          email: email.trim(),
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Mevcut kullanıcının oturumunu kapatır.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
