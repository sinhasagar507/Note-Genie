import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

/// The @immutable annotation indicates that this class is immutable.
/// Once an instance of this class is created, its fields cannot be changed.
@immutable
class AuthUser {
  final String id;

  /// A final field that holds the email verification status of the user.
  /// Since it's final, it can only be set once and cannot be modified.
  final String?
      email; // I need to define using the ? operator cause the user might be anonymous as per the user class in defined in Dart
  final bool isEmailVerified;

  /// A constant constructor that initializes the [isEmailVerified] field.
  /// The `const` keyword indicates that instances of this class can be
  /// compile-time constants if all their fields are compile-time constants.

  // So up till this point I wasn't able to fetch all notes for a particular user through his/her's email address
  // So I need to make modifications to the code over here and add email as one of the required parameters
  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
  });

  /// A factory constructor that creates an instance of [AuthUser] from a
  /// Firebase [User] object. This is useful for converting Firebase user
  /// data into your app's user model.
  factory AuthUser.fromFirebase(User user) {
    // Create and return an AuthUser instance using the email verification
    // status from the Firebase [User] object.
    // THe user is an optional instance of
    return AuthUser(
      id: user.uid,
      email: user.email,
      isEmailVerified: user.emailVerified,
    );
  }
}
