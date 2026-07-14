// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appName => 'OHTK Mobile';

  @override
  String get loginTitle => 'ลงชื่อเข้าใช้บัญชีของคุณ';

  @override
  String get signupTitle => 'ลงทะเบียนผ่าน Code';

  @override
  String get signupSubTitle => 'กรุณากรอก Invitation Code\nสำหรับใช้ลงทะเบียน';

  @override
  String get forgotPasswordTitle => 'ลืมรหัสผ่าน';

  @override
  String get forgotPasswordSubTitle =>
      'กรุณาระบุอีเมลเพื่อรับข้อความ\nสำหรับแก้ไขรหัสผ่าน';

  @override
  String get changePasswordTitle => 'เปลี่ยนรหัสผ่าน';

  @override
  String get incidentsTabTitle => 'รายงาน';

  @override
  String get observationsTabTitle => 'สังเกตุการณ์';

  @override
  String get censusTabTitle => 'สำมะโน';

  @override
  String get profileTabTitle => 'ผู้ใช้';

  @override
  String get caseTag => 'Case';

  @override
  String get reportTitle => 'รายงาน';

  @override
  String get reportTypeTitle => 'ประเภทรายงาน';

  @override
  String get reportDetailTitle => 'รายละเอียดรายงาน';

  @override
  String get followupTitle => 'ติดตาม';

  @override
  String get followupDetailTitle => 'รายละเอียดการติดตาม';

  @override
  String get profileTitle => 'แก้ไขโปรไฟล์';

  @override
  String get loginButton => 'เข้าสู่ระบบ';

  @override
  String get qrCodeLoginButton => 'เข้าสู่ระบบผ่าน QR Code';

  @override
  String get pickQrcodeImageButton => 'เลือกรูป QR Code';

  @override
  String get getLoginQrcodeButton => 'QR ของฉันเพื่อใช้เข้าสู่ระบบ';

  @override
  String get logoutButton => 'ออกจากระบบ';

  @override
  String get registerButton => 'ลงทะเบียนผ่าน Code';

  @override
  String get forgotPasswordButton => 'ลืมรหัสผ่าน';

  @override
  String get messagesPageTitle => 'Messages';

  @override
  String get messagePageTitle => 'Message';

  @override
  String get formPageLabel => 'Page';

  @override
  String get backButton => 'Back';

  @override
  String get formBackButton => 'ย้อนกลับ';

  @override
  String get nextButton => 'ไปขั้นตอนต่อไป';

  @override
  String get formNextButton => 'ต่อไป';

  @override
  String get submitButton => 'บันทึก';

  @override
  String get confirmButton => 'ยืนยัน';

  @override
  String get confirmRegisterButton => 'ยืนยันลงทะเบียน';

  @override
  String get sendButton => 'ส่ง';

  @override
  String get updateProfileButton => 'แก้ไขโปรไฟล์';

  @override
  String get confirmUpdate => 'ยืนยันการแก้ไข';

  @override
  String get profileUpdateSuccess => 'แก้ไขโปรไฟล์สำเร็จ';

  @override
  String get passwordUpdatedSuccess => 'เปลี่ยนรหัสผ่านเรียบร้อยแล้ว';

  @override
  String get changePasswordButton => 'แก้ไขรหัสผ่าน';

  @override
  String get laguageLabel => 'ภาษา';

  @override
  String get serverLabel => 'เซิร์ฟเวอร์';

  @override
  String get usernameLabel => 'ชื่อผู้ใช้';

  @override
  String get passwordLabel => 'รหัสผ่าน';

  @override
  String get newPasswordLabel => 'รหัสผ่านใหม่';

  @override
  String get confirmPasswordLabel => 'ยืนยันรหัสผ่าน';

  @override
  String get invitationCodeLabel => 'กรอกรหัสสำหรับลงทะเบียน';

  @override
  String get firstNameLabel => 'ชื่อจริง';

  @override
  String get lastNameLabel => 'นามสกุล';

  @override
  String get emailLabel => 'อีเมล';

  @override
  String get emailHint => 'tester@gmail.com';

  @override
  String get telephoneLabel => 'โทรศัพท์';

  @override
  String get addressLabel => 'ที่อยู่';

  @override
  String get allReportTabLabel => 'รายงานทั้งหมด';

  @override
  String get myReportTabLabel => 'รายงานของฉัน';

  @override
  String get detailTabLabel => 'รายละเอียด';

  @override
  String get commentTabLabel => 'ความคิดเห็น';

  @override
  String get followupTabLabel => 'การติดตาม';

  @override
  String get authorityNameLabel => 'หน่วยงาน';

  @override
  String get noFollowupReport => 'ไม่มีรายงานการติดตาม';

  @override
  String get noComment => 'ไม่มีความคิดเห็น';

  @override
  String get noGpsProvided => 'ไม่ได้ระบุสถานที่ gps';

  @override
  String get zeroReportLabel => 'รายงานไม่พบเหตุผิดปกติ';

  @override
  String get zeroReportPillLabel => 'Zero report';

  @override
  String get nothingToReportTitle => 'สัปดาห์นี้ไม่มีอะไรต้องรายงาน';

  @override
  String lastZeroReportLabel(String datetime) {
    return 'Zero report ล่าสุด $datetime';
  }

  @override
  String get testModeLabel => 'โหมดทดสอบ';

  @override
  String get testModeBannerMessage =>
      'โหมดทดสอบเปิดอยู่ — ข้อมูลที่ส่งจะไปที่กระบะทดสอบเท่านั้น';

  @override
  String offlineCachedListMessage(String date) {
    return 'ออฟไลน์ · แสดงรายการที่บันทึกไว้จาก $date';
  }

  @override
  String get noReportTypesTitle => 'ไม่มีประเภทรายงาน';

  @override
  String get noReportTypesHelper =>
      'ผู้ประสานงานยังไม่ได้เผยแพร่รายการ หรือการซิงค์ยังไม่เสร็จ ดึงเพื่อรีเฟรช หรือสอบถามผู้นำหมู่บ้าน';

  @override
  String get tryAgainButton => 'ลองอีกครั้ง';

  @override
  String get adminToolsSectionLabel => 'เครื่องมือผู้ดูแล';

  @override
  String get testDraftFormLabel => 'ทดสอบฟอร์มร่าง';

  @override
  String get testDraftFormHelper =>
      'สแกน QR จากแดชบอร์ดเว็บเพื่อดูตัวอย่างประเภทรายงานที่ยังไม่ได้เผยแพร่';

  @override
  String get formChromeBackLabel => 'ย้อนกลับ';

  @override
  String get formChromeNextLabel => 'ถัดไป';

  @override
  String get formChromeReviewLabel => 'ตรวจสอบ';

  @override
  String get formChromeSubmitReportLabel => 'ส่งรายงาน';

  @override
  String get formChromeSubmitFollowupLabel => 'ส่งการติดตาม';

  @override
  String formStepLabel(int current, int total) {
    return 'ขั้นตอนที่ $current จาก $total';
  }

  @override
  String get formSaveDraftAction => 'บันทึกเป็นแบบร่าง';

  @override
  String get formDraftSavedMessage =>
      'บันทึกแบบร่างแล้ว — ภาพและไฟล์ถูกเก็บไว้ในเครื่อง';

  @override
  String get exitDialogTitle => 'ออกโดยไม่ส่งใช่ไหม';

  @override
  String get exitDialogBody =>
      'คำตอบและภาพที่แนบไว้จะถูกลบ คุณสามารถบันทึกเป็นแบบร่างจากเมนูเพื่อเก็บไว้';

  @override
  String get exitDialogDiscardButton => 'ลบและออก';

  @override
  String get exitDialogKeepButton => 'ทำต่อ';

  @override
  String get choiceOtherPlaceholder => 'โปรดระบุ';

  @override
  String get attachFileButton => 'แนบไฟล์';

  @override
  String get addAnotherSubformButton => 'เพิ่มอีก';

  @override
  String get subformDeleteConfirmTitle => 'ลบรายการนี้?';

  @override
  String get subformDeleteConfirmBody => 'รายการนี้จะถูกลบออกจากแบบฟอร์ม';

  @override
  String get subformDeleteConfirmAction => 'ลบ';

  @override
  String get reviewHeaderEyebrow => 'ทบทวนและส่ง';

  @override
  String get reviewHeaderTitle => 'ตรวจสอบรายงานก่อนส่ง';

  @override
  String get authorityEyebrow => 'อีกหนึ่งข้อ';

  @override
  String get authorityHelper => 'ใช้สำหรับส่งรายงานไปยังทีมที่รับผิดชอบ';

  @override
  String get reviewEditButton => 'แก้ไข';

  @override
  String get reviewReminderBody =>
      'หลังส่งรายงานแล้วจะไม่สามารถแก้ไขได้ กรุณาตรวจสอบสรุปด้านบนให้เรียบร้อยก่อนส่ง';

  @override
  String get reviewBackToFormButton => 'กลับไปแก้แบบฟอร์ม';

  @override
  String get recentSectionLabel => 'ล่าสุด';

  @override
  String get earlierSectionLabel => 'ก่อนหน้านี้';

  @override
  String get noReportsTitle => 'ยังไม่มีรายงาน';

  @override
  String get noReportsHelper =>
      'กดปุ่ม + สีเขียวด้านล่างเพื่อสร้างรายงานฉบับแรก หรือส่งรายงานปกติหากไม่มีเหตุการณ์ในสัปดาห์นี้';

  @override
  String get newReportFabLabel => 'รายงานใหม่';

  @override
  String get descriptionSectionLabel => 'รายละเอียด';

  @override
  String get noDescriptionProvided => 'ไม่มีรายละเอียด';

  @override
  String get photosSectionLabel => 'ภาพถ่าย';

  @override
  String get attachmentsSectionLabel => 'เอกสารแนบ';

  @override
  String get locationSectionLabel => 'ตำแหน่ง';

  @override
  String get followUpFabLabel => 'ติดตามผล';

  @override
  String get commentPlaceholder => 'เขียนความคิดเห็น…';

  @override
  String get noCommentsTitle => 'ยังไม่มีความคิดเห็น';

  @override
  String get noCommentsHelper =>
      'เป็นคนแรกที่แสดงความคิดเห็น ทีมงานจะได้รับการแจ้งเตือน';

  @override
  String get noFollowupsTitle => 'ยังไม่มีการติดตามผล';

  @override
  String get noFollowupsHelper =>
      'กด + เพื่อเพิ่มการติดตามผลครั้งแรก เช่น การลงพื้นที่ ผลตรวจ หรือสถานะล่าสุด';

  @override
  String followupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ติดตามผล $count รายการ',
    );
    return '$_temp0';
  }

  @override
  String get reportNotFoundTitle => 'ไม่พบรายงานนี้';

  @override
  String get reportNotFoundHelper =>
      'รายงานอาจถูกลบไปแล้ว หรือคุณอาจออฟไลน์อยู่ ดึงเพื่อรีเฟรชหรือกลับไปยังรายการ';

  @override
  String get backToIncidentsButton => 'กลับไปหน้ารายงาน';

  @override
  String get loadingLabel => 'กำลังโหลด…';

  @override
  String get testTag => 'ทดสอบ';

  @override
  String zeroReportLastReportedMessage(String datetime) {
    return 'รายงานครั้งสุดท้ายเมื่อวันที่ $datetime';
  }

  @override
  String get zeroReportSubmitSuccess => 'ส่งรายงานไม่พบเหตุผิดปกติสำเร็จ';

  @override
  String get fieldUndefinedLocation => 'ยังไม่ระบุพิกัด';

  @override
  String get fieldUseCurrentLocation => 'ใช้ตำแหน่งปัจจุบัน';

  @override
  String get authorityLabel => 'หน่วยงาน';

  @override
  String get incidentDate => 'วันที่เกิดเหตุ';

  @override
  String get invalidQrcode => 'qrcode ไม่ถูกต้อง';

  @override
  String get invalidReportTypeQrcode => 'qrcode ไม่ถูกต้องสำหรับประเภทรายงาน';

  @override
  String get invalidFormValue => 'ค่าที่ป้อนไม่ถูกต้อง';

  @override
  String get simulateReportTitle => 'จำลองแบบรายงาน';

  @override
  String get closeSimulateReportButton => 'ปิดการจำลองรายงาน';

  @override
  String get consentButton => 'ยินยอม';

  @override
  String get observationSubjectViewTitle => 'หัวเรื่อง';

  @override
  String get observationSubjectDetailTabLabel => 'รายละเอียด';

  @override
  String get observationSubjectMonitoringTabLabel => 'การเฝ้าดูติดตาม';

  @override
  String get observationSubjectMonitoringViewTitle =>
      'หัวเรื่องการเฝ้าดูติดตาม';

  @override
  String get validateRequiredMsg => 'กรุณาระบุค่า';

  @override
  String dateFieldMaxErrorMsg(String max) {
    return 'ต้องน้อยกว่า $max';
  }

  @override
  String dateFieldMinErrorMsg(String min) {
    return 'ต้องมากกว่า $min';
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
    return 'Number of files must be equal or lesser than $max';
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
  String get testFlag => 'ทดสอบ';

  @override
  String get confirm => 'ต้องการออกจากหน้ารายงานหรือไม่';

  @override
  String get confirmCheckReport =>
      'รายงานที่ส่งแล้วจะไม่สามารถแก้ไขได้อีก กรุณาตรวจสอบความถูกต้องของข้อมูลก่อนส่ง';

  @override
  String get submitReportMessage => 'กดปุ่มบันทึกเพื่อส่งรายงาน';

  @override
  String get reportDataSummary => 'สรุปรายงาน';

  @override
  String get reportDataSummaryNotFound =>
      'ไม่พบเนื้อหาการสรุปสำหรับประเภทรายงานนี้';

  @override
  String get confirmExit => 'ต้องการออกจากหน้าจอหรือไม่';

  @override
  String get incidentInAuthority =>
      'พื้นที่เกิดเหตุอยู่ในหน่วยงานสังกัดของท่านหรือไม่';

  @override
  String get yesAsAccept => 'ใช่';

  @override
  String get noAsReject => 'ไม่ใช่';

  @override
  String get ok => 'ตกลง';

  @override
  String get cancel => 'Cancel';

  @override
  String get yes => 'ตกลง';

  @override
  String get no => 'ยกเลิก';

  @override
  String get testModeOn => 'กำลังเปิดใช้งานโหมดทดสอบ';

  @override
  String get loading => 'Loading...';

  @override
  String get fieldRequired => 'กรุณากรอกข้อมูล';

  @override
  String get passwordMismatch => 'รหัสผ่านไม่ถูกต้อง';

  @override
  String get restartApp => 'แอปพลิเคชันจะทำการรีสตาร์ท';

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
  String get loadMore => 'ดูเพิ่มเติม';

  @override
  String get welcomeTitle => 'ยินดีต้อนรับ';

  @override
  String get welcomeSubtitle => 'ตั้งค่าก่อนเริ่ม';

  @override
  String get welcomeLanguageTitle => 'ภาษา';

  @override
  String get welcomeServerTitle => 'เซิร์ฟเวอร์';

  @override
  String get welcomeContinueButton => 'ดำเนินการต่อ';

  @override
  String get welcomeSavingLabel => 'กำลังบันทึก…';

  @override
  String get welcomeNoServersText => 'ไม่มีเซิร์ฟเวอร์ให้เลือก';

  @override
  String get welcomeCannotLoadServers => 'โหลดข้อมูลเซิร์ฟเวอร์ไม่สำเร็จ';

  @override
  String get signInRegisterCta => 'ลงทะเบียนเป็นผู้รายงาน';

  @override
  String get signInButton => 'เข้าสู่ระบบ';

  @override
  String get signInQrCodeButton => 'เข้าระบบด้วย QRCode';

  @override
  String get signInReturningEyebrow => 'ผู้รายงานเดิม';

  @override
  String get signInServerLabel => 'เซิร์ฟเวอร์';

  @override
  String get signInChangeServerButton => 'เปลี่ยน';

  @override
  String get signInChangeLanguageTitle => 'ภาษา';

  @override
  String get signInChangeLanguageHint => 'แตะเพื่อใช้งานทันที';

  @override
  String get signInChangeServerTitle => 'เปลี่ยนเซิร์ฟเวอร์';

  @override
  String get signInChangeServerHint =>
      'ประเทศและองค์กรต่าง ๆ ใช้เซิร์ฟเวอร์ต่างกัน';

  @override
  String get signInServerCurrentBadge => 'ปัจจุบัน';

  @override
  String get signInCancelButton => 'ยกเลิก';

  @override
  String get signInConfirmServerButton => 'เปลี่ยนเซิร์ฟเวอร์';

  @override
  String get registerTitle => 'ลงทะเบียนผู้รายงาน';

  @override
  String get registerStep1Eyebrow => 'ขั้นตอนที่ 1 จาก 2';

  @override
  String get registerStep2Eyebrow => 'ขั้นตอนที่ 2 จาก 2';

  @override
  String get registerCodeTitle => 'กรอกรหัสเชิญ';

  @override
  String get registerCodeSubtitle => 'ผู้ประสานงานอบรมจะให้รหัส 7 หลักกับคุณ';

  @override
  String get registerCodeError => 'รหัสไม่ถูกต้อง โปรดติดต่อผู้ประสานงาน';

  @override
  String get registerCodeChecking => 'กำลังตรวจสอบรหัส…';

  @override
  String get registerCodeContinue => 'ถัดไป';

  @override
  String get registerCodeContinueChecking => 'กำลังตรวจสอบ…';

  @override
  String get registerCodeHelp => 'ยังไม่มีรหัส?';

  @override
  String get registerCodeHelpLink => 'ติดต่อผู้ประสานงาน';

  @override
  String get registerCodeAccepted => 'รหัสถูกต้อง';

  @override
  String get registerVillageLabel => 'หมู่บ้าน';

  @override
  String get registerUsernameHint =>
      'ระบบสร้างให้แล้ว แก้ไขได้ตอนนี้เท่านั้น ภายหลังจะแก้ไม่ได้';

  @override
  String get registerFirstNamePlaceholder => 'ชื่อจริง';

  @override
  String get registerLastNamePlaceholder => 'นามสกุล';

  @override
  String get registerPhonePlaceholder => '08x-xxx-xxxx';

  @override
  String get registerEmailHint =>
      'ระบบสร้างอีเมลให้ แตะเพื่อใส่อีเมลจริงของคุณถ้ามี';

  @override
  String get registerAddressPlaceholder => 'บ้านเลขที่ ถนน';

  @override
  String get registerOptional => 'ไม่บังคับ';

  @override
  String get registerAuto => 'อัตโนมัติ';

  @override
  String get registerNoPasswordInfo =>
      'ยังไม่ต้องตั้งรหัสผ่าน ตั้งภายหลังได้ที่หน้าตั้งค่า';

  @override
  String get registerSubmit => 'สร้างบัญชีและเข้าระบบ';

  @override
  String get registerCreating => 'กำลังสร้างบัญชี…';

  @override
  String get profileSectionContactInfo => 'ข้อมูลติดต่อ';

  @override
  String get profileLabelActiveVillage => 'หมู่บ้านที่ใช้งานอยู่';

  @override
  String get profileValueNotProvided => 'ยังไม่ได้กรอก';

  @override
  String get profileValueNotAssigned => 'ยังไม่ได้มอบหมาย';

  @override
  String get profileCompleteContactTitle => 'กรอกข้อมูลติดต่อ';

  @override
  String get profileCompleteContactBody =>
      'เพื่อให้ทีมผู้รับผิดชอบติดต่อกลับเกี่ยวกับรายงานของคุณได้';

  @override
  String get signOutConfirmTitle => 'ออกจากระบบ OHTK?';

  @override
  String get signOutConfirmBody =>
      'คุณจะต้องเข้าสู่ระบบใหม่เพื่อดูรายงานของคุณ';

  @override
  String get qrDialogEyebrow => 'รหัส QR ของคุณ';

  @override
  String get qrDialogTitle => 'บันทึกเพื่อใช้ภายหลัง';

  @override
  String get qrDialogBody =>
      'บันทึกภาพนี้ลงในโทรศัพท์ของคุณ ครั้งหน้าที่คุณเข้าสู่ระบบ — บนเครื่องนี้หรือเครื่องใหม่ — เลือก \"เข้าสู่ระบบด้วย QR\" และแสดงรหัสนี้ให้กล้อง';

  @override
  String get qrLoading => 'กำลังโหลด';

  @override
  String get qrKeepPrivate => 'เก็บภาพนี้เป็นส่วนตัว';

  @override
  String get qrSaveToGallery => 'บันทึกในแกลเลอรี';

  @override
  String get qrSaveSuccess => 'บันทึกลงแกลเลอรีเรียบร้อย';

  @override
  String get qrSaveFailed => 'บันทึกรหัส QR ไม่สำเร็จ';

  @override
  String get avatarSheetTitle => 'อัปเดตรูปโปรไฟล์';

  @override
  String get avatarSheetSubtitle =>
      'เลือกภาพสี่เหลี่ยม — คนอื่นจะเห็นในรายงานของคุณ';

  @override
  String get avatarSheetTakePhoto => 'ถ่ายภาพ';

  @override
  String get avatarSheetChooseGallery => 'เลือกจากแกลเลอรี';

  @override
  String get villageSheetTitle => 'เลือกหมู่บ้านที่ใช้งาน';

  @override
  String get villageSheetBody => 'รายงานใหม่จะถูกบันทึกไว้ที่หมู่บ้านนี้';

  @override
  String get profileFormReadonlyEyebrow => 'ผู้ดูแลกำหนด · แก้ไขไม่ได้';

  @override
  String get profilePhoneOptionalHelper =>
      'ใช้สำหรับติดต่อเกี่ยวกับรายงานของคุณ';

  @override
  String get passwordIntroBody =>
      'ใช้รหัสที่จำง่ายก็พอ — คุณใช้ไม่บ่อย ขอแค่ไม่ลืม';

  @override
  String get passwordHelperTip => 'เคล็ดลับ: ใช้คำหรือตัวเลขที่คุณจำได้ง่าย';

  @override
  String get villageEyebrow => 'หมู่บ้าน';

  @override
  String get censusHubHelperMulti =>
      'เลือกสำมะโนที่ต้องการอัปเดต แต่ละรายการจะถูกบันทึกแยกกัน';

  @override
  String get censusHubHelperSingle => 'เลือกเพื่อปรับสำมะโนนี้ให้เป็นปัจจุบัน';

  @override
  String censusCachedDefinitionNotice(int version) {
    return 'ออฟไลน์หรือไม่สามารถรีเฟรชได้ กำลังแสดงแบบฟอร์มที่บันทึกไว้เวอร์ชัน v$version.';
  }

  @override
  String get censusOldSnapshotMatchingNotice =>
      'การส่งครั้งก่อนใช้แบบฟอร์มเวอร์ชันเก่า ค่าที่ตรงกันถูกเติมไว้แล้ว';

  @override
  String get censusOldSnapshotBlankNotice =>
      'การส่งครั้งก่อนใช้แบบฟอร์มเวอร์ชันเก่า โปรดกรอกค่าปัจจุบันสำหรับเวอร์ชันนี้';

  @override
  String get censusNoPreviousSubmissionInstruction =>
      'ยังไม่เคยส่งสำมะโน โปรดกรอกค่าปัจจุบันในแต่ละแถว';

  @override
  String get censusUpdatePreviousSubmissionInstruction =>
      'อัปเดตค่าที่เปลี่ยนแปลง ตัวเลขจากการส่งครั้งล่าสุดถูกเติมไว้แล้ว';

  @override
  String get censusDefinitionChangedMessage =>
      'แบบฟอร์มสำมะโนเปลี่ยนระหว่างที่กำลังกรอก โปรดโหลดแบบฟอร์มใหม่เพื่อให้มีรายการล่าสุด แล้วส่งอีกครั้ง';

  @override
  String get censusReloadFormAction => 'โหลดแบบฟอร์มใหม่';

  @override
  String get censusFormReloadedMessage => 'โหลดแบบฟอร์มสำมะโนใหม่แล้ว';

  @override
  String get censusFormReloadedPartialMessage =>
      'โหลดแบบฟอร์มสำมะโนใหม่แล้ว บางค่าต้องกรอกใหม่';

  @override
  String get censusAnimalTitle => 'สำมะโนสัตว์';

  @override
  String get censusHumanTitle => 'สำมะโนประชากร';

  @override
  String get censusGenericTitle => 'สำมะโน';

  @override
  String get censusUnavailableTitle => 'ไม่สามารถใช้สำมะโนได้';

  @override
  String get censusUnavailableMessage =>
      'บัญชีนี้ไม่ได้รับมอบหมายให้อัปเดตสำมะโนของหมู่บ้าน';

  @override
  String get censusInactiveTitle => 'This census is inactive';

  @override
  String get censusInactiveMessage =>
      'This census form is currently turned off by your coordinator. Go back to choose an available census.';

  @override
  String get censusLoadFailedTitle => 'โหลดสำมะโนไม่สำเร็จ';

  @override
  String get censusUnsupportedTitle => 'สำมะโนนี้ต้องใช้แอปเวอร์ชันใหม่กว่า';

  @override
  String get censusUnsupportedMessage =>
      'สำมะโนหมู่บ้านถูกอัปเดตแล้วและแอป OHTK Mobile เวอร์ชันนี้ยังไม่รองรับ โปรดอัปเดตแอปแล้วลองอีกครั้ง';

  @override
  String get censusNoRowsConfigured => 'ยังไม่ได้กำหนดแถวสำมะโนที่ใช้งาน';

  @override
  String get censusNoSetupTitle => 'ยังไม่ได้ตั้งค่าสำมะโน';

  @override
  String get censusNoSetupMessage =>
      'หมู่บ้านนี้ยังไม่มีแบบฟอร์มสำมะโนที่ใช้งาน';

  @override
  String censusLastUpdatedLabel(String date) {
    return 'อัปเดตล่าสุด $date';
  }

  @override
  String get censusNotSubmittedYet => 'ยังไม่ได้ส่ง';

  @override
  String get censusNoVillage => 'ไม่มีหมู่บ้าน';

  @override
  String get censusNoSubmittedYet => 'ยังไม่ได้ส่งสำมะโน';

  @override
  String get censusEditedBadge => 'แก้ไขแล้ว';

  @override
  String get censusHouseholdSummaryTitle => 'สรุปครัวเรือนของหมู่บ้าน';

  @override
  String get censusVillageHouseholdQuantityLabel => 'จำนวนครัวเรือนในหมู่บ้าน';

  @override
  String get censusAnimalHouseholdQuantityLabel => 'จำนวนครัวเรือนที่มีสัตว์';

  @override
  String get censusAnimalHouseholdsExceedVillageError =>
      'จำนวนครัวเรือนที่มีสัตว์ต้องไม่เกินจำนวนครัวเรือนในหมู่บ้าน';

  @override
  String get censusSaveCurrentButton => 'บันทึกสำมะโนปัจจุบัน';

  @override
  String get censusSubmittedMessage => 'ส่งสำมะโนแล้ว';

  @override
  String get censusDraftSavedNotice => 'บันทึกร่างไว้ในอุปกรณ์นี้แล้ว';

  @override
  String get censusDiscardDraftAction => 'ทิ้งร่าง';

  @override
  String get censusDraftDiscardedMessage => 'ทิ้งร่างแล้ว';

  @override
  String get censusVillageUnavailableError => 'ไม่สามารถใช้สำมะโนหมู่บ้านได้';

  @override
  String get censusUnsupportedError =>
      'แอปเวอร์ชันนี้ยังไม่รองรับแบบฟอร์มสำมะโนนี้';

  @override
  String get censusUnknownKindError => 'ไม่รู้จักชนิดสำมะโน';

  @override
  String censusInvalidNumberError(String label) {
    return 'กรอกจำนวนเต็มที่ไม่ติดลบสำหรับ $label';
  }

  @override
  String get notificationsTitle => 'การแจ้งเตือน';

  @override
  String get notificationDetailTitle => 'ข้อความ';

  @override
  String get reportSubmitSuccess => 'ส่งรายงานสำเร็จ';
}
