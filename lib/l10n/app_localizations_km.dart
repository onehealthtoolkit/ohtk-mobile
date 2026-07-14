// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Khmer Central Khmer (`km`).
class AppLocalizationsKm extends AppLocalizations {
  AppLocalizationsKm([String locale = 'km']) : super(locale);

  @override
  String get appName => 'OHTK Mobile';

  @override
  String get loginTitle => 'ចូលទៅគណនីរបស់អ្នក។';

  @override
  String get signupTitle => 'ចុះ​ឈ្មោះ';

  @override
  String get signupSubTitle => 'Please enter Invitation Code\nfor registration';

  @override
  String get forgotPasswordTitle => 'ភ្លេច​លេខសំងាត់​';

  @override
  String get forgotPasswordSubTitle =>
      'Please enter your email address to receive messages for editing password';

  @override
  String get changePasswordTitle => 'ផ្លាស់ប្តូរពាក្យសម្ងាត់';

  @override
  String get incidentsTabTitle => 'Incidents';

  @override
  String get observationsTabTitle => 'Observations';

  @override
  String get censusTabTitle => 'Census';

  @override
  String get profileTabTitle => 'Profile';

  @override
  String get caseTag => 'Case';

  @override
  String get reportTitle => 'រាយការណ៍';

  @override
  String get reportTypeTitle => 'ប្រភេទ​នៃ​របាយការណ៍';

  @override
  String get reportDetailTitle => 'រាយការណ៍លម្អិត';

  @override
  String get followupTitle => 'តាមដាន';

  @override
  String get followupDetailTitle => 'ព័ត៌មានលម្អិតតាមដាន';

  @override
  String get profileTitle => 'Profile';

  @override
  String get loginButton => 'ចូល';

  @override
  String get qrCodeLoginButton => 'QRCode LOGIN';

  @override
  String get pickQrcodeImageButton => 'Choose QRCode image';

  @override
  String get getLoginQrcodeButton => 'my QR login';

  @override
  String get logoutButton => 'Logout';

  @override
  String get registerButton => 'ចុះឈ្មោះ';

  @override
  String get forgotPasswordButton => 'ភ្លេច​លេខសំងាត់​';

  @override
  String get messagesPageTitle => 'Messages';

  @override
  String get messagePageTitle => 'Message';

  @override
  String get formPageLabel => 'Page';

  @override
  String get backButton => 'ត្រឡប់មកវិញ';

  @override
  String get formBackButton => 'back';

  @override
  String get nextButton => 'បន្ទាប់';

  @override
  String get formNextButton => 'next';

  @override
  String get submitButton => 'Submit';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get confirmRegisterButton => 'Confirm Register';

  @override
  String get sendButton => 'Send';

  @override
  String get updateProfileButton => 'Update Profile';

  @override
  String get confirmUpdate => 'Confirm Update';

  @override
  String get profileUpdateSuccess => 'Profile Updated';

  @override
  String get passwordUpdatedSuccess =>
      'Your password has been successfully changed!';

  @override
  String get changePasswordButton => 'Change Password';

  @override
  String get laguageLabel => 'ភាសា';

  @override
  String get serverLabel => 'ម៉ាស៊ីនមេ';

  @override
  String get usernameLabel => 'ឈ្មោះ​អ្នកប្រើប្រាស់';

  @override
  String get passwordLabel => 'ពាក្យសម្ងាត់';

  @override
  String get newPasswordLabel => 'ពាក្យសម្ងាត់';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get invitationCodeLabel => 'លេខ​កូដ​ការ​អញ្ជើញ';

  @override
  String get firstNameLabel => 'ឈ្មោះដំបូង';

  @override
  String get lastNameLabel => 'នាមត្រកូល';

  @override
  String get emailLabel => 'អ៊ីមែល';

  @override
  String get emailHint => 'tester@gmail.com';

  @override
  String get telephoneLabel => 'ទូរស័ព្ទ';

  @override
  String get addressLabel => 'Address';

  @override
  String get allReportTabLabel => 'របាយការណ៍ទាំងអស់។';

