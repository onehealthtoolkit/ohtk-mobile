part of 'widgets.dart';

class FormLocationField extends StatefulWidget {
  final opsv.LocationField field;

  const FormLocationField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormLocationField> createState() => _FormLocationFieldState();
}

class _FormLocationFieldState extends State<FormLocationField> {
  final Completer<GoogleMapController> _controller = Completer();
  final _logger = locator<Logger>();

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      var latitude = widget.field.latitude;
      var longitude = widget.field.longitude;

      var markers = <Marker>{};
      if (latitude != null && longitude != null) {
        markers.add(Marker(
          markerId: const MarkerId('center'),
          position: LatLng(latitude, longitude),
        ));
      }

      return ValidationWrapper(
        widget.field,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.field.label != null && widget.field.label != "")
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  widget.field.label!,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
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
                    widget.field.value =
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
