import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/models/profile_result.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'profile_view.dart';
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _ProfileForm(),
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
      decoration: decoration,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
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
                          var showSuccessMessage = SnackBar(
                            content: Text(AppLocalizations.of(context)
                                    ?.profileUpdateSuccess ??
                                'Profile update success'),
                            backgroundColor: Colors.green,
                          );
                          ScaffoldMessenger.of(context)
                              .showSnackBar(showSuccessMessage);
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
