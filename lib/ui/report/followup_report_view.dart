import 'package:flutter/material.dart';
import 'package:podd_app/models/entities/followup_report.dart';
import 'package:podd_app/ui/report/followup_report_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:intl/intl.dart';

// View that creates and provides the viewmodel
class FollowupReportView extends StatelessWidget {
  final String id;
  const FollowupReportView({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FollowupReportViewModel>.nonReactive(
      builder: (context, model, child) => Scaffold(
          body: Center(
        child: _FollowupReportView(),
      )),
      viewModelBuilder: () => FollowupReportViewModel(id),
    );
  }
}

class _FollowupReportView extends HookViewModelWidget<FollowupReportViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, FollowupReportViewModel viewModel) {
    final followup = viewModel.data;
    if (followup == null) {
      return const CircularProgressIndicator();
    } else {
      var formatter = DateFormat("dd/MM/yyyy HH:mm");

      return Scaffold(
        appBar: AppBar(
          title: const Text("Followup detail"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _title(context, followup),
              const SizedBox(height: 10),
              Text(
                formatter.format(followup.createdAt),
                textScaleFactor: .75,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  color: Colors.white,
                  constraints: const BoxConstraints(
                      minHeight: 100, minWidth: double.infinity),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(followup.description.isEmpty
                        ? "no description"
                        : followup.description),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  _title(BuildContext context, FollowupReport incident) {
    return Row(
      children: [
        Text(
          incident.reportTypeName,
          textScaleFactor: 1.5,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
