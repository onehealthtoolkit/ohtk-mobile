import 'package:flutter/material.dart';
import 'package:podd_app/ui/resubmit/resubmit_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ReSubmitView extends StatelessWidget {
  const ReSubmitView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReSubmitViewModel>.nonReactive(
      viewModelBuilder: () => ReSubmitViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Outstanding reports"),
        ),
        body: _Body(),
      ),
    );
  }
}

class _Body extends HookViewModelWidget<ReSubmitViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ReSubmitViewModel viewModel) {
    return viewModel.isBusy
        ? const CircularProgressIndicator()
        : Column(
            children: [
              viewModel.isOffline
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: 30,
                      color: Colors.grey.shade400,
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                            "You are offline, please check your internet connection"),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: viewModel.submitAllPendingReport,
                      child: const Text("submit"),
                    ),
              Expanded(
                child: ListView.separated(
                  itemCount: viewModel.pendingReports.length,
                  itemBuilder: ((context, index) {
                    var reportState = viewModel.pendingReports[index];
                    return _PendingReport(reportState: reportState);
                  }),
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          );
  }
}

class _PendingReport extends StatelessWidget {
  final PendingReportState reportState;
  const _PendingReport({Key? key, required this.reportState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(reportState.report.reportTypeName ?? ""),
      trailing: _buildProgressStatus(reportState.state),
    );
  }

  Widget? _buildProgressStatus(Progress status) {
    switch (status) {
      case Progress.pending:
        return const CircularProgressIndicator();
      case Progress.complete:
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
        );
      case Progress.fail:
        return const Icon(
          Icons.close,
          color: Colors.red,
        );
      default:
        return null;
    }
  }
}
