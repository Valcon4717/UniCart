import 'package:cloud_firestore/cloud_firestore.dart';

/// Provides services for managing grocery items within a group and list.
///
/// Interacts with Firestore to perform CRUD operations on grocery items.
/// Includes methods for adding, updating, deleting, and toggling the bought status of items.
///
/// Properties:
/// - [_db]: An instance of [FirebaseFirestore] for database operations.
///
/// Methods:
/// - [getItems]: Streams a list of grocery items for a specific group and list.
/// - [addItem]: Adds a new grocery item to a specific group and list.
/// - [updateItem]: Updates an existing grocery item with new data.
/// - [deleteItem]: Deletes a grocery item from a specific group and list.
/// - [toggleBought]: Toggles the bought status of a grocery item and updates the completed count.
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
        var categories = data['categories'];

        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'quantity': data['quantity'] ?? 0,
          'price': data['price'] ?? 0.0,
          'bought': data['bought'] ?? false,
          'addedBy': data['addedBy'] ?? '',
          'brand': data['brand'] ?? '',
          'size': data['size'] ?? '',
          'image': data['image'] ?? '',
          'addedByName': data['addedByName'] ?? '',
          'addedByPhoto': data['addedByPhoto'] ?? '',
          'categories': categories,
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
    final userDoc = await _db.collection('users').doc(addedBy).get();
    final userData = userDoc.data() ?? {};
    final addedByName = userData['name'] ?? '';
    final addedByPhoto = userData['photoURL'] ?? '';
    final timestamp = FieldValue.serverTimestamp();

    await _db
        .collection('groups')
        .doc(groupId)
        .collection('lists')
        .doc(listId)
        .update({
      'itemsCount': FieldValue.increment(1),
      'lastUpdated': timestamp,
    });

    var categories = extraFields?['categories'] ?? 'Uncategorized';

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
      'bought': false,
      'addedBy': addedBy,
      'addedByName': addedByName,
      'addedByPhoto': addedByPhoto,
      'createdAt': timestamp,
      'categories': categories,
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
    final itemsRef = _db
        .collection('groups')
        .doc(groupId)
        .collection('lists')
        .doc(listId)
        .collection('items');

    await itemsRef.doc(itemId).update({'bought': !currentStatus});

    final snapshot = await itemsRef.where('bought', isEqualTo: true).get();
    final completedCount = snapshot.docs.length;

    await _db
        .collection('groups')
        .doc(groupId)
        .collection('lists')
        .doc(listId)
        .update({'completedCount': completedCount});
  }
}
