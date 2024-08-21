import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart';
import 'package:notes_app/firebase_options.dart';
import 'auth_user.dart';
import 'auth_provider.dart';
import 'auth_exception.dart';
import 'dart:developer' as logging show log;

class FirebaseAuthProvider implements AuthProvider {
  @override
  // TODO: implement currentUser
  AuthUser? get currentUser {
    // Get the current user from FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      logging
          .log(user.email.toString()); // Remove this as its not a good practice
      return AuthUser.fromFirebase(user);
    }
    // If the user is not null, return an AuthUser object
    else {
      logging.log("No user is currently logged in");
    }
    // If the user is null, return null
    return null;
  }

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    // TODO: implement createUser
    try {
      // Create a new user with the provided email and password
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      // Get the current user from FirebaseAuth
      final user = currentUser;
      // If the user is not null, return an AuthUser object
      if (user != null) {
        return user;
      }
      // If the user is null, throw an exception
      else {
        throw UserNotLoggedInException();
      }
    } on FirebaseAuthException catch (e) {
      // If an error occurs during user creation, throw an AuthException
      // Do nothing
      if (e.code == "weak-password") {
        // logging.log("The password provided is too weak.");
        throw WeakPasswordAuthException();
      } else if (e.code == "email-already-in-use") {
        // logging.log("The account already exists for that email.");
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == "invalid-email") {
        // logging.log("The email address is not valid.");
        throw InvalidEmailException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<AuthUser> login(
      {required String email, required String password}) async {
    // TODO: implement login
    try {
      // Log in the user with the provided email and password
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // Get the current user from FirebaseAuth
      final user = currentUser;
      // If the user is not null, return an AuthUser object
      if (user != null) {
        return user;
      }
      // If the user is null, throw an exception
      else {
        throw UserNotLoggedInException();
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          // logging.log("No user found for that email.");
          throw UserNotFoundAuthException();
        case 'wrong-password':
          // logging.log("Wrong password provided for that user.");
          throw WrongPasswordAuthException();
        case 'invalid-email':
          // logging.log("The email address is not valid.");
          throw InvalidEmailException();
        default:
          // logging.log("An error occurred: ${e.code}");
          throw GenericAuthException();
      }
    } catch (_) {
      print("Nothng found");
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logout() {
    // TODO: implement logout
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInException();
    }
  }

  @override
  Future<void> sendEmailVerification() {
    // TODO: implement sendEmailVerification
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.sendEmailVerification();
    } else {
      throw UserNotLoggedInException();
    }
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
