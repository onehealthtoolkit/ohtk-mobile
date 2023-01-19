import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/ui/observation/subject/observation_subject_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

import 'observation_subject_map_view_model.dart';

class ObservationSubjectMapView extends StatelessWidget {
  final ObservationDefinition definition;

  const ObservationSubjectMapView({
    Key? key,
    required this.definition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.nonReactive(
      viewModelBuilder: () => ObservationSubjectMapViewModel(definition),
      builder: (context, model, child) => _SubjectMap(),
    );
  }
}

class _SubjectMap extends HookViewModelWidget<ObservationSubjectMapViewModel> {
  final GlobalKey _mapKey = GlobalKey();

  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectMapViewModel viewModel) {
    if (viewModel.isBusy || viewModel.currentPosition == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    var markers = viewModel.subjects
        .where((subject) => subject.gpsLocation != null)
        .map((subject) {
      var latlng =
          subject.gpsLocation!.split(',').map((e) => double.parse(e)).toList();
      return Marker(
        markerId: MarkerId(subject.id.toString()),
        position: LatLng(latlng[1], latlng[0]),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ObservationSubjectView(
                definition: viewModel.definition,
                subject: subject,
              ),
            ),
          );
        },
      );
    });

    onCameraIdle() {
      viewModel.controller?.getVisibleRegion().then((region) {
        // latitude = y axis
        // longitude = x axis

        // convert southwest and northeast to topLeft and bottomRight boundary
        double topLeftX = region.southwest.longitude;
        double topLeftY = region.northeast.latitude;

        double bottomRightX = region.northeast.longitude;
        double bottomRightY = region.southwest.latitude;

        viewModel.fetch(topLeftX, topLeftY, bottomRightX, bottomRightY);
      });
    }

    return Container(
      color: Colors.white,
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: double.infinity,
      ),
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GoogleMap(
            key: _mapKey,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
                zoom: 14,
                target: LatLng(viewModel.currentPosition!.latitude,
                    viewModel.currentPosition!.longitude)),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            scrollGesturesEnabled: true,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            markers: markers.toSet(),
            onMapCreated: (GoogleMapController controller) {
              viewModel.controller = controller;
            },
            onCameraIdle: onCameraIdle,
          )),
    );
  }
}
