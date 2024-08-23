import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/enums/menu_action.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/services/crud/notes_services.dart';
import 'package:notes_app/utilities/alert_dialog.dart';
import 'dart:developer' as logging show log;

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  // Now I have to connect the backend database service with the UI. Hence I will open my notesService here
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase()
      .currentUser!
      .email!; // I am forcing wrapping it to be non-null. Because at this stage, its the only way to authenticate the users

  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes View"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNote);
            },
            icon: const Icon(
              Icons.add,
            ),
          ),
          PopupMenuButton<MenuOptions>(
            onSelected: (value) async {
              switch (value) {
                case MenuOptions.logout:
                  final dialogVal = await showAlertDialog(context);
                  logging.log(dialogVal.toString());
                  // Okay if I have logged out, I should navigate to the login page
                  // Depending upon the dialogVall, decide to log out the user from Firebase
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
      body: FutureBuilder(
        /*
        Purpose - "FutureBuilder" is used when I need to work with a "Future", which represents a single asynchronous computation that returns a 
        value once. Once the "Future" completes, the "FutureBuilder" rebuilds its widget tree based on the result 

        Use Case - It is commonly used for tasks like fetching data from a network, loading a file, or any asynchronous operation 
        that results in a single outcome 

        Rebuilding - The widget tree built by "FutureBuilder" is only rebuilt when the "Future" completes. After the "Future" is resolved, 
        the builder function does not run again unless the "Future" itself is replaced 

        */
        future: _notesService.getOrCreateUser(
          email: userEmail,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                /*
                Purpose - StreamBuilder is used when one needs to work with a Stream, which represents a sequence of 
                asynchronous events over time. it rebuilds its widget tree every time a new event is emitted by
                the "stream". 

                Use Case - It is ideal for real-time data handling, such as receiving updates from a 
                Websocket, listening to data changes in a database, or managing periodic updates (eg:, a timer)

                Rebuilding - The widget tree built by "StreamBuilder" is rebuilt every time the "Stream" emits a new value. This makes 
                it suitable for continuous data streams where you want the UI to reflect each piece of data as it arrives. 

                */
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    // Here I fixed a broken logic
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return const Text("All your notes will stream here...");
                    // Here I am actually trying to run a StreamBuilder where
                    default:
                      return CircularProgressIndicator();
                  }
                },
              );
            default:
              return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
