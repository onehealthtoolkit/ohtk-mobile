part of 'widgets.dart';

class FormSubformField extends StatefulWidget {
  final opsv.SubformField field;

  const FormSubformField(this.field, {Key? key}) : super(key: key);

  @override
  State<FormSubformField> createState() => _FormSubformFieldState();
}

class _FormSubformFieldState extends State<FormSubformField> {
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (BuildContext context) {
      widget.field.isValid;
      if (!widget.field.display) {
        return Container();
      }
      return ListView(
        padding: EdgeInsets.fromLTRB(0, 8.w, 0, 8.w),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          _Label(widget.field),
          _ItemList(widget.field),
        ],
      );
    });
  }
}

class _ItemList extends StatelessObserverWidget {
  final AppTheme appTheme = locator<AppTheme>();
  final opsv.SubformField field;

  _ItemList(this.field, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(left: 8.w),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: field.forms.length,
      itemBuilder: (context, index) {
        var subform = field.forms[index];
        return Dismissible(
          direction: DismissDirection.horizontal,
          background: _deletingTrash(DismissDirection.startToEnd),
          secondaryBackground: _deletingTrash(DismissDirection.endToStart),
          key: Key(subform.ref.id),
          onDismissed: (direction) {
            field.deleteSubform(subform);
          },
          child: GestureDetector(
            onTap: () {
              var title = field.getSubformRecordTitle(subform.name);

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      SubformFormView(field.form.testFlag, title, subform.ref),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.only(top: 8.0.w),
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titleDesc(context, index),
                  _separator(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _deletingTrash(DismissDirection direction) => ColoredBox(
        color: appTheme.warn,
        child: Align(
          alignment: direction == DismissDirection.startToEnd
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Icon(Icons.delete_forever, color: Colors.white),
          ),
        ),
      );

  Row _titleDesc(BuildContext context, int index) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.forms[index].evaluatedTitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 15.sp),
              ),
              if (field.forms[index].evaluatedDescription.isNotEmpty)
                Text(
                  field.forms[index].evaluatedDescription,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 12.sp, color: appTheme.sub1),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.w),
          child: Icon(
            Icons.keyboard_arrow_right_rounded,
            size: 24.w,
            color: appTheme.sub1,
          ),
        ),
      ],
    );
  }

  Widget _separator() {
    return Container(
      padding: EdgeInsets.only(top: 8.w),
      height: 8.w,
      width: double.infinity,
      child: CustomPaint(
        painter: DashedLinePainter(backgroundColor: appTheme.primary),
      ),
    );
  }
}

class _Label extends StatefulObserverWidget {
  final opsv.SubformField field;

  const _Label(this.field, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LabelState();
  }
}

class _LabelState extends State<_Label> {
  final AppTheme appTheme = locator<AppTheme>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: appTheme.primary),
        borderRadius: BorderRadius.circular(appTheme.borderRadius),
      ),
      padding: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.field.label ?? '',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: 24.w,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(24.w, 24.w),
                shape: const CircleBorder(),
              ),
              onPressed: () {
                var subform = widget.field.addSubform();

                if (subform != null) {
                  var title = widget.field.getSubformRecordTitle(subform.name);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SubformFormView(
                          widget.field.form.testFlag, title, subform.ref),
                    ),
                  );
                }
              },
              child: Icon(Icons.add, size: 16.w),
            ),
          ),
        ],
      ),
    );
  }
}
