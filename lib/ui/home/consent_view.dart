import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/ui/home/consent_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ConsentView extends HookWidget {
  const ConsentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ConsentViewModel>.reactive(
      viewModelBuilder: () => ConsentViewModel(),
      builder: (context, viewModel, child) => Padding(
        padding: const EdgeInsets.all(8),
        child: viewModel.isBusy
            ? Center(child: const CircularProgressIndicator())
            : !viewModel.hasError
                ? _ConsentDetail()
                : const Text("Consent not found"),
      ),
    );
  }
}

class _ConsentDetail extends HookViewModelWidget<ConsentViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ConsentViewModel viewModel) {
    final detail = viewModel.data!;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Material(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  color: Colors.white,
                  constraints: const BoxConstraints(
                      minHeight: 80, minWidth: double.infinity),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(detail),
                  ),
                ),
              ),
              Row(children: [
                Checkbox(
                    value: viewModel.isConsent,
                    onChanged: (value) {
                      viewModel.setConsent(value);
                    }),
                Expanded(child: Text('I hereby consent to everything in here')),
              ]),
              Center(
                child: ElevatedButton(
                  onPressed: viewModel.isConsent
                      ? () {
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
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
