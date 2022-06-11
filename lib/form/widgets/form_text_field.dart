import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:podd_app/form/form_data/form_values/string_form_value.dart';
import 'package:podd_app/form/ui_definition/form_ui_definition.dart';
import 'package:provider/provider.dart';

import '../form_data/form_data.dart';

class FormTextField extends StatefulWidget {
  final TextFieldUIDefinition fieldDefinition;

  const FormTextField(this.fieldDefinition, {Key? key}) : super(key: key);

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var formData = Provider.of<FormData>(context);
    var formValue =
        formData.getFormValue(widget.fieldDefinition.name) as StringFormValue;

    return Observer(builder: (BuildContext context) {
      var value = formValue.value ?? '';

      if (formValue.dependOn != null) {
        var _dependFormValue = formData.getFormValue(formValue.dependOn!);
        _dependFormValue.value;
      }

      if (!formValue.evaluateCondition(formData)) {
        return Container();
      }
      if (value != '' && value != _controller.text) {
        _controller.value = TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length));
      }
      return TextField(
        controller: _controller,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: widget.fieldDefinition.label,
          suffixText: widget.fieldDefinition.suffixLabel != null
              ? widget.fieldDefinition.suffixLabel!
              : null,
          helperText: widget.fieldDefinition.description != null
              ? widget.fieldDefinition.description!
              : null,
          errorText: formValue.isValid ? null : formValue.invalidMessage,
        ),
        onChanged: (val) {
          formValue.value = val;
        },
      );
    });
  }
}
