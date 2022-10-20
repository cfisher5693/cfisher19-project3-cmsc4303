import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project3/model/inventory_item.dart';

class FirestoreController {
  static const ItemCollection = 'item_collection';

  static Future<String> addItem({required InventoryItem item}) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(ItemCollection)
        .add(item.toFirestoreDoc());
    return ref.id;
  }

  static Future<List<InventoryItem>> getItemList({required String email,}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(ItemCollection)
        .where(DocKeyItem.createdBy.name, isEqualTo: email)
        .orderBy(DocKeyItem.name.name, descending: true)
        .get();
    var result = <InventoryItem>[];
    for(var doc in querySnapshot.docs) {
      if(doc.data() != null) {
        var document = doc.data() as Map<String, dynamic>;
        var i = InventoryItem.fromFirestoreDoc(doc: document, docId: doc.id);
        if(i.isValid()) result.add(i);
      }
    }
    return result;
  }

  static Future<void> updateItem({required String docId, required Map<String, dynamic> update}) async {
    await FirebaseFirestore.instance
        .collection(ItemCollection)
        .doc(docId)
        .update(update);
  }

  static Future<void> deleteDoc({required docId}) async {
    await FirebaseFirestore.instance
        .collection(ItemCollection)
        .doc(docId)
        .delete();
  }
}