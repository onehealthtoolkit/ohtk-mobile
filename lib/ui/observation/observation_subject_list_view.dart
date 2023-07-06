import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/router.dart';
import 'package:podd_app/ui/observation/observation_subject_list_view_model.dart';
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

class _SubjectListing extends StackedHookView<ObservationSubjectListViewModel> {
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget builder(
      BuildContext context, ObservationSubjectListViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async => viewModel.refetchSubjects,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
        child: ListView.builder(
          key: const PageStorageKey('subject-list-storage-key'),
          itemBuilder: (context, index) {
            var subject = viewModel.observationSubjects[index];

            var leading = subject.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: subject.imageUrl!,
                    placeholder: (context, url) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                    fit: BoxFit.cover,
                  )
                : ColoredBox(
                    color: appTheme.sub4,
                    child: Image.asset(
                      "assets/images/OHTK.png",
                    ),
                  );

            return SubjectRecordItem(
              subject: subject,
              leading: leading,
              onTap: () {
                GoRouter.of(context).goNamed(
                  OhtkRouter.observationSubjectDetail,
                  pathParameters: {
                    "definitionId": viewModel.definition.id.toString(),
                    "subjectId": subject.id,
                  },
                );
              },
            );
          },
          itemCount: viewModel.observationSubjects.length,
        ),
      ),
    );
  }
}

class SubjectRecordItem extends StatelessWidget {
  final ObservationSubjectRecord subject;
  final void Function() onTap;
  final Widget? leading;

  final AppTheme appTheme = locator<AppTheme>();

  SubjectRecordItem({
    Key? key,
    required this.subject,
    required this.onTap,
    this.leading,
  }) : super(key: key);

  _title(BuildContext context, ObservationSubjectRecord report) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            report.title,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: appTheme.primary,
                ),
          ),
        ),
      ],
    );
  }

  _description() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            subject.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              color: appTheme.sub1,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Icon(
          Icons.arrow_forward_ios_sharp,
          size: 14,
          color: appTheme.secondary,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: appTheme.bg2,
        elevation: 0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 80.w,
                    maxWidth: 80.w,
                    minHeight: 75.w,
                    maxHeight: 75.w,
                  ),
                  child: leading,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title(context, subject),
                    _description(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
