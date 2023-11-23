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
  final AppTheme appTheme = locator<AppTheme>();

  getCurrentPosition({required bool timeoutRetry}) async {
    widget.field.clearError();
    try {
      var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
        timeLimit: const Duration(seconds: 7),
      );
      widget.field.value = "${position.longitude},${position.latitude}";
    } on TimeoutException catch (e) {
      _logger.e(e);
      if (timeoutRetry) {
        getCurrentPosition(timeoutRetry: false);
      } else {
        // error message
        widget.field.markError(
            "Timeout! No location is received within specific duration");
      }
    } on LocationServiceDisabledException catch (e) {
      _logger.e(e);
      showLocationServiceAlert(context);
    } on PermissionDeniedException catch (e) {
      _logger.e(e);
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // error message
        widget.field
            .markError("You have denied a permission to access location");
      } else {
        getCurrentPosition(timeoutRetry: timeoutRetry);
      }
    }
  }

  showLocationServiceAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(AppLocalizations.of(context)!.locationServiceIsDisabled),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          FlatButton.primary(
            child: Text(AppLocalizations.of(context)!.ok),
            onPressed: () {
              Navigator.pop(context);
              AppSettings.openAppSettings(type: AppSettingsType.location);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      var latitude = widget.field.latitude;
      var longitude = widget.field.longitude;
      var markers = <Marker>{};

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
            if (latitude == null || longitude == null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(appTheme.borderRadius),
                  color: appTheme.sub4,
                ),
                child: SizedBox(
                  height: 300.w,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on_sharp,
                          size: 60,
                          color: Color(0xFFD9D9D9),
                        ),
                        Text(AppLocalizations.of(context)!
                            .fieldUndefinedLocation),
                        FlatButton.primary(
                          onPressed: () {
                            getCurrentPosition(timeoutRetry: true);
                          },
                          child: Text(
                            AppLocalizations.of(context)!
                                .fieldUseCurrentLocation,
                            style: TextStyle(
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (latitude != null && longitude != null)
              SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.hybrid,
                      initialCameraPosition: CameraPosition(
                          zoom: 12, target: LatLng(latitude, longitude)),
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      scrollGesturesEnabled: true,
                      gestureRecognizers: <Factory<
                          OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                      onCameraMove: (CameraPosition position) {
                        widget.field.value =
                            "${position.target.longitude},${position.target.latitude}";
                      },
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                        Future.delayed(const Duration(seconds: 1), () {
                          controller.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(latitude, longitude),
                                zoom: 17.0,
                              ),
                            ),
                          );
                        });
                      },
                      markers: markers,
                    ),
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/images/map_pin_icon.png",
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}
