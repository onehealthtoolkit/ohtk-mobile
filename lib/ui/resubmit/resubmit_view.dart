import 'package:flutter/material.dart';
import 'package:podd_app/ui/resubmit/resubmit_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:intl/intl.dart';

class ReSubmitView extends StatelessWidget {
  const ReSubmitView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReSubmitViewModel>.nonReactive(
      viewModelBuilder: () => ReSubmitViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Pending reports"),
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
    if (viewModel.isBusy) {
      return const CircularProgressIndicator();
    }
    return viewModel.isEmpty
        ? _showEmptyMessage(context, viewModel)
        : _showPendingList(context, viewModel);
  }

  _showEmptyMessage(BuildContext context, ReSubmitViewModel viewModel) {
    return const Center(
      child: Text("There are no pending reports."),
    );
  }

  _showPendingList(BuildContext context, ReSubmitViewModel viewModel) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: viewModel.pendingReports.length,
              itemBuilder: ((context, index) {
                var reportState = viewModel.pendingReports[index];
                return Dismissible(
                  key: Key(reportState.report.id),
                  child: Card(
                    child: _PendingReport(reportState: reportState),
                  ),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) async {
                    await viewModel.deletePendingReport(reportState.report.id);
                  },
                );
              }),
            ),
          ),
        ),
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
            : Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
                child: ElevatedButton(
                  onPressed: viewModel.pendingReports.isNotEmpty
                      ? viewModel.submitAllPendingReport
                      : null,
                  child: const Text("resubmit pending report"),
                ),
              ),
      ],
    );
  }
}

class _PendingReport extends StatelessWidget {
  final PendingReportState reportState;
  _PendingReport({Key? key, required this.reportState}) : super(key: key);
  final formatter = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(reportState.report.reportTypeName ?? ""),
      subtitle:
          Text(formatter.format(reportState.report.incidentDate.toLocal())),
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
