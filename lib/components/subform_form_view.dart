import 'package:flutter/material.dart' hide Form;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/back_appbar_action.dart';
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/components/form_confirm.dart';
import 'package:podd_app/components/form_input.dart';
import 'package:podd_app/components/form_stepper.dart';
import 'package:podd_app/components/form_test_banner.dart';
import 'package:podd_app/components/subform_form_view_model.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/ui/report/form_base_view_model.dart';
import 'package:stacked/stacked.dart';

class SubformFormView extends StatelessWidget {
  final AppTheme apptheme = locator<AppTheme>();
  final String name;
  final Form form;
  final bool testFlag;

  SubformFormView(this.testFlag, this.name, this.form, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SubformFormViewModel>.reactive(
      viewModelBuilder: () => SubformFormViewModel(testFlag, name, form),
      onViewModelReady: (viewModel) => viewModel.gotoStart(),
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
                title: Text(viewModel.formName),
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
                          submitText: AppLocalizations.of(context)!.ok,
                          busy: viewModel.isBusy,
                          onSubmit: () async {
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          onBack: () {
                            viewModel.back();
                          },
                          child:
                              const Text('Press [OK] to close this sub-form,\n'
                                  'or [Back] to return to previous questions'),
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
