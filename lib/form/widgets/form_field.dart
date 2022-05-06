import 'package:flutter/material.dart';

import '../ui_definition/form_ui_definition.dart';
import 'form_images_field.dart';
import 'form_integer_field.dart';
import 'form_location_field.dart';
import 'form_text_field.dart';

class FormField extends StatelessWidget {
  final FieldUIDefinition field;

  const FormField({Key? key, required this.field}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildWidget(),
    );
  }

  _buildWidget() {
    if (field is TextFieldUIDefinition) {
      return FormTextField(field as TextFieldUIDefinition);
    } else if (field is LocationFieldUIDefinition) {
      return FormLocationField(field as LocationFieldUIDefinition);
    } else if (field is IntegerFieldUIDefinition) {
      return FormIntegerField(field as IntegerFieldUIDefinition);
    } else if (field is ImagesFieldUIDefinition) {
      return FormImagesField(field as ImagesFieldUIDefinition);
    }
    //  else if (field is IntegerFieldUIDefinition) {
    //   return FormIntegerField(field as IntegerFieldUIDefinition);
    // } else if (field is DateFieldUIDefinition) {
    //   return FormDateField(field as DateFieldUIDefinition);

    return const Text("unknown field");
  }
}
