// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'OHTK Mobile';

  @override
  String get loginTitle => 'Connectez-vous à votre compte';

  @override
  String get signupTitle => 'S\'inscrire';

  @override
  String get signupSubTitle =>
      'Veuillez saisir le code d\'invitation pour l\'inscription';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get forgotPasswordSubTitle =>
      'Veuillez entrer votre adresse e-mail et nous vous enverrons un lien de réinitialisation de mot de passe';

  @override
  String get changePasswordTitle => 'Changer le mot de passe';

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
  String get reportTitle => 'Rapport';

  @override
  String get reportTypeTitle => 'Type de rapport';

  @override
  String get reportDetailTitle => 'Détail du rapport';

  @override
  String get followupTitle => 'Suivi';

  @override
  String get followupDetailTitle => 'Détails du suivi';

  @override
  String get profileTitle => 'Profil';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get qrCodeLoginButton => 'CONNEXION QRCode';

  @override
  String get pickQrcodeImageButton => 'Choose QRCode image';

  @override
  String get getLoginQrcodeButton => 'my QR login';

  @override
  String get logoutButton => 'Se déconnecter';

  @override
  String get registerButton => 'Registre';

  @override
  String get forgotPasswordButton => 'Mot de passe oublié';

  @override
  String get messagesPageTitle => 'Messages';

  @override
  String get messagePageTitle => 'Message';

  @override
  String get formPageLabel => 'Page';

  @override
  String get backButton => 'Dos';

  @override
  String get formBackButton => 'dos';

  @override
  String get nextButton => 'Suivant';

  @override
  String get formNextButton => 'suivant';

  @override
  String get submitButton => 'Soumettre';

  @override
  String get confirmButton => 'Confirmer';

  @override
  String get confirmRegisterButton => 'Confirmer l\'inscription';

  @override
  String get sendButton => 'Envoyer';

  @override
  String get updateProfileButton => 'Mettre à jour le profil';

  @override
  String get confirmUpdate => 'Confirmer la mise à jour';

  @override
  String get profileUpdateSuccess => 'Profil mis à jour';

  @override
  String get passwordUpdatedSuccess =>
      'Votre mot de passe a été changé avec succès!';

  @override
  String get changePasswordButton => 'Changer le mot de passe';

  @override
  String get laguageLabel => 'Langue';

  @override
  String get serverLabel => 'Serveur';

  @override
  String get usernameLabel => 'Nom d\'utilisateur';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get newPasswordLabel => 'nouveau mot de passe';

  @override
  String get confirmPasswordLabel => 'Confirmez le mot de passe';

  @override
  String get invitationCodeLabel => 'code d\'invitation';

  @override
  String get firstNameLabel => 'Prénom';

  @override
  String get lastNameLabel => 'Nom de famille';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailHint => 'tester@gmail.com';

  @override
  String get telephoneLabel => 'Téléphone';

  @override
  String get addressLabel => 'Address';

  @override
  String get allReportTabLabel => 'Tous les rapports';

  @override
  String get myReportTabLabel => 'Mes rapports';

  @override
  String get detailTabLabel => 'Détail';

  @override
  String get commentTabLabel => 'Commentaire';

  @override
  String get followupTabLabel => 'Suivi';

  @override
  String get authorityNameLabel => 'Nom de l\'autorité';

  @override
  String get noFollowupReport => 'Aucun rapport de suivi';

  @override
  String get noComment => 'Aucun commentaire';

  @override
  String get noGpsProvided => 'No gps location provided';

  @override
  String get zeroReportLabel => 'Zéro rapport';

  @override
  String get zeroReportPillLabel => 'Zéro rapport';

  @override
  String get nothingToReportTitle => 'Rien à signaler cette semaine';

  @override
  String lastZeroReportLabel(String datetime) {
    return 'Dernier zéro rapport $datetime';
  }

  @override
  String get testModeLabel => 'Mode test';

  @override
  String get testModeBannerMessage =>
      'Le mode test est activé — les soumissions vont uniquement dans le bac à sable.';

  @override
  String offlineCachedListMessage(String date) {
    return 'Hors ligne · liste en cache du $date';
  }

  @override
  String get noReportTypesTitle => 'Aucun type de rapport disponible';

  @override
  String get noReportTypesHelper =>
      'Votre coordinateur n\'a pas encore publié de liste, ou la synchronisation n\'est pas terminée. Tirez pour rafraîchir, ou contactez votre chef de village.';

  @override
  String get tryAgainButton => 'Réessayer';

  @override
  String get adminToolsSectionLabel => 'Outils d\'administration';

  @override
  String get testDraftFormLabel => 'Tester un formulaire brouillon';

  @override
  String get testDraftFormHelper =>
      'Scannez un QR du tableau de bord web pour prévisualiser un type de rapport non publié.';

  @override
  String get formChromeBackLabel => 'Retour';

  @override
  String get formChromeNextLabel => 'Suivant';

  @override
  String get formChromeReviewLabel => 'Revoir';

  @override
  String get formChromeSubmitReportLabel => 'Envoyer le rapport';

  @override
  String get formChromeSubmitFollowupLabel => 'Envoyer le suivi';

  @override
  String formStepLabel(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get formSaveDraftAction => 'Enregistrer comme brouillon';

  @override
  String get formDraftSavedMessage =>
      'Brouillon enregistré — les photos et fichiers restent sur l\'appareil.';

  @override
  String get exitDialogTitle => 'Quitter sans envoyer ?';

  @override
  String get exitDialogBody =>
      'Vos réponses et photos jointes seront supprimées. Vous pouvez enregistrer un brouillon depuis le menu pour les conserver.';

  @override
  String get exitDialogDiscardButton => 'Supprimer et quitter';

  @override
  String get exitDialogKeepButton => 'Continuer à modifier';

  @override
  String get choiceOtherPlaceholder => 'Veuillez préciser';

  @override
  String get attachFileButton => 'Joindre un fichier';

  @override
  String get addAnotherSubformButton => 'Ajouter un autre';

  @override
  String get subformDeleteConfirmTitle => 'Supprimer l\'entrée ?';

  @override
  String get subformDeleteConfirmBody =>
      'Cette entrée sera retirée du formulaire.';

  @override
  String get subformDeleteConfirmAction => 'Supprimer';

  @override
  String get reviewHeaderEyebrow => 'VÉRIFIER ET ENVOYER';

  @override
  String get reviewHeaderTitle => 'Vérifiez votre rapport avant l\'envoi';

  @override
  String get authorityEyebrow => 'UNE DERNIÈRE CHOSE';

  @override
  String get authorityHelper =>
      'Nous l\'utilisons pour acheminer le rapport à la bonne équipe.';

  @override
  String get reviewEditButton => 'Modifier';

  @override
  String get reviewReminderBody =>
      'Une fois envoyé, ce rapport ne peut plus être modifié. Vérifiez le résumé ci-dessus avant l\'envoi.';

  @override
  String get reviewAccuracyConfirmLabel =>
      'I confirm that the information provided is accurate';

  @override
  String get reviewBackToFormButton => 'Retour au formulaire';

  @override
  String get recentSectionLabel => 'Récent';

  @override
  String get earlierSectionLabel => 'Plus tôt';

  @override
  String get noReportsTitle => 'Aucun rapport pour l\'instant';

  @override
  String get noReportsHelper =>
      'Appuyez sur le + vert ci-dessous pour créer votre premier rapport, ou envoyez un Zéro rapport s\'il n\'y a rien à signaler cette semaine.';

  @override
  String get newReportFabLabel => 'New report';

  @override
  String get descriptionSectionLabel => 'Description';

  @override
  String get noDescriptionProvided => 'Aucune description';

  @override
  String get photosSectionLabel => 'Photos';

  @override
  String get attachmentsSectionLabel => 'Pièces jointes';

  @override
  String get locationSectionLabel => 'Lieu';

  @override
  String get followUpFabLabel => 'Suivi';

  @override
  String get commentPlaceholder => 'Écrire un commentaire…';

  @override
  String get noCommentsTitle => 'Aucun commentaire';

  @override
  String get noCommentsHelper =>
      'Soyez le premier à commenter. Votre équipe recevra une notification.';

  @override
  String get noFollowupsTitle => 'Aucun suivi';

  @override
  String get noFollowupsHelper =>
      'Appuyez sur + pour ajouter le premier suivi — visite sur le terrain, résultat de labo ou mise à jour de statut.';

  @override
  String followupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suivis',
      one: '$count suivi',
    );
    return '$_temp0';
  }

  @override
  String get reportNotFoundTitle => 'Rapport introuvable';

  @override
  String get reportNotFoundHelper =>
      'Ce rapport a peut-être été supprimé, ou vous êtes hors ligne. Tirez pour rafraîchir, ou revenez à la liste.';

  @override
  String get backToIncidentsButton => 'Retour aux incidents';

  @override
  String get loadingLabel => 'Chargement…';

  @override
  String get testTag => 'Test';

  @override
  String zeroReportLastReportedMessage(String datetime) {
    return 'Signalé pour la dernière fois à $datetime';
  }

  @override
  String get zeroReportSubmitSuccess => 'Aucun rapport soumis';

  @override
  String get fieldUndefinedLocation => 'Aucun emplacement sélectionné';

  @override
  String get fieldUseCurrentLocation => 'Utiliser l\'emplacement actuel';

  @override
  String get fieldGettingLocation => 'Getting location…';

  @override
  String get fieldGettingLocationHint => 'This can take a few seconds';

  @override
  String get locationRationaleTitle => 'Allow location access?';

  @override
  String get locationRationaleBody =>
      'Location is used only when you choose to attach it to a report or center the map, so responders can find the site. We do not track you in the background.';

  @override
  String get locationRationaleContinue => 'Continue';

  @override
  String get locationRationaleNotNow => 'Not now';

  @override
  String get locationPermissionDenied => 'Location permission was denied';

  @override
  String get locationPermissionDeniedForeverTitle =>
      'Location permission blocked';

  @override
  String get locationPermissionDeniedForeverBody =>
      'Location access is blocked for this app. Open Settings and allow location, then try again.';

  @override
  String get locationOpenSettings => 'Open settings';

  @override
  String get locationServiceDisabledTitle => 'Location is turned off';

  @override
  String get locationTimeout =>
      'Could not get a GPS fix in time. Try again outdoors or check that location is enabled.';

  @override
  String get locationCouldNotGet => 'Could not get current location';

  @override
  String get locationCenterOnMe => 'Center on my location';

  @override
  String get authorityLabel => 'Autorité';

  @override
  String get incidentDate => 'Date de l\'incident';

  @override
  String get invalidQrcode => 'Invalid qrcode';

  @override
  String get invalidReportTypeQrcode => 'QRcode de type de rapport non valide';

  @override
  String get invalidFormValue => 'Valeur de formulaire invalide';

  @override
  String get simulateReportTitle => 'Simuler le rapport';

  @override
  String get closeSimulateReportButton => 'Fermer la simulation du rapport';

  @override
  String get consentButton => 'Je suis d\'accord';

  @override
  String get observationSubjectViewTitle => 'Sujet';

  @override
  String get observationSubjectDetailTabLabel => 'Détail';

  @override
  String get observationSubjectMonitoringTabLabel => 'Surveillance';

  @override
  String get observationSubjectMonitoringViewTitle => 'Surveillance du sujet';

  @override
  String get validateRequiredMsg => 'Ce champ est obligatoire';

  @override
  String dateFieldMaxErrorMsg(String max) {
    return 'doit être égal ou inférieur à $max';
  }

  @override
  String dateFieldMinErrorMsg(String min) {
    return 'doit être égal ou supérieur à $min';
  }

  @override
  String integerFieldMaxErrorMsg(String max) {
    return 'doit être égal ou inférieur à $max';
  }

  @override
  String integerFieldMinErrorMsg(String min) {
    return 'doit être égal ou supérieur à $min';
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
    return 'Le nombre doit être égal ou inférieur à $max';
  }

  @override
  String filesFieldMinErrorMsg(String min) {
    return 'Le nombre doit être égal ou supérieur à $min';
  }

  @override
  String filesFieldMaxSizeErrorMsg(String index, String maxSize) {
    return 'Taille du fichier : #$index doit être égal ou inférieur à $maxSize octets';
  }

  @override
  String filesFieldSupportedTypeErrorMsg(String index) {
    return 'Type de fichier : #$index ne sont pas pris en charge';
  }

  @override
  String get testFlag => 'Test';

  @override
  String get confirm => 'Êtes-vous sûr de continuer ?';

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
  String get confirmExit => 'Êtes-vous sûr de continuer ?';

  @override
  String get incidentInAuthority =>
      'Cet incident s\'est-il produit sous votre propre autorité ?';

  @override
  String get yesAsAccept => 'Oui';

  @override
  String get noAsReject => 'Non';

  @override
  String get ok => 'D\'ACCORD';

  @override
  String get cancel => 'Annuler';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get testModeOn => 'Le mode test est activé';

  @override
  String get loading => 'Chargement...';

  @override
  String get fieldRequired => 'Champ requis.';

  @override
  String get passwordMismatch =>
      'Le mot de passe ne correspond pas à confirmer le mot de passe';

  @override
  String get restartApp => 'L\'application doit être redémarrée.';

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
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeSubtitle => 'Set up before signing in';

  @override
  String get welcomeLanguageTitle => 'Language';

  @override
  String get welcomeServerTitle => 'Server';

  @override
  String get welcomeContinueButton => 'Continue';

  @override
  String get welcomeSavingLabel => 'Saving…';

  @override
  String get welcomeNoServersText => 'No servers available';

  @override
  String get welcomeCannotLoadServers => 'Cannot load servers';

  @override
  String get signInRegisterCta => 'Register as reporter';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signInQrCodeButton => 'QRCode Sign In';

  @override
  String get signInReturningEyebrow => 'Returning reporter';

  @override
  String get signInServerLabel => 'Server';

  @override
  String get signInChangeServerButton => 'Change';

  @override
  String get signInChangeLanguageTitle => 'Language';

  @override
  String get signInChangeLanguageHint => 'Single tap applies immediately';

  @override
  String get signInChangeServerTitle => 'Switch server';

  @override
  String get signInChangeServerHint =>
      'Different countries and orgs use different servers.';

  @override
  String get signInServerCurrentBadge => 'CURRENT';

  @override
  String get signInCancelButton => 'Cancel';

  @override
  String get signInConfirmServerButton => 'Switch server';

  @override
  String get registerTitle => 'Register reporter';

  @override
  String get registerStep1Eyebrow => 'Step 1 of 2';

  @override
  String get registerStep2Eyebrow => 'Step 2 of 2';

  @override
  String get registerCodeTitle => 'Enter invitation code';

  @override
  String get registerCodeSubtitle =>
      'Your training coordinator gave you a 7-digit code.';

  @override
  String get registerCodeError =>
      'That code wasn\'t recognized. Check with your coordinator.';

  @override
  String get registerCodeChecking => 'Checking code…';

  @override
  String get registerCodeContinue => 'Continue';

  @override
  String get registerCodeContinueChecking => 'Checking…';

  @override
  String get registerCodeHelp => 'Don\'t have a code?';

  @override
  String get registerCodeHelpLink => 'Talk to your coordinator';

  @override
  String get registerCodeAccepted => 'Code accepted';

  @override
  String get registerVillageLabel => 'Village';

  @override
  String get registerUsernameHint =>
      'Auto-suggested. You can change it now — but not later.';

  @override
  String get registerFirstNamePlaceholder => 'Your given name';

  @override
  String get registerLastNamePlaceholder => 'Your family name';

  @override
  String get registerPhonePlaceholder => '08x-xxx-xxxx';

  @override
  String get registerEmailHint =>
      'We made one for you. Tap to enter your real email if you have one.';

  @override
  String get registerAddressPlaceholder => 'House number, road';

  @override
  String get registerOptional => 'Optional';

  @override
  String get registerAuto => 'Auto';

  @override
  String get registerNoPasswordInfo =>
      'No password yet. You can set one in Settings after sign-in.';

  @override
  String get registerSubmit => 'Create account & sign in';

  @override
  String get registerCreating => 'Creating account…';

  @override
  String get genderLabel => 'Gender';

  @override
  String get ageLabel => 'Age';

  @override
  String get registerAgePlaceholder => 'Years';

  @override
  String get registerAgeInvalid => 'Enter an age between 1 and 120';

  @override
  String get registerGenderMale => 'Male';

  @override
  String get registerGenderFemale => 'Female';

  @override
  String get registerGenderOther => 'Other';

  @override
  String get registerGenderPlaceholder => 'Select gender';

  @override
  String get registerConsentLabel => 'I accept the terms and agreement';

  @override
  String get registerConsentRequired =>
      'You must accept the terms and agreement to register';

  @override
  String get registerConsentReadFirst =>
      'Please open and read the terms before accepting';

  @override
  String get registerConsentConfirmRead => 'I have read the terms';

  @override
  String get registerConsentSectionTitle => 'Privacy & terms';

  @override
  String get registerConsentSectionSubtitle =>
      'Required before you can register';

  @override
  String get registerConsentReadButton => 'Read privacy notice';

  @override
  String get registerConsentViewAgain => 'View again';

  @override
  String get registerConsentReviewed => 'Privacy notice reviewed';

  @override
  String get registerConsentSubmitBlocked => 'Accept the terms to continue';

  @override
  String get registerViewTerms => 'View terms';

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
