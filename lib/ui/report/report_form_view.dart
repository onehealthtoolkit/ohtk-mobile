import 'package:flutter/material.dart' hide Form;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:im_stepper/stepper.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/opsv_form/widgets/widgets.dart';
import 'package:podd_app/ui/report/report_form_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ReportFormView extends StatelessWidget {
  final ReportType reportType;
  const ReportFormView(this.reportType, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReportFormViewModel>.reactive(
      viewModelBuilder: () => ReportFormViewModel(reportType),
      builder: (context, viewModel, child) {
        return WillPopScope(
          onWillPop: () async {
            return _onWillpPop(context);
          },
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: const Text("Report"),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    if (viewModel.state == ReportFormState.formInput)
                      _Stepper(),
                    if (viewModel.state == ReportFormState.confirmation)
                      Expanded(
                        flex: 1,
                        child: _ConfirmSubmit(),
                      ),
                    if (viewModel.state == ReportFormState.formInput)
                      Expanded(
                        flex: 1,
                        child: _FormInput(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _onWillpPop(BuildContext context) async {
    return confirm(context);
  }
}

class _FormInput extends HookViewModelWidget<ReportFormViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportFormViewModel viewModel) {
    final form = viewModel.formStore;
    return Observer(
      builder: (_) => ListView.builder(
        itemBuilder: (context, index) {
          if (index < form.currentSection.questions.length) {
            return FormQuestion(
              question: form.currentSection.questions[index],
            );
          } else {
            return _Footer();
          }
        },
        itemCount: form.currentSection.questions.length + 1,
      ),
    );
  }
}

class _ConfirmSubmit extends HookViewModelWidget<ReportFormViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportFormViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            _ConfirmIncidentArea(),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
              child: Text("Press the submit button to submit your report"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // NEW
              ),
              onPressed: () async {
                var result = await viewModel.submit();
                if (result is ReportSubmitSuccess ||
                    result is ReportSubmitPending) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Submit"),
            ),
            const SizedBox(
              height: 8,
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // NEW
              ),
              onPressed: () {
                viewModel.back();
              },
              child: const Text("Back"),
            ),
            const SizedBox(
              height: 60,
            )
          ],
        ),
      ),
    );
  }
}

class _ConfirmIncidentArea extends HookViewModelWidget<ReportFormViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportFormViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.center,
            child: Text(
              "Did this incident occur in your own authority?",
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          RadioListTile<bool?>(
            groupValue: viewModel.incidentInAuthority,
            title: const Text("yes"),
            value: true,
            onChanged: (bool? value) {
              viewModel.incidentInAuthority = value;
            },
          ),
          RadioListTile<bool?>(
            groupValue: viewModel.incidentInAuthority,
            title: const Text("no"),
            value: false,
            onChanged: (bool? value) {
              viewModel.incidentInAuthority = value;
            },
          ),
        ],
      ),
    );
  }
}

class _Footer extends HookViewModelWidget<ReportFormViewModel> {
  final Logger logger = locator<Logger>();
  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportFormViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () async {
              if (viewModel.back() == BackAction.navigationPop) {
                if (await confirm(context)) {
                  logger.d("back using pop");
                  Navigator.popUntil(context, ModalRoute.withName("/"));
                }
              } else {
                logger.d("back but do nothing");
              }
            },
            child: const Text("< back"),
          ),
          const Spacer(flex: 1),
          ElevatedButton(
            onPressed: () {
              viewModel.next();
            },
            child: const Text("next >"),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends HookViewModelWidget<ReportFormViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportFormViewModel viewModel) {
    Form store = viewModel.formStore;
    if (store.numberOfSections == 1) {
      return Container();
    }
    return Observer(
      builder: (_) => Column(
        children: [
          if (store.currentSection.label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Text(store.currentSection.label),
            ),
          NumberStepper(
            numbers:
                List.generate(store.numberOfSections, (index) => index + 1),
            activeStep: store.currentSectionIdx,
            activeStepColor: Colors.blue.shade200,
            stepColor: Colors.grey.shade400,
            stepRadius: 16,
            enableStepTapping: false,
            enableNextPreviousButtons: false,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
