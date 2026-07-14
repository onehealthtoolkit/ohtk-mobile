import 'package:flutter/material.dart' hide Form;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/components/form_chrome.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/opsv_form/opsv_form.dart' as opsv;
import 'package:podd_app/opsv_form/widgets/widgets.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/home/incidents_theme.dart';
import 'package:podd_app/ui/report_type/form_simulator_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class FormSimulatorView extends StatelessWidget {
  final ReportType reportType;
  const FormSimulatorView(this.reportType, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FormSimulatorViewModel>.reactive(
      viewModelBuilder: () => FormSimulatorViewModel(reportType),
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
        final localize = AppLocalizations.of(context)!;
        return ConfirmPopScope(
          onWillPop: () => _onWillpPop(context, viewModel),
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: incidentsSand,
              appBar: FormChromeAppBar(
                title: "${localize.simulateReportTitle} ${reportType.name}",
                onBack: () async {
                  if (await _onWillpPop(context, viewModel) &&
                      context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              body: SafeArea(
                top: false,
                child: Column(
                  children: [
                    if (viewModel.state == ReportFormState.formInput)
                      FormChromeProgressStrip(form: viewModel.formStore),
                    if (viewModel.state == ReportFormState.confirmation)
                      const Expanded(child: _ConfirmSubmit()),
                    if (viewModel.state == ReportFormState.formInput)
                      Expanded(
                        child: _SimulatorFormInput(viewModel: viewModel),
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

  Future<bool> _onWillpPop(
      BuildContext context, FormSimulatorViewModel viewModel) async {
    if (viewModel.state == ReportFormState.confirmation) {
      viewModel.back();
      return false;
    }
    return showExitConfirmDialog(context);
  }
}

class _SimulatorFormInput extends StatefulWidget {
  final FormSimulatorViewModel viewModel;
  const _SimulatorFormInput({required this.viewModel});

  @override
  State<_SimulatorFormInput> createState() => _SimulatorFormInputState();
}

class _SimulatorFormInputState extends State<_SimulatorFormInput> {
  final ScrollController _scrollController = ScrollController();
  final FormTextInputFocusController _textInputFocusController =
      FormTextInputFocusController();
  final Map<opsv.Question, GlobalKey> _questionKeys = {};

  GlobalKey _keyFor(opsv.Question q) =>
      _questionKeys.putIfAbsent(q, () => GlobalKey());

  void _scrollToInvalid(int index) {
    final questions = widget.viewModel.formStore.currentSection.questions;
    if (index < 0 || index >= questions.length) return;
    final ctx = _questionKeys[questions[index]]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 200),
      alignment: 0.1,
    );
  }

  @override
  void dispose() {
    _textInputFocusController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final form = widget.viewModel.formStore;
        final questions = form.currentSection.questions;
        _textInputFocusController.sync(questions);
        return FormTextInputFocusScope(
          controller: _textInputFocusController,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  key: ObjectKey(form.currentSectionIdx),
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    children: [
                      for (final q in questions)
                        FormQuestion(key: _keyFor(q), question: q),
                    ],
                  ),
                ),
              ),
              FormChromeFooter(
                canGoBack: form.couldGoToPreviousSection,
                isLastSection: !form.couldGoToNextSection,
                isReviewing: false,
                onBack: () async {
                  if (widget.viewModel.back() == BackAction.navigationPop) {
                    if (await showExitConfirmDialog(context) &&
                        context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                onNext: () {
                  if (!widget.viewModel.next()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: incidentsErrorRed,
                        content: Text(
                          AppLocalizations.of(context)!.invalidFormValue,
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    _scrollToInvalid(
                        widget.viewModel.firstInvalidQuestionIndex);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConfirmSubmit extends StackedHookView<FormSimulatorViewModel> {
  const _ConfirmSubmit();

  @override
  Widget builder(BuildContext context, FormSimulatorViewModel viewModel) {
    final localize = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: ListView(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * .60,
            ),
            child: _ConfirmReportData(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: OhtkTheme.palette.teal700,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      localize.closeSimulateReportButton,
                      style: const TextStyle(
                        fontFamily: incidentsFontFamily,
                        fontFamilyFallback: incidentsFontFamilyFallback,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: incidentsInk,
                side: const BorderSide(color: incidentsHair, width: 1),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                viewModel.back();
              },
              child: Text(
                localize.backButton,
                style: const TextStyle(
                  fontFamily: incidentsFontFamily,
                  fontFamilyFallback: incidentsFontFamilyFallback,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ConfirmReportData extends StackedHookView<FormSimulatorViewModel> {
  @override
  Widget builder(BuildContext context, FormSimulatorViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: _data(viewModel.report),
    );
  }

  Widget _data(Report report) {
    return Table(
      border: TableBorder.all(color: incidentsHair, width: 1),
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
      },
      children: report.data.entries.map((entry) {
        return entry.key.contains("__value")
            ? const TableRow(
                children: [SizedBox.shrink(), SizedBox.shrink()],
              )
            : TableRow(
                children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontFamily: incidentsFontFamily,
                          fontFamilyFallback: incidentsFontFamilyFallback,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: incidentsInk,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontFamily: incidentsFontFamily,
                          fontFamilyFallback: incidentsFontFamilyFallback,
                          fontSize: 13,
                          color: incidentsBody,
                        ),
                      ),
                    ),
                  ),
                ],
              );
      }).toList(),
    );
  }
}
