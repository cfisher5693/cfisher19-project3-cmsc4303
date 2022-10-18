import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project3/viewscreen/startdispatcher.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: StartDispatcher.routeName,
      routes: {
        StartDispatcher.routeName:(context) => const StartDispatcher(),
      },
    );
  }

}