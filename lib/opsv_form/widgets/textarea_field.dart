part of 'widgets.dart';

class FormTextareaField extends StatefulWidget {
  final opsv.TextareaField field;

  const FormTextareaField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormTextareaField> createState() => _FormTextareaFieldState();
}

class _FormTextareaFieldState extends State<FormTextareaField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      if (!widget.field.display) return const SizedBox.shrink();
      final value = widget.field.value ?? '';
      if (value != _controller.text) {
        _controller.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
      final isInvalid = !widget.field.isValid;
      final focusController = FormTextInputFocusScope.maybeOf(context);
      return TextField(
        controller: _controller,
        focusNode: focusController?.nodeFor(widget.field),
        style: ohtkInputTextStyle,
        textInputAction: focusController?.textInputActionFor(widget.field) ??
            TextInputAction.newline,
        minLines: widget.field.rows,
        maxLines: null,
        keyboardType: TextInputType.multiline,  
        decoration: ohtkInputDecoration(
          hintText: widget.field.label,
          suffixText: widget.field.suffixLabel,
          isInvalid: isInvalid,
          isMultiline: true,
        ),
        onChanged: (val) {
          widget.field.value = val;
          if (isInvalid) widget.field.clearError();
        },
      );
    });
  }
}
