part of opensurveillance_form;

class Values {
  Values? parent;
  final Map<String, Either<Values, ValueDelegate>> values = {};

  Values({this.parent});

  List<String> get keys => values.keys.toList();

  ValueDelegate? getDelegate(String name) {
    var names = name.split(".");

    return values[names[0]]
        ?.fold((l) => l.getDelegate(names.sublist(1).join('.')), (r) => r);
  }

  setValues(String name, Values values) {
    this.values[name] = Left(values);
  }

  setValueDelegate(String name, ValueDelegate delegate) {
    values[name] = Right(delegate);
  }
}

typedef GetField = Field Function();

class ValueDelegate {
  GetField getField;

  ValueDelegate(this.getField);
}
