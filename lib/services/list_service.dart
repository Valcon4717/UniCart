import 'package:cloud_firestore/cloud_firestore.dart';

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

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(createdBy).get();

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