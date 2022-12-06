import 'package:flutter/material.dart';
import 'package:podd_app/ui/observation/observation_subject_monitoring_view_model.dart';
import 'package:podd_app/ui/observation/observation_subject_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationSubjectMonitoringView extends StatelessWidget {
  final String subjectId;

  const ObservationSubjectMonitoringView({
    Key? key,
    required this.subjectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.nonReactive(
      viewModelBuilder: () => ObservationSubjectMonitoringViewModel(subjectId),
      builder: (context, model, child) => _MonitoringListing(),
    );
  }
}

class _MonitoringListing
    extends HookViewModelWidget<ObservationSubjectMonitoringViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectMonitoringViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async => viewModel.fetchSubjectMonitorings(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            var subject = viewModel.observationSubjectMonitorings[index];

            return ListTile(
                leading: Container(
                  color: Colors.grey,
                  width: 40,
                ),
                title: Text(subject.title ?? ""),
                dense: true,
                visualDensity: const VisualDensity(vertical: -3),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ObservationSubjectView(id: subject.id),
                    ),
                  );
                });
          },
          separatorBuilder: (context, index) => const Divider(),
          itemCount: viewModel.observationSubjectMonitorings.length,
        ),
      ),
    );
  }
}
