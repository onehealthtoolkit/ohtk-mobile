import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:podd_app/components/back_appbar_action.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/components/report_file_grid_view.dart';
import 'package:podd_app/components/report_image_carousel.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/observation/subject/observation_subject_monitoring_view.dart';
import 'package:podd_app/ui/observation/subject/observation_subject_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationSubjectView extends HookWidget {
  final String definitionId;
  final String subjectId;

  const ObservationSubjectView({
    Key? key,
    required this.definitionId,
    required this.subjectId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 2);
    final selectedIndex = useState(0);

    useEffect(() {
      void listener() => selectedIndex.value = tabController.index;
      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    final localize = AppLocalizations.of(context)!;

    return ViewModelBuilder<ObservationSubjectViewModel>.reactive(
      viewModelBuilder: () =>
          ObservationSubjectViewModel(definitionId, subjectId),
      builder: (context, viewModel, child) => Scaffold(
        backgroundColor: OhtkColor.cream,
        appBar: AppBar(
          title: Text(localize.observationSubjectViewTitle),
          leading: const BackAppBarAction(),
          automaticallyImplyLeading: false,
        ),
        body: viewModel.isBusy
            ? const Center(child: OhtkProgressIndicator(size: 100))
            : viewModel.hasError
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Observation subject not found',
                        style: TextStyle(color: OhtkColor.ink500),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      _TabsStrip(
                        controller: tabController,
                        activeIndex: selectedIndex.value,
                        labels: [
                          localize.observationSubjectDetailTabLabel,
                          localize.observationSubjectMonitoringTabLabel,
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: tabController,
                          children: [
                            _SubjectDetail(),
                            ObservationSubjectMonitoringView(
                              definition: viewModel.data!.definition!,
                              subject: viewModel.data!,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _TabsStrip extends StatelessWidget {
  final TabController controller;
  final int activeIndex;
  final List<String> labels;

  const _TabsStrip({
    required this.controller,
    required this.activeIndex,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: OhtkColor.paper,
        border: Border(bottom: BorderSide(color: OhtkColor.line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: OhtkLayout.pagePad),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: _TabButton(
                label: labels[i],
                selected: activeIndex == i,
                onTap: () => controller.animateTo(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? OhtkColor.accent : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: selected ? OhtkColor.ink900 : OhtkColor.ink500,
          ),
        ),
      ),
    );
  }
}

class _SubjectDetail extends StackedHookView<ObservationSubjectViewModel> {
  @override
  Widget builder(BuildContext context, ObservationSubjectViewModel viewModel) {
    final subject = viewModel.data!;

    return SingleChildScrollView(
      key: const PageStorageKey('subject-detail-storage-key'),
      padding: const EdgeInsets.fromLTRB(
        OhtkLayout.pagePad,
        OhtkSpace.lg,
        OhtkLayout.pagePad,
        OhtkSpace.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderCard(subject: subject),
          if (subject.formData != null && subject.formData!.isNotEmpty) ...[
            const SizedBox(height: OhtkLayout.rowGap),
            _DataCard(formData: subject.formData!),
          ],
          if (subject.images?.isNotEmpty ?? false) ...[
            const SizedBox(height: OhtkLayout.sectionGap),
            const _SectionLabel(label: 'Images'),
            const SizedBox(height: OhtkSpace.xs),
            ReportImagesCarousel(subject.images),
          ],
          if (subject.files?.isNotEmpty ?? false) ...[
            const SizedBox(height: OhtkLayout.sectionGap),
            const _SectionLabel(label: 'Files'),
            const SizedBox(height: OhtkSpace.xs),
            ReportFileGridView(subject.files),
          ],
          const SizedBox(height: OhtkLayout.sectionGap),
          const _SectionLabel(label: 'Location'),
          const SizedBox(height: OhtkSpace.xs),
          _MapCard(),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: OhtkEyebrow(label: label),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ObservationSubjectRecord subject;

  const _HeaderCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    final title = subject.title.isNotEmpty ? subject.title : 'No title';
    final identity = subject.identity;
    final description = subject.description;

    return OhtkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: OhtkColor.ink900,
              height: 1.3,
            ),
          ),
          if (identity.isNotEmpty) ...[
            const SizedBox(height: OhtkSpace.xs),
            OhtkChip(label: identity, small: true),
          ],
          if (description.isNotEmpty) ...[
            const SizedBox(height: OhtkSpace.sm),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: OhtkColor.ink700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  final Map<String, dynamic> formData;

  const _DataCard({required this.formData});

  @override
  Widget build(BuildContext context) {
    final rows = formData.entries
        .where((e) => !e.key.contains('__value') && e.value != null)
        .toList();

    if (rows.isEmpty) return const SizedBox.shrink();

    return OhtkCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < rows.length; i++)
            Container(
              decoration: BoxDecoration(
                border: i == rows.length - 1
                    ? null
                    : const Border(
                        bottom: BorderSide(color: OhtkColor.lineSoft),
                      ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: OhtkLayout.cardPad,
                vertical: OhtkSpace.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      rows[i].key,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: OhtkColor.ink500,
                      ),
                    ),
                  ),
                  const SizedBox(width: OhtkSpace.md),
                  Expanded(
                    flex: 2,
                    child: Text(
                      rows[i].value.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: OhtkColor.ink900,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MapCard extends StackedHookView<ObservationSubjectViewModel> {
  @override
  Widget builder(BuildContext context, ObservationSubjectViewModel viewModel) {
    final latlng = viewModel.latlng;
    final mapControllerCompleter = Completer<GoogleMapController>();
    final markers = <Marker>{};

    if (latlng != null) {
      markers.add(Marker(
        markerId: const MarkerId('center'),
        position: LatLng(latlng[0], latlng[1]),
      ));
    }

    return OhtkCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: OhtkRadius.card,
        child: SizedBox(
          height: 220,
          width: double.infinity,
          child: latlng != null
              ? GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    zoom: 12,
                    target: LatLng(latlng[0], latlng[1]),
                  ),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  scrollGesturesEnabled: true,
                  onMapCreated: (controller) =>
                      mapControllerCompleter.complete(controller),
                  markers: markers,
                )
              : Container(
                  color: OhtkTheme.palette.teal50,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.location_off_outlined,
                        color: OhtkColor.ink400,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'No GPS location provided',
                        style: TextStyle(
                          fontSize: 13,
                          color: OhtkColor.ink500,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
