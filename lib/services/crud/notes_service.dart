import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';


class NotesService{
  Database? _db;

  List<DatabaseNotes> _notes = [];
  final _notesStreamController = StreamController<List<DatabaseNotes>>.broadcast();
  Stream<List<DatabaseNotes>> get allNotes => _notesStreamController.stream;

  //making it a singleton
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
  factory NotesService() => _shared;

  Future<void> _cachNotes() async{
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try{
      final user = await getUser(email: email);
      return user;
    } on UserNotExistException{
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch(e){
      rethrow;
    }
  }
  
  Future<void> open() async{
    if (_db != null){
      throw DatabaseAlreadyOpenedException();
    }

    try{
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path,dbName);
      final db = await openDatabase(dbPath);
      await db.execute(createTableUser);
      await db.execute(createTableNotes);
      await _cachNotes();
    } on MissingPlatformDirectoryException{
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async{
    final db = _db;
    if (db!=null){
      await db.close();
      _db = null;
    }else{
      throw DatabaseNotOpenException();
    }
  }

  Future<void> _ensureDbIsOpen() async{
    try{
      await open();
    } on DatabaseAlreadyOpenedException{

    }
  }

  Database _getDatabaseOrThrow(){
    final db=_db;
    if (db!=null){
      return db;
    }else{
      throw DatabaseNotOpenException();
    }
  }

  Future <void> deleteUser ({required String email}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete('user',where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (deletedCount !=1){
      throw CouldNotDeleteUserException();
    }
  }

  Future<DatabaseUser> createUser ({required String email}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final createQuery = await db.query('user',where: 'email = ?',whereArgs: [email.toLowerCase()],limit: 1);
    if (createQuery.isNotEmpty){
      throw UserAlreadyExistsException();
    }else{
    final userId = await db.insert('user', {'email':email.toLowerCase()});
    return DatabaseUser(id: userId, email: email.toLowerCase());
    }
  }

  Future<DatabaseUser> getUser ({required String email}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final createQuery = await db.query('user',where: 'email = ?',whereArgs: [email.toLowerCase()],limit: 1);
    if (createQuery.isEmpty){
      throw UserNotExistException();
    }else{
      return DatabaseUser.fromRow(createQuery.first);
    }
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser!=owner){
      throw UserNotExistException();
    }else{
      const noteText = '';
      final noteId = await db.insert('notes', {
        'user_id':owner.id,
        'note':noteText,
        'synced_with_cloud':1,
      });
      final note = DatabaseNotes(id: noteId, userId: owner.id, note: noteText, syncedWithCloud: true);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<void> deleteNote({required int id}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete('notes',where: 'id = ?',whereArgs: [id]);
    if (deletedCount == 0){
      throw CouldNotDeleteNoteException();
    }else{
      _notes.removeWhere((note) => note.id==id);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes() async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete('notes');
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }

  Future<DatabaseNotes> getNote({required int id}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query('notes', limit: 1, where: 'id = ?',whereArgs: [id]);
    if (notes.isEmpty){
      throw CouldNotFindNoteException;
    }else{
      final note= DatabaseNotes.fromRow(notes.first);
      _notes.removeWhere((note) => note.id==id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future <Iterable<DatabaseNotes>> getAllNotes() async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query('notes');

    return notes.map((noteRow) => DatabaseNotes.fromRow(noteRow));
  }

  Future<DatabaseNotes> updateNote({required DatabaseNotes note, required String text}) async{
    await _ensureDbIsOpen();    
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updatesCount = await db.update('notes',{
      'note':text,
      'synced_with_cloud':0
    });
    if (updatesCount == 0){
      throw CouldNotUpdateNoteException();
    }else{
      final updatedNote =  await getNote(id: note.id);
      _notes.removeWhere((note) => note.id==updatedNote.id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }
}

@immutable
class DatabaseUser{
  final int id;
  final String email;

  DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String,Object?> map) : id = map["id"] as int, email = map["email"] as String;

  @override
  String toString() =>  'Person, ID = $id , email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode=> id.hashCode;
}

class DatabaseNotes{
  final int id;
  final int userId;
  final String note;
  final bool syncedWithCloud;

  DatabaseNotes({required this.id, required this.userId, required this.note, required this.syncedWithCloud});
  DatabaseNotes.fromRow(Map<String,Object?> map) : id = map["id"] as int, userId = map["user_id"] as int, note = map["note"] as String, syncedWithCloud = map["synced_with_cloud"] as int==1 ? true : false;

  @override
  String toString() =>  'Note, ID = $id , userId = $userId, synced with cloud = $syncedWithCloud, text = $note';

  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode=> id.hashCode;
}

const dbName = 'notes.db';
const createTableUser = '''CREATE TABLE "user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);''';

const createTableNotes = '''CREATE TABLE "notes" (
	"id"	INTEGER NOT NULL,
	"note"	TEXT,
	"synced_with_cloud"	INTEGER NOT NULL,
	"user_id"	INTEGER,
	FOREIGN KEY("user_id") REFERENCES "user"("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
);''';