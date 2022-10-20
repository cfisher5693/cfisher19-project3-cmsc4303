import 'package:firebase_auth/firebase_auth.dart';
import 'package:project3/model/inventory_item.dart';

class HomeScreenModel {
  User user;
  List<InventoryItem>? itemList;
  int? editIndex;

  HomeScreenModel({required this.user});
}