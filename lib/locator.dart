import 'dart:ui';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/services/api/auth_api.dart';
import 'package:podd_app/services/api/comment_api.dart';
import 'package:podd_app/services/api/configuration_api.dart';
import 'package:podd_app/services/api/file_api.dart';
import 'package:podd_app/services/api/forgot_password_api.dart';
import 'package:podd_app/services/api/image_api.dart';
import 'package:podd_app/services/api/notification_api.dart';
import 'package:podd_app/services/api/observation_api.dart';
import 'package:podd_app/services/api/profile_api.dart';
import 'package:podd_app/services/api/register_api.dart';
import 'package:podd_app/services/api/report_api.dart';
import 'package:podd_app/services/api/report_type_api.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/comment_service.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:podd_app/services/file_service.dart';
import 'package:podd_app/services/forgot_password_service.dart';
import 'package:podd_app/services/gql_service.dart';
import 'package:podd_app/services/image_service.dart';
import 'package:podd_app/services/notification_service.dart';
import 'package:podd_app/services/observation_definition_service.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:podd_app/services/profile_service.dart';
import 'package:podd_app/services/register_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:podd_app/services/report_type_service.dart';
import 'package:podd_app/services/secure_storage_service.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/ui/home/all_reports_view_model.dart';
import 'package:podd_app/ui/home/my_reports_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

final locator = GetIt.instance;

/*
 * register localization that will use in OPSV not ui widget
 */
void setupAppLocalization() {
  locator.registerSingletonAsync<AppLocalizations>(() async {
    var prefs = await SharedPreferences.getInstance();
    var language = prefs.getString("language") ?? "en";
    return AppLocalizations.delegate.load(Locale(language));
  });

  locator.registerSingletonAsync<Locale>(() async {
    var prefs = await SharedPreferences.getInstance();
    var language = prefs.getString("language") ?? "en";
    return Locale(language);
  });
}

void setupTheme() {
  locator.registerSingletonAsync<AppTheme>(() async {
    return AppTheme();
  });
}

void setupLocator(String environment) {
  locator.allowReassignment = true;

  if (locator.isRegistered<Logger>()) {
    locator.unregister<Logger>();
  }
  locator.registerSingleton<Logger>(Logger());

  if (locator.isRegistered<ConfigService>()) {
    locator.unregister<ConfigService>();
  }
  locator.registerSingleton<ConfigService>(ConfigService());

  if (locator.isRegistered<ISecureStorageService>()) {
    locator.unregister<ISecureStorageService>();
  }
  locator.registerSingletonAsync<ISecureStorageService>(() async {
    return SecureStorageService();
  });

  if (locator.isRegistered<GqlService>()) {
    locator.unregister<GqlService>();
  }
  locator.registerSingletonAsync<GqlService>(() async {
    var service = GqlService();
    await service.init();
    return service;
  }, dependsOn: [ISecureStorageService]);

  registerApiLocators();

  if (locator.isRegistered<IDbService>()) {
    locator.unregister<IDbService>();
  }
  locator.registerSingletonAsync<IDbService>(() async {
    final dbService = DbService();
    await dbService.init();
    return dbService;
  }, dependsOn: []);

  if (locator.isRegistered<IImageService>()) {
    locator.unregister<IImageService>();
  }
  locator.registerSingletonAsync<IImageService>(() async {
    return ImageService();
  }, dependsOn: [
    IDbService,
    ImageApi,
  ]);

  if (locator.isRegistered<IFileService>()) {
    locator.unregister<IFileService>();
  }
  locator.registerSingletonAsync<IFileService>(() async {
    return FileService();
  }, dependsOn: [
    IDbService,
    FileApi,
  ]);

  if (locator.isRegistered<IReportTypeService>()) {
    locator.unregister<IReportTypeService>();
  }
  locator.registerSingletonAsync<IReportTypeService>(() async {
    final reportTypeService = ReportTypeService();
    return reportTypeService;
  }, dependsOn: [
    IDbService,
    ReportTypeApi,
  ]);

  if (locator.isRegistered<ICommentService>()) {
    locator.unregister<ICommentService>();
  }
  locator.registerSingletonAsync<ICommentService>(() async {
    return CommentService();
  }, dependsOn: [
    CommentApi,
  ]);

  if (locator.isRegistered<INotificationService>()) {
    locator.unregister<INotificationService>();
  }
  locator.registerSingletonAsync<INotificationService>(() async {
    final service = NotificationService();
    service.fetchMyMessages(true);
    return service;
  }, dependsOn: [
    NotificationApi,
  ]);

  if (locator.isRegistered<IReportService>()) {
    locator.unregister<IReportService>();
  }
  locator.registerSingletonAsync<IReportService>(() async {
    return ReportService();
  }, dependsOn: [
    ReportApi,
    ImageApi,
    IImageService,
    IFileService,
    IDbService,
  ]);

  if (locator.isRegistered<IObservationRecordService>()) {
    locator.unregister<IObservationRecordService>();
  }
  locator.registerSingletonAsync<IObservationRecordService>(() async {
    return ObservationRecordService();
  }, dependsOn: [
    ImageApi,
    IImageService,
    ObservationApi,
    IDbService,
  ]);

  if (locator.isRegistered<IObservationDefinitionService>()) {
    locator.unregister<IObservationDefinitionService>();
  }
  locator.registerSingletonAsync<IObservationDefinitionService>(() async {
    return ObservationDefinitionService();
  }, dependsOn: [
    IDbService,
    ObservationApi,
  ]);

  if (locator.isRegistered<IAuthService>()) {
    locator.unregister<IAuthService>();
  }
  locator.registerSingletonAsync<IAuthService>(() async {
    final authService = AuthService();
    await authService.init();
    return authService;
  }, dependsOn: [
    ISecureStorageService,
    AuthApi,
    IReportTypeService,
    IReportService,
    IObservationDefinitionService,
  ]);

  if (locator.isRegistered<IRegisterService>()) {
    locator.unregister<IRegisterService>();
  }
  locator.registerSingletonAsync<IRegisterService>(() async {
    return RegisterService();
  }, dependsOn: [
    ISecureStorageService,
    RegisterApi,
    IAuthService,
  ]);

  if (locator.isRegistered<IForgotPasswordService>()) {
    locator.unregister<IForgotPasswordService>();
  }
  locator.registerSingletonAsync<IForgotPasswordService>(() async {
    return ForgotPasswordService();
  }, dependsOn: [
    ForgotPasswordApi,
  ]);

  if (locator.isRegistered<IProfileService>()) {
    locator.unregister<IProfileService>();
  }
  locator.registerSingletonAsync<IProfileService>(() async {
    return ProfileService();
  }, dependsOn: [
    ProfileApi,
    IAuthService,
  ]);

  registerViewModelLocators();
}

