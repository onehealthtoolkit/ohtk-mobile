import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/ui/report/followup_report_view.dart';
import 'package:podd_app/utils.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:intl/intl.dart';

import 'followup_list_view_model.dart';

class FollowupListView extends StatelessWidget {
  final String incidentId;
  const FollowupListView(this.incidentId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FollowupListViewModel>.nonReactive(
        viewModelBuilder: () => FollowupListViewModel(incidentId),
        disposeViewModel: false,
        initialiseSpecialViewModelsOnce: true,
        builder: (context, viewModel, child) => _FollowupList());
  }
}

class _FollowupList extends HookViewModelWidget<FollowupListViewModel> {
  final formatter = DateFormat("dd/MM/yyyy HH:mm");

  @override
  Widget buildViewModelWidget(
      BuildContext context, FollowupListViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refetchFollowups();
      },
      child: ListView.separated(
        key: const PageStorageKey('all-followups-storage-key'),
        separatorBuilder: (context, index) => const Divider(),
        itemCount: viewModel.followupReport.length,
        itemBuilder: (context, index) {
          var followup = viewModel.followupReport[index];
          IncidentReportImage? image;
          if (followup.images?.isNotEmpty != false) {
            image = followup.images?.first;
          }
          return ListTile(
            leading: image != null
                ? CachedNetworkImage(
                    imageUrl: viewModel.resolveImagePath(image.thumbnailPath),
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                  )
                : Container(
                    color: Colors.grey,
                    width: 80,
                  ),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            title: const Text(" "),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatter.format(followup.createdAt.toLocal()),
                    textScaleFactor: .75),
                Text(
                  truncate(followup.trimWhitespaceDescription, length: 100),
                  textScaleFactor: .75,
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FollowupReportView(id: followup.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
