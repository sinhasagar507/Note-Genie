import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; 
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory; 
import 'package:path/path.dart' show join; 

import 'package:meta/meta.dart';

@immutable
class DataBaseUser {
  // Fields for storing the user's unique ID and email address.
  final int id;
  final String email;

  // Static constants to represent the column names in a database. 
  // These constants are used to extract values from a Map, ensuring consistency and avoiding magic strings.
  static const idColumn = 'id';
  static const emailColumn = 'email';

  // A constant constructor that initializes the id and email fields. 
  // The 'const' keyword ensures that this constructor can be used to create compile-time constants.
  const DataBaseUser({
    required this.id,
    required this.email,
  });

  // A named constructor that initializes a DataBaseUser instance from a Map.
  // The Map is expected to contain entries with keys 'id' and 'email' (defined by idColumn and emailColumn).
  // The 'as int' and 'as String' cast the values to their appropriate types.
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
