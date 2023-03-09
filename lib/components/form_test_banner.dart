import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/locator.dart';

class FormTestBanner extends StatelessWidget {
  final bool testFlag;
  final AppTheme appTheme = locator<AppTheme>();

  FormTestBanner({required this.testFlag, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return testFlag
        ? Container(
            height: 30.w,
            color: appTheme.warn,
            child: Center(
              child: Text(
                AppLocalizations.of(context)?.testModeOn ?? 'Test mode is on',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
