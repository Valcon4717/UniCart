import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _emailError = 'Please enter a valid email.';
        _isLoading = false;
      });
      return;
    }

    if (password.isEmpty || password.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters.';
        _isLoading = false;
      });
      return;
    }

    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.login(email, password);

    setState(() {
      _isLoading = false;
      if (authController.error != null) {
        _emailError = authController.error;
        _passwordError = authController.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null) ...[
                Text(_error!, style: TextStyle(color: cs.error)),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: const OutlineInputBorder(),
                  errorText: _emailError,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  errorText: _passwordError,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Log In"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text("Don’t have an account? Register here"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
