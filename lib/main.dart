import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/sign_in_page.dart';
import 'screens/home_page.dart';

//Uygulama açılınca Firebase sistemini hazırlar.
//Kullanıcı giriş yaptı mı yapmadı mı diye kontrol eder.
//Eğer giriş yaptıysa (HomePage) açılır.
//Eğer yapmadıysa (SignInPage) açılır.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ortak Alışveriş Listesi',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const AuthWrapper(),
    );
  }
}

// Kullanıcı giriş yaptıysa HomePage, yoksa SignInPage
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const SignInPage();
      },
    );
  }
}