  @override
  String get myReportTabLabel => 'របាយការណ៍របស់ខ្ញុំ';

  @override
  String get detailTabLabel => 'លម្អិត';

  @override
  String get commentTabLabel => 'មតិយោបល់';

  @override
  String get followupTabLabel => 'Followup';

  @override
  String get authorityNameLabel => 'Authority Name';

  @override
  String get noFollowupReport => 'No followup report';

  @override
  String get noComment => 'No comment';

  @override
  String get noGpsProvided => 'No gps location provided';

  @override
  String get zeroReportLabel =>
      'របាយការណ៍​មិន​បាន​រក​ឃើញ​អ្វី​ខុស​ប្រក្រតី​ទេ។';

  @override
  String get zeroReportPillLabel => 'Zero report';

  @override
  String get nothingToReportTitle => 'មិនមានអ្វីត្រូវរាយការណ៍សប្តាហ៍នេះទេ';

  @override
  String lastZeroReportLabel(String datetime) {
    return 'Zero report ចុងក្រោយ $datetime';
  }

  @override
  String get testModeLabel => 'របៀបសាកល្បង';

  @override
  String get testModeBannerMessage =>
      'របៀបសាកល្បងបើក — ការដាក់ស្នើនឹងទៅកាន់សាកល្បងតែប៉ុណ្ណោះ។';

  @override
  String offlineCachedListMessage(String date) {
    return 'ក្រៅបណ្តាញ · បង្ហាញបញ្ជីដែលរក្សាទុកពី $date';
  }

  @override
  String get noReportTypesTitle => 'មិនមានប្រភេទរបាយការណ៍';

  @override
  String get noReportTypesHelper =>
      'អ្នកសម្របសម្រួលរបស់អ្នកមិនទាន់បានចេញផ្សាយបញ្ជី ឬ​ការធ្វើសមកាលកម្មមិនទាន់បានបញ្ចប់​ទេ។ ទាញដើម្បីផ្ទុកឡើងវិញ ឬ​ទាក់ទងមេភូមិ។';

  @override
  String get tryAgainButton => 'ព្យាយាមម្តងទៀត';

  @override
  String get adminToolsSectionLabel => 'ឧបករណ៍អ្នកគ្រប់គ្រង';

  @override
  String get testDraftFormLabel => 'សាកល្បងទម្រង់ព្រាង';

  @override
  String get testDraftFormHelper =>
      'ស្កេន QR ពីផ្ទាំងគ្រប់គ្រងបណ្តាញដើម្បីមើលប្រភេទរបាយការណ៍មិនទាន់ផ្សាយ។';

  @override
  String get formChromeBackLabel => 'ត្រឡប់';

  @override
  String get formChromeNextLabel => 'បន្ទាប់';

  @override
  String get formChromeReviewLabel => 'ពិនិត្យ';

  @override
  String get formChromeSubmitReportLabel => 'ដាក់ស្នើរបាយការណ៍';

  @override
  String get formChromeSubmitFollowupLabel => 'ដាក់ស្នើការតាមដាន';

  @override
  String formStepLabel(int current, int total) {
    return 'ជំហានទី $current ក្នុងចំណោម $total';
  }

  @override
  String get formSaveDraftAction => 'រក្សាទុកជាសេចក្តីព្រាង';

  @override
  String get formDraftSavedMessage =>
      'បានរក្សាទុកសេចក្តីព្រាង — រូបភាព និងឯកសារ​នៅរក្សាទុក​លើឧបករណ៍នេះ';

  @override
  String get exitDialogTitle => 'ចាកចេញដោយមិនដាក់ស្នើ?';

  @override
  String get exitDialogBody =>
      'ចម្លើយ និងរូបភាពដែលភ្ជាប់នឹងត្រូវលុបចោល។ អ្នកអាចរក្សាទុកជាសេចក្តីព្រាងពីម៉ឺនុយដើម្បីរក្សាវាបាន។';

  @override
  String get exitDialogDiscardButton => 'លុបចោល និងចាកចេញ';

