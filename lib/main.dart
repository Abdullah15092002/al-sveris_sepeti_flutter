import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/sign_in_page.dart';
import 'screens/home_page.dart';
import 'services/auth_service.dart';
import 'services/list_service.dart';
import 'services/user_service.dart';
import 'services/group_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // DEĞİŞİKLİK: Uygulama genelinde servisleri erişilebilir kılmak için MultiProvider kullanılıyor.
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ListService>(create: (_) => ListService()),
        Provider<UserService>(create: (_) => UserService()),
        Provider<GroupService>(create: (_) => GroupService()),
      ],
      child: MaterialApp(
        title: 'Ortak Alışveriş Listesi',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: const AuthWrapper(),
      ),
    );
  }
}

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
