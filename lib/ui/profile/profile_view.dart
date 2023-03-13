import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              _Avatar(),
                              if (viewModel.hasErrorForKey("uploadFail"))
                                Text(
                                  viewModel.error("uploadFail"),
                                  style: const TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              const SizedBox(height: 20),
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
                          const SizedBox(height: 15),
                          DisplayField(
                              label:
                                  AppLocalizations.of(context)!.firstNameLabel,
                              value: viewModel.firstName),
                          const SizedBox(height: 15),
                          DisplayField(
                              label:
                                  AppLocalizations.of(context)!.lastNameLabel,
                              value: viewModel.lastName),
                          const SizedBox(height: 15),
                          DisplayField(
                              label: AppLocalizations.of(context)!.emailLabel,
                              value: viewModel.email),
                          const SizedBox(height: 15),
                          DisplayField(
                              label:
                                  AppLocalizations.of(context)!.telephoneLabel,
                              value: viewModel.telephone),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: FlatButton.primary(
                              onPressed: () {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfileFormView(),
                                      ),
                                    )
                                    .then((value) =>
                                        value ? viewModel.initValue() : null);
                              },
                              child: viewModel.isBusy
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
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
                                            style: TextStyle(fontSize: 15.sp)),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
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
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
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
                                          style: TextStyle(fontSize: 15.sp),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
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
                                AppLocalizations.of(context)!.logoutButton,
                                style: TextStyle(fontSize: 15.sp),
                              ),
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
      child: viewModel.isBusy
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: ClipRRect(
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
                  await viewModel.setPhoto(image);
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
                  viewModel.setPhoto(image);
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
