import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  // Displays a dialog and returns a Future<bool> indicating the user's choice
  return showDialog<bool>(
      // Just displays a dialog in the future and returns nothing
      context:
          context, // The current context in which the dialog should be shown
      builder: (BuildContext context) {
        // Builds the content of the dialog.
        return AlertDialog(
          title: Text(text), // The title of the alert dialog.
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Closes the dialog and returns nothing
                Navigator.of(context).pop();
              },
              child: const Text(
                  'Okay'), // Text displayed on the button which closes the dialog
            ),
          ],
        );
      });
  // After the dialog is dismissed, the Future completes and returns the value from the dialog, which is void in this case
}
