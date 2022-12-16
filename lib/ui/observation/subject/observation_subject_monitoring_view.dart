import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/ui/observation/form/monitoring_record_form_view.dart';
import 'package:podd_app/ui/observation/monitoring/observation_monitoring_view.dart';
import 'package:podd_app/ui/observation/subject/observation_subject_monitoring_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationSubjectMonitoringView extends StatelessWidget {
  final ObservationDefinition definition;
  final ObservationSubject subject;

  const ObservationSubjectMonitoringView({
    Key? key,
    required this.definition,
    required this.subject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.nonReactive(
      viewModelBuilder: () => ObservationSubjectMonitoringViewModel(
        definition: definition,
        subject: subject,
      ),
      builder: (context, model, child) => _MonitoringDefinitionListing(),
    );
  }
}

class _MonitoringDefinitionListing
    extends HookViewModelWidget<ObservationSubjectMonitoringViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectMonitoringViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async => viewModel.fetchSubjectMonitorings(),
      child: ListView.separated(
        itemBuilder: (context, index) {
          var monitoringDefinition =
              viewModel.observationMonitoringDefinitions[index];

          return ListTile(
            title: _title(context, viewModel, monitoringDefinition),
            subtitle: _MonitoringRecordListing(monitoringDefinition),
            contentPadding: const EdgeInsets.all(0),
          );
        },
        separatorBuilder: (context, index) => const Divider(),
        itemCount: viewModel.observationMonitoringDefinitions.length,
      ),
    );
  }

  _title(
    BuildContext context,
    ObservationSubjectMonitoringViewModel viewModel,
    ObservationMonitoringDefinition monitoringDefinition,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          bottom: BorderSide(width: 4.0, color: Colors.lightBlue.shade900),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(monitoringDefinition.name),
          ElevatedButton(
            child: const Icon(Icons.add),
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(16, 16),
              shape: const CircleBorder(),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ObservationMonitoringRecordFormView(
                    monitoringDefinition: monitoringDefinition,
                    subject: viewModel.subject,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MonitoringRecordListing
    extends HookViewModelWidget<ObservationSubjectMonitoringViewModel> {
  final ObservationMonitoringDefinition monitoringDefinition;

  const _MonitoringRecordListing(this.monitoringDefinition);

  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectMonitoringViewModel viewModel) {
    var items = viewModel.getSortedMonitoringRecords(monitoringDefinition.id);

    return RefreshIndicator(
      onRefresh: () async => viewModel.fetchSubjectMonitorings(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemBuilder: (context, index) {
            var monitoring = items[index];

            var leading = monitoring.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: monitoring.imageUrl!,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    fit: BoxFit.fill,
                  )
                : Container(
                    color: Colors.grey.shade300,
                    width: 80,
                  );

            return ListTile(
                contentPadding: const EdgeInsets.all(4),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 50,
                      maxWidth: 50,
                    ),
                    child: leading,
                  ),
                ),
                title: Text(monitoring.title),
                dense: true,
                visualDensity: const VisualDensity(vertical: -3),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ObservationMonitoringRecordView(
                        monitoringDefinition: monitoringDefinition,
                        subject: viewModel.subject,
                        monitoringRecord: monitoring,
                      ),
                    ),
                  );
                });
          },
          itemCount: items.length,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
        ),
      ),
    );
  }
}
