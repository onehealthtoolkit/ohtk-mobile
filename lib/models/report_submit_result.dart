import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/models/operation_exception_failure.dart';

abstract class ReportSubmitResult {}

class ReportSubmitSuccess extends ReportSubmitResult {
  final IncidentReport _incidentReport;

  ReportSubmitSuccess(this._incidentReport);

  IncidentReport get incidentReport => _incidentReport;
}

class ReportSubmitFailure extends OperationExceptionFailure
    with ReportSubmitResult {
  ReportSubmitFailure(e) : super(e);
}

class ReportSubmitPending extends ReportSubmitResult {}
