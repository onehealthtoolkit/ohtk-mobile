import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/back_appbar_action.dart';
import 'package:podd_app/components/incident_report_tag.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/components/report_file_grid_view.dart';
import 'package:podd_app/components/report_image_carousel.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/ui/report/followup_list_view.dart';
import 'package:podd_app/ui/report/incident_report_view_model.dart';
import 'package:podd_app/ui/report/report_comment_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

var formatter = DateFormat("dd/MM/yyyy HH:mm");
var noTimeFormatter = DateFormat("dd/MM/yyyy");

class IncidentReportView extends HookWidget {
  final String id;
  final AppTheme appTheme = locator<AppTheme>();

  IncidentReportView({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<IncidentReportViewModel>.nonReactive(
      viewModelBuilder: () => IncidentReportViewModel(id),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            leading: const BackAppBarAction(),
            elevation: 0,
            title: Text(AppLocalizations.of(context)!.reportDetailTitle),
          ),
          body: _TabView(),
        );
      },
    );
  }
}

class _TabView extends HookViewModelWidget<IncidentReportViewModel> {
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget buildViewModelWidget(
      BuildContext context, IncidentReportViewModel viewModel) {
    final TabController _tabController = useTabController(initialLength: 3);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.w),
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
      body: viewModel.isBusy
          ? const Center(child: OhtkProgressIndicator(size: 100))
          : !viewModel.hasError
              ? _content(_tabController, viewModel)
              : const Text("Incident report not found"),
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
              ReportImagesCarousel(viewModel.data!.images),
              ReportFileGridView(viewModel.data!.files),
              _Map(),
            ],
          ),
        ),
      );
    });
  }

  _title(BuildContext context, IncidentReport incident) {
    return Container(
      height: 45.w,
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            incident.reportTypeName,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 20.sp,
                ),
          ),
          Text(
            formatter.format(incident.createdAt.toLocal()),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w300,
                ),
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
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
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
      padding: const EdgeInsets.fromLTRB(28, 10, 28, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.authorityLabel ?? "Authority",
                style: TextStyle(color: appTheme.sub2, fontSize: 13.sp),
              ),
              Text(
                viewModel.data!.authorityName ?? "-",
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.incidentDate ?? "Incident Date",
                style: TextStyle(color: appTheme.sub2, fontSize: 13.sp),
              ),
              Text(
                noTimeFormatter.format(
                  viewModel.data!.incidentDate.toLocal(),
                ),
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        ],
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
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: 250,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SizedBox(
        height: 250.w,
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
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "No gps location provided",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w300,
                      ),
                ),
              ),
      ),
    );
  }
}
