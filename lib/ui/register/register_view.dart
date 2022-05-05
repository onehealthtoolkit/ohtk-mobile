import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/models/register_result.dart';
import 'package:podd_app/ui/register/register_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class RegisterView extends StatelessWidget {
  static const String route = '/register';

  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RegisterViewModel>.reactive(
      viewModelBuilder: () => RegisterViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(title: const Text("Register")),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: viewModel.state == RegisterState.invitation
              ? _InvitationCodeForm()
              : _DetailCodeForm(),
        ),
      ),
    );
  }
}

class _InvitationCodeForm extends HookViewModelWidget<RegisterViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, RegisterViewModel viewModel) {
    var code = useTextEditingController();
    return Column(
      children: <Widget>[
        TextField(
          controller: code,
          onChanged: viewModel.setInvitationCode,
          textInputAction: TextInputAction.done,
          onSubmitted: (_value) {
            viewModel.setInvitationCode(_value);
            viewModel.checkInvitationCode();
          },
          decoration: InputDecoration(
              labelText: "Code", errorText: viewModel.error('invitationCode')),
        ),
        TextButton(
          onPressed: viewModel.checkInvitationCode,
          child: const Text("Next"),
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
          Text("Authoirty: ${viewModel.authorityName ?? ""}"),
          TextField(
            controller: username,
            textInputAction: TextInputAction.next,
            onChanged: viewModel.setUsername,
            decoration: InputDecoration(
              labelText: "username",
              errorText: viewModel.error("username"),
            ),
          ),
          TextField(
            controller: firstName,
            textInputAction: TextInputAction.next,
            onChanged: viewModel.setFirstName,
            decoration: InputDecoration(
              labelText: "First name",
              errorText: viewModel.error("firstName"),
            ),
          ),
          TextField(
            controller: lastName,
            textInputAction: TextInputAction.next,
            onChanged: viewModel.setLastName,
            decoration: InputDecoration(
              labelText: "Last name",
              errorText: viewModel.error("lastName"),
            ),
          ),
          TextField(
            controller: email,
            textInputAction: TextInputAction.next,
            onChanged: viewModel.setEmail,
            decoration: InputDecoration(
              labelText: "Email",
              errorText: viewModel.error("email"),
            ),
          ),
          TextField(
            controller: phone,
            textInputAction: TextInputAction.next,
            onChanged: viewModel.setPhone,
            decoration: InputDecoration(
              labelText: "Phone",
              errorText: viewModel.error("phone"),
            ),
          ),
          ElevatedButton(
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
                : const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
