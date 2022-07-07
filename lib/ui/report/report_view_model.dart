import 'package:podd_app/form/form_data/form_values/location_form_value.dart';
import 'package:podd_app/form/form_store.dart';
import 'package:podd_app/form/ui_definition/form_ui_definition.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:stacked/stacked.dart';
import 'package:uuid/uuid.dart';

enum ReportFormState {
  formInput,
  confirmation,
}

enum BackAction {
  navigationPop,
  doNothing,
}

var _uuid = const Uuid();

class ReportViewModel extends BaseViewModel {
  final IReportService _reportService = locator<IReportService>();

  final ReportType _reportType;
  ReportFormState state = ReportFormState.formInput;
  late String _reportId;
  late FormStore _formStore;
  bool? _incidentInAuthority;

  FormStore get formStore => _formStore;

  ReportViewModel(this._reportType) {
    _reportId = _uuid.v4();
    var uiDefinition = _reportType.formUIDefinition;
    _formStore = FormStore(_reportId, uiDefinition);
  }

  bool? get incidentInAuthority => _incidentInAuthority;

  set incidentInAuthority(bool? value) {
    _incidentInAuthority = value;
    notifyListeners();
  }

  BackAction back() {
    if (state == ReportFormState.formInput) {
      if (formStore.couldGoToPreviousSection) {
        formStore.previous();
      } else {
        return BackAction.navigationPop;
      }
    } else if (state == ReportFormState.confirmation) {
      state = ReportFormState.formInput;
      notifyListeners();
    }
    return BackAction.doNothing;
  }

  next() {
    if (state == ReportFormState.formInput) {
      if (formStore.couldGoToNextSection) {
        formStore.next();
      } else {
        if (formStore.validate()) {
          state = ReportFormState.confirmation;
          notifyListeners();
        }
      }
    } else {}
  }

  Future<ReportSubmitResult> submit() async {
    setBusy(true);

    String? gpsLocation;

    var locationFields = _reportType.formUIDefinition
        .find((FieldUIDefinition field, Question question) {
      return (field is LocationFieldUIDefinition);
    });
    if (locationFields.isNotEmpty) {
      var fieldName = locationFields.first.name;
      LocationFormValue formValue =
          _formStore.formData.values[fieldName]! as LocationFormValue;
      gpsLocation = formValue.toString();
    }

    var report = Report(
      id: _reportId,
      data: _formStore.formData.toJson(),
      reportTypeId: _reportType.id,
      incidentDate: DateTime.now(),
      gpsLocation: gpsLocation,
      incidentInAuthority: _incidentInAuthority,
    );

    var result = await _reportService.submit(report);

    setBusy(false);
    return result;
  }
}
