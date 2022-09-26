import 'package:podd_app/locator.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:podd_app/services/api/profile_api.dart';
import 'package:podd_app/services/auth_service.dart';

abstract class IProfileService {
  Future<ProfileResult> updateProfile({
    required String firstName,
    required String lastName,
    String? telephone,
  });
  Future<ProfileResult> changePassword(String newPassword);
}

class ProfileService extends IProfileService {
  final ProfileApi _profiledApi = locator<ProfileApi>();
  final IAuthService _authService = locator<IAuthService>();

  @override
  Future<ProfileResult> updateProfile({
    required String firstName,
    required String lastName,
    String? telephone,
  }) async {
    var result = await _profiledApi.updateProfile(
      firstName: firstName,
      lastName: lastName,
      telephone: telephone,
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
