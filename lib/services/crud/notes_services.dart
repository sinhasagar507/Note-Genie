import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:meta/meta.dart';
import 'package:notes_app/services/crud/crud_exceptions.dart';

// Constants to represent the column names in a database.
// These constants are used to extract values from a Map, ensuring consistency and avoiding magic strings.
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const IsSyncedWithCloudColumn = 'isSyncedWithCloud';
const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';

// The following SQL queries are used for creating our tables inside the database called 'notes.db'.
const createUserTable = '''CREATE TABLE "user" (
          "id"	INTEGER NOT NULL,
          "email "	TEXT NOT NULL UNIQUE,
          PRIMARY KEY("id" AUTOINCREMENT)
      );''';

// The following SQL query creates a note table and defines its associated attributes
const createNoteTable = '''CREATE TABLE "notes" (
          "id"	INTEGER NOT NULL,
          "user_id"	INTEGER NOT NULL,
          "text"	TEXT,
          "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
          PRIMARY KEY("id" AUTOINCREMENT),
          FOREIGN KEY("user_id") REFERENCES "user"("id")
      );''';

/// Here I am creating a NotesService class, which implements the full-fledged capability of reading and performing manipulations on the database
class NotesService {
  Database? _db;

  // Let's define a variable called _notes which consists of all the lists from a particular user
  List<DataBaseNote> _notes = [];

  // Here I am defining a StreamController of the type <List<DataBaseNote>> which I can broadcast
  final _noteStreamController =
      StreamController<List<DataBaseNote>>.broadcast();

  Stream<List<DataBaseNote>> get allNotes => _noteStreamController.stream;

  Future<void> _cacheNotes() async {
    // Here I am fetching all the notes
    final allNotes = await getAllNotes();

    // Then I am converting all the notes to a list
    _notes = allNotes.toList();

    // I am adding those notes to a Stream Controller, so that they can be viewed asynchronously
    _noteStreamController.add(_notes);
  }

  // This function serves as a check to determine whether the database can be accessed for particular reading and writing operations
  Database _getDataBaseOrThrow() {
    final db = _db;

    // If the database is null, then no such user exists (throw the particular exception)
    if (db == null) {
      throw DatabaseIsNotOpen();
    }

    // Else I will return the database
    else {
      return db;
    }
  }

  // Now I want something for getOrCreate Users thing as well
  Future<DataBaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(
        email: email,
      ); // Now I am awaiting to see if the user still exists in the database
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(
        email: email,
      ); // If I don't find the user, the user will be created
      return createdUser;
    } catch (e) {
      // Okay, so there might be some other Exceptions as well which I haven't taken care of
      rethrow; // So I kinda just rethrow the exception again back to the caller and from there it will be shown
    }
  }

  // In the function below, I am trying to create a new user
  Future<DataBaseUser> createUser({required String email}) async {
    // I am checking if the database is open
    await _ensureDbIsOpen();
    // I am checking if there is an instance of database under existence
    final db = _getDataBaseOrThrow();

    // If the database is not null or the database is null but no such user exists, results will be 0
    final results = await db.query(
      userTable, // Here userTable is being passed as the primary parameter to the 'db.query' function
      limit: 1, // The limit is set to 1
      where: 'email = ?', // Here the where clause of SQL is executed
      whereArgs: [
        email.toLowerCase()
      ], // Here the email parameter is converted to lowercase and passed as a parameter which is searched
    );

    // If the results are not empty or non-zero, then the particular user already exists
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    // Now I am fetching the user ID of the newly created user
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    // Finally I return an instance of Database User
    return DataBaseUser(id: userId, email: email);
  }

  // This particular user is used to fetch a user from the database
  Future<DataBaseUser> getUser({required String email}) async {
    // First fetch the database
    await _ensureDbIsOpen();

    // Then throw the required Dart Exception
    final db = _getDataBaseOrThrow();

    // For the results parameter, I am querying the parameter to check if the user exists
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );

    // If the results are empty, then I cannot find the particular user
    if (results.isEmpty) {
      throw CouldNotFindUser();
    }

    // Return the instance of Database user from the row
    return DataBaseUser.fromRow(results.first);
  }

  // Delete the users from the database
  Future<void> deleteUser({required String email}) async {
    // Ensure that the database is first open
    await _ensureDbIsOpen(); // If I don't perform this operation, the second operation will always return a null
    // Again I am fetching the instance of database user
    final db = _getDataBaseOrThrow();

    // Try deleting the user from database
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    // If the deleted count is not at least 1, then no such user exists
    if (deletedCount != 1) {
      throw CouldNotDeleteNote();
    }
  }

