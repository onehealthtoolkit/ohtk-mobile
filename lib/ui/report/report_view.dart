import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:im_stepper/stepper.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/form/form_data/form_data.dart';
import 'package:podd_app/form/form_store.dart';
import 'package:podd_app/form/widgets/form_question.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:provider/provider.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/ui/report/report_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ReportView extends StatelessWidget {
  final ReportType reportType;
  const ReportView(this.reportType, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReportViewModel>.reactive(
      viewModelBuilder: () {
        var model = ReportViewModel(reportType);
        return model;
      },
      builder: (context, viewModel, child) => Provider<FormStore>(
        create: (BuildContext context) => viewModel.formStore,
        builder: (context, widget) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Report"),
            ),
            body: Column(
              children: [
                if (viewModel.state == ReportFormState.formInput) _Stepper(),
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
                if (viewModel.state == ReportFormState.formInput) _Footer(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FormInput extends HookViewModelWidget<ReportViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ReportViewModel viewModel) {
    FormStore store = viewModel.formStore;
    return Observer(
      builder: (_) => Provider<FormData>(
        create: (BuildContext context) => store.formData,
        child: ListView.builder(
          itemBuilder: (context, index) => FormQuestion(
            question: store.currentSection.questions[index],
          ),
          itemCount: store.currentSection.questions.length,
        ),
      ),
    );
  }
}

class _ConfirmSubmit extends HookViewModelWidget<ReportViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ReportViewModel viewModel) {
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

class _ConfirmIncidentArea extends HookViewModelWidget<ReportViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ReportViewModel viewModel) {
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

class _Footer extends HookViewModelWidget<ReportViewModel> {
  final Logger logger = locator<Logger>();
  @override
  Widget buildViewModelWidget(BuildContext context, ReportViewModel viewModel) {
    double height = MediaQuery.of(context).size.height * 0.1;

    return Container(
      height: height,
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              if (viewModel.back() == BackAction.navigationPop) {
                logger.d("back using pop");
                Navigator.popUntil(context, ModalRoute.withName("/"));
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

class _Stepper extends HookViewModelWidget<ReportViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ReportViewModel viewModel) {
    FormStore store = viewModel.formStore;
    return Observer(
      builder: (_) => NumberStepper(
        numbers: List.generate(store.numberOfSections, (index) => index + 1),
        activeStep: store.currentSectionIdx,
        activeStepColor: Colors.blue.shade500,
        stepColor: Colors.grey.shade400,
        stepRadius: 16,
        enableStepTapping: false,
        enableNextPreviousButtons: false,
      ),
    );
  }
}
