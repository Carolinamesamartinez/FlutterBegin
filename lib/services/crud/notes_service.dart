import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:secondflutter/extensions/list/filter.dart';
import 'package:secondflutter/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;

  List<DatabaseNotes> _notes = [];

  DatabaseUser? _user;

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNotes>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesService() => _shared;

  late final StreamController<List<DatabaseNotes>> _notesStreamController;

  Stream<List<DatabaseNotes>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingNotes();
        }
      });

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<void> deleteUser({required String email}) async {
    await ensureDBisOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email =?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await ensureDBisOpen();

    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await ensureDBisOpen();

    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseNotes> createnote({required DatabaseUser owner}) async {
    await ensureDBisOpen();

    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const text = '';
    final noteId = await db.insert(noteTable,
        {userIdColumn: owner.id, textColumn: text, isSyncedWithCloudColumn: 1});

    final note = DatabaseNotes(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<void> deleteNote({required int id}) async {
    await ensureDBisOpen();

    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes() async {
    await ensureDBisOpen();

    final db = _getDatabaseOrThrow();
    final numberOdFeletions = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOdFeletions;
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    await ensureDBisOpen();

    final db = _getDatabaseOrThrow();
    final results =
        await db.query(noteTable, limit: 1, where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNotes.fromRow(results.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    await ensureDBisOpen();

    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNotes.fromRow(noteRow));
  }

  Future<DatabaseNotes> updateNote(
      {required DatabaseNotes note, required String text}) async {
    await ensureDBisOpen();
    await ensureDBisOpen();

    final db = _getDatabaseOrThrow();
    //make sure note exists
    await getNote(id: note.id);

    final updatesCount = await db.update(
        noteTable, {textColumn: text, isSyncedWithCloudColumn: 0},
        where: 'id = ?', whereArgs: [note.id]);

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNotes = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNotes.id);
      _notes.add(updatedNotes);
      _notesStreamController.add(_notes);
      return updatedNotes;
    }
  }

  Future<DatabaseUser> getOrCretateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> ensureDBisOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final doscsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(doscsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);

      await db.execute(createNoteTable);

      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToCreateDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;
  @override
  String toString() => 'Person, ID = $id,email= $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNotes {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNotes(
      {required this.id,
      required this.userId,
      required this.text,
      required this.isSyncedWithCloud});

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note,ID = $id,userId=$userId, isSyncronized=$isSyncedWithCloud,text= $text';

  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" 
      
      ("id" INTEGER NOT NULL,
      "user_id" INTEGER NOT NULL,
      "text" TEXT,
      "is_synced_with_cloud" INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY("user_id") REFERENCES "user"("id"),
      PRIMARY KEY("id" AUTOINCREMENT)
      );  ''';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" 
      
      ("id" INTEGER NOT NULL,
      "email" TEXT NOT NULL UNIQUE,
      PRIMARY KEY("id" AUTOINCREMENT)
      );  ''';
