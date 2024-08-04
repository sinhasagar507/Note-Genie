// This abstract class defines the interface for authentication providers.
// It includes methods for creating a user, sending email verification, logging in, and logging out.
// Any class that implements AuthProvider will need to provide concrete implementations for these methods.

import "package:firebase_core/firebase_core.dart";
import "package:notes_app/services/auth/auth_user.dart";

/// An abstract class that defines the contract for authentication providers.
/// Any class that implements AuthProvider must provide implementations for
/// the methods and properties defined here.
abstract class AuthProvider {
  /// A getter that returns the currently authenticated user as an AuthUser object.
  /// If no user is authenticated, it returns null.
  AuthUser? get currentUser;

  /// A method to create a new user with the provided email and password.
  /// This method returns a Future that resolves to an AuthUser object representing
  /// the newly created user.
  /// 
  /// Parameters:
  /// - email: The email address of the new user.
  /// - password: The password for the new user.
  
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  /// A method to send an email verification to the currently authenticated user.
  /// This method returns a Future that completes when the email has been sent.
  Future<void> sendEmailVerification();

  /// A method to log in a user with the provided email and password.
  /// This method returns a Future that resolves to an AuthUser object representing
  /// the authenticated user.
  /// 
  /// Parameters:
  /// - email: The email address of the user.
  /// - password: The password for the user.
  Future<AuthUser> login({
    required String email,
    required String password,
  });

  /// A method to log out the currently authenticated user.
  /// This method returns a Future that completes when the user has been logged out.
  Future<void> logout();
}