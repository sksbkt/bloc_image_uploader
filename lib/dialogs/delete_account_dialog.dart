import 'package:bloc_image_uploader/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showDeleteAccountDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete account',
    content:
        'Are you sure you want to delete your account? you can not undo this operation!',
    optionBuilder: () => {
      'Cancel': false,
      'Delete account': true,
    },
  ).then(
    //! user can click outside the dialog and even tho its canceling the dialog but it wont return a value so we handle it and return false
    (value) => value ?? false,
  );
}
