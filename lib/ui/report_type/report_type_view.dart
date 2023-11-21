import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/back_appbar_action.dart';
import 'package:podd_app/components/flat_button.dart';
import 'package:podd_app/components/form_test_banner.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/opsv_form/widgets/widgets.dart';
import 'package:podd_app/ui/report_type/form_simulator_view.dart';
import 'package:podd_app/ui/report_type/qr_report_type_view.dart';
import 'package:podd_app/ui/report_type/report_type_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ReportTypeView extends StatelessWidget {
  final AppTheme appTheme = locator<AppTheme>();
  ReportTypeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReportTypeViewModel>.reactive(
      viewModelBuilder: () => ReportTypeViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          leading: const BackAppBarAction(),
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(AppLocalizations.of(context)!.reportTypeTitle),
          actions: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                tooltip: 'Simulate report form',
                onPressed: () async {
                  var result = await Navigator.push<ReportType>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QrReportTypeView(),
                    ),
                  );

                  if (context.mounted) {
                    if (result != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormSimulatorView(result),
                        ),
                      );
                    } else {
                      var errorMessage = SnackBar(
                        content: Text(AppLocalizations.of(context)
                                ?.invalidReportTypeQrcode ??
                            'Invalid report type qrcode'),
                        backgroundColor: Colors.red,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(errorMessage);
                    }
                  }
                },
              ),
            ),
            SizedBox(width: 5.w),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Refresh report form',
                onPressed: () async {
                  await viewModel.syncReportTypes();
                },
              ),
            ),
            SizedBox(width: 15.w),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await viewModel.syncReportTypes();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FormTestBanner(testFlag: viewModel.testFlag),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.67.h, 20.w, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _ZeroReport()),
                    _TestFlag(),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                    child: _Listing()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestFlag extends StackedHookView<ReportTypeViewModel> {
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget builder(BuildContext context, ReportTypeViewModel viewModel) {
    return GestureDetector(
      onTap: () {
        viewModel.testFlag = !viewModel.testFlag;
      },
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: FlatButton(
              padding: const EdgeInsets.fromLTRB(15, 6, 20, 6),
              onPressed: () {
                viewModel.testFlag = !viewModel.testFlag;
              },
              borderRadius: 8.r,
              backgroundColor:
                  viewModel.testFlag ? appTheme.tag2 : appTheme.sub4,
              borderColor: viewModel.testFlag ? appTheme.tag2 : appTheme.sub4,
              forgroundColor:
                  viewModel.testFlag ? appTheme.warn : appTheme.sub2,
              child: Padding(
                padding: const EdgeInsets.only(left: 35.0),
                child: Text(
                  AppLocalizations.of(context)?.testFlag ?? "Test",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            width: 40.w,
            height: 40.w,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: viewModel.testFlag ? appTheme.tag2 : appTheme.sub4,
                    width: 3),
                borderRadius: BorderRadius.circular(33.33.r),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 12, 9, 12),
                child: SvgPicture.asset(
                  "assets/images/check_icon.svg",
                  colorFilter: ColorFilter.mode(
                    viewModel.testFlag ? appTheme.warn : Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZeroReport extends StackedHookView<ReportTypeViewModel> {
  final AppTheme appTheme = locator<AppTheme>();
  final formatter = DateFormat('dd/MM/yyyy HH:mm');

  _ZeroReport({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, ReportTypeViewModel viewModel) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FlatButton.primary(
                padding: const EdgeInsets.fromLTRB(15, 6, 20, 6),
                onPressed: () async {
                  var success = await viewModel.submitZeroReport();

                  if (context.mounted) {
                    showZeroReportResultAlert(context, success);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 28.0),
                  child: Text(
                    AppLocalizations.of(context)?.zeroReportLabel ??
                        "Zero report",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              FutureBuilder<DateTime?>(
                future: viewModel.getLatestZeroReport(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      var dateTimeString =
                          formatter.format(snapshot.data!.toLocal());
                      return Text(
                        AppLocalizations.of(context)!
                            .zeroReportLastReportedMessage(dateTimeString),
                        textScaleFactor: 0.8,
                        style: TextStyle(color: appTheme.warn),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                  return const OhtkProgressIndicator(size: 50);
                },
              ),
            ],
          ),
        ),
        Positioned(
          width: 40.w,
          height: 40.w,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: appTheme.primary, width: 2.w),
              borderRadius: BorderRadius.circular(33.33).r,
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: SvgPicture.asset(
                "assets/images/doc_fill_icon.svg",
                colorFilter: ColorFilter.mode(
                    Theme.of(context).primaryColor, BlendMode.srcIn),
              ),
            ),
          ),
        )
      ],
    );
  }

  showZeroReportResultAlert(BuildContext context, bool success) {
    final AppTheme appTheme = locator<AppTheme>();
    String message = success
        ? AppLocalizations.of(context)?.zeroReportSubmitSuccess ??
            'Zero report submit success'
        : 'Failed to submit';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        contentTextStyle: TextStyle(
          fontSize: 16,
          color: success ? appTheme.primary : appTheme.warn,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          FlatButton.primary(
            child: Text(AppLocalizations.of(context)!.ok),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _Listing extends StackedHookView<ReportTypeViewModel> {
  final Logger logger = locator<Logger>();
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget builder(BuildContext context, ReportTypeViewModel viewModel) {
    return ListView.builder(
      itemBuilder: (context, categoryIndex) =>
          viewModel.categories[categoryIndex].reportTypes.isNotEmpty
              ? _category(context, viewModel, categoryIndex)
              : Container(),
      itemCount: viewModel.categories.length,
    );
  }

  _category(
      BuildContext context, ReportTypeViewModel viewModel, int categoryIndex) {
    var categoryReportType = viewModel.categories[categoryIndex];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 5),
          child: Text(
            categoryReportType.category.name,
            style: TextStyle(
              fontSize: 13.sp,
              color: appTheme.warn,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        ListView.builder(
          itemBuilder: (context, reportTypeIndex) {
            return _item(
                viewModel, context, categoryReportType, reportTypeIndex);
          },
          itemCount: categoryReportType.reportTypes.length,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
        )
      ],
    );
  }

  _item(ReportTypeViewModel viewModel, BuildContext context,
      CategoryAndReportType categoryReportType, int reportTypeIndex) {
    var reportType = categoryReportType.reportTypes[reportTypeIndex];
    return Column(
      children: [
        InkWell(
          onTap: () async {
            var allow = await viewModel.createReport(reportType.id);
            if (allow) {
              if (context.mounted) {
                GoRouter.of(context).pushReplacementNamed(
                  'reportForm',
                  pathParameters: {
                    "reportTypeId": reportType.id,
                  },
                  queryParameters: {"test": viewModel.testFlag ? '1' : '0'},
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 9, bottom: 5),
            child: Row(
              children: [
                _categoryIcon(categoryReportType.category.id,
                    categoryReportType.category.icon),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    reportType.name,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: appTheme.secondary,
                  size: 13.h,
                ),
              ],
            ),
          ),
        ),
        CustomPaint(
          painter: DashedLinePainter(backgroundColor: appTheme.primary),
          child: Container(
            height: 1.h,
          ),
        )
      ],
    );
  }

  _categoryIcon(int id, String iconUrl) {
    var icon = iconUrl.isNotEmpty
        ? CachedNetworkImage(
            cacheKey: 'categoryIcon-$id',
            imageUrl: iconUrl,
            placeholder: (context, url) => const Padding(
              padding: EdgeInsets.all(9),
              child: CircularProgressIndicator(),
            ),
            fit: BoxFit.cover,
          )
        : Image.asset(
            "assets/images/OHTK.png",
            color: appTheme.bg1,
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(33.33.r),
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(width: 33.33.w, height: 33.33.w),
        child: Container(
          padding: const EdgeInsets.all(9),
          color: appTheme.tertiary,
          child: icon,
        ),
      ),
    );
  }
}
