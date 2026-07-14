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
            TextInputAction.next,
        onEditingComplete: focusController == null
            ? null
            : () => focusController.completeEditing(context, widget.field),
        decoration: ohtkInputDecoration(
          hintText: widget.field.label,
          suffixText: widget.field.suffixLabel,
          isInvalid: isInvalid,
          suffixIcon: (widget.field.scan != null && widget.field.scan!)
              ? _QrScanSuffix(
                  onScan: () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QrScanner(),
                      ),
                    );
                    if (!context.mounted) return;
                    if (result != null) {
                      widget.field.value = result;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: incidentsErrorRed,
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            AppLocalizations.of(context)?.invalidQrcode ??
                                'Invalid qrcode',
                          ),
                        ),
                      );
                    }
                  },
                )
              : null,
        ),
        onChanged: (val) {
          widget.field.value = val;
          if (isInvalid) widget.field.clearError();
        },
      );
    });
  }
}

class _QrScanSuffix extends StatelessWidget {
  final VoidCallback onScan;

  const _QrScanSuffix({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 6, 4),
      child: Material(
        color: _ohtkFormBrandTint(0.10),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onScan,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(
              Icons.qr_code_scanner,
              color: _ohtkFormBrand,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
