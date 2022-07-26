import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:podd_app/ui/report/incident_report_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:intl/intl.dart';

class IncidentReportView extends StatelessWidget {
  final String id;
  const IncidentReportView({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<IncidentReportViewModel>.reactive(
      viewModelBuilder: () => IncidentReportViewModel(id),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Report detail"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: viewModel.isBusy
              ? const CircularProgressIndicator()
              : !viewModel.hasError
                  ? _IncidentDetail()
                  : const Text("Incident report not found"),
        ),
      ),
    );
  }
}

class _IncidentDetail extends HookViewModelWidget<IncidentReportViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, IncidentReportViewModel viewModel) {
    final incident = viewModel.data!;
    var formatter = DateFormat("dd/MM/yyyy HH:mm");

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(incident.reportTypeName,
            textScaleFactor: 1.25,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(
          formatter.format(incident.createdAt),
          textScaleFactor: .75,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(incident.description.isEmpty
              ? "no description"
              : incident.description),
        ),
        _Images(),
        _Map(),
      ],
    );
  }
}

class _Images extends HookViewModelWidget<IncidentReportViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, IncidentReportViewModel viewModel) {
    final images = viewModel.data!.images;
    var _pageController = usePageController(viewportFraction: .5);

    if (images == null || images.isEmpty) {
      return Text("No images uploaded");
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 150,
        child: PageView.builder(
          itemCount: images.length,
          pageSnapping: true,
          controller: _pageController,
          itemBuilder: (context, pagePosition) {
            return Container(
              margin: EdgeInsets.all(10),
              child: CachedNetworkImage(
                imageUrl:
                    viewModel.resolveImagePath(images[pagePosition].filePath),
                placeholder: (context, url) => CircularProgressIndicator(),
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Map extends HookViewModelWidget<IncidentReportViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, IncidentReportViewModel viewModel) {
    final latlng = viewModel.latlng;
    if (latlng == null) {
      return Text("No gps location provided");
    }

    final Completer<GoogleMapController> _controller = Completer();
    var markers = <Marker>{};
    markers.add(Marker(
      markerId: const MarkerId('center'),
      position: LatLng(latlng[0], latlng[1]),
    ));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 250,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition:
              CameraPosition(zoom: 12, target: LatLng(latlng[0], latlng[1])),
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          scrollGesturesEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: markers,
        ),
      ),
    );
  }
}
