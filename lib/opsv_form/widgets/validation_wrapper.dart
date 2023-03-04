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
                    borderRadius: BorderRadius.circular(4),
                  )
                : BoxDecoration(
                    border: Border.all(
                      color: apptheme.bg2,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.child,
                if (!widget.field.isValid)
                  Text(widget.field.invalidMessage ?? "",
                      style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }
}
