import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// Optional: Get all groups the current user is a member of
  Future<List<DocumentSnapshot>> getUserGroups() async {
    final snapshot = await _db
        .collection('groups')
        .where('members', arrayContains: userId)
        .get();
    return snapshot.docs;
  }
}