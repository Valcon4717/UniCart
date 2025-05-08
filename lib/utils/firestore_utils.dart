// lib/services/firestore_utils.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// This class provides static methods to access and manipulate Firestore
/// collections and documents related to groups, users, and lists.
///
/// Properties:
/// - [_db]: A private instance of [FirebaseFirestore] used to interact with
///   the Firestore database.
///
/// Methods:
/// - [groupsCollection]: Returns a reference to the 'groups' collection in Firestore.
/// - [usersCollection]: Returns a reference to the 'users' collection in Firestore.
/// - [groupDoc]: Returns a reference to a specific document in the 'groups' collection
///   based on the provided group ID.
/// - [userDoc]: Returns a reference to a specific document in the 'users' collection
///   based on the provided user ID.
/// - [listCollection]: Returns a reference to the 'lists' subcollection within a
///   specific group document, based on the provided group ID.
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
