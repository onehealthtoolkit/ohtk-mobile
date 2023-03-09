import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

import 'profile_view.dart';
import 'profile_view_model.dart';

class ChangePasswordView extends StatelessWidget {
  static const String route = '/register';

  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.changePasswordTitle),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _ChangePasswordForm(),
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
                          Navigator.pop(context, true);
                        }
                      },
                child: viewModel.isBusy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Text(AppLocalizations.of(context)!.confirmUpdate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
