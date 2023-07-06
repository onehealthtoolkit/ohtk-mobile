import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  late FilesField field;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    locator.registerSingletonAsync<AppLocalizations>(() async {
      return AppLocalizations.delegate.load(const material.Locale('en'));
    });

    /// Fix MissingPluginException
    /// FilesField has used library 'path_provider'
    /// implementing 'getApplicationDocumentsDirectory' to save local files
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return ".";
    });
  });

  group("json value", () {
    setUp(() {
      field = FilesField("id", "files");
      field.form = Form('id');
    });

    test("to json with value", () {
      var ary = ["123.png", "222.png"];
      field.value = ary;
      field.fileNames = ary;
      Map<String, dynamic> json = {};
      field.toJsonValue(json);

      expect(json["files"], {
        "123.png": "123.png",
        "222.png": "222.png",
      });
      expect(json["files__value"], "123.png (123.png), 222.png (222.png)");
    });

    test("to json without value", () {
      Map<String, dynamic> json = {};
      field.toJsonValue(json);
      expect(json["files"], {});
      expect(json["files__value"], isEmpty);
    });

    test("load json data", () {
      var ary = ["123.png", "222.png"];
      var map = {
        "123.png": "123.png",
        "222.png": "222.png",
      };
      field.loadJsonValue({"files": map});
      expect(field.value, ary);
    });

    test("init from json definition", () {
      var field = FilesField.fromJson(
          {"id": "1", "name": "files", "required": true, 'supports': []});
      field.form = Form('id');
      expect(field.name, "files");
      expect(field.required, isTrue);
    });
  });

  group("validation", () {
    test("required", () {
      field = FilesField("id", "files");
      field.form = Form('id');
      expect(field.validate(), isTrue);

      field = FilesField("id", "files", required: true);
      field.form = Form('id');
      expect(field.validate(), isFalse);
      field.value = ["tt.png"];
      expect(field.validate(), isTrue);
    });

    test("min value", () {
      field = FilesField("id", "files", min: 2, minMessage: "test_min_message");
      field.form = Form('id');
      expect(field.validate(), isFalse);
      expect(field.invalidMessage, "test_min_message");
      field.value = ["tt.png"];
      expect(field.validate(), isFalse);
      field.add("me.png", "me.png");
      expect(field.validate(), isTrue);
    });

    test("max value", () {
      field = FilesField("id", "files", max: 2, maxMessage: "test_max_message");
      field.form = Form('id');
      expect(field.validate(), isTrue);
      field.value = ["tt.png"];
      expect(field.validate(), isTrue);
      field.add("me.png", "me.png");
      expect(field.validate(), isTrue);
      field.add("test1.png", "test1.png");
      expect(field.validate(), isFalse);
      expect(field.invalidMessage, "test_max_message");
    });

    test("min, max value", () {
      field = FilesField("id", "files",
          min: 1,
          minMessage: "test_min_message",
          max: 2,
          maxMessage: "test_max_message");
      field.form = Form('id');
      expect(field.validate(), isFalse);
      expect(field.invalidMessage, "test_min_message");
      field.value = ["tt.png"];
      expect(field.validate(), isTrue);
      expect(field.invalidMessage, isNull);
      field.add("me.png", "me.png");
      expect(field.validate(), isTrue);
      expect(field.invalidMessage, isNull);
      field.add("test1.png", "test1.png");
      expect(field.validate(), isFalse);
      expect(field.invalidMessage, "test_max_message");
    });
  });
}
