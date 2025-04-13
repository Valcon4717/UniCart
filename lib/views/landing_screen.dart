import 'package:flutter/material.dart';
import 'login_screen.dart'; // Make sure these paths are correct
import 'onboarding_screen.dart'; // For your "Continue" navigation
import '../widgets/auth_gate.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              "Welcome to",
              style: textTheme.headlineMedium?.copyWith(
              fontSize: 57,
              fontWeight: FontWeight.w500,
              height: 1.12,
              letterSpacing: -0.25,
              color: cs.onSurface,
              ),
            ),
            Text(
              "UniCart",
              style: textTheme.displaySmall?.copyWith(
              fontSize: 57,
              fontWeight: FontWeight.w500,
              height: 1.12,
              letterSpacing: -0.25,
              color: cs.tertiary,
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: "Shared groceries ",
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                  color: cs.onSurface,
                ),
                children: [
                  TextSpan(
                    text: "made simple",
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 90),
            Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/images/land_dark.png'
                  : 'assets/images/land_light.png',
              height: 220,
            ),
            const SizedBox(height: 90),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthGate()),
                );
              },
              child: const Text("Continue"),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: const Text("Log in"),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
