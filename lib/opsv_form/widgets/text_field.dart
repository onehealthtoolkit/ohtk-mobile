part of 'widgets.dart';

class FormTextField extends StatefulWidget {
  final opsv.TextField field;

  const FormTextField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
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
          suffixIcon: (widget.field.scan != null && widget.field.scan!)
              ? IconButton(
                  splashColor: Colors.blueGrey.shade200,
                  icon: Icon(
                    Icons.qr_code_scanner,
                    color: Theme.of(context).primaryColor,
                    size: 20.w,
                  ),
                  onPressed: () async {
                    var result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QrScanner(),
                      ),
                    );

                    if (context.mounted) {
                      if (result != null) {
                        widget.field.value = result;
                      } else {
                        var errorMessage = SnackBar(
                          content: Text(
                              AppLocalizations.of(context)?.invalidQrcode ??
                                  'Invalid qrcode'),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(errorMessage);
                      }
                    }
                  },
                )
              : null,
        ),
        onChanged: (val) {
          widget.field.value = val;
        },
      );
    });
  }
}
