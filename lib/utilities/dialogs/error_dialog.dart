import 'package:flutter/material.dart';
import 'package:secondflutter/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog(
      context: context,
      title: 'An error ocurred',
      content: text,
      optionBuilder: () => {
            'OK': null,
          });
}