// This particular function deletes all notes from a particular database
  Future<int> deleteAllNotes() async {
    // First of all, I make sure that the database is open
    await _ensureDbIsOpen();
    // Then I am making sure that the data is initialized
    final db = _getDataBaseOrThrow();

    // Try deleting the user from the database
    final noOfDeletions = await db.delete(
        noteTable); // First of all, I would wait for all notes to be deleted normally
    _notes = []; // Then I would set the private variable _notes to null
    _noteStreamController.add(
        _notes); // And I would finally add it to the _notesStreamController. The user-facing StreamController of the class is also updated with the latest information. StreamController is user-facing, so I need to update it
    return noOfDeletions; // Then I return the no. of deletions
  }

  // The following function is used to update all notes
  Future<DataBaseNote> updateNote({
    required DataBaseNote note,
    required String text,
  }) async {
    // First I have to make sure that the database is even open
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();
    await getNote(id: note.id);

    // So here I am getting the value of how many notes are being updated through the db.update function
    final updateCount = await db.update(
      noteTable,
      {
        textColumn: text,
        IsSyncedWithCloudColumn: 0,
      },
    );

    // If the updateCount is 0, then CouldNotUpdateNote() is returned
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      // Else I return an instance of getNote function to return the updated note
      final updatedNote = await getNote(id: note.id);

      // Now I will modify the local existing cache
      // Remove the older note
      _notes.removeWhere((note) => note.id == updatedNote.id);

      // Add the updated note
      _notes.add(updatedNote);

      // Finally update the StreamBuilder as well
      _noteStreamController.add(_notes);

      return updatedNote;
    }
  }

  // This particular function deletes all particular users
  Future<int> deleteUsers() async {
    /*
    Jbb bhi koi nya user arrives toh pehle check kro if the database open hua hai bhi ki nai
    Ye check krna is very necessary. Aise hi by default database open krdena is not optimal by design 
    */
    // First i have to ensure that the database is even open
    await _ensureDbIsOpen();

    // Again I am fetching the instance of database user
    final db = _getDataBaseOrThrow();

    // Try deleting the user from the database
    return await db.delete(userTable);
  }

  // This particular function gets a particular note from the database
  Future<DataBaseNote> getNote({required int id}) async {
    // Ensure first tha the database is open
    await _ensureDbIsOpen();
    // Then if doesn't show any
    final db = _getDataBaseOrThrow();

    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DataBaseNote.fromRow(notes.first);
      // What if _notes got updated? It would be a huge problem if I don't update the _notes locally
      // Hence I have removed the earlier version of note
      _notes.removeWhere((note) => note.id == id);
      // Now here I have the updated version of note, so I am adding that one
      _notes.add(note);
      // I have added the updated cache to the front-facing stream_controller
      _noteStreamController.add(_notes);
      return note;
    }
  }

// Write a function to capture all notes
  Future<Iterable<DataBaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDataBaseOrThrow();

    // Here I am creating a functionality to get all notes
    final notes = await db.query(
      noteTable,
    );

    // Then I am mapping each note to the constructor initializer for fetching id and other metadata
    return notes.map((noteRow) => DataBaseNote.fromRow(noteRow));
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      // Here I am getting the Application Directory path
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);

      /*
    The temporary 'db' variable is used within the 'try' block to hold 
    the result of await openDatabase(dbPath);. This way, any errors that occur during the opening 
    of the database can be handled without prematurely modifying the _db instance variable. 

    Only after the database has been successfully opened and is fully initialized (e.g., tables created) do you 
    assign it to _db. This prevents _db from being set to an incomplete or erroneous state if something goes wrong 
    during the initialization process
    */

      final db = await openDatabase(dbPath);
      _db = db;

      // Waiting for the db cursor instance to execute those SQL queries
      await db.execute(createUserTable);
      await db.execute(createNoteTable);

      // Every time a particular user logs into the application, he or she is going to see all of their previous notes hosted there
      await _cacheNotes();
    }

    // No such directory or database path exists
    on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  // The following function helps us in creating a new note
  Future<DataBaseNote?> createNote({required DataBaseUser owner}) async {
    await _ensureDbIsOpen();
    // Again fetch the database
    final db = _getDataBaseOrThrow();

    // Make sure that the user exists in the database with the correct ID
    // I fetch the database user
    final dbUser = await getUser(email: owner.email);

    // Now here I am trying to apply the equality operator which I had overridden before
    // Two users with the same email ID don't exist in the database
    // If the database user is not the owner, means I cannot find the user.
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';
// This particular function creates a note in the database
// Using the createNote SQL query to fetch the noteID
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      text: text,
      IsSyncedWithCloudColumn: 1,
    });

