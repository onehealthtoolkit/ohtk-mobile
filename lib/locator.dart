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

final locator = GetIt.instance;

void setupLocator(String environment) {
  locator.registerSingleton<Logger>(Logger());

  locator.registerSingleton<ConfigService>(ConfigService());

  locator.registerSingletonAsync<ISecureStorageService>(() async {
    return SecureStorageService();
  });

  locator.registerSingletonAsync<GqlService>(() async {
    var service = GqlService();
    await service.init();
    return service;
  }, dependsOn: [ISecureStorageService]);

  locator.registerSingletonAsync<IDbService>(() async {
    final dbService = DbService();
    await dbService.init();
    return dbService;
  }, dependsOn: []);

  locator.registerSingletonAsync<IImageService>(() async {
    return ImageService();
  }, dependsOn: [
    IDbService,
  ]);

  locator.registerSingletonAsync<AuthApi>(() async {
    var gqlService = locator<GqlService>();
    return AuthApi(gqlService.client);
  }, dependsOn: [GqlService]);

  locator.registerSingletonAsync<RegisterApi>(() async {
    var gqlService = locator<GqlService>();
    return RegisterApi(gqlService.client);
  }, dependsOn: [GqlService]);

  locator.registerSingletonAsync<ReportTypeApi>(() async {
    var gqlService = locator<GqlService>();
    return ReportTypeApi(gqlService.client);
  }, dependsOn: [GqlService]);

  locator.registerSingletonAsync<ReportApi>(() async {
    var gqlService = locator<GqlService>();
    return ReportApi(gqlService.client);
  }, dependsOn: [GqlService]);

  locator.registerSingletonAsync<ImageApi>(() async {
    var gqlService = locator<GqlService>();
    return ImageApi(gqlService.client);
  }, dependsOn: [GqlService]);

  locator.registerSingletonAsync<NotificationApi>(() async {
    var gqlService = locator<GqlService>();
    return NotificationApi(gqlService.client);
  }, dependsOn: [GqlService]);

  locator.registerSingletonAsync<IReportTypeService>(() async {
    final reportTypeService = ReportTypeService();
    return reportTypeService;
  }, dependsOn: [
    IDbService,
    ReportTypeApi,
  ]);

  locator.registerSingletonAsync<CommentApi>(() async {
    var gqlService = locator<GqlService>();
    return CommentApi(gqlService.client);
  }, dependsOn: [GqlService]);

  locator.registerSingletonAsync<ICommentService>(() async {
    return CommentService();
  }, dependsOn: [
    CommentApi,
  ]);

  locator.registerSingletonAsync<INotificationService>(() async {
    return NotificationService();
  }, dependsOn: [
    NotificationApi,
  ]);

  locator.registerSingletonAsync<IReportService>(() async {
    return ReportService();
  }, dependsOn: [
    ReportApi,
    ImageApi,
    IImageService,
    IDbService,
  ]);

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

  locator.registerSingletonAsync<IRegisterService>(() async {
    return RegisterService();
  }, dependsOn: [
    ISecureStorageService,
    RegisterApi,
    IAuthService,
  ]);
}
