import 'package:flutter/material.dart' hide Form;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/components/form_confirm.dart';
import 'package:podd_app/components/form_input.dart';
import 'package:podd_app/components/form_stepper.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/models/observation_monitoring_record_submit_result.dart';
import 'package:podd_app/ui/observation/form/monitoring_record_form_view_model.dart';
import 'package:podd_app/ui/report/form_base_view_model.dart';
import 'package:stacked/stacked.dart';

class ObservationMonitoringRecordFormView extends StatelessWidget {
  final ObservationMonitoringDefinition monitoringDefinition;
  final ObservationSubjectRecord subject;
  final ObservationMonitoringRecord? monitoringRecord;

  const ObservationMonitoringRecordFormView({
    Key? key,
    required this.monitoringDefinition,
    required this.subject,
    this.monitoringRecord,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ObservationMonitoringRecordFormViewModel>.reactive(
      viewModelBuilder: () => ObservationMonitoringRecordFormViewModel(
          monitoringDefinition, subject, monitoringRecord),
      builder: (context, viewModel, child) {
        if (!viewModel.isReady) {
          return const Center(child: OhtkProgressIndicator(size: 100));
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
                title: Text(AppLocalizations.of(context)!.reportTitle +
                    " ${monitoringDefinition.name}"),
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
                          child: const Text(
                              "Press the submit button to submit your report"),
                          onSubmit: () async {
                            var result = await viewModel.submit();
                            if (result is MonitoringRecordSubmitSuccess ||
                                result is MonitoringRecordSubmitPending) {
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
          ),
        );
      },
    );
  }

  Future<bool> _onWillpPop(BuildContext context) async {
    return confirm(context);
  }
}
