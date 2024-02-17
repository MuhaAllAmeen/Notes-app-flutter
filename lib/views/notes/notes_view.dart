import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
// import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utils/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/notes/notes_grid_view.dart';


class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

enum MenuAction{ logout}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  late final PageController _pageViewController;
  String get userId => AuthService.firebase().currentUser!.id;
  bool _showAppbar = true;
  bool isScrollingDown = false;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _pageViewController = PageController(initialPage: 0,keepPage: false);
    _pageViewController.addListener(() {
      if (_pageViewController.position.userScrollDirection ==
          ScrollDirection.reverse || _pageViewController.page == 1) {
          isScrollingDown = true;
          _showAppbar = false;
          setState(() {});
        
      }

      if (_pageViewController.position.userScrollDirection ==
          ScrollDirection.forward || _pageViewController.page == 0) {
          isScrollingDown = false;
          _showAppbar = true;
          setState(() {});
        
      }
    });
    // _notesService.open();
    super.initState();
  }

  @override
  void dispose() {
    // _notesService.close();
    _pageViewController.dispose();
    _pageViewController.removeListener(() {});
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:_showAppbar? AppBar(
        toolbarHeight: 90,
        title: const Column(
          crossAxisAlignment:CrossAxisAlignment.start,
          children: [
            Text("Your Notes",style: TextStyle(fontFamily: 'PlayfairDisplay',fontSize: 30),),
            Text('Swipe left to add a new note or tap +',style: TextStyle(color: Colors.white30,fontSize: 15,fontFamily: 'Quicksand',fontWeight: FontWeight.bold),)
          ],
        ),
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
      ):null,
      body: 
      PageView(
        controller: _pageViewController,
        children: [
          StreamBuilder(stream: _notesService.allNotes(ownerUserId: userId), 
          builder:(context, snapshot) {
            switch(snapshot.connectionState){  
              case ConnectionState.waiting:
              case ConnectionState.active: 
                if (snapshot.hasData){
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  final validNotes = allNotes.where((note) => note.text!='');
                  final orderedNotes = validNotes.toList()..sort((b, a) => a.dateTime.compareTo(b.dateTime),);
                  Iterable<CloudNote> orderedIterable = Iterable<CloudNote>.generate(orderedNotes.length,(index) => orderedNotes[index]);
                  return NotesGridView(notes: orderedIterable, onDeleteNote:(note) async{
                    await _notesService.deleteNote(documentId: note.documentId);
                  }, onTap: (note) async{
                    Navigator.of(context).pushNamed(createUpdateNoteRoute,arguments: note);
                  },);
                }else{
                  return const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child:  CircularProgressIndicator()),
                  );
                }
              default:
                return const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child:  CircularProgressIndicator()),
                  );
            }
          },
        ),
        const CreateUpdateNoteView()
        ],
      )
    );
  }
}

