import 'package:gql_dio_link/gql_dio_link.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/gql_service.dart';
import 'package:stacked/stacked.dart';

class QrLoginViewModel extends BaseViewModel {
  final _authService = locator<IAuthService>();
  final _gqlService = locator<GqlService>();

  final _logger = locator<Logger>();
  bool detected = false;

  Future<String?> authenticate(String token) async {
    setBusy(true);
    String? error;

    try {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      var domain = payload['domain'];
      await _gqlService.setBackendSubDomain(domain);
      await _gqlService.renewClient();

      var authResult = await _authService.verifyQrToken(token);
      if (authResult is AuthFailure) {
        _logger.i(authResult.messages.join(','));
        error = "Invalid QR code";
      }
    } on DioLinkServerException {
      error = "Server Error";
    } on DioLinkUnkownException {
      error = "Connection refused";
    } catch (e) {
      error = "Application error";
    }

    // Let everything finished setting up after logged in
    await Future.delayed(const Duration(seconds: 1));
    setBusy(false);

    return error;
  }
}
