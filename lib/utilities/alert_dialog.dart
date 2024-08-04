import 'package:flutter/material.dart';

Future<bool> showAlertDialog(BuildContext context) {
  // Displays a dialog and returns a Future<bool> indicating the user's choice.
  return showDialog<bool>(
      context:
          context, // The current context in which the dialog should be shown.
      builder: (BuildContext context) {
        // Builds the content of the dialog.
        return AlertDialog(
          title: const Text('Signout'), // The title of the alert dialog.
          content: const Text('Are you sure you want to signout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Closes the dialog and returns false.
                Navigator.of(context).pop(false);
              },
              child:
                  const Text('Cancel'), // Text displayed on the cancel button.
            ),
            TextButton(
              onPressed: () {
                // Closes the dialog and returns true.
                // If the user confirms sign out, this will trigger the navigation to the home screen or appropriate action.
                Navigator.of(context).pop(true);
              },
              child: const Text(
                  'Signout'), // Text displayed on the signout button.
            ),
          ],
        );
      }).then((value) => value ?? false);
  // After the dialog is dismissed, the Future completes and returns the value from the dialog.
  // If the value is null (which happens if the dialog is dismissed without selecting an option), it returns false.
}
