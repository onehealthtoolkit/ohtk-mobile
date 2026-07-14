import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/ui/census/census_view.dart';
import 'package:podd_app/ui/home/home_view.dart';
import 'package:podd_app/ui/home/observation/observation_home_view.dart';
import 'package:podd_app/ui/home/report_home_view.dart';
import 'package:podd_app/components/restart_widget.dart';
import 'package:podd_app/ui/login/login_view.dart';
import 'package:podd_app/ui/welcome/welcome_view.dart';
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

import 'locator.dart';

CustomTransitionPage<void> _tabFadePage({
  required Widget child,
  LocalKey? key,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, _, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
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
  static const census = 'census';

  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  String? initialLocation = '/reports';

  factory OhtkRouter() {
    return _instance;
  }
  OhtkRouter._internal();

  GoRouter getRouter({bool setupComplete = true}) {
    final IAuthService authService = locator<IAuthService>();
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: initialLocation,
      refreshListenable: authService,
      // redirect to the welcome gate (first launch) or login page (returning
      // user) until both setup and authentication are complete
      redirect: (BuildContext context, GoRouterState state) {
        final bool loggedIn = authService.isLogin ?? false;
        final bool loggingIn = state.matchedLocation == '/login';
        final bool onWelcome = state.matchedLocation == '/welcome';

        // First-launch gate: no language or no server picked yet
        if (!setupComplete && !onWelcome) {
          return '/welcome';
        }

        // Standard auth gate: not logged in → /login
        if (!loggedIn && !loggingIn && !onWelcome) {
          return '/login';
        }

        // Logged-in users shouldn't sit on /login; bounce them home
        if (loggedIn && loggingIn) {
          return initialLocation;
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
        GoRoute(
          path: '/welcome',
          builder: (BuildContext context, GoRouterState state) => WelcomeView(
            onContinue: () {
              if (context.mounted) RestartWidget.restartApp(context);
            },
          ),
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
              pageBuilder: (context, state) => _tabFadePage(
                key: state.pageKey,
                child: const ReportHomeView(),
              ),
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
                    var testFlag = state.uri.queryParameters['test'] == '1';
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
              name: census,
              path: '/census',
              pageBuilder: (context, state) => _tabFadePage(
                key: state.pageKey,
                child: const CensusView(),
              ),
              routes: [
                GoRoute(
                  path: ':kind',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => CensusView(
                    kind: state.pathParameters['kind'],
                    trainingMode: state.uri.queryParameters['training'] == '1',
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/observations',
              pageBuilder: (context, state) => _tabFadePage(
                key: state.pageKey,
                child: const ObservationHomeView(),
              ),
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
              pageBuilder: (context, state) => _tabFadePage(
                key: state.pageKey,
                child: const ProfileView(),
              ),
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
