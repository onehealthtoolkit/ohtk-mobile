import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:podd_app/form/form_data/form_values/base_form_value.dart';

class ValidationWrapper extends StatefulWidget {
  final IValidatable validatable;
  final Widget child;

  const ValidationWrapper(this.validatable, {Key? key, required this.child})
      : super(key: key);

  @override
  State<ValidationWrapper> createState() => _ValidationWrapperState();
}

class _ValidationWrapperState extends State<ValidationWrapper> {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      return Container(
        decoration: (widget.validatable.isValid == false)
            ? BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.child,
            if (widget.validatable.invalidMessage != "")
              Text(widget.validatable.invalidMessage ?? ""),
          ],
        ),
      );
    });
  }
}
