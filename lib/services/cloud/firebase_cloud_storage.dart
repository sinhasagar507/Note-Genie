import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/services/cloud/cloud_note.dart';
import 'package:notes_app/services/cloud/cloud_storage_constants.dart';
import 'package:notes_app/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  // The function 'allNotes' returns a stream of iterable collection objects.
  Stream<Iterable<CloudNote>> allNotes({
    required String
        ownerUserId, // The ID of the user whose notes are to be retrieved
  }) =>
      notes.snapshots().map((
            // Receives a stream of snapshots from the 'notes' collection
            event, // Each snapshot contains the current state of the notes collection
          ) =>
              event.docs // Access the list of documents from the snapshot
                  .map((
                    doc, // For each document in the snapshot
                  ) =>
                      CloudNote.fromSnapshot(
                        // Convert the document data into a CloudNote object
                        doc,
                      ))
                  .where((
                    note, // Filter the CloudNote objects
                  ) =>
                      note.ownerUserId ==
                      ownerUserId)); // Only return notes that belong to the specified ownerUserId

  // The following function is used to 'update' a specific note
  Future<void> updateNotes({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({
        // From the 'notes' collection, retrieve the document with the appropriate document ID through the notes/document ID path
        textFieldName: text, // Update the document with the given 'text'
      });
    } catch (_) {
      throw CouldNotUpdateNoteException();
    }
  }

  // The following function is used to 'delete' a specific note
  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (_) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<Iterable> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (
              value,
            ) =>
                value.docs.map(
              (doc) => CloudNote(
                documentId: doc.id,
                ownerUserId: doc.data()[ownerUserIdFieldName] as String,
                text: doc.data()[textFieldName] as String,
              ),
            ),
          );
    } catch (_) {
      throw CouldNotGetAllNotesException;
    }
  }

  void createNewNote({required String ownerUserId}) async {
    await notes.add(
      {
        ownerUserIdFieldName: ownerUserId,
        textFieldName: '',
      },
    );
  }

  // Create a singleton class
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
