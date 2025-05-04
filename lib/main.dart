import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'utils/router.dart';
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';
import 'providers/group_provider.dart';
import 'services/auth_service.dart';

/// The main function initializes Firebase and sets up providers for a Flutter application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthController(authService: AuthenticationService()),
        ),
      ],
      child: UniCartApp(),
    ),
  );
}

/// The `UniCartApp` class is a StatelessWidget that defines the main application structure for the
/// UniCart app in Dart.
class UniCartApp extends StatelessWidget {
  const UniCartApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    return MaterialApp(
      title: 'UniCart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeController.themeMode,
      initialRoute: '/',
      onGenerateRoute: generateRoute,
    );
  }
}
