import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:podd_app/form/ui_definition/form_ui_definition.dart';
import 'package:provider/provider.dart';

import '../form_data/form_data.dart';
import '../form_store.dart';
import 'validation.dart';

class FormTextField extends StatefulWidget {
  final TextFieldUIDefinition fieldDefinition;

  const FormTextField(this.fieldDefinition, {Key? key}) : super(key: key);

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
  final TextEditingController _controller = TextEditingController();
  UnRegisterValidationCallback? unRegisterValidationCallback;
  bool valid = true;
  String errorMessage = '';

  ValidationState validate() {
    var isValid = true;
    var msg = '';

    if (_controller.text.isEmpty) {
      isValid = false;
      msg = '${widget.fieldDefinition.label} is required';
    }
    if (mounted) {
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
        formData.getFormValue(widget.fieldDefinition.name) as StringFormValue;

    return Observer(builder: (BuildContext context) {
      var value = formValue.value ?? '';
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
          errorText: valid ? null : errorMessage,
        ),
        onChanged: (val) {
          formValue.value = val;
          if (!valid) {
            // clear error message
            setState(() {
              valid = true;
            });
          }
        },
      );
    });
  }
}
