import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utils/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNotes? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState(){
    _notesService = NotesService();
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
  
  Future<DatabaseNotes> createOrGetExisitingNote(BuildContext context) async{
    
    try{
    final widgetNote = context.getArgument<DatabaseNotes>(); 
    if(widgetNote!=null){
      _note = widgetNote;
      _textController.text = widgetNote.note;
      return widgetNote;
    }
    final existingNote = _note;
    if (existingNote != null){
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    final createdNote = await _notesService.createNote(owner: owner);
    _note = createdNote;
    return createdNote;
    } catch(e){
      print("exception $e");
      rethrow;
    }

  }

  void _deleteNoteIfTextIsEmpty(){
    final note = _note;
    if(_textController.text.isEmpty && note!=null){
      _notesService.deleteNote(id: note.id);
    }
  }

  void saveNoteIfTextIsNotEmpty() async{
    final note = _note;
    if (_textController.text.isNotEmpty && note!=null){
      await _notesService.updateNote(note: note, text: _textController.text);
    }
  }

  void _textControllerListener() async{
    final note = _note;
    if(note == null){
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(note: note, text: text);
  }

  void _setupTextControllerListener(){
    _textController.removeListener( _textControllerListener);
    _textController.addListener(_textControllerListener);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(future: createOrGetExisitingNote(context),
       builder:(context, snapshot) {
         switch(snapshot.connectionState){      
           case ConnectionState.done:
           _setupTextControllerListener();
           return TextField(
            controller: _textController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Start typing your note...'
            ),
           );
           default:
            return const CircularProgressIndicator();
         }
       },
      ),
    );
  }
}