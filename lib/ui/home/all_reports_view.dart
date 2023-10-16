import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/ui/home/all_reports_view_model.dart';
import 'package:podd_app/ui/home/report_list_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class AllReportsView extends StatefulWidget {
  const AllReportsView({Key? key}) : super(key: key);

  @override
  State<AllReportsView> createState() => _AllReportsViewState();
}

class _AllReportsViewState extends State<AllReportsView>
    with AutomaticKeepAliveClientMixin {
  final viewModel = locator<AllReportsViewModel>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<AllReportsViewModel>.nonReactive(
        viewModelBuilder: () => viewModel,
        disposeViewModel: false,
        initialiseSpecialViewModelsOnce: true,
        builder: (context, viewModel, child) => _ReportList());
  }

  @override
  bool get wantKeepAlive => true;
}

class _ReportList extends StackedHookView<AllReportsViewModel> {
  @override
  Widget builder(BuildContext context, AllReportsViewModel viewModel) {
    final isMounted = useIsMounted();
    useEffect(() {
      if (isMounted()) {
        // use future.delayed to avoid  widget cannot be marked as needing to build because the framework is already in the process of building widgets
        Future.delayed(Duration.zero, () {
          viewModel.refetchIncidentReports();
        });
      }
      return null;
    }, []);
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refetchIncidentReports();
      },
      child: !viewModel.isBusy
          ? ReportListView(
              viewModel: viewModel,
              key: const PageStorageKey('all-reports-storage-key'),
              trailingFn: (report) {
                return null;
              },
            )
          : const Center(
              child: OhtkProgressIndicator(
              size: 100,
            )),
    );
  }
}
