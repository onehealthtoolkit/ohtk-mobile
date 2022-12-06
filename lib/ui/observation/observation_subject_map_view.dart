import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:podd_app/ui/observation/observation_subject_list_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationSubjectMapView extends StatelessWidget {
  final String definitionId;

  const ObservationSubjectMapView({
    Key? key,
    required this.definitionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.nonReactive(
      viewModelBuilder: () => ObservationSubjectListViewModel(definitionId),
      builder: (context, model, child) => _SubjectMap(),
    );
  }
}

class _SubjectMap extends HookViewModelWidget<ObservationSubjectListViewModel> {
  final latlng = [36.54995, -121.88107];

  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectListViewModel viewModel) {
    final Completer<GoogleMapController> _controller = Completer();
    var markers = <Marker>{};

    markers.add(Marker(
      markerId: const MarkerId('center'),
      position: LatLng(latlng[0], latlng[1]),
    ));

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
            mapType: MapType.normal,
            initialCameraPosition:
                CameraPosition(zoom: 12, target: LatLng(latlng[0], latlng[1])),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            scrollGesturesEnabled: true,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: markers,
          )),
    );
  }
}
