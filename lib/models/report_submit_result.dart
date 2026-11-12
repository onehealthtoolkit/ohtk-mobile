import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/models/operation_exception_failure.dart';
import 'package:podd_app/models/submission_problem.dart';

abstract class ReportSubmitResult {}

class ReportSubmitSuccess extends ReportSubmitResult {
  final IncidentReport _incidentReport;

  int pendingAttachments = 0;
  final attachmentProblems = <String, SubmissionProblem>{};

  ReportSubmitSuccess(this._incidentReport);

  IncidentReport get incidentReport => _incidentReport;
}

class ReportSubmitFailure extends OperationExceptionFailure
    implements ReportSubmitResult {
  final SubmissionProblem? problem;
  ReportSubmitFailure(e, {this.problem}) : super(e);
}

class ReportSubmitPending extends ReportSubmitResult {
  final SubmissionProblem? problem;
  ReportSubmitPending([this.problem]);
}

class ZeroReportSubmitSuccess extends ReportSubmitResult {
  final String _id;

  ZeroReportSubmitSuccess(this._id);

  String get id => _id;
}

class ZeroReportSubmitFailure extends ReportSubmitFailure {
  ZeroReportSubmitFailure(e) : super(e);
}
