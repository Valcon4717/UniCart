// lib/widgets/user_avatar.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_utils.dart';

class UserAvatar extends StatelessWidget {
  final String userId;
  final double radius;

  const UserAvatar({super.key, required this.userId, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirestoreUtils.userDoc(userId).get(),
      builder: (context, snapshot) {
        final photoUrl = snapshot.data?.get('photoURL');

        return CircleAvatar(
          radius: radius,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          child:
              photoUrl == null ? const Icon(Icons.person, size: 12) : null,
        );
      },
    );
  }
}