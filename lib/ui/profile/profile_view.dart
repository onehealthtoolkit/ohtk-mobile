import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:podd_app/ui/profile/profile_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.nonReactive(
      viewModelBuilder: () => ProfileViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Profile"),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _Info(),
                    const SizedBox(height: 20),
                    _ProfileForm(),
                    const SizedBox(height: 20),
                    _ChangePasswordForm(),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                              primary: Colors.red[600],
                            ),
                            onPressed: () async {
                              await viewModel.logout();
                              Navigator.pop(
                                context,
                              );
                            },
                            child: const Text("Logout"),
                          ),
                        ),
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

class _Info extends HookViewModelWidget<ProfileViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ProfileViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: useTextEditingController(text: viewModel.username),
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Username",
              ),
            ),
            TextField(
              controller:
                  useTextEditingController(text: viewModel.authorityName),
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Authroity Name",
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
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              textInputAction: TextInputAction.next,
              onChanged: viewModel.setFirstName,
              controller: firstName,
              decoration: InputDecoration(
                labelText: "First name",
                errorText: viewModel.error("firstName"),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              textInputAction: TextInputAction.next,
              onChanged: viewModel.setLastName,
              controller: lastName,
              decoration: InputDecoration(
                labelText: "Last name",
                errorText: viewModel.error("lastName"),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              textInputAction: TextInputAction.next,
              onChanged: viewModel.setTelephone,
              controller: telephone,
              decoration: InputDecoration(
                labelText: "Telephone",
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
                          Navigator.pop(context, true);
                        }
                      },
                child: viewModel.isBusy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text("Update Profile"),
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
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              textInputAction: TextInputAction.next,
              obscureText: true,
              onChanged: viewModel.setPassword,
              decoration: InputDecoration(
                labelText: "Password",
                errorText: viewModel.error("password"),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              textInputAction: TextInputAction.next,
              obscureText: true,
              onChanged: viewModel.setConfirmPassword,
              decoration: InputDecoration(
                labelText: "Confirm password",
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
                          Navigator.pop(context, true);
                        }
                      },
                child: viewModel.isBusy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text("Change Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
