import 'package:flutter/material.dart' hide FormField;

import '../ui_definition/question.dart';
import 'form_field.dart';

class FormQuestion extends StatelessWidget {
  final Question question;

  const FormQuestion({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
  }
}
