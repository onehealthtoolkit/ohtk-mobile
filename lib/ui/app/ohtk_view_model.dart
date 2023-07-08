import 'dart:async';

import 'package:podd_app/locator.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:stacked/stacked.dart';

class AppViewModel extends ReactiveViewModel {
  final IAuthService authService = locator<IAuthService>();

  late Timer timer;

  AppViewModel() : super() {
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      authService.requestAccessTokenIfExpired();
    });
  }

  @override
  List<ListenableServiceMixin> get listenableServices =>
      [authService as AuthService];
}
