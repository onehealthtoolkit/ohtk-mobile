import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:podd_app/form/form_data/form_values/single_choices_form_value.dart';
import 'package:podd_app/form/ui_definition/fields/option_field_ui_definition.dart';
import 'package:podd_app/form/ui_definition/form_ui_definition.dart';
import 'package:provider/provider.dart';

import '../form_data/form_data.dart';

class FormSingleChoicesField extends StatefulWidget {
  final SingleChoicesFieldUIDefinition fieldDefinition;

  const FormSingleChoicesField(this.fieldDefinition, {Key? key})
      : super(key: key);

  @override
  State<FormSingleChoicesField> createState() => _FormSingleChoicesFieldState();
}

class _FormSingleChoicesFieldState extends State<FormSingleChoicesField> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var formData = Provider.of<FormData>(context);
    var formValue = formData.getFormValue(widget.fieldDefinition.name)
        as SingleChoicesFormValue;

    return Observer(builder: (BuildContext context) {
      formValue.value;
      formValue
          .isValid; // make sure that this field is registered in mobx listener

      var currentText = formValue.text ?? '';
      if (currentText != _controller.text) {
        _controller.value = TextEditingValue(
            text: currentText,
            selection: TextSelection.collapsed(offset: currentText.length));
      }

      onSelect(value) {
        formValue.value = value;
      }

      onSetInputValue(value) {
        formValue.text = value;
      }

      var tiles = widget.fieldDefinition.options.map((option) => _RadioOption(
            option,
            formValue,
            _controller,
            onSelect,
            onSetInputValue,
          ));
      return Column(
        children: tiles.toList(),
      );
    });
  }
}

typedef OnSelectFunction = void Function(String? value);
typedef OnSetInputValue = void Function(String value);

class _RadioOption extends StatelessWidget {
  final Option option;
  final SingleChoicesFormValue formValue;
  final TextEditingController? currentText;
  final OnSelectFunction onSelect;
  final OnSetInputValue onSetInputValue;

  const _RadioOption(this.option, this.formValue, this.currentText,
      this.onSelect, this.onSetInputValue,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Radio<String>(
          groupValue: formValue.value,
          value: option.value,
          onChanged: onSelect,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                child: Text(
                  option.label,
                ),
                onTap: () {
                  onSelect(option.value);
                },
              ),
              if (option.input && formValue.value == option.value)
                TextField(
                  controller: currentText,
                  onChanged: onSetInputValue,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    errorText:
                        formValue.isValid ? null : formValue.invalidateMessage,
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}
