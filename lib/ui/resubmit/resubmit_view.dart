import 'package:flutter/material.dart';
import 'package:podd_app/ui/resubmit/resubmit_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ReSubmitView extends StatelessWidget {
  const ReSubmitView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReSubmitViewModel>.nonReactive(
      viewModelBuilder: () => ReSubmitViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Re Submit"),
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
    return viewModel.isBusy
        ? const CircularProgressIndicator()
        : Column(
            children: [
              ElevatedButton(
                onPressed: viewModel.submit,
                child: const Text("submit"),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.pendingReports.length,
                  itemBuilder: ((context, index) {
                    var report = viewModel.pendingReports[index];
                    return ListTile(
                      title: Text(report.id),
                    );
                  }),
                ),
              ),
            ],
          );
  }
}
