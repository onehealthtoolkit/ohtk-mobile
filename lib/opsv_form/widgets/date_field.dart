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
              widget.field.separatedFields
                  ? _DateTimeDropdown(widget.field)
                  : _DateTimePicker(widget.field)
            ],
          ),
        );
      },
    );
  }
}

class _DateTimeDropdown extends StatelessWidget {
  final opsv.DateField field;
  final currentYear = DateTime.now().year;

  _DateTimeDropdown(this.field, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      return Row(
        children: [
          Expanded(child: _dayDropdown(field), flex: 1),
          const SizedBox(width: 6, child: null),
          Expanded(child: _monthDropdown(field, context), flex: 2),
          const SizedBox(width: 6, child: null),
          Expanded(child: _yearDropdown(field), flex: 1),
          if (field.withTime)
            const Text(
              ": ",
              style: TextStyle(fontWeight: FontWeight.bold),
              textScaleFactor: 1.2,
            ),
          if (field.withTime) Expanded(child: _hourDropdown(field)),
          if (field.withTime) Expanded(child: _minuteDropdown(field)),
        ],
      );
    });
  }

  bool _isLeapYear(int? year) {
    return year != null &&
        ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0);
  }

  TextStyle _optionStyle(bool enabled) => TextStyle(
        color: enabled ? Colors.grey[700] : Colors.black26,
        fontWeight: FontWeight.w500,
      );

  // Day is from 1-31
  _dayDropdown(opsv.DateField field) {
    final items = List<int>.generate(31, (int index) => index).map((e) {
      final day = e + 1;
      bool enabled = true;
      if (field.month != null) {
        if (day == 29 && field.month == 2 && !_isLeapYear(field.year)) {
          enabled = false;
        }
        if (day == 30 && field.month == 2) {
          enabled = false;
        }
        if (day == 31 && [2, 4, 6, 9, 11].contains(field.month)) {
          enabled = false;
        }
      }
      return DropdownMenuItem(
        child: Text(day.toString(), style: _optionStyle(enabled)),
        value: day,
        enabled: enabled,
      );
    }).toList();

    return DropdownButtonFormField(
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      hint: const Text("D"),
      value: field.day,
      onChanged: (int? value) {
        field.day = value;
      },
      items: items,
    );
  }

  // month value is between 1-12
  _monthDropdown(opsv.DateField field, BuildContext context) {
    final locale = Localizations.localeOf(context);

    var formatter = DateFormat.MMMM(locale.toString());
    final items = List<int>.generate(12, (int index) => index).map((e) {
      final month = e + 1;
      bool enabled = true;
      if (field.day != null) {
        if (field.day == 29 && month == 2 && !_isLeapYear(field.year)) {
          enabled = false;
        }
        if (field.day == 30 && month == 2) {
          enabled = false;
        }
        if (field.day == 31 && [2, 4, 6, 9, 11].contains(month)) {
          enabled = false;
        }
      }

      final monthStr = formatter.format(DateTime(2000, month, 1));

      return DropdownMenuItem(
        child: Text(monthStr, style: _optionStyle(enabled)),
        value: month,
        enabled: enabled,
      );
    }).toList();

    return DropdownButtonFormField(
      hint: const Text("M"),
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      value: field.month,
      onChanged: (int? value) {
        field.month = value;
      },
      items: items,
    );
  }

  // Year range is between +/- 10 years from now
  _yearDropdown(opsv.DateField field) {
    final items = List<int>.generate(20, (int index) => index).map((e) {
      final year = e + currentYear - 9;
      bool enabled = true;
      if (field.day != null && field.month != null) {
        if (field.day == 29 && field.month == 2 && !_isLeapYear(year)) {
          enabled = false;
        }
      }
      return DropdownMenuItem(
        child: Text(year.toString(), style: _optionStyle(enabled)),
        value: year,
        enabled: enabled,
      );
    }).toList();

    return DropdownButtonFormField(
      hint: const Text("Y"),
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      value: field.year,
      onChanged: (int? value) {
        field.year = value;
      },
      items: items,
    );
  }

  _hourDropdown(opsv.DateField field) {
    final items = List<int>.generate(24, (int index) => index).map((e) {
      return DropdownMenuItem(
        child: Text((e / 10 >= 1 ? "" : "0") + e.toString(),
            style: _optionStyle(true)),
        value: e,
      );
    }).toList();

    return DropdownButtonFormField(
      hint: const Text("hh"),
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      value: field.hour,
      onChanged: (int? value) {
        field.hour = value;
      },
      items: items,
    );
  }

  _minuteDropdown(opsv.DateField field) {
    final items = List<int>.generate(60, (int index) => index).map((e) {
      return DropdownMenuItem(
        child: Text((e / 10 >= 1 ? "" : "0") + e.toString(),
            style: _optionStyle(true)),
        value: e,
      );
    }).toList();

    return DropdownButtonFormField(
      hint: const Text("mm"),
      decoration: const InputDecoration(
        border: InputBorder.none,
      ),
      value: field.minute,
      onChanged: (int? value) {
        field.minute = value;
      },
      items: items,
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  final opsv.DateField field;
  const _DateTimePicker(this.field, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      var datetime = field.value;

      if (!field.display) {
        return Container();
      }

      final buttonStyle = ButtonStyle(
        foregroundColor: MaterialStateProperty.all(
            datetime != null ? Colors.grey.shade700 : Colors.black54),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        ),
      );

      return Row(
        children: [
          TextButton(
            style: buttonStyle,
            onPressed: () =>
                _showDialog(context, datetime, CupertinoDatePickerMode.date),
            child: Text(
              datetime != null
                  ? '${datetime.day}/${datetime.month}/${datetime.year}'
                  : 'DD/MM/YYYY',
              style: TextStyle(
                fontSize: 15.sp,
              ),
            ),
          ),
          if (field.withTime)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextButton(
                style: buttonStyle,
                onPressed: () => _showDialog(
                    context, datetime, CupertinoDatePickerMode.time),
                child: Text(
                  datetime != null
                      ? '${datetime.hour}:${datetime.minute}'
                      : 'HH:MM',
                  style: TextStyle(
                    fontSize: 15.sp,
                  ),
                ),
              ),
            )
        ],
      );
    });
  }

  Future<void> _showDialog(BuildContext context, DateTime? datetime,
      CupertinoDatePickerMode mode) async {
    if (Platform.isIOS) {
      final child = CupertinoDatePicker(
        initialDateTime: datetime,
        mode: mode,
        use24hFormat: true,
        onDateTimeChanged: (DateTime newTime) {
          field.value = newTime;
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
    } else {
      final DateTime now = DateTime.now();
      if (mode == CupertinoDatePickerMode.date) {
        final DateTime? picked = await showDatePicker(
          context: context,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 50),
          initialDate: datetime ?? now,
        );
        if (picked != null) field.value = picked;
      } else {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: (datetime != null)
              ? TimeOfDay(
                  hour: datetime.hour,
                  minute: datetime.minute,
                )
              : TimeOfDay.now(),
        );
        if (picked != null) {
          if (datetime != null) {
            field.value = DateTime(datetime.year, datetime.month, datetime.day,
                picked.hour, picked.minute);
          } else {
            field.value = DateTime(
                now.year, now.month, now.day, picked.hour, picked.minute);
          }
        }
      }
    }
  }
}
