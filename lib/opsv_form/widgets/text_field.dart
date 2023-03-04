part of 'widgets.dart';

class FormTextField extends StatefulWidget {
  final opsv.TextField field;

  const FormTextField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
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
        textInputAction: TextInputAction.next,
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
