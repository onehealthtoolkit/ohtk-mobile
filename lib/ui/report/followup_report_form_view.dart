import 'package:flutter/material.dart' hide Form;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:im_stepper/stepper.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/models/followup_submit_result.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/opsv_form/widgets/widgets.dart';
import 'package:podd_app/ui/report/followup_report_form_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FollowupReportFormView extends StatelessWidget {
  final String incidentId;
  final ReportType reportType;

  const FollowupReportFormView({
    Key? key,
    required this.reportType,
    required this.incidentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FollowupReportFormViewModel>.reactive(
      viewModelBuilder: () => FollowupReportFormViewModel(
        incidentId: incidentId,
        reportType: reportType,
      ),
      builder: (context, viewModel, child) {
        if (!viewModel.isReady) {
          return const Center(child: CircularProgressIndicator());
        }
        return WillPopScope(
          onWillPop: () async {
            return _onWillpPop(context);
          },
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.followupTitle),
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
                ],
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

class _FormInput extends HookViewModelWidget<FollowupReportFormViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, FollowupReportFormViewModel viewModel) {
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

class _ConfirmSubmit extends HookViewModelWidget<FollowupReportFormViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, FollowupReportFormViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
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
                if (result is FollowupSubmitSuccess) {
                  Navigator.pop(context);
                }
              },
              child: Text(AppLocalizations.of(context)!.submitButton),
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
              child: Text(AppLocalizations.of(context)!.backButton),
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

class _Footer extends HookViewModelWidget<FollowupReportFormViewModel> {
  final Logger logger = locator<Logger>();
  @override
  Widget buildViewModelWidget(
      BuildContext context, FollowupReportFormViewModel viewModel) {
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
            child: Text(AppLocalizations.of(context)!.formBackButton),
          ),
          const Spacer(flex: 1),
          ElevatedButton(
            onPressed: () {
              viewModel.next();
            },
            child: Text(AppLocalizations.of(context)!.formNextButton),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends HookViewModelWidget<FollowupReportFormViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, FollowupReportFormViewModel viewModel) {
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
