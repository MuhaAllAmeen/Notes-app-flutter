import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage{
  static final  FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  final notes = FirebaseFirestore.instance.collection('notes');

  void createNewNote({required String ownerUserId}) async{
    await notes.add({
      'user_id':ownerUserId,
      'text':'',
    });
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async{
    try{
      return await notes.where('user_id',isEqualTo: ownerUserId)
          .get()
          .then((value) => value.docs.map(
                           (doc) => CloudNote(documentId: doc.id, ownerUserId: doc.data()['user_id'], text: doc.data()['text'])));
    } catch(e){
      throw CouldNotGetAllNotesException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
    notes.snapshots().map((event) => event.docs.map(
        (doc) => CloudNote.fromSnapshot(doc))
        .where((note) => note.ownerUserId == ownerUserId));

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