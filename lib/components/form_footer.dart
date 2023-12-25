import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/flat_button.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/ui/report/form_base_view_model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef OnLastSectionValid = void Function();

class FormFooter extends StatelessWidget {
  final AppTheme apptheme = locator<AppTheme>();
  final Logger logger = locator<Logger>();
  final ItemScrollController scrollController;
  final FormBaseViewModel viewModel;

  /// callback function called when form reaches last section and then hit 'Next'
  /// while all questions have been validated to true
  final OnLastSectionValid? onLastSectionValid;

  FormFooter({
    required this.viewModel,
    required this.scrollController,
    this.onLastSectionValid,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: apptheme.bg2,
        border: Border(
          top: BorderSide(width: 2.0, color: Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10.0,
            spreadRadius: 0.0,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: apptheme.bg2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () async {
              FocusManager.instance.primaryFocus?.unfocus();
              if (viewModel.back() == BackAction.navigationPop) {
                logger.d("back using pop");
                Navigator.maybePop(context);
              } else {
                logger.d("back but do nothing");
                scrollController.scrollTo(
                    index: 0, duration: const Duration(milliseconds: 100));
              }
            },
            child: Text(
              AppLocalizations.of(context)!.formBackButton,
              style: TextStyle(fontSize: 13.sp),
            ),
          ),
          const Spacer(flex: 1),
          FlatButton.primary(
            padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              if (!viewModel.next()) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text("Invalid form value"),
                  duration: Duration(milliseconds: 700),
                ));
                scrollController.scrollTo(
                    index: viewModel.firstInvalidQuestionIndex,
                    duration: const Duration(milliseconds: 100));
              } else {
                scrollController.scrollTo(
                    index: 0, duration: const Duration(milliseconds: 100));

                if (onLastSectionValid != null &&
                    viewModel.state == ReportFormState.confirmation) {
                  onLastSectionValid!.call();
                }
              }
            },
            child: Row(
              children: [
                Text(AppLocalizations.of(context)!.formNextButton,
                    style: TextStyle(fontSize: 13.sp)),
                const Icon(
                  Icons.navigate_next,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
