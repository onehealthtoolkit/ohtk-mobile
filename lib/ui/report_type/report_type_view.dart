import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/ui/report/report_form_view.dart';
import 'package:podd_app/ui/report_type/report_type_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ReportTypeView extends StatelessWidget {
  const ReportTypeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReportTypeViewModel>.nonReactive(
      viewModelBuilder: () => ReportTypeViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Report type"),
        ),
        body: _Listing(),
      ),
    );
  }
}

class _Listing extends HookViewModelWidget<ReportTypeViewModel> {
  final Logger logger = locator<Logger>();

  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportTypeViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.syncReportTypes();
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemBuilder: (context, categoryIndex) =>
              viewModel.categories[categoryIndex].reportTypes.isNotEmpty
                  ? _category(context, viewModel, categoryIndex)
                  : Container(),
          itemCount: viewModel.categories.length,
        ),
      ),
    );
  }

  _category(
      BuildContext context, ReportTypeViewModel viewModel, int categoryIndex) {
    double width = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              viewModel.categories[categoryIndex].category.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, reportTypeIndex) {
            var reportType = viewModel
                .categories[categoryIndex].reportTypes[reportTypeIndex];
            return ListTile(
              title: Text(reportType.name),
              onTap: () async {
                var allow = await viewModel.createReport(reportType.id);
                if (allow) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportFormView(reportType),
                    ),
                  ).then((value) => {logger.d("back from from $value")});
                }
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            );
          },
          itemCount: viewModel.categories[categoryIndex].reportTypes.length,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
        )
      ],
    );
  }
}
