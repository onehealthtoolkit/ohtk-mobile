import 'package:flutter/material.dart' hide FormField;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:podd_app/form/form_data/form_data.dart';
import 'package:podd_app/form/form_store.dart';
import 'package:provider/provider.dart';

import '../ui_definition/question.dart';
import 'form_field.dart';

class FormQuestion extends StatelessWidget {
  final Question question;

  const FormQuestion({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var formStore = Provider.of<FormStore>(context);
    var formData = Provider.of<FormData>(context);

    return Observer(
      builder: (BuildContext context) {
        var shouldEnable = formStore.isQuestionEnable(question);
        if (!shouldEnable) {
          return Container();
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(question.label),
              ListView.builder(
                itemBuilder: (context, index) =>
                    FormField(field: question.fields[index]),
                itemCount: question.fields.length,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
              ),
            ],
          ),
        );
      },
    );
  }
}
