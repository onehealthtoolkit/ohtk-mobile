import 'package:dio/dio.dart';
import 'package:gql_dio_link/gql_dio_link.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:podd_app/services/gql_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

const languageKey = "language";

class LoginViewModel extends BaseViewModel {
  IAuthService authService = locator<IAuthService>();
  ConfigService configService = locator<ConfigService>();
  GqlService gqlService = locator<GqlService>();

  final _dio = Dio();
  List<Map<String, String>> serverOptions = [
    {"label": "-- Default --", "domain": ""}
  ];

  String subDomain = "";
  String language = "";
  String? username;
  String? password;

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
    subDomain = value;
    await gqlService.setBackendSubDomain(value);
  }

  changeLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(languageKey, value);
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
    } on DioLinkServerException {
      setErrorForObject("general", "Server Error");
    } on DioLinkUnkownException {
      setErrorForObject("general", "Connection refused");
    }

    setBusy(false);
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
}
