import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:podd_app/ui/home/consent_view_model.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConsentView extends HookWidget {
  const ConsentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ConsentViewModel>.reactive(
      viewModelBuilder: () => ConsentViewModel(),
      builder: (context, viewModel, child) {
        if (viewModel.isBusy) {
          return const Scaffold(
            body: Center(
              child: OhtkProgressIndicator(),
            ),
          );
        }

        if (viewModel.hasError || viewModel.consentNotFound) {
          var duration = const Duration(seconds: 1);
          Timer(duration, () {
            Navigator.pop(context);
          });

          return const Scaffold(
            body: Center(
              child: OhtkProgressIndicator(),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8),
          child: _ConsentDetail(),
        );
      },
    );
  }
}

class _ConsentDetail extends HookViewModelWidget<ConsentViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ConsentViewModel viewModel) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Material(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                      minHeight: 80, minWidth: double.infinity),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Html(data: viewModel.consentContent),
                  ),
                ),
              ),
              CheckboxListTile(
                  value: viewModel.isConsent,
                  title: Text(viewModel.consentAcceptText),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    viewModel.setConsent(value);
                  }),
              if (viewModel.hasErrorForKey(consentErrorKey))
                Center(
                  child: Text(
                    viewModel.error(consentErrorKey),
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              Center(
                child: ElevatedButton(
                  onPressed: viewModel.isConsent
                      ? () async {
                          await viewModel.confirmConsent();
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Text(
                    AppLocalizations.of(context)!.consentButton,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
