// Implement some Exception classes
// Databases are being referenced by a cursor. So if a database is already open, its not a desired scenario. A database reference must always be closed
class DatabaseAlreadyOpenException implements Exception {}

// Implement an Exception for when the database is already open
class DatabaseIsNotOpen implements Exception {}

// If unable to locate the file in directory, or the provided path is wrong, this exception will be thrown
class UnableToGetDocumentsDirectoryException implements Exception {}

// This exception gets implemented if we are trying to delete a particular user which doesn't even exist
class CannotDeleteUser implements Exception {}

// This particular exception is implemented if the user already exists in the database
class UserAlreadyExists implements Exception {}

// If I cannot find a particular user, then this particular exception will be thrown
class CouldNotFindUser implements Exception {}

// If I cannot find a particular note, then this particular exception will be thrown
class CouldNotDeleteNote implements Exception {}

// Class which implements CouldNotFindNote
class CouldNotFindNote implements Exception {}

// This is a class which asks to implement if the note can be updated or not
class CouldNotUpdateNote implements Exception {}
