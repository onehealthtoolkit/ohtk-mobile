import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/ui/observation/form/subject_form_view.dart';
import 'package:podd_app/ui/observation/subject/observation_subject_monitoring_view.dart';
import 'package:podd_app/ui/observation/subject/observation_subject_report_view.dart';
import 'package:podd_app/ui/observation/subject/observation_subject_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationSubjectView extends HookWidget {
  final ObservationDefinition definition;
  final ObservationSubject subject;

  const ObservationSubjectView({
    Key? key,
    required this.definition,
    required this.subject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TabController _tabController = useTabController(initialLength: 2);

    return ViewModelBuilder<ObservationSubjectViewModel>.reactive(
      viewModelBuilder: () => ObservationSubjectViewModel(definition, subject),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Subject view"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child: viewModel.isBusy
                ? const Center(child: CircularProgressIndicator())
                : !viewModel.hasError
                    ? _bodyView(_tabController, context)
                    : const Text("Observation subject not found")),
      ),
    );
  }

  Widget _bodyView(TabController _tabController, BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, value) {
        return [
          SliverToBoxAdapter(
            child: _SubjectDetail(),
          ),
          SliverToBoxAdapter(
            child: _moreDetailTabBar(_tabController, context),
          ),
        ];
      },
      body: _moreDetailTabBarView(_tabController),
    );
  }

  Widget _moreDetailTabBarView(TabController _tabController) {
    return TabBarView(
      controller: _tabController,
      children: [
        ObservationSubjectMonitoringView(
            definition: definition, subject: subject),
        ObservationSubjectReportView(subjectId: subject.id),
      ],
    );
  }

  PreferredSize _moreDetailTabBar(
      TabController _tabController, BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ColoredBox(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.blue[500],
          unselectedLabelColor: Colors.blue[200],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          tabs: const [
            Tab(
              child: Text("Monitoring"),
            ),
            Tab(
              child: Text("Report"),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectDetail extends HookViewModelWidget<ObservationSubjectViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationSubjectViewModel viewModel) {
    var subject = viewModel.data!;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(subject.id.toString()),
          const SizedBox(height: 10),
          Text(
            subject.title.isNotEmpty ? subject.title : "no title",
            textScaleFactor: 1.5,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(subject.description.isNotEmpty
              ? subject.description
              : "no description"),
          const SizedBox(height: 10),
          Text(subject.identity.isNotEmpty ? subject.identity : "no identity"),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ObservationSubjectFormView(
                  definition: viewModel.definition,
                  subject: subject,
                ),
              ),
            ),
            child: const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.edit_note),
            ),
          ),
          _data(subject),
        ],
      ),
    );
  }

  _data(ObservationSubject subject) {
    var dataTable = Table(
        border: TableBorder.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1),
        },
        children: subject.formData!.entries.map((entry) {
          return TableRow(
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

    return subject.formData != null ? dataTable : const Text("no data");
  }
}
