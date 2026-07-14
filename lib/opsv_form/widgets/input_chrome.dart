part of 'widgets.dart';

const _ohtkInputBaseStyle = TextStyle(
  fontFamily: incidentsFontFamily,
  fontFamilyFallback: incidentsFontFamilyFallback,
  fontSize: 15,
  color: incidentsInk,
);

const _ohtkInputHintStyle = TextStyle(
  fontFamily: incidentsFontFamily,
  fontFamilyFallback: incidentsFontFamilyFallback,
  fontSize: 15,
  color: incidentsMuted,
);

const _ohtkInputSuffixStyle = TextStyle(
  fontFamily: incidentsFontFamily,
  fontFamilyFallback: incidentsFontFamilyFallback,
  fontSize: 13,
  color: incidentsMuted,
);

InputDecoration ohtkInputDecoration({
  String? hintText,
  String? suffixText,
  Widget? suffixIcon,
  bool isInvalid = false,
  bool isMultiline = false,
}) {
  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );
  final idleColor = isInvalid ? incidentsErrorRed : incidentsHair;
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(
      horizontal: 12,
      vertical: isMultiline ? 14 : 13,
    ),
    hintText: hintText,
    hintStyle: _ohtkInputHintStyle,
    suffixText: suffixText,
    suffixStyle: _ohtkInputSuffixStyle,
    suffixIcon: suffixIcon,
    suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    border: border(idleColor, 1.5),
    enabledBorder: border(idleColor, 1.5),
    focusedBorder: border(
      isInvalid ? incidentsErrorRed : _ohtkFormBrand,
      1.8,
    ),
    errorBorder: border(incidentsErrorRed, 1.5),
    focusedErrorBorder: border(incidentsErrorRed, 1.8),
  );
}

Widget ohtkFieldLabel(String? label) {
  if (label == null || label.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      label,
      style: const TextStyle(
        fontFamily: incidentsFontFamily,
        fontFamilyFallback: incidentsFontFamilyFallback,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: incidentsMuted,
        height: 1.4,
      ),
    ),
  );
}

TextStyle get ohtkInputTextStyle => _ohtkInputBaseStyle;
