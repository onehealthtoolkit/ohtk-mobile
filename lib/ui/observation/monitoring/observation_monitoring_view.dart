import 'package:flutter/material.dart';
import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/ui/observation/form/monitoring_record_form_view.dart';
import 'package:podd_app/ui/observation/monitoring/observation_monitoring_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationMonitoringRecordView extends StatelessWidget {
  final ObservationMonitoringDefinition monitoringDefinition;
  final ObservationSubject subject;
  final ObservationSubjectMonitoring monitoringRecord;

  const ObservationMonitoringRecordView({
    Key? key,
    required this.monitoringDefinition,
    required this.subject,
    required this.monitoringRecord,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ObservationMonitoringRecordViewModel>.reactive(
      viewModelBuilder: () => ObservationMonitoringRecordViewModel(
        monitoringDefinition: monitoringDefinition,
        subject: subject,
        monitoringRecord: monitoringRecord,
      ),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Subject Monitoring View"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child: viewModel.isBusy
                ? const Center(child: CircularProgressIndicator())
                : !viewModel.hasError
                    ? _bodyView(context)
                    : const Text("Monitoring record not found")),
      ),
    );
  }

  SingleChildScrollView _bodyView(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
        child: Column(
          children: [
            _MonitoringRecordDetail(),
          ],
        ),
      ),
    );
  }
}

class _MonitoringRecordDetail
    extends HookViewModelWidget<ObservationMonitoringRecordViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationMonitoringRecordViewModel viewModel) {
    var monitoringRecord = viewModel.data!;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(monitoringRecord.id.toString()),
          const SizedBox(height: 10),
          Text(
            monitoringRecord.title,
            textScaleFactor: 1.5,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(monitoringRecord.description),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ObservationMonitoringRecordFormView(
                  monitoringDefinition: viewModel.monitoringDefinition,
                  subject: viewModel.subject,
                  monitoringRecord: monitoringRecord,
                ),
              ),
            ),
            child: const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.edit_note),
            ),
          ),
          _data(monitoringRecord),
        ],
      ),
    );
  }

  _data(ObservationSubjectMonitoring monitoringRecord) {
    var dataTable = Table(
        border: TableBorder.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1),
        },
        children: monitoringRecord.formData!.entries.map((entry) {
          return TableRow(
            children: [
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(entry.key),
                  )),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(entry.value.toString()),
                  )),
            ],
          );
        }).toList());

    return monitoringRecord.formData != null
        ? dataTable
        : const Text("no data");
  }
}
