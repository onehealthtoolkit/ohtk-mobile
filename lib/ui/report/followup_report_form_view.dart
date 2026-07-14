import 'package:flutter/material.dart' hide Form;
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/components/form_chrome.dart';
import 'package:podd_app/components/form_confirm.dart';
import 'package:podd_app/components/form_input.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/followup_submit_result.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
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
          return Scaffold(
            backgroundColor: incidentsSand,
            body: Center(
              child: CircularProgressIndicator(
                color: OhtkTheme.palette.teal700,
              ),
            ),
          );
        }
        final localize = AppLocalizations.of(context)!;
        return ConfirmPopScope(
          onWillPop: () => _onWillpPop(context, viewModel),
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: incidentsSand,
              appBar: FormChromeAppBar(
                title: localize.followupTitle,
                onBack: () async {
                  if (await _onWillpPop(context, viewModel) &&
                      context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              body: SafeArea(
                top: false,
                child: Column(
                  children: [
                    if (viewModel.state == ReportFormState.formInput)
                      FormChromeProgressStrip(form: viewModel.formStore),
                    if (viewModel.state == ReportFormState.confirmation)
                      Expanded(
                        flex: 1,
                        child: FormConfirmSubmit(
                          busy: viewModel.isBusy,
                          showDataSummary: true,
                          dataSummary: viewModel.dataSummary,
                          submitText: localize.formChromeSubmitFollowupLabel,
                          onSubmit: () async {
                            final result = await viewModel.submit();
                            if (result is FollowupSubmitSuccess) {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
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
                        child: FormInput(
                          viewModel: viewModel,
                          onLastSectionValid: () {
                            viewModel.getReportDataSummary();
                          },
                        ),
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

  Future<bool> _onWillpPop(
      BuildContext context, FollowupReportFormViewModel viewModel) async {
    if (viewModel.state == ReportFormState.confirmation) {
      viewModel.back();
      return false;
    }
    return showExitConfirmDialog(context);
  }
}
