import 'package:flutter/material.dart' hide Form;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/components/form_confirm.dart';
import 'package:podd_app/components/form_input.dart';
import 'package:podd_app/components/form_stepper.dart';
import 'package:podd_app/models/followup_submit_result.dart';
import 'package:podd_app/ui/report/followup_report_form_view_model.dart';
import 'package:podd_app/ui/report/form_base_view_model.dart';
import 'package:stacked/stacked.dart';

class FollowupReportFormView extends StatelessWidget {
  final String incidentId;
  final String reportTypeId;

  const FollowupReportFormView({
    Key? key,
    required this.reportTypeId,
    required this.incidentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FollowupReportFormViewModel>.reactive(
      viewModelBuilder: () => FollowupReportFormViewModel(
        incidentId: incidentId,
        reportTypeId: reportTypeId,
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
                  if (viewModel.state == ReportFormState.formInput)
                    FormStepper(form: viewModel.formStore),
                  if (viewModel.state == ReportFormState.confirmation)
                    Expanded(
                      flex: 1,
                      child: FormConfirmSubmit(
                        busy: viewModel.isBusy,
                        child: const Text(
                            "Press the submit button to submit your report"),
                        onSubmit: () async {
                          var result = await viewModel.submit();
                          if (result is FollowupSubmitSuccess) {
                            Navigator.pop(context);
                          }
                        },
                        onBack: () {
                          viewModel.back();
                        },
                      ),
                    ),
                  if (viewModel.state == ReportFormState.formInput)
                    Expanded(
                      flex: 1,
                      child: FormInput(viewModel: viewModel),
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
