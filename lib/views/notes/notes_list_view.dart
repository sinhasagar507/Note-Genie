import 'package:flutter/material.dart';
import 'package:notes_app/services/crud/notes_services.dart';
import 'package:notes_app/utilities/dialogs/delete_dialog.dart';

// Defining a callback placeholder
typedef NoteCallback = void Function(DataBaseNote note);

class NotesListView extends StatelessWidget {
  final List<DataBaseNote> notes;

  // The callback function
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (
        context,
        index,
      ) {
        final note = notes[index];
        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () async {
            onTap(note);
          },
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            icon: const Icon(
              Icons.delete,
            ),
          ),
        );
      },
    );
    // return const Text("Got all the notes");
  }
}
