import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/router.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/all_reports_view.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
import 'package:podd_app/ui/home/my_reports_view.dart';
import 'package:podd_app/ui/home/report_home_view_model.dart';
import 'package:stacked/stacked.dart';

class ReportHomeView extends HookWidget {
  const ReportHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 2);
    final selectedIndex = useState(0);

    useEffect(() {
      void listener() {
        if (!tabController.indexIsChanging) {
          selectedIndex.value = tabController.index;
        } else {
          selectedIndex.value = tabController.index;
        }
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    return ViewModelBuilder<ReportHomeViewModel>.nonReactive(
      viewModelBuilder: () => ReportHomeViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        backgroundColor: incidentsSand,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: _TabsStrip(
            controller: tabController,
            activeIndex: selectedIndex.value,
            labels: [
              AppLocalizations.of(context)!.allReportTabLabel,
              AppLocalizations.of(context)!.myReportTabLabel,
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 2, bottom: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: OhtkShadow.raised,
            ),
            child: FloatingActionButton.extended(
              backgroundColor: OhtkTheme.palette.teal700,
              foregroundColor: Colors.white,
              elevation: 0,
              highlightElevation: 0,
              shape: const StadiumBorder(),
              extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
              onPressed: () {
                GoRouter.of(context).goNamed(OhtkRouter.reportTypes);
              },
              icon: const Icon(Icons.add, size: 22),
              label: Text(
                AppLocalizations.of(context)!.newReportFabLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: const [
            AllReportsView(),
            MyReportsView(),
          ],
        ),
      ),
    );
  }
}

class _TabsStrip extends StatelessWidget {
  final TabController controller;
  final int activeIndex;
  final List<String> labels;

  const _TabsStrip({
    required this.controller,
    required this.activeIndex,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: OhtkColor.paper,
        border: Border(bottom: BorderSide(color: OhtkColor.line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: OhtkLayout.pagePad),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: _TabButton(
                label: labels[i],
                selected: activeIndex == i,
                onTap: () => controller.animateTo(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? OhtkColor.accent : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: selected ? OhtkColor.ink900 : OhtkColor.ink500,
          ),
        ),
      ),
    );
  }
}
