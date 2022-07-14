import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/form/form_data/form_values/location_form_value.dart';
import 'package:podd_app/form/widgets/validation_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:podd_app/form/form_data/form_data.dart';

import 'package:podd_app/form/ui_definition/form_ui_definition.dart';
import 'package:podd_app/locator.dart';

class FormLocationField extends StatefulWidget {
  final LocationFieldUIDefinition fieldDefinition;

  const FormLocationField(this.fieldDefinition, {Key? key}) : super(key: key);

  @override
  State<FormLocationField> createState() => _FormLocationFieldState();
}

class _FormLocationFieldState extends State<FormLocationField> {
  final Completer<GoogleMapController> _controller = Completer();
  final _logger = locator<Logger>();

  @override
  Widget build(BuildContext context) {
    var formData = Provider.of<FormData>(context);
    var formValue =
        formData.getFormValue(widget.fieldDefinition.name) as LocationFormValue;

    return Observer(builder: (BuildContext context) {
      var latitude = formValue.latitude;
      var longitude = formValue.longitude;

      var markers = <Marker>{};
      if (latitude != null && longitude != null) {
        markers.add(Marker(
          markerId: const MarkerId('center'),
          position: LatLng(latitude, longitude),
        ));
      }

      return ValidationWrapper(
        formValue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () async {
                bool serviceEnabled =
                    await Geolocator.isLocationServiceEnabled();
                if (serviceEnabled) {
                  LocationPermission permission =
                      await Geolocator.requestPermission();
                  if (permission == LocationPermission.denied) {
                    _logger.e("permission denied");
                  } else {
                    var _position = await Geolocator.getCurrentPosition(
                        desiredAccuracy: LocationAccuracy.medium);
                    formValue.value =
                        "${_position.longitude},${_position.latitude}";
                  }
                } else {
                  _logger.e("location is disable");
                }
              },
              child: const Text("current location"),
            ),
            if (latitude != null && longitude != null)
              SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition: CameraPosition(
                      zoom: 12, target: LatLng(latitude, longitude)),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  scrollGesturesEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: markers,
                ),
              ),
          ],
        ),
      );
    });
  }
}
