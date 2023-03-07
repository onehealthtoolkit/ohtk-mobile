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

import '../../components/flat_button.dart';
import '../../components/language_dropdown.dart';

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
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  colors: [
                    Color(0xFF393E46),
                    Color(0xFF393E46),
                    Color(0xFF393E46),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Center(
                  child: _LoginForm(),
                ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 30, 50, 30),
          child: Image.asset('assets/images/logo.png'),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 30,
                      child: _languageDropdown(viewModel, context),
                    ),
                    const SizedBox(height: 10),
                    _tenantDropdown(viewModel, context),
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
                    const SizedBox(height: 20),
                    TextField(
                      controller: password,
                      textInputAction: TextInputAction.done,
                      obscureText: viewModel.obscureText,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.passwordLabel,
                        errorText: viewModel.error("password"),
                        suffixIcon: IconButton(
                          onPressed: () {
                            viewModel.setObscureText(!viewModel.obscureText);
                          },
                          hoverColor: Colors.transparent,
                          icon: viewModel.obscureText
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                        ),
                      ),
                      onChanged: viewModel.setPassword,
                      onSubmitted: (_value) {
                        viewModel.setPassword(_value);
                        viewModel.authenticate();
                      },
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: -10,
                            right: 2,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ResetPasswordRequestView(),
                                  ),
                                );
                              },
                              child: Text(AppLocalizations.of(context)!
                                  .forgotPasswordButton),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        onPressed:
                            viewModel.isBusy ? null : viewModel.authenticate,
                        child: viewModel.isBusy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(),
                              )
                            : Text(AppLocalizations.of(context)!.loginButton),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _qrcodeLogin(context),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: FlatButton.outline(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterView(),
                            ),
                          );
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.grid_view_outlined, size: 24),
                              const SizedBox(width: 4),
                              Text(
                                  AppLocalizations.of(context)!.registerButton),
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _qrcodeLogin(
    BuildContext context,
  ) {
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
        children: [
          Icon(
            Icons.qr_code_scanner,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 4),
          Text(AppLocalizations.of(context)!.qrCodeLoginButton,
              style: TextStyle(color: Theme.of(context).primaryColor)),
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
        border: InputBorder.none,
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor)),
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
    return LanguageDropdown(
      value: viewModel.language,
      onChanged: (String? value) async {
        await viewModel.changeLanguage(value ?? "en");
        RestartWidget.restartApp(context);
      },
    );
  }
}
