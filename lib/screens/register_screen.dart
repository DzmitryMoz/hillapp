// lib/screens/register_screen.dart

import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const RegisterScreen({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  String? errorText;
  bool isLoading = false;

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
        errorText = null;
      });
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => isLoading = false);
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Сменить тему',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (errorText != null)
                Text(errorText!,
                    style: const TextStyle(color: Colors.red)),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Имя'),
                onChanged: (val) => name = val,
                validator: (val) =>
                (val == null || val.isEmpty) ? 'Введите имя' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (val) => email = val,
                validator: (val) =>
                (val == null || val.isEmpty) ? 'Введите email' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                onChanged: (val) => password = val,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Введите пароль';
                  }
                  if (val.length < 6) {
                    return 'Минимум 6 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _register,
                child: const Text('Зарегистрироваться'),
              ),
              TextButton(
                onPressed: _goBack,
                child: const Text('Уже есть аккаунт? Войдите'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
