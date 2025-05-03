// lib/widgets/user_avatar.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firestore_utils.dart';

class UserAvatar extends StatelessWidget {
  final String userId;
  final double radius;

  const UserAvatar({super.key, required this.userId, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirestoreUtils.userDoc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data!.exists) {
          final doc = snapshot.data!;
          final photoUrl = doc.data() is Map && (doc.data() as Map).containsKey('photoURL')
              ? doc.get('photoURL')
              : null;

          return CircleAvatar(
            radius: radius,
            backgroundImage: photoUrl != null && photoUrl != ''
                ? NetworkImage(photoUrl)
                : null,
            child: (photoUrl == null || photoUrl == '')
                ? const Icon(Icons.person, size: 12)
                : null,
          );
        }

        // fallback when doc doesn't exist or is loading
        return CircleAvatar(
          radius: radius,
          child: const Icon(Icons.person, size: 12),
        );
      },
    );
  }
}