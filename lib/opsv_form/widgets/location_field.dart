part of 'widgets.dart';

const Color _locationEmptyBg = Color(0xFFEEF2F4);
const double _locationMapHeight = 170;
const double _locationEmptyHeight = 160;

class FormLocationField extends StatefulWidget {
  final opsv.LocationField field;

  const FormLocationField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormLocationField> createState() => _FormLocationFieldState();
}

class _FormLocationFieldState extends State<FormLocationField> {
  final Completer<GoogleMapController> _controller = Completer();
  final _logger = locator<Logger>();

  Future<void> getCurrentPosition({required bool timeoutRetry}) async {
    widget.field.clearError();
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 7),
        ),
      );
      widget.field.value = "${position.longitude},${position.latitude}";
    } on TimeoutException catch (e) {
      _logger.e(e);
      if (timeoutRetry) {
        getCurrentPosition(timeoutRetry: false);
      } else {
        widget.field.markError(
            "Timeout! No location is received within specific duration");
      }
    } on LocationServiceDisabledException catch (e) {
      _logger.e(e);
      if (mounted) {
        _showLocationServiceAlert(context);
      }
    } on PermissionDeniedException catch (e) {
      _logger.e(e);
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        widget.field
            .markError("You have denied a permission to access location");
      } else {
        getCurrentPosition(timeoutRetry: timeoutRetry);
      }
    }
  }

  void _showLocationServiceAlert(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(localize.locationServiceIsDisabled),
        contentTextStyle: const TextStyle(
          fontFamily: incidentsFontFamily,
          fontFamilyFallback: incidentsFontFamilyFallback,
          fontSize: 14,
          color: incidentsInk,
          height: 1.4,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: _ohtkFormBrand,
            ),
            child: Text(
              localize.ok,
              style: const TextStyle(
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
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
      final lat = widget.field.latitude;
      final lng = widget.field.longitude;
      final hasValue = lat != null && lng != null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!hasValue) _LocationEmptyPanel(onUseCurrent: _onUseCurrent),
          if (hasValue) ...[
            _LocationMapPreview(
              latitude: lat,
              longitude: lng,
              controller: _controller,
              onCameraMove: (CameraPosition pos) {
                widget.field.value =
                    "${pos.target.longitude},${pos.target.latitude}";
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _onUseCurrent,
                style: TextButton.styleFrom(
                  foregroundColor: _ohtkFormBrand,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.my_location, size: 16),
                label: Text(
                  AppLocalizations.of(context)!.fieldUseCurrentLocation,
                  style: const TextStyle(
                    fontFamily: incidentsFontFamily,
                    fontFamilyFallback: incidentsFontFamilyFallback,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  void _onUseCurrent() => getCurrentPosition(timeoutRetry: true);
}

class _LocationEmptyPanel extends StatelessWidget {
  final VoidCallback onUseCurrent;
  const _LocationEmptyPanel({required this.onUseCurrent});

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return Container(
      height: _locationEmptyHeight,
      decoration: BoxDecoration(
        color: _locationEmptyBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: incidentsHair, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 36,
            color: incidentsMuted,
          ),
          const SizedBox(height: 6),
          Text(
            localize.fieldUndefinedLocation,
            style: const TextStyle(
              fontFamily: incidentsFontFamily,
              fontFamilyFallback: incidentsFontFamilyFallback,
              fontSize: 13,
              color: incidentsMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onUseCurrent,
            style: TextButton.styleFrom(
              backgroundColor: _ohtkFormBrand,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.my_location, size: 14),
            label: Text(
              localize.fieldUseCurrentLocation,
              style: const TextStyle(
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationMapPreview extends StatelessWidget {
  final double latitude;
  final double longitude;
  final Completer<GoogleMapController> controller;
  final ValueChanged<CameraPosition> onCameraMove;

  const _LocationMapPreview({
    required this.latitude,
    required this.longitude,
    required this.controller,
    required this.onCameraMove,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: _locationMapHeight,
        decoration: BoxDecoration(
          border: Border.all(color: incidentsHair, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  zoom: 12,
                  target: LatLng(latitude, longitude),
                ),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                scrollGesturesEnabled: true,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                onCameraMove: onCameraMove,
                onMapCreated: (c) {
                  controller.complete(c);
                  Future.delayed(const Duration(seconds: 1), () {
                    c.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(latitude, longitude),
                          zoom: 17.0,
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Icon(
                  Icons.location_on,
                  size: 36,
                  color: _ohtkFormBrand,
                ),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: _LatLngChip(latitude: latitude, longitude: longitude),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatLngChip extends StatelessWidget {
  final double latitude;
  final double longitude;
  const _LatLngChip({required this.latitude, required this.longitude});

  String _fmt(double v, {required String pos, required String neg}) {
    final hemi = v >= 0 ? pos : neg;
    return '${v.abs().toStringAsFixed(4)}° $hemi';
  }

  @override
  Widget build(BuildContext context) {
    final text =
        '${_fmt(latitude, pos: 'N', neg: 'S')}, ${_fmt(longitude, pos: 'E', neg: 'W')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: incidentsHair, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: incidentsFontFamily,
          fontFamilyFallback: incidentsFontFamilyFallback,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: incidentsInk,
          fontFeatures: [FontFeature.tabularFigures()],
          height: 1.2,
        ),
      ),
    );
  }
}
