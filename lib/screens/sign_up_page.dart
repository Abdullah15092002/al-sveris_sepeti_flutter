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

  Future<void> _signUp() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final errorMessage = await authService.signUp(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (errorMessage == null && mounted) {
      // Başarılı olursa geri dön
      Navigator.pop(context);
    } else if (mounted) {
      setState(() {
        _errorMessage = errorMessage!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SingleChildScrollView(
        child: AuthForm(
          buttonText: 'Kayıt Ol',
          emailController: _emailController,
          passwordController: _passwordController,
          onSubmitted: _signUp,
          errorMessage: _errorMessage,
        ),
      ),
    );
  }
}
