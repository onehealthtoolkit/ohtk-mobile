part of opensurveillance_form;

class DateField extends Field {
  final Observable<int?> _day = Observable(null);
  final Observable<int?> _month = Observable(null);
  final Observable<int?> _year = Observable(null);
  final Observable<int?> _hour = Observable(null);
  final Observable<int?> _minute = Observable(null);

  bool withTime;
  bool separatedFields;
  int? backwardDaysOffset;
  int? forwardDaysOffset;

  DateField(
    String id,
    String name, {
    String? label,
    String? description,
    String? suffixLabel,
    bool? required,
    String? requiredMessage,
    this.withTime = false,
    this.separatedFields = false,
    this.backwardDaysOffset,
    this.forwardDaysOffset,
    Condition? condition,
  }) : super(id, name,
            label: label,
            description: description,
            suffixLabel: suffixLabel,
            required: required,
            requiredMessage: requiredMessage,
            condition: condition) {
    var now = DateTime.now();
    _day.value = now.day;
    _month.value = now.month;
    _year.value = now.year;
    if (withTime) {
      _hour.value = now.hour;
      _minute.value = now.minute;
    }
  }

  factory DateField.fromJson(Map<String, dynamic> json) {
    var condition = parseConditionFromJson(json);

    return DateField(
      json["id"],
      json["name"],
      label: json["label"],
      description: json["description"],
      suffixLabel: json["suffixLabel"],
      required: json["required"],
      requiredMessage: json["requiredMessage"],
      withTime: json["withTime"] ?? false,
      separatedFields: json["separatedFields"] ?? false,
      backwardDaysOffset: json["backwardDaysOffset"],
      forwardDaysOffset: json["forwardDaysOffset"],
      condition: condition,
    );
  }

  int? get day => _day.value;

  set day(value) {
    runInAction(() {
      _day.value = value;
      if (!isValid) clearError();
    });
  }

  int? get month => _month.value;

  set month(value) {
    runInAction(() {
      _month.value = value;
      if (!isValid) clearError();
    });
  }

  int? get year => _year.value;

  set year(value) {
    runInAction(() {
      _year.value = value;
      if (!isValid) clearError();
    });
  }

  int? get hour => _hour.value;

  set hour(value) {
    runInAction(() {
      _hour.value = value;
      if (!isValid) clearError();
    });
  }

  int? get minute => _minute.value;

  set minute(value) {
    runInAction(() {
      _minute.value = value;
      if (!isValid) clearError();
    });
  }

  @override
  DateTime? get value {
    if (_year.value == null ||
        _month.value == null ||
        _day.value == null ||
        (withTime && _hour.value == null && _minute.value == null)) {
      return null;
    }

    if (withTime) {
      return DateTime(_year.value!, _month.value!, _day.value!, _hour.value!,
          _minute.value!);
    } else {
      return DateTime(_year.value!, _month.value!, _day.value!);
    }
  }

  set value(DateTime? v) {
    if (v != null) {
      runInAction(() {
        _day.value = v.day;
        _month.value = v.month;
        _year.value = v.year;
        if (withTime) {
          _hour.value = v.hour;
          _minute.value = v.minute;
        }
      });
    }
  }

  @override
  bool _validate() {
    return runInAction(() {
      clearError();
      var validateFns = ilist([
        _validateRequired,
        _validateMin,
        _validateMax,
      ]);
      return validateFns.all((fn) => fn());
    });
  }

  bool _validateMin() {
    if (value == null && required == true) {
      return false;
    }
    if (backwardDaysOffset != null) {
      if (value != null) {
        DateTime minDate;
        var now = DateTime.now();

        if (withTime) {
          minDate = now;
        } else {
          minDate = DateTime(now.year, now.month, now.day);
        }
        minDate = minDate.subtract(Duration(days: backwardDaysOffset!));

        var valid =
            value!.millisecondsSinceEpoch >= minDate.millisecondsSinceEpoch;
        if (!valid) {
          markError(
            formatWithMap(
              "{name} must be equal or more than {min}",
              {
                "name": name,
                "min": minDate.toIso8601String(),
              },
            ),
          );
          return false;
        }
      }
    }
    return true;
  }

  bool _validateMax() {
    if (value == null && required == true) {
      return false;
    }
    if (forwardDaysOffset != null) {
      if (value != null) {
        DateTime maxDate;
        var now = DateTime.now();

        if (withTime) {
          maxDate = now;
        } else {
          maxDate = DateTime(now.year, now.month, now.day);
        }
        maxDate = maxDate.add(Duration(days: forwardDaysOffset!));

        var valid =
            value!.millisecondsSinceEpoch <= maxDate.millisecondsSinceEpoch;
        if (!valid) {
          markError(
            formatWithMap(
              "{name} must be equal or less than {max}",
              {
                "name": name,
                "max": maxDate.toIso8601String(),
              },
            ),
          );
          return false;
        }
      }
    }
    return true;
  }

  @override
  bool evaluate(ConditionOperator operator, String targetValue) {
    switch (operator) {
      case ConditionOperator.equal:
        return value?.toIso8601String() == targetValue;
      case ConditionOperator.contain:
        return value?.toIso8601String().contains(targetValue) ?? false;
      default:
        return false;
    }
  }

  @override
  void loadJsonValue(Map<String, dynamic> json) {
    if (json[name] != null) {
      var givenDate = DateTime.parse(json[name]);
      value = givenDate;
    }
  }

  @override
  void toJsonValue(Map<String, dynamic> aggregateResult) {
    aggregateResult[name] = value?.toIso8601String();
  }
}
