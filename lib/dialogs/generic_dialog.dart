import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionBuilder,
}) {
  final options = optionBuilder();

  return showDialog<T?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        actions: options.keys.map(
          (optionTitle) {
            final value = options[optionTitle];
            return TextButton(
              onPressed: () {
                if (value != value) {
                  Navigator.of(context).pop(value);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(optionTitle),
            );
          },
        ).toList(),
      );
    },
  );
}
