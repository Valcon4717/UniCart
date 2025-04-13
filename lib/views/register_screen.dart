import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  Future<void> _register() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate
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

    if (confirmPassword != password) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match.';
        _isLoading = false;
      });
      return;
    }

    // Proceed with Firebase registration
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.register(email, password);

    setState(() {
      _isLoading = false;
    });

    if (authController.error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _emailError = authController.error;
        _passwordError = authController.error;
        _confirmPasswordError = authController.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
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
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: const OutlineInputBorder(),
                errorText: _confirmPasswordError,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Register"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Already have an account? Log in"),
            ),
          ],
        ),
      ),
    );
  }
}