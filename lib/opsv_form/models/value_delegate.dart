part of opensurveillance_form;

class Values {
  Values? parent;
  final Map<String, Either<Values, ValueDelegate>> values = {};

  Values({this.parent});

  List<String> get keys => values.keys.toList();

  ValueDelegate? getDelegate(String id) {
    var names = id.split(".");

    return values[names[0]]
        ?.fold((l) => l.getDelegate(names.sublist(1).join('.')), (r) => r);
  }

  setValues(String id, Values values) {
    this.values[id] = Left(values);
  }

  setValueDelegate(String id, ValueDelegate delegate) {
    values[id] = Right(delegate);
  }
}

typedef GetField = Field Function();

class ValueDelegate {
  GetField getField;

  ValueDelegate(this.getField);
}
