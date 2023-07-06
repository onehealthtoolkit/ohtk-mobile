import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/followup_report.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

import 'followup_list_view_model.dart';

class FollowupListView extends StatelessWidget {
  final String incidentId;
  const FollowupListView(this.incidentId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FollowupListViewModel>.nonReactive(
      viewModelBuilder: () => FollowupListViewModel(incidentId),
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      builder: (context, viewModel, child) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
        child: _FollowupList(),
      ),
    );
  }
}

class _FollowupList extends StackedHookView<FollowupListViewModel> {
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget builder(BuildContext context, FollowupListViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refetchFollowups();
      },
      child: viewModel.followupReport.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context)!.noFollowupReport,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w300,
                    ),
              ),
            )
          : ListView.builder(
              key: const PageStorageKey('all-followups-storage-key'),
              itemCount: viewModel.followupReport.length,
              itemBuilder: (context, index) {
                var followup = viewModel.followupReport[index];

                IncidentReportImage? image;
                if (followup.images?.isNotEmpty != false) {
                  image = followup.images?.first;
                }
                var leading = image != null
                    ? CachedNetworkImage(
                        cacheKey: 'thumbnail-${image.id}',
                        imageUrl:
                            viewModel.resolveImagePath(image.thumbnailPath),
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                        fit: BoxFit.cover,
                      )
                    : ColoredBox(
                        color: appTheme.sub4,
                        child: Image.asset(
                          "assets/images/OHTK.png",
                        ),
                      );

                return FollowupReportItem(
                  report: followup,
                  leading: leading,
                  onTap: () {
                    GoRouter.of(context).goNamed(
                      OhtkRouter.incidentFollowup,
                      pathParameters: {
                        "incidentId": viewModel.incidentId,
                        "followupId": followup.id,
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

class FollowupReportItem extends StatelessWidget {
  final FollowupReport report;
  final void Function() onTap;
  final Widget? leading;

  final AppTheme appTheme = locator<AppTheme>();
  final formatter = DateFormat("dd/MM/yyyy HH:mm");

  FollowupReportItem({
    Key? key,
    required this.report,
    required this.onTap,
    this.leading,
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
                    _title(),
                    SizedBox(height: 5.h),
                    _description(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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

  _description() {
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
        SizedBox(width: 10.w),
        Icon(
          Icons.arrow_forward_ios_sharp,
          size: 9.h,
          color: appTheme.secondary,
        ),
      ],
    );
  }
}
