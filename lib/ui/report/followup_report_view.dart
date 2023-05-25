import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/components/back_appbar_action.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/components/report_file_grid_view.dart';
import 'package:podd_app/components/report_image_carousel.dart';
import 'package:podd_app/models/entities/followup_report.dart';
import 'package:podd_app/ui/report/followup_report_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

var formatter = DateFormat("dd/MM/yyyy HH:mm");

class FollowupReportView extends StatelessWidget {
  final String id;
  const FollowupReportView({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FollowupReportViewModel>.reactive(
      viewModelBuilder: () => FollowupReportViewModel(id),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          leading: const BackAppBarAction(),
          automaticallyImplyLeading: false,
          title: Text(AppLocalizations.of(context)!.followupDetailTitle),
        ),
        body: viewModel.isBusy
            ? const Center(child: OhtkProgressIndicator(size: 100))
            : !viewModel.hasError
                ? _FollowupReportView()
                : const Text("Incident report not found"),
      ),
    );
  }
}

class _FollowupReportView extends HookViewModelWidget<FollowupReportViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, FollowupReportViewModel viewModel) {
    final followup = viewModel.data;
    if (followup == null) {
      return const Center(child: OhtkProgressIndicator(size: 100));
    } else {
      return LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                _title(context, followup),
                _description(context, followup),
                ReportImagesCarousel(followup.images),
                ReportFileGridView(followup.files),
              ],
            ),
          ),
        );
      });
    }
  }

  _title(BuildContext context, FollowupReport followup) {
    return Container(
      height: 45,
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            followup.reportTypeName,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 20.sp,
                ),
          ),
          Text(
            formatter.format(followup.createdAt.toLocal()),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w300,
                ),
          ),
        ],
      ),
    );
  }

  _description(BuildContext context, FollowupReport followup) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 10),
      child: Text(
        followup.description.isEmpty
            ? "no description"
            : followup.trimWhitespaceDescription,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }
}
