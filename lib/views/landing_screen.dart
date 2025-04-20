import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _textOffset;
  late Animation<Offset> _buttonOffset;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textOffset = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _buttonOffset = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 230),

              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _fadeIn.value,
                  child: SlideTransition(
                    position: _textOffset,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Welcome to",
                            style: textTheme.headlineMedium?.copyWith(
                              fontSize: 57,
                              fontWeight: FontWeight.w500,
                              color: theme.onSurface,
                            ),
                          ),
                          Text(
                            "UniCart",
                            style: textTheme.displaySmall?.copyWith(
                              fontSize: 57,
                              fontWeight: FontWeight.w500,
                              color: theme.tertiary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text.rich(
                            TextSpan(
                              text: "Shared groceries ",
                              style: textTheme.bodyLarge?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 1.33,
                                color: theme.onSurface,
                              ),
                              children: [
                                TextSpan(
                                  text: "made simple",
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    height: 1.33,
                                    color: theme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),
              // Button animation
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Opacity(
                  opacity: _fadeIn.value,
                  child: SlideTransition(
                    position: _buttonOffset,
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: theme.onPrimary,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/onboarding');
                          },
                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: theme.primary,
                            ),
                            child: const Text(
                              "Log in",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
