// lib/services/firestore_utils.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUtils {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference groupsCollection() => _db.collection('groups');
  static CollectionReference usersCollection() => _db.collection('users');

  static DocumentReference groupDoc(String groupId) =>
      groupsCollection().doc(groupId);

  static DocumentReference userDoc(String userId) =>
      usersCollection().doc(userId);

  static CollectionReference listCollection(String groupId) =>
      groupDoc(groupId).collection('lists');
}