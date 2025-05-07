import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';
import '../services/user_service.dart';
import '../views/grocery_list_screen.dart';
import '../views/share_group_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  Future<void> _pickAndUploadPhoto() async {
    final userService = UserService();
    try {
      final photoUrl = await userService.uploadProfilePhoto();

      final user = FirebaseAuth.instance.currentUser;
      await user?.updatePhotoURL(photoUrl);
      await user?.reload();

      setState(() {}); // Refresh UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }
  final List<Widget> _screens = const [
    GroceryListScreen(),
    Center(
      child: Text(
        '🚧 Budget Under Construction 🚧',
        style: TextStyle(fontSize: 18),
      ),
    ),
    Center(
      child: Text(
        '🚧 Split Under Construction 🚧',
        style: TextStyle(fontSize: 18),
      ),
    ),
  ];

  void _navigateToCreateGroup() {
    Navigator.pushNamed(context, '/join-or-create-group');
  }

  void _showAddGroupDialog() async {
    String currentGroupId = await _getCurrentGroupId();

    if (currentGroupId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or create a group first')),
      );
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => ShareGroupDialog(groupId: currentGroupId),
      );
    }
  }

  Future<String> _getCurrentGroupId() async {
    return 'current_group_id';
  }

  void _navigateToManageGroup() async {
    final result = await Navigator.pushNamed(context, '/manage-groups');

    if (result == 'group_changed') {
      setState(() {});
    }
  }

  void _toggleTheme(bool value) {
    final themeController =
        Provider.of<ThemeController>(context, listen: false);
    themeController.toggleTheme(value ? ThemeMode.dark : ThemeMode.light);

    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final themeController = Provider.of<ThemeController>(context);

    _isDarkMode = themeController.themeMode == ThemeMode.dark;
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor:
            _isDarkMode ? const Color(0xFF0F0E17) : const Color(0xFFEEECF4),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Column(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickAndUploadPhoto,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                      ),
                    ),
                    if (user?.displayName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        user!.displayName ?? 'User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: const Text('Appearance'),
                      value: _isDarkMode,
                      onChanged: _toggleTheme,
                      secondary: const Icon(Icons.brightness_6),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.group_add),
                      title: const Text('Add/Create Group'),
                      onTap: _navigateToCreateGroup,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: const Text('Manage Groups'),
                      onTap: _navigateToManageGroup,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () => _logout(context),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.group_add),
              tooltip: 'Add to group',
              onPressed: _showAddGroupDialog,
            ),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        surfaceTintColor: theme.surface,
        indicatorColor: theme.primaryContainer,
        backgroundColor:
            _isDarkMode ? const Color(0xFF0F0E17) : const Color(0xFFEEECF4),
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
        ],
      ),
    );
  }
}
