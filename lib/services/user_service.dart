import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

/// Provides user-related services such as profile photo upload and user data retrieval
/// using Firebase Authentication, Firestore, and Firebase Storage.
///
/// Properties:
/// - [_auth]: An instance of [FirebaseAuth] for managing authentication.
/// - [_db]: An instance of [FirebaseFirestore] for interacting with Firestore.
/// - [_storage]: An instance of [FirebaseStorage] for handling file uploads.
/// - [_picker]: An instance of [ImagePicker] for selecting images from the device.
///
/// Methods:
/// - [uploadProfilePhoto]: Allows the currently authenticated user to upload a profile photo.
/// - [getUserStream]: Returns a stream of [DocumentSnapshot] for real-time updates of a user's data
///   from Firestore.
/// - [getUserData]: Retrieves a user's data from Firestore as a [Map<String, dynamic>].
class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<String?> uploadProfilePhoto() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Pick image
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile == null) return null;

    try {
      // Upload to storage
      final file = File(pickedFile.path);
      final ext = pickedFile.path.split('.').last;
      final storageRef =
          _storage.ref().child('user_profiles/${user.uid}/profile.$ext');
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore user document
      await _db.collection('users').doc(user.uid).update({
        'photoURL': downloadUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update Auth user profile
      await user.updatePhotoURL(downloadUrl);

      return downloadUrl;
    } catch (e) {
      print('Error uploading profile photo: $e');
      return null;
    }
  }

  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots();
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
}
