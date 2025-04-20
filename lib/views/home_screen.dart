import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  final List<Widget> _screens = const [
    Center(child: Text('Lists Page')),
    Center(child: Text('Budget Page')),
    Center(child: Text('Split Page')),
    Center(child: Text('Settings Page')),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UniCart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[_selectedIndex], // ← only this part updates!
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        height: 70,
        surfaceTintColor: theme.surface,
        indicatorColor: theme.primaryContainer,
        destinations: [
          NavigationDestination(
            icon: IconTheme(
              data: IconThemeData(color: theme.onSurface),
              child: const Icon(Icons.list_outlined),
            ),
            selectedIcon: IconTheme(
              data: IconThemeData(color: theme.onSurface),
              child: const Icon(Icons.list),
            ),
            label: 'Lists',
          ),
          NavigationDestination(
            icon: IconTheme(
              data: IconThemeData(color: theme.onSurface),
              child: const Icon(Icons.attach_money_outlined),
            ),
            selectedIcon: IconTheme(
              data: IconThemeData(color: theme.onSurface),
              child: const Icon(Icons.attach_money),
            ),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: IconTheme(
              data: IconThemeData(color: theme.onSurface),
              child: const Icon(Icons.money_outlined),
            ),
            selectedIcon: IconTheme(
              data: IconThemeData(color: theme.onSurface),
              child: const Icon(Icons.money),
            ),
            label: 'Split',
          ),
          NavigationDestination(
            icon: IconTheme(
              data: IconThemeData(color: theme.onSurface),
              child: const Icon(Icons.settings_outlined),
            ),
            selectedIcon: IconTheme(
              data: IconThemeData(color: theme.onSurface),
              child: const Icon(Icons.settings),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
