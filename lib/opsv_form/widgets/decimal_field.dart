part of 'widgets.dart';

class FormDecimalField extends StatefulWidget {
  final opsv.DecimalField field;

  const FormDecimalField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormDecimalField> createState() => _FormDecimalFieldState();
}

class _FormDecimalFieldState extends State<FormDecimalField> {
  final TextEditingController _controller = TextEditingController();
  final _logger = locator<Logger>();

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      var value = widget.field.value?.toString() ?? '';

      if (!widget.field.display) {
        return Container();
      }

      if (value != _controller.text) {
        _controller.value = TextEditingValue(
            text: value,
            selection: TextSelection.collapsed(offset: value.length));
      }

      return TextField(
        controller: _controller,
        textInputAction: TextInputAction.next,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: false),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
          TextInputFormatter.withFunction((oldValue, newValue) {
            try {
              final text = newValue.text;
              if (text.isNotEmpty) double.parse(text);
              return newValue;
            } catch (e) {
              _logger.e(e);
            }
            return oldValue;
          }),
        ],
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: widget.field.label,
          suffixText: widget.field.suffixLabel != null
              ? widget.field.suffixLabel!
              : null,
          helperText: widget.field.description != null
              ? widget.field.description!
              : null,
          errorText: widget.field.isValid ? null : widget.field.invalidMessage,
        ),
        onChanged: (val) {
          try {
            widget.field.value = Decimal.parse(val);
          } on FormatException catch (_) {
            _logger.e("parsing error ${val.toString()}");
            widget.field.value = null;
          }
        },
      );
    });
  }
}
