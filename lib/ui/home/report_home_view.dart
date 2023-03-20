import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/ui/home/all_reports_view.dart';
import 'package:podd_app/ui/home/my_reports_view.dart';
import 'package:podd_app/ui/home/report_home_view_model.dart';
import 'package:podd_app/ui/report_type/report_type_view.dart';
import 'package:stacked/stacked.dart';

class ReportHomeView extends HookWidget {
  final AppTheme appTheme = locator<AppTheme>();

  ReportHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TabController _tabController = useTabController(initialLength: 2);
    TabBar _tabBar = TabBar(
      controller: _tabController,
      tabs: [
        _tabItem(AppLocalizations.of(context)!.allReportTabLabel),
        _tabItem(AppLocalizations.of(context)!.myReportTabLabel),
      ],
    );

    return ViewModelBuilder<ReportHomeViewModel>.nonReactive(
      viewModelBuilder: () => ReportHomeViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56.w),
          child: ColoredBox(
            color: appTheme.bg2,
            child: _tabBar,
          ),
        ),
        floatingActionButton: CircleAvatar(
          radius: 30.r,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          child: IconButton(
            iconSize: 38.w,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportTypeView(),
                ),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TabBarView(controller: _tabController, children: const [
                  AllReportsView(),
                  MyReportsView(),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Tab _tabItem(String label) {
    return Tab(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Text(label),
      ),
    );
  }
}
