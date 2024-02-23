import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podd_app/ui/resubmit/resubmit_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReSubmitView extends StatelessWidget {
  const ReSubmitView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var localize = AppLocalizations.of(context);
    return ViewModelBuilder<ReSubmitViewModel>.nonReactive(
      viewModelBuilder: () => ReSubmitViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: Text(localize!.pendingAppLabel),
        ),
        body: _Body(),
      ),
    );
  }
}

class _Body extends StackedHookView<ReSubmitViewModel> {
  @override
  Widget builder(BuildContext context, ReSubmitViewModel viewModel) {
    if (viewModel.isBusy) {
      return const CircularProgressIndicator();
    }
    return viewModel.isEmpty
        ? _showEmptyMessage(context, viewModel)
        : _showPendingList(context, viewModel);
  }

  _showEmptyMessage(BuildContext context, ReSubmitViewModel viewModel) {
    return Center(
      child: SizedBox(
        height: 300,
        child: Column(
          children: [
            Text(AppLocalizations.of(context)!.noPendingSubmissions),
            ElevatedButton(
              onPressed: () {
                Navigator.maybePop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocalizations.of(context)!.formBackButton,
                  style: TextStyle(
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showPendingList(BuildContext context, ReSubmitViewModel viewModel) {
    var localize = AppLocalizations.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (viewModel.pendingReports.isNotEmpty)
                          ? _pendingTitle(localize!.pendingReportsTitle)
                          : Container(),
                      PendingList(
                        items: viewModel.pendingReports,
                        onDismissed: (String id) async {
                          await viewModel.deletePendingReport(id);
                        },
                      ),
                      viewModel.pendingSubjectRecords.isNotEmpty
                          ? _pendingTitle(localize!.pendingSubjectsTitle)
                          : Container(),
                      PendingList(
                        items: viewModel.pendingSubjectRecords,
                        onDismissed: (String id) async {
                          await viewModel.deletePendingSubjectRecord(id);
                        },
                      ),
                      viewModel.pendingMonitoringRecords.isNotEmpty
                          ? _pendingTitle(localize!.pendingMonitoringsTitle)
                          : Container(),
                      PendingList(
                        items: viewModel.pendingMonitoringRecords,
                        onDismissed: (String id) async {
                          await viewModel.deletePendingMonitoringRecord(id);
                        },
                      ),
                      viewModel.pendingImages.isNotEmpty
                          ? _pendingTitle(localize!.pendingImagesTitle)
                          : Container(),
                      PendingList(
                        items: viewModel.pendingImages,
                        onDismissed: (String id) async {
                          await viewModel.deletePendingImage(id);
                        },
                      ),
                      viewModel.pendingFiles.isNotEmpty
                          ? _pendingTitle(localize!.pendingFilesTitle)
                          : Container(),
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
            ),
          ),
          viewModel.isOffline
              ? Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  color: Colors.red.shade400,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      localize!.offlineWarning,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
                  child: ElevatedButton(
                    onPressed:
                        !viewModel.isEmpty ? viewModel.submitAllPendings : null,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
                      child: Text(
                        localize!.resubmit,
                        style: TextStyle(
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      );
    });
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
        physics: const NeverScrollableScrollPhysics(),
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
