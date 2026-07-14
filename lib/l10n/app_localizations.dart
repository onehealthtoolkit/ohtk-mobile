import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_km.dart';
import 'app_localizations_lo.dart';
import 'app_localizations_my.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('km'),
    Locale('lo'),
    Locale('my'),
    Locale('th')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'OHTK Mobile'**
  String get appName;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login to Your Account'**
  String get loginTitle;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupTitle;

  /// No description provided for @signupSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter Invitation Code\nfor registration'**
  String get signupSubTitle;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address and we will send you a password reset link'**
  String get forgotPasswordSubTitle;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @incidentsTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Incidents'**
  String get incidentsTabTitle;

  /// No description provided for @observationsTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Observations'**
  String get observationsTabTitle;

  /// No description provided for @censusTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Census'**
  String get censusTabTitle;

  /// No description provided for @profileTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTabTitle;

  /// No description provided for @caseTag.
  ///
  /// In en, this message translates to:
  /// **'Case'**
  String get caseTag;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportTitle;

  /// No description provided for @reportTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Report type'**
  String get reportTypeTitle;

  /// No description provided for @reportDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Report detail'**
  String get reportDetailTitle;

  /// No description provided for @followupTitle.
  ///
  /// In en, this message translates to:
  /// **'Followup'**
  String get followupTitle;

  /// No description provided for @followupDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Followup detail'**
  String get followupDetailTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @qrCodeLoginButton.
  ///
  /// In en, this message translates to:
  /// **'QRCode LOGIN'**
  String get qrCodeLoginButton;

  /// No description provided for @pickQrcodeImageButton.
  ///
  /// In en, this message translates to:
  /// **'Choose QRCode image'**
  String get pickQrcodeImageButton;

  /// No description provided for @getLoginQrcodeButton.
  ///
  /// In en, this message translates to:
  /// **'my QR login'**
  String get getLoginQrcodeButton;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordButton;

  /// No description provided for @messagesPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesPageTitle;

  /// No description provided for @messagePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messagePageTitle;

  /// No description provided for @formPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get formPageLabel;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @formBackButton.
  ///
  /// In en, this message translates to:
  /// **'back'**
  String get formBackButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @formNextButton.
  ///
  /// In en, this message translates to:
  /// **'next'**
  String get formNextButton;

  /// No description provided for @submitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @confirmRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Register'**
  String get confirmRegisterButton;

  /// No description provided for @sendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendButton;

  /// No description provided for @updateProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfileButton;

  /// No description provided for @confirmUpdate.
  ///
  /// In en, this message translates to:
  /// **'Confirm Update'**
  String get confirmUpdate;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile Updated'**
  String get profileUpdateSuccess;

  /// No description provided for @passwordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password has been successfully changed!'**
  String get passwordUpdatedSuccess;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordButton;

  /// No description provided for @laguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get laguageLabel;

  /// No description provided for @serverLabel.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get serverLabel;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @invitationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invitation Code'**
  String get invitationCodeLabel;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'tester@gmail.com'**
  String get emailHint;

  /// No description provided for @telephoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Telephone'**
  String get telephoneLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @allReportTabLabel.
  ///
  /// In en, this message translates to:
  /// **'All Reports'**
  String get allReportTabLabel;

  /// No description provided for @myReportTabLabel.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReportTabLabel;

  /// No description provided for @detailTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detailTabLabel;

  /// No description provided for @commentTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentTabLabel;

  /// No description provided for @followupTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Followup'**
  String get followupTabLabel;

  /// No description provided for @authorityNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Authority Name'**
  String get authorityNameLabel;

  /// No description provided for @noFollowupReport.
  ///
  /// In en, this message translates to:
  /// **'No followup report'**
  String get noFollowupReport;

  /// No description provided for @noComment.
  ///
  /// In en, this message translates to:
  /// **'No comment'**
  String get noComment;

  /// No description provided for @noGpsProvided.
  ///
  /// In en, this message translates to:
  /// **'No gps location provided'**
  String get noGpsProvided;

  /// No description provided for @zeroReportLabel.
  ///
  /// In en, this message translates to:
  /// **'Zero report'**
  String get zeroReportLabel;

  /// No description provided for @zeroReportPillLabel.
  ///
  /// In en, this message translates to:
  /// **'Zero report'**
  String get zeroReportPillLabel;

  /// No description provided for @nothingToReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to report this week'**
  String get nothingToReportTitle;

  /// No description provided for @lastZeroReportLabel.
  ///
  /// In en, this message translates to:
  /// **'Last zero report {datetime}'**
  String lastZeroReportLabel(String datetime);

  /// No description provided for @testModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Test mode'**
  String get testModeLabel;

  /// No description provided for @testModeBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'Test mode is on — submissions land in the sandbox only.'**
  String get testModeBannerMessage;

  /// No description provided for @offlineCachedListMessage.
  ///
  /// In en, this message translates to:
  /// **'Offline · showing cached list from {date}'**
  String offlineCachedListMessage(String date);

  /// No description provided for @noReportTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'No report types available'**
  String get noReportTypesTitle;

  /// No description provided for @noReportTypesHelper.
  ///
  /// In en, this message translates to:
  /// **'Your coordinator hasn\'t published a list yet, or the sync hasn\'t finished. Pull to refresh, or contact your village leader.'**
  String get noReportTypesHelper;

  /// No description provided for @tryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgainButton;

  /// No description provided for @adminToolsSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin tools'**
  String get adminToolsSectionLabel;

  /// No description provided for @testDraftFormLabel.
  ///
  /// In en, this message translates to:
  /// **'Test a draft form'**
  String get testDraftFormLabel;

  /// No description provided for @testDraftFormHelper.
  ///
  /// In en, this message translates to:
  /// **'Scan a QR from the web dashboard to preview an unpublished report type.'**
  String get testDraftFormHelper;

  /// No description provided for @formChromeBackLabel.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get formChromeBackLabel;

  /// No description provided for @formChromeNextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get formChromeNextLabel;

  /// No description provided for @formChromeReviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get formChromeReviewLabel;

  /// No description provided for @formChromeSubmitReportLabel.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get formChromeSubmitReportLabel;

  /// No description provided for @formChromeSubmitFollowupLabel.
  ///
  /// In en, this message translates to:
  /// **'Submit follow-up'**
  String get formChromeSubmitFollowupLabel;

  /// No description provided for @formStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String formStepLabel(int current, int total);

  /// No description provided for @formSaveDraftAction.
  ///
  /// In en, this message translates to:
  /// **'Save as draft'**
  String get formSaveDraftAction;

  /// No description provided for @formDraftSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Draft saved — photos and files kept on this device.'**
  String get formDraftSavedMessage;

  /// No description provided for @exitDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave without submitting?'**
  String get exitDialogTitle;

  /// No description provided for @exitDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Your answers and attached photos will be discarded. You can save a draft from the menu to keep them.'**
  String get exitDialogBody;

  /// No description provided for @exitDialogDiscardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard & leave'**
  String get exitDialogDiscardButton;

  /// No description provided for @exitDialogKeepButton.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get exitDialogKeepButton;

  /// No description provided for @choiceOtherPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Please specify'**
  String get choiceOtherPlaceholder;

  /// No description provided for @attachFileButton.
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get attachFileButton;

  /// No description provided for @addAnotherSubformButton.
  ///
  /// In en, this message translates to:
  /// **'Add another'**
  String get addAnotherSubformButton;

  /// No description provided for @subformDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get subformDeleteConfirmTitle;

  /// No description provided for @subformDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This entry will be removed from the form.'**
  String get subformDeleteConfirmBody;

  /// No description provided for @subformDeleteConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get subformDeleteConfirmAction;

  /// No description provided for @reviewHeaderEyebrow.
  ///
  /// In en, this message translates to:
  /// **'REVIEW & SUBMIT'**
  String get reviewHeaderEyebrow;

  /// No description provided for @reviewHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your report before sending'**
  String get reviewHeaderTitle;

  /// No description provided for @authorityEyebrow.
  ///
  /// In en, this message translates to:
  /// **'ONE MORE THING'**
  String get authorityEyebrow;

  /// No description provided for @authorityHelper.
  ///
  /// In en, this message translates to:
  /// **'We use this to route the report to the right responding team.'**
  String get authorityHelper;

  /// No description provided for @reviewEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get reviewEditButton;

  /// No description provided for @reviewReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Once submitted, this report can\'t be edited. Double-check the summary above before sending.'**
  String get reviewReminderBody;

  /// No description provided for @reviewBackToFormButton.
  ///
  /// In en, this message translates to:
  /// **'Back to form'**
  String get reviewBackToFormButton;

  /// No description provided for @recentSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recentSectionLabel;

  /// No description provided for @earlierSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlierSectionLabel;

  /// No description provided for @noReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get noReportsTitle;

  /// No description provided for @noReportsHelper.
  ///
  /// In en, this message translates to:
  /// **'Tap the green + below to file your first report, or submit a Zero report if there\'s nothing to report this week.'**
  String get noReportsHelper;

  /// No description provided for @newReportFabLabel.
  ///
  /// In en, this message translates to:
  /// **'New report'**
  String get newReportFabLabel;

  /// No description provided for @descriptionSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionSectionLabel;

  /// No description provided for @noDescriptionProvided.
  ///
  /// In en, this message translates to:
  /// **'No description provided'**
  String get noDescriptionProvided;

  /// No description provided for @photosSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photosSectionLabel;

  /// No description provided for @attachmentsSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachmentsSectionLabel;

  /// No description provided for @locationSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationSectionLabel;

  /// No description provided for @followUpFabLabel.
  ///
  /// In en, this message translates to:
  /// **'Follow up'**
  String get followUpFabLabel;

  /// No description provided for @commentPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write a comment…'**
  String get commentPlaceholder;

  /// No description provided for @noCommentsTitle.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noCommentsTitle;

  /// No description provided for @noCommentsHelper.
  ///
  /// In en, this message translates to:
  /// **'Be the first to add a note. Your team gets a push notification.'**
  String get noCommentsHelper;

  /// No description provided for @noFollowupsTitle.
  ///
  /// In en, this message translates to:
  /// **'No follow-ups yet'**
  String get noFollowupsTitle;

  /// No description provided for @noFollowupsHelper.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add the first follow-up — typically a field visit, lab result, or status update.'**
  String get noFollowupsHelper;

  /// No description provided for @followupsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} follow-up} other{{count} follow-ups}}'**
  String followupsCount(int count);

  /// No description provided for @reportNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Report not found'**
  String get reportNotFoundTitle;

  /// No description provided for @reportNotFoundHelper.
  ///
  /// In en, this message translates to:
  /// **'This report may have been removed, or you might be offline. Pull to refresh, or go back to the list.'**
  String get reportNotFoundHelper;

  /// No description provided for @backToIncidentsButton.
  ///
  /// In en, this message translates to:
  /// **'Back to incidents'**
  String get backToIncidentsButton;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loadingLabel;

  /// No description provided for @testTag.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get testTag;

  /// No description provided for @zeroReportLastReportedMessage.
  ///
  /// In en, this message translates to:
  /// **'Last reported at {datetime}'**
  String zeroReportLastReportedMessage(String datetime);

  /// No description provided for @zeroReportSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Zero report submitted'**
  String get zeroReportSubmitSuccess;

  /// No description provided for @fieldUndefinedLocation.
  ///
  /// In en, this message translates to:
  /// **'No location selected'**
  String get fieldUndefinedLocation;

  /// No description provided for @fieldUseCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get fieldUseCurrentLocation;

  /// No description provided for @authorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Authority'**
  String get authorityLabel;

  /// No description provided for @incidentDate.
  ///
  /// In en, this message translates to:
  /// **'Incident Date'**
  String get incidentDate;

  /// No description provided for @invalidQrcode.
  ///
  /// In en, this message translates to:
  /// **'Invalid qrcode'**
  String get invalidQrcode;

  /// No description provided for @invalidReportTypeQrcode.
  ///
  /// In en, this message translates to:
  /// **'Invalid report type qrcode'**
  String get invalidReportTypeQrcode;

  /// No description provided for @invalidFormValue.
  ///
  /// In en, this message translates to:
  /// **'Invalid form value'**
  String get invalidFormValue;

  /// No description provided for @simulateReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Simulate report'**
  String get simulateReportTitle;

  /// No description provided for @closeSimulateReportButton.
  ///
  /// In en, this message translates to:
  /// **'Close report simulation'**
  String get closeSimulateReportButton;

  /// No description provided for @consentButton.
  ///
  /// In en, this message translates to:
  /// **'I agree'**
  String get consentButton;

  /// No description provided for @observationSubjectViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get observationSubjectViewTitle;

  /// No description provided for @observationSubjectDetailTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get observationSubjectDetailTabLabel;

  /// No description provided for @observationSubjectMonitoringTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get observationSubjectMonitoringTabLabel;

  /// No description provided for @observationSubjectMonitoringViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Subject monitoring'**
  String get observationSubjectMonitoringViewTitle;

  /// No description provided for @validateRequiredMsg.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validateRequiredMsg;

  /// No description provided for @dateFieldMaxErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'must be equal or less than {max}'**
  String dateFieldMaxErrorMsg(String max);

  /// No description provided for @dateFieldMinErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'must be equal or more than {min}'**
  String dateFieldMinErrorMsg(String min);

  /// No description provided for @integerFieldMaxErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'must be equal or less than {max}'**
  String integerFieldMaxErrorMsg(String max);

  /// No description provided for @integerFieldMinErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'must be equal or more than {min}'**
  String integerFieldMinErrorMsg(String min);

  /// No description provided for @textFieldMaxErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'must be equal or less than {max} letters'**
  String textFieldMaxErrorMsg(String max);

  /// No description provided for @textFieldMinErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'must be equal or more than {min} letters'**
  String textFieldMinErrorMsg(String min);

  /// No description provided for @filesFieldMaxErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Number of files must be equal or less than {max}'**
  String filesFieldMaxErrorMsg(String max);

  /// No description provided for @filesFieldMinErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Number of files must be equal or more than {min}'**
  String filesFieldMinErrorMsg(String min);

  /// No description provided for @filesFieldMaxSizeErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Size of file: #{index} must be equal or less than {maxSize} bytes'**
  String filesFieldMaxSizeErrorMsg(String index, String maxSize);

  /// No description provided for @filesFieldSupportedTypeErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Type of file: #{index} are not supported'**
  String filesFieldSupportedTypeErrorMsg(String index);

  /// No description provided for @testFlag.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get testFlag;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to continue?'**
  String get confirm;

  /// No description provided for @confirmCheckReport.
  ///
  /// In en, this message translates to:
  /// **'This report data cannot be changed once it was submitted. Please make sure everything is correct.'**
  String get confirmCheckReport;

  /// No description provided for @submitReportMessage.
  ///
  /// In en, this message translates to:
  /// **'Press the submit button to submit your report'**
  String get submitReportMessage;

  /// No description provided for @reportDataSummary.
  ///
  /// In en, this message translates to:
  /// **'Report data summary'**
  String get reportDataSummary;

  /// No description provided for @reportDataSummaryNotFound.
  ///
  /// In en, this message translates to:
  /// **'No content of summary is defined for this report type'**
  String get reportDataSummaryNotFound;

  /// No description provided for @confirmExit.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to continue?'**
  String get confirmExit;

  /// No description provided for @incidentInAuthority.
  ///
  /// In en, this message translates to:
  /// **'Did this incident occur in your own authority?'**
  String get incidentInAuthority;

  /// No description provided for @yesAsAccept.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesAsAccept;

  /// No description provided for @noAsReject.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noAsReject;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @testModeOn.
  ///
  /// In en, this message translates to:
  /// **'Test mode is on'**
  String get testModeOn;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'field is required.'**
  String get fieldRequired;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Password does not match confirm password'**
  String get passwordMismatch;

  /// No description provided for @restartApp.
  ///
  /// In en, this message translates to:
  /// **'Application needs to be restarted.'**
  String get restartApp;

  /// No description provided for @numberOfPendingSubmissions.
  ///
  /// In en, this message translates to:
  /// **'{count} pending {count, plural, =1{submission} other{submissions}}, tap here to re-submit'**
  String numberOfPendingSubmissions(int count);

  /// No description provided for @pendingReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get pendingReportsTitle;

  /// No description provided for @pendingSubjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Observation records'**
  String get pendingSubjectsTitle;

  /// No description provided for @pendingMonitoringsTitle.
  ///
  /// In en, this message translates to:
  /// **'Observation monitorings'**
  String get pendingMonitoringsTitle;

  /// No description provided for @pendingImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get pendingImagesTitle;

  /// No description provided for @pendingFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get pendingFilesTitle;

  /// No description provided for @pendingAppLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending submissions'**
  String get pendingAppLabel;

  /// No description provided for @invitationCodeIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Invitation code is required'**
  String get invitationCodeIsRequired;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get pickFromGallery;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takeAPhoto;

  /// No description provided for @offlineWarning.
  ///
  /// In en, this message translates to:
  /// **'You are offline, please check your internet connection'**
  String get offlineWarning;

  /// No description provided for @resubmit.
  ///
  /// In en, this message translates to:
  /// **'Resubmit'**
  String get resubmit;

  /// No description provided for @noPendingSubmissions.
  ///
  /// In en, this message translates to:
  /// **'There are no pending submissions.'**
  String get noPendingSubmissions;

  /// No description provided for @locationServiceIsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location service is disabled, you need to turn it on.'**
  String get locationServiceIsDisabled;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up before signing in'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get welcomeLanguageTitle;

  /// No description provided for @welcomeServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get welcomeServerTitle;

  /// No description provided for @welcomeContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get welcomeContinueButton;

  /// No description provided for @welcomeSavingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get welcomeSavingLabel;

  /// No description provided for @welcomeNoServersText.
  ///
  /// In en, this message translates to:
  /// **'No servers available'**
  String get welcomeNoServersText;

  /// No description provided for @welcomeCannotLoadServers.
  ///
  /// In en, this message translates to:
  /// **'Cannot load servers'**
  String get welcomeCannotLoadServers;

  /// No description provided for @signInRegisterCta.
  ///
  /// In en, this message translates to:
  /// **'Register as reporter'**
  String get signInRegisterCta;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @signInQrCodeButton.
  ///
  /// In en, this message translates to:
  /// **'QRCode Sign In'**
  String get signInQrCodeButton;

  /// No description provided for @signInReturningEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Returning reporter'**
  String get signInReturningEyebrow;

  /// No description provided for @signInServerLabel.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get signInServerLabel;

  /// No description provided for @signInChangeServerButton.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get signInChangeServerButton;

  /// No description provided for @signInChangeLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get signInChangeLanguageTitle;

  /// No description provided for @signInChangeLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Single tap applies immediately'**
  String get signInChangeLanguageHint;

  /// No description provided for @signInChangeServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch server'**
  String get signInChangeServerTitle;

  /// No description provided for @signInChangeServerHint.
  ///
  /// In en, this message translates to:
  /// **'Different countries and orgs use different servers.'**
  String get signInChangeServerHint;

  /// No description provided for @signInServerCurrentBadge.
  ///
  /// In en, this message translates to:
  /// **'CURRENT'**
  String get signInServerCurrentBadge;

  /// No description provided for @signInCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get signInCancelButton;

  /// No description provided for @signInConfirmServerButton.
  ///
  /// In en, this message translates to:
  /// **'Switch server'**
  String get signInConfirmServerButton;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register reporter'**
  String get registerTitle;

  /// No description provided for @registerStep1Eyebrow.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2'**
  String get registerStep1Eyebrow;

  /// No description provided for @registerStep2Eyebrow.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2'**
  String get registerStep2Eyebrow;

  /// No description provided for @registerCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter invitation code'**
  String get registerCodeTitle;

  /// No description provided for @registerCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your training coordinator gave you a 7-digit code.'**
  String get registerCodeSubtitle;

  /// No description provided for @registerCodeError.
  ///
  /// In en, this message translates to:
  /// **'That code wasn\'t recognized. Check with your coordinator.'**
  String get registerCodeError;

  /// No description provided for @registerCodeChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking code…'**
  String get registerCodeChecking;

  /// No description provided for @registerCodeContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get registerCodeContinue;

  /// No description provided for @registerCodeContinueChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get registerCodeContinueChecking;

  /// No description provided for @registerCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have a code?'**
  String get registerCodeHelp;

  /// No description provided for @registerCodeHelpLink.
  ///
  /// In en, this message translates to:
  /// **'Talk to your coordinator'**
  String get registerCodeHelpLink;

  /// No description provided for @registerCodeAccepted.
  ///
  /// In en, this message translates to:
  /// **'Code accepted'**
  String get registerCodeAccepted;

  /// No description provided for @registerVillageLabel.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get registerVillageLabel;

  /// No description provided for @registerUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Auto-suggested. You can change it now — but not later.'**
  String get registerUsernameHint;

  /// No description provided for @registerFirstNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your given name'**
  String get registerFirstNamePlaceholder;

  /// No description provided for @registerLastNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your family name'**
  String get registerLastNamePlaceholder;

  /// No description provided for @registerPhonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'08x-xxx-xxxx'**
  String get registerPhonePlaceholder;

  /// No description provided for @registerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'We made one for you. Tap to enter your real email if you have one.'**
  String get registerEmailHint;

  /// No description provided for @registerAddressPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'House number, road'**
  String get registerAddressPlaceholder;

  /// No description provided for @registerOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get registerOptional;

  /// No description provided for @registerAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get registerAuto;

  /// No description provided for @registerNoPasswordInfo.
  ///
  /// In en, this message translates to:
  /// **'No password yet. You can set one in Settings after sign-in.'**
  String get registerNoPasswordInfo;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create account & sign in'**
  String get registerSubmit;

  /// No description provided for @registerCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating account…'**
  String get registerCreating;

  /// No description provided for @profileSectionContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact info'**
  String get profileSectionContactInfo;

  /// No description provided for @profileLabelActiveVillage.
  ///
  /// In en, this message translates to:
  /// **'Active village'**
  String get profileLabelActiveVillage;

  /// No description provided for @profileValueNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get profileValueNotProvided;

  /// No description provided for @profileValueNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get profileValueNotAssigned;

  /// No description provided for @profileCompleteContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your contact info'**
  String get profileCompleteContactTitle;

  /// No description provided for @profileCompleteContactBody.
  ///
  /// In en, this message translates to:
  /// **'So responders can reach you about your reports.'**
  String get profileCompleteContactBody;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of OHTK?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to see your reports.'**
  String get signOutConfirmBody;

  /// No description provided for @qrDialogEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your login code'**
  String get qrDialogEyebrow;

  /// No description provided for @qrDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save this to use later'**
  String get qrDialogTitle;

  /// No description provided for @qrDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Save this image to your phone. Next time you sign in — on this phone or a new one — pick \"Sign in with QR\" and show this code to the camera.'**
  String get qrDialogBody;

  /// No description provided for @qrLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get qrLoading;

  /// No description provided for @qrKeepPrivate.
  ///
  /// In en, this message translates to:
  /// **'Keep this image private'**
  String get qrKeepPrivate;

  /// No description provided for @qrSaveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to gallery'**
  String get qrSaveToGallery;

  /// No description provided for @qrSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved to gallery'**
  String get qrSaveSuccess;

  /// No description provided for @qrSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save QR code'**
  String get qrSaveFailed;

  /// No description provided for @avatarSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Update profile photo'**
  String get avatarSheetTitle;

  /// No description provided for @avatarSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a square image — others will see it on your reports.'**
  String get avatarSheetSubtitle;

  /// No description provided for @avatarSheetTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get avatarSheetTakePhoto;

  /// No description provided for @avatarSheetChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get avatarSheetChooseGallery;

  /// No description provided for @villageSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose active village'**
  String get villageSheetTitle;

  /// No description provided for @villageSheetBody.
  ///
  /// In en, this message translates to:
  /// **'New reports will be filed against this village.'**
  String get villageSheetBody;

  /// No description provided for @profileFormReadonlyEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Set by your admin · not editable'**
  String get profileFormReadonlyEyebrow;

  /// No description provided for @profilePhoneOptionalHelper.
  ///
  /// In en, this message translates to:
  /// **'Used to reach you about your reports'**
  String get profilePhoneOptionalHelper;

  /// No description provided for @passwordIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Pick something easy for you to remember — you only use this once in a while.'**
  String get passwordIntroBody;

  /// No description provided for @passwordHelperTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: pick a word or number you\'ll remember.'**
  String get passwordHelperTip;

  /// No description provided for @villageEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get villageEyebrow;

  /// No description provided for @censusHubHelperMulti.
  ///
  /// In en, this message translates to:
  /// **'Choose a census to update. Each one is saved separately.'**
  String get censusHubHelperMulti;

  /// No description provided for @censusHubHelperSingle.
  ///
  /// In en, this message translates to:
  /// **'Choose to keep this census up to date.'**
  String get censusHubHelperSingle;

  /// No description provided for @censusCachedDefinitionNotice.
  ///
  /// In en, this message translates to:
  /// **'Offline or unable to refresh. Showing cached form version v{version}.'**
  String censusCachedDefinitionNotice(int version);

  /// No description provided for @censusOldSnapshotMatchingNotice.
  ///
  /// In en, this message translates to:
  /// **'Previous submission used an older form. Matching values are pre-filled.'**
  String get censusOldSnapshotMatchingNotice;

  /// No description provided for @censusOldSnapshotBlankNotice.
  ///
  /// In en, this message translates to:
  /// **'Previous submission used an older form. Enter current values for this version.'**
  String get censusOldSnapshotBlankNotice;

  /// No description provided for @censusNoPreviousSubmissionInstruction.
  ///
  /// In en, this message translates to:
  /// **'No census has been submitted yet. Enter the current values for each row.'**
  String get censusNoPreviousSubmissionInstruction;

  /// No description provided for @censusUpdatePreviousSubmissionInstruction.
  ///
  /// In en, this message translates to:
  /// **'Update anything that has changed. Numbers from the last submission are pre-filled.'**
  String get censusUpdatePreviousSubmissionInstruction;

  /// No description provided for @censusDefinitionChangedMessage.
  ///
  /// In en, this message translates to:
  /// **'Census form changed while you were editing. Reload the form to include the latest rows, then submit again.'**
  String get censusDefinitionChangedMessage;

  /// No description provided for @censusReloadFormAction.
  ///
  /// In en, this message translates to:
  /// **'Reload form'**
  String get censusReloadFormAction;

  /// No description provided for @censusFormReloadedMessage.
  ///
  /// In en, this message translates to:
  /// **'Census form reloaded.'**
  String get censusFormReloadedMessage;

  /// No description provided for @censusFormReloadedPartialMessage.
  ///
  /// In en, this message translates to:
  /// **'Census form reloaded. Some values need to be entered again.'**
  String get censusFormReloadedPartialMessage;

  /// No description provided for @censusAnimalTitle.
  ///
  /// In en, this message translates to:
  /// **'Animal census'**
  String get censusAnimalTitle;

  /// No description provided for @censusHumanTitle.
  ///
  /// In en, this message translates to:
  /// **'Human census'**
  String get censusHumanTitle;

  /// No description provided for @censusGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Census'**
  String get censusGenericTitle;

  /// No description provided for @censusUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Census is not available'**
  String get censusUnavailableTitle;

  /// No description provided for @censusUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'This account is not assigned to update a village census.'**
  String get censusUnavailableMessage;

  /// No description provided for @censusInactiveTitle.
  ///
  /// In en, this message translates to:
  /// **'This census is inactive'**
  String get censusInactiveTitle;

  /// No description provided for @censusInactiveMessage.
  ///
  /// In en, this message translates to:
  /// **'This census form is currently turned off by your coordinator. Go back to choose an available census.'**
  String get censusInactiveMessage;

  /// No description provided for @censusLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the census'**
  String get censusLoadFailedTitle;

  /// No description provided for @censusUnsupportedTitle.
  ///
  /// In en, this message translates to:
  /// **'This census needs a newer app'**
  String get censusUnsupportedTitle;

  /// No description provided for @censusUnsupportedMessage.
  ///
  /// In en, this message translates to:
  /// **'The village census has been updated and isn\'t supported on this version of OHTK Mobile. Please update the app, then try again.'**
  String get censusUnsupportedMessage;

  /// No description provided for @censusNoRowsConfigured.
  ///
  /// In en, this message translates to:
  /// **'No active census rows are configured.'**
  String get censusNoRowsConfigured;

  /// No description provided for @censusNoSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'No census set up'**
  String get censusNoSetupTitle;

  /// No description provided for @censusNoSetupMessage.
  ///
  /// In en, this message translates to:
  /// **'This village does not have an active census form configured.'**
  String get censusNoSetupMessage;

  /// No description provided for @censusLastUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last updated {date}'**
  String censusLastUpdatedLabel(String date);

  /// No description provided for @censusNotSubmittedYet.
  ///
  /// In en, this message translates to:
  /// **'Not submitted yet'**
  String get censusNotSubmittedYet;

  /// No description provided for @censusNoVillage.
  ///
  /// In en, this message translates to:
  /// **'No village'**
  String get censusNoVillage;

  /// No description provided for @censusNoSubmittedYet.
  ///
  /// In en, this message translates to:
  /// **'No census submitted yet'**
  String get censusNoSubmittedYet;

  /// No description provided for @censusEditedBadge.
  ///
  /// In en, this message translates to:
  /// **'EDITED'**
  String get censusEditedBadge;

  /// No description provided for @censusHouseholdSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Village household summary'**
  String get censusHouseholdSummaryTitle;

  /// No description provided for @censusVillageHouseholdQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Village households'**
  String get censusVillageHouseholdQuantityLabel;

  /// No description provided for @censusAnimalHouseholdQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Households with animals'**
  String get censusAnimalHouseholdQuantityLabel;

  /// No description provided for @censusAnimalHouseholdsExceedVillageError.
  ///
  /// In en, this message translates to:
  /// **'Households with animals cannot exceed village households.'**
  String get censusAnimalHouseholdsExceedVillageError;

  /// No description provided for @censusSaveCurrentButton.
  ///
  /// In en, this message translates to:
  /// **'Save current census'**
  String get censusSaveCurrentButton;

  /// No description provided for @censusSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Census submitted.'**
  String get censusSubmittedMessage;

  /// No description provided for @censusDraftSavedNotice.
  ///
  /// In en, this message translates to:
  /// **'Draft saved on this device.'**
  String get censusDraftSavedNotice;

  /// No description provided for @censusDiscardDraftAction.
  ///
  /// In en, this message translates to:
  /// **'Discard draft'**
  String get censusDiscardDraftAction;

  /// No description provided for @censusDraftDiscardedMessage.
  ///
  /// In en, this message translates to:
  /// **'Draft discarded.'**
  String get censusDraftDiscardedMessage;

  /// No description provided for @censusVillageUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Village census is not available.'**
  String get censusVillageUnavailableError;

  /// No description provided for @censusUnsupportedError.
  ///
  /// In en, this message translates to:
  /// **'This census form is not supported by this app version.'**
  String get censusUnsupportedError;

  /// No description provided for @censusUnknownKindError.
  ///
  /// In en, this message translates to:
  /// **'Unknown census kind.'**
  String get censusUnknownKindError;

  /// No description provided for @censusInvalidNumberError.
  ///
  /// In en, this message translates to:
  /// **'Enter a non-negative whole number for {label}.'**
  String censusInvalidNumberError(String label);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get notificationDetailTitle;

  /// No description provided for @reportSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get reportSubmitSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'es',
        'fr',
        'km',
        'lo',
        'my',
        'th'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'km':
      return AppLocalizationsKm();
    case 'lo':
      return AppLocalizationsLo();
    case 'my':
      return AppLocalizationsMy();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
