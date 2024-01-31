import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/back_appbar_action.dart';
import 'package:podd_app/components/report_file_grid_view.dart';
import 'package:podd_app/components/report_image_carousel.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/ui/observation/monitoring/observation_monitoring_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationMonitoringRecordView extends StatelessWidget {
  final String monitoringRecordId;

  const ObservationMonitoringRecordView({
    Key? key,
    required this.monitoringRecordId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ObservationMonitoringRecordViewModel>.reactive(
      viewModelBuilder: () => ObservationMonitoringRecordViewModel(
        monitoringRecordId: monitoringRecordId,
      ),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!
              .observationSubjectMonitoringViewTitle),
          leading: const BackAppBarAction(),
          automaticallyImplyLeading: false,
          shadowColor: Colors.transparent,
        ),
        body: viewModel.isBusy
            ? const Center(child: CircularProgressIndicator())
            : !viewModel.hasError
                ? _bodyView(context, viewModel)
                : const Text("Monitoring record not found"),
      ),
    );
  }

  Widget _bodyView(
      BuildContext context, ObservationMonitoringRecordViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            children: [
              _MonitoringRecordDetail(),
              ReportImagesCarousel(viewModel.data!.images),
              ReportFileGridView(viewModel.data!.files),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonitoringRecordDetail
    extends StackedHookView<ObservationMonitoringRecordViewModel> {
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget builder(
      BuildContext context, ObservationMonitoringRecordViewModel viewModel) {
    var monitoringRecord = viewModel.data!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        _title(context, monitoringRecord),
        _description(context, monitoringRecord),
        _data(context, monitoringRecord.subjectId, monitoringRecord,
            monitoringRecord.monitoringDefinitionId),
      ],
    );
  }

  _title(BuildContext context, ObservationMonitoringRecord subject) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
      child: Text(
        subject.title.isNotEmpty ? subject.title : "No title",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 20.sp,
            ),
      ),
    );
  }

  _description(BuildContext context, ObservationMonitoringRecord subject) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 10),
      child: Text(
        subject.description.isEmpty ? "No description" : subject.description,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }

  _data(
      BuildContext context,
      String subjectId,
      ObservationMonitoringRecord monitoringRecord,
      int monitoringDefinitionId) {
    var dataTable = Table(
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
        },
        children: monitoringRecord.formData!.entries.map((entry) {
          return entry.key.contains("__value") || entry.value == null
              ? const TableRow(children: [SizedBox.shrink(), SizedBox.shrink()])
              : TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: appTheme.secondary,
                        width: 1,
                      ),
                    ),
                  ),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 10),
      child: monitoringRecord.formData != null
          ? dataTable
          : const Center(
              child: Text("No data"),
            ),
    );
  }
}
