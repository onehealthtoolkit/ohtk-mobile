import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/ui/home/all_reports_view_model.dart';
import 'package:podd_app/ui/report/incident_report_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class AllReportsView extends StatelessWidget {
  final viewModel = locator<AllReportsViewModel>();

  AllReportsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AllReportsViewModel>.nonReactive(
        viewModelBuilder: () => viewModel,
        disposeViewModel: false,
        initialiseSpecialViewModelsOnce: true,
        builder: (context, viewModel, child) => _ReportList());
  }
}

class _ReportList extends HookViewModelWidget<AllReportsViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, AllReportsViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refetchIncidentReports();
      },
      child: ListView.separated(
        key: const PageStorageKey('all-reports-storage-key'),
        separatorBuilder: (context, index) => const Divider(),
        itemCount: viewModel.incidentReports.length,
        itemBuilder: (context, index) {
          var report = viewModel.incidentReports[index];
          IncidentReportImage? image;
          if (report.images?.isNotEmpty != false) {
            image = report.images?.first;
          }
          var formatter = DateFormat("dd/MM/yyyy HH:mm");
          return ListTile(
            leading: image != null
                ? CachedNetworkImage(
                    imageUrl: viewModel.resolveImagePath(image.thumbnailPath),
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                  )
                : Container(
                    color: Colors.grey,
                    width: 80,
                  ),
            title: _title(context, report),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatter.format(report.createdAt), textScaleFactor: .75),
                Text(
                  report.description,
                  textScaleFactor: .75,
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => IncidentReportView(id: report.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  _title(BuildContext context, IncidentReport report) {
    return Row(
      children: [
        Text(report.reportTypeName),
        const SizedBox(width: 10),
        if (report.caseId != null)
          Container(
            color: Colors.red,
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
            child: const Text(
              "Case",
              style: TextStyle(
                color: Colors.white,
              ),
              textScaleFactor: 0.8,
            ),
          ),
      ],
    );
  }
}
