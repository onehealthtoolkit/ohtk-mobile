import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/ui/home/home_view.dart';
import 'package:podd_app/ui/home/observation/observation_home_view.dart';
import 'package:podd_app/ui/home/report_home_view.dart';
import 'package:podd_app/ui/login/login_view.dart';
import 'package:podd_app/ui/profile/profile_view.dart';
import 'package:stacked/stacked.dart';

class OhtkRouter {
  static final OhtkRouter _instance = OhtkRouter._internal();

  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  factory OhtkRouter() {
    return _instance;
  }
  OhtkRouter._internal();

  GoRouter getRouter(String initialLocation) => GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: initialLocation,
        routes: <RouteBase>[
          /// Application shell
          ShellRoute(
            navigatorKey: _shellNavigatorKey,
            builder: (BuildContext context, GoRouterState state, Widget child) {
              return _App(child: child);
            },
            routes: <RouteBase>[
              GoRoute(
                path: '/reports',
                builder: (context, state) => ReportHomeView(),
              ),
              GoRoute(
                path: '/observations',
                builder: (context, state) => const ObservationHomeView(),
              ),
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileView(),
              ),
            ],
          )
        ],
      );
}

class _App extends StatelessWidget {
  final Widget child;

  const _App({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<_AppViewModel>.reactive(
      viewModelBuilder: () => _AppViewModel(),
      builder: (context, viewModel, _) => viewModel.isLogin == true
          ? HomeView(child: child)
          : const LoginView(),
    );
  }
}

class _AppViewModel extends ReactiveViewModel {
  final IAuthService authService = locator<IAuthService>();
  bool? get isLogin => authService.isLogin;

  late Timer timer;

  _AppViewModel() : super() {
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      authService.requestAccessTokenIfExpired();
    });
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices =>
      [authService as AuthService];
}
