import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/opsv_form/widgets/widgets.dart';
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
          padding: EdgeInsets.fromLTRB(20.w, 16.67.h, 20.w, 16.67.h),
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
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget buildViewModelWidget(
      BuildContext context, ObservationHomeViewModel viewModel) {
    return viewModel.isBusy
        ? const Center(
            child: OhtkProgressIndicator(size: 100),
          )
        : ListView.separated(
            separatorBuilder: (context, index) => CustomPaint(
              painter: DashedLinePainter(backgroundColor: appTheme.primary),
              child: Container(
                height: 1.h,
              ),
            ),
            shrinkWrap: true,
            itemCount: viewModel.observationDefinitions.length,
            itemBuilder: ((context, index) {
              final observationDefinition =
                  viewModel.observationDefinitions[index];

              return ListTile(
                  title: Text(
                    observationDefinition.name,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  onTap: () {
                    GoRouter.of(context).goNamed('observationSubjects',
                        params: {
                          "definitionId": observationDefinition.id.toString()
                        });
                  },
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: appTheme.secondary,
                    size: 13.h,
                  ));
            }),
          );
  }
}
