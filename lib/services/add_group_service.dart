import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum MemberRole {
  admin,
  editor,
  viewer
}

class AddGroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Invite a user to the group by email
  Future<void> inviteUser(String groupId, String email) async {
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    
    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw Exception('Invalid email format');
    }

    try {
      // First, check if the user exists in the system
      final userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception('User not found. Please ensure the email is registered.');
      }

      final invitedUser = userSnapshot.docs.first;
      
      // Check if user is already a member
      final existingMember = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(invitedUser.id)
          .get();
          
      if (existingMember.exists) {
        throw Exception('User is already a member of this group');
      }

      // Add user to the group with default role
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(invitedUser.id)
          .set({
        'userId': invitedUser.id,
        'name': invitedUser.data()?['name'] ?? 'Unknown User',
        'email': email.toLowerCase(),
        'photoURL': invitedUser.data()?['photoURL'] ?? '',
        'role': MemberRole.editor.name,
        'addedAt': FieldValue.serverTimestamp(),
        'addedBy': _auth.currentUser?.uid ?? '',
      });

      // Also add this group to the user's groups collection for easy reference
      await _firestore
          .collection('users')
          .doc(invitedUser.id)
          .collection('groups')
          .doc(groupId)
          .set({
        'joinedAt': FieldValue.serverTimestamp(),
        'role': MemberRole.editor.name,
      });
      
    } catch (e) {
      if (e is FirebaseException) {
        throw Exception('Firebase error: ${e.message}');
      }
      rethrow;
    }
  }

  // Get stream of group members
  Stream<List<Map<String, dynamic>>> getGroupMembers(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .orderBy('addedAt', descending: false)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => {
              ...doc.data(),
              'id': doc.id,
            }).toList()
        );
  }

  // Change a member's role
  Future<void> updateMemberRole(String groupId, String userId, MemberRole role) async {
    try {
      // Verify current user is admin of the group
      final currentUserMember = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(_auth.currentUser?.uid)
          .get();
          
      if (!currentUserMember.exists || 
          currentUserMember.data()?['role'] != MemberRole.admin.name) {
        throw Exception('You do not have permission to change member roles');
      }
      
      // Update the member's role
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .update({
        'role': role.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _auth.currentUser?.uid,
      });
      
      // Also update in user's groups collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('groups')
          .doc(groupId)
          .update({
        'role': role.name,
      });
      
    } catch (e) {
      if (e is FirebaseException) {
        throw Exception('Firebase error: ${e.message}');
      }
      rethrow;
    }
  }

  // Remove a member from the group
  Future<void> removeMember(String groupId, String userId) async {
    try {
      // Verify current user is admin of the group
      final currentUserMember = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(_auth.currentUser?.uid)
          .get();
          
      if (!currentUserMember.exists || 
          currentUserMember.data()?['role'] != MemberRole.admin.name) {
        throw Exception('You do not have permission to remove members');
      }
      
      // Remove from group's members collection
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('members')
          .doc(userId)
          .delete();
      
      // Remove from user's groups collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('groups')
          .doc(groupId)
          .delete();
      
    } catch (e) {
      if (e is FirebaseException) {
        throw Exception('Firebase error: ${e.message}');
      }
      rethrow;
    }
  }

  // Get the current user's groups
  Stream<List<DocumentSnapshot>> getUserGroups() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('groups')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  // Get specific group details
  Future<DocumentSnapshot> getGroupDetails(String groupId) {
    return _firestore.collection('groups').doc(groupId).get();
  }
}