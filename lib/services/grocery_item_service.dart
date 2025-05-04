import 'package:cloud_firestore/cloud_firestore.dart';

class GroceryItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getItems(String groupId, String listId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'quantity': data['quantity'] ?? 0,
          'price': data['price'] ?? 0.0,
          'addedBy': data['addedBy'] ?? '',
          'brand': data['brand'] ?? '',
          'size': data['size'] ?? '',
          'image': data['image'] ?? '',
          'addedByName': data['addedByName'] ?? '',
          'addedByPhoto': data['addedByPhoto'] ?? '',
          'createdAt': data['createdAt']?.toDate() ?? DateTime.now(),
        };
      }).toList();
    });
  }

  Future<void> addItem({
    required String groupId,
    required String listId,
    required String name,
    required int quantity,
    required double price,
    required String addedBy,
    Map<String, dynamic>? extraFields,
  }) async {
    // Get current user data to include in the item
    final userDoc = await _db.collection('users').doc(addedBy).get();
    final userData = userDoc.data() ?? {};

    final addedByName = userData['name'] ?? '';
    final addedByPhoto = userData['photoURL'] ?? '';

    final timestamp = FieldValue.serverTimestamp();

    // Update the item count in the list document
    await _db
        .collection('groups')
        .doc(groupId)
        .collection('lists')
        .doc(listId)
        .update({
      'itemsCount': FieldValue.increment(1),
      'lastUpdated': timestamp,
    });

    // Add the item with user data
    await _db
        .collection('groups')
        .doc(groupId)
        .collection('lists')
        .doc(listId)
        .collection('items')
        .add({
      'name': name,
      'quantity': quantity,
      'price': price,
      'addedBy': addedBy,
      'addedByName': addedByName,
      'addedByPhoto': addedByPhoto,
      'createdAt': timestamp,
      ...?extraFields,
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