  @override
  String get exitDialogKeepButton => 'បន្តកែសម្រួល';

  @override
  String get choiceOtherPlaceholder => 'សូមបញ្ជាក់';

  @override
  String get attachFileButton => 'ភ្ជាប់ឯកសារ';

  @override
  String get addAnotherSubformButton => 'បន្ថែមមួយទៀត';

  @override
  String get subformDeleteConfirmTitle => 'លុបធាតុនេះ?';

  @override
  String get subformDeleteConfirmBody => 'ធាតុនេះនឹងត្រូវលុបចេញពីទម្រង់។';

  @override
  String get subformDeleteConfirmAction => 'លុប';

  @override
  String get reviewHeaderEyebrow => 'ពិនិត្យ និងផ្ញើ';

  @override
  String get reviewHeaderTitle => 'ពិនិត្យរបាយការណ៍មុនពេលផ្ញើ';

  @override
  String get authorityEyebrow => 'មួយរឿងទៀត';

  @override
  String get authorityHelper =>
      'យើងប្រើវាដើម្បីបញ្ជូនរបាយការណ៍ទៅក្រុមដែលទទួលខុសត្រូវ។';

  @override
  String get reviewEditButton => 'កែ';

  @override
  String get reviewReminderBody =>
      'នៅពេលផ្ញើរួច របាយការណ៍នេះមិនអាចកែបានទេ។ សូមពិនិត្យសេចក្តីសង្ខេបខាងលើមុនពេលផ្ញើ។';

  @override
  String get reviewBackToFormButton => 'ត្រឡប់ទៅទម្រង់';

  @override
  String get recentSectionLabel => 'ថ្មីៗ';

  @override
  String get earlierSectionLabel => 'មុននេះ';

  @override
  String get noReportsTitle => 'មិនទាន់មានរបាយការណ៍';

  @override
  String get noReportsHelper =>
      'ចុចលើ + ពណ៌បៃតងខាងក្រោមដើម្បីបង្កើតរបាយការណ៍ដំបូងរបស់អ្នក ឬ​ដាក់ស្នើ​របាយការណ៍​សូន្យ​ប្រសិន​បើ​មិន​មាន​អ្វី​ដែល​ត្រូវ​រាយការណ៍​ក្នុង​សប្តាហ៍​នេះ​ទេ។';

  @override
  String get newReportFabLabel => 'New report';

  @override
  String get descriptionSectionLabel => 'ការ​ពិពណ៌នា';

  @override
  String get noDescriptionProvided => 'មិន​មាន​ការ​ពិពណ៌នា';

  @override
  String get photosSectionLabel => 'រូបថត';

  @override
  String get attachmentsSectionLabel => 'ឯកសារ​ភ្ជាប់';

  @override
  String get locationSectionLabel => 'ទីតាំង';

  @override
  String get followUpFabLabel => 'ការតាមដាន';

  @override
  String get commentPlaceholder => 'សរសេរ​មតិ…';

  @override
  String get noCommentsTitle => 'មិន​ទាន់​មាន​មតិ​ទេ';

  @override
  String get noCommentsHelper =>
      'បន្ថែម​មតិ​មុន​គេ ក្រុម​របស់​អ្នក​នឹង​ទទួល​បាន​ការ​ជូន​ដំណឹង';

  @override
  String get noFollowupsTitle => 'មិន​ទាន់​មាន​ការតាមដាន';

  @override
  String get noFollowupsHelper =>
      'ចុច​ + ដើម្បី​បន្ថែម​ការតាមដាន​ដំបូង — ការ​ចុះ​ពិនិត្យ​មូលដ្ឋាន លទ្ធផល​មន្ទីរ​ពិសោធន៍ ឬ​ការ​ធ្វើ​បច្ចុប្បន្នភាព​ស្ថានភាព';

