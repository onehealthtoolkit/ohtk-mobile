import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/ui/home/home_view_model.dart';
import 'package:podd_app/ui/notification/user_message_list.dart';
import 'package:podd_app/ui/notification/user_message_view.dart';
import 'package:podd_app/ui/report/incident_report_view.dart';
import 'package:podd_app/ui/report_type/report_type_view.dart';
import 'package:podd_app/ui/resubmit/resubmit_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:intl/intl.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  _viewUserMessage(BuildContext context, String userMessageId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserMessageView(id: userMessageId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.nonReactive(
      viewModelBuilder: () => HomeViewModel(),
      fireOnModelReadyOnce: true,
      onModelReady: (viewModel) {
        viewModel.setupFirebaseMessaging(onBackgroundMessage: (userMessageId) {
          _viewUserMessage(context, userMessageId);
        }, onForegroundMessage: (userMessageId) {
          showSimpleNotification(
            const Text("You've got a new message"),
            trailing: Builder(builder: (context) {
              return TextButton(
                onPressed: () {
                  OverlaySupportEntry.of(context)!.dismiss();
                  _viewUserMessage(context, userMessageId);
                },
                child: const Text(
                  'View message',
                  style: TextStyle(color: Colors.amber),
                ),
              );
            }),
            background: Colors.blueAccent.shade700,
            slideDismissDirection: DismissDirection.horizontal,
            duration: const Duration(seconds: 3),
          );
        });
      },
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          actions: [
            IconButton(
              icon: const Icon(Icons.mail),
              tooltip: 'Messages',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserMessageList(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                viewModel.logout();
              },
            )
          ],
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
                child: _ReportList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportList extends HookViewModelWidget<HomeViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, HomeViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refetchIncidentReports();
      },
      child: ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        itemCount: viewModel.incidentReports.length,
        itemBuilder: (context, index) {
          var report = viewModel.incidentReports[index];
          IncidentReportImage? image;
          if (report.images?.isNotEmpty != false) {
            image = report.images?.first;
          }
          var formatter = DateFormat("dd/MM/yyyy HH:mm");
          return ListTile(
            leading: image != null
                ? CachedNetworkImage(
                    imageUrl: viewModel.resolveImagePath(image.filePath),
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                  )
                : Container(
                    color: Colors.grey,
                    width: 80,
                  ),
            title: _title(context, report),
            trailing: const Icon(Icons.arrow_forward_ios_sharp),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatter.format(report.createdAt), textScaleFactor: .75),
                Text(
                  report.description,
                  textScaleFactor: .75,
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => IncidentReportView(id: report.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  _title(BuildContext context, IncidentReport report) {
    return Row(
      children: [
        Text(report.reportTypeName),
        const SizedBox(width: 10),
        if (report.caseId != null)
          Container(
            color: Colors.red,
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
            child: const Text(
              "Case",
              style: TextStyle(
                color: Colors.white,
              ),
              textScaleFactor: 0.8,
            ),
          ),
      ],
    );
  }
}

class _ReSubmitBlock extends HookViewModelWidget<HomeViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, HomeViewModel viewModel) {
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
