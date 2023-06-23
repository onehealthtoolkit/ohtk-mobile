import 'package:flutter/material.dart' hide Form;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/back_appbar_action.dart';
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/components/form_confirm.dart';
import 'package:podd_app/components/form_input.dart';
import 'package:podd_app/components/form_stepper.dart';
import 'package:podd_app/components/form_test_banner.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/opsv_form/widgets/widgets.dart';
import 'package:podd_app/ui/report/form_base_view_model.dart';
import 'package:podd_app/ui/report/report_form_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReportFormView extends StatelessWidget {
  final AppTheme apptheme = locator<AppTheme>();
  final String reportTypeId;
  final bool testFlag;
  ReportFormView(this.testFlag, this.reportTypeId, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReportFormViewModel>.reactive(
      viewModelBuilder: () => ReportFormViewModel(testFlag, reportTypeId),
      builder: (context, viewModel, child) {
        if (!viewModel.isReady) {
          return const Center(child: CircularProgressIndicator());
        }
        return WillPopScope(
          onWillPop: () async {
            return _onWillpPop(context);
          },
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                leading: const BackAppBarAction(),
                title: Text(
                    "${AppLocalizations.of(context)!.reportTitle} ${viewModel.reportType?.name}"),
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                foregroundColor: testFlag
                    ? Colors.black87
                    : Theme.of(context).appBarTheme.foregroundColor,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    FormTestBanner(testFlag: testFlag),
                    if (viewModel.state == ReportFormState.formInput)
                      FormStepper(form: viewModel.formStore),
                    if (viewModel.state == ReportFormState.confirmation)
                      Expanded(
                        flex: 1,
                        child: FormConfirmSubmit(
                          busy: viewModel.isBusy,
                          onSubmit: () async {
                            var result = await viewModel.submit();
                            if (result is ReportSubmitSuccess ||
                                result is ReportSubmitPending) {
                              Navigator.pop(context);
                            }
                          },
                          onBack: () {
                            viewModel.back();
                          },
                          child: _ConfirmIncidentArea(),
                        ),
                      ),
                    if (viewModel.state == ReportFormState.formInput)
                      Expanded(
                        flex: 1,
                        child: FormInput(
                          viewModel: viewModel,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _onWillpPop(BuildContext context) async {
    return confirm(context);
  }
}

class _ConfirmIncidentArea extends StackedHookView<ReportFormViewModel> {
  final AppTheme apptheme = locator<AppTheme>();
  @override
  Widget builder(BuildContext context, ReportFormViewModel viewModel) {
    return Column(
      children: [
        Center(
          child: Text(
            "Did this incident occur in your own authority?",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 13.sp,
                ),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Column(
          children: [
            _RadioOption(
              title: AppLocalizations.of(context)!.yes,
              value: true,
              groupValue: viewModel.incidentInAuthority,
              onChanged: (bool? value) {
                viewModel.incidentInAuthority = value;
              },
            ),
            _RadioOption(
              title: AppLocalizations.of(context)!.no,
              value: false,
              groupValue: viewModel.incidentInAuthority,
              onChanged: (bool? value) {
                viewModel.incidentInAuthority = value;
              },
            ),
          ],
        )
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  final AppTheme apptheme = locator<AppTheme>();
  final String title;
  final bool? value;
  final bool? groupValue;
  final ValueChanged<bool?>? onChanged;
  final AppTheme appTheme = locator<AppTheme>();

  _RadioOption({
    Key? key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<bool?>(
          groupValue: groupValue,
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          contentPadding: const EdgeInsets.all(0),
          activeColor: apptheme.primary,
          value: value,
          onChanged: onChanged,
          visualDensity: VisualDensity.standard,
        ),
        CustomPaint(
          painter: DashedLinePainter(backgroundColor: apptheme.primary),
          child: Container(
            height: 1,
          ),
        ),
      ],
    );
  }
}
