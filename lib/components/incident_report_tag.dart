import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:podd_app/app_theme.dart';
import 'package:podd_app/locator.dart';

const tagLTRB = EdgeInsets.fromLTRB(8, 0, 8, 0);

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
      padding: tagLTRB,
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
      padding: tagLTRB,
      child: Text(
        "Case",
        style: TextStyle(
          color: appTheme.bg1,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}
