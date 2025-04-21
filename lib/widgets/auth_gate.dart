import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/group_service.dart';
import '../providers/group_provider.dart';
import 'package:provider/provider.dart';
import '../views/home_screen.dart';
import '../views/landing_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _groupLoaded = false;

  Future<void> _loadSavedGroup() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGroupId = prefs.getString('currentGroupId');

    if (savedGroupId != null) {
      final groupDoc = await GroupService().getGroup(savedGroupId);
      if (groupDoc.exists) {
        Provider.of<GroupProvider>(context, listen: false).setGroup(groupDoc);
      } else {
        await prefs.remove('currentGroupId');
      }
    }

    setState(() {
      _groupLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedGroup();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still checking auth
        if (snapshot.connectionState == ConnectionState.waiting || !_groupLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Authenticated and group is loaded
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Not logged in
        return const LandingScreen();
      },
    );
  }
}