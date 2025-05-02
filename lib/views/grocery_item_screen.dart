import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_item_provider.dart';
import '../providers/group_provider.dart';
import '../utils/grocery_item_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroceryItemScreen extends StatefulWidget {
  const GroceryItemScreen({super.key});

  @override
  State<GroceryItemScreen> createState() => _GroceryItemScreenState();
}

class _GroceryItemScreenState extends State<GroceryItemScreen> {
  late GroceryItemProvider groceryItemProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    groceryItemProvider = Provider.of<GroceryItemProvider>(context, listen: false);

    final groupId = groupProvider.group?.id;
    final listId = groceryItemProvider.listId;

    if (groupId != null && listId != null) {
      groceryItemProvider.setGroupAndList(groupId: groupId, listId: listId);
    }
  }

  @override
  void dispose() {
    groceryItemProvider.clear(); // <-- safely use it here now
    super.dispose();
  }

void _showAddItemDialog(BuildContext context) {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Add Grocery Item"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = nameController.text.trim();
            final quantity = int.tryParse(quantityController.text.trim()) ?? 1;
            final price = double.tryParse(priceController.text.trim()) ?? 0.0;

            if (name.isNotEmpty) {
              await Provider.of<GroceryItemProvider>(context, listen: false)
                  .addItem(name, quantity, price, userId);
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
    final itemsProvider = Provider.of<GroceryItemProvider>(context);
    final items = itemsProvider.items;
    final theme = Theme.of(context).colorScheme;

    final incompleteItems =
        items.where((i) => !(i['bought'] ?? false)).toList();
    final boughtItems = items.where((i) => i['bought'] == true).toList();

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        backgroundColor: theme.surface,
        elevation: 0,
        title: const Text(
          'Items',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: [
                  ...incompleteItems.map((item) => GroceryItemCard(item: item)),
                  if (boughtItems.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Bought',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...boughtItems.map((item) => GroceryItemCard(item: item)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: theme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
