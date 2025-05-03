import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadProfilePhoto() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) throw Exception("No image selected");

    final file = File(pickedFile.path);
    final ref = _storage.ref().child('user_profiles/${user.uid}/profile.jpg');

    final uploadTask = await ref.putFile(file);
    if (uploadTask.state == TaskState.success) {
      final photoUrl = await ref.getDownloadURL();
      await user.updatePhotoURL(photoUrl);
      final userDocRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        await userDocRef.update({'photoURL': photoUrl});
      } else {
        await userDocRef.set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? '',
          'photoURL': photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await user.reload();
      return photoUrl;
    } else {
      throw Exception('Failed to upload photo');
    }
  }
}
