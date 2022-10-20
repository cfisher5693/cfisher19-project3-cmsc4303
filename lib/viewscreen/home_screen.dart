import 'package:flutter/material.dart';
import 'package:project3/model/inventory_item.dart';
import 'package:project3/viewscreen/view/view_util.dart';

import '../controller/auth_controller.dart';
import '../controller/firestore_controller.dart';
import '../model/additem_screen_model.dart';
import '../model/home_screen_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomeScreen> {
  late _Controller con;
  late HomeScreenModel screenModel;
  late AddItemScreenModel dialogModel;
  int tempQuantity = 0;
  var formKey = GlobalKey<FormState>();
  final TextEditingController value = TextEditingController();
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    screenModel = HomeScreenModel(user: Auth.user!);
    dialogModel = AddItemScreenModel(user: Auth.user!);
    con.loadItemList();
  }

  @override
  void dispose() {
    value.dispose();
    super.dispose();
  }

  void render(fn) {
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Inventory'),
        actions: [
          IconButton(onPressed: con.signOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: screenModel.itemList == null
          ? const Center(child: CircularProgressIndicator())
          : bodyView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.lime[300],
                  title: const Text('Add A New Item'),
                  content: Stack(
                    children: <Widget>[
                      Form(
                        key: formKey,
                        child: TextFormField(
                          controller: value,
                          decoration: const InputDecoration(hintText: 'Title'),
                          autocorrect: true,
                          validator: InventoryItem.validateName,
                          onSaved: dialogModel.saveName,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        for (int i = 0; i < screenModel.itemList!.length; i++) {
                          if (screenModel.itemList![i].name ==
                              value.text.toLowerCase()) {
                            print(
                                '${screenModel.itemList![i].name} vs ${value.text.toLowerCase()}');
                            value.clear();
                            Navigator.pop(context);
                            showSnackBar(
                                context: context,
                                message: 'Item already exists!');
                            return;
                          }
                        }
                        con.save();
                      },
                      child: const Text('Create'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget bodyView() {
    if (screenModel.itemList!.isEmpty) {
      return const Text('No Inventory');
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
            itemCount: screenModel.itemList?.length,
            itemBuilder: (context, index) {
              InventoryItem item = screenModel.itemList![index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: screenModel.editIndex == index
                    ? Container(
                        child: Column(
                          children: [
                            Text(
                              '${item.name} (qty: ${item.quantity})',
                              style: const TextStyle(color: Colors.blue),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  color: Colors.blue,
                                  icon: const Icon(Icons.remove),
                                  onPressed: con.decrement,
                                ),
                                Text(
                                  tempQuantity.toString(),
                                  style: const TextStyle(color: Colors.blue),
                                ),
                                IconButton(
                                  color: Colors.blue,
                                  icon: const Icon(Icons.add),
                                  onPressed: con.increment,
                                ),
                                const SizedBox(
                                  width: 70,
                                  height: 40,
                                ),
                                IconButton(
                                  color: Colors.blue,
                                  icon: const Icon(Icons.done),
                                  onPressed: con.edit,
                                ),
                                IconButton(
                                  color: Colors.blue,
                                  icon: const Icon(Icons.cancel),
                                  onPressed: con.cancel,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : ListTile(
                        tileColor: Colors.lime[300],
                        title: Text('${item.name} (qty: ${item.quantity})'),
                        onTap: null,
                        onLongPress: () => con.onLongPress(index)),
              );
            }),
      );
    }
  }
}

class _Controller {
  _HomeState state;
  _Controller(this.state);

  void signOut() {
    Auth.signOut();
  }

  Future<void> loadItemList() async {
    try {
      state.screenModel.itemList = await FirestoreController.getItemList(
          email: state.screenModel.user.email!);
      state.render(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> save() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) {
      return;
    }
    currentState.save();
    state.dialogModel.tempItem.createdBy = state.screenModel.user.email!;
    String docId =
        await FirestoreController.addItem(item: state.dialogModel.tempItem);
    state.dialogModel.tempItem.docId = docId;
    final item = state.dialogModel.tempItem;
    InventoryItem newItem = item as InventoryItem;
    state.render(() {
      state.screenModel.itemList!.insert(0, newItem);
      loadItemList();
    });
    state.value.clear();
    //Navigator.of(state.context).pop();
    Navigator.pop(state.context);
  }

  void onLongPress(int index) {
    state.render(() {
      if (state.screenModel.editIndex == null ||
          state.screenModel.editIndex != index) {
        state.screenModel.editIndex = index;
        state.tempQuantity = state.screenModel.itemList![state.screenModel.editIndex!].quantity;
      } else {
        state.screenModel.editIndex = null;
      }
    });
  }

  void cancel() {
    state.render(() {
      state.screenModel.editIndex = null;
    });
  }

  void increment() {
    state.render(() {
      state.tempQuantity++;
      //state.screenModel.itemList![state.screenModel.editIndex!].quantity;
    });
  }

  void decrement() {
    if (state.screenModel.itemList![state.screenModel.editIndex!].quantity != 0) {
      state.render(() {
        state.tempQuantity--;
        //state.screenModel.itemList![state.screenModel.editIndex!].quantity--;
      });
    } else {
      showSnackBar(context: state.context, message: 'Cannot reduce past 0!');
    }
  }

  void edit() {
    if(state.tempQuantity == 0) {
      delete();
    } else {
      if(state.screenModel.itemList![state.screenModel.editIndex!].quantity == state.tempQuantity) {
        showSnackBar(context: state.context, message: 'No change made!');
        return;
      }
      update();
    }
  }

  void update() async {
    Map<String, dynamic> fieldsToUpdate = {};
    InventoryItem tempItem = state.screenModel.itemList![state.screenModel.editIndex!];
    tempItem.quantity = state.tempQuantity;
    fieldsToUpdate[DocKeyItem.quantity.name] = tempItem.quantity;
    await FirestoreController.updateItem(docId: tempItem.docId!, update: fieldsToUpdate);
    state.render(() {
      state.screenModel.editIndex = null;
    });
  }

  Future<void> delete() async {
    InventoryItem item = state.screenModel.itemList![state.screenModel.editIndex!];
    await FirestoreController.deleteDoc(docId: item.docId!);
    state.render(() {
      state.screenModel.itemList!.removeAt(state.screenModel.editIndex!);
      state.screenModel.editIndex = null;
    });
  }
}
