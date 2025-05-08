import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Manages the state of a group document.
///
/// Interacts with [DocumentSnapshot] to store and manage group-related data.
/// Notifies listeners when the group document changes.
///
/// Properties:
/// - [group]: The current group document, or `null` if no group is set.
///
/// Methods:
/// - [setGroup]: Updates the current group document and notifies listeners.
/// - [clearGroup]: Clears the current group document and notifies listeners.
class GroupProvider extends ChangeNotifier {
  DocumentSnapshot? _groupDoc;

  DocumentSnapshot? get group => _groupDoc;

  void setGroup(DocumentSnapshot groupDoc) {
    _groupDoc = groupDoc;
    notifyListeners();
  }

  void clearGroup() {
    _groupDoc = null;
    notifyListeners();
  }
}
