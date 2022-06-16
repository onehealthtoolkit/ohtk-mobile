import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/form/form_data/form_data.dart';
import 'package:podd_app/form/form_store.dart';
import 'package:podd_app/form/widgets/form_question.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:provider/provider.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/ui/report/report_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ReportView extends StatelessWidget {
  final ReportType reportType;
  const ReportView(this.reportType, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReportViewModel>.reactive(
      viewModelBuilder: () {
        var model = ReportViewModel(reportType);
        return model;
      },
      builder: (context, viewModel, child) => Provider<FormStore>(
        create: (BuildContext context) => viewModel.formStore,
        builder: (context, widget) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Report"),
            ),
            body: Column(
              children: [
                if (viewModel.state == ReportFormState.confirmation)
                  Expanded(
                    flex: 1,
                    child: _ConfirmSubmit(),
                  ),
                if (viewModel.state == ReportFormState.formInput)
                  Expanded(
                    flex: 1,
                    child: _FormInput(),
                  ),
                if (viewModel.state == ReportFormState.formInput) _Footer(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FormInput extends HookViewModelWidget<ReportViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ReportViewModel viewModel) {
    FormStore store = viewModel.formStore;
    return Observer(
      builder: (_) => Provider<FormData>(
        create: (BuildContext context) => store.formData,
        child: ListView.builder(
          itemBuilder: (context, index) => FormQuestion(
            question: store.currentSection.questions[index],
          ),
          itemCount: store.currentSection.questions.length,
        ),
      ),
    );
  }
}

class _ConfirmSubmit extends HookViewModelWidget<ReportViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, ReportViewModel viewModel) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              var result = await viewModel.submit();
              if (result is ReportSubmitSuccess) {
                Navigator.pop(context);
              }
            },
            child: const Text("Submit"),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.back();
            },
            child: const Text("Back"),
          ),
        ],
      ),
    );
  }
}

class _Footer extends HookViewModelWidget<ReportViewModel> {
  final Logger logger = locator<Logger>();
  @override
  Widget buildViewModelWidget(BuildContext context, ReportViewModel viewModel) {
    double height = MediaQuery.of(context).size.height * 0.1;

    return Container(
      height: height,
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              if (viewModel.back() == BackAction.navigationPop) {
                logger.d("back using pop");
                Navigator.popUntil(context, ModalRoute.withName("/"));
              } else {
                logger.d("back but do nothing");
              }
            },
            child: const Text("< back"),
          ),
          const Spacer(flex: 1),
          ElevatedButton(
            onPressed: () {
              viewModel.next();
            },
            child: const Text("next >"),
          ),
        ],
      ),
    );
  }
}
