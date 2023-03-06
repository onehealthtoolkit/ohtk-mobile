import 'package:flutter/material.dart' hide Form;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:im_stepper/stepper.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/components/flat_button.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/opsv_form/widgets/widgets.dart';
import 'package:podd_app/ui/report/report_form_view_model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReportFormView extends StatelessWidget {
  final ReportType reportType;
  final bool testFlag;
  const ReportFormView(this.testFlag, this.reportType, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReportFormViewModel>.reactive(
      viewModelBuilder: () => ReportFormViewModel(testFlag, reportType),
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
                    " ${reportType.name}"),
                backgroundColor: testFlag
                    ? Colors.yellow.shade500
                    : Theme.of(context).appBarTheme.backgroundColor,
                foregroundColor: testFlag
                    ? Colors.black87
                    : Theme.of(context).appBarTheme.foregroundColor,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    if (viewModel.state == ReportFormState.formInput &&
                        viewModel.formStore.numberOfSections > 1)
                      _DotStepper(),
                    if (viewModel.state == ReportFormState.confirmation)
                      Expanded(
                        flex: 1,
                        child: _ConfirmSubmit(),
                      ),
                    if (viewModel.state == ReportFormState.formInput)
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

class _FormInput extends HookViewModelWidget<ReportFormViewModel> {
  final ItemScrollController _scrollController = ItemScrollController();

  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportFormViewModel viewModel) {
    final form = viewModel.formStore;
    return Observer(
      builder: (_) => ScrollablePositionedList.builder(
        key: ObjectKey(form.currentSectionIdx),
        itemScrollController: _scrollController,
        itemBuilder: (context, index) {
          if (index < form.currentSection.questions.length) {
            return FormQuestion(
              question: form.currentSection.questions[index],
            );
          } else {
            return _Footer(_scrollController);
          }
        },
        itemCount: form.currentSection.questions.length + 1,
      ),
    );
  }
}

class _ConfirmSubmit extends HookViewModelWidget<ReportFormViewModel> {
  final AppTheme apptheme = locator<AppTheme>();
  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportFormViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
        child: Column(
          children: [
            _ConfirmIncidentArea(),
            const SizedBox(
              height: 20,
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: FlatButton.primary(
                onPressed: () async {
                  var result = await viewModel.submit();
                  if (result is ReportSubmitSuccess ||
                      result is ReportSubmitPending) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("ยืนยันรายงาน"),
              ),
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

class _ConfirmIncidentArea extends HookViewModelWidget<ReportFormViewModel> {
  final AppTheme apptheme = locator<AppTheme>();
  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportFormViewModel viewModel) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.center,
          child: Text(
            "Did this incident occur in your own authority?",
            textScaleFactor: 1.1,
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
            style: TextStyle(
                color: appTheme.inputTextColor, fontWeight: FontWeight.w500),
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

class _Footer extends HookViewModelWidget<ReportFormViewModel> {
  final Logger logger = locator<Logger>();
  final ItemScrollController scrollController;

  _Footer(this.scrollController);

  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportFormViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () async {
              if (viewModel.back() == BackAction.navigationPop) {
                if (await confirm(context)) {
                  logger.d("back using pop");
                  Navigator.popUntil(context, ModalRoute.withName("/"));
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
              if (!viewModel.next()) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text("Invalid form value"),
                ));
                scrollController.scrollTo(
                    index: viewModel.firstInvalidQuestionIndex,
                    duration: const Duration(milliseconds: 400));
              }
            },
            child: const Text("next >"),
          ),
        ],
      ),
    );
  }
}

class _DotStepper extends HookViewModelWidget<ReportFormViewModel> {
  // appTheme
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportFormViewModel viewModel) {
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
                      Text(
                        store.currentSection.label,
                        style: TextStyle(
                            color: appTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      DotStepper(
                        dotCount: store.numberOfSections,
                        spacing: 10,
                        dotRadius: 12,
                        activeStep: store.currentSectionIdx,
                        tappingEnabled: true,
                        indicatorDecoration:
                            IndicatorDecoration(color: appTheme.primary),
                        shape: Shape.pipe3,
                        indicator: Indicator.jump,
                        onDotTapped: (tappedDotIndex) {
                          if (tappedDotIndex > store.currentSectionIdx) {
                            viewModel.next();
                          } else if (tappedDotIndex < store.currentSectionIdx) {
                            viewModel.back();
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
    );
  }
}
