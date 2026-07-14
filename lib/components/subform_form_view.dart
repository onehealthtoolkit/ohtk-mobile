import 'package:flutter/material.dart' hide Form;
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/components/form_chrome.dart';
import 'package:podd_app/components/form_input.dart';
import 'package:podd_app/components/subform_form_view_model.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
import 'package:stacked/stacked.dart';

class SubformFormView extends StatelessWidget {
  final String name;
  final Form form;
  final bool testFlag;

  const SubformFormView(this.testFlag, this.name, this.form, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SubformFormViewModel>.reactive(
      viewModelBuilder: () => SubformFormViewModel(testFlag, name, form),
      onViewModelReady: (viewModel) => viewModel.gotoStart(),
      builder: (context, viewModel, child) {
        if (!viewModel.isReady) {
          return Scaffold(
            backgroundColor: incidentsSand,
            body: Center(
              child: CircularProgressIndicator(
                color: OhtkTheme.palette.teal700,
              ),
            ),
          );
        }
        return ConfirmPopScope(
          onWillPop: () => _onWillpPop(context),
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: incidentsSand,
              appBar: FormChromeAppBar(
                title: viewModel.formName,
                onBack: () async {
                  if (await _onWillpPop(context) && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              body: SafeArea(
                top: false,
                child: Column(
                  children: [
                    FormChromeTestBanner(testFlag: testFlag),
                    FormChromeProgressStrip(form: viewModel.formStore),
                    Expanded(
                      flex: 1,
                      child: FormInput(
                        viewModel: viewModel,
                        onLastSectionValid: () {
                          Navigator.pop(context, 'complete');
                        },
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
    return showExitConfirmDialog(context);
  }
}
