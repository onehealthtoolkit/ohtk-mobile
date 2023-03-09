import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/back_appbar_action.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/ui/observation/form/subject_form_view.dart';
import 'package:podd_app/ui/observation/observation_subject_list_view.dart';
import 'package:podd_app/ui/observation/observation_subject_map_view.dart';
import 'package:podd_app/ui/observation/observation_view_model.dart';
import 'package:stacked/stacked.dart';

class ObservationView extends HookWidget {
  final AppTheme appTheme = locator<AppTheme>();
  final ObservationDefinition definition;

  ObservationView(this.definition, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TabController _tabController = useTabController(initialLength: 2);

    return ViewModelBuilder<ObservationViewModel>.reactive(
      viewModelBuilder: () => ObservationViewModel(definition),
      builder: (context, viewModel, child) => Scaffold(
          appBar: AppBar(
            leading: const BackAppBarAction(),
            automaticallyImplyLeading: false,
            shadowColor: Colors.transparent,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: ColoredBox(
                color: appTheme.bg2,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(child: Text('List')),
                    Tab(child: Text('Map')),
                  ],
                ),
              ),
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
          floatingActionButton: CircleAvatar(
            radius: 30.r,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            child: IconButton(
              iconSize: 38.w,
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
              icon: const Icon(Icons.add_circle_outline),
            ),
          )),
    );
  }
}
