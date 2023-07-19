import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:podd_app/components/form_footer.dart';
import 'package:podd_app/opsv_form/widgets/widgets.dart';
import 'package:podd_app/ui/report/form_base_view_model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class FormInput extends StatelessWidget {
  final FormBaseViewModel viewModel;
  final ItemScrollController _scrollController = ItemScrollController();

  FormInput({required this.viewModel, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var appbarHeight = AppBar().preferredSize.height;
    var top = MediaQuery.of(context).padding.top;
    var bottom = MediaQuery.of(context).padding.bottom;
    var footerHeight = 50.h;
    var stepperHeight = viewModel.formStore.numberOfSections > 1 ? 60.h : 0;
    var testBannerHeight = viewModel.isTestMode ? 30.h : 0;
    var spare = MediaQuery.of(context).viewInsets.bottom == 0 ? 0 : 170.h;

    return Observer(
      builder: (_) => Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              height: height -
                  appbarHeight -
                  top -
                  bottom -
                  stepperHeight -
                  footerHeight -
                  testBannerHeight -
                  spare -
                  80.w,
              child: ScrollablePositionedList.builder(
                itemScrollController: _scrollController,
                itemBuilder: (context, index) {
                  return FormQuestion(
                    question:
                        viewModel.formStore.currentSection.questions[index],
                  );
                },
                itemCount: viewModel.formStore.currentSection.questions.length,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              child: FormFooter(
                viewModel: viewModel,
                scrollController: _scrollController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
