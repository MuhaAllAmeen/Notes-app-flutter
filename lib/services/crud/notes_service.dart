import 'dart:js_interop';
import 'dart:js_util';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseAlreadyOpenedException implements Exception{}
class UnableToGetDocumentsDirectory implements Exception{}
class DatabaseNotOpenException implements Exception{}
class CouldNotDeleteUserException implements Exception{}
class UserAlreadyExistsException implements Exception{}
class UserNotExistException implements Exception{}
class CouldNotDeleteNoteException implements Exception{}
class CouldNotFindNoteException implements Exception{}
class CouldNotUpdateNoteException implements Exception{}

class NotesService{
  Database? _db;
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
    } on MissingPlatformDirectoryException{
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async{
    final db = _db;
    if (db!=null){
      await db.close();
      _db =null;
    }else{
      throw DatabaseNotOpenException();
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
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete('user',where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (deletedCount !=1){
      throw CouldNotDeleteUserException();
    }
  }

  Future<DatabaseUser> createUser ({required String email}) async{
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
    final db = _getDatabaseOrThrow();
    final createQuery = await db.query('user',where: 'email = ?',whereArgs: [email.toLowerCase()],limit: 1);
    if (createQuery.isEmpty){
      throw UserNotExistException();
    }else{
      return DatabaseUser.fromRow(createQuery.first);
    }
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async{
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser!=owner){
      throw UserNotExistException();
    }else{
      const note = '';
      final noteId = await db.insert('notes', {
        'user_id':owner.id,
        'note':note,
        'synced_with_cloud':1,
      });
      return DatabaseNotes(id: noteId, userId: owner.id, note: note, syncedWithCloud: true);
    }
  }

  Future<void> deleteNote({required int id}) async{
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete('notes',where: 'id = ?',whereArgs: [id]);
    if (deletedCount == 0){
      throw CouldNotDeleteNoteException();
    }
  }

  Future<int> deleteAllNotes() async{
    final db = _getDatabaseOrThrow();
    return await db.delete('notes');
  }

  Future<DatabaseNotes> getNote({required int id}) async{
    final db = _getDatabaseOrThrow();
    final notes = await db.query('notes', limit: 1, where: 'id = ?',whereArgs: [id]);
    if (notes.isEmpty){
      throw CouldNotFindNoteException;
    }else{
      return DatabaseNotes.fromRow(notes.first);
    }
  }

  Future <Iterable<DatabaseNotes>> getAllNotes() async{
    final db = _getDatabaseOrThrow();
    final notes = await db.query('notes');

    return notes.map((noteRow) => DatabaseNotes.fromRow(noteRow));
  }

  Future<DatabaseNotes> updateNote({required DatabaseNotes note, required String text}) async{
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updatesCount = await db.update('notes',{
      'note':text,
      'synced_with_cloud':0
    });
    if (updatesCount == 0){
      throw CouldNotUpdateNoteException();
    }else{
      return await getNote(id: note.id);
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