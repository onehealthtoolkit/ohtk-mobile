import 'package:image_picker/image_picker.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/consent_result.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:podd_app/services/api/profile_api.dart';
import 'package:podd_app/services/auth_service.dart';

abstract class IProfileService {
  Future<ProfileResult> updateProfile({
    required String firstName,
    required String lastName,
    String? telephone,
    String? address,
  });

  Future<ProfileResult> changePassword(String newPassword);

  Future<bool> confirmConsent();

  Future<ProfileResult> uploadAvatar(XFile image);

  Future<String> getLoginQrToken(int userId);
}

class ProfileService extends IProfileService {
  final ProfileApi _profileApi = locator<ProfileApi>();
  final IAuthService _authService = locator<IAuthService>();

  @override
  Future<ProfileResult> updateProfile({
    required String firstName,
    required String lastName,
    String? telephone,
    String? address,
  }) async {
    var result = await _profileApi.updateProfile(
      firstName: firstName,
      lastName: lastName,
      telephone: telephone,
      address: address,
    );

    if (result is ProfileSuccess && result.success) {
      await _authService.fetchProfile();
    }
    return result;
  }

  @override
  Future<ProfileResult> changePassword(String newPassword) async {
    var result = await _profileApi.changePassword(newPassword);

    return result;
  }

  @override
  Future<bool> confirmConsent() async {
    var result = await _profileApi.confirmConsent();
    if (result is ConsentSubmitSuccess) {
      _authService.updateConfirmedConsent();
      return true;
    }
    return false;
  }

  @override
  Future<ProfileResult> uploadAvatar(XFile image) async {
    var result = await _profileApi.uploadAvatar(
      image,
    );

    if (result is ProfileUploadSuccess && result.success) {
      if (result.avatarUrl != null) {
        _authService.updateAvatarUrl(result.avatarUrl!);
      }
    }
    return result;
  }

  @override
  Future<String> getLoginQrToken(int userId) async {
    var result = await _profileApi.getLoginQrToken(userId.toString());
    return result;
  }
}
