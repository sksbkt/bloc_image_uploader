import 'package:bloc_image_uploader/auth/auth_error.dart';
import 'package:bloc_image_uploader/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showAuthErrorDialog({
  required AuthError authError,
  required BuildContext context,
}) {
  return showGenericDialog<bool>(
    context: context,
    title: authError.dialogTitle,
    content: authError.dialogText,
    optionBuilder: () => {
      'Ok': true,
    },
  );
}
