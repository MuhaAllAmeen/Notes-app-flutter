import 'package:flutter/material.dart';
import 'package:mynotes/helpers/encryption/encryption.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
// import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utils/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mynotes/utils/dialogs/cannot_share_empty_note_dialog.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  @override
  void initState(){
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }
  
  @override
  void dispose(){
    _deleteNoteIfTextIsEmpty();
    saveNoteIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }
  
  Future<CloudNote> createOrGetExisitingNote(BuildContext context) async{
    try{
    final widgetNote = context.getArgument<CloudNote>(); 
    if(widgetNote!=null){
      _note = widgetNote;
      _textController.text = EncryptData.decryptAES(widgetNote.text);
      return widgetNote;
    }
    final existingNote = _note;
    if (existingNote != null){
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    // final email = currentUser.email;
    // final owner = await _notesService.getUser(email: email);
    final userId = currentUser.id;
    final createdNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = createdNote;
    return createdNote;
    } catch(e){
      print("exception $e");
      rethrow;
    }

  }

  void _deleteNoteIfTextIsEmpty(){
    final note = _note;
    if((_textController.text.isEmpty) && note!=null){
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void saveNoteIfTextIsNotEmpty() async{
    final note = _note;
    if (_textController.text.isNotEmpty && note!=null){
      await _notesService.updateNote(documentId: note.documentId, text: _textController.text);
    }
  }

  void _textControllerListener() async{
    final note = _note;
    if(note == null){
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(documentId: note.documentId, text: text);
  }

  void _setupTextControllerListener(){
    _textController.removeListener( _textControllerListener);
    _textController.addListener(_textControllerListener);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("New Note"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [IconButton(onPressed:() async {
          final text = _textController.text;
          if (_note==null || text.isEmpty){
            await showCannotShareEmptyNoteDialog(context);
          } else{
            Share.share(text);
          }
        }, icon: const Icon(Icons.share))],
      ),
      body: FutureBuilder(future: createOrGetExisitingNote(context),
       builder:(context, snapshot) {
         switch(snapshot.connectionState){      
           case ConnectionState.done:
           _setupTextControllerListener();
           return Padding(
             padding: const EdgeInsets.all(25.0),
             child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,        
               children: [
                  Text(_textController.text.isEmpty?'Create':'Edit',style: const TextStyle(color: Colors.white30,fontSize: 30,fontFamily: 'PlayfairDisplay'),),
                  const Text('Your Note',style: TextStyle(color: Colors.white,fontSize: 45,fontFamily: 'PlayfairDisplay',fontWeight: FontWeight.bold),),
                  const SizedBox(height: 50),
                  Text(_textController.text.isNotEmpty?'Last Updated on: ${_note?.dateTime}':'',style: const TextStyle(color: Colors.white30),),
                  SizedBox(height: _textController.text.isNotEmpty?30:0,),
                  TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Start typing your note...',
                      hintStyle: TextStyle(color: Colors.white70 )
                    ),
                  ),
                ],
              ),
            );
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
    );
  }
}