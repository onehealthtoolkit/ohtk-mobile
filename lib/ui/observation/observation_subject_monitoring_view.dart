import 'package:cached_network_image/cached_network_image.dart';
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
            var monitoring = viewModel.observationSubjectMonitorings[index];
            var leading = monitoring.imageUrl == null
                ? CachedNetworkImage(
                    imageUrl: "https://picsum.photos/200/300",
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
          separatorBuilder: (context, index) => const Divider(),
          itemCount: viewModel.observationSubjectMonitorings.length,
        ),
      ),
    );
  }
}
