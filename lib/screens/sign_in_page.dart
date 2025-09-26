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
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AuthForm(
              buttonText: 'Giriş Yap',
              emailController: _emailController,
              passwordController: _passwordController,
              onSubmitted: _signIn,
              errorMessage: _errorMessage,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpPage()),
                );
              },
              child: const Text('Hesabın yok mu? Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}
