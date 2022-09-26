import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/ui/report/incident_report_view.dart';

import 'all_reports_view_model.dart';

typedef TrailingFunction = Widget? Function(IncidentReport report);

var formatter = DateFormat("dd/MM/yyyy HH:mm");

class ReportListView<T extends BaseReportViewModel> extends StatelessWidget {
  final T viewModel;
  final TrailingFunction trailingFn;

  const ReportListView({
    Key? key,
    required this.viewModel,
    required this.trailingFn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: key,
      separatorBuilder: (context, index) => const Divider(),
      itemCount: viewModel.incidentReports.length,
      itemBuilder: (context, index) {
        var report = viewModel.incidentReports[index];
        IncidentReportImage? image;
        if (report.images?.isNotEmpty != false) {
          image = report.images?.first;
        }
        var leading = image != null
            ? CachedNetworkImage(
                imageUrl: viewModel.resolveImagePath(image.thumbnailPath),
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                fit: BoxFit.fill,
              )
            : Container(
                color: Colors.grey.shade300,
                width: 80,
              );
        var trailing = trailingFn(report);
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 70,
                  maxWidth: 70,
                  minHeight: 52,
                  maxHeight: 52,
                ),
                child: leading),
          ),
          title: _title(context, report),
          trailing: trailing,
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formatter.format(report.createdAt.toLocal()),
                  textScaleFactor: .75),
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
