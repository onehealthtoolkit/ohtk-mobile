import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/inviation_code_result.dart';
import 'package:podd_app/models/register_result.dart';
import 'package:podd_app/services/api/register_api.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/secure_storage_service.dart';

abstract class IRegisterService {
  Future<InvitationCodeResult> checkInvitationCode(String invitationCode);

  Future<RegisterResult> registerUser(
      {required String invitationCode,
      String? username,
      String? firstName,
      String? lastName,
      String? email,
      String? phone});
}

class RegisterService extends IRegisterService {
  final RegisterApi _registerApi = locator<RegisterApi>();
  final IAuthService _authService = locator<IAuthService>();

  final ISecureStorageService secureStorageService =
      locator<ISecureStorageService>();

  final logger = locator<Logger>();

  @override
  Future<InvitationCodeResult> checkInvitationCode(String invitationCode) {
    return _registerApi.checkInvitationCode(invitationCode);
  }

  @override
  Future<RegisterResult> registerUser(
      {required String invitationCode,
      String? username,
      String? firstName,
      String? lastName,
      String? email,
      String? phone}) async {
    var result = await _registerApi.registerUser(
        invitationCode: invitationCode,
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone);

    if (result is RegisterSuccess) {
      _authService.saveTokenAndFetchProfile(result.loginSuccess);
    }
    return result;
  }
}
