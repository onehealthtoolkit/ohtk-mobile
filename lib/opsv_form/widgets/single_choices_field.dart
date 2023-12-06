part of 'widgets.dart';

class FormSingleChoicesField extends StatefulWidget {
  final opsv.SingleChoicesField field;

  const FormSingleChoicesField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormSingleChoicesField> createState() => _FormSingleChoicesFieldState();
}

class _FormSingleChoicesFieldState extends State<FormSingleChoicesField> {
  final TextEditingController _controller = TextEditingController();
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      widget.field.value;
      widget.field.invalidMessage;
      widget.field
          .isValid; // make sure that this field is registered in mobx listener

      if (!widget.field.display) {
        return Container();
      }

      var currentText = widget.field.text ?? '';
      if (currentText != _controller.text) {
        _controller.value = TextEditingValue(
            text: currentText,
            selection: TextSelection.collapsed(offset: currentText.length));
      }

      onSelect(value) {
        widget.field.value = value;
      }

      onSetInputValue(value) {
        widget.field.text = value;
      }

      var tiles = widget.field.options.map((option) => _RadioOption(
            option,
            widget.field,
            _controller,
            onSelect,
            onSetInputValue,
          ));
      return ValidationWrapper(
        widget.field,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.field.label != null && widget.field.label != "")
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 0, top: 0),
                child: Text(
                  widget.field.label!,
                  textScaleFactor: 1.1,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ...tiles.toList(),
          ],
        ),
      );
    });
  }
}

typedef OnSelectFunction = void Function(String? value);
typedef OnSetInputValue = void Function(String value);

class _RadioOption extends StatelessWidget {
  final opsv.ChoiceOption option;
  final opsv.SingleChoicesField field;
  final TextEditingController? currentText;
  final OnSelectFunction onSelect;
  final OnSetInputValue onSetInputValue;
  final AppTheme apptheme = locator<AppTheme>();

  _RadioOption(this.option, this.field, this.currentText, this.onSelect,
      this.onSetInputValue,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 4,
        ),
        Material(
          child: InkWell(
            onTap: () {
              onSelect(option.value);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Radio<String>(
                  groupValue: field.value,
                  activeColor: apptheme.primary,
                  value: option.value,
                  onChanged: onSelect,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (option.textInput && field.value == option.value)
                        TextField(
                          controller: currentText,
                          style: Theme.of(context).textTheme.bodyLarge,
                          onTap: () {
                            field.clearError();
                          },
                          onChanged: onSetInputValue,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            errorText: field.invalidTextInputMessage,
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (option.textInput && field.value == option.value)
          const SizedBox(
            height: 4,
          ),
        CustomPaint(
          painter: DashedLinePainter(backgroundColor: apptheme.primary),
          child: Container(
            height: 1,
          ),
        ),
      ],
    );
  }
}
