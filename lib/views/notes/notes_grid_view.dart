import 'package:flutter/material.dart';
import 'package:mynotes/design/box/frosted_glass.dart';
import 'package:mynotes/helpers/encryption/encryption.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/utils/dialogs/cannot_share_empty_note_dialog.dart';
// import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utils/dialogs/delete_dialog.dart';
import 'package:share_plus/share_plus.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesGridView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;
  const NotesGridView({super.key, required this.notes, required this.onDeleteNote, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,mainAxisSpacing: 8.0, // spacing between rows
        crossAxisSpacing: 8.0,),
      itemCount: notes.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder:(context, index) {
        final note = notes.elementAt(index);
        final decryptedNote = EncryptData.decryptAES(note.text);
        final formattedDate = '${note.dateTime.day}-${note.dateTime.month}-${note.dateTime.year}';
        final formattedTime ='${note.dateTime.hour}:${note.dateTime.minute}';
        return GestureDetector(
          onTap: () {
            onTap(note);
          },
          child: 
            GridTile(  
              header: GridTileBar(
                leading: Text(formattedDate,style: const TextStyle(color:Colors.white),),
                backgroundColor: Colors.white10,
                trailing: Text(formattedTime,style: const TextStyle(color:Colors.white)),
                ),   
              footer: GridTileBar(
                leading: IconButton(
                    onPressed:() async {
                      final shouldDelete = await showDeleteDialog(context);
                      if (shouldDelete){
                        onDeleteNote(note);
                      }
                    },
                    icon: const Icon(Icons.delete),
                  ),
                trailing: IconButton(onPressed:() async {
                  final text = decryptedNote;
                  if (note==null || text.isEmpty){
                    await showCannotShareEmptyNoteDialog(context);
                  } else{
                    Share.share(text);
                  }
                  }, icon: const Icon(Icons.share)),
              ),      
              child: FrostedGlassBox(
                theHeight: 100.0,
                theWidth: 100.0,
                theChild: Text(
                  decryptedNote,
                  maxLines: 3,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white,fontSize: 20),
                  ),
              ),
            ),
        );
      },
    );
  }
}