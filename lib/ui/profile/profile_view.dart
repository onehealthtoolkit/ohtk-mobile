import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/display_field.dart';
import 'package:podd_app/components/flat_button.dart';
import 'package:podd_app/components/restart_widget.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/ui/profile/profile_view_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

import '../../components/language_dropdown.dart';

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
                          Divider(
                            height: 20,
                            thickness: 1,
                            indent: 0,
                            endIndent: 0,
                            color: Colors.red.shade400,
                          ),
                          _DownloadLoginQrCodeButton(),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: FlatButton.primary(
                              onPressed: () {
                                GoRouter.of(context).push('/profile/form').then(
                                    (value) => value == true
                                        ? viewModel.initValue()
                                        : null);
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
                                GoRouter.of(context).push('/profile/password');
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

class _DownloadLoginQrCodeButton extends StackedHookView<ProfileViewModel> {
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget builder(BuildContext context, ProfileViewModel viewModel) {
    return viewModel.busy('downloadQrcode')
        ? Padding(
            padding: EdgeInsets.all(12.0.w),
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: appTheme.primary,
                ),
              ),
            ),
          )
        : SizedBox(
            width: double.infinity,
            child: TextButton(
                onPressed: () {
                  viewModel.downloadLoginQrCode().then((token) {
                    showQrCodeDialog(context, token);
                  });
                },
                child: const Text('Get login QRcode')),
          );
  }

  showQrCodeDialog(BuildContext context, String data) {
    showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(animation),
              child: SafeArea(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.height * 0.95,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Login QR Code',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        QrImageView(
                          data: data,
                          version: QrVersions.auto,
                          size: 300,
                        ),
                        FlatButton.outline(
                          onPressed: () => GoRouter.of(context).pop(),
                          child: const Text('close'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class _Language extends StackedHookView<ProfileViewModel> {
  @override
  Widget builder(BuildContext context, ProfileViewModel viewModel) {
    return SizedBox(
      width: 200,
      height: 30,
      child: LanguageDropdown(
        value: viewModel.language,
        onChanged: (String? value) async {
          await showDialog<bool>(
            barrierDismissible: false,
            context: context,
            builder: (_) => AlertDialog(
              content: Text(
                AppLocalizations.of(context)!.restartApp,
                textAlign: TextAlign.center,
              ),
              contentTextStyle: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding:
                  const EdgeInsets.only(right: 20, left: 20, bottom: 20),
              actions: <Widget>[
                FlatButton.primary(
                  child: Text(AppLocalizations.of(context)!.ok),
                  onPressed: () async {
                    await viewModel.changeLanguage(value ?? "en");
                    if (context.mounted) {
                      RestartWidget.restartApp(context);
                    }
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Avatar extends StackedHookView<ProfileViewModel> {
  @override
  Widget builder(BuildContext context, ProfileViewModel viewModel) {
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
                  radius: 55,
                  child: ClipOval(
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
                    padding: const EdgeInsets.all(10.0),
                    shape: CircleBorder(
                        side: BorderSide(
                            width: 2, color: Theme.of(context).primaryColor)),
                    child: Icon(
                      Icons.camera_alt,
                      color: Theme.of(context).primaryColor,
                    ),
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
                if (context.mounted) {
                  Navigator.pop(context);
                }
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
                if (context.mounted) {
                  Navigator.pop(context);
                }
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
