import 'package:flutter/material.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/services/cloud/cloud_note.dart';
import 'package:notes_app/utilities/generics/get_arguments.dart';
import 'package:notes_app/services/cloud/firebase_cloud_storage.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    // If I am disposing something, I need to initialize it as well in _initstate() and only then I can do anything
    super.initState();
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final existingNote = _note;
    final widgetNote = context.getArgument<CloudNote>();

    // Check if there exists an argument for updating the note
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase()
        .currentUser!; // App should definitely crash if I am able to reach up till this point without notifying the user
    final userId = currentUser.id; // the email should definitely be there
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      // Okay so I have created an instance of new note in the database
      _notesService.deleteNote(
          documentId: note.documentId); // Delete the note with the given ID
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;

    if (note != null && text.isNotEmpty) {
      await _notesService.updateNotes(documentId: note.documentId, text: text);
    }
  }

  // I am not gonna leave execution till the last minute (wait for the user to press back button) for the
  // updates to happen.

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }

    final text = _textController.text;
    await _notesService.updateNotes(documentId: note.documentId, text: text);
  }

  // Hook our textController to the listener for proper updates
  // Remove and add the listener if it gets called multiple times
  void _setUpTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  @override
  void dispose() {
    // When I am letting go of the current application context, what all steps i need to perform will be listed over here
    super.dispose();
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // _note = snapshot.data; Its not a good idea that a core variable is being changed this way (it should be handled in the note view itself)
              _setUpTextControllerListener(); // I have setup the TextController because at this point I really want to start listening to the main UI
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Start typing your notes...",
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
