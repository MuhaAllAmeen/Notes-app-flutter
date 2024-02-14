import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage{
  static final  FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  final notes = FirebaseFirestore.instance.collection('notes');

  Future<CloudNote> createNewNote({required String ownerUserId}) async{
    final document = await notes.add({
      'user_id':ownerUserId,
      'text':'',
    });
    final fetchedNote = await document.get();
    return CloudNote(documentId: fetchedNote.id, ownerUserId: ownerUserId, text: '');
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
    notes.where('user_id',isEqualTo: ownerUserId).snapshots().map((event) => event.docs.map(
        (doc) => CloudNote.fromSnapshot(doc)));

  Future<void> updateNote({required String documentId, required String text}) async{
    try{
      await notes.doc(documentId).update({'text':text});
    }catch (e){
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async{
    try{
      await notes.doc(documentId).delete();
    }catch (e){
      throw CouldNotDeleteNoteException();
    }
  }
}