import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void loginUser() async {
    if (!_formKey.currentState!.validate()) return;

setState(() => _isLoading = true);

    try {
      await FirebaseServices().login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Грешка при входа. Моля, опитайте отново.')),
      );
      } finally 
      {
    if (mounted) {
      setState(() => _isLoading = false);
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(
                controller: emailController,
                label: 'Имейл',
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: passwordController,
                label: 'Парола',
                obscureText: true,
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 24),
              _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                onPressed: loginUser,
                child: const Text('Вход'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child:
                    const Text('Все още нямате акаунт? Регистрирайте се тук'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
