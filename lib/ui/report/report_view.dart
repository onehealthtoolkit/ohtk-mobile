import 'package:flutter/material.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/ui/report/report_view_model.dart';
import 'package:stacked/stacked.dart';

class ReportView extends StatelessWidget {
  final ReportType reportType;
  const ReportView(this.reportType, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReportViewModel>.nonReactive(
      viewModelBuilder: () {
        var model = ReportViewModel();
        return model;
      },
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Report"),
        ),
        body: Center(
          child: Text(reportType.name),
        ),
      ),
    );
  }
}
