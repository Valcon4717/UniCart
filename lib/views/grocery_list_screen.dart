import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/list_service.dart';
import '../utils/firestore_utils.dart';
import '../providers/group_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/user_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryListScreen extends StatelessWidget {
  const GroceryListScreen({super.key});

  Future<void> _showAddListDialog(BuildContext context, String groupId) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New List"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'List Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final desc = descriptionController.text.trim();

              if (name.isNotEmpty) {
                await ListService().createList(
                  groupId: groupId,
                  name: name,
                  description: desc,
                  createdBy: userId,
                );
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final groupDoc = groupProvider.group;
    final groupId = groupDoc?.id;
    final groupName = groupDoc?.get('name') ?? 'UniCart';
    final theme = Theme.of(context).colorScheme;

    // TO DO: Add picture when there is no
    if (groupId == null) {
      return const Center(child: Text("No group selected."));
    }

    return Scaffold(
      backgroundColor: theme.surface,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: ListService().getLists(groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allLists = snapshot.data ?? [];
          final pinnedLists =
              allLists.where((list) => list['isPinned'] == true).toList();
          final unpinnedLists =
              allLists.where((list) => list['isPinned'] != true).toList();
          final lists = [...pinnedLists, ...unpinnedLists];

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            itemCount: lists.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    groupName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.onSurface,
                    ),
                  ),
                );
              }

              final list = lists[index - 1];
              final listId = list['id'];

              return Dismissible(
                key: ValueKey(listId),
                direction: DismissDirection.endToStart,
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async => await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete List"),
                    content: const Text(
                        "Are you sure you want to delete this list?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                ),
                onDismissed: (_) async {
                  try {
                    await FirestoreUtils.listCollection(groupId)
                        .doc(listId)
                        .delete();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('List "${list['name']}" deleted')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error deleting list')),
                    );
                  }
                },
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.3),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFFEEECF4)
                      : const Color(0xFF0F0E17),
                  child: ListTile(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/grocery-items',
                        arguments: {
                          'groupId': groupId,
                          'listId': listId,
                          'listName': list['name'],
                        },
                      );
                    },
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      list['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Row(
                      children: [
                        _buildListAvatar(list),
                        const SizedBox(width: 8),
                        const Icon(Icons.list, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "List 0/${list['itemsCount'] ?? 0} Completed",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        list['isPinned'] == true
                            ? Icons.favorite
                            : Icons.favorite_outline,
                        color: theme.primary,
                      ),
                      onPressed: () async {
                        await FirestoreUtils.listCollection(groupId)
                            .doc(listId)
                            .update({
                          'isPinned': !(list['isPinned'] ?? false),
                        });
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddListDialog(context, groupId),
        backgroundColor: theme.primary,
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: theme.surface),
      ),
    );
  }

  Widget _buildListAvatar(Map<String, dynamic> list) {
    final userId = list['createdBy'];
    final photoUrl = list['createdByPhoto'];

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundImage: NetworkImage(photoUrl),
        child: _prefetchLatestAvatar(userId),
      );
    }

    return UserAvatar(
      userId: userId,
      radius: 14,
      useStream: true,
    );
  }

  Widget _prefetchLatestAvatar(String userId) {
    return Opacity(
      opacity: 0,
      child: SizedBox(
        width: 1,
        height: 1,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
          builder: (context, snapshot) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
