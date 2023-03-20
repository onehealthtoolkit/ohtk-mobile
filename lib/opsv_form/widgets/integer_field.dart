part of 'widgets.dart';

class FormIntegerField extends StatefulWidget {
  final opsv.IntegerField field;

  const FormIntegerField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormIntegerField> createState() => _FormIntegerFieldState();
}

class _FormIntegerFieldState extends State<FormIntegerField> {
  final TextEditingController _controller = TextEditingController();
  final _logger = locator<Logger>();
  final AppTheme appTheme = locator<AppTheme>();

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
        style: TextStyle(
          color: appTheme.inputTextColor,
          fontFamily: appTheme.font,
          fontWeight: FontWeight.w400,
        ),
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: widget.field.label,
          suffixText: widget.field.suffixLabel != null
              ? widget.field.suffixLabel!
              : null,
          helperText: widget.field.description != null
              ? widget.field.description!
              : null,
          errorText: widget.field.invalidMessage,
        ),
        onChanged: (val) {
          try {
            widget.field.value = int.parse(val);
          } on FormatException catch (_) {
            _logger.e("parsing error ${val.toString()}");
            widget.field.value = null;
          }
        },
      );
    });
  }
}
