import 'package:flutter/material.dart';
import 'package:secondflutter/utilities/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'password reset',
    content: 'we have sent you a password email',
    optionBuilder: () => {
      'Ok': null,
    },
  );
}
