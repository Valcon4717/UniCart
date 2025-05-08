import 'package:cloud_firestore/cloud_firestore.dart';

/// Provides group management services using Firebase Firestore.
///
/// Properties:
/// - [_db]: An instance of [FirebaseFirestore] used to interact with the Firestore database.
/// - [userId]: The ID of the current user, used to identify the user in group operations.
///
/// Methods:
/// - [createGroup]: Creates a new group with the specified name and adds the current user as a member.
/// - [joinGroup]: Adds the current user to an existing group by its ID.
/// - [getGroup]: Retrieves the document snapshot of a group by its ID.
/// - [getUserGroups]: Fetches a list of groups where the current user is a member.
/// - [leaveGroup]: Removes the current user from the members of a specified group.
/// - [deleteGroup]: Deletes a group by its ID.
class GroupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  GroupService({required this.userId});

  Future<String> createGroup(String groupName) async {
    final doc = await _db.collection('groups').add({
      'name': groupName,
      'createdBy': userId,
      'members': [userId],
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<DocumentSnapshot?> joinGroup(String groupId) async {
    try {
      final groupRef = _db.collection('groups').doc(groupId);
      final doc = await groupRef.get();

      if (!doc.exists) return null;

      await groupRef.update({
        'members': FieldValue.arrayUnion([userId]),
      });

      return doc;
    } catch (e) {
      return null;
    }
  }

  Future<DocumentSnapshot> getGroup(String groupId) {
    return _db.collection('groups').doc(groupId).get();
  }

  Future<List<DocumentSnapshot>> getUserGroups() async {
    final snapshot = await _db
        .collection('groups')
        .where('members', arrayContains: userId)
        .get();
    return snapshot.docs;
  }

  Future<void> leaveGroup(String groupId) async {
    await _db.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> deleteGroup(String groupId) async {
    await _db.collection('groups').doc(groupId).delete();
  }
}
