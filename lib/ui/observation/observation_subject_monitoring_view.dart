import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/ui/observation/observation_subject_monitoring_view_model.dart';
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
            subtitle: _MonitoringRecordListing(monitoringDefinition.id),
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
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(monitoringDefinition.name),
          ElevatedButton(
            child: const Icon(Icons.add),
            onPressed: () {
              //   Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ObservationSubjectFormView(
              //       definition: definition,
              //     ),
              //   ),
              // );
            },
          ),
        ],
      ),
    );
  }
}

class _MonitoringRecordListing
    extends HookViewModelWidget<ObservationSubjectMonitoringViewModel> {
  final int monitoringDefinitionId;

  const _MonitoringRecordListing(this.monitoringDefinitionId);

  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectMonitoringViewModel viewModel) {
    var items = viewModel.getSortedMonitoringRecords(monitoringDefinitionId);

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
                title: Text(monitoring.title ?? ""),
                dense: true,
                visualDensity: const VisualDensity(vertical: -3),
                onTap: () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) =>
                  //         ObservationSubjectView(id: monitoring.id),
                  //   ),
                  // );
                });
          },
          itemCount: items.length,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
        ),
      ),
    );
  }
}
