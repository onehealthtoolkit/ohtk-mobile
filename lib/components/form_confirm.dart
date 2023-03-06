import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podd_app/components/flat_button.dart';

typedef OnSubmit = Future<void> Function();

class FormConfirmSubmit extends StatelessWidget {
  final OnSubmit onSubmit;
  final Function() onBack;
  final Widget? child;
  final String? submitText;
  final String? backText;

  const FormConfirmSubmit(
      {required this.onSubmit,
      required this.onBack,
      this.child,
      this.submitText,
      this.backText,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
        child: Column(children: [
          child ?? Container(),
          const SizedBox(
            height: 20,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: FlatButton.primary(
              onPressed: () {
                onSubmit();
              },
              child: Text(
                  submitText ?? AppLocalizations.of(context)!.submitButton),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          TextButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50), // NEW
            ),
            onPressed: () {
              onBack();
            },
            child:
                Text(backText ?? AppLocalizations.of(context)!.formBackButton),
          ),
          const SizedBox(
            height: 60,
          )
        ]),
      ),
    );
  }
}
