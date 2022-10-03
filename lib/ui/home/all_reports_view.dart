import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/ui/home/all_reports_view_model.dart';
import 'package:podd_app/ui/home/report_list_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class AllReportsView extends StatelessWidget {
  final viewModel = locator<AllReportsViewModel>();

  AllReportsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AllReportsViewModel>.nonReactive(
        viewModelBuilder: () => viewModel,
        disposeViewModel: false,
        initialiseSpecialViewModelsOnce: true,
        builder: (context, viewModel, child) => _ReportList());
  }
}

class _ReportList extends HookViewModelWidget<AllReportsViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, AllReportsViewModel viewModel) {
    final isMounted = useIsMounted();
    useEffect(() {
      if (isMounted()) {
        viewModel.refetchIncidentReports();
      }
      return null;
    }, []);
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refetchIncidentReports();
      },
      child: ReportListView(
        viewModel: viewModel,
        key: const PageStorageKey('all-reports-storage-key'),
        trailingFn: (report) {
          return null;
        },
      ),
    );
  }
}
