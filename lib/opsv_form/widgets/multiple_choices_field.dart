part of 'widgets.dart';

class FormMultipleChoicesField extends StatefulWidget {
  final opsv.MultipleChoicesField field;

  const FormMultipleChoicesField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormMultipleChoicesField> createState() =>
      _FormMultipleChoicesFieldState();
}

class _FormMultipleChoicesFieldState extends State<FormMultipleChoicesField> {
  final AppTheme appTheme = locator<AppTheme>();
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) {
        widget.field.isValid;

        if (!widget.field.display) {
          return Container();
        }

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
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ...widget.field.options
                  .map((option) => _OptionWidget(widget.field, option))
                  .toList(),
            ],
          ),
        );
      },
    );
  }
}

class _OptionWidget extends StatelessWidget {
  final opsv.MultipleChoicesField field;
  final opsv.ChoiceOption option;
  final TextEditingController _controller = TextEditingController();
  final AppTheme apptheme = locator<AppTheme>();

  _OptionWidget(this.field, this.option, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        var checkValue = field.valueFor(option.value);
        var text = field.textValueFor(option.value)?.value ?? '';
        var invalidTextMessage =
            field.invalidTextMessageFor(option.value)?.value;

        if (text != _controller.text) {
          _controller.value = TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length));
        }
        return Column(
          children: [
            const SizedBox(
              height: 4,
            ),
            Material(
              child: InkWell(
                onTap: () {
                  field.setSelectedFor(option.value, !checkValue);
                },
                child: Row(
                  children: [
                    Checkbox(
                        value: checkValue,
                        activeColor: apptheme.primary,
                        onChanged: (value) {
                          field.setSelectedFor(option.value, value ?? false);
                        }),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.label,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          if (option.textInput && checkValue)
                            TextField(
                              controller: _controller,
                              style: Theme.of(context).textTheme.bodyLarge,
                              onChanged: (val) {
                                field.setTextValueFor(option.value, val);
                              },
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  errorText: invalidTextMessage),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CustomPaint(
              painter: DashedLinePainter(backgroundColor: apptheme.primary),
              child: Container(
                height: 1,
              ),
            ),
          ],
        );
      },
    );
  }
}
