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
  final _locationService = const DeviceLocationService();
  bool _locating = false;

  void _setLocating(bool value) {
    if (!mounted || _locating == value) return;
    setState(() => _locating = value);
  }

  /// Google-aligned, user-initiated foreground location.
  Future<void> _useCurrentLocation() async {
    if (_locating) return;
    _setLocating(true);
    widget.field.clearError();
    try {
      final result = await _locationService.obtainCurrentPosition(context);
      if (!mounted) return;
      if (result.isSuccess) {
        final p = result.position!;
        widget.field.value = "${p.longitude},${p.latitude}";
        
        // Animate camera to the new position
        if (_controller.isCompleted) {
          final controller = await _controller.future;
          await controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(p.latitude, p.longitude),
                zoom: 17.0,
              ),
            ),
          );
        }
      } else if (result.failure != null &&
          result.failure != DeviceLocationFailure.rationaleDeclined &&
          result.failure != DeviceLocationFailure.serviceDisabled &&
          result.failure !=
              DeviceLocationFailure.permissionDeniedForever) {
        // Dialogs already covered service / permanent deny; surface the rest.
        final l10n = AppLocalizations.of(context)!;
        widget.field
            .markError(_locationService.messageFor(result.failure!, l10n));
      }
    } catch (e, st) {
      _logger.e('useCurrentLocation failed: $e\n$st');
      if (mounted) {
        widget.field.markError(
            AppLocalizations.of(context)!.locationCouldNotGet);
      }
    } finally {
      _setLocating(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    return Observer(builder: (BuildContext context) {
      final lat = widget.field.latitude;
      final lng = widget.field.longitude;
      final hasValue = lat != null && lng != null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!hasValue)
            _LocationEmptyPanel(
              locating: _locating,
              locatingLabel: localize.fieldGettingLocation,
              onUseCurrent: _locating ? null : _useCurrentLocation,
            ),
          if (hasValue) ...[
            Stack(
              children: [
                _LocationMapPreview(
                  latitude: lat,
                  longitude: lng,
                  controller: _controller,
                  onCameraMove: (CameraPosition pos) {
                    if (_locating) return;
                    widget.field.value =
                        "${pos.target.longitude},${pos.target.latitude}";
                  },
                ),
                if (_locating)
                  Positioned.fill(
                    child: _LocationBusyOverlay(
                      label: localize.fieldGettingLocation,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _locating ? null : _useCurrentLocation,
                style: TextButton.styleFrom(
                  foregroundColor: _ohtkFormBrand,
                  disabledForegroundColor: incidentsMuted,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: _locating
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _ohtkFormBrand,
                        ),
                      )
                    : const Icon(Icons.my_location, size: 16),
                label: Text(
                  _locating
                      ? localize.fieldGettingLocation
                      : localize.fieldUseCurrentLocation,
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
}

class _LocationEmptyPanel extends StatelessWidget {
  final bool locating;
  final String locatingLabel;
  final VoidCallback? onUseCurrent;

  const _LocationEmptyPanel({
    required this.locating,
    required this.locatingLabel,
    required this.onUseCurrent,
  });

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
          if (locating) ...[
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _ohtkFormBrand,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              locatingLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 13,
                color: incidentsInk,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              localize.fieldGettingLocationHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: incidentsFontFamily,
                fontFamilyFallback: incidentsFontFamilyFallback,
                fontSize: 12,
                color: incidentsMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
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
                disabledBackgroundColor: incidentsHair,
                disabledForegroundColor: incidentsMuted,
                shape: const StadiumBorder(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
        ],
      ),
    );
  }
}

class _LocationBusyOverlay extends StatelessWidget {
  final String label;
  const _LocationBusyOverlay({required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: ColoredBox(
        color: Colors.white.withValues(alpha: 0.72),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _ohtkFormBrand,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: incidentsFontFamily,
                  fontFamilyFallback: incidentsFontFamilyFallback,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: incidentsInk,
                ),
              ),
            ],
          ),
        ),
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
