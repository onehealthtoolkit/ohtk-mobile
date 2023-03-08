import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/models/forgot_password_result.dart';
import 'package:podd_app/ui/forgot_password/reset_password_request_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResetPasswordRequestView extends StatelessWidget {
  static const String route = '/register';

  const ResetPasswordRequestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ResetPasswordRequestViewModel>.reactive(
      viewModelBuilder: () => ResetPasswordRequestViewModel(),
      builder: (context, viewModel, child) => WillPopScope(
        onWillPop: () async {
          return _willPop(context);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.forgotPasswordTitle),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _DetailCodeForm(),
          ),
        ),
      ),
    );
  }

  Future<bool> _willPop(BuildContext context) {
    return confirm(context);
  }
}

class _DetailCodeForm
    extends HookViewModelWidget<ResetPasswordRequestViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ResetPasswordRequestViewModel viewModel) {
    var email = useTextEditingController();

    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.forgotPasswordSubTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: email,
            textInputAction: TextInputAction.next,
            onChanged: viewModel.setEmail,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.emailLabel,
              hintText: AppLocalizations.of(context)!.emailHint,
              errorText: viewModel.error("email"),
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
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: viewModel.isBusy
                  ? null
                  : () async {
                      var result = await viewModel.resetPasswordRequest();
                      if (result is ForgotPasswordSuccess) {
                        Navigator.pop(context, true);
                      }
                    },
              child: viewModel.isBusy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : Text(AppLocalizations.of(context)!.confirmButton),
            ),
          ),
        ],
      ),
    );
  }
}
