import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podd_app/ui/observation/subject/observation_subject_report_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationSubjectReportView extends StatelessWidget {
  final int subjectId;

  const ObservationSubjectReportView({
    Key? key,
    required this.subjectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.nonReactive(
      viewModelBuilder: () => ObservationSubjectReportViewModel(subjectId),
      builder: (context, model, child) => _ReportListing(),
    );
  }
}

class _ReportListing
    extends HookViewModelWidget<ObservationSubjectReportViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectReportViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async => viewModel.fetchSubjectReports(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            var report = viewModel.observationSubjectReports[index];
            var leading = report.imageUrl == null
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
                title: Text(report.reportTypeName),
                dense: true,
                visualDensity: const VisualDensity(vertical: -3),
                onTap: () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) =>
                  //         ObservationSubjectView(id: Report.id),
                  //   ),
                  // );
                });
          },
          separatorBuilder: (context, index) => const Divider(),
          itemCount: viewModel.observationSubjectReports.length,
        ),
      ),
    );
  }
}
