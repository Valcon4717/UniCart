import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'views/landing_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeController()),
      ChangeNotifierProvider(
        create: (_) => AuthController(authService: AuthenticationService()),
      ),
    ],
    child: const UniCartApp(),
  ),
);}

class UniCartApp extends StatelessWidget {
  const UniCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniCart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const LandingScreen(),
    );
  }
}