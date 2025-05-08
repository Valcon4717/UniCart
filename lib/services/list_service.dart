import 'package:cloud_firestore/cloud_firestore.dart';

/// Provides services for managing grocery lists within a group using Firebase Firestore.
///
/// Properties:
/// - [_db]: An instance of [FirebaseFirestore] used to interact with the Firestore database.
///
/// Methods:
/// - [getLists]: Fetches all grocery lists for a specific group as a stream of list maps.
/// - [createList]: Creates a new grocery list with the provided details, including metadata such as
///   the creator's name and photo.
/// - [updateGroceryList]: Updates the name of a specific grocery list and updates its last modified timestamp.
/// - [deleteGroceryList]: Deletes a specific grocery list from the Firestore database.
/// - [togglePinnedStatus]: Toggles the pinned status of a specific grocery list.

class ListService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch all grocery lists for a group
  Stream<List<Map<String, dynamic>>> getLists(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('lists')
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  /// Create a detailed list
  Future<void> createList({
    required String groupId,
    required String name,
    required String description,
    required String createdBy,
    bool isPinned = false,
  }) async {
    final now = Timestamp.now();

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(createdBy)
        .get();

    final createdByName = userDoc.exists ? userDoc['name'] ?? '' : '';
    final createdByPhoto = userDoc.exists ? userDoc['photoURL'] ?? '' : '';

    await _db.collection('groups').doc(groupId).collection('lists').add({
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'itemsCount': 0,
      'createdAt': now,
      'lastUpdated': now,
      'isPinned': isPinned,
      'createdByName': createdByName,
      'createdByPhoto': createdByPhoto,
    });
  }

  /// Update list name
  Future<void> updateGroceryList(
      String groupId, String listId, String newName) async {
    await _db
        .collection('groups')
        .doc(groupId)
        .collection('lists')
        .doc(listId)
        .update({
      'name': newName,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a list
  Future<void> deleteGroceryList(String groupId, String listId) async {
    await _db
        .collection('groups')
        .doc(groupId)
        .collection('lists')
        .doc(listId)
        .delete();
  }

  Future<void> togglePinnedStatus({
    required String groupId,
    required String listId,
    required bool currentStatus,
  }) async {
    await _db
        .collection('groups')
        .doc(groupId)
        .collection('lists')
        .doc(listId)
        .update({'isPinned': !currentStatus});
  }
}
