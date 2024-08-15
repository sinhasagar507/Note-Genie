import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; 
import 'package:path_provider/path_provider.dart'; 
import 'package:path/path.dart' show join; 

import 'package:meta/meta.dart';

// Constants to represent the column names in a database. 
// These constants are used to extract values from a Map, ensuring consistency and avoiding magic strings.
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text'; 
const IsSyncedWithCloud = 'isSyncedWithCloud'; 
const dbName = 'notes.db'; 
const noteTable = 'note'; 
const userTable = 'user'; 

// The following SQL queries are used for creating our tables inside the database called 'notes.db'. 
const createUserTable = '''CREATE TABLE "user" (
          "id"	INTEGER NOT NULL,
          "email "	TEXT NOT NULL UNIQUE,
          PRIMARY KEY("id" AUTOINCREMENT)
      );''';

const createNoteTable = '''CREATE TABLE "notes" (
          "id"	INTEGER NOT NULL,
          "user_id"	INTEGER NOT NULL,
          "text"	TEXT,
          "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
          PRIMARY KEY("id" AUTOINCREMENT),
          FOREIGN KEY("user_id") REFERENCES "user"("id")
      );'''; 


// Implement some Exception classes 
// Databases are being referenced by a cursor. So if a database is already open, its not a desired scenario. A database reference must always be closed 
class DatabaseAlreadyOpenException implements Exception {} 

// If unable to locate the file in directory, or the provided path is wrong, this exception will be thrown 
class UnableToGetDocumentsDirectoryException implements Exception {}


/// Here I am creating a NotesService class, which implements the full-fledged capability of reading and performing manipulations on the database 
class NotesService {
  Database? _db; 

  Future<void> open() async {
    if(_db != null){
      throw DatabaseAlreadyOpenException(); 
    }

    try{
      // Here I am getting the Application Directory path 
      final docsPath = await getApplicationDocumentsDirectory(); 
      final dbPath = join(docsPath.path, dbName); 
      final db = await openDatabase(dbPath); 
      _db = db; 


      // Waiting for the db cursor instance to execute those SQL queries 
      await db.execute(createUserTable); 
      await db.execute(createNoteTable); 

    }
    on MissingPlatformDirectoryException{
      throw UnableToGetDocumentsDirectoryException(); 
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
  bool operator == (covariant DataBaseUser other) => id == other.id;

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
        isSyncedWithCloud = (map[IsSyncedWithCloud] as int) == 1 ? true: false;

  // Overriding the toString method to provide a custom string representation of the DataBaseUser object.
  // This is useful for debugging or logging, as it gives a clear, human-readable format of the object's data.
  @override
  String toString() => 'Note, ID: {$id}, user: {$user_id}, cloudSynced: {$isSyncedWithCloud}, text: {$text}';

  // Overriding the '==' operator to compare two DataBaseNote objects based on their IDs.
  // The 'covariant' keyword allows the 'other' parameter to be of a more specific type than the original 'Object' type.
  // This ensures that the comparison is type-safe and specific to DataBaseNote instances.
  @override
  bool operator == (covariant DataBaseNote other) => id == other.id;

  // Overriding the hashCode getter to return the hash code of the 'id' field.
  // This ensures that DataBaseNote objects with the same 'id' have the same hash code, which is crucial for using instances
  // of this class in hash-based collections like Set and Map.
  @override
  int get hashCode => id.hashCode;
}