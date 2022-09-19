import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/services/api/auth_api.dart';
import 'package:podd_app/services/api/comment_api.dart';
import 'package:podd_app/services/api/image_api.dart';
import 'package:podd_app/services/api/notification_api.dart';
import 'package:podd_app/services/api/register_api.dart';
import 'package:podd_app/services/api/report_api.dart';
import 'package:podd_app/services/api/report_type_api.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/comment_service.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:podd_app/services/gql_service.dart';
import 'package:podd_app/services/image_service.dart';
import 'package:podd_app/services/notification_service.dart';
import 'package:podd_app/services/register_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:podd_app/services/report_type_service.dart';
import 'package:podd_app/services/secure_storage_service.dart';
import 'package:podd_app/ui/home/all_reports_view_model.dart';
import 'package:podd_app/ui/home/my_reports_view_model.dart';

final locator = GetIt.instance;

void setupLocator(String environment) {
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
    return NotificationService();
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
    IDbService,
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
    return AuthApi(gqlService.client);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<RegisterApi>()) {
    locator.unregister<RegisterApi>();
  }
  locator.registerSingletonAsync<RegisterApi>(() async {
    var gqlService = locator<GqlService>();
    return RegisterApi(gqlService.client);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<ReportTypeApi>()) {
    locator.unregister<ReportTypeApi>();
  }
  locator.registerSingletonAsync<ReportTypeApi>(() async {
    var gqlService = locator<GqlService>();
    return ReportTypeApi(gqlService.client);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<ReportApi>()) {
    locator.unregister<ReportApi>();
  }
  locator.registerSingletonAsync<ReportApi>(() async {
    var gqlService = locator<GqlService>();
    return ReportApi(gqlService.client);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<ImageApi>()) {
    locator.unregister<ImageApi>();
  }
  locator.registerSingletonAsync<ImageApi>(() async {
    var gqlService = locator<GqlService>();
    return ImageApi(gqlService.client);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<NotificationApi>()) {
    locator.unregister<NotificationApi>();
  }
  locator.registerSingletonAsync<NotificationApi>(() async {
    var gqlService = locator<GqlService>();
    return NotificationApi(gqlService.client);
  }, dependsOn: [GqlService]);

  if (locator.isRegistered<CommentApi>()) {
    locator.unregister<CommentApi>();
  }
  locator.registerSingletonAsync<CommentApi>(() async {
    var gqlService = locator<GqlService>();
    return CommentApi(gqlService.client);
  }, dependsOn: [GqlService]);
}
