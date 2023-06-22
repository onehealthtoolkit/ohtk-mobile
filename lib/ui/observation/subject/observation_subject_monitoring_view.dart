import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/opsv_form/widgets/widgets.dart';
import 'package:podd_app/ui/observation/subject/observation_subject_monitoring_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationSubjectMonitoringView extends StatelessWidget {
  final ObservationDefinition definition;
  final ObservationSubjectRecord subject;

  const ObservationSubjectMonitoringView({
    Key? key,
    required this.definition,
    required this.subject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.nonReactive(
      viewModelBuilder: () => ObservationSubjectMonitoringViewModel(
        definition: definition,
        subject: subject,
      ),
      builder: (context, model, child) => _MonitoringDefinitionListing(),
    );
  }
}

class _MonitoringDefinitionListing
    extends HookViewModelWidget<ObservationSubjectMonitoringViewModel> {
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectMonitoringViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async => viewModel.fetchSubjectMonitorings(),
      child: ListView.separated(
        itemBuilder: (context, index) {
          var monitoringDefinition =
              viewModel.observationMonitoringDefinitions[index];

          return ListTile(
            title: _title(context, viewModel, monitoringDefinition),
            subtitle: _MonitoringRecordListing(monitoringDefinition),
            contentPadding: const EdgeInsets.all(0),
          );
        },
        separatorBuilder: (context, index) => CustomPaint(
          painter: DashedLinePainter(backgroundColor: appTheme.primary),
          child: Container(
            height: 1.h,
          ),
        ),
        itemCount: viewModel.observationMonitoringDefinitions.length,
      ),
    );
  }

  _title(
    BuildContext context,
    ObservationSubjectMonitoringViewModel viewModel,
    ObservationMonitoringDefinition monitoringDefinition,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              monitoringDefinition.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                color: appTheme.warn,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(16, 16),
              shape: const CircleBorder(),
            ),
            onPressed: () {
              GoRouter.of(context).goNamed(
                'observationMonitoringForm',
                pathParameters: {
                  "definitionId": viewModel.definition.id.toString(),
                  "subjectId": viewModel.subject.id,
                  "monitoringDefinitionId": monitoringDefinition.id.toString(),
                },
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _MonitoringRecordListing
    extends HookViewModelWidget<ObservationSubjectMonitoringViewModel> {
  final AppTheme appTheme = locator<AppTheme>();
  final ObservationMonitoringDefinition monitoringDefinition;

  _MonitoringRecordListing(this.monitoringDefinition);

  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectMonitoringViewModel viewModel) {
    var items = viewModel.getSortedMonitoringRecords(monitoringDefinition.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: ListView.builder(
        itemBuilder: (context, index) {
          var monitoring = items[index];

          var leading = monitoring.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: monitoring.imageUrl!,
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
          return MonitoringRecordItem(
              monitoring: monitoring,
              leading: leading,
              onTap: () {
                GoRouter.of(context).goNamed(
                  'observationMonitoringDetail',
                  pathParameters: {
                    "definitionId": viewModel.definition.id.toString(),
                    "subjectId": viewModel.subject.id,
                    "monitoringId": monitoring.id,
                  },
                );
              });
        },
        itemCount: items.length,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
      ),
    );
  }
}

class MonitoringRecordItem extends StatelessWidget {
  final ObservationMonitoringRecord monitoring;
  final void Function() onTap;
  final Widget? leading;

  final AppTheme appTheme = locator<AppTheme>();

  MonitoringRecordItem({
    Key? key,
    required this.monitoring,
    required this.onTap,
    this.leading,
  }) : super(key: key);

  _title(BuildContext context, ObservationMonitoringRecord report) {
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
            monitoring.description,
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
                    _title(context, monitoring),
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
