// Kullanıcının e-posta ve şifre ile uygulamaya giriş yapmasını sağlar.
import 'package:alisveris_sepeti/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alisveris_sepeti/services/auth_service.dart';
import 'package:alisveris_sepeti/screens/sign_up_page.dart';
import 'package:alisveris_sepeti/widgets/auth_form.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Kullanıcı giriş bilgilerini AuthService'e gönderir.
  Future<void> _signIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final errorMessage = await authService.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (errorMessage != null && mounted) {
      setState(() {
        _errorMessage = errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      imagePath: 'assets/images/sign_in_sign_up.jpeg',
      appBar: AppBar(
        title: const Text('Giriş Yap'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                margin: const EdgeInsets.all(20),
                elevation: 8,
                color: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: AuthForm(
                  buttonText: 'Giriş Yap',
                  emailController: _emailController,
                  passwordController: _passwordController,
                  onSubmitted: _signIn,
                  errorMessage: _errorMessage,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  );
                },
                child: const Text(
                  'Hesabın yok mu? Kayıt Ol',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 2)]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
