import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utils/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';


class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

enum MenuAction{ logout}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _notesService = NotesService();
    // _notesService.open();
    super.initState();
  }

  // @override
  // void dispose() {
  //   _notesService.close();
  //   super.dispose();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: (){Navigator.of(context).pushNamed(createUpdateNoteRoute);},
           icon: const Icon(Icons.add)),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value){
                
                case MenuAction.logout:
                  final loginOrCancel = await showLogOutDialog(context);
                  if (loginOrCancel){
                    await AuthService.firebase().logout();
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
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
      body: 
      FutureBuilder(future: _notesService.getOrCreateUser(email: userEmail), 
        builder:(context, snapshot) {
          switch(snapshot.connectionState){       
            case ConnectionState.done:
              return  StreamBuilder(stream: _notesService.allNotes, 
                builder:(context, snapshot) {
                  switch(snapshot.connectionState){  
                    case ConnectionState.waiting:
                    case ConnectionState.active: 
                      if (snapshot.hasData){
                        final allNotes = snapshot.data as List<DatabaseNotes>;
                        return NotesListView(notes: allNotes, onDeleteNote:(note) async{
                          await _notesService.deleteNote(id: note.id);
                        }, onTap: (note) async{
                          Navigator.of(context).pushNamed(createUpdateNoteRoute,arguments: note);
                        },);
                      }else{
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
            return const CircularProgressIndicator();
          }
        },),
    );
  }
}

