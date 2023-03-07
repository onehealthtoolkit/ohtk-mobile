import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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

    return Observer(
      builder: (_) => Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              height: height - appbarHeight - 70 - 160,
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
              height: 70,
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
/*
ScrollablePositionedList.builder(
        itemScrollController: _scrollController,
        itemBuilder: (context, index) {
          if (index < viewModel.formStore.currentSection.questions.length) {
            return FormQuestion(
              question: viewModel.formStore.currentSection.questions[index],
            );
          } else {
            return FormFooter(
                viewModel: viewModel, scrollController: _scrollController);
          }
        },
        itemCount: viewModel.formStore.currentSection.questions.length + 1,
      ),
      */