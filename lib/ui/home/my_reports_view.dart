import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/ui/home/my_reports_view_model.dart';
import 'package:podd_app/ui/report/followup_report_form_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

import 'report_list_view.dart';

class MyReportsView extends StatefulWidget {
  const MyReportsView({Key? key}) : super(key: key);

  @override
  State<MyReportsView> createState() => _MyReportsViewState();
}

class _MyReportsViewState extends State<MyReportsView>
    with AutomaticKeepAliveClientMixin {
  final viewModel = locator<MyReportsViewModel>();

  @override
  bool wantKeepAlive = true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<MyReportsViewModel>.reactive(
        viewModelBuilder: () => viewModel,
        disposeViewModel: false,
        initialiseSpecialViewModelsOnce: true,
        builder: (context, viewModel, child) => _ReportList());
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
      child: !viewModel.isBusy
          ? ReportListView(
              viewModel: viewModel,
              key: const PageStorageKey('my-reports-storage-key'),
              trailingFn: (report) {
                var children = <Widget>[];
                if (viewModel.canFollow(report.reportTypeId) &&
                    !report.testFlag) {
                  children.insert(0, _followLink(context, report, viewModel));
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: children,
                );
              },
            )
          : const Center(
              child: OhtkProgressIndicator(
              size: 100,
            )),
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
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).primaryColor),
        padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
        child: Row(
          children: [
            Icon(
              Icons.file_open_outlined,
              size: 15.w,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.followupTitle,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
