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
  final AppTheme apptheme = locator<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: (widget.field.isValid == false)
                ? BoxDecoration(
                    border: Border.all(
                      color: Colors.red,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(apptheme.borderRadius),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.child,
                if (!widget.field.isValid)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: Text(
                      widget.field.invalidMessage ?? "",
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }
}
