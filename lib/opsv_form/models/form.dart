part of opensurveillance_form;

var logger = Logger();

class Form {
  final logger = Logger();

  final String id;
  List<Section> sections = List.empty(growable: true);
  final Values values = Values();

  final Observable<int> _currentSectionIdx = Observable(0);

  Form(this.id);

  get numberOfSections => sections.length;

  get currentSectionIdx => _currentSectionIdx.value;

  Values _registerValues() {
    for (var section in sections) {
      section._registerValues(values, this);
    }
    return values;
  }

  factory Form.fromJson(Map<String, dynamic> json, [String? id]) {
    var form = Form(id ?? json["id"]);
    var jsonSections = json["sections"] as List;
    for (var jsonSection in jsonSections) {
      form.sections.add(Section.fromJson(jsonSection));
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
    return result;
  }

  Field? getField(name) {
    return values.getDelegate(name)?.getField();
  }

  IList<Condition> allConditions() {
    return ilist(sections).flatMap((section) => section.allConiditions());
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

  void next() {
    runInAction(() {
      if (couldGoToNextSection) {
        if (currentSection.validate()) {
          _currentSectionIdx.value++;
        }
      }
    });
  }
}
