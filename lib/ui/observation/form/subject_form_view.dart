import 'package:flutter/material.dart' hide Form;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:im_stepper/stepper.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/observation_subject_submit_result.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/opsv_form/widgets/widgets.dart';
import 'package:podd_app/ui/observation/form/subject_form_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationSubjectFormView extends StatelessWidget {
  final ObservationDefinition definition;
  final ObservationSubjectRecord? subject;

  const ObservationSubjectFormView({
    Key? key,
    required this.definition,
    this.subject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ObservationSubjectFormViewModel>.reactive(
      viewModelBuilder: () =>
          ObservationSubjectFormViewModel(definition, subject),
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
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.reportTitle +
                    " ${definition.name}"),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    if (viewModel.state ==
                        ObservationSubjectFormState.formInput)
                      _DotStepper(),
                    if (viewModel.state ==
                        ObservationSubjectFormState.confirmation)
                      Expanded(
                        flex: 1,
                        child: _ConfirmSubmit(),
                      ),
                    if (viewModel.state ==
                        ObservationSubjectFormState.formInput)
                      Expanded(
                        flex: 1,
                        child: _FormInput(),
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

class _FormInput extends HookViewModelWidget<ObservationSubjectFormViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectFormViewModel viewModel) {
    final form = viewModel.formStore;
    return Observer(
      builder: (_) => ListView.builder(
        key: ObjectKey(form.currentSectionIdx),
        itemBuilder: (context, index) {
          if (index < form.currentSection.questions.length) {
            return FormQuestion(
              question: form.currentSection.questions[index],
            );
          } else {
            return _Footer();
          }
        },
        itemCount: form.currentSection.questions.length + 1,
      ),
    );
  }
}

class _ConfirmSubmit
    extends HookViewModelWidget<ObservationSubjectFormViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectFormViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 40),
              child: Text("Press the submit button to submit your report"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // NEW
              ),
              onPressed: () async {
                var result = await viewModel.submit();
                if (result is SubjectRecordSubmitSuccess ||
                    result is SubjectRecordSubmitPending) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Submit"),
            ),
            const SizedBox(
              height: 8,
            ),
            TextButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // NEW
              ),
              onPressed: () {
                viewModel.back();
              },
              child: const Text("Back"),
            ),
            const SizedBox(
              height: 60,
            )
          ],
        ),
      ),
    );
  }
}

class _Footer extends HookViewModelWidget<ObservationSubjectFormViewModel> {
  final Logger logger = locator<Logger>();
  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectFormViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () async {
              if (viewModel.back() == BackAction.navigationPop) {
                if (await confirm(context)) {
                  logger.d("back using pop");
                  Navigator.pop(context);
                }
              } else {
                logger.d("back but do nothing");
              }
            },
            child: const Text("< back"),
          ),
          const Spacer(flex: 1),
          ElevatedButton(
            onPressed: () {
              viewModel.next();
            },
            child: const Text("next >"),
          ),
        ],
      ),
    );
  }
}

class _DotStepper extends HookViewModelWidget<ObservationSubjectFormViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectFormViewModel viewModel) {
    Form store = viewModel.formStore;
    return Observer(
      builder: (_) => Padding(
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
                      Text(store.currentSection.label),
                      if (store.numberOfSections > 1)
                        DotStepper(
                          dotCount: store.numberOfSections,
                          spacing: 10,
                          dotRadius: 12,
                          activeStep: store.currentSectionIdx,
                          tappingEnabled: false,
                          indicatorDecoration:
                              const IndicatorDecoration(color: Colors.blue),
                          shape: Shape.pipe,
                          indicator: Indicator.jump,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
