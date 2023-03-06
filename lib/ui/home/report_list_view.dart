import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/ui/report/incident_report_view.dart';

import 'all_reports_view_model.dart';

typedef TrailingFunction = Widget? Function(IncidentReport report);

var formatter = DateFormat("dd/MM/yyyy HH:mm");

class ReportListView<T extends BaseReportViewModel> extends StatelessWidget {
  final T viewModel;
  final TrailingFunction trailingFn;

  final AppTheme appTheme = locator<AppTheme>();

  ReportListView({
    Key? key,
    required this.viewModel,
    required this.trailingFn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: ListView.builder(
        key: key,
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
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                  fit: BoxFit.cover,
                )
              : ColoredBox(
                  color: appTheme.placeholder,
                  child: Image.asset(
                    "assets/images/OHTK.png",
                  ),
                );

          var trailing = trailingFn(report);

          return IncidentReportItem(
            report: report,
            leading: leading,
            trailing: trailing,
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
}

class IncidentReportItem extends StatelessWidget {
  final IncidentReport report;
  final void Function() onTap;
  final Widget? leading;
  final Widget? trailing;

  final AppTheme appTheme = locator<AppTheme>();

  IncidentReportItem({
    Key? key,
    required this.report,
    required this.onTap,
    this.leading,
    this.trailing,
  }) : super(key: key);

  _testTag() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: appTheme.tag2,
      ),
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
      child: Text(
        "Test",
        style: TextStyle(
          color: appTheme.bg1,
        ),
        textScaleFactor: 0.8,
      ),
    );
  }

  _caseTag() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: appTheme.tag1,
      ),
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Text(
        "Case",
        style: TextStyle(
          color: appTheme.bg1,
        ),
        textScaleFactor: 0.7,
      ),
    );
  }

  _title(BuildContext context, IncidentReport report) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          report.reportTypeName,
          textScaleFactor: 1.2,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          formatter.format(report.createdAt.toLocal()),
          textScaleFactor: .9,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.w100),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var imageRatio = 0.23;
    var imageWidth = MediaQuery.of(context).size.width * imageRatio;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: appTheme.bg2,
      elevation: 0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: imageWidth,
                  maxWidth: imageWidth,
                  minHeight: imageWidth,
                  maxHeight: imageWidth,
                ),
                child: leading,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title(context, report),
                  Text(
                    report.trimWhitespaceDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      if (report.caseId != null) _caseTag(),
                      if (report.testFlag)
                        const SizedBox(
                          width: 5,
                        ),
                      if (report.testFlag) _testTag(),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
