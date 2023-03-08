import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/ui/observation/form/subject_form_view.dart';
import 'package:podd_app/ui/observation/subject/observation_subject_monitoring_view.dart';
import 'package:podd_app/ui/observation/subject/observation_subject_view_model.dart';
import 'package:podd_app/ui/report/full_screen_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationSubjectView extends HookWidget {
  final ObservationDefinition definition;
  final ObservationSubjectRecord subject;

  const ObservationSubjectView({
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
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                  child: Text(AppLocalizations.of(context)!
                      .observationSubjectDetailTabLabel)),
              Tab(
                  child: Text(AppLocalizations.of(context)!
                      .observationSubjectMonitoringTabLabel)),
            ],
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child: viewModel.isBusy
                ? const Center(child: OhtkProgressIndicator(size: 100))
                : !viewModel.hasError
                    ? _bodyView(_tabController, context)
                    : const Text("Observation subject not found")),
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

class _Images extends HookViewModelWidget<ObservationSubjectViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectViewModel viewModel) {
    final images = viewModel.data!.images;

    var imageWidgets = images?.map((image) => Container(
          margin: const EdgeInsets.all(0),
          child: FullScreenWidget(
            fullscreenChild: CachedNetworkImage(
              imageUrl: image.imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            child: CachedNetworkImage(
              imageUrl: image.thumbnailPath,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ));

    return Container(
      color: Colors.white,
      constraints:
          const BoxConstraints(minWidth: double.infinity, minHeight: 150),
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: 200,
        child: (images != null && images.isNotEmpty)
            ? CarouselSlider(
                items: imageWidgets?.toList() ?? [],
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  aspectRatio: 1,
                  viewportFraction: 0.8,
                  autoPlay: true,
                  disableCenter: true,
                  enableInfiniteScroll: false,
                ),
              )
            : const Text("No images uploaded"),
      ),
    );
  }
}

class _SubjectDetail extends HookViewModelWidget<ObservationSubjectViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectViewModel viewModel) {
    var subject = viewModel.data!;

    return LayoutBuilder(
      key: const PageStorageKey('subject-detail-storage-key'),
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  subject.title.isNotEmpty ? subject.title : "no title",
                  textScaleFactor: 1.5,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subject.identity.isNotEmpty
                      ? subject.identity
                      : "no identity",
                  textScaleFactor: .75,
                ),
                const SizedBox(height: 16),
                Container(
                  color: Colors.white,
                  constraints: const BoxConstraints(
                      minHeight: 80, minWidth: double.infinity),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(subject.description.isNotEmpty
                        ? subject.description
                        : "no description"),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ObservationSubjectFormView(
                        definition: viewModel.definition,
                        subject: subject,
                      ),
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.edit_note),
                  ),
                ),
                _data(subject),
                const SizedBox(height: 8),
                _Images(),
                const SizedBox(height: 8),
                _Map(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _data(ObservationSubjectRecord subject) {
    var dataTable = Table(
        border: TableBorder.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
        },
        children: subject.formData!.entries.map((entry) {
          return entry.key.contains("__value")
              ? const TableRow(children: [SizedBox.shrink(), SizedBox.shrink()])
              : TableRow(
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

    return subject.formData != null ? dataTable : const Text("no data");
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
