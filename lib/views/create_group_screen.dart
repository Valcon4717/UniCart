import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../services/group_service.dart';
import '../providers/group_provider.dart';

class CreateGroupScreen extends StatelessWidget {
  final String groupId;
  final String groupName;

  const CreateGroupScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });
  

  void _shareInviteLink(BuildContext context) async {
    try {
      final link = 'https://unicart.app/join?group=$groupId';
      await Share.share('Join my UniCart group "$groupName": $link');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing: $e')),
      );
    }
  }

  Future<void> _finishSetup(BuildContext context) async {
    final groupDoc = await GroupService().getGroup(groupId);
    if (groupDoc.exists) {
      Provider.of<GroupProvider>(context, listen: false).setGroup(groupDoc);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentGroupId', groupDoc.id);
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load group. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: theme.primary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              groupName,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Your group has been created! Share the invite link below to let others join.",
              style: textTheme.bodyMedium?.copyWith(
                color: theme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.60,
              ),
            ),
            SizedBox(height: 32),
            TextField(
              readOnly: true,
              controller: TextEditingController(
                  text: 'https://unicart.app/join?group=$groupId'),
              decoration: InputDecoration(
                labelText: "Invite Link",
                suffixIcon: IconButton(
                  icon: Icon(Icons.link),
                  onPressed: () {
                    // Copy link to clipboard
                    Clipboard.setData(ClipboardData(
                        text: 'https://unicart.app/join?group=$groupId'));

                    // Show SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Copied link successfully!")),
                    );
                  },
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            SizedBox(height: 20),

            // Group Code field with copy icon
            TextField(
              readOnly: true,
              controller: TextEditingController(text: groupId),
              decoration: InputDecoration(
                labelText: "Group Code",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: groupId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Group code copied!")),
                    );
                  },
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _shareInviteLink(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
                minimumSize: Size.fromHeight(48),
              ),
              child: Text(
                "Share Invite Link",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () => _finishSetup(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.tertiary,
                foregroundColor: theme.onSurface,
                minimumSize: Size.fromHeight(48),
              ),
              child: Text(
                "Let’s get started",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
