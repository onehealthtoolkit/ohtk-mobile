import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/components/back_appbar_action.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/router.dart';
import 'package:podd_app/theme/ohtk_style_system.dart';
import 'package:podd_app/ui/observation/observation_subject_list_view.dart';
import 'package:podd_app/ui/observation/observation_subject_map_view.dart';
import 'package:podd_app/ui/observation/observation_view_model.dart';
import 'package:stacked/stacked.dart';

class ObservationView extends HookWidget {
  final String definitionId;

  const ObservationView(this.definitionId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 2);
    final selectedIndex = useState(0);
    final searchController = useTextEditingController();

    useEffect(() {
      void listener() => selectedIndex.value = tabController.index;
      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    return ViewModelBuilder<ObservationViewModel>.reactive(
      viewModelBuilder: () => ObservationViewModel(definitionId),
      builder: (context, viewModel, child) => Scaffold(
        backgroundColor: OhtkColor.cream,
        appBar: AppBar(
          leading: const BackAppBarAction(),
          automaticallyImplyLeading: false,
          title: viewModel.searchMode
              ? _SearchField(
                  controller: searchController,
                  viewModel: viewModel,
                )
              : Text(viewModel.title),
          actions: viewModel.searchMode
              ? null
              : [
                  IconButton(
                    onPressed: viewModel.toggleSearchMode,
                    icon: const Icon(Icons.search),
                  ),
                  const SizedBox(width: 4),
                ],
        ),
        body: Column(
          children: [
            _TabsStrip(
              controller: tabController,
              activeIndex: selectedIndex.value,
              labels: const ['List', 'Map'],
            ),
            Expanded(
              child: viewModel.isBusy
                  ? const Center(child: OhtkProgressIndicator(size: 100))
                  : viewModel.definition != null
                      ? TabBarView(
                          controller: tabController,
                          children: [
                            ObservationSubjectListView(
                                definition: viewModel.definition!),
                            ObservationSubjectMapView(
                                definition: viewModel.definition!),
                          ],
                        )
                      : const Center(child: Text('No definition')),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(right: 2, bottom: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: OhtkShadow.raised,
            ),
            child: FloatingActionButton.extended(
              backgroundColor: OhtkTheme.palette.teal700,
              foregroundColor: Colors.white,
              elevation: 0,
              highlightElevation: 0,
              shape: const StadiumBorder(),
              extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
              onPressed: viewModel.definition != null
                  ? () {
                      GoRouter.of(context).goNamed(
                        OhtkRouter.observationSubjectForm,
                        pathParameters: {
                          'definitionId': viewModel.definitionId,
                        },
                      );
                    }
                  : null,
              icon: const Icon(Icons.add, size: 22),
              label: const Text(
                'NEW',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabsStrip extends StatelessWidget {
  final TabController controller;
  final int activeIndex;
  final List<String> labels;

  const _TabsStrip({
    required this.controller,
    required this.activeIndex,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: OhtkColor.paper,
        border: Border(bottom: BorderSide(color: OhtkColor.line)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: OhtkLayout.pagePad),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: _TabButton(
                label: labels[i],
                selected: activeIndex == i,
                onTap: () => controller.animateTo(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? OhtkColor.accent : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: selected ? OhtkColor.ink900 : OhtkColor.ink500,
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ObservationViewModel viewModel;

  const _SearchField({required this.controller, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onChanged: viewModel.setSearchWord,
        onSubmitted: (value) {
          viewModel.setSearchWord(value);
          viewModel.submitSearch();
        },
        style: const TextStyle(fontSize: 15, color: OhtkColor.ink900),
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: 'Search…',
          hintStyle: const TextStyle(color: OhtkColor.ink400),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  controller.text = '';
                  viewModel.setSearchWord('');
                  viewModel.submitSearch();
                },
                icon: const Icon(Icons.close, color: OhtkColor.ink500),
                splashRadius: 18,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
