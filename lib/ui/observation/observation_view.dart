import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/ui/observation/form/subject_form_view.dart';
import 'package:podd_app/ui/observation/observation_subject_list_view.dart';
import 'package:podd_app/ui/observation/observation_subject_map_view.dart';
import 'package:podd_app/ui/observation/observation_view_model.dart';
import 'package:stacked/stacked.dart';

class ObservationView extends HookWidget {
  final ObservationDefinition definition;

  const ObservationView(this.definition, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TabController _tabController = useTabController(initialLength: 2);

    return ViewModelBuilder<ObservationViewModel>.reactive(
      viewModelBuilder: () => ObservationViewModel(definition),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(child: Text('List')),
              Tab(child: Text('Map')),
            ],
          ),
          title: Text(definition.name),
        ),
        body: viewModel.isBusy
            ? const Center(child: OhtkProgressIndicator(size: 100))
            : TabBarView(
                controller: _tabController,
                children: [
                  ObservationSubjectListView(definition: definition),
                  ObservationSubjectMapView(definition: definition),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ObservationSubjectFormView(
                  definition: definition,
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
