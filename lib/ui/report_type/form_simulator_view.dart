import 'package:flutter/material.dart' hide Form;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:im_stepper/stepper.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/opsv_form/widgets/widgets.dart';
import 'package:podd_app/ui/report_type/form_simulator_view_model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FormSimulatorView extends StatelessWidget {
  final ReportType reportType;
  const FormSimulatorView(this.reportType, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FormSimulatorViewModel>.reactive(
      viewModelBuilder: () => FormSimulatorViewModel(reportType),
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
                title: Text(
                    "${AppLocalizations.of(context)!.simulateReportTitle} ${reportType.name}"),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    if (viewModel.state == ReportFormState.formInput)
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

class _FormInput extends StackedHookView<FormSimulatorViewModel> {
  final ItemScrollController _scrollController = ItemScrollController();

  @override
  Widget builder(BuildContext context, FormSimulatorViewModel viewModel) {
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

class _ConfirmSubmit extends StackedHookView<FormSimulatorViewModel> {
  @override
  Widget builder(BuildContext context, FormSimulatorViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * .60,
            ),
            child: _ConfirmReportData(),
          ),
          const SizedBox(
            height: 60,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: viewModel.isBusy
                ? null
                : () async {
                    var result = await viewModel.submit();
                    if (result is ReportSubmitSuccess ||
                        result is ReportSubmitPending) {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
            child: viewModel.isBusy
                ? const CircularProgressIndicator()
                : Text(AppLocalizations.of(context)!.closeSimulateReportButton),
          ),
          const SizedBox(
            height: 8,
          ),
          TextButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () {
              viewModel.back();
            },
            child: Text(AppLocalizations.of(context)!.backButton),
          ),
          const SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }
}

class _ConfirmReportData extends StackedHookView<FormSimulatorViewModel> {
  @override
  Widget builder(BuildContext context, FormSimulatorViewModel viewModel) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: _data(viewModel.report));
  }

  _data(Report report) {
    var dataTable = Table(
        border: TableBorder.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
        },
        children: report.data.entries.map((entry) {
          return entry.key.contains("__value")
              ? const TableRow(children: [SizedBox.shrink(), SizedBox.shrink()])
              : TableRow(
                  children: [
                    TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(entry.key),
                        )),
                    TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(entry.value.toString()),
                        )),
                  ],
                );
        }).toList());

    return dataTable;
  }
}

class _Footer extends StackedHookView<FormSimulatorViewModel> {
  final Logger logger = locator<Logger>();
  final ItemScrollController scrollController;

  _Footer(this.scrollController);

  @override
  Widget builder(BuildContext context, FormSimulatorViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () async {
              if (viewModel.back() == BackAction.navigationPop) {
                if (await confirm(context)) {
                  logger.d("back using pop");
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              } else {
                logger.d("back but do nothing");
              }
            },
            child: Text(AppLocalizations.of(context)!.formBackButton),
          ),
          const Spacer(flex: 1),
          ElevatedButton(
            onPressed: () {
              if (!viewModel.next()) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(AppLocalizations.of(context)!.invalidFormValue),
                ));
                scrollController.scrollTo(
                    index: viewModel.firstInvalidQuestionIndex,
                    duration: const Duration(milliseconds: 400));
              }
            },
            child: Text(AppLocalizations.of(context)!.formNextButton),
          ),
        ],
      ),
    );
  }
}

class _DotStepper extends StackedHookView<FormSimulatorViewModel> {
  @override
  Widget builder(BuildContext context, FormSimulatorViewModel viewModel) {
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
                          tappingEnabled: true,
                          indicatorDecoration:
                              const IndicatorDecoration(color: Colors.blue),
                          shape: Shape.pipe,
                          indicator: Indicator.jump,
                          onDotTapped: (tappedDotIndex) {
                            if (tappedDotIndex > store.currentSectionIdx) {
                              viewModel.next();
                            } else if (tappedDotIndex <
                                store.currentSectionIdx) {
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
