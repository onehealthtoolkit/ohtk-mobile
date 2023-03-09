import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podd_app/components/back_appbar_action.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

import 'change_password_view_model.dart';

class ChangePasswordView extends StatelessWidget {
  static const String route = '/register';

  const ChangePasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChangePasswordViewModel>.reactive(
      viewModelBuilder: () => ChangePasswordViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.changePasswordTitle),
          leading: const BackAppBarAction(),
        ),
        body: _ChangePasswordForm(),
      ),
    );
  }
}

class _ChangePasswordForm extends HookViewModelWidget<ChangePasswordViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ChangePasswordViewModel viewModel) {
    return Column(children: [
      if (viewModel.hasErrorForKey("generalChangePassword"))
        Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          color: Colors.red,
          child: Text(
            viewModel.error("generalChangePassword"),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              textInputAction: TextInputAction.next,
              obscureText: viewModel.obscurePassword,
              onChanged: viewModel.setPassword,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.newPasswordLabel,
                errorText: viewModel.error("password"),
                suffixIcon: IconButton(
                  onPressed: () {
                    viewModel.setObscurePassword(!viewModel.obscurePassword);
                  },
                  hoverColor: Colors.transparent,
                  icon: viewModel.obscurePassword
                      ? const Icon(Icons.visibility)
                      : const Icon(Icons.visibility_off),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              textInputAction: TextInputAction.next,
              obscureText: viewModel.obscureConfirmPassword,
              onChanged: viewModel.setConfirmPassword,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.confirmPasswordLabel,
                errorText: viewModel.error("confirmPassword"),
                suffixIcon: IconButton(
                  onPressed: () {
                    viewModel.setObscureConfirmPassword(
                        !viewModel.obscureConfirmPassword);
                  },
                  hoverColor: Colors.transparent,
                  icon: viewModel.obscureConfirmPassword
                      ? const Icon(Icons.visibility)
                      : const Icon(Icons.visibility_off),
                ),
              ),
            ),
            const SizedBox(height: 30),
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
      )
    ]);
  }
}
