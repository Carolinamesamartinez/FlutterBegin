import 'package:flutter/material.dart';
import 'package:secondflutter/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
      context: context,
      title: 'log out',
      content: 'Are you sure you want to logout?',
      optionBuilder: () => {
            'Cancel': null,
            'Log Out': true,
          }).then((value) => value ?? false);
}