// Here I created an instance of database note and then return the note with the appropriate parameters
    final note = DataBaseNote(
        id: noteId, user_id: owner.id, text: text, isSyncedWithCloud: true);
    return note;
  }

  Future<void> deleteNote({required int id}) async {
    // First check if the database is open
    await _ensureDbIsOpen();
    // So I am trying to implement deleting that particular note
    final db = _getDataBaseOrThrow();

    // Try deleting the user from database
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    // If the deleted count is not atleast 1, then no such user exists
    if (deletedCount != 1) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _noteStreamController.add(_notes);
    }
  }

  Future<void> close() async {
    final db = _db;

    // Here again I am checking if there exists a database instance
    if (db == null) {
      // throws the required exception
      throw DatabaseIsNotOpen();
    } else {
      // else closes the connection and sets the database instance to null
      await db.close();
      _db = null;
    }
  }

  // I just don't have to check if a particular database instance exists
  // Its also necessary that the database is also open. And for that, I need to add this check as well to ensure that the database is indeed open
  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }
}

@immutable
class DataBaseUser {
  // Fields for storing the user's unique ID and email address.
  final int id;
  final String email;

  // A constant constructor that initializes the id and email fields.
  // The 'const' keyword ensures that this constructor can be used to create compile-time constants.
  const DataBaseUser({
    required this.id,
    required this.email,
  });

  // A named constructor that initializes a DataBaseUser instance from a Map.
  // The Map is expected to contain entries with keys 'id' and 'email' (defined by idColumn and emailColumn).
  // The 'as int' and 'as String' cast the values to their appropriate types.
  // This is demonstrating the usage of initializerList in Dart. Here Id and
  DataBaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  // Overriding the toString method to provide a custom string representation of the DataBaseUser object.
  // This is useful for debugging or logging, as it gives a clear, human-readable format of the object's data.
  @override
  String toString() => 'Person, ID: {$id}, email: {$email}';

  // Overriding the '==' operator to compare two DataBaseUser objects based on their IDs.
  // The 'covariant' keyword allows the 'other' parameter to be of a more specific type than the original 'Object' type.
  // This ensures that the comparison is type-safe and specific to DataBaseUser instances.
  @override
  bool operator ==(covariant DataBaseUser other) => id == other.id;

  // Overriding the hashCode getter to return the hash code of the 'id' field.
  // This ensures that DataBaseUser objects with the same 'id' have the same hash code, which is crucial for using instances
  // of this class in hash-based collections like Set and Map.
  @override
  int get hashCode => id.hashCode;
}

class DataBaseNote {
  // Fields for storing a note's unique ID, corresponding user_id, note text and the boolean parameter for checking if its syncedWithCloud.
  final int id;
  final int user_id;
  final String text;
  final bool isSyncedWithCloud;

  // A constant constructor that initializes the id and email fields.
  // The 'const' keyword ensures that this constructor can be used to create compile-time constants.
  const DataBaseNote({
    required this.id,
    required this.user_id,
    required this.text,
    required this.isSyncedWithCloud,
  });

  // A named constructor that initializes a DataBaseUser instance from a Map.
  // The Map is expected to contain entries with keys 'id' and 'email' (defined by idColumn and emailColumn).
  // The 'as int' and 'as String' cast the values to their appropriate types.
  // This is demonstrating the usage of initializerList in Dart. Here Id and
  DataBaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        user_id = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[IsSyncedWithCloudColumn] as int) == 1 ? true : false;

  // Overriding the toString method to provide a custom string representation of the DataBaseUser object.
  // This is useful for debugging or logging, as it gives a clear, human-readable format of the object's data.
  @override
  String toString() =>
      'Note, ID: {$id}, user: {$user_id}, cloudSynced: {$isSyncedWithCloud}, text: {$text}';

  // Overriding the '==' operator to compare two DataBaseNote objects based on their IDs.
  // The 'covariant' keyword allows the 'other' parameter to be of a more specific type than the original 'Object' type.
  // This ensures that the comparison is type-safe and specific to DataBaseNote instances.
  @override
  bool operator ==(covariant DataBaseNote other) => id == other.id;

  // Overriding the hashCode getter to return the hash code of the 'id' field.
  // This ensures that DataBaseNote objects with the same 'id' have the same hash code, which is crucial for using instances
  // of this class in hash-based collections like Set and Map.
  @override
  int get hashCode => id.hashCode;
}
