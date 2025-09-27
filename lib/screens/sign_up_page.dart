// Yeni kullanıcıların e-posta ve şifre ile uygulamaya kaydolmasını sağlar.
import 'package:alisveris_sepeti/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alisveris_sepeti/services/auth_service.dart';
import 'package:alisveris_sepeti/widgets/auth_form.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Yeni kullanıcı kayıt bilgilerini AuthService'e gönderir.
  Future<void> _signUp() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final errorMessage = await authService.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      // Not: AuthService'deki signUp metodunun da sadece email ve password aldığından emin ol.
    );

    if (errorMessage == null && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      setState(() {
        _errorMessage = errorMessage!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      imagePath: 'assets/images/sign_in_sign_up.jpeg',
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.all(20),
            elevation: 8,
            color: Colors.white.withOpacity(0.9),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: AuthForm(
              buttonText: 'Kayıt Ol',
              emailController: _emailController,
              passwordController: _passwordController,
              onSubmitted: _signUp,
              errorMessage: _errorMessage,
            ),
          ),
        ),
      ),
    );
  }
}
