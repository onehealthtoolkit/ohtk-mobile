part of opensurveillance_form;

class FilesField extends Field {
  final _value = ObservableList<String>.of([]);
  final _fileNames = ObservableList<String>.of([]);

  int? min;
  int? max;
  int? maxSize; // max size per file in bytes, null for unlimit size
  List<String> supports; // supported mime types

  String? fileDir; // file directory: {appDataDir}/reports/{reportId}

  FilesField(
    String id,
    String name, {
    String? label,
    String? description,
    String? suffixLabel,
    bool? required,
    String? requiredMessage,
    this.min,
    this.max,
    this.maxSize = 1000,
    this.supports = const [],
    Condition? condition,
    String? tags,
  }) : super(id, name,
            label: label,
            description: description,
            suffixLabel: suffixLabel,
            required: required,
            requiredMessage: requiredMessage,
            condition: condition,
            tags: tags) {
    init();
  }

  init() async {
    final directory = await getApplicationDocumentsDirectory();
    fileDir = '${directory.path}/reports/${form.id}';
  }

  factory FilesField.fromJson(Map<String, dynamic> json) {
    var condition = parseConditionFromJson(json);

    return FilesField(
      json["id"],
      json["name"],
      label: json["label"],
      description: json["description"],
      suffixLabel: json["suffixLabel"],
      required: json["required"],
      requiredMessage: json["requiredMessage"],
      min: json["min"],
      max: json["max"],
      maxSize: json["maxSize"],
      supports: (json["supports"] as List).cast<String>(),
      condition: condition,
      tags: json["tags"],
    );
  }

  add(String fileId, String fileName) {
    runInAction(() {
      clearError();
      _value.add(fileId);
      _fileNames.add(fileName);
    });
  }

  remove(String fileId) {
    runInAction(() {
      clearError();
      var idx = _value.indexWhere((element) => element == fileId);
      _value.removeAt(idx);
      _fileNames.removeAt(idx);
    });
  }

  @override
  List<String> get value => _value;
  set value(List<String> ary) {
    runInAction(() {
      _value.clear();
      _value.addAll(ary);
    });
  }

  List<String> get fileNames => _fileNames;
  set fileNames(List<String> ary) {
    runInAction(() {
      _fileNames.clear();
      _fileNames.addAll(ary);
    });
  }

  int get length => _value.length;

  @override
  bool _validate() {
    return runInAction(() {
      clearError();
      var validateFns = ilist([
        _validateRequired,
        _validateNotEmpty,
        _validateMin,
        _validateMax,
        _validateMaxSize,
        _validateSupportedType,
      ]);
      return validateFns.all((fn) => fn());
    });
  }

  _validateNotEmpty() {
    if (required == true && _value.isEmpty) {
      final localize = locator<AppLocalizations>();
      markError(localize.validateRequiredMsg);
      return false;
    }
    _invalidMessage.value = null;
    return true;
  }

  bool _validateMin() {
    if (min != null) {
      var valid = value.length >= min!;
      if (!valid) {
        final localize = locator<AppLocalizations>();
        markError(localize.filesFieldMinErrorMsg(displayName, min!.toString()));
        return false;
      }
    }
    return true;
  }

  bool _validateMax() {
    if (max != null) {
      var valid = value.length <= max!;
      if (!valid) {
        final localize = locator<AppLocalizations>();
        markError(localize.filesFieldMaxErrorMsg(displayName, max!.toString()));
        return false;
      }
    }
    return true;
  }

  bool _validateMaxSize() {
    if (maxSize != null) {
      var valid = true;
      var index = 0;
      var invalidIndice = [];

      for (String id in value) {
        index++;
        var size = _getFileSize(id);
        valid = size <= maxSize!;
        if (!valid) {
          invalidIndice.add(index);
        }
      }
      if (invalidIndice.isNotEmpty) {
        final localize = locator<AppLocalizations>();
        markError(
          localize.filesFieldMaxSizeErrorMsg(
            invalidIndice.join(','),
            displayName,
            maxSize!.toString(),
          ),
        );
        return false;
      }
    }
    return true;
  }

  bool _validateSupportedType() {
    if (supports.isNotEmpty) {
      var valid = true;
      var index = 0;
      var invalidIndice = [];

      for (String id in value) {
        index++;
        var mime = _getFileMimeType(id);
        valid = mime != null ? supports.contains(mime) : false;
        if (!valid) {
          invalidIndice.add(index);
        }
      }
      if (invalidIndice.isNotEmpty) {
        final localize = locator<AppLocalizations>();
        markError(
          localize.filesFieldSupportedTypeErrorMsg(
            invalidIndice.join(','),
            displayName,
          ),
        );
        return false;
      }
    }
    return true;
  }

  int _getFileSize(String fileId) {
    if (fileDir != null) {
      try {
        var f = File('$fileDir/$fileId');
        return f.lengthSync();
      } catch (e) {
        /// skip, no file
      }
    }
    return 0;
  }

  String? _getFileMimeType(String fileId) {
    String? mime;
    if (fileDir != null) {
      try {
        mime = lookupMimeType('$fileDir/$fileId');
      } catch (e) {
        /// skip, no file
      }
    }
    return mime;
  }

  @override
  bool evaluate(ConditionOperator operator, String targetValue) {
    throw UnimplementedError();
  }

  @override
  void loadJsonValue(Map<String, dynamic> json) {
    if (json[name] != null) {
      (json[name] as Map<String, dynamic>).entries.toList().forEach((element) {
        add(element.value, element.key);
      });
    }
  }

  @override
  void toJsonValue(Map<String, dynamic> aggregateResult) {
    Map<String, dynamic> json = {};
    int i = 0;
    for (var id in value) {
      json[fileNames[i]] = id;
      i++;
    }
    aggregateResult[name] = json;
    aggregateResult["${name}__value"] = renderedValue;
  }

  @override
  String get renderedValue {
    var result = [];
    int i = 0;
    for (var e in value) {
      result.add("${fileNames[i]} ($e)");
      i++;
    }
    return result.join(", ");
  }
}
