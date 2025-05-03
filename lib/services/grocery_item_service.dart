// lib/services/grocery_item_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream all items in a list, sorted with unbought first
  Stream<List<Map<String, dynamic>>> getItems(String groupId, String listId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .orderBy('bought')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }
  
  /// Add a new item
  Future<DocumentReference> addItem({
    required String groupId,
    required String listId,
    required String name,
    required String addedBy,
    String? brand,
    int quantity = 1,
    String? size,
    double? price,
  }) async {
    final now = Timestamp.now();

    return await _db
        .collection('groups')
        .doc(groupId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .add({
      'name': name,
      'brand': brand ?? '',
      'quantity': quantity,
      'size': size ?? '',
      'price': price ?? 0.0,
      'addedBy': addedBy,
      'bought': false,
      'createdAt': now,
    });
  }

  /// Update an existing item
  Future<void> updateItem({
    required String groupId,
    required String listId,
    required String itemId,
    required Map<String, dynamic> updates,
  }) async {
    await _db
        .collection('groups')
        .doc(groupId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(itemId)
        .update(updates);
  }

  /// Delete an item
  Future<void> deleteItem({
    required String groupId,
    required String listId,
    required String itemId,
  }) async {
    await _db
        .collection('groups')
        .doc(groupId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(itemId)
        .delete();
  }

  /// Toggle bought status
  Future<void> toggleBought({
    required String groupId,
    required String listId,
    required String itemId,
    required bool currentStatus,
  }) async {
    await _db
        .collection('groups')
        .doc(groupId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .doc(itemId)
        .update({'bought': !currentStatus});
  }
}