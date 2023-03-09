import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/components/display_field.dart';
import 'package:podd_app/models/register_result.dart';
import 'package:podd_app/ui/register/register_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterView extends StatelessWidget {
  static const String route = '/register';

  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RegisterViewModel>.reactive(
      viewModelBuilder: () => RegisterViewModel(),
      builder: (context, viewModel, child) => WillPopScope(
        onWillPop: () async {
          return _willPop(context);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.signupTitle),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
            child: viewModel.state == RegisterState.invitation
                ? _InvitationCodeForm()
                : _DetailCodeForm(),
          ),
        ),
      ),
    );
  }

  Future<bool> _willPop(BuildContext context) {
    return confirm(context);
  }
}

class _InvitationCodeForm extends HookViewModelWidget<RegisterViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, RegisterViewModel viewModel) {
    var code = useTextEditingController();
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            AppLocalizations.of(context)!.signupSubTitle,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: code,
          onChanged: viewModel.setInvitationCode,
          textInputAction: TextInputAction.done,
          onSubmitted: (_value) {
            viewModel.setInvitationCode(_value);
            viewModel.checkInvitationCode();
          },
          decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.invitationCodeLabel,
              errorText: viewModel.error('invitationCode')),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
            onPressed: viewModel.checkInvitationCode,
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
    );
  }
}

class _DetailCodeForm extends HookViewModelWidget<RegisterViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, RegisterViewModel viewModel) {
    var username = useTextEditingController();
    var firstName = useTextEditingController();
    var lastName = useTextEditingController();
    var email = useTextEditingController();
    var phone = useTextEditingController();

    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            children: [
              DisplayField(
                  label: AppLocalizations.of(context)!.authorityNameLabel,
                  value: viewModel.authorityName),
            ],
          ),
          Divider(
            height: 20,
            thickness: 1,
            indent: 0,
            endIndent: 0,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: username,
            textInputAction: TextInputAction.next,
            onChanged: viewModel.setUsername,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.usernameLabel,
              errorText: viewModel.error("username"),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: firstName,
            textInputAction: TextInputAction.next,
            onChanged: viewModel.setFirstName,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.firstNameLabel,
              errorText: viewModel.error("firstName"),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: lastName,
            textInputAction: TextInputAction.next,
            onChanged: viewModel.setLastName,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.lastNameLabel,
              errorText: viewModel.error("lastName"),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: email,
            textInputAction: TextInputAction.next,
            onChanged: viewModel.setEmail,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.emailLabel,
              errorText: viewModel.error("email"),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phone,
            textInputAction: TextInputAction.next,
            onChanged: viewModel.setPhone,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.telephoneLabel,
              errorText: viewModel.error("phone"),
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
                      var result = await viewModel.register();
                      if (result is RegisterSuccess) {
                        Navigator.pop(context, true);
                      }
                    },
              child: viewModel.isBusy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : Text(AppLocalizations.of(context)!.confirmRegisterButton),
            ),
          ),
        ],
      ),
    );
  }
}
