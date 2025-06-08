import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseServices().register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Грешка при регистрацията. Моля, опитайте отново.')),
      );
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
                controller: nameController,
                label: 'Име',
                validator: Validators.validateNotEmpty,
              ),
              const SizedBox(height: 16),
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
              ElevatedButton(
                onPressed: registerUser,
                child: const Text('Регистрация'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Вече имате акаунт? Влезте'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
