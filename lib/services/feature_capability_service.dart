import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/services/api/feature_capability_api.dart';
import 'package:stacked/stacked.dart';

abstract class IFeatureCapabilityService with ListenableServiceMixin {
  bool get villageEnabled;

  bool get villageCapabilityKnown;

  Future<void> refresh();

  void reset();
}

class FeatureCapabilityService extends IFeatureCapabilityService {
  final FeatureCapabilityApi _api;
  final Logger _logger;

  final ReactiveValue<bool> _villageEnabled = ReactiveValue<bool>(false);
  final ReactiveValue<bool> _villageCapabilityKnown =
      ReactiveValue<bool>(false);

  FeatureCapabilityService({
    FeatureCapabilityApi? api,
    Logger? logger,
  })  : _api = api ?? locator<FeatureCapabilityApi>(),
        _logger = logger ?? locator<Logger>() {
    listenToReactiveValues([
      _villageEnabled,
      _villageCapabilityKnown,
    ]);
  }

  @override
  bool get villageEnabled => _villageEnabled.value;

  @override
  bool get villageCapabilityKnown => _villageCapabilityKnown.value;

  @override
  Future<void> refresh() async {
    try {
      _villageEnabled.value = await _api.fetchVillageEnabled();
      _villageCapabilityKnown.value = true;
    } catch (e) {
      // Keep last known value; a transport failure is not "disabled".
      _logger.w('Cannot refresh feature capabilities: $e');
    }
  }

  @override
  void reset() {
    _villageEnabled.value = false;
    _villageCapabilityKnown.value = false;
  }
}
