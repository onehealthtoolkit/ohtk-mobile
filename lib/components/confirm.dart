import 'package:flutter/material.dart';
import 'package:podd_app/components/flat_button.dart';

/// credit to https://github.com/gtgalone/confirm_dialog
Future<bool> confirm(
  BuildContext context, {
  Widget? title,
  Widget? content,
  Widget? textOK,
  Widget? textCancel,
}) async {
  final bool? isConfirm = await showDialog<bool>(
    context: context,
    builder: (_) => WillPopScope(
      child: AlertDialog(
        title: title,
        content: content ??
            const Text(
              'Are you sure to continue?',
              textAlign: TextAlign.center,
            ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsPadding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
        actions: <Widget>[
          FlatButton.outline(
              onPressed: () => Navigator.pop(context, false),
              child: textCancel ?? const Text('No')),
          FlatButton.primary(
            child: textOK ?? const Text('Yes'),
            onPressed: () => Navigator.pop(context, true),
          )
        ],
      ),
      onWillPop: () async {
        Navigator.pop(context, false);
        return true;
      },
    ),
  );

  return isConfirm ?? false;
}
