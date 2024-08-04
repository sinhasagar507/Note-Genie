// This file defines custom exceptions for authentication-related errors.
// These exceptions help in handling specific error cases in a more granular way, 
// making it easier to debug and provide user-friendly error messages.

// Login Exceptions
// Thrown when the email address is already in use by another account.
class EmailAlreadyInUseAuthException implements Exception {}

// Thrown when the email address provided is not valid.
class InvalidEmailException implements Exception {}

// Register Exceptions
// Thrown when an operation is attempted without the user being logged in.
class UserNotLoggedInException implements Exception {}

// Thrown when the user is not found in the authentication system.
class UserNotFoundAuthException implements Exception {}

// Thrown when the password provided is incorrect.
class WrongPasswordAuthException implements Exception {}

// Thrown when the password provided is too weak
class WeakPasswordAuthException implements Exception {}

// Generic Exceptions
// Thrown for any generic authentication error that doesn't fit other specific cases.
class GenericAuthException implements Exception {}

// Thrown when an operation is attempted without the user being logged in (duplicate of UserNotLoggedInException).
class UserNotloggedInException implements Exception {}