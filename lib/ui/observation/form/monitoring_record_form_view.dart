import 'package:flutter/material.dart' hide Form;
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/components/form_confirm.dart';
import 'package:podd_app/components/form_input.dart';
import 'package:podd_app/components/form_stepper.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/models/observation_monitoring_record_submit_result.dart';
import 'package:podd_app/models/submission_problem.dart';
import 'package:podd_app/ui/observation/form/monitoring_record_form_view_model.dart';
import 'package:podd_app/ui/report/form_base_view_model.dart';
import 'package:stacked/stacked.dart';

class ObservationMonitoringRecordFormView extends StatelessWidget {
  final String monitoringDefinitionId;
  final String subjectId;
  final ObservationMonitoringRecord? monitoringRecord;

  const ObservationMonitoringRecordFormView({
    Key? key,
    required this.monitoringDefinitionId,
    required this.subjectId,
    this.monitoringRecord,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ObservationMonitoringRecordFormViewModel>.reactive(
      viewModelBuilder: () => ObservationMonitoringRecordFormViewModel(
          monitoringDefinitionId, subjectId, monitoringRecord),
      builder: (context, viewModel, child) {
        if (!viewModel.isReady) {
          return const Center(child: OhtkProgressIndicator(size: 100));
        }
        return ConfirmPopScope(
          onWillPop: () => _onWillpPop(context),
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text(
                    "${AppLocalizations.of(context)!.reportTitle} ${viewModel.definition != null ? viewModel.definition!.name : ''}"),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    if (viewModel.state == ReportFormState.formInput)
                      FormStepper(form: viewModel.formStore),
                    if (viewModel.state == ReportFormState.confirmation)
                      Expanded(
                        flex: 1,
                        child: FormConfirmSubmit(
                          busy: viewModel.isBusy,
                          onSubmit: () async {
                            var result = await viewModel.submit();
                            if (!context.mounted) return;
                            final localize = AppLocalizations.of(context)!;
                            if (result is MonitoringRecordSubmitSuccess ||
                                result is MonitoringRecordSubmitPending) {
                              if (result is MonitoringRecordSubmitSuccess &&
                                  result.pendingAttachments > 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(localize
                                            .pendingAttachmentsNotice)));
                              } else if (result
                                      is MonitoringRecordSubmitPending &&
                                  result.problem != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text(localize.pendingSavedNotice)));
                              }
                              Navigator.pop(context);
                            } else if (result
                                is MonitoringRecordSubmitFailure) {
                              final problem = result.problem ??
                                  SubmissionProblem.from(result.exception);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          problem.localizedMessage(localize))));
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
          ),
        );
      },
    );
  }

  Future<bool> _onWillpPop(BuildContext context) async {
    return confirm(context);
  }
}
