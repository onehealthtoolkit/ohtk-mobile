import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:date_field/date_field.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/form/form_data/form_data.dart';
import 'package:podd_app/form/form_data/form_values/date_form_value.dart';
import 'package:provider/provider.dart';
import 'package:podd_app/form/ui_definition/form_ui_definition.dart';

class FormDateField extends StatefulWidget {
  final DateFieldUIDefinition fieldDefinition;

  const FormDateField(this.fieldDefinition, {Key? key}) : super(key: key);

  @override
  State<FormDateField> createState() => _FormDateFieldState();
}

class _FormDateFieldState extends State<FormDateField> {
  @override
  Widget build(BuildContext context) {
    var formData = Provider.of<FormData>(context);
    var formValue =
        formData.getFormValue(widget.fieldDefinition.name) as DateFormValue;

    return Observer(builder: (BuildContext context) {
      formValue.value;
      formValue
          .isValid; // make sure that this field is registered in mobx listener

      return DateTimeField(
          dateFormat:
              DateFormat.yMMMd(Localizations.localeOf(context).toString()),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: widget.fieldDefinition.label,
            suffixText: widget.fieldDefinition.suffixLabel != null
                ? widget.fieldDefinition.suffixLabel!
                : null,
            helperText: widget.fieldDefinition.description != null
                ? widget.fieldDefinition.description!
                : null,
            errorText: formValue.isValid ? null : formValue.invalidateMessage,
          ),
          mode: DateTimeFieldPickerMode.date,
          selectedDate: formValue.value,
          onDateSelected: (DateTime value) {
            formValue.value = value;
          });
    });
  }
}
