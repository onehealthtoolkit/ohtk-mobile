import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/incident_report_tag.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/ui/report/followup_list_view.dart';
import 'package:podd_app/ui/report/full_screen_view.dart';
import 'package:podd_app/ui/report/incident_report_view_model.dart';
import 'package:podd_app/ui/report/report_comment_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:carousel_slider/carousel_slider.dart';

var formatter = DateFormat("dd/MM/yyyy HH:mm");
var noTimeFormatter = DateFormat("dd/MM/yyyy");

class IncidentReportView extends HookWidget {
  final String id;
  final AppTheme appTheme = locator<AppTheme>();

  IncidentReportView({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TabController _tabController = useTabController(initialLength: 3);

    return ViewModelBuilder<IncidentReportViewModel>.reactive(
      viewModelBuilder: () => IncidentReportViewModel(id),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: appTheme.primary,
                size: 28,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            automaticallyImplyLeading: false,
            shadowColor: Colors.transparent,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: ColoredBox(
                color: appTheme.bg2,
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    _tabItem(AppLocalizations.of(context)!.detailTabLabel),
                    _tabItem(AppLocalizations.of(context)!.commentTabLabel),
                    _tabItem(AppLocalizations.of(context)!.followupTabLabel),
                  ],
                ),
              ),
            ),
            title: Text(AppLocalizations.of(context)!.reportDetailTitle),
          ),
          body: viewModel.isBusy
              ? const Center(child: OhtkProgressIndicator(size: 100))
              : !viewModel.hasError
                  ? _content(_tabController, viewModel)
                  : const Text("Incident report not found"),
        );
      },
    );
  }

  Tab _tabItem(String label) {
    return Tab(
        child: Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(label),
    ));
  }

  Widget _content(
      TabController _tabController, IncidentReportViewModel viewModel) {
    var view = TabBarView(controller: _tabController, children: [
      _IncidentDetail(),
      ReportCommentView(viewModel.data!.threadId!),
      FollowupListView(viewModel.data!.id)
    ]);

    if (viewModel.data!.testFlag) {
      return Stack(
        children: [
          view,
          Align(
            alignment: Alignment.center,
            child: Transform.rotate(
              angle: -math.pi / 4,
              child: const Opacity(
                opacity: 0.4,
                child: Text(
                  'Test Report',
                  textScaleFactor: 4,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          )
        ],
      );
    }
    return view;
  }
}

class _IncidentDetail extends HookViewModelWidget<IncidentReportViewModel> {
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget buildViewModelWidget(
      BuildContext context, IncidentReportViewModel viewModel) {
    final incident = viewModel.data!;

    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              _title(context, incident),
              _tags(incident),
              _description(incident, context),
              _Data(),
              _Images(),
              const SizedBox(height: 8),
              _Map(),
            ],
          ),
        ),
      );
    });
  }

  _title(BuildContext context, IncidentReport incident) {
    return Container(
      height: 45,
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            incident.reportTypeName,
            textScaleFactor: 1.3,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            formatter.format(incident.createdAt.toLocal()),
            textScaleFactor: 1.5,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  _description(IncidentReport incident, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 10),
      child: Text(
        incident.description.isEmpty
            ? "no description"
            : incident.trimWhitespaceDescription,
        style:
            Theme.of(context).textTheme.bodyMedium!.apply(fontSizeFactor: 1.2),
      ),
    );
  }

  _tags(IncidentReport incident) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
        child: Row(
          children: [
            if (incident.caseId != null) IncidentReportCaseTag(),
            if (incident.testFlag) IncidentReportTestTag()
          ],
        ));
  }
}

class _Data extends HookViewModelWidget<IncidentReportViewModel> {
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget buildViewModelWidget(
    BuildContext context,
    IncidentReportViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.authorityLabel ?? "Authority",
                style: TextStyle(color: appTheme.sub2),
                textScaleFactor: 1.5,
              ),
              Text(
                viewModel.data!.authorityName ?? "-",
                textScaleFactor: 1.5,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.incidentDate ?? "Incident Date",
                style: TextStyle(color: appTheme.sub2),
                textScaleFactor: 1.5,
              ),
              Text(
                noTimeFormatter.format(viewModel.data!.incidentDate.toLocal()),
                textScaleFactor: 1.5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Images extends HookViewModelWidget<IncidentReportViewModel> {
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget buildViewModelWidget(
      BuildContext context, IncidentReportViewModel viewModel) {
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
      color: appTheme.bg1,
      constraints:
          const BoxConstraints(minWidth: double.infinity, minHeight: 200),
      child: SizedBox(
        height: 240,
        child: (images != null && images.isNotEmpty)
            ? CarouselSlider(
                items: imageWidgets?.toList() ?? [],
                options: CarouselOptions(
                  height: 240,
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

class _Map extends HookViewModelWidget<IncidentReportViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, IncidentReportViewModel viewModel) {
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
      padding: const EdgeInsets.only(top: 20, bottom: 20),
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
            : const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No gps location provided"),
              ),
      ),
    );
  }
}