  @override
  String followupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ការតាមដាន $count',
    );
    return '$_temp0';
  }

  @override
  String get reportNotFoundTitle => 'មិន​ឃើញ​របាយការណ៍';

  @override
  String get reportNotFoundHelper =>
      'របាយការណ៍​នេះ​អាច​ត្រូវ​បាន​លុប ឬ​អ្នក​មិន​មាន​អ៊ីនធឺណិត ទាញ​ដើម្បី​ផ្ទុក​ឡើង​វិញ ឬ​ត្រឡប់​ទៅ​បញ្ជី';

  @override
  String get backToIncidentsButton => 'ត្រឡប់​ទៅ​បញ្ជី';

  @override
  String get loadingLabel => 'កំពុង​ផ្ទុក…';

  @override
  String get testTag => 'សាកល្បង';

  @override
  String zeroReportLastReportedMessage(String datetime) {
    return 'រាយការណ៍ចុងក្រោយនៅ $datetime';
  }

  @override
  String get zeroReportSubmitSuccess => 'បានផ្ញើរបាយការណ៍ដោយជោគជ័យ';

  @override
  String get fieldUndefinedLocation => 'មិនបានជ្រើសរើសទីតាំងទេ។';

  @override
  String get fieldUseCurrentLocation => 'ប្រើទីតាំងបច្ចុប្បន្ន';

  @override
  String get authorityLabel => 'Authority';

  @override
  String get incidentDate => 'Incident Date';

  @override
  String get invalidQrcode => 'Invalid qrcode';

  @override
  String get invalidReportTypeQrcode => 'Invalid report type qrcode';

  @override
  String get invalidFormValue => 'Invalid form value';

  @override
  String get simulateReportTitle => 'Simulate report';

  @override
  String get closeSimulateReportButton => 'Close report simulation';

  @override
  String get consentButton => 'I agree';

  @override
  String get observationSubjectViewTitle => 'Subject';

  @override
  String get observationSubjectDetailTabLabel => 'Detail';

  @override
  String get observationSubjectMonitoringTabLabel => 'Monitoring';

  @override
  String get observationSubjectMonitoringViewTitle => 'Subject monitoring';

  @override
  String get validateRequiredMsg => 'This field is required';

  @override
  String dateFieldMaxErrorMsg(String max) {
    return 'must be equal or less than $max';
  }

  @override
  String dateFieldMinErrorMsg(String min) {
    return 'must be equal or more than $min';
  }

  @override
  String integerFieldMaxErrorMsg(String max) {
    return 'must be equal or less than $max';
  }

  @override
  String integerFieldMinErrorMsg(String min) {
    return 'must be equal or more than $min';
  }

  @override
  String textFieldMaxErrorMsg(String max) {
    return 'must be equal or less than $max letters';
  }

  @override
  String textFieldMinErrorMsg(String min) {
    return 'must be equal or more than $min letters';
  }

  @override
  String filesFieldMaxErrorMsg(String max) {
    return 'Number of files must be equal or less than $max';
  }

  @override
  String filesFieldMinErrorMsg(String min) {
    return 'Number of files must be equal or more than $min';
  }

  @override
  String filesFieldMaxSizeErrorMsg(String index, String maxSize) {
    return 'Size of file: #$index must be equal or less than $maxSize bytes';
  }

  @override
  String filesFieldSupportedTypeErrorMsg(String index) {
    return 'Type of file: #$index are not supported';
  }

  @override
  String get testFlag => 'Test';

  @override
  String get confirm => 'Are you sure to continue?';

  @override
  String get confirmCheckReport =>
      'This report data cannot be changed once it was submitted. Please make sure everything is correct.';

  @override
  String get submitReportMessage =>
      'Press the submit button to submit your report';

  @override
  String get reportDataSummary => 'Report data summary';

  @override
  String get reportDataSummaryNotFound =>
      'No content of summary is defined for this report type';

  @override
  String get confirmExit => 'Are you sure to continue?';

  @override
  String get incidentInAuthority =>
      'Did this incident occur in your own authority?';

  @override
  String get yesAsAccept => 'Yes';

  @override
  String get noAsReject => 'No';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get testModeOn => 'Test mode is on';

  @override
  String get loading => 'Loading...';

  @override
  String get fieldRequired => 'field is required.';

  @override
  String get passwordMismatch => 'Password does not match confirm password';

  @override
  String get restartApp => 'Application needs to be restarted.';

  @override
  String numberOfPendingSubmissions(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'submissions',
      one: 'submission',
    );
    return '$countString pending $_temp0, tap here to re-submit';
  }

  @override
  String get pendingReportsTitle => 'Reports';

  @override
  String get pendingSubjectsTitle => 'Observation records';

  @override
  String get pendingMonitoringsTitle => 'Observation monitorings';

  @override
  String get pendingImagesTitle => 'Images';

  @override
  String get pendingFilesTitle => 'Files';

  @override
  String get pendingAppLabel => 'Pending submissions';

  @override
  String get invitationCodeIsRequired => 'Invitation code is required';

  @override
  String get pickFromGallery => 'Pick from Gallery';

  @override
  String get takeAPhoto => 'Take a Photo';

  @override
  String get offlineWarning =>
      'You are offline, please check your internet connection';

  @override
  String get resubmit => 'Resubmit';

  @override
  String get noPendingSubmissions => 'There are no pending submissions.';

  @override
  String get locationServiceIsDisabled =>
      'Location service is disabled, you need to turn it on.';

  @override
  String get loadMore => 'Load more';

  @override
  String get welcomeTitle => 'សូមស្វាគមន៍';

  @override
  String get welcomeSubtitle => 'រៀបចំមុនពេលចូលប្រើ';

  @override
  String get welcomeLanguageTitle => 'ភាសា';

  @override
  String get welcomeServerTitle => 'ម៉ាស៊ីនមេ';

  @override
  String get welcomeContinueButton => 'បន្ត';

  @override
  String get welcomeSavingLabel => 'កំពុងរក្សាទុក…';

  @override
  String get welcomeNoServersText => 'មិនមានម៉ាស៊ីនមេដែលអាចប្រើបាន';

  @override
  String get welcomeCannotLoadServers => 'មិនអាចផ្ទុកម៉ាស៊ីនមេបានទេ';

  @override
  String get signInRegisterCta => 'ចុះឈ្មោះជាអ្នករាយការណ៍';

  @override
  String get signInButton => 'ចូលប្រើប្រាស់';

  @override
  String get signInQrCodeButton => 'ចូលប្រើប្រាស់ដោយ QRCode';

  @override
  String get signInReturningEyebrow => 'អ្នករាយការណ៍ចាស់';

  @override
  String get signInServerLabel => 'ម៉ាស៊ីនមេ';

  @override
  String get signInChangeServerButton => 'ប្ដូរ';

  @override
  String get signInChangeLanguageTitle => 'ភាសា';

  @override
  String get signInChangeLanguageHint => 'ប៉ះតែម្ដងអនុវត្តភ្លាមៗ';

  @override
  String get signInChangeServerTitle => 'ប្ដូរម៉ាស៊ីនមេ';

  @override
  String get signInChangeServerHint =>
      'ប្រទេសនិងអង្គការផ្សេងគ្នាប្រើម៉ាស៊ីនមេផ្សេងគ្នា';

  @override
  String get signInServerCurrentBadge => 'បច្ចុប្បន្ន';

  @override
  String get signInCancelButton => 'បោះបង់';

  @override
  String get signInConfirmServerButton => 'ប្ដូរម៉ាស៊ីនមេ';

  @override
  String get registerTitle => 'ចុះឈ្មោះអ្នករាយការណ៍';

  @override
  String get registerStep1Eyebrow => 'ជំហានទី 1 ក្នុងចំណោម 2';

  @override
  String get registerStep2Eyebrow => 'ជំហានទី 2 ក្នុងចំណោម 2';

  @override
  String get registerCodeTitle => 'បញ្ចូលលេខកូដការអញ្ជើញ';

  @override
  String get registerCodeSubtitle =>
      'អ្នកសម្របសម្រួលនឹងផ្ដល់លេខកូដ 7 ខ្ទង់ឱ្យអ្នក។';

  @override
  String get registerCodeError =>
      'លេខកូដមិនត្រឹមត្រូវ សូមទាក់ទងអ្នកសម្របសម្រួល។';

  @override
  String get registerCodeChecking => 'កំពុងពិនិត្យលេខកូដ…';

  @override
  String get registerCodeContinue => 'បន្ទាប់';

  @override
  String get registerCodeContinueChecking => 'កំពុងពិនិត្យ…';

  @override
  String get registerCodeHelp => 'មិនមានលេខកូដទេ?';

  @override
  String get registerCodeHelpLink => 'ទាក់ទងអ្នកសម្របសម្រួល';

  @override
  String get registerCodeAccepted => 'លេខកូដត្រឹមត្រូវ';

  @override
  String get registerVillageLabel => 'ភូមិ';

  @override
  String get registerUsernameHint =>
      'បានបង្កើតដោយស្វ័យប្រវត្តិ អាចកែប្រែបានតែឥឡូវនេះប៉ុណ្ណោះ';

  @override
  String get registerFirstNamePlaceholder => 'ឈ្មោះដំបូង';

  @override
  String get registerLastNamePlaceholder => 'នាមត្រកូល';

  @override
  String get registerPhonePlaceholder => '08x-xxx-xxxx';

  @override
  String get registerEmailHint =>
      'យើងបង្កើតអ៊ីមែលឱ្យអ្នកហើយ ចុចដើម្បីបញ្ចូលអ៊ីមែលពិតរបស់អ្នកប្រសិនបើមាន';

  @override
  String get registerAddressPlaceholder => 'លេខផ្ទះ ផ្លូវ';

  @override
  String get registerOptional => 'ស្រេចចិត្ត';

  @override
  String get registerAuto => 'ស្វ័យប្រវត្តិ';

  @override
  String get registerNoPasswordInfo =>
      'មិនទាន់មានពាក្យសម្ងាត់ទេ អាចកំណត់នៅក្នុងការកំណត់ក្រោយចូលប្រើ';

  @override
  String get registerSubmit => 'បង្កើតគណនី និងចូល';

  @override
  String get registerCreating => 'កំពុងបង្កើតគណនី…';

  @override
  String get profileSectionContactInfo => 'Contact info';

  @override
  String get profileLabelActiveVillage => 'Active village';

  @override
  String get profileValueNotProvided => 'Not provided';

  @override
  String get profileValueNotAssigned => 'Not assigned';

  @override
  String get profileCompleteContactTitle => 'Complete your contact info';

  @override
  String get profileCompleteContactBody =>
      'So responders can reach you about your reports.';

  @override
  String get signOutConfirmTitle => 'Sign out of OHTK?';

  @override
  String get signOutConfirmBody =>
      'You\'ll need to sign in again to see your reports.';

  @override
  String get qrDialogEyebrow => 'Your login code';

  @override
  String get qrDialogTitle => 'Save this to use later';

  @override
  String get qrDialogBody =>
      'Save this image to your phone. Next time you sign in — on this phone or a new one — pick \"Sign in with QR\" and show this code to the camera.';

  @override
  String get qrLoading => 'Loading';

  @override
  String get qrKeepPrivate => 'Keep this image private';

  @override
  String get qrSaveToGallery => 'Save to gallery';

  @override
  String get qrSaveSuccess => 'Saved to gallery';

  @override
  String get qrSaveFailed => 'Couldn\'t save QR code';

  @override
  String get avatarSheetTitle => 'Update profile photo';

  @override
  String get avatarSheetSubtitle =>
      'Pick a square image — others will see it on your reports.';

  @override
  String get avatarSheetTakePhoto => 'Take a photo';

  @override
  String get avatarSheetChooseGallery => 'Choose from gallery';

  @override
  String get villageSheetTitle => 'Choose active village';

  @override
  String get villageSheetBody =>
      'New reports will be filed against this village.';

  @override
  String get profileFormReadonlyEyebrow => 'Set by your admin · not editable';

  @override
  String get profilePhoneOptionalHelper =>
      'Used to reach you about your reports';

  @override
  String get passwordIntroBody =>
      'Pick something easy for you to remember — you only use this once in a while.';

  @override
  String get passwordHelperTip =>
      'Tip: pick a word or number you\'ll remember.';

  @override
  String get villageEyebrow => 'Village';

  @override
  String get censusHubHelperMulti =>
      'Choose a census to update. Each one is saved separately.';

  @override
  String get censusHubHelperSingle => 'Choose to keep this census up to date.';

  @override
  String censusCachedDefinitionNotice(int version) {
    return 'Offline or unable to refresh. Showing cached form version v$version.';
  }

  @override
  String get censusOldSnapshotMatchingNotice =>
      'Previous submission used an older form. Matching values are pre-filled.';

  @override
  String get censusOldSnapshotBlankNotice =>
      'Previous submission used an older form. Enter current values for this version.';

  @override
  String get censusNoPreviousSubmissionInstruction =>
      'No census has been submitted yet. Enter the current values for each row.';

  @override
  String get censusUpdatePreviousSubmissionInstruction =>
      'Update anything that has changed. Numbers from the last submission are pre-filled.';

  @override
  String get censusDefinitionChangedMessage =>
      'Census form changed. Reload the form and submit again.';

  @override
  String get censusReloadFormAction => 'Reload form';

  @override
  String get censusFormReloadedMessage => 'Census form reloaded.';

  @override
  String get censusFormReloadedPartialMessage =>
      'Census form reloaded. Some values need to be entered again.';

  @override
  String get censusAnimalTitle => 'Animal census';

  @override
  String get censusHumanTitle => 'Human census';

  @override
  String get censusGenericTitle => 'Census';

  @override
  String get censusUnavailableTitle => 'Census is not available';

  @override
  String get censusUnavailableMessage =>
      'This account is not assigned to update a village census.';

  @override
  String get censusInactiveTitle => 'This census is inactive';

  @override
  String get censusInactiveMessage =>
      'This census form is currently turned off by your coordinator. Go back to choose an available census.';

  @override
  String get censusLoadFailedTitle => 'Couldn\'t load the census';

  @override
  String get censusUnsupportedTitle => 'This census needs a newer app';

  @override
  String get censusUnsupportedMessage =>
      'The village census has been updated and isn\'t supported on this version of OHTK Mobile. Please update the app, then try again.';

  @override
  String get censusNoRowsConfigured => 'No active census rows are configured.';

  @override
  String get censusNoSetupTitle => 'No census set up';

  @override
  String get censusNoSetupMessage =>
      'This village does not have an active census form configured.';

  @override
  String censusLastUpdatedLabel(String date) {
    return 'Last updated $date';
  }

  @override
  String get censusNotSubmittedYet => 'Not submitted yet';

  @override
  String get censusNoVillage => 'No village';

  @override
  String get censusNoSubmittedYet => 'No census submitted yet';

  @override
  String get censusEditedBadge => 'EDITED';

  @override
  String get censusHouseholdSummaryTitle => 'Village household summary';

  @override
  String get censusVillageHouseholdQuantityLabel => 'Village households';

  @override
  String get censusAnimalHouseholdQuantityLabel => 'Households with animals';

  @override
  String get censusAnimalHouseholdsExceedVillageError =>
      'Households with animals cannot exceed village households.';

  @override
  String get censusSaveCurrentButton => 'Save current census';

  @override
  String get censusSubmittedMessage => 'Census submitted.';

  @override
  String get censusDraftSavedNotice => 'Draft saved on this device.';

  @override
  String get censusDiscardDraftAction => 'Discard draft';

  @override
  String get censusDraftDiscardedMessage => 'Draft discarded.';

  @override
  String get censusVillageUnavailableError =>
      'Village census is not available.';

  @override
  String get censusUnsupportedError =>
      'This census form is not supported by this app version.';

  @override
  String get censusUnknownKindError => 'Unknown census kind.';

  @override
  String censusInvalidNumberError(String label) {
    return 'Enter a non-negative whole number for $label.';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationDetailTitle => 'Message';

  @override
  String get reportSubmitSuccess => 'Report submitted';
}
