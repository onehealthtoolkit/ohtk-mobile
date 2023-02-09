import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/main.dart';
import 'package:podd_app/ui/forgot_password/reset_password_request_view.dart';
import 'package:podd_app/ui/login/login_view_model.dart';
import 'package:podd_app/ui/login/qr_login_view.dart';
import 'package:podd_app/ui/register/register_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LoginViewModel>.nonReactive(
      viewModelBuilder: () => LoginViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Center(
                child: _LoginForm(),
              ),
            ),
          ),
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

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 0, 50, 50),
            child: Image.asset('assets/images/logo.png'),
          ),
          _qrcodeLogin(context),
          const SizedBox(height: 10),
          _languageDropdown(viewModel, context),
          const SizedBox(height: 10),
          _tenantDropdown(viewModel, context),
          const SizedBox(height: 10),
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
            controller: password,
            textInputAction: TextInputAction.done,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.passwordLabel,
              errorText: viewModel.error("password"),
            ),
            onChanged: viewModel.setPassword,
            onSubmitted: (_value) {
              viewModel.setPassword(_value);
              viewModel.authenticate();
            },
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
              onPressed: viewModel.isBusy ? null : viewModel.authenticate,
              child: viewModel.isBusy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : Text(AppLocalizations.of(context)!.loginButton),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RegisterView(),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.registerButton),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ResetPasswordRequestView(),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.forgotPasswordButton),
          ),
        ],
      ),
    );
  }

  Widget _qrcodeLogin(BuildContext context) {
    return InkWell(
      onTap: () async {
        var error = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => const QrLoginView(),
          ),
        );
        if (error != null) {
          showAlert(context, error);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.qr_code_scanner,
            size: 36,
          ),
          SizedBox(width: 4),
          Text(
            'QRCode\n LOGIN',
            maxLines: 2,
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => WillPopScope(
        child: AlertDialog(
          title: const Text("Scan Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        onWillPop: () async {
          Navigator.pop(context);
          return true;
        },
      ),
    );
  }

  Widget _tenantDropdown(LoginViewModel viewModel, BuildContext context) {
    if (viewModel.busy("tenants")) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(),
      );
    }

    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.serverLabel,
      ),
      hint: const Text("Server"),
      value: viewModel.subDomain,
      onChanged: (String? value) async {
        await viewModel.changeServer(value ?? "");
        RestartWidget.restartApp(context);
      },
      items: viewModel.serverOptions
          .map<DropdownMenuItem<String>>((option) => DropdownMenuItem(
                child: Text(option['label'] ?? ""),
                value: option["domain"],
              ))
          .toList(),
    );
  }

  Widget _languageDropdown(LoginViewModel viewModel, BuildContext context) {
    if (viewModel.busy("tenants")) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(),
      );
    }
    return DropdownButtonFormField<String>(
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
        ]);
  }
}