/// Some viewmodels need to persist their own states across app lifecycle,
/// so register them as singleton works well
registerViewModelLocators() {
  if (locator.isRegistered<AllReportsViewModel>()) {
    locator.unregister<AllReportsViewModel>();
  }
  locator.registerSingletonAsync<AllReportsViewModel>(() async {
    return AllReportsViewModel();
  }, dependsOn: [
    IReportService,
  ]);

  if (locator.isRegistered<MyReportsViewModel>()) {
    locator.unregister<MyReportsViewModel>();
  }
  locator.registerSingletonAsync<MyReportsViewModel>(() async {
    return MyReportsViewModel();
  }, dependsOn: [
    IReportService,
    IReportTypeService,
  ]);
}

registerApiLocators() {
  if (locator.isRegistered<AuthApi>()) {
    locator.unregister<AuthApi>();
  }
  locator.registerSingletonAsync<AuthApi>(() async {
    var gqlService = locator<GqlService>();
    return AuthApi(gqlService.resolveClientFunction);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<RegisterApi>()) {
    locator.unregister<RegisterApi>();
  }
  locator.registerSingletonAsync<RegisterApi>(() async {
    var gqlService = locator<GqlService>();
    return RegisterApi(gqlService.resolveClientFunction);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<ForgotPasswordApi>()) {
    locator.unregister<ForgotPasswordApi>();
  }
  locator.registerSingletonAsync<ForgotPasswordApi>(() async {
    var gqlService = locator<GqlService>();
    return ForgotPasswordApi(gqlService.resolveClientFunction);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<ProfileApi>()) {
    locator.unregister<ProfileApi>();
  }
  locator.registerSingletonAsync<ProfileApi>(() async {
    var gqlService = locator<GqlService>();
    return ProfileApi(gqlService.resolveClientFunction);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<ReportTypeApi>()) {
    locator.unregister<ReportTypeApi>();
  }
  locator.registerSingletonAsync<ReportTypeApi>(() async {
    var gqlService = locator<GqlService>();
    return ReportTypeApi(gqlService.resolveClientFunction);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<ReportApi>()) {
    locator.unregister<ReportApi>();
  }
  locator.registerSingletonAsync<ReportApi>(() async {
    var gqlService = locator<GqlService>();
    return ReportApi(gqlService.resolveClientFunction);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<ImageApi>()) {
    locator.unregister<ImageApi>();
  }
  locator.registerSingletonAsync<ImageApi>(() async {
    var gqlService = locator<GqlService>();
    return ImageApi(gqlService.resolveClientFunction);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<FileApi>()) {
    locator.unregister<FileApi>();
  }
  locator.registerSingletonAsync<FileApi>(() async {
    var gqlService = locator<GqlService>();
    return FileApi(gqlService.resolveClientFunction);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<NotificationApi>()) {
    locator.unregister<NotificationApi>();
  }
  locator.registerSingletonAsync<NotificationApi>(() async {
    var gqlService = locator<GqlService>();
    return NotificationApi(gqlService.resolveClientFunction);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<CommentApi>()) {
    locator.unregister<CommentApi>();
  }
  locator.registerSingletonAsync<CommentApi>(() async {
    var gqlService = locator<GqlService>();
    return CommentApi(gqlService.resolveClientFunction);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<ConfigurationApi>()) {
    locator.unregister<ConfigurationApi>();
  }
  locator.registerSingletonAsync<ConfigurationApi>(() async {
    var gqlService = locator<GqlService>();
    return ConfigurationApi(gqlService.resolveClientFunction);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<ObservationApi>()) {
    locator.unregister<ObservationApi>();
  }
  locator.registerSingletonAsync<ObservationApi>(() async {
    var gqlService = locator<GqlService>();
    return ObservationApi(gqlService.resolveClientFunction);
  }, dependsOn: [GqlService]);
}
