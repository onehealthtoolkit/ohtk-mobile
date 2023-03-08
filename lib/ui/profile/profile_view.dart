import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podd_app/components/display_field.dart';
import 'package:podd_app/components/flat_button.dart';
import 'package:podd_app/main.dart';
import 'package:podd_app/ui/profile/change_password_view.dart';
import 'package:podd_app/ui/profile/profile_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../components/language_dropdown.dart';
import 'profile_form_view.dart';

var decoration = BoxDecoration(
  border: Border.all(color: Colors.grey.shade300),
  borderRadius: BorderRadius.circular(4.0),
  color: Colors.white,
);

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 20),
                        children: [
                          Column(
                            children: [
                              _Avatar(),
                              const SizedBox(height: 8),
                              _Language(),
                              const SizedBox(height: 8),
                              DisplayField(
                                label: AppLocalizations.of(context)!
                                    .authorityNameLabel,
                                value: viewModel.authorityName,
                                crossAxisAlignment: CrossAxisAlignment.center,
                              ),
                            ],
                          ),
                          Divider(
                            height: 20,
                            thickness: 1,
                            indent: 0,
                            endIndent: 0,
                            color: Colors.red.shade400,
                          ),
                          DisplayField(
                              label:
                                  AppLocalizations.of(context)!.usernameLabel,
                              value: viewModel.username),
                          DisplayField(
                              label:
                                  AppLocalizations.of(context)!.firstNameLabel,
                              value: viewModel.firstName),
                          DisplayField(
                              label:
                                  AppLocalizations.of(context)!.lastNameLabel,
                              value: viewModel.lastName),
                          DisplayField(
                              label: AppLocalizations.of(context)!.emailLabel,
                              value: viewModel.email),
                          DisplayField(
                              label:
                                  AppLocalizations.of(context)!.telephoneLabel,
                              value: viewModel.telephone),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FlatButton.primary(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileFormView(),
                                  ),
                                );
                              },
                              child: viewModel.isBusy
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.settings_outlined,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .updateProfileButton,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FlatButton.primary(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ChangePasswordView(),
                                  ),
                                );
                              },
                              child: viewModel.isBusy
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.lock_outline,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .changePasswordButton,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FlatButton.primary(
                              backgroundColor: Colors.red[600],
                              onPressed: () async {
                                await viewModel.logout();
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/', (route) => false);
                              },
                              child: Text(
                                  AppLocalizations.of(context)!.logoutButton),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}

class _Language extends HookViewModelWidget<ProfileViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ProfileViewModel viewModel) {
    return SizedBox(
      width: 200,
      height: 30,
      child: LanguageDropdown(
        value: viewModel.language,
        onChanged: (String? value) async {
          await viewModel.changeLanguage(value ?? "en");
          RestartWidget.restartApp(context);
        },
      ),
    );
  }
}

class _Avatar extends HookViewModelWidget<ProfileViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ProfileViewModel viewModel) {
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            //backgroundColor: Color(0xFF7c3f96),
            child: viewModel.photo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.file(
                      File(viewModel.photo!.path),
                      width: 115,
                      height: 115,
                      fit: BoxFit.fill,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: viewModel.avatarUrl == null
                        ? Image.asset(
                            'assets/images/default-avatar-profile.png')
                        : Image.network(
                            viewModel.avatarUrl!,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return const Text('เลือกรูปภาพ');
                            },
                            width: 115,
                            height: 115,
                            fit: BoxFit.fill,
                          ),
                  ),
            //Text('เลือกรูปภาพ'),
            radius: 55,
          ),
          Positioned(
            bottom: 0,
            right: -25,
            child: RawMaterialButton(
              onPressed: () {
                _showAddImageModal(context, viewModel);
              },
              elevation: 2.0,
              fillColor: Colors.white,
              child: Icon(
                Icons.camera_alt,
                color: Theme.of(context).primaryColor,
              ),
              padding: const EdgeInsets.all(10.0),
              shape: CircleBorder(
                  side: BorderSide(
                      width: 2, color: Theme.of(context).primaryColor)),
            ),
          ),
        ],
      ),
    );
  }

  _showAddImageModal(BuildContext context, ProfileViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_album),
              title: const Text('Pick from Gallery'),
              onTap: () async {
                var image = await _pickImage(ImageSource.gallery);
                if (image != null) {
                  viewModel.photo = image;
                }
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a Photo'),
              onTap: () async {
                var image = await _pickImage(ImageSource.camera);
                if (image != null) {
                  viewModel.photo = image;
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<XFile?> _pickImage(ImageSource source) async {
    var picker = ImagePicker();
    try {
      final image = await picker.pickImage(source: source);
      return image;
    } catch (e) {
      debugPrint("$e");
    }
    return null;
  }
}
