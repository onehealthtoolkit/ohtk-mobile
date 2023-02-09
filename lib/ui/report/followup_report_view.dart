import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/models/entities/followup_report.dart';
import 'package:podd_app/ui/report/followup_report_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// View that creates and provides the viewmodel
class FollowupReportView extends StatelessWidget {
  final String id;
  const FollowupReportView({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FollowupReportViewModel>.nonReactive(
      builder: (context, model, child) => Scaffold(
          body: Center(
        child: _FollowupReportView(),
      )),
      viewModelBuilder: () => FollowupReportViewModel(id),
    );
  }
}

class _FollowupReportView extends HookViewModelWidget<FollowupReportViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, FollowupReportViewModel viewModel) {
    final followup = viewModel.data;
    if (followup == null) {
      return const OhtkProgressIndicator(size: 100);
    } else {
      var formatter = DateFormat("dd/MM/yyyy HH:mm");

      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.followupDetailTitle),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _title(context, followup),
              const SizedBox(height: 10),
              Text(
                formatter.format(followup.createdAt.toLocal()),
                textScaleFactor: .75,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  color: Colors.white,
                  constraints: const BoxConstraints(
                      minHeight: 100, minWidth: double.infinity),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(followup.description.isEmpty
                        ? "no description"
                        : followup.trimWhitespaceDescription),
                  ),
                ),
              ),
              _Images(),
            ],
          ),
        ),
      );
    }
  }

  _title(BuildContext context, FollowupReport incident) {
    return Row(
      children: [
        Text(
          incident.reportTypeName,
          textScaleFactor: 1.5,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}

class _Images extends HookViewModelWidget<FollowupReportViewModel> {
  @override
  Widget buildViewModelWidget(
      BuildContext context, FollowupReportViewModel viewModel) {
    final images = viewModel.data!.images;
    var _pageController = usePageController(viewportFraction: .5);

    return Container(
      color: Colors.white,
      constraints:
          const BoxConstraints(minWidth: double.infinity, minHeight: 150),
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: 150,
        child: (images != null && images.isNotEmpty)
            ? PageView.builder(
                itemCount: images.length,
                pageSnapping: true,
                controller: _pageController,
                itemBuilder: (context, pagePosition) {
                  return Container(
                    margin: const EdgeInsets.all(10),
                    child: CachedNetworkImage(
                      imageUrl: viewModel
                          .resolveImagePath(images[pagePosition].thumbnailPath),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              )
            : const Text("No images uploaded"),
      ),
    );
  }
}
