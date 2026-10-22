import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/components/report_case_badge.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/comment.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/services/comment_service.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/all_reports_view_model.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
import 'package:podd_app/ui/home/report_list_view.dart';
import 'package:podd_app/ui/report/incident_report_view.dart';
import 'package:stacked/stacked.dart';
import '../fixtures/case_report.dart';
import '../fixtures/report_services.dart';

class _ListModel implements BaseReportViewModel {
  @override
  final List<IncidentReport> incidentReports;
  _ListModel(IncidentReport report) : incidentReports = [report];
  @override
  String resolveImagePath(String path) => path;
}

class _Comments extends Fake
    with ListenableServiceMixin
    implements ICommentService {
  @override
  List<Comment> get comments => [];
  @override
  Future<void> fetchComments(int threadId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
    for (final font in [
      ('Inter', 'Inter-Variable.ttf'),
      ('NotoSansLao', 'NotoSansLao-Variable.ttf'),
      ('NotoSansThai', 'NotoSansThai-Regular.ttf'),
    ]) {
      await (FontLoader(font.$1)
            ..addFont(rootBundle.load('assets/fonts/${font.$2}')))
          .load();
    }
  });
  tearDown(() async => locator.reset());
  final rows = <(String, Map<String, dynamic>?, String, Color)>[
    ('unknown', null, 'case', incidentsCasePillBg),
    (
      'open',
      caseStatusJson('officer', 'close_case', finished: false),
      'case',
      incidentsCasePillBg
    ),
    (
      'closed',
      caseStatusJson('officer', 'close_case'),
      'closed',
      const Color(0xFFDCFCE7)
    ),
    (
      'automatic',
      caseStatusJson('system', ''),
      'automatic',
      const Color(0xFFF3F4F6)
    ),
    (
      'false-positive',
      caseStatusJson('officer', 'false_positive'),
      'false-positive',
      const Color(0xFFF3F4F6)
    ),
    (
      'late-completion',
      caseStatusJson('system', 'close_case'),
      'automatic',
      const Color(0xFFF3F4F6)
    ),
    ('legacy-finish', caseStatusJson('', ''), 'case', incidentsCasePillBg),
  ];
  for (final locale in ['en', 'lo', 'th']) {
    for (final detail in [false, true]) {
      for (final row in rows) {
        testWidgets(
            '$locale ${detail ? 'detail' : 'list'} ${row.$1} renders correct badge at phone width',
            (tester) async {
          tester.view.physicalSize = const Size(320, 740);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final localize = await AppLocalizations.delegate.load(Locale(locale));
          final report = caseReport(status: row.$2)..testFlag = true;
          final (api, _) = registerReportServices();
          api.nextReport = report;
          locator.registerSingleton<ICommentService>(_Comments());
          final boundary = GlobalKey();
          await tester.pumpWidget(MaterialApp(
            theme: OhtkTheme.build(),
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: RepaintBoundary(
              key: boundary,
              child: detail
                  ? const IncidentReportView(id: 'report-1')
                  : Scaffold(
                      body: ReportListView(viewModel: _ListModel(report))),
            ),
          ));
          await tester.pumpAndSettle();
          final label = switch (row.$3) {
            'closed' => localize.caseClosedTag,
            'automatic' => localize.caseAutomaticCloseTag,
            'false-positive' => localize.caseFalsePositiveTag,
            _ => localize.caseTag,
          };
          expect(find.text(label.toUpperCase()), findsOneWidget);
          final container = tester.widget<Container>(find
              .descendant(
                  of: find.byType(ReportCaseBadge),
                  matching: find.byType(Container))
              .first);
          expect((container.decoration as BoxDecoration).color, row.$4);
          expect(
              find.descendant(
                  of: find.byType(ReportCaseBadge),
                  matching: find.byIcon(Icons.check)),
              row.$3 == 'closed' ? findsOneWidget : findsNothing);
          if (detail) {
            expect(find.text(localize.testTag.toUpperCase()), findsWidgets);
          }
          expect(tester.takeException(), isNull);
          if (const bool.fromEnvironment('CO2C_CAPTURE') &&
              ['closed', 'automatic', 'false-positive'].contains(row.$1) &&
              locale == 'lo') {
            await tester.runAsync(() async {
              final image = await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
              final bytes =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              final output = Directory('build/co2c-ui')
                ..createSync(recursive: true);
              File('${output.path}/$locale-${detail ? 'detail' : 'list'}-${row.$1}.png')
                  .writeAsBytesSync(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }
  testWidgets('no caseId suppresses even a finished badge', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: ReportCaseBadge(
              report: caseReport(
                  caseId: null,
                  status: caseStatusJson('officer', 'close_case')))),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(Text), findsNothing);
    expect(find.byIcon(Icons.check), findsNothing);
  });
}
