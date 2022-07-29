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
        var datetime = widget.field.value;
        final buttonStyle = ButtonStyle(
          foregroundColor: MaterialStateProperty.all(
              datetime != null ? Colors.grey.shade700 : Colors.black54),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          ),
        );

        return ValidationWrapper(
          widget.field,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.field.label != null && widget.field.label != "")
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    widget.field.label!,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              DecoratedBox(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  border: Border.fromBorderSide(
                    BorderSide(
                      color: Colors.black45,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    TextButton(
                      style: buttonStyle,
                      onPressed: () =>
                          _showDialog(datetime, CupertinoDatePickerMode.date),
                      child: Text(
                        datetime != null
                            ? '${datetime.day}/${datetime.month}/${datetime.year}'
                            : 'DD/MM/YYYY',
                        textScaleFactor: 1.2,
                      ),
                    ),
                    if (widget.field.withTime)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextButton(
                          style: buttonStyle,
                          onPressed: () => _showDialog(
                              datetime, CupertinoDatePickerMode.time),
                          child: Text(
                            datetime != null
                                ? '${datetime.hour}:${datetime.minute}'
                                : 'HH:MM',
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDialog(DateTime? datetime, CupertinoDatePickerMode mode) {
    final child = CupertinoDatePicker(
      initialDateTime: datetime,
      mode: mode,
      use24hFormat: true,
      onDateTimeChanged: (DateTime newTime) {
        widget.field.value = newTime;
      },
    );
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }
}
