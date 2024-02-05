import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
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
  
  Future<DatabaseNotes> createNewNote() async{
    try{
    final existingNote = _note;
    if (existingNote != null){
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    final createdNote = await _notesService.createNote(owner: owner);
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
      body: FutureBuilder(future: createNewNote(),
       builder:(context, snapshot) {
         switch(snapshot.connectionState){      
           case ConnectionState.done:
           _note = snapshot.data as DatabaseNotes?;
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