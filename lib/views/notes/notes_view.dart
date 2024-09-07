import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/enums/menu_action.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/services/cloud/cloud_note.dart';
import 'package:notes_app/services/cloud/firebase_cloud_storage.dart';
import 'package:notes_app/utilities/dialogs/logout_dialog.dart';
import 'dart:developer' as logging show log;

import 'package:notes_app/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  // Now I have to connect the backend database service with the UI. Hence I will open my notesService here
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase()
      .currentUser!
      .id; // I am forcing wrapping it to be non-null. Because at this stage, its the only way to authenticate the users

  @override
  void initState() {
    super.initState();
    _notesService = FirebaseCloudStorage();
  }

  // I am currently disposing

  // @override
  // void dispose() {
  //   _notesService.close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes View"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createUpdateNote);
            },
            icon: const Icon(
              Icons.add,
            ),
          ),
          PopupMenuButton<MenuOptions>(
            onSelected: (value) async {
              switch (value) {
                case MenuOptions.logout:
                  final dialogVal = await showLogOutDialog(context);
                  logging.log(dialogVal.toString());
                  // Okay if I have logged out, I should navigate to the login page
                  // Depending upon the dialogValue, decide to log out the user from Firebase
                  if (dialogVal) {
                    AuthService.firebase().logout();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      login,
                      (_) => false,
                    );
                  }
                  break;
              }
            },
            icon: const Icon(Icons.more_vert), // Vertical 3 dots icon
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<MenuOptions>(
                  value: MenuOptions.logout,
                  child: Text("Logout"),
                ),
              ];
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(documentId: note.documentId);
                  },
                  onTap: (note) {
                    Navigator.of(context).pushNamed(
                      createUpdateNote,
                      arguments: note,
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }

            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
