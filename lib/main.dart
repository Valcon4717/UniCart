import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';
import 'package:provider/provider.dart';
import 'providers/group_provider.dart';
import 'services/auth_service.dart';
import 'views/landing_screen.dart';
import 'views/login_screen.dart';
import 'views/onboarding_screen.dart';
import 'views/register_screen.dart';
import 'utils/auth_gate.dart';
import 'views/home_screen.dart';
import 'views/budget_screen.dart';
import 'views/split_screen.dart';
import 'views/settings_screen.dart';
import 'views/create_group_screen.dart';
import 'views/manage_groups_screen.dart';
import 'views/join_or_create_group_screen.dart';
import 'views/grocery_item_screen.dart';
import 'providers/grocery_item_provider.dart';
import 'services/grocery_item_service.dart';

/// The main function initializes Firebase and sets up providers for a Flutter application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
);}

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
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/landing': (context) => const LandingScreen(),
        '/budget': (context) => const BudgetScreen(),
        '/split': (context) => const SplitScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/create-group': (context) => CreateGroupScreen( 
          groupId: '',
          groupName: '',
        ),
        '/join-or-create-group': (context) => const JoinOrCreateGroupScreen(),
        '/manage-groups': (context) => const ManageGroupsScreen(),
        '/grocery-items': (context) => ChangeNotifierProvider(
          create: (_) => GroceryItemProvider(groceryItemService: GroceryItemService()),
          child: GroceryItemScreen(),
        ),
      },
    );
  }
}