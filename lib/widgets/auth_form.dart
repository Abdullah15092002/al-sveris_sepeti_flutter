// Giriş ve kayıt sayfalarında kullanılan, yeniden kullanılabilir form widget'ı.
import 'package:flutter/material.dart';

class AuthForm extends StatelessWidget {
  final String buttonText;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmitted;
  final String errorMessage;

  const AuthForm({
    super.key,
    required this.buttonText,
    required this.emailController,
    required this.passwordController,
    required this.onSubmitted,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'E-posta'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Şifre'),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onSubmitted, child: Text(buttonText)),
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
