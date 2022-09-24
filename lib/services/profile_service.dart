import 'package:podd_app/locator.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:podd_app/services/api/profile_api.dart';
import 'package:podd_app/services/auth_service.dart';

abstract class IProfileService {
  Future<ProfileResult> updateProfile(
      {required String id,
      required int authorityId,
      required String email,
      required String firstName,
      required String lastName,
      required String username,
      String? telephone,
      String? role});
  Future<ProfileResult> changePassword(String newPassword);
}

class ProfileService extends IProfileService {
  final ProfileApi _profiledApi = locator<ProfileApi>();
  final IAuthService _authService = locator<IAuthService>();

  @override
  Future<ProfileResult> updateProfile(
      {required String id,
      required int authorityId,
      required String email,
      required String firstName,
      required String lastName,
      required String username,
      String? telephone,
      String? role}) async {
    var result = await _profiledApi.updateProfile(
      id: id,
      authorityId: authorityId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      username: username,
      telephone: telephone,
      role: role,
    );

    if (result is ProfileSuccess && result.success) {
      _authService.fetchProfile();
    }
    return result;
  }

  @override
  Future<ProfileResult> changePassword(String newPassword) async {
    var result = await _profiledApi.changePassword(newPassword);

    return result;
  }
}
