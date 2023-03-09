import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:im_stepper/stepper.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/opsv_form/opsv_form.dart' as opsv_form;

class FormStepper extends StatelessWidget {
  final AppTheme appTheme = locator<AppTheme>();
  final opsv_form.Form form;
  FormStepper({required this.form, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => SizedBox(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          form.currentSection.label,
                          style: TextStyle(
                              color: appTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp),
                        ),
                        if (form.numberOfSections > 1)
                          DotStepper(
                            dotCount: form.numberOfSections,
                            spacing: 10,
                            dotRadius: 12,
                            activeStep: form.currentSectionIdx,
                            tappingEnabled: true,
                            indicatorDecoration:
                                IndicatorDecoration(color: appTheme.primary),
                            shape: Shape.pipe3,
                            indicator: Indicator.jump,
                            onDotTapped: (tappedDotIndex) {
                              if (tappedDotIndex > form.currentSectionIdx) {
                                form.next();
                              } else if (tappedDotIndex <
                                  form.currentSectionIdx) {
                                form.previous();
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
