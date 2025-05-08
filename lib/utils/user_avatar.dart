import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// This class is a widget that displays a user's avatar image fetched from
/// Firestore, with options to use a stream or a future for real-time updates.
class UserAvatar extends StatelessWidget {
  final String userId;
  final double radius;
  final bool useStream;

  const UserAvatar({
    super.key,
    required this.userId,
    this.radius = 12,
    this.useStream = true,
  });

  @override
  Widget build(BuildContext context) {
    if (useStream) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          return _buildAvatar(snapshot);
        },
      );
    } else {
      return FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          return _buildAvatar(snapshot);
        },
      );
    }
  }

  Widget _buildAvatar(AsyncSnapshot<DocumentSnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.active ||
        snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData && snapshot.data!.exists) {
        final doc = snapshot.data!;
        final data = doc.data() as Map<String, dynamic>?;
        final photoUrl = data?['photoURL'];

        return CircleAvatar(
          radius: radius,
          backgroundImage: photoUrl != null && photoUrl != ''
              ? NetworkImage(photoUrl)
              : null,
          child: (photoUrl == null || photoUrl == '')
              ? Icon(Icons.person, size: radius * 0.8)
              : null,
        );
      }
    }

    // Fallback avatar
    return CircleAvatar(
      radius: radius,
      child: Icon(Icons.person, size: radius * 0.8),
    );
  }
}
