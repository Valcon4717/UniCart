import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/group_provider.dart';
import '../services/group_service.dart';
import 'create_group_screen.dart';

/// StatefulWidget that allows users to create or join a
/// group using group name and code inputs.
class JoinOrCreateGroupScreen extends StatefulWidget {
  const JoinOrCreateGroupScreen({super.key});

  @override
  State<JoinOrCreateGroupScreen> createState() =>
      _JoinOrCreateGroupScreenState();
}

class _JoinOrCreateGroupScreenState extends State<JoinOrCreateGroupScreen> {
  final _groupNameController = TextEditingController();
  final _groupCodeController = TextEditingController();
  final userId = FirebaseAuth.instance.currentUser!.uid;

  String? _nameError;
  String? _codeError;
  bool _isLoading = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupCodeController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) return;

    final groupService = GroupService(userId: userId);
    final groupId = await groupService.createGroup(groupName);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateGroupScreen(
          groupId: groupId,
          groupName: groupName,
        ),
      ),
    );
  }

  Future<void> _joinGroup() async {
    final code = _groupCodeController.text.trim();
    if (code.isEmpty) {
      setState(() => _codeError = 'Please enter a group code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _codeError = null;
    });

    try {
      final groupService = GroupService(userId: userId);
      final groupDoc = await groupService.joinGroup(code);

      if (groupDoc != null) {
        Provider.of<GroupProvider>(context, listen: false).setGroup(groupDoc);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentGroupId', groupDoc.id);
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      } else {
        setState(() => _codeError = 'Group not found.');
      }
    } catch (e) {
      setState(
          () => _codeError = 'Unable to join group. Please check the code.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: theme.primary,
        ),
        elevation: 0,
        backgroundColor: theme.surface,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          children: [
            Text(
              "Create Your Group",
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Create a shared space to manage your grocery lists, budgets, and group expenses.",
              style: textTheme.bodyMedium?.copyWith(
                color: theme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.60,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                errorText: _nameError,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
                minimumSize: Size.fromHeight(48),
              ),
              onPressed: _isLoading ? null : _createGroup,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text("Create Group",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 40),
            Text(
              "Have an invite already?",
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Enter a group code to join your shared grocery space.",
              style: textTheme.bodyMedium?.copyWith(
                color: theme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.60,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _groupCodeController,
              decoration: InputDecoration(
                labelText: 'Group Code',
                errorText: _codeError,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
                minimumSize: Size.fromHeight(48),
              ),
              child: Text("Join Group",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
