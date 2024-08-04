import 'package:flutter/material.dart';
import 'package:notes_app/constants/routes.dart';
import 'package:notes_app/services/auth/auth_service.dart';
import 'package:notes_app/utilities/alert_dialog.dart';
import 'dart:developer' as logging show log;

enum MenuOptions { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesviewState();
}

class _NotesviewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main UI"),
        actions: [
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
      body: const Center(
        child: Text("Notes View"),
      ),
    );
  }
}
