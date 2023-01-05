import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
          title: Text(AppLocalizations.of(context)!
              .observationSubjectMonitoringViewTitle),
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

  Widget _bodyView(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            children: [
              _MonitoringRecordDetail(),
              _Images(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Images
    extends HookViewModelWidget<ObservationMonitoringRecordViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationMonitoringRecordViewModel viewModel) {
    final images = viewModel.data!.images;

    var imageWidgets = images?.map((image) => Container(
          margin: const EdgeInsets.all(0),
          child: FullScreenWidget(
            fullscreenChild: CachedNetworkImage(
              imageUrl: image.imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            child: CachedNetworkImage(
              imageUrl: image.thumbnailPath,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ));

    return Container(
      color: Colors.white,
      constraints:
          const BoxConstraints(minWidth: double.infinity, minHeight: 150),
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: 200,
        child: (images != null && images.isNotEmpty)
            ? CarouselSlider(
                items: imageWidgets?.toList() ?? [],
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  aspectRatio: 1,
                  viewportFraction: 0.8,
                  autoPlay: true,
                  disableCenter: true,
                  enableInfiniteScroll: false,
                ),
              )
            : const Text("No images uploaded"),
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
          Text(
            monitoringRecord.title.isNotEmpty
                ? monitoringRecord.title
                : "no title",
            textScaleFactor: 1.5,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            color: Colors.white,
            constraints:
                const BoxConstraints(minHeight: 80, minWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(monitoringRecord.description.isNotEmpty
                  ? monitoringRecord.description
                  : "no description"),
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 8),
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
          1: FlexColumnWidth(2),
        },
        children: monitoringRecord.formData!.entries.map((entry) {
          return entry.key.contains("__value")
              ? const TableRow(children: [SizedBox.shrink(), SizedBox.shrink()])
              : TableRow(
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
