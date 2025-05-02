import 'package:flutter/material.dart';
import 'dart:async';
import '../services/grocery_item_service.dart';

class GroceryItemProvider extends ChangeNotifier {
  final GroceryItemService _groceryItemService;

  String? groupId;
  String? listId;
  bool isLoading = false;

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => _items;

  StreamSubscription? _subscription;

  GroceryItemProvider({required GroceryItemService groceryItemService})
      : _groceryItemService = groceryItemService;

  void setGroupAndList({required String groupId, required String listId}) {
    this.groupId = groupId;
    this.listId = listId;
    _subscribe();
  }

  void _subscribe() {
    if (groupId == null || listId == null) return;
    isLoading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription =
        _groceryItemService.getItems(groupId!, listId!).listen((fetchedItems) {
      _items = fetchedItems;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addItem(
      String name, int quantity, double price, String addedBy) async {
    if (groupId == null || listId == null) return;

    final now = DateTime.now();

    final newItem = {
      'name': name,
      'quantity': quantity,
      'price': price,
      'addedBy': addedBy,
      'bought': false,
      'createdAt': now,
    };

    await _groceryItemService.addItem(
      groupId: groupId!,
      listId: listId!,
      name: name,
      quantity: quantity,
      price: price,
      addedBy: addedBy,
    );
    refresh();
  }

  void refresh() {
    _subscribe();
  }

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
