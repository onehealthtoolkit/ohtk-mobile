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
          title: const Text("Pending submissions"),
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
      child: Text("There are no pending submissions."),
    );
  }

  _showPendingList(BuildContext context, ReSubmitViewModel viewModel) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _pendingTitle("Reports"),
                PendingList(
                  items: viewModel.pendingReports,
                  onDismissed: (String id) async {
                    await viewModel.deletePendingReport(id);
                  },
                ),
                _pendingTitle("Subject Records"),
                PendingList(
                  items: viewModel.pendingSubjectRecords,
                  onDismissed: (String id) async {
                    await viewModel.deletePendingSubjectRecord(id);
                  },
                ),
                _pendingTitle("Monitoring Records"),
                PendingList(
                  items: viewModel.pendingMonitoringRecords,
                  onDismissed: (String id) async {
                    await viewModel.deletePendingMonitoringRecord(id);
                  },
                ),
                _pendingTitle("Images"),
                PendingList(
                  items: viewModel.pendingImages,
                  onDismissed: (String id) async {
                    await viewModel.deletePendingImage(id);
                  },
                ),
                _pendingTitle("Files"),
                PendingList(
                  items: viewModel.pendingFiles,
                  onDismissed: (String id) async {
                    await viewModel.deletePendingFile(id);
                  },
                ),
              ],
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
                  onPressed:
                      !viewModel.isEmpty ? viewModel.submitAllPendings : null,
                  child: const Text("Resubmit"),
                ),
              ),
      ],
    );
  }

  _pendingTitle(String name) => Text(
        name,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
}

typedef ItemDismissedCallback = Function(String id);

class PendingList extends StatelessWidget {
  final List<SubmissionState> items;
  final ItemDismissedCallback? onDismissed;

  const PendingList({
    required this.items,
    this.onDismissed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: ((context, index) {
          var reportState = items[index];

          return Dismissible(
            key: Key(reportState.item.id),
            background: Container(color: Colors.red),
            onDismissed: (direction) {
              onDismissed != null && onDismissed!(reportState.item.id);
            },
            child: Card(
              child: _PendingSubmission(reportState: reportState),
            ),
          );
        }),
        shrinkWrap: true,
      ),
    );
  }
}

class _PendingSubmission extends StatelessWidget {
  final SubmissionState reportState;
  _PendingSubmission({Key? key, required this.reportState}) : super(key: key);
  final formatter = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(reportState.item.name),
      subtitle: reportState.item.date != null
          ? Text(formatter.format(reportState.item.date!.toLocal()))
          : null,
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
          Icons.block,
          color: Colors.red,
        );
      default:
        return null;
    }
  }
}
