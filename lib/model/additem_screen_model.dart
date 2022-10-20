import 'package:firebase_auth/firebase_auth.dart';
import 'package:project3/main.dart';
import 'package:project3/model/inventory_item.dart';

import '../viewscreen/view/view_util.dart';

class AddItemScreenModel {
  User user;
  late InventoryItem tempItem;

  AddItemScreenModel({required this.user}) {
    tempItem = InventoryItem(createdBy: user.email!, name: '', quantity: 1);
  }

  void saveName(String? value) {
    if (value != null) {
      tempItem.name = value.toLowerCase();
    }
  }
}
