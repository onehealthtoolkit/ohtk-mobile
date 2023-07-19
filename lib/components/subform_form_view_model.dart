import 'package:podd_app/opsv_form/opsv_form.dart';
import 'package:podd_app/ui/report/form_base_view_model.dart';

class SubformFormViewModel extends FormBaseViewModel {
  final bool _testFlag;
  final String _name;
  final Form _form;

  SubformFormViewModel(this._testFlag, this._name, this._form) : super() {
    init();
  }

  init() {
    isReady = true;
  }

  @override
  Form get formStore => _form;

  String get formName => _name;

  @override
  bool get isTestMode => _testFlag;

  submit() {
    /// Do nothing here, all form values are already stored in Form object
  }
}
