import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:podd_app/form/form_data/form_data.dart';
import 'package:podd_app/form/form_store.dart';

import 'package:podd_app/form/ui_definition/form_ui_definition.dart';
import 'package:podd_app/form/widgets/validation.dart';
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
  UnRegisterValidationCallback? unRegisterValidationCallback;
  bool valid = true;
  String errorMessage = '';

  ValidationState validate() {
    var isValid = true;
    var msg = '';

    var formData = Provider.of<FormData>(context, listen: false);
    var formValue =
        formData.getFormValue(widget.fieldDefinition.name) as StringFormValue;

    if (formValue.value == null) {
      isValid = false;
      msg = '${widget.fieldDefinition.name} is required';
    }

    if (mounted) {
      setState(() {
        valid = isValid;
        errorMessage = msg;
      });
    }
    return ValidationState(isValid, msg);
  }

  @override
  void dispose() {
    if (unRegisterValidationCallback != null) {
      unRegisterValidationCallback!();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var formStore = Provider.of<FormStore>(context);
    if (widget.fieldDefinition.required == true) {
      unRegisterValidationCallback = formStore.registerValidation(validate);
    }

    var formData = Provider.of<FormData>(context);
    var formValue =
        formData.getFormValue(widget.fieldDefinition.name) as StringFormValue;

    return Observer(builder: (BuildContext context) {
      double? latitude, longitude;

      var latLongStr = formValue.value;
      if (latLongStr != null) {
        var latLongAry = latLongStr.split(',');
        var latValue = double.parse(latLongAry[0]);
        var longValue = double.parse(latLongAry[1]);
        if (latValue != latitude) {
          latitude = latValue;
        }
        if (longValue != longitude) {
          longitude = longValue;
        }
      }

      var markers = <Marker>{};
      if (latitude != null && longitude != null) {
        markers.add(Marker(
          markerId: const MarkerId('center'),
          position: LatLng(latitude, longitude),
        ));
      }

      return Container(
        decoration: (valid == false)
            ? BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
              )
            : null,
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
                        "${_position.latitude},${_position.longitude}";
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
            if (errorMessage != "") Text(errorMessage),
          ],
        ),
      );
    });
  }
}
