import 'package:podd_app/locator.dart';
import 'package:podd_app/models/inviation_code_result.dart';
import 'package:podd_app/models/register_result.dart';
import 'package:podd_app/services/register_service.dart';
import 'package:stacked/stacked.dart';

enum RegisterState { invitation, detail }

class RegisterViewModel extends BaseViewModel {
  IRegisterService registerService = locator<IRegisterService>();

  RegisterState state = RegisterState.invitation;

  String? invitationCode;
  String? authorityName;

  String? username;
  String? firstName;
  String? lastName;
  String? phone;
  String? email;

  setInvitationCode(value) {
    invitationCode = value;
  }

  checkInvitationCode() async {
    setBusy(true);
    if (invitationCode == null || invitationCode!.isEmpty) {
      setErrorForObject("invitationCode", "Invitation code is required");
      setBusy(false);
      return;
    }

    var result = await registerService.checkInvitationCode(invitationCode!);
    if (result is InvitationCodeSuccess) {
      state = RegisterState.detail;
      authorityName = result.authorityName;
      notifyListeners();
    } else if (result is InvitationCodeFailure) {
      setErrorForObject("invitationCode", result.messages.join(','));
    }

    setBusy(false);
  }

  _clearErrorForKey(String key) {
    if (hasErrorForKey(key)) {
      setErrorForObject(key, null);
    }
  }

  void setUsername(String value) {
    username = value;
    _clearErrorForKey('username');
  }

  void setFirstName(String value) {
    firstName = value;
    _clearErrorForKey('firstName');
  }

  void setLastName(String value) {
    lastName = value;
    _clearErrorForKey('lastName');
  }

  void setEmail(String value) {
    email = value;
    _clearErrorForKey('email');
  }

  void setPhone(String value) {
    phone = value;
    _clearErrorForKey('phone');
  }

  Future<RegisterResult> register() async {
    setBusy(true);
    var isValidData = true;
    if (username == null || username!.isEmpty) {
      setErrorForObject("username", "Username is required");
      isValidData = false;
    }
    if (firstName == null || firstName!.isEmpty) {
      setErrorForObject("firstName", "First name is required");
      isValidData = false;
    }
    if (lastName == null || lastName!.isEmpty) {
      setErrorForObject("lastName", "Last name is required");
      isValidData = false;
    }
    if (email == null || email!.isEmpty) {
      setErrorForObject("email", "Email is required");
      isValidData = false;
    }
    if (phone == null || phone!.isEmpty) {
      setErrorForObject("phone", "Phone number is required");
      isValidData = false;
    }

    if (!isValidData) {
      setBusy(false);
      return RegisterInvalidData();
    }

    var result = await registerService.registerUser(
        invitationCode: invitationCode!,
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone);

    setBusy(false);
    return result;
  }
}
