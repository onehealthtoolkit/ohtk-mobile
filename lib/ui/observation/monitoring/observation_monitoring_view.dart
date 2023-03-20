import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/back_appbar_action.dart';
import 'package:podd_app/components/report_image_carousel.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/ui/observation/form/monitoring_record_form_view.dart';
import 'package:podd_app/ui/observation/monitoring/observation_monitoring_view_model.dart';
import 'package:podd_app/ui/report/full_screen_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationMonitoringRecordView extends StatelessWidget {
  final ObservationMonitoringDefinition monitoringDefinition;
  final ObservationSubjectRecord subject;
  final ObservationMonitoringRecord monitoringRecord;

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
          title: Text(AppLocalizations.of(context)!
              .observationSubjectMonitoringViewTitle),
          leading: const BackAppBarAction(),
          automaticallyImplyLeading: false,
          shadowColor: Colors.transparent,
        ),
        body: viewModel.isBusy
            ? const Center(child: CircularProgressIndicator())
            : !viewModel.hasError
                ? _bodyView(context)
                : const Text("Monitoring record not found"),
      ),
    );
  }

  Widget _bodyView(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            children: [
              _MonitoringRecordDetail(),
              ReportImagesCarousel(monitoringRecord.images),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonitoringRecordDetail
    extends HookViewModelWidget<ObservationMonitoringRecordViewModel> {
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationMonitoringRecordViewModel viewModel) {
    var monitoringRecord = viewModel.data!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        _title(context, monitoringRecord),
        _description(context, monitoringRecord),
        _data(context, viewModel.subject, monitoringRecord,
            viewModel.monitoringDefinition),
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
      ObservationSubjectRecord subject,
      ObservationMonitoringRecord monitoringRecord,
      ObservationMonitoringDefinition monitoringDefinition) {
    var dataTable = Table(
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
        },
        children: monitoringRecord.formData!.entries.map((entry) {
          return entry.key.contains("__value")
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
          ? Stack(
              children: [
                dataTable,
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ObservationMonitoringRecordFormView(
                        monitoringDefinition: monitoringDefinition,
                        subject: subject,
                        monitoringRecord: monitoringRecord,
                      ),
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.edit_note),
                  ),
                )
              ],
            )
          : const Center(
              child: Text("No data"),
            ),
    );
  }
}
