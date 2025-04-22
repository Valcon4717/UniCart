import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/grocery_service.dart';
import '../providers/group_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
                await GroceryService().createList(
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
    final groupId = Provider.of<GroupProvider>(context).group?.id;
    final theme = Theme.of(context).colorScheme;

    if (groupId == null) {
      return const Center(child: Text("No group selected."));
    }

    return Scaffold(
      backgroundColor: theme.surface,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: GroceryService().getLists(groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allLists = snapshot.data ?? [];

          if (allLists.isEmpty) {
            return const Center(child: Text("No grocery lists yet."));
          }

          // Separate pinned and unpinned lists
          final pinnedLists =
              allLists.where((list) => list['isPinned'] == true).toList();
          final unpinnedLists =
              allLists.where((list) => list['isPinned'] != true).toList();
          final lists = [...pinnedLists, ...unpinnedLists];

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];

              return Dismissible(
                  key: ValueKey(list['id']),
                  direction: DismissDirection.endToStart, // swipe left
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog(
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
                    );
                  },
                  onDismissed: (_) async {
                    final listId = list['id'];

                    try {
                      await FirebaseFirestore.instance
                          .collection('groups')
                          .doc(groupId)
                          .collection('lists')
                          .doc(listId)
                          .delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('List "${list['name']}" deleted')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting list')),
                      );
                    }
                  },
                  child: Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFFEEECF4)
                        : const Color(0xFF0F0E17),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: Text(
                        list['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Row(
                        children: [
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(list['createdBy'])
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircleAvatar(
                                    radius: 12,
                                    child: Icon(Icons.person, size: 12));
                              }

                              final userData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              final photoUrl = userData['photoURL'];

                              return CircleAvatar(
                                radius: 12,
                                backgroundImage: photoUrl != null
                                    ? NetworkImage(photoUrl)
                                    : null,
                                child: photoUrl == null
                                    ? const Icon(Icons.person, size: 12)
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.list, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  "List 0/${list['itemsCount'] ?? 0} Completed", // replace 0 with actual completed count later
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          list['isPinned'] == true
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () async {
                          final groupId =
                              Provider.of<GroupProvider>(context, listen: false)
                                  .group
                                  ?.id;
                          final listId = list['id'];

                          if (groupId != null && listId != null) {
                            await FirebaseFirestore.instance
                                .collection('groups')
                                .doc(groupId)
                                .collection('lists')
                                .doc(listId)
                                .update({
                              'isPinned': !(list['isPinned'] ?? false),
                            });
                          }
                        },
                      ),
                    ),
                  ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddListDialog(context, groupId),
        backgroundColor: theme.tertiary,
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: theme.surface),
      ),
    );
  }
}
