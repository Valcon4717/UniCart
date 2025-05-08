import 'package:flutter/material.dart';
import '../services/add_group_service.dart';

/// The ShareGroupDialog class in Dart represents a dialog for sharing a group and inviting users,
/// displaying group members, and providing actions for each member.
class ShareGroupDialog extends StatefulWidget {
  final String groupId;

  const ShareGroupDialog({super.key, required this.groupId});

  @override
  State<ShareGroupDialog> createState() => _ShareGroupDialogState();
}

class _ShareGroupDialogState extends State<ShareGroupDialog> {
  final TextEditingController _emailController = TextEditingController();
  final AddGroupService _groupService = AddGroupService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _inviteUser() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _groupService.inviteUser(widget.groupId, email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User invited successfully')),
        );
        _emailController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Share Group',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter email to invite',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _inviteUser,
                      ),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _inviteUser(),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Group Members',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _groupService.getGroupMembers(widget.groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No members in this group yet'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final member = snapshot.data![index];
                    return _UserRow(
                      name: member['name'] ?? 'Unknown',
                      imageUrl: member['photoURL'] ?? '',
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final String name;
  final String imageUrl;

  const _UserRow({required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
                imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            child: imageUrl.isEmpty ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'viewer', child: Text('Make Viewer')),
              PopupMenuItem(value: 'remove', child: Text('Remove')),
            ],
            child: const Text('Actions', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
