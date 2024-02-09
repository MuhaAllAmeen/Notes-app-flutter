import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
// import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utils/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';


class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

enum MenuAction{ logout}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
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
                    context.read<AuthBloc>().add(const AuthEventLogOut());
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
      StreamBuilder(stream: _notesService.allNotes(ownerUserId: userId), 
        builder:(context, snapshot) {
          switch(snapshot.connectionState){  
            case ConnectionState.waiting:
            case ConnectionState.active: 
              if (snapshot.hasData){
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(notes: allNotes, onDeleteNote:(note) async{
                  await _notesService.deleteNote(documentId: note.documentId);
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
      )
    );
  }
}

