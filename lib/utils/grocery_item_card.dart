import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_item_provider.dart';
import '../services/grocery_item_service.dart';

class GroceryItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  const GroceryItemCard({super.key, required this.item});

  @override
  State<GroceryItemCard> createState() => _GroceryItemCardState();
}

class _GroceryItemCardState extends State<GroceryItemCard> {
  bool _expanded = false;
  final GroceryItemService _groceryItemService = GroceryItemService();

  void _toggleBought() async {
    final groupId = Provider.of<GroceryItemProvider>(context, listen: false).groupId;
    final listId = Provider.of<GroceryItemProvider>(context, listen: false).listId;
    final itemId = widget.item['id'];

    if (groupId != null && listId != null && itemId != null) {
      await _groceryItemService.toggleBought(
        groupId: groupId,
        listId: listId,
        itemId: itemId,
        currentStatus: widget.item['bought'] ?? false,
      );
    }
  }

  void _deleteItem() async {
    final groupId = Provider.of<GroceryItemProvider>(context, listen: false).groupId;
    final listId = Provider.of<GroceryItemProvider>(context, listen: false).listId;
    final itemId = widget.item['id'];

    if (groupId != null && listId != null && itemId != null) {
      await _groceryItemService.deleteItem(
        groupId: groupId,
        listId: listId,
        itemId: itemId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(widget.item['id']),
      direction: DismissDirection.endToStart,
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
            title: const Text("Delete Item"),
            content: const Text("Are you sure you want to delete this item?"),
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
      onDismissed: (_) => _deleteItem(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: theme.surfaceVariant.withOpacity(0.5),
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: widget.item['bought'] ?? false,
                      onChanged: (_) => _toggleBought(),
                      activeColor: theme.primary,
                    ),
                    Expanded(
                      child: Text(
                        widget.item['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Handle edit item popup
                      },
                    ),
                    CircleAvatar(
                      radius: 14,
                      child: const Icon(Icons.person, size: 16),
                      // TODO: Load addedBy profile picture if available
                    )
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 8),
                  Text("Brand: ${widget.item['brand'] ?? ''}"),
                  Text("Quantity: ${widget.item['quantity'] ?? 1}"),
                  Text("Size: ${widget.item['size'] ?? ''}"),
                  Text("Price: \$${(widget.item['price'] ?? 0).toStringAsFixed(2)}"),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}