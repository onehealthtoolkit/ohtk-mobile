import 'package:flutter/material.dart';
import 'package:podd_app/ui/home/observation/observation_home_view_model.dart';
import 'package:podd_app/ui/observation/observation_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';

class ObservationHomeView extends StatelessWidget {
  const ObservationHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ObservationHomeViewModel>.nonReactive(
      viewModelBuilder: () => ObservationHomeViewModel(),
      builder: (context, viewModel, child) => RefreshIndicator(
        onRefresh: () => viewModel.syncDefinitions(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Flex(direction: Axis.vertical, children: [
            Expanded(
              child: _Listing(),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Listing extends HookViewModelWidget<ObservationHomeViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationHomeViewModel viewModel) {
    return viewModel.isBusy
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            shrinkWrap: true,
            itemCount: viewModel.observationDefinitions.length,
            itemBuilder: ((context, index) {
              final observationDefinition =
                  viewModel.observationDefinitions[index];

              return ListTile(
                title: Text(
                  observationDefinition.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ObservationView(observationDefinition),
                    ),
                  );
                },
                trailing: const Icon(Icons.arrow_forward_ios),
              );
            }),
          );
  }
}
