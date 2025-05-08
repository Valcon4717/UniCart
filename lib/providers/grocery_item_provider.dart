import 'package:flutter/material.dart';
import 'dart:async';
import '../services/grocery_item_service.dart';

/// Manages grocery items in a list.
///
/// Interacts with [GroceryItemService] to fetch, add, and update items.
/// Notifies listeners on changes.
///
/// Properties:
/// - [items]: List of grocery items.
/// - [isLoading]: Indicates if data is loading.
///
/// Methods:
/// - [_subscribe]: Listens to item updates.
/// - [addItem]: Adds a new item.
/// - [updateItem]: Updates an item.
/// - [refresh]: Reloads items.
/// - [clear]: Clears items and cancels subscription.
///
/// Disposes subscription on cleanup.
class GroceryItemProvider extends ChangeNotifier {
  final GroceryItemService _groceryItemService;
  final String groupId;
  final String listId;

  bool isLoading = false;

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => _items;

  StreamSubscription? _subscription;

  GroceryItemProvider({
    required GroceryItemService groceryItemService,
    required this.groupId,
    required this.listId,
  }) : _groceryItemService = groceryItemService {
    _subscribe(); // auto-subscribe when created
  }

  void _subscribe() {
    isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _groceryItemService
        .getItems(groupId, listId)
        .listen((fetchedItems) {
      _items = fetchedItems.map((item) {
        var categories = item['categories'];
        categories ??= 'Uncategorized';
        
        return {
          ...item,
          'image': item['image'] ?? '',
          'brand': item['brand'] ?? '',
          'size': item['size'] ?? '',
          'categories': categories,
        };
      }).toList();
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addItem(
    String name,
    int quantity,
    double price,
    String addedBy, {
    Map<String, dynamic>? extraFields,
  }) async {
    await _groceryItemService.addItem(
      groupId: groupId,
      listId: listId,
      name: name,
      quantity: quantity,
      price: price,
      addedBy: addedBy,
      extraFields: extraFields,
    );
    refresh();
  }

  Future<void> updateItem(String itemId, Map<String, dynamic> updates) async {
    await _groceryItemService.updateItem(
      groupId: groupId,
      listId: listId,
      itemId: itemId,
      updates: updates,
    );
    refresh();
  }

  void refresh() => _subscribe();

  void clear() {
    _items = [];
    _subscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}