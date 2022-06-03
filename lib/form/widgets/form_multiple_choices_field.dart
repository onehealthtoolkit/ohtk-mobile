import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:podd_app/form/form_data/form_data.dart';
import 'package:podd_app/form/form_data/form_values/multiple_choices_form_value.dart';
import 'package:podd_app/form/ui_definition/fields/option_field_ui_definition.dart';
import 'package:podd_app/form/ui_definition/form_ui_definition.dart';
import 'package:podd_app/form/widgets/validation_wrapper.dart';
import 'package:provider/provider.dart';

class FormMultipleChoicesField extends StatefulWidget {
  final MultipleChoicesFieldUIDefinition fieldDefinition;

  const FormMultipleChoicesField(this.fieldDefinition, {Key? key})
      : super(key: key);

  @override
  State<FormMultipleChoicesField> createState() =>
      _FormMultipleChoicesFieldState();
}

class _FormMultipleChoicesFieldState extends State<FormMultipleChoicesField> {
  @override
  Widget build(BuildContext context) {
    var formData = Provider.of<FormData>(context);
    var formValue = formData.getFormValue(widget.fieldDefinition.name)
        as MultipleChoicesFormValue;
    return Observer(
      builder: (BuildContext context) {
        return ValidationWrapper(
          formValue,
          child: Column(
            children: widget.fieldDefinition.options
                .map((option) => _OptionWidget(formValue, option))
                .toList(),
          ),
        );
      },
    );
  }
}

class _OptionWidget extends StatelessWidget {
  final MultipleChoicesFormValue formValue;
  final Option option;
  final TextEditingController _controller = TextEditingController();

  _OptionWidget(this.formValue, this.option, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        var _checkValue = formValue.valueFor(option.value);
        var _text = formValue.textValueFor(option.value)?.value ?? '';
        var _invalidTextMessage =
            formValue.invalidTextMessageFor(option.value)?.value;

        if (_text != _controller.text) {
          _controller.value = TextEditingValue(
              text: _text,
              selection: TextSelection.collapsed(offset: _text.length));
        }
        return Row(
          children: [
            Checkbox(
                value: _checkValue,
                onChanged: (value) {
                  formValue.setSelectedFor(option.value, value ?? false);
                }),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    child: Text(option.label),
                    onTap: () {
                      formValue.setSelectedFor(option.value, !_checkValue);
                    },
                  ),
                  if (option.textInput && _checkValue)
                    TextField(
                      controller: _controller,
                      onChanged: (val) {
                        formValue.setTextValueFor(option.value, val);
                      },
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          errorText: _invalidTextMessage),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
