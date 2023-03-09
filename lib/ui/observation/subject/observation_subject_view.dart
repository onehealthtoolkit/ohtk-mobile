import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/back_appbar_action.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/components/report_image_carousel.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/ui/observation/form/subject_form_view.dart';
import 'package:podd_app/ui/observation/subject/observation_subject_monitoring_view.dart';
import 'package:podd_app/ui/observation/subject/observation_subject_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationSubjectView extends HookWidget {
  final ObservationDefinition definition;
  final ObservationSubjectRecord subject;

  final AppTheme appTheme = locator<AppTheme>();

  ObservationSubjectView({
    Key? key,
    required this.definition,
    required this.subject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TabController _tabController = useTabController(initialLength: 2);

    return ViewModelBuilder<ObservationSubjectViewModel>.reactive(
      viewModelBuilder: () => ObservationSubjectViewModel(definition, subject),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title:
              Text(AppLocalizations.of(context)!.observationSubjectViewTitle),
          leading: const BackAppBarAction(),
          automaticallyImplyLeading: false,
          shadowColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: ColoredBox(
              color: appTheme.bg2,
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Text(AppLocalizations.of(context)!
                        .observationSubjectDetailTabLabel),
                  ),
                  Tab(
                    child: Text(AppLocalizations.of(context)!
                        .observationSubjectMonitoringTabLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: viewModel.isBusy
            ? const Center(child: OhtkProgressIndicator(size: 100))
            : !viewModel.hasError
                ? _bodyView(_tabController, context)
                : const Text("Observation subject not found"),
      ),
    );
  }

  Widget _bodyView(TabController _tabController, BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: [
        _SubjectDetail(),
        ObservationSubjectMonitoringView(
            definition: definition, subject: subject),
      ],
    );
  }
}

class _SubjectDetail extends HookViewModelWidget<ObservationSubjectViewModel> {
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectViewModel viewModel) {
    var subject = viewModel.data!;

    return LayoutBuilder(
      key: const PageStorageKey('subject-detail-storage-key'),
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              _title(context, subject),
              _identity(subject),
              _description(context, subject),
              _data(context, subject, viewModel.definition),
              ReportImagesCarousel(subject.images),
              const SizedBox(height: 8),
              _Map(),
            ],
          ),
        ),
      ),
    );
  }

  _title(BuildContext context, ObservationSubjectRecord subject) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            subject.title.isNotEmpty ? subject.title : "No title",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 20.sp,
                ),
          ),
        ],
      ),
    );
  }

  _identity(ObservationSubjectRecord subject) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: appTheme.tag1,
        ),
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Text(
          subject.identity.isNotEmpty ? subject.identity : "No identity",
          style: TextStyle(
            color: appTheme.bg1,
            fontSize: 10.sp,
          ),
        ),
      ),
    );
  }

  _description(BuildContext context, ObservationSubjectRecord subject) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 10),
      child: Text(
        subject.description.isEmpty ? "No description" : subject.description,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }

  _data(BuildContext context, ObservationSubjectRecord subject,
      ObservationDefinition definition) {
    var dataTable = Table(
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
        },
        children: subject.formData!.entries.map((entry) {
          return entry.key.contains("__value")
              ? const TableRow(children: [SizedBox.shrink(), SizedBox.shrink()])
              : TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: appTheme.secondary,
                        width: 1,
                      ),
                    ),
                  ),
                  children: [
                    TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(entry.key),
                        )),
                    TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(entry.value.toString()),
                        )),
                  ],
                );
        }).toList());

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 10),
      child: subject.formData != null
          ? Stack(
              children: [
                dataTable,
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ObservationSubjectFormView(
                        definition: definition,
                        subject: subject,
                      ),
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.edit_note),
                  ),
                ),
              ],
            )
          : const Center(
              child: Text("No data"),
            ),
    );
  }
}

class _Map extends HookViewModelWidget<ObservationSubjectViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectViewModel viewModel) {
    final latlng = viewModel.latlng;

    final Completer<GoogleMapController> _controller = Completer();
    var markers = <Marker>{};

    if (latlng != null) {
      markers.add(Marker(
        markerId: const MarkerId('center'),
        position: LatLng(latlng[0], latlng[1]),
      ));
    }

    return Container(
      color: Colors.white,
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: 250,
      ),
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: 250,
        width: MediaQuery.of(context).size.width,
        child: (latlng != null)
            ? GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                    zoom: 12, target: LatLng(latlng[0], latlng[1])),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                scrollGesturesEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: markers,
              )
            : Text("No gps location provided",
                style: TextStyle(fontSize: 14.sp)),
      ),
    );
  }
}
