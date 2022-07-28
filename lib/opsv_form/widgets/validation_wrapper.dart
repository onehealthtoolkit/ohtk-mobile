part of 'widgets.dart';

class ValidationWrapper extends StatefulWidget {
  final opsv.Field field;
  final Widget child;

  const ValidationWrapper(this.field, {Key? key, required this.child})
      : super(key: key);

  @override
  State<ValidationWrapper> createState() => _ValidationWrapperState();
}

class _ValidationWrapperState extends State<ValidationWrapper> {
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      return Container(
        decoration: (widget.field.isValid == false)
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
            if (widget.field.invalidMessage != "")
              Text(widget.field.invalidMessage ?? ""),
          ],
        ),
      );
    });
  }
}
