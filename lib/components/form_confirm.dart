import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podd_app/components/flat_button.dart';
import 'package:podd_app/opsv_form/widgets/widgets.dart';

typedef OnSubmit = Future<void> Function();

class FormConfirmSubmit extends StatelessWidget {
  final OnSubmit onSubmit;
  final Function() onBack;
  final Widget? child;
  final String? submitText;
  final String? backText;
  final String? dataSummary;
  final bool showDataSummary;
  final bool busy;

  const FormConfirmSubmit(
      {required this.onSubmit,
      required this.onBack,
      this.child,
      this.submitText,
      this.backText,
      this.dataSummary,
      this.showDataSummary = false,
      this.busy = false,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
        child: Column(children: [
          child ?? Container(),
          const SizedBox(
            height: 20,
          ),
          if (showDataSummary) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.reportDataSummary,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 14.sp,
                    ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                dataSummary != null && dataSummary!.isNotEmpty
                    ? dataSummary!
                    : AppLocalizations.of(context)!.reportDataSummaryNotFound,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 13.sp,
                    ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            CustomPaint(
              painter: DashedLinePainter(
                  backgroundColor: Theme.of(context).primaryColor),
              child: Container(
                height: 1,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
          Center(
            child: Text(
              AppLocalizations.of(context)!.confirmCheckReport,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 13.sp,
                  ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: double.infinity),
            child: FlatButton.primary(
              onPressed: () {
                if (!busy) {
                  onSubmit();
                }
              },
              child: busy
                  ? busyIndicator()
                  : Text(
                      submitText ?? AppLocalizations.of(context)!.submitButton,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          if (!busy)
            TextButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // NEW
              ),
              onPressed: () {
                if (!busy) {
                  onBack();
                }
              },
              child: Text(
                backText ?? AppLocalizations.of(context)!.formBackButton,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(
            height: 60,
          )
        ]),
      ),
    );
  }

  static Widget busyIndicator({Color color = Colors.white}) {
    return Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          color: color,
        ),
      ),
    );
  }
}
