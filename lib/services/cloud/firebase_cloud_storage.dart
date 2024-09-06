import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/services/cloud/cloud_note.dart';
import 'package:notes_app/services/cloud/cloud_storage_constants.dart';
import 'package:notes_app/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Stream<Iterable<CloudNote>> allNotes({
    required String ownerUserId,
  }) =>
      notes.snapshots().map((
            event,
          ) =>
              event.docs
                  .map((
                    doc,
                  ) =>
                      CloudNote.fromSnapshot(
                        doc,
                      ))
                  .where((
                    note,
                  ) =>
                      note.ownerUserId == ownerUserId));

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
