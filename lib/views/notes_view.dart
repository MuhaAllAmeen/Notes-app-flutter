import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

enum MenuAction{ logout}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value){
                
                case MenuAction.logout:
                  final loginOrCancel = await showLogOutDialog(context);
                  if (loginOrCancel){
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil('/Login/', (route) => false);
                  }
              }              
            },
            itemBuilder:(context) => 
          [const PopupMenuItem<MenuAction>(
            value: MenuAction.logout, 
            child: Text("Logout"))],
            )
        ],
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context){
  return showDialog<bool>(context: context,
  builder:(context) => 
  AlertDialog(title: const Text("Log Out"),
  content: const Text("Are you sure you want to log out?"),
  actions: [
    TextButton(onPressed:() {Navigator.of(context).pop(true);}, child: const Text("Log Out")),
    TextButton(onPressed: (){Navigator.of(context).pop(false);}, child: const Text("Cancel"))
  ],
  ),
  ).then((value) => value ?? false);
}