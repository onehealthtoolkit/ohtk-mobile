import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/forgot_password_result.dart';
import 'package:podd_app/services/secure_storage_service.dart';

import 'api/forgot_password_api.dart';

abstract class IForgotPasswordService {
  Future<ForgotPasswordResult> resetPasswordRequest(String email);
}

class ForgotPasswordService extends IForgotPasswordService {
  final ForgotPasswordApi _forgotPasswordApi = locator<ForgotPasswordApi>();

  final ISecureStorageService secureStorageService =
      locator<ISecureStorageService>();

  final logger = locator<Logger>();

  @override
  Future<ForgotPasswordResult> resetPasswordRequest(String email) {
    return _forgotPasswordApi.resetPasswordRequest(email);
  }
}
