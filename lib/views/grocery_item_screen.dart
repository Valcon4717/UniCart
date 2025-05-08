import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/grocery_item_provider.dart';
import '../utils/grocery_item_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/kroger_product_service.dart';

/// The following defines a StatefulWidget for managing grocery items, including adding items,
/// displaying categories, and searching for products using Kroger API.
class GroceryItemScreen extends StatefulWidget {
  final String listName;

  const GroceryItemScreen({super.key, required this.listName});

  @override
  State<GroceryItemScreen> createState() => _GroceryItemScreenState();
}

class _GroceryItemScreenState extends State<GroceryItemScreen> {
  GroceryItemProvider? _groceryItemProvider;
  List<Map<String, dynamic>> _krogerSearchResults = [];

  String? _krogerLocationId;
  final KrogerProductService _krogerProductService = KrogerProductService();

  @override
  void initState() {
    super.initState();
    _loadStoreLocation();
  }

  Future<void> _loadStoreLocation() async {
    final stores = await _krogerProductService.getNearbyStores('98052');
    if (stores != null && stores.isNotEmpty) {
      setState(() {
        _krogerLocationId = stores[0]['locationId'];
      });
    } else {
      print('No store found or error fetching stores');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _groceryItemProvider ??=
        Provider.of<GroceryItemProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _groceryItemProvider?.clear();
    super.dispose();
  }

  String extractImageUrl(Map<String, dynamic> product) {
    try {
      final images = product['images'] as List?;
      if (images == null || images.isEmpty) {
        return '';
      }

      for (var image in images) {
        if (image['perspective'] == 'front' &&
            (image['default'] == true || image['featured'] == true)) {
          final sizes = image['sizes'] as List?;
          if (sizes == null || sizes.isEmpty) {
            continue;
          }

          for (var size in sizes) {
            if (size['size'] == 'medium' && size['url'] != null) {
              return size['url'] as String;
            }
          }
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  void _showAddItemDialog(BuildContext context) {
    final parentContext = context;
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Add Grocery Item"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final quantity =
                  int.tryParse(quantityController.text.trim()) ?? 1;
              final price = double.tryParse(priceController.text.trim()) ?? 0.0;
              final category = categoryController.text.trim();
              if (name.isNotEmpty) {
                await Provider.of<GroceryItemProvider>(parentContext,
                        listen: false)
                    .addItem(name, quantity, price, userId, extraFields: {
                  if (category.isNotEmpty) 'categories': category,
                });
              } else {}

              Navigator.pop(dialogContext);
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Groceries',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFFEEECF4)
                        : const Color(0xFF0F0E17),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (query) async {
                    if (query.isNotEmpty && _krogerLocationId != null) {
                      final results = await _krogerProductService
                          .searchProducts(query, _krogerLocationId!);
                      setState(() {
                        _krogerSearchResults =
                            (results ?? []).cast<Map<String, dynamic>>();
                      });
                    } else {
                      setState(() {
                        _krogerSearchResults = [];
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      ..._buildCategorySections(
                          context, incompleteItems, theme),
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
                        ...boughtItems
                            .map((item) => GroceryItemCard(item: item)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_krogerSearchResults.isNotEmpty)
            Positioned(
              top: 90,
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                constraints: BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _krogerSearchResults.length,
                  itemBuilder: (context, index) {
                    final product = _krogerSearchResults[index];
                    final name = product['description'] ?? 'Unknown';
                    final brand = product['brand'] ?? '';
                    final items = product['items'] as List<dynamic>? ?? [];
                    final size =
                        items.isNotEmpty ? (items[0]['size'] ?? '') : '';
                    final price = (items.isNotEmpty &&
                            items[0]['price'] != null &&
                            items[0]['price']['regular'] != null)
                        ? double.tryParse(
                                items[0]['price']['regular'].toString()) ??
                            0.0
                        : 0.0;

                    final imageUrl = extractImageUrl(product);

                    return ListTile(
                      title: Text(name),
                      subtitle: Text('$brand $size'),
                      trailing: Text('\$${price.toStringAsFixed(2)}'),
                      leading: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported);
                              },
                            )
                          : const Icon(Icons.shopping_bag),
                      onTap: () async {
                        final userId =
                            FirebaseAuth.instance.currentUser?.uid ?? '';
                        final size =
                            items.isNotEmpty ? (items[0]['size'] ?? '') : '';
                        final price = (items.isNotEmpty &&
                                items[0]['price'] != null &&
                                items[0]['price']['regular'] != null)
                            ? double.tryParse(
                                    items[0]['price']['regular'].toString()) ??
                                0.0
                            : 0.0;
                        final imageUrl = extractImageUrl(product);

                        await Provider.of<GroceryItemProvider>(context,
                                listen: false)
                            .addItem(
                          product['description'] ?? 'Unknown',
                          1,
                          price,
                          userId,
                          extraFields: {
                            'brand': product['brand'] ?? '',
                            'size': size,
                            'image': imageUrl,
                            'categories': product['categories'] ?? [],
                          },
                        );

                        setState(() {
                          _krogerSearchResults = [];
                        });
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: theme.primary,
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: theme.surface),
      ),
    );
  }
}

List<Widget> _buildCategorySections(
    BuildContext context, List<Map<String, dynamic>> items, ColorScheme theme) {
  final Map<String, List<Map<String, dynamic>>> groupedItems = {};

  for (var item in items) {
    String category = 'Uncategorized';

    if (item.containsKey('categories')) {
      var rawCategory = item['categories'];

      if (rawCategory is List && rawCategory.isNotEmpty) {
        category = rawCategory.first.toString();
      } else if (rawCategory is String && rawCategory.isNotEmpty) {
        category = rawCategory;
      } else if (rawCategory != null && rawCategory.toString().isNotEmpty) {
        category = rawCategory.toString();
      }
    }

    if (!groupedItems.containsKey(category)) {
      groupedItems[category] = [];
    }

    groupedItems[category]!.add(item);
  }

  return groupedItems.entries.map((entry) {
    final category = entry.key;
    final itemsInCategory = entry.value;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        title: Text(
          category,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.onSurface,
          ),
        ),
        initiallyExpanded: true,
        children:
            itemsInCategory.map((item) => GroceryItemCard(item: item)).toList(),
      ),
    );
  }).toList();
}
