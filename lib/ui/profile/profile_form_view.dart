import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/components/back_appbar_action.dart';
import 'package:podd_app/components/flat_button.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'profile_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileFormView extends StatelessWidget {
  static const String route = '/register';

  const ProfileFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profileTitle),
          leading: const BackAppBarAction(),
        ),
        body: _ProfileForm(),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FlatButton.primary(
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
                        Navigator.pop(context, true);
                      }
                    },
              child: viewModel.isBusy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(
                      AppLocalizations.of(context)!.confirmUpdate,
                      style: TextStyle(fontSize: 16.sp),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
