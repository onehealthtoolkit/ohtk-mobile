import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/ui/home/all_reports_view.dart';
import 'package:podd_app/ui/home/my_reports_view.dart';
import 'package:podd_app/ui/home/report_home_view_model.dart';
import 'package:podd_app/ui/report_type/report_type_view.dart';
import 'package:podd_app/ui/resubmit/resubmit_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ReportHomeView extends HookWidget {
  const ReportHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TabController _tabController = useTabController(initialLength: 2);
    final primaryColor = Theme.of(context).primaryColor;
    TabBar _tabBar = TabBar(
      controller: _tabController,
      labelColor: Colors.blue[500],
      unselectedLabelColor: Colors.blue[200],
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
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
            color: Colors.white,
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
              _ReSubmitBlock(),
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

class _ReSubmitBlock extends HookViewModelWidget<ReportHomeViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportHomeViewModel viewModel) {
    if (viewModel.numberOfReportPendingToSubmit > 0) {
      return TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ReSubmitView(),
            ),
          );
        },
        child: Text(
            "${viewModel.numberOfReportPendingToSubmit} reports still pending to submit tap here to re-submit"),
      );
    }
    return Container();
  }
}
