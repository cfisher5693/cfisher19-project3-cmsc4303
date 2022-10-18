import 'package:flutter/material.dart';

import '../controller/auth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomeScreen> {
  late _Controller con;
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }
  void render(fn) {
    setState(fn);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(onPressed: con.signOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: const Text('Home Screen'),
    );
  }
}

class _Controller {
  _HomeState state;
  _Controller(this.state);

  void signOut() {
    Auth.signOut();
  }
}