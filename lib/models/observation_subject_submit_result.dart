import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/operation_exception_failure.dart';

abstract class ObservationSubjectSubmitResult {}

class ObservationSubjectSubmitSuccess extends ObservationSubjectSubmitResult {
  final ObservationSubject _subject;

  ObservationSubjectSubmitSuccess(this._subject);

  ObservationSubject get subject => _subject;
}

class ObservationSubjectSubmitFailure extends OperationExceptionFailure
    with ObservationSubjectSubmitResult {
  ObservationSubjectSubmitFailure(e) : super(e);
}

class ObservationSubjectSubmitPending extends ObservationSubjectSubmitResult {}
