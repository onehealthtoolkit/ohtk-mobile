import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/ui/home/my_reports_view_model.dart';
import 'package:podd_app/ui/report/followup_report_form_view.dart';
import 'package:podd_app/ui/report/incident_report_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class MyReportsView extends StatelessWidget {
  final viewModel = locator<MyReportsViewModel>();

  MyReportsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MyReportsViewModel>.reactive(
      viewModelBuilder: () => viewModel,
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      onModelReady: (viewModel) => viewModel.init(),
      builder: (context, viewModel, child) => viewModel.isReady
          ? _ReportList()
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ReportList extends HookViewModelWidget<MyReportsViewModel> {
  final _logger = locator<Logger>();
  final formatter = DateFormat("dd/MM/yyyy HH:mm");

  @override
  Widget buildViewModelWidget(
      BuildContext context, MyReportsViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refetchIncidentReports();
      },
      child: ListView.separated(
        key: const PageStorageKey('my-reports-storage-key'),
        separatorBuilder: (context, index) => const Divider(),
        itemCount: viewModel.incidentReports.length,
        itemBuilder: (context, index) {
          var report = viewModel.incidentReports[index];
          IncidentReportImage? image;
          if (report.images?.isNotEmpty != false) {
            image = report.images?.first;
          }

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
            trailing: viewModel.canFollow(report.reportTypeId)
                ? _followLink(context, report, viewModel)
                : null,
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

  Widget _followLink(BuildContext context, IncidentReport report,
      MyReportsViewModel viewModel) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FollowupReportFormView(
              incidentId: report.id,
              reportType: viewModel.getReportType(report.reportTypeId)!,
            ),
          ),
        ).then((value) => {_logger.d("back from from $value")});
      },
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Padding(
          padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Text(
            "Follow",
            style: TextStyle(
              color: Colors.white,
            ),
            textScaleFactor: 0.8,
          ),
        ),
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
