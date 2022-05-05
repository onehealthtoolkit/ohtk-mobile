import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/services/api/auth_api.dart';
import 'package:podd_app/services/api/register_api.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/config_service.dart';
import 'package:podd_app/services/gql_service.dart';
import 'package:podd_app/services/register_service.dart';
import 'package:podd_app/services/secure_storage_service.dart';

final locator = GetIt.instance;

void setupLocator(String environment) {
  locator.registerSingleton<Logger>(Logger());

  locator.registerSingleton<ConfigService>(ConfigService());

  locator.registerSingletonAsync<ISecureStorageService>(() async {
    return SecureStorageService();
  });

  locator.registerSingletonAsync<GqlService>(() async => GqlService(),
      dependsOn: [ISecureStorageService]);

  locator.registerSingletonAsync<AuthApi>(() async {
    var gqlService = locator<GqlService>();
    return AuthApi(gqlService.client);
  }, dependsOn: [GqlService]);

  locator.registerSingletonAsync<RegisterApi>(() async {
    var gqlService = locator<GqlService>();
    return RegisterApi(gqlService.client);
  }, dependsOn: [GqlService]);

  locator.registerSingletonAsync<IAuthService>(() async {
    final authService = AuthService();
    await authService.init();
    return authService;
  }, dependsOn: [
    ISecureStorageService,
    AuthApi,
  ]);

  locator.registerSingletonAsync<IRegisterService>(() async {
    return RegisterService();
  }, dependsOn: [ISecureStorageService, RegisterApi, IAuthService]);
}
