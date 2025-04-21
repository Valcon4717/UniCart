import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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