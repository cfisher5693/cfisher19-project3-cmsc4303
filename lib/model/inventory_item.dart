import 'package:flutter/material.dart';

enum DocKeyItem {
  createdBy,
  name,
  quantity,
}

class InventoryItem {
  String? docId;
  String createdBy;
  String name;
  int quantity;

  InventoryItem({this.docId, required this.createdBy, required this.name, required this.quantity});

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyItem.createdBy.name: createdBy,
      DocKeyItem.name.name: name,
      DocKeyItem.quantity.name: quantity,
    };
  }

  factory InventoryItem.fromFirestoreDoc({required Map<String,dynamic> doc, required String docId}) {
    return InventoryItem(
      docId: docId,
      createdBy: doc[DocKeyItem.createdBy.name] ??= '',
      name: doc[DocKeyItem.name.name] ??= '',
      quantity: doc[DocKeyItem.quantity.name] ??= '',
    );
  }

  bool isValid() {
    if (createdBy.isEmpty ||
        name.isEmpty ||
        quantity == 0) {
      return false;
    } else {
      return true;
    }
  }

  static String? validateName(String? value) {
    return (value == null || value.trim().length < 2)
        ? 'Title too short'
        : null;
  }

  void copyFrom(InventoryItem i) {
    docId = i.docId;
    createdBy = i.createdBy;
    name = i.name;
    quantity = i.quantity;
  }
}