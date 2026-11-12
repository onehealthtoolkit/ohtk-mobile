import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/operation_exception_failure.dart';
import 'package:podd_app/models/submission_problem.dart';

abstract class SubjectRecordSubmitResult {}

class SubjectRecordSubmitSuccess extends SubjectRecordSubmitResult {
  final ObservationSubjectRecord _subject;

  int pendingAttachments = 0;
  final attachmentProblems = <String, SubmissionProblem>{};

  SubjectRecordSubmitSuccess(this._subject);

  ObservationSubjectRecord get subject => _subject;
}

class SubjectRecordSubmitFailure extends OperationExceptionFailure
    implements SubjectRecordSubmitResult {
  final SubmissionProblem? problem;
  SubjectRecordSubmitFailure(e, {this.problem}) : super(e);
}

class SubjectRecordSubmitPending extends SubjectRecordSubmitResult {
  final SubmissionProblem? problem;
  SubjectRecordSubmitPending([this.problem]);
}
