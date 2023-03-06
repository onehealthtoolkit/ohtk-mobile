import 'package:flutter/material.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/locator.dart';

class IncidentReportTestTag extends StatelessWidget {
  final AppTheme appTheme = locator<AppTheme>();

  IncidentReportTestTag({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: appTheme.tag2,
      ),
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
      child: Text(
        "Test",
        style: TextStyle(
          color: appTheme.bg1,
        ),
        textScaleFactor: 0.8,
      ),
    );
  }
}

class IncidentReportCaseTag extends StatelessWidget {
  final AppTheme appTheme = locator<AppTheme>();

  IncidentReportCaseTag({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: appTheme.tag1,
      ),
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Text(
        "Case",
        style: TextStyle(
          color: appTheme.bg1,
        ),
        textScaleFactor: 0.7,
      ),
    );
  }
}
