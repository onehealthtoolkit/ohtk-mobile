import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/ui/home/home_view_model.dart';
import 'package:podd_app/ui/report_type/report_type_view.dart';
import 'package:podd_app/ui/resubmit/resubmit_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:intl/intl.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.nonReactive(
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          actions: [
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
    return ListView.builder(
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
          title: Text(report.reportTypeName),
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
        );
      },
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
