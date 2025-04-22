import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../controllers/theme_controller.dart';
import '../views/grocery_list_screen.dart';
import 'dart:io';

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
  final picker = ImagePicker();
  final user = FirebaseAuth.instance.currentUser;

  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile == null || user == null) return;

  final file = File(pickedFile.path);
  final storageRef = FirebaseStorage.instance
      .ref()
      .child('user_profiles/${user.uid}/profile.jpg');

  try {
    final uploadTask = await storageRef.putFile(file);
    final snapshot = await uploadTask;

    if (snapshot.state == TaskState.success) {
      final photoURL = await snapshot.ref.getDownloadURL();
      await user.updatePhotoURL(photoURL);
      await user.reload();

      setState(() {}); // Refresh UI
      // Update Firestore (not just FirebaseAuth)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'photoURL': photoURL});

      // (Optional) Also update FirebaseAuth if you still want it
      await user.updatePhotoURL(photoURL);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile photo updated!')),
      );
    } else {
      throw Exception("Upload failed. Task state: ${snapshot.state}");
    }
  } catch (e) {
    debugPrint('Upload failed: $e');
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
    Center(child: Text('Budget Page')),
    Center(child: Text('Split Page')),
  ];

  // TO DO: Add functionality to navigate to create group screen
  void _navigateToCreateGroup() {
    Navigator.pushNamed(context, '/join-or-create-group');
  }

  void _navigateToManageGroup() async {
    final result = await Navigator.pushNamed(context, '/manage-groups');

    // If the user deleted/left a group, refresh the state
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
      backgroundColor: _isDarkMode
        ? const Color(0xFF0F0E17)
        : const Color(0xFFEEECF4),
      child: SafeArea(
        child: Column(
        children: [
          Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 10),
          child: Column(
            children: [
            Center(
            child: GestureDetector(
              onTap: _pickAndUploadPhoto,
              child: CircleAvatar(
              radius: 30,
              backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
              child: user?.photoURL == null
                ? Icon(Icons.person, size: 40)
                : null,
              ),
            ),
            ),
            if (user?.displayName != null) ...[
            SizedBox(height: 8),
            Text(user!.displayName ?? 'User',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
                    ),
                    ),
                  ],
                  SizedBox(height: 24),
                  SwitchListTile(
                    title: Text('Appearance'),
                    value: _isDarkMode,
                    onChanged: _toggleTheme,
                    secondary: Icon(Icons.brightness_6),
                  ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.group_add),
                      title: Text('Add/Create Group'),
                      onTap: _navigateToCreateGroup,
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.group),
                      title: Text('Manage Groups'),
                      onTap: _navigateToManageGroup,
                    ),
                  ],
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
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
        leading: Padding(
          padding: EdgeInsets.only(left: 12.0),
          child: IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: CircleAvatar(
              backgroundImage:
            user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child:
            user?.photoURL == null ? Icon(Icons.person, size: 20) : null,
            ),
          ),
        ),
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
        backgroundColor: _isDarkMode
          ? const Color(0xFF0F0E17)
          : const Color(0xFFEEECF4),
        destinations: [
          NavigationDestination(
            icon: IconTheme(
              data: IconThemeData(color: theme.onSurface),
              child: Icon(Icons.list_outlined),
            ),
            selectedIcon: IconTheme(
              data: IconThemeData(color: theme.onSurface),
              child: Icon(Icons.list),
            ),
            label: 'Lists',
          ),
          NavigationDestination(
            icon: IconTheme(
              data: IconThemeData(color: theme.onSurface),
              child: Icon(Icons.attach_money_outlined),
            ),
            selectedIcon: IconTheme(
              data: IconThemeData(color: theme.onSurface),
              child: Icon(Icons.attach_money),
            ),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: IconTheme(
              data: IconThemeData(color: theme.onSurface),
              child: Icon(Icons.money_outlined),
            ),
            selectedIcon: IconTheme(
              data: IconThemeData(color: theme.onSurface),
              child: Icon(Icons.money),
            ),
            label: 'Split',
          ),
        ],
      ),
    );
  }
}
