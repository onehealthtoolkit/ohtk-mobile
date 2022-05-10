import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:date_field/date_field.dart';
import 'package:intl/intl.dart';
import 'package:podd_app/form/form_data/form_data.dart';
import 'package:podd_app/form/form_store.dart';
import 'package:provider/provider.dart';
import 'package:podd_app/form/ui_definition/form_ui_definition.dart';
import 'package:podd_app/form/widgets/validation.dart';

class FormDateField extends StatefulWidget {
  final DateFieldUIDefinition fieldDefinition;

  const FormDateField(this.fieldDefinition, {Key? key}) : super(key: key);

  @override
  State<FormDateField> createState() => _FormDateFieldState();
}

class _FormDateFieldState extends State<FormDateField> {
  UnRegisterValidationCallback? unRegisterValidationCallback;
  bool valid = true;
  String errorMessage = '';

  ValidationState validate() {
    var isValid = true;
    var msg = '';

    if (mounted) {
      var formData = Provider.of<FormData>(context, listen: false);
      var formValue =
          formData.getFormValue(widget.fieldDefinition.name) as DateFormValue;

      if (formValue.value == null) {
        isValid = false;
        msg = '${widget.fieldDefinition.name} is required';
      }

      setState(() {
        valid = isValid;
        errorMessage = msg;
      });
    }
    return ValidationState(isValid, msg);
  }

  @override
  void dispose() {
    if (unRegisterValidationCallback != null) {
      unRegisterValidationCallback!();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var formStore = Provider.of<FormStore>(context);
    if (widget.fieldDefinition.required == true) {
      unRegisterValidationCallback = formStore.registerValidation(validate);
    }
    var formData = Provider.of<FormData>(context);
    var formValue =
        formData.getFormValue(widget.fieldDefinition.name) as DateFormValue;

    return Observer(builder: (BuildContext context) {
      formValue.value;
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
            errorText: valid ? null : errorMessage,
          ),
          mode: DateTimeFieldPickerMode.date,
          selectedDate: formValue.value,
          onDateSelected: (DateTime value) {
            formValue.value = value;
            if (!valid) {
              // clear error message
              setState(() {
                valid = true;
              });
            }
          });
    });
  }
}
