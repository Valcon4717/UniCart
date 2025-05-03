import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String userId;
  final double radius;
  final bool useStream; // Option to use stream for real-time updates

  const UserAvatar({
    super.key, 
    required this.userId, 
    this.radius = 12,
    this.useStream = true, // Default to using stream for real-time updates
  });

  @override
  Widget build(BuildContext context) {
    // Use a stream builder instead of future builder for real-time updates
    if (useStream) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          return _buildAvatar(snapshot);
        },
      );
    } else {
      // Fallback to future for non-critical displays
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
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