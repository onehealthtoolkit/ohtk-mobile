import 'package:podd_app/locator.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
  IAuthService authService = locator<IAuthService>();

  UserProfile? get userProfile => authService.userProfile;

  logout() {
    authService.logout();
  }

  String? get username => userProfile?.username;
}
