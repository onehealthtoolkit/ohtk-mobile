import 'package:cached_network_image/cached_network_image.dart';
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
        onRefresh: () => viewModel.fetch(),
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

              var leading = observationDefinition.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: observationDefinition.imageUrl!,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      fit: BoxFit.fill,
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      width: 80,
                    );

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 70,
                      maxWidth: 70,
                      minHeight: 52,
                      maxHeight: 52,
                    ),
                    child: leading,
                  ),
                ),
                title: Text(observationDefinition.name),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ObservationView(observationDefinition),
                    ),
                  );
                },
              );
            }),
          );
  }
}
