import 'package:flutter/material.dart';

class DisplayField extends StatelessWidget {
  final String label;
  final String? value;
  final CrossAxisAlignment crossAxisAlignment;

  const DisplayField(
      {super.key,
      required this.label,
      required this.value,
      this.crossAxisAlignment = CrossAxisAlignment.start});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: Theme.of(context).inputDecorationTheme.labelStyle,
        ),
        const SizedBox(height: 2),
        Text(
          value ?? "",
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ],
    );
  }
}
