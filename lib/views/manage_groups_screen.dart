import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../services/group_service.dart';
import '../providers/group_provider.dart';

class ManageGroupsScreen extends StatefulWidget {
  const ManageGroupsScreen({super.key});

  @override
  State<ManageGroupsScreen> createState() => _ManageGroupsScreenState();
}

class _ManageGroupsScreenState extends State<ManageGroupsScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  List<DocumentSnapshot> _groups = [];
  bool _isLoading = true;
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    final groups = await GroupService(userId: userId).getUserGroups();
    final currentGroup = Provider.of<GroupProvider>(context, listen: false).group;
    setState(() {
      _groups = groups;
      _selectedGroupId = currentGroup?.id;
      _isLoading = false;
    });
  }

  Future<void> _confirmAndDelete(String groupId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text('Are you sure you want to delete this group?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) await _deleteGroup(groupId);
  }

  Future<void> _confirmAndLeave(String groupId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Leave')),
        ],
      ),
    );
    if (confirmed == true) await _leaveGroup(groupId);
  }

  Future<void> _leaveGroup(String groupId) async {
    try {
      await GroupService(userId: userId).leaveGroup(groupId);

      final currentGroup = Provider.of<GroupProvider>(context, listen: false).group;
      if (currentGroup?.id == groupId) {
        Provider.of<GroupProvider>(context, listen: false).clearGroup();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('currentGroupId');
        if (mounted) {
          Navigator.pop(context, 'group_changed');
        }
      } else {
        _fetchGroups();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Left group successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to leave the group. Please try again.')),
      );
    }
  }

  Future<void> _deleteGroup(String groupId) async {
    try {
      await GroupService(userId: userId).deleteGroup(groupId);

      final currentGroup = Provider.of<GroupProvider>(context, listen: false).group;
      if (currentGroup?.id == groupId) {
        Provider.of<GroupProvider>(context, listen: false).clearGroup();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('currentGroupId');
        if (mounted) {
          Navigator.pop(context, 'group_changed');
        }
      } else {
        _fetchGroups();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted group successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete the group. Please try again.')),
      );
    }
  }

  void _selectGroup(DocumentSnapshot group) async {
    Provider.of<GroupProvider>(context, listen: false).setGroup(group);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentGroupId', group.id);
    setState(() => _selectedGroupId = group.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Switched to group: ${group['name']}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Groups'),
        backgroundColor: theme.surface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final group = _groups[index];
                final groupName = group['name'];
                final isCreator = group['createdBy'] == userId;

                return Dismissible(
                  key: Key(group.id),
                  background: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit not yet implemented.')),
                      );
                      return false;
                    } else {
                      if (isCreator) {
                        await _confirmAndDelete(group.id);
                      } else {
                        await _confirmAndLeave(group.id);
                      }
                      return false;
                    }
                  },
                  child: RadioListTile(
                    title: Text(groupName),
                    value: group.id,
                    groupValue: _selectedGroupId,
                    onChanged: (_) => _selectGroup(group),
                  ),
                );
              },
            ),
    );
  }
}