import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

// the GenericDialog function returns a template of type T? cause it might be possible that I don't have
// any parameters at all.
Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        // Actions are the buttons which will perform some sort of action in an AlertDialog
        // I will map the options to a single optionTitle
        actions: options.keys.map(
          (optionTitle) {
            final value = options[optionTitle];
            return TextButton(
              onPressed: () {
                if (value != null) {
                  return Navigator.of(context).pop(value);
                } else {
                  // The value Okay will be provided - which is set to NULL
                  return Navigator.of(context).pop();
                }
              },
              child: Text(
                optionTitle,
              ),
            );
          },
        ).toList(), // actions needs a List: so I convert the mapped iterable to a list format
      );
    },
  );
}
