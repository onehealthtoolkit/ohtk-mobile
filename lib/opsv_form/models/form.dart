part of opensurveillance_form;

var logger = Logger();

typedef SubformMap = Map<String, Form>;

class Form {
  final logger = Logger();

  final String id;
  final Map<String, dynamic> jsonDefinition;
  final bool testFlag;

  List<Section> sections = List.empty(growable: true);
  final Values values = Values();
  String _timezone = "";
  SubformMap subforms = {};

  final Observable<int> _currentSectionIdx = Observable(0);

  Form(this.id, {this.jsonDefinition = const {}, this.testFlag = false});

  get numberOfSections => sections.length;

  int get currentSectionIdx => _currentSectionIdx.value;
  set currentSectionIdx(int index) => _currentSectionIdx.value = index;

  Values _registerValues() {
    for (var section in sections) {
      section._registerValues(values, this);
    }
    return values;
  }

  setTimezone(String timezone) {
    _timezone = timezone;
  }

  factory Form.fromJson(Map<String, dynamic> json,
      [String? id, bool? testFlag]) {
    var form = Form(
      id ?? json["id"],
      jsonDefinition: json,
      testFlag: testFlag ?? false,
    );
    var jsonSections = (json["sections"] ?? []) as List;
    for (var jsonSection in jsonSections) {
      form.sections.add(Section.fromJson(jsonSection));
    }

    var jsonSubforms = (json["subforms"] ?? []) as List;
    for (var jsonSubform in jsonSubforms) {
      var subform = jsonSubform as Map<dynamic, dynamic>;
      for (var entry in subform.entries) {
        form.subforms[entry.key] =
            Form.fromJson(entry.value, entry.key, testFlag);
      }
    }

    form._registerValues();
    return form;
  }

  factory Form.withSection(id, List<Section> sections) {
    var form = Form(id);
    form.sections = sections;
    form._registerValues();
    return form;
  }

  void loadJsonValue(Map<String, dynamic> json) {
    for (var section in sections) {
      section.loadJsonValue(json);
    }
  }

  Map<String, dynamic> toJsonValue() {
    Map<String, dynamic> result = {};
    for (var section in sections) {
      section.toJsonValue(result);
    }
    result["tz"] = _timezone;
    return result;
  }

  Field? getField(name) {
    return values.getDelegate(name)?.getField();
  }

  IList<Condition> allConditions() {
    return ilist(sections).flatMap((section) => section.allConditions());
  }

  IList<Field> allFields() {
    return ilist(sections).flatMap((section) => section.allFields());
  }

  Field? findField(bool Function(Field) predicate) {
    var fields = allFields().toList();
    try {
      return fields.firstWhere(predicate);
    } catch (_) {
      return null;
    }
  }

  Computed<Section>? _currentSectionComputed;
  Section get currentSection => (_currentSectionComputed ??= Computed<Section>(
          () => sections[_currentSectionIdx.value],
          name: 'form.currentSection'))
      .value;

  Computed<bool>? _couldGoToNextSectionComputed;
  bool get couldGoToNextSection => (_couldGoToNextSectionComputed ??=
          Computed<bool>(() => _currentSectionIdx.value < sections.length - 1,
              name: 'form.couldGoToNextSection'))
      .value;

  Computed<bool>? _couldGoToPreviousSectionComputed;
  bool get couldGoToPreviousSection => (_couldGoToPreviousSectionComputed ??=
          Computed<bool>(() => _currentSectionIdx.value > 0,
              name: 'form.couldGoToPreviousSection'))
      .value;

  void previous() {
    runInAction(() {
      if (couldGoToPreviousSection) {
        _currentSectionIdx.value--;
      }
    });
  }

  bool next() {
    return runInAction(() {
      if (couldGoToNextSection) {
        var isValid = currentSection.validate();
        if (isValid) {
          _currentSectionIdx.value++;
        }
        return isValid;
      } else {
        return false;
      }
    });
  }
}
