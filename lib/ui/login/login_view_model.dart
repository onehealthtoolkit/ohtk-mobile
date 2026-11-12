import 'package:dio/dio.dart';
import 'package:gql_dio_link/gql_dio_link.dart';
import 'package:podd_app/constants.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/submission_problem.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:podd_app/services/feature_capability_service.dart';
import 'package:podd_app/services/gql_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class LoginViewModel extends BaseViewModel {
  IAuthService authService = locator<IAuthService>();
  ConfigService configService = locator<ConfigService>();
  IFeatureCapabilityService featureCapabilityService =
      locator<IFeatureCapabilityService>();
  GqlService gqlService = locator<GqlService>();

  final _dio = Dio();
  List<Map<String, String>> serverOptions = [
    {"label": "-- Please select server --", "domain": ""}
  ];

  String subDomain = "";
  String language = "en";
  String? username;
  String? password;

  bool obscureText = true;

  LoginViewModel() {
    fetchTenantAndLanguage();
  }

  fetchTenantAndLanguage() async {
    setBusyForObject("tenants", true);

    final prefs = await SharedPreferences.getInstance();

    try {
      final resp = await _dio.get(configService.tenantApiEndpoint);
      final tenants =
          (resp.data['tenants'] as List).map<Map<String, String>>((it) {
        return {"label": it['label'], "domain": it['domain']};
      });
      final backendUrl = prefs.getString(gqlService.backendUrlKey);
      if (backendUrl != null) {
        if (tenants.any((it) => it['domain'] == backendUrl)) {
          subDomain = backendUrl;
        }
      }
      serverOptions.addAll(tenants);
      language = prefs.getString(languageKey) ?? "en";
      notifyListeners();
    } catch (e) {
      setErrorForObject("general", "Cannot get tenants data ");
    } finally {
      setBusyForObject("tenants", false);
    }
  }

  changeServer(String value) async {
    try {
      await gqlService.setBackendSubDomain(value);
      subDomain = value;
      await gqlService.renewClient();
      featureCapabilityService.reset();
      if (value.isNotEmpty) await featureCapabilityService.refresh();
      setErrorForObject('general', null);
    } on SubmissionProblem catch (e) {
      setErrorForObject('general', e.message);
    }
    notifyListeners();
  }

  Future<void> changeLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageKey, value);
    language = value;
    notifyListeners();
  }

  authenticate() async {
    setBusy(true);
    bool hasError = false;

    if (username == null || username!.isEmpty) {
      setErrorForObject("username", "Username is required");
      hasError = true;
    }
    if (password == null || password!.isEmpty) {
      setErrorForObject("password", "Password is required");
      hasError = true;
    }

    if (hasError) {
      setBusy(false);
      notifyListeners();
      return;
    }
    try {
      var authResult = await authService.authenticate(username!, password!);
      if (authResult is AuthFailure) {
        setErrorForObject("general", authResult.messages.join("\n"));
      } else {
        clearErrors();
      }
    } on SubmissionProblem catch (e) {
      setErrorForObject("general", e.message);
    } on DioLinkServerException {
      setErrorForObject("general", "Server Error");
    } on DioLinkUnkownException {
      setErrorForObject("general", "Connection refused");
    } catch (_) {
      setErrorForObject("general", "Cannot sign in. Please try again.");
    } finally {
      setBusy(false);
    }
  }

  void setUsername(String value) {
    username = value;
    if (hasErrorForKey('username')) {
      setErrorForObject("username", null);
    }
  }

  void setPassword(String value) {
    password = value;
    if (hasErrorForKey('password')) {
      setErrorForObject("password", null);
    }
  }

  void setObscureText(bool value) {
    obscureText = value;
    notifyListeners();
  }
}
