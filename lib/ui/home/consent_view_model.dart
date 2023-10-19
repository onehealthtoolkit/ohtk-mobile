import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/services/api/configuration_api.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:podd_app/services/profile_service.dart';
import 'package:stacked/stacked.dart';

const consentErrorKey = 'consent';

class ConsentViewModel extends BaseViewModel {
  Logger logger = locator<Logger>();
  ConfigurationApi configurationApi = locator<ConfigurationApi>();
  ConfigService configService = locator<ConfigService>();
  IProfileService profileService = locator<IProfileService>();

  bool isConsent = false;
  bool consentNotFound = false;
  String consentContent = "";
  String consentAcceptText = "";

  ConsentViewModel() {
    setBusy(true);
    getConsentConfiguration();
  }

  getConsentConfiguration() async {
    // check if we are in offline mode?
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      consentNotFound = true;
      logger.w("No internet connection");
      setBusy(false);
      return;
    }

    final result = await configurationApi.getConfigurations();
    try {
      final config = result.data.firstWhere(
          (element) => element.key == configService.consentConfigurationKey);
      consentContent = config.value;

      final acceptText = result.data.firstWhere(
          (element) => element.key == configService.consentAcceptTextKey);
      consentAcceptText = acceptText.value;
    } catch (_) {
      consentNotFound = true;
      logger.w(
          "${configService.consentConfigurationKey} not found in configurations");
    }
    setBusy(false);
  }

  setConsent(bool? value) {
    isConsent = value ?? false;
    setErrorForObject(consentErrorKey, null);
  }

  Future<bool> confirmConsent() async {
    var success = await profileService.confirmConsent();
    if (!success) {
      setErrorForObject(consentErrorKey, 'Failed to confirm consent');
    }
    return success;
  }
}
