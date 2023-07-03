import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/ui/home/home_view.dart';
import 'package:podd_app/ui/home/observation/observation_home_view.dart';
import 'package:podd_app/ui/home/report_home_view.dart';
import 'package:podd_app/ui/login/login_view.dart';
import 'package:podd_app/ui/observation/form/monitoring_record_form_view.dart';
import 'package:podd_app/ui/observation/form/subject_form_view.dart';
import 'package:podd_app/ui/observation/monitoring/observation_monitoring_view.dart';
import 'package:podd_app/ui/observation/observation_view.dart';
import 'package:podd_app/ui/observation/subject/observation_subject_view.dart';
import 'package:podd_app/ui/profile/change_password_view.dart';
import 'package:podd_app/ui/profile/profile_form_view.dart';
import 'package:podd_app/ui/profile/profile_view.dart';
import 'package:podd_app/ui/report/followup_report_form_view.dart';
import 'package:podd_app/ui/report/followup_report_view.dart';
import 'package:podd_app/ui/report/incident_report_view.dart';
import 'package:podd_app/ui/report/report_form_view.dart';
import 'package:podd_app/ui/report_type/report_type_view.dart';
import 'package:stacked/stacked.dart';

class AppViewModel extends ReactiveViewModel {
  final IAuthService authService = locator<IAuthService>();
  bool? get isLogin => authService.isLogin;

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

class OhtkRouter {
  static final OhtkRouter _instance = OhtkRouter._internal();

  static const incidentDetail = 'incidentDetail';
  static const incidentFollowup = 'incidentFollowup';
  static const reportTypes = 'reportTypes';
  static const reportForm = 'reportForm';
  static const followupReportForm = 'followupReportForm';
  static const observationSubjects = 'observationSubjects';
  static const observationSubjectForm = 'observationSubjectForm';
  static const observationSubjectDetail = 'observationSubjectDetail';
  static const observationMonitoringForm = 'observationMonitoringForm';
  static const observationMonitoringDetail = 'observationMonitoringDetail';

  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  factory OhtkRouter() {
    return _instance;
  }
  OhtkRouter._internal();

  GoRouter getRouter(String initialLocation, AppViewModel viewModel) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: initialLocation,
      refreshListenable: viewModel,
      // redirect to the login page if the user is not logged in
      redirect: (BuildContext context, GoRouterState state) {
        // if the user is not logged in, they need to login
        final bool loggedIn = viewModel.isLogin ?? false;
        final bool loggingIn = state.location == '/login';
        if (!loggedIn) {
          return '/login';
        }

        // if the user is logged in but still on the login page, send them to
        // the home page (shell route) on first view, default to 'reports'
        if (loggingIn) {
          return '/reports';
        }

        // no need to redirect at all
        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) =>
              const LoginView(),
        ),

        /// Application shell
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return HomeView(child: child);
          },
          routes: <RouteBase>[
            GoRoute(
              path: '/reports',
              builder: (context, state) => ReportHomeView(),
              routes: <RouteBase>[
                GoRoute(
                  name: incidentDetail,
                  path: 'incident/:incidentId',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    var incidentId = state.pathParameters['incidentId'];
                    return IncidentReportView(id: incidentId!);
                  },
                  routes: [
                    GoRoute(
                      name: incidentFollowup,
                      path: 'followup/:followupId',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        var followupId = state.pathParameters['followupId'];
                        return FollowupReportView(id: followupId!);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  name: reportTypes,
                  path: 'types',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => ReportTypeView(),
                ),
                GoRoute(
                  name: reportForm,
                  path: 'types/:reportTypeId/form',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    var reportTypeId = state.pathParameters['reportTypeId'];
                    var testFlag = state.queryParameters['test'] == '1';
                    return ReportFormView(testFlag, reportTypeId!);
                  },
                ),
                GoRoute(
                  name: followupReportForm,
                  path: 'incident/:incidentId/types/:reportTypeId/form',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    var incidentId = state.pathParameters['incidentId'];
                    var reportTypeId = state.pathParameters['reportTypeId'];
                    return FollowupReportFormView(
                      incidentId: incidentId!,
                      reportTypeId: reportTypeId!,
                    );
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/observations',
              builder: (context, state) => const ObservationHomeView(),
              routes: [
                GoRoute(
                  name: observationSubjects,
                  path: ':definitionId/subjects',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    var definitionId = state.pathParameters['definitionId'];
                    return ObservationView(definitionId!);
                  },
                  routes: [
                    GoRoute(
                      name: observationSubjectForm,
                      path: 'form',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        var definitionId = state.pathParameters['definitionId'];
                        return ObservationSubjectFormView(
                          definitionId: definitionId!,
                        );
                      },
                    ),
                    GoRoute(
                      name: observationSubjectDetail,
                      path: ':subjectId',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        var definitionId = state.pathParameters['definitionId'];
                        var subjectId = state.pathParameters['subjectId'];
                        return ObservationSubjectView(
                          definitionId: definitionId!,
                          subjectId: subjectId!,
                        );
                      },
                      routes: [
                        GoRoute(
                          name: observationMonitoringForm,
                          path:
                              'monitoringDefinition/:monitoringDefinitionId/form',
                          parentNavigatorKey: _rootNavigatorKey,
                          builder: (context, state) {
                            var subjectId = state.pathParameters['subjectId'];
                            var monitoringDefinitionId =
                                state.pathParameters['monitoringDefinitionId'];
                            return ObservationMonitoringRecordFormView(
                              monitoringDefinitionId: monitoringDefinitionId!,
                              subjectId: subjectId!,
                            );
                          },
                        ),
                        GoRoute(
                          name: observationMonitoringDetail,
                          path: 'monitoringRecords/:monitoringId',
                          parentNavigatorKey: _rootNavigatorKey,
                          builder: (context, state) {
                            var monitoringId =
                                state.pathParameters['monitoringId'];
                            return ObservationMonitoringRecordView(
                              monitoringRecordId: monitoringId!,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileView(),
              routes: [
                GoRoute(
                  path: 'form',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    return const ProfileFormView();
                  },
                ),
                GoRoute(
                  path: 'password',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    return const ChangePasswordView();
                  },
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
