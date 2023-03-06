import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/components/confirm.dart';
import 'package:podd_app/components/flat_button.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/ui/report/form_base_view_model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FormFooter extends StatelessWidget {
  final Logger logger = locator<Logger>();
  final ItemScrollController scrollController;
  final FormBaseViewModel viewModel;
  FormFooter(
      {required this.viewModel, required this.scrollController, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          TextButton(
            onPressed: () async {
              if (viewModel.back() == BackAction.navigationPop) {
                if (await confirm(context)) {
                  logger.d("back using pop");
                  Navigator.popUntil(context, ModalRoute.withName("/"));
                }
              } else {
                logger.d("back but do nothing");
                scrollController.scrollTo(
                    index: 0, duration: const Duration(milliseconds: 100));
              }
            },
            child: Text(AppLocalizations.of(context)!.formBackButton),
          ),
          const Spacer(flex: 1),
          FlatButton.primary(
            padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
            onPressed: () {
              if (!viewModel.next()) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text("Invalid form value"),
                ));
                scrollController.scrollTo(
                    index: viewModel.firstInvalidQuestionIndex,
                    duration: const Duration(milliseconds: 100));
              } else {
                scrollController.scrollTo(
                    index: 0, duration: const Duration(milliseconds: 100));
              }
            },
            child: Row(
              children: [
                Text(AppLocalizations.of(context)!.formNextButton),
                const Icon(
                  Icons.navigate_next,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
