import 'package:flutter/material.dart';
import 'package:podd_app/ui/observation/observation_subject_list_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationSubjectListView extends StatelessWidget {
  final String definitionId;

  const ObservationSubjectListView({
    Key? key,
    required this.definitionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.nonReactive(
      viewModelBuilder: () => ObservationSubjectListViewModel(definitionId),
      builder: (context, model, child) => _SubjectListing(),
    );
  }
}

class _SubjectListing
    extends HookViewModelWidget<ObservationSubjectListViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectListViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async => viewModel.refetchSubjects,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemBuilder: (context, index) {
            var subject = viewModel.observationSubjects[index];

            return ListTile(
              title: Text(subject.title ?? ""),
            );
          },
          separatorBuilder: (context, index) => const Divider(),
          itemCount: viewModel.observationSubjects.length,
        ),
      ),
    );
  }
}
