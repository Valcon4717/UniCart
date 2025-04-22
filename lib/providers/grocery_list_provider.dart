import 'package:flutter/material.dart';
import '../services/grocery_service.dart';
import 'dart:async';

class GroceryListProvider extends ChangeNotifier {
  final GroceryService _groceryService = GroceryService();

  List<Map<String, dynamic>> _groceryLists = [];
  List<Map<String, dynamic>> get groceryLists => _groceryLists;

  StreamSubscription? _subscription;

  void loadGroceryLists(String groupId) {
    _subscription?.cancel();
    _subscription = _groceryService.getLists(groupId).listen((lists) {
      _groceryLists = lists;
      notifyListeners();
    });
  }

  void clear() {
    _groceryLists = [];
    _subscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}