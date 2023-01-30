import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/main.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:podd_app/ui/profile/profile_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

var decoration = BoxDecoration(
  border: Border.all(color: Colors.grey.shade300),
  borderRadius: BorderRadius.circular(4.0),
  color: Colors.white,
);

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.nonReactive(
      viewModelBuilder: () => ProfileViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(40),
                                primary: Colors.red[600],
                              ),
                              onPressed: () async {
                                await viewModel.logout();
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/', (route) => false);
                              },
                              child: Text(
                                  AppLocalizations.of(context)!.logoutButton),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _Language(),
                          const SizedBox(height: 8),
                          _Info(),
                          const SizedBox(height: 8),
                          _ProfileForm(),
                          const SizedBox(height: 8),
                          _ChangePasswordForm(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}

class _Language extends HookViewModelWidget<ProfileViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ProfileViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      padding: const EdgeInsets.all(18.0),
      decoration: decoration,
      child: DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.laguageLabel,
          ),
          hint: const Text("Language"),
          value: viewModel.language,
          onChanged: (String? value) async {
            await viewModel.changeLanguage(value ?? "en");
            RestartWidget.restartApp(context);
          },
          items: const [
            DropdownMenuItem(child: Text("English"), value: "en"),
            DropdownMenuItem(child: Text("ภาษาไทย"), value: "th"),
            DropdownMenuItem(child: Text("ភាសាខ្មែរ"), value: "km"),
            DropdownMenuItem(child: Text("ພາສາລາວ"), value: "lo"),
          ]),
    );
  }
}

class _Info extends HookViewModelWidget<ProfileViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ProfileViewModel viewModel) {
    var username = useTextEditingController();
    username.text = viewModel.username ?? "";
    var authorityName = useTextEditingController();
    authorityName.text = viewModel.authorityName ?? "";

    return Container(
      margin: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      decoration: decoration,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            TextField(
              controller: username,
              readOnly: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.usernameLabel,
              ),
            ),
            TextField(
              controller: authorityName,
              readOnly: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.authorityNameLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileForm extends HookViewModelWidget<ProfileViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ProfileViewModel viewModel) {
    var firstName = useTextEditingController();
    firstName.text = viewModel.firstName ?? "";
    var lastName = useTextEditingController();
    lastName.text = viewModel.lastName ?? "";
    var telephone = useTextEditingController();
    telephone.text = viewModel.telephone ?? "";

    return Container(
      margin: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      decoration: decoration,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              textInputAction: TextInputAction.next,
              onChanged: viewModel.setFirstName,
              controller: firstName,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.firstNameLabel,
                errorText: viewModel.error("firstName"),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              textInputAction: TextInputAction.next,
              onChanged: viewModel.setLastName,
              controller: lastName,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.lastNameLabel,
                errorText: viewModel.error("lastName"),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              textInputAction: TextInputAction.next,
              onChanged: viewModel.setTelephone,
              controller: telephone,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.telephoneLabel,
                errorText: viewModel.error("telephone"),
              ),
            ),
            const SizedBox(height: 10),
            if (viewModel.hasErrorForKey("general"))
              Text(
                viewModel.error("general"),
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: viewModel.isBusy
                    ? null
                    : () async {
                        var result = await viewModel.updateProfile();
                        if (result is ProfileSuccess && result.success) {
                          var showSuccessMessage = SnackBar(
                            content: Text(AppLocalizations.of(context)
                                    ?.profileUpdateSuccess ??
                                'Profile update success'),
                            backgroundColor: Colors.green,
                          );
                          ScaffoldMessenger.of(context)
                              .showSnackBar(showSuccessMessage);
                        }
                      },
                child: viewModel.isBusy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Text(AppLocalizations.of(context)!.updateProfileButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordForm extends HookViewModelWidget<ProfileViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ProfileViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      decoration: decoration,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              textInputAction: TextInputAction.next,
              obscureText: true,
              onChanged: viewModel.setPassword,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.passwordLabel,
                errorText: viewModel.error("password"),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              textInputAction: TextInputAction.next,
              obscureText: true,
              onChanged: viewModel.setConfirmPassword,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.confirmPasswordLabel,
                errorText: viewModel.error("confirmPassword"),
              ),
            ),
            const SizedBox(height: 10),
            if (viewModel.hasErrorForKey("generalChangePassword"))
              Text(
                viewModel.error("generalChangePassword"),
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: viewModel.isBusy
                    ? null
                    : () async {
                        var result = await viewModel.changePassword();
                        if (result is ProfileSuccess && result.success) {
                          var showSuccessMessage = SnackBar(
                            content: Text(AppLocalizations.of(context)
                                    ?.passwordUpdatedSuccess ??
                                'Your password has been successfully changed!'),
                            backgroundColor: Colors.green,
                          );
                          ScaffoldMessenger.of(context)
                              .showSnackBar(showSuccessMessage);
                        }
                      },
                child: viewModel.isBusy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Text(AppLocalizations.of(context)!.changePasswordButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
