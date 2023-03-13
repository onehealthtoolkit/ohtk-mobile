import 'package:flutter/material.dart';
import 'package:podd_app/components/flat_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            Text(
              AppLocalizations.of(context)!.confirm,
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
              child: textCancel ?? Text(AppLocalizations.of(context)!.no)),
          FlatButton.primary(
            child: textOK ?? Text(AppLocalizations.of(context)!.yes),
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
