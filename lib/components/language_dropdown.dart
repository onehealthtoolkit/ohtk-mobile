import 'package:flutter/material.dart';

class LanguageDropdown extends StatelessWidget {
  final Function(String?) onChanged;
  final String value;

  const LanguageDropdown(
      {super.key, required this.onChanged, required this.value});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: const InputDecoration(
          // labelText: AppLocalizations.of(context)!.laguageLabel,
          contentPadding: EdgeInsets.symmetric(vertical: 5.0),
          prefixIcon: Icon(
            Icons.language,
            size: 24,
          ),
        ),
        hint: const Text("Language"),
        value: value,
        onChanged: onChanged,
        items: const [
          DropdownMenuItem(child: Text("English"), value: "en"),
          DropdownMenuItem(child: Text("ภาษาไทย"), value: "th"),
          DropdownMenuItem(child: Text("ភាសាខ្មែរ"), value: "km"),
          DropdownMenuItem(child: Text("ພາສາລາວ"), value: "lo"),
        ]);
  }
}
