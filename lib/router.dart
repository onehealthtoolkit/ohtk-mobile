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
import 'package:podd_app/ui/profile/profile_view.dart';
import 'package:podd_app/ui/report/followup_report_form_view.dart';
import 'package:podd_app/ui/report/followup_report_view.dart';
import 'package:podd_app/ui/report/incident_report_view.dart';
import 'package:podd_app/ui/report/report_form_view.dart';
import 'package:podd_app/ui/report_type/report_type_view.dart';
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
                routes: <RouteBase>[
                  GoRoute(
                    name: 'incidentDetail',
                    path: 'incident/:incidentId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      var incidentId = state.params['incidentId'];
                      return IncidentReportView(id: incidentId!);
                    },
                    routes: [
                      GoRoute(
                        name: 'incidentFollowup',
                        path: 'followup/:followupId',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) {
                          var followupId = state.params['followupId'];
                          return FollowupReportView(id: followupId!);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    name: 'reportTypes',
                    path: 'types',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => ReportTypeView(),
                  ),
                  GoRoute(
                    name: 'reportForm',
                    path: 'types/:reportTypeId/form',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      var reportTypeId = state.params['reportTypeId'];
                      var testFlag = state.queryParams['test'] == '1';
                      return ReportFormView(testFlag, reportTypeId!);
                    },
                  ),
                  GoRoute(
                    name: 'followupReportForm',
                    path: 'incident/:incidentId/types/:reportTypeId/form',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      var incidentId = state.params['incidentId'];
                      var reportTypeId = state.params['reportTypeId'];
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
                    name: 'observationSubjects',
                    path: ':definitionId/subjects',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      var definitionId = state.params['definitionId'];
                      return ObservationView(definitionId!);
                    },
                    routes: [
                      GoRoute(
                        name: 'observationSubjectForm',
                        path: 'form',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) {
                          var definitionId = state.params['definitionId'];
                          return ObservationSubjectFormView(
                            definitionId: definitionId!,
                          );
                        },
                      ),
                      GoRoute(
                        name: 'observationSubjectDetail',
                        path: ':subjectId',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (context, state) {
                          var definitionId = state.params['definitionId'];
                          var subjectId = state.params['subjectId'];
                          return ObservationSubjectView(
                            definitionId: definitionId!,
                            subjectId: subjectId!,
                          );
                        },
                        routes: [
                          GoRoute(
                            name: 'observationMonitoringForm',
                            path:
                                'monitoringDefinition/:monitoringDefinitionId/form',
                            parentNavigatorKey: _rootNavigatorKey,
                            builder: (context, state) {
                              var subjectId = state.params['subjectId'];
                              var monitoringDefinitionId =
                                  state.params['monitoringDefinitionId'];
                              return ObservationMonitoringRecordFormView(
                                monitoringDefinitionId: monitoringDefinitionId!,
                                subjectId: subjectId!,
                              );
                            },
                          ),
                          GoRoute(
                            name: 'observationMonitoringDetail',
                            path: 'monitoringRecords/:monitoringId',
                            parentNavigatorKey: _rootNavigatorKey,
                            builder: (context, state) {
                              var monitoringId = state.params['monitoringId'];
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
