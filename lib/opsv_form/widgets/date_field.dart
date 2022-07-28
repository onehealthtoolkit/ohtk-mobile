part of 'widgets.dart';

class FormDateField extends StatefulWidget {
  final opsv.DateField field;

  const FormDateField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormDateField> createState() => _FormDateFieldState();
}

class _FormDateFieldState extends State<FormDateField> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) {
        widget.field.isValid;
        return DateTimeField(
          dateFormat:
              DateFormat.yMMMd(Localizations.localeOf(context).toString()),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: widget.field.label,
            suffixText: widget.field.suffixLabel != null
                ? widget.field.suffixLabel!
                : null,
            helperText: widget.field.description != null
                ? widget.field.description!
                : null,
            errorText:
                widget.field.isValid ? null : widget.field.invalidMessage,
          ),
          mode: DateTimeFieldPickerMode.date,
          selectedDate: widget.field.value,
          onDateSelected: (DateTime value) {
            widget.field.value = value;
          },
        );
      },
    );
  }
}
