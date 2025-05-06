import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_item_provider.dart';
import '../services/grocery_item_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  const GroceryItemCard({super.key, required this.item});

  @override
  State<GroceryItemCard> createState() => _GroceryItemCardState();
}

class _GroceryItemCardState extends State<GroceryItemCard> {
  final GroceryItemService _groceryItemService = GroceryItemService();

void _toggleBought() async {
  final provider = Provider.of<GroceryItemProvider>(context, listen: false);
  final itemId = widget.item['id'];

  if (itemId != null) {
    final newStatus = !(widget.item['bought'] ?? false);

    await _groceryItemService.toggleBought(
      groupId: provider.groupId,
      listId: provider.listId,
      itemId: itemId,
      currentStatus: !newStatus,
    );

    if (!mounted) return;
    setState(() {
      widget.item['bought'] = newStatus;
    });
  }
}

  void _deleteItem() async {
    final provider = Provider.of<GroceryItemProvider>(context, listen: false);
    final itemId = widget.item['id'];

    if (itemId != null) {
      await _groceryItemService.deleteItem(
        groupId: provider.groupId,
        listId: provider.listId,
        itemId: itemId,
      );
    }
  }

  Widget _detailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(widget.item['id']),
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
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Theme.of(context).brightness == Brightness.light
            ? const Color(0xFFEEECF4)
            : const Color(0xFF0F0E17),
        child: ExpansionTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          collapsedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          leading: Checkbox(
            value: widget.item['bought'] ?? false,
            onChanged: (_) => _toggleBought(),
            activeColor: theme.primary,
          ),
          title: Text(
            widget.item['name'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          trailing: buildItemAvatar(widget.item),
          children: [
            if ((widget.item['image'] ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.item['image'],
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((widget.item['brand'] ?? '').isNotEmpty)
                        _detailText("Brand", widget.item['brand']),
                      _detailText(
                          "Quantity", "${widget.item['quantity'] ?? 1}"),
                      if ((widget.item['size'] ?? '').isNotEmpty)
                        _detailText("Size", widget.item['size']),
                      _detailText("Cost",
                          "\$${(widget.item['price'] ?? 0).toStringAsFixed(2)}"),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    final nameController =
                        TextEditingController(text: widget.item['name']);
                    final quantityController = TextEditingController(
                        text: widget.item['quantity']?.toString() ?? '1');
                    final priceController = TextEditingController(
                        text: widget.item['price']?.toString() ?? '0.0');
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Edit Item"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: nameController,
                              decoration:
                                  const InputDecoration(labelText: 'Name'),
                            ),
                            TextField(
                              controller: quantityController,
                              decoration:
                                  const InputDecoration(labelText: 'Quantity'),
                              keyboardType: TextInputType.number,
                            ),
                            TextField(
                              controller: priceController,
                              decoration:
                                  const InputDecoration(labelText: 'Price'),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final updatedName = nameController.text.trim();
                              final updatedQuantity = int.tryParse(
                                      quantityController.text.trim()) ??
                                  1;
                              final updatedPrice = double.tryParse(
                                      priceController.text.trim()) ??
                                  0.0;
                              final groupId = Provider.of<GroceryItemProvider>(
                                      context,
                                      listen: false)
                                  .groupId;
                              final listId = Provider.of<GroceryItemProvider>(
                                      context,
                                      listen: false)
                                  .listId;
                              final itemId = widget.item['id'];
                              await _groceryItemService.updateItem(
                                groupId: groupId,
                                listId: listId,
                                itemId: itemId,
                                updates: {
                                  'name': updatedName,
                                  'quantity': updatedQuantity,
                                  'price': updatedPrice,
                                },
                              );
                              Navigator.pop(ctx);
                            },
                            child: const Text("Save"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

Widget buildItemAvatar(Map<String, dynamic> item) {
  final userId = item['addedBy'];
  final photoUrl = item['addedByPhoto'];

  if (photoUrl != null && photoUrl.isNotEmpty) {
    return CircleAvatar(
      radius: 14,
      backgroundImage: NetworkImage(photoUrl),
      child: _prefetchLatestAvatar(userId),
    );
  }

  return StreamBuilder<DocumentSnapshot>(
    stream:
        FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
    builder: (context, snapshot) {
      final data = snapshot.data?.data() as Map<String, dynamic>?;

      if (data != null &&
          data['photoURL'] != null &&
          data['photoURL'].toString().isNotEmpty) {
        return CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage(data['photoURL']),
        );
      }

      return const CircleAvatar(
        radius: 14,
        child: Icon(Icons.person, size: 16),
      );
    },
  );
}

Widget _prefetchLatestAvatar(String userId) {
  return Opacity(
    opacity: 0,
    child: SizedBox(
      width: 1,
      height: 1,
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) => const SizedBox.shrink(),
      ),
    ),
  );
}
