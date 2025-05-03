import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../views/grocery_item_screen.dart';
import '../providers/grocery_item_provider.dart';
import '../services/grocery_item_service.dart';
import '../views/home_screen.dart';
import '../views/login_screen.dart';
import '../views/register_screen.dart';
import '../views/onboarding_screen.dart';
import '../views/landing_screen.dart';
import '../views/budget_screen.dart';
import '../views/split_screen.dart';
import '../views/settings_screen.dart';
import '../views/create_group_screen.dart';
import '../views/manage_groups_screen.dart';
import '../views/join_or_create_group_screen.dart';
import '../utils/auth_gate.dart';

Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const AuthGate());
    case '/home':
      return MaterialPageRoute(builder: (_) => const HomeScreen());

    case '/grocery-items':
      final args = settings.arguments as Map<String, dynamic>;
      final listId = args['listId'];
      final listName = args['listName'];
      final groupId = args['groupId'];

      return MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => GroceryItemProvider(
            groceryItemService: GroceryItemService(),
            listId: listId,
            groupId: groupId,
          ),
          child: GroceryItemScreen(listName: listName),
        ),
      );

    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginScreen());

    case '/register':
      return MaterialPageRoute(builder: (_) => const RegisterScreen());

    case '/onboarding':
      return MaterialPageRoute(builder: (_) => const OnboardingScreen());

    case '/landing':
      return MaterialPageRoute(builder: (_) => const LandingScreen());

    case '/budget':
      return MaterialPageRoute(builder: (_) => const BudgetScreen());

    case '/split':
      return MaterialPageRoute(builder: (_) => const SplitScreen());

    case '/settings':
      return MaterialPageRoute(builder: (_) => const SettingsScreen());

    case '/create-group':
      return MaterialPageRoute(
        builder: (_) => CreateGroupScreen(groupId: '', groupName: ''),
      );

    case '/join-or-create-group':
      return MaterialPageRoute(builder: (_) => const JoinOrCreateGroupScreen());

    case '/manage-groups':
      return MaterialPageRoute(builder: (_) => const ManageGroupsScreen());

    default:
      return null;
  }
}
