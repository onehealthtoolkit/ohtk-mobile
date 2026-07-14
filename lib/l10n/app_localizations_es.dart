// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'OHTK Mobile';

  @override
  String get loginTitle => 'Ingrese a su cuenta';

  @override
  String get signupTitle => 'Inscribirse';

  @override
  String get signupSubTitle =>
      'Por favor ingrese el código de invitación para registrarse';

  @override
  String get forgotPasswordTitle => 'Has olvidado tu contraseña';

  @override
  String get forgotPasswordSubTitle =>
      'Ingrese su dirección de correo electrónico y le enviaremos un enlace para restablecer su contraseña.';

  @override
  String get changePasswordTitle => 'Cambiar la contraseña';

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
  String get reportTitle => 'Informe';

  @override
  String get reportTypeTitle => 'Tipo de informe';

  @override
  String get reportDetailTitle => 'Detalle del informe';

  @override
  String get followupTitle => 'Hacer un seguimiento';

  @override
  String get followupDetailTitle => 'Detalle de seguimiento';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get loginButton => 'Acceso';

  @override
  String get qrCodeLoginButton => 'Código QR INICIAR SESIÓN';

  @override
  String get pickQrcodeImageButton => 'Choose QRCode image';

  @override
  String get getLoginQrcodeButton => 'my QR login';

  @override
  String get logoutButton => 'Cerrar sesión';

  @override
  String get registerButton => 'Registro';

  @override
  String get forgotPasswordButton => 'Has olvidado tu contraseña';

  @override
  String get messagesPageTitle => 'Messages';

  @override
  String get messagePageTitle => 'Message';

  @override
  String get formPageLabel => 'Page';

  @override
  String get backButton => 'Atrás';

  @override
  String get formBackButton => 'atrás';

  @override
  String get nextButton => 'Próximo';

  @override
  String get formNextButton => 'próximo';

  @override
  String get submitButton => 'Entregar';

  @override
  String get confirmButton => 'Confirmar';

  @override
  String get confirmRegisterButton => 'Confirmar Registro';

  @override
  String get sendButton => 'Enviar';

  @override
  String get updateProfileButton => 'Actualización del perfil';

  @override
  String get confirmUpdate => 'Confirmar actualización';

  @override
  String get profileUpdateSuccess => 'Perfil actualizado';

  @override
  String get passwordUpdatedSuccess =>
      '¡Su contraseña ha sido cambiada exitosamente!';

  @override
  String get changePasswordButton => 'Cambiar la contraseña';

  @override
  String get laguageLabel => 'Idioma';

  @override
  String get serverLabel => 'Servidor';

  @override
  String get usernameLabel => 'Nombre de usuario';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get confirmPasswordLabel => 'Confirmar Contraseña';

  @override
  String get invitationCodeLabel => 'código de invitación';

  @override
  String get firstNameLabel => 'Nombre de pila';

  @override
  String get lastNameLabel => 'Apellido';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailHint => 'tester@gmail.com';

  @override
  String get telephoneLabel => 'Teléfono';

  @override
  String get addressLabel => 'Address';

  @override
  String get allReportTabLabel => 'Todos los informes';

  @override
  String get myReportTabLabel => 'Mis informes';

  @override
  String get detailTabLabel => 'Detalle';

  @override
  String get commentTabLabel => 'Comentario';

  @override
  String get followupTabLabel => 'Hacer un seguimiento';

  @override
  String get authorityNameLabel => 'Nombre de la autoridad';

  @override
  String get noFollowupReport => 'Sin informe de seguimiento';

  @override
  String get noComment => 'Sin comentarios';

  @override
  String get noGpsProvided => 'No gps location provided';

  @override
  String get zeroReportLabel => 'Informe cero';

  @override
  String get zeroReportPillLabel => 'Informe cero';

  @override
  String get nothingToReportTitle => 'Nada que informar esta semana';

  @override
  String lastZeroReportLabel(String datetime) {
    return 'Último informe cero $datetime';
  }

  @override
  String get testModeLabel => 'Modo de prueba';

  @override
  String get testModeBannerMessage =>
      'El modo de prueba está activado — los envíos van solo al entorno de pruebas.';

  @override
  String offlineCachedListMessage(String date) {
    return 'Sin conexión · mostrando lista guardada del $date';
  }

  @override
  String get noReportTypesTitle => 'No hay tipos de informe disponibles';

  @override
  String get noReportTypesHelper =>
      'Tu coordinador aún no ha publicado una lista, o la sincronización no ha terminado. Desliza para actualizar o contacta al líder de tu pueblo.';

  @override
  String get tryAgainButton => 'Reintentar';

  @override
  String get adminToolsSectionLabel => 'Herramientas de administrador';

  @override
  String get testDraftFormLabel => 'Probar formulario borrador';

  @override
  String get testDraftFormHelper =>
      'Escanea un QR del panel web para previsualizar un tipo de informe no publicado.';

  @override
  String get formChromeBackLabel => 'Atrás';

  @override
  String get formChromeNextLabel => 'Siguiente';

  @override
  String get formChromeReviewLabel => 'Revisar';

  @override
  String get formChromeSubmitReportLabel => 'Enviar informe';

  @override
  String get formChromeSubmitFollowupLabel => 'Enviar seguimiento';

  @override
  String formStepLabel(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get formSaveDraftAction => 'Guardar borrador';

  @override
  String get formDraftSavedMessage =>
      'Borrador guardado: las fotos y archivos siguen en este dispositivo.';

  @override
  String get exitDialogTitle => '¿Salir sin enviar?';

  @override
  String get exitDialogBody =>
      'Tus respuestas y fotos adjuntas se descartarán. Puedes guardar un borrador desde el menú para conservarlas.';

  @override
  String get exitDialogDiscardButton => 'Descartar y salir';

  @override
  String get exitDialogKeepButton => 'Seguir editando';

  @override
  String get choiceOtherPlaceholder => 'Por favor especifique';

  @override
  String get attachFileButton => 'Adjuntar archivo';

  @override
  String get addAnotherSubformButton => 'Añadir otro';

  @override
  String get subformDeleteConfirmTitle => '¿Eliminar entrada?';

  @override
  String get subformDeleteConfirmBody =>
      'Esta entrada se eliminará del formulario.';

  @override
  String get subformDeleteConfirmAction => 'Eliminar';

  @override
  String get reviewHeaderEyebrow => 'REVISAR Y ENVIAR';

  @override
  String get reviewHeaderTitle => 'Revisa el informe antes de enviarlo';

  @override
  String get authorityEyebrow => 'UNA COSA MÁS';

  @override
  String get authorityHelper =>
      'Lo usamos para enrutar el informe al equipo responsable.';

  @override
  String get reviewEditButton => 'Editar';

  @override
  String get reviewReminderBody =>
      'Una vez enviado, este informe no se puede editar. Verifica el resumen anterior antes de enviar.';

  @override
  String get reviewBackToFormButton => 'Volver al formulario';

  @override
  String get recentSectionLabel => 'Reciente';

  @override
  String get earlierSectionLabel => 'Antes';

  @override
  String get noReportsTitle => 'Aún no hay informes';

  @override
  String get noReportsHelper =>
      'Toca el + verde para crear tu primer informe, o envía un Informe cero si no hay nada que reportar esta semana.';

  @override
  String get newReportFabLabel => 'New report';

  @override
  String get descriptionSectionLabel => 'Descripción';

  @override
  String get noDescriptionProvided => 'Sin descripción';

  @override
  String get photosSectionLabel => 'Fotos';

  @override
  String get attachmentsSectionLabel => 'Adjuntos';

  @override
  String get locationSectionLabel => 'Ubicación';

  @override
  String get followUpFabLabel => 'Seguimiento';

  @override
  String get commentPlaceholder => 'Escribe un comentario…';

  @override
  String get noCommentsTitle => 'Sin comentarios';

  @override
  String get noCommentsHelper =>
      'Sé el primero en comentar. Tu equipo recibirá una notificación.';

  @override
  String get noFollowupsTitle => 'Sin seguimientos';

  @override
  String get noFollowupsHelper =>
      'Toca + para añadir el primer seguimiento — visita de campo, resultado de laboratorio o actualización de estado.';

  @override
  String followupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seguimientos',
      one: '$count seguimiento',
    );
    return '$_temp0';
  }

  @override
  String get reportNotFoundTitle => 'Informe no encontrado';

  @override
  String get reportNotFoundHelper =>
      'Este informe puede haber sido eliminado, o estás sin conexión. Desliza para recargar, o vuelve a la lista.';

  @override
  String get backToIncidentsButton => 'Volver a incidentes';

  @override
  String get loadingLabel => 'Cargando…';

  @override
  String get testTag => 'Prueba';

  @override
  String zeroReportLastReportedMessage(String datetime) {
    return 'Reportado por última vez el $datetime';
  }

  @override
  String get zeroReportSubmitSuccess => 'Informe cero enviado';

  @override
  String get fieldUndefinedLocation => 'Ninguna ubicación seleccionada';

  @override
  String get fieldUseCurrentLocation => 'Usar ubicación actual';

  @override
  String get authorityLabel => 'Autoridad';

  @override
  String get incidentDate => 'Fecha del incidente';

  @override
  String get invalidQrcode => 'Invalid qrcode';

  @override
  String get invalidReportTypeQrcode =>
      'Código QR de tipo de informe no válido';

  @override
  String get invalidFormValue => 'Valor de formulario no válido';

  @override
  String get simulateReportTitle => 'Simular informe';

  @override
  String get closeSimulateReportButton => 'Cerrar simulación de informe';

  @override
  String get consentButton => 'Estoy de acuerdo';

  @override
  String get observationSubjectViewTitle => 'Sujeto';

  @override
  String get observationSubjectDetailTabLabel => 'Detalle';

  @override
  String get observationSubjectMonitoringTabLabel => 'Supervisión';

  @override
  String get observationSubjectMonitoringViewTitle => 'Seguimiento de sujetos';

  @override
  String get validateRequiredMsg => 'Este campo es obligatorio';

  @override
  String dateFieldMaxErrorMsg(String max) {
    return 'debe ser igual o menor que $max';
  }

  @override
  String dateFieldMinErrorMsg(String min) {
    return 'debe ser igual o mayor que $min';
  }

  @override
  String integerFieldMaxErrorMsg(String max) {
    return 'debe ser igual o menor que $max';
  }

  @override
  String integerFieldMinErrorMsg(String min) {
    return 'debe ser igual o mayor que $min';
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
    return 'El número de archivos debe ser igual o menor que $max';
  }

  @override
  String filesFieldMinErrorMsg(String min) {
    return 'El número de archivos debe ser igual o mayor que $min';
  }

  @override
  String filesFieldMaxSizeErrorMsg(String index, String maxSize) {
    return 'Tamaño del archivo: #$index debe ser igual o menor que $maxSize bytes';
  }

  @override
  String filesFieldSupportedTypeErrorMsg(String index) {
    return 'Tipo de archivo: #$index no son compatibles';
  }

  @override
  String get testFlag => 'Test';

  @override
  String get confirm => '¿Estás seguro de continuar?';

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
  String get confirmExit => '¿Estás seguro de continuar?';

  @override
  String get incidentInAuthority =>
      '¿Este incidente ocurrió bajo su propia autoridad?';

  @override
  String get yesAsAccept => 'Sí';

  @override
  String get noAsReject => 'No';

  @override
  String get ok => 'DE ACUERDO';

  @override
  String get cancel => 'Cancelar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get testModeOn => 'El modo de prueba está activado.';

  @override
  String get loading => 'Cargando...';

  @override
  String get fieldRequired => 'Se requiere campo.';

  @override
  String get passwordMismatch =>
      'La contraseña no coincide. Confirmar contraseña.';

  @override
  String get restartApp => 'Es necesario reiniciar la aplicación.';

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
