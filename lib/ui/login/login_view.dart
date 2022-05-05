import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/ui/login/login_view_model.dart';
import 'package:podd_app/ui/register/register_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.nonReactive(
      viewModelBuilder: () => LoginViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: _LoginForm()),
        ),
      ),
    );
  }
}

class _LoginForm extends HookViewModelWidget<LoginViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, LoginViewModel viewModel) {
    var username = useTextEditingController();
    var password = useTextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
          controller: password,
          textInputAction: TextInputAction.done,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "password",
            errorText: viewModel.error("password"),
          ),
          onChanged: viewModel.setPassword,
          onSubmitted: (_value) {
            viewModel.setPassword(_value);
            viewModel.authenticate();
          },
        ),
        if (viewModel.hasErrorForKey("general"))
          Text(viewModel.error("general")),
        ElevatedButton(
          onPressed: viewModel.isBusy ? null : viewModel.authenticate,
          child: viewModel.isBusy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(),
                )
              : const Text("Login"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RegisterView(),
              ),
            );
          },
          child: const Text("Register"),
        ),
      ],
    );
  }
}
