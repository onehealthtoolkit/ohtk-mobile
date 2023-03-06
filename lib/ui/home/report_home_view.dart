import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
        Tab(
          child: Text(AppLocalizations.of(context)!.allReportTabLabel),
        ),
        Tab(
          child: Text(AppLocalizations.of(context)!.myReportTabLabel),
        ),
      ],
    );

    return ViewModelBuilder<ReportHomeViewModel>.nonReactive(
      viewModelBuilder: () => ReportHomeViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ColoredBox(
            color: appTheme.bg2,
            child: _tabBar,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReportTypeView(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TabBarView(controller: _tabController, children: [
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
}
