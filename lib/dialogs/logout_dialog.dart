import 'package:bloc_image_uploader/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Log out',
    content: 'Are you sure you want to Log out?',
    optionBuilder: () => {
      'Cancel': false,
      'Log out': true,
    },
  ).then(
    //! user can click outside the dialog and even tho its canceling the dialog but it wont return a value so we handle it and return false
    (value) => value ?? false,
  );
}
