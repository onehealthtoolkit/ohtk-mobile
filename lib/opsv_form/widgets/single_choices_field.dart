part of 'widgets.dart';

class FormSingleChoicesField extends StatefulWidget {
  final opsv.SingleChoicesField field;

  const FormSingleChoicesField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormSingleChoicesField> createState() => _FormSingleChoicesFieldState();
}

class _FormSingleChoicesFieldState extends State<FormSingleChoicesField> {
  final TextEditingController _otherController = TextEditingController();

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      if (!widget.field.display) return const SizedBox.shrink();
      final field = widget.field;
      // Read all observables synchronously inside the Observer scope so MobX
      // tracks them. Closures passed to child widgets execute outside this
      // scope and would not retrigger this builder.
      final selectedValue = field.value;
      final selectedText = field.text ?? '';
      final invalidTextInputMessage = field.invalidTextInputMessage;
      if (selectedText != _otherController.text) {
        _otherController.value = TextEditingValue(
          text: selectedText,
          selection: TextSelection.collapsed(offset: selectedText.length),
        );
      }
      return _ChoiceRowList(
        options: field.options,
        builder: (option, isFirst, isLast) {
          final isSelected = selectedValue == option.value;
          return _RadioRow(
            option: option,
            selected: isSelected,
            isLast: isLast,
            onTap: () {
              field.value = option.value;
              if (!field.isValid) field.clearError();
            },
            inlineText: option.textInput && isSelected
                ? _OtherInlineInput(
                    controller: _otherController,
                    invalidMessage: invalidTextInputMessage,
                    onChanged: (val) {
                      field.text = val;
                      if (!field.isValid) field.clearError();
                    },
                  )
                : null,
          );
        },
      );
    });
  }
}

class _RadioRow extends StatelessWidget {
  final opsv.ChoiceOption option;
  final bool selected;
  final bool isLast;
  final VoidCallback onTap;
  final Widget? inlineText;

  const _RadioRow({
    required this.option,
    required this.selected,
    required this.isLast,
    required this.onTap,
    this.inlineText,
  });

  @override
  Widget build(BuildContext context) {
    return _ChoiceRowShell(
      isLast: isLast,
      onTap: onTap,
      indicator: _RadioIndicator(selected: selected),
      label: option.label,
      inlineText: inlineText,
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  final bool selected;
  const _RadioIndicator({required this.selected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? _ohtkFormBrand : incidentsHair,
            width: 2,
          ),
        ),
        child: selected
            ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _ohtkFormBrand,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class FormMultipleChoicesField extends StatefulWidget {
  final opsv.MultipleChoicesField field;

  const FormMultipleChoicesField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormMultipleChoicesField> createState() =>
      _FormMultipleChoicesFieldState();
}

class _FormMultipleChoicesFieldState extends State<FormMultipleChoicesField> {
  final Map<String, TextEditingController> _controllers = {};

  TextEditingController _controllerFor(String value) =>
      _controllers.putIfAbsent(value, () => TextEditingController());

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      if (!widget.field.display) return const SizedBox.shrink();
      final field = widget.field;
      // Eagerly read all observables for each option inside this Observer
      // scope so MobX subscribes. Deferring these reads into child builders
      // breaks reactivity.
      final selections = <String, bool>{
        for (final opt in field.options) opt.value: field.valueFor(opt.value),
      };
      final texts = <String, String>{
        for (final opt in field.options)
          opt.value: field.textValueFor(opt.value)?.value ?? '',
      };
      final textErrors = <String, String?>{
        for (final opt in field.options)
          opt.value: field.invalidTextMessageFor(opt.value)?.value,
      };
      return _ChoiceRowList(
        options: field.options,
        builder: (option, isFirst, isLast) {
          final isChecked = selections[option.value] ?? false;
          final controller = _controllerFor(option.value);
          final text = texts[option.value] ?? '';
          if (text != controller.text) {
            controller.value = TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
            );
          }
          return _CheckRow(
            option: option,
            checked: isChecked,
            isLast: isLast,
            onTap: () {
              field.setSelectedFor(option.value, !isChecked);
              if (!field.isValid) field.clearError();
            },
            inlineText: option.textInput && isChecked
                ? _OtherInlineInput(
                    controller: controller,
                    invalidMessage: textErrors[option.value],
                    onChanged: (val) {
                      field.setTextValueFor(option.value, val);
                      if (!field.isValid) field.clearError();
                    },
                  )
                : null,
          );
        },
      );
    });
  }
}

class _CheckRow extends StatelessWidget {
  final opsv.ChoiceOption option;
  final bool checked;
  final bool isLast;
  final VoidCallback onTap;
  final Widget? inlineText;

  const _CheckRow({
    required this.option,
    required this.checked,
    required this.isLast,
    required this.onTap,
    this.inlineText,
  });

  @override
  Widget build(BuildContext context) {
    return _ChoiceRowShell(
      isLast: isLast,
      onTap: onTap,
      indicator: _CheckIndicator(checked: checked),
      label: option.label,
      inlineText: inlineText,
    );
  }
}

class _CheckIndicator extends StatelessWidget {
  final bool checked;

  const _CheckIndicator({required this.checked});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: checked ? _ohtkFormBrand : Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: checked ? _ohtkFormBrand : incidentsHair,
          width: 2,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _ChoiceRowList extends StatelessWidget {
  final List<opsv.ChoiceOption> options;
  final Widget Function(opsv.ChoiceOption, bool isFirst, bool isLast) builder;

  const _ChoiceRowList({required this.options, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < options.length; i++)
          builder(options[i], i == 0, i == options.length - 1),
      ],
    );
  }
}

class _ChoiceRowShell extends StatelessWidget {
  final bool isLast;
  final VoidCallback onTap;
  final Widget indicator;
  final String label;
  final Widget? inlineText;

  const _ChoiceRowShell({
    required this.isLast,
    required this.onTap,
    required this.indicator,
    required this.label,
    this.inlineText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: isLast
            ? null
            : const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: incidentsHair, width: 1),
                ),
              ),
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: indicator,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: incidentsFontFamily,
                      fontFamilyFallback: incidentsFontFamilyFallback,
                      fontSize: 15,
                      color: incidentsInk,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            if (inlineText != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
                child: inlineText,
              ),
          ],
        ),
      ),
    );
  }
}

class _OtherInlineInput extends StatelessWidget {
  final TextEditingController controller;
  final String? invalidMessage;
  final ValueChanged<String> onChanged;

  const _OtherInlineInput({
    required this.controller,
    required this.invalidMessage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;
    final isInvalid = invalidMessage != null;
    return TextField(
      controller: controller,
      style: ohtkInputTextStyle,
      onChanged: onChanged,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintText: localize.choiceOtherPlaceholder,
        hintStyle: _ohtkInputHintStyle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isInvalid ? incidentsErrorRed : _ohtkFormBrand,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isInvalid ? incidentsErrorRed : _ohtkFormBrand,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isInvalid ? incidentsErrorRed : _ohtkFormBrand,
            width: 1.8,
          ),
        ),
      ),
    );
  }
}
