import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/ui/observation/observation_subject_list_view_model.dart';
import 'package:podd_app/ui/observation/observation_subject_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationSubjectListView extends StatelessWidget {
  final ObservationDefinition definition;

  const ObservationSubjectListView({
    Key? key,
    required this.definition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.nonReactive(
      viewModelBuilder: () => ObservationSubjectListViewModel(definition),
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

            var leading = subject.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: subject.imageUrl!,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    fit: BoxFit.fill,
                  )
                : Container(
                    color: Colors.grey.shade300,
                    width: 80,
                  );

            return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 70,
                      maxWidth: 70,
                      minHeight: 52,
                      maxHeight: 52,
                    ),
                    child: leading,
                  ),
                ),
                title: Text(subject.title ?? ""),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ObservationSubjectView(
                        definition: viewModel.definition,
                        subject: subject,
                      ),
                    ),
                  );
                });
          },
          separatorBuilder: (context, index) => const Divider(),
          itemCount: viewModel.observationSubjects.length,
        ),
      ),
    );
  }
}
