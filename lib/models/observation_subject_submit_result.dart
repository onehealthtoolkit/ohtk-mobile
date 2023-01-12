import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/operation_exception_failure.dart';

abstract class SubjectRecordSubmitResult {}

class SubjectRecordSubmitSuccess extends SubjectRecordSubmitResult {
  final ObservationSubjectRecord _subject;

  SubjectRecordSubmitSuccess(this._subject);

  ObservationSubjectRecord get subject => _subject;
}

class SubjectRecordSubmitFailure extends OperationExceptionFailure
    with SubjectRecordSubmitResult {
  SubjectRecordSubmitFailure(e) : super(e);
}

class SubjectRecordSubmitPending extends SubjectRecordSubmitResult {}
