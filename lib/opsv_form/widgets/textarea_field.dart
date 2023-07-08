part of 'widgets.dart';

class FormTextareaField extends StatefulWidget {
  final opsv.TextareaField field;

  const FormTextareaField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormTextareaField> createState() => _FormTextareaFieldState();
}

class _FormTextareaFieldState extends State<FormTextareaField> {
  final AppTheme appTheme = locator<AppTheme>();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      var value = widget.field.value ?? '';

      if (!widget.field.display) {
        return Container();
      }
      if (value != _controller.text) {
        _controller.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
      return TextField(
        controller: _controller,
        style: TextStyle(
          color: appTheme.inputTextColor,
          fontFamily: appTheme.font,
          fontWeight: FontWeight.w400,
        ),
        textInputAction: TextInputAction.next,
        minLines: widget.field.rows,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          // border: const OutlineInputBorder(),
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
          widget.field.value = val;
        },
      );
    });
  }
}
