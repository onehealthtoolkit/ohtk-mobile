import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/incident_report_tag.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/router.dart';

import 'all_reports_view_model.dart';

typedef TrailingFunction = Widget? Function(IncidentReport report);

var formatter = DateFormat("dd/MM/yyyy HH:mm");

/// rewrite code base of this thread
/// https://github.com/flutter/flutter/issues/19269#issuecomment-577515503
/// https://github.com/flutter/flutter/issues/19269#issuecomment-454164875
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
                  cacheKey: 'thumbnail-${image.id}',
                  imageUrl: viewModel.resolveImagePath(image.thumbnailPath),
                  placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    return Image.asset(
                      "assets/images/OHTK.png",
                    );
                  },
                )
              : ColoredBox(
                  color: appTheme.sub4,
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
              GoRouter.of(context).goNamed(
                OhtkRouter.incidentDetail,
                pathParameters: {
                  "incidentId": report.id,
                },
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: appTheme.bg2,
        elevation: 0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 80.w,
                    maxWidth: 80.w,
                    minHeight: 75.w,
                    maxHeight: 75.w,
                  ),
                  child: leading,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Title(report: report, appTheme: appTheme),
                    _Description(report: report, appTheme: appTheme),
                    _Options(report: report, trailing: trailing)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final IncidentReport report;
  final AppTheme appTheme;

  const _Title({Key? key, required this.report, required this.appTheme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            report.reportTypeName,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: appTheme.primary,
                ),
          ),
        ),
        Text(
          formatter.format(report.createdAt.toLocal()),
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

class _Description extends StatelessWidget {
  final IncidentReport report;
  final AppTheme appTheme;

  const _Description({Key? key, required this.report, required this.appTheme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            report.trimWhitespaceDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              color: appTheme.sub1,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Icon(
          Icons.arrow_forward_ios_sharp,
          size: 14,
          color: appTheme.secondary,
        ),
      ],
    );
  }
}

class _Options extends StatelessWidget {
  final IncidentReport report;
  final Widget? trailing;

  const _Options({Key? key, required this.report, this.trailing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              if (report.caseId != null) IncidentReportCaseTag(),
              if (report.testFlag) const SizedBox(width: 5),
              if (report.testFlag) IncidentReportTestTag(),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
