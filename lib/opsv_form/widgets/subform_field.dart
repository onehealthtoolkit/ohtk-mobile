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
        padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 8.w),
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
          key: Key(subform.ref.id),
          onDismissed: (direction) {
            field.deleteFormRecord(subform);
          },
          child: GestureDetector(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.only(top: 8.0.w),
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

  Row _titleDesc(BuildContext context, int index) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.forms[index].evaluatedTitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 15.sp),
              ),
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
        IconButton(
          onPressed: () {},
          icon: Icon(
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
  final TextEditingController _textFieldController = TextEditingController();

  Future<void> _showNameInputDialog(BuildContext context) async {
    _textFieldController.clear();

    return showDialog(
        context: context,
        builder: (context) {
          return Observer(builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Add new sub-form record'),
              content: TextField(
                onChanged: (value) {
                  widget.field.setError();
                },
                controller: _textFieldController,
                decoration: InputDecoration(
                  hintText: "Enter record name (no spacing)",
                  errorText: widget.field.error.value.isNotEmpty
                      ? widget.field.error.value
                      : null,
                ),
              ),
              actions: <Widget>[
                FlatButton.outline(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                FlatButton.primary(
                    onPressed: () {
                      var name = _textFieldController.text;
                      var subform = widget.field.addForm(name);

                      if (subform != null) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => SubformFormView(
                                  widget.field.form.testFlag,
                                  name,
                                  subform.ref)),
                        );
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.ok)),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: appTheme.primary),
        borderRadius: BorderRadius.circular(appTheme.borderRadius),
      ),
      padding: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 8.w),
      margin: EdgeInsets.only(bottom: 8.w),
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
                _showNameInputDialog(context);
              },
              child: Icon(Icons.add, size: 16.w),
            ),
          ),
        ],
      ),
    );
  }
}
