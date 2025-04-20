import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  late final List<Map<String, String>> pagesData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    pagesData = [
      {
        "image": isDark
            ? "assets/images/first_dark.png"
            : "assets/images/first_light.png",
        "title": "Build shared grocery lists",
        "caption":
            "Create lists together in real-time.\nAdd items, track prices, and avoid duplicate runs."
      },
      {
        "image": isDark
            ? "assets/images/second_dark.png"
            : "assets/images/second_light.png",
        "title": "Set a budget, track your spend",
        "caption":
            "Stick to your weekly grocery budget with real-time updates and progress tracking."
      },
      {
        "image": isDark
            ? "assets/images/third_dark.png"
            : "assets/images/third_light.png",
        "title": "Split and settle with ease",
        "caption":
            "See who paid and who owes. Easily track group contributions after each trip."
      },
    ];
  }

  Future<void> _completeSetup(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSetupComplete', true);
    Navigator.pushNamed(context, '/');
  }

  void _onNextPressed() {
    if (_currentIndex < pagesData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeSetup(context);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: theme.onSurface,
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: pagesData.length,
                itemBuilder: (context, index) {
                  final data = pagesData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 32.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          data["image"]!,
                          height: 220,
                        ),
                        const SizedBox(height: 48),
                        Text(
                          data["title"]!,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data["caption"]!,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: theme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.60,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots indicator
            SmoothPageIndicator(
              controller: _pageController,
              count: pagesData.length,
              effect: WormEffect(
                activeDotColor: theme.primary,
                dotColor: Colors.grey,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),
            const SizedBox(height: 24),

            // Continue button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentIndex == pagesData.length - 1) {
                    Navigator.pushNamed(context, '/register');
                  } else {
                    _onNextPressed();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: theme.onPrimary,
                  minimumSize: Size.fromHeight(48),
                ),
                child: Text(
                  _currentIndex == pagesData.length - 1
                      ? "Get Started"
                      : "Continue",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
